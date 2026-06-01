# BoneGuard — Plataforma de Rastreio e Prevenção de Osteoporose

> **Global Solution 2026/1 — Java Advanced | FIAP**  
> Tema: O Espaço é a Nova Fronteira — protocolos NASA de preservação óssea adaptados para pacientes terrestres.

---

## Arquitetura dos Microserviços

```
┌──────────────────────────────────────────────────────────────────────────┐
│                      CLIENTES (Mobile / Web / MCP)                       │
└────────────────┬──────────────────────────────┬──────────────────────────┘
                 │ HTTP + JWT                    │ MCP (SSE)
                 ▼                               ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                    boneguard-service  (porta 8080)                        │
│                                                                           │
│  Controllers (REST + HATEOAS + Swagger)                                   │
│  ├── AuthController        POST /auth/register, POST /auth/login          │
│  ├── PacienteController    POST/GET/PUT /pacientes                        │
│  ├── AvaliacaoController   POST/GET /avaliacoes                           │
│  ├── RadiografiaController POST /radiografias/upload                      │
│  ├── PlanoSaudeController  GET /planos/paciente, POST /planos/gerar       │
│  ├── AlertaController      GET /alertas/paciente, PATCH /alertas/lido     │
│  ├── EvolucaoController    GET/POST /evolucao                             │
│  └── RagController         GET /rag/consultar  ◄── RAG                   │
│                                                                           │
│  Spring AI                                                                │
│  ├── PlanoAIService   — Tooling (@Tool x3) + ChatClient → Groq/LLM       │
│  ├── NasaRagService   — RAG (keyword retrieval + augmented generation)    │
│  └── McpToolsConfig   — MCP Server expõe as 3 tools via SSE /mcp/sse     │
│                                                                           │
│  Integrações                                                              │
│  ├── VisionServiceClient — Feign → API Python /analisar-radiografia       │
│  └── AlertaPublisher     — RabbitMQ → fila boneguard.alertas              │
│                                                                           │
│  Infraestrutura                                                           │
│  ├── Security: JWT Filter + BCrypt + UserDetailsService                   │
│  ├── Cache:    @Cacheable("planos-paciente")                              │
│  └── CORS:     origens configuráveis via env var                          │
└───────────────┬──────────────────────────┬───────────────────────────────┘
                │ Oracle JDBC              │ RabbitMQ
                ▼                          ▼
┌───────────────────────┐  ┌───────────────────────────────────────────────┐
│    Oracle Database    │  │      notification-service  (porta 8081)        │
│                       │  │                                                │
│  TB_PACIENTE_BG       │  │  AlertaConsumer                                │
│  TB_AVALIACAO_BG      │  │  └── @RabbitListener(boneguard.alertas)        │
│  TB_RADIOGRAFIA_BG    │  │      Persiste Alerta com status PENDENTE       │
│  TB_PLANO_SAUDE_BG    │  └───────────────────────────────────────────────┘
│  TB_EVOLUCAO_BG       │
│  TB_ALERTA_BG         │
│  TB_USUARIO_BG        │
└───────────────────────┘
```

---

## Requisitos Implementados

| Requisito | Implementação |
|-----------|---------------|
| API REST + boas práticas | Controllers com DTOs, interfaces de service, exception handler global (`GlobalExceptionHandler`) |
| Persistência relacional | Oracle 19c via Spring Data JPA — todas as entidades mapeadas |
| Spring Security + JWT | `JwtAuthenticationFilter`, `JwtService`, rotas `/auth/**` e `/rag/**` públicas |
| Controle de acesso por role | `ROLE_ADMIN` (médico) e `ROLE_USER` (paciente) — restrição via `SecurityConfig` + `@PreAuthorize` |
| Flyway | Migrations versionadas (`V1` DDL · `V2` ALTER TABLE · `V3` seed) — schema criado e populado automaticamente na inicialização |
| HATEOAS | Todos os 6 controllers de domínio retornam `_links` via `RepresentationModel` |
| Cache | `@Cacheable("planos-paciente")` + `@CacheEvict` em `PlanoSaudeServiceImpl` |
| CORS | `CorsConfig` com origens configuráveis via `cors.allowed-origins` |
| Swagger / OpenAPI | `@Tag` e `@Operation` em todos os controllers — acesse `/swagger-ui.html` |
| Microserviços | `boneguard-service` (domínio) + `notification-service` (alertas) — ver justificativa abaixo |
| Mensageria (RabbitMQ) | `AlertaPublisher` publica eventos; `notification-service` consome e persiste |
| Funcionalidade REAL | Avaliação de risco ósseo → classificação → alerta → geração de plano personalizado por IA |
| OpenFeign | `VisionServiceClient` com `VisionServiceFallback` — ver justificativa abaixo |
| Spring AI — Tooling | `PlanoAIService` com 3 `@Tool` (perfil, histórico, protocolo NASA) via `ToolCallbacks.from()` |
| Spring AI — RAG | `NasaRagService`: keyword retrieval em 5 documentos NASA → augmented generation via ChatClient |
| Spring AI — MCP | `McpToolsConfig` registra as 3 tools como MCP tools — endpoint SSE em `/mcp/sse` |

---

## Justificativas

### Arquitetura de Microserviços

O BoneGuard foi dividido em dois serviços porque as responsabilidades são **distintas e com ciclos de vida independentes**:

- **`boneguard-service`** — domínio principal: pacientes, avaliações, planos, radiografias. Escala conforme volume de requisições e processamento de IA.
- **`notification-service`** — responsável exclusivamente por processar e persistir alertas via RabbitMQ. Pode escalar separadamente em cenários de alto volume de alertas; uma falha isolada nele não derruba o serviço principal.

A comunicação via **RabbitMQ** é assíncrona: o `boneguard-service` publica o evento e continua sua execução sem aguardar resposta, garantindo **desacoplamento real** entre os serviços.

### OpenFeign como cliente HTTP

O `VisionServiceClient` usa **OpenFeign** para consumir a API Python de análise de radiografias. A escolha se justifica por:

1. **Interface declarativa** — elimina todo o boilerplate de `RestTemplate` ou `WebClient`; o contrato HTTP é expresso como um método Java simples.
2. **Resiliência com fallback** — `fallback = VisionServiceFallback.class` garante que, se a API de visão estiver fora do ar, o sistema retorna um resultado padrão sem expor erro ao usuário.
3. **Configuração por env var** — `${VISION_SERVICE_URL}` permite apontar para diferentes ambientes sem alteração de código.

---

## Endpoints

### Autenticação (público)
```
POST /auth/register   Body: { "email": "...", "senha": "..." }
POST /auth/login      Body: { "email": "...", "senha": "..." }
```

### Pacientes `(Bearer token obrigatório)`
```
GET    /pacientes              ← ADMIN apenas
POST   /pacientes
GET    /pacientes/{id}
PUT    /pacientes/{id}
DELETE /pacientes/{id}         ← ADMIN apenas
```

### Avaliações
```
POST   /avaliacoes
GET    /avaliacoes/{id}
GET    /avaliacoes/paciente/{pacienteId}
```

### Radiografias
```
POST   /radiografias/upload   multipart/form-data  [avaliacaoId, imagem]
```

### Planos de Saúde
```
GET    /planos/paciente/{pacienteId}    (cache habilitado)
POST   /planos/gerar/{avaliacaoId}      (Spring AI Tooling + protocolos NASA)
```

### Alertas
```
GET    /alertas/paciente/{pacienteId}
PATCH  /alertas/{id}/lido
```

### Evolução
```
GET    /evolucao/{pacienteId}
POST   /evolucao
```

### RAG — Consulta Inteligente
```
GET    /rag/consultar?pergunta=...
```
Exemplos de perguntas:
- `"Qual a dose de cálcio recomendada pela NASA?"`
- `"Que exercícios o protocolo ARED indica?"`
- `"Como interpretar o score de risco ósseo?"`

### MCP Server (Model Context Protocol)
```
GET    /mcp/sse       Conexão SSE para clientes MCP (Claude Desktop, Cursor, etc.)
POST   /mcp/message   Envio de mensagens MCP
```
Tools expostas via MCP: `buscarPerfilPaciente`, `buscarHistoricoAvaliacoes`, `buscarProtocoloNASA`

### Documentação
```
GET    /swagger-ui.html
GET    /v3/api-docs
GET    /actuator/health
```

---

## Como Rodar

### Pré-requisitos
- JDK 17+
- Maven 3.8+
- Oracle 19c+ acessível — **as tabelas são criadas automaticamente pelo Flyway na primeira inicialização**
- RabbitMQ 3.13+
- Chave Groq gratuita em [console.groq.com](https://console.groq.com)

### Usuários seed (criados pelo Flyway automaticamente)

| Role | E-mail | Senha |
|------|--------|-------|
| `ADMIN` | `admin@boneguard.com` | `admin123` |
| `USER` | `paciente@boneguard.com` | `user123` |

### 1. Subir com Docker Compose

```bash
cp .env.example .env
# Edite o .env com suas credenciais
docker compose up -d
```

### 2. Subir manualmente (desenvolvimento)

```bash
# Terminal 1 — RabbitMQ
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.13-management

# Terminal 2 — boneguard-service
cd boneguard-service
mvn spring-boot:run

# Terminal 3 — notification-service
cd notification-service
mvn spring-boot:run
```

---

## Variáveis de Ambiente

| Variável | Descrição | Default |
|----------|-----------|---------|
| `DATASOURCE_URL` | JDBC URL do Oracle | `jdbc:oracle:thin:@oracle.fiap.com.br:1521:orcl` |
| `DB_USERNAME` | Usuário Oracle | `rm560027` |
| `DB_PASSWORD` | Senha Oracle | — |
| `JWT_SECRET` | Chave secreta JWT (mín 32 chars) | *(definir em produção)* |
| `JWT_EXPIRATION_MS` | Expiração do token em ms | `86400000` (24h) |
| `RABBITMQ_HOST` | Host do RabbitMQ | `localhost` |
| `RABBITMQ_USER` | Usuário RabbitMQ | `guest` |
| `RABBITMQ_PASS` | Senha RabbitMQ | `guest` |
| `VISION_SERVICE_URL` | URL da API Python de visão | `http://localhost:5000` |
| `GROQ_API_KEY` | Chave da API Groq (Spring AI) | *(obrigatório)* |

---

## Fluxo Completo — Exemplo

```bash
# Login como admin
TOKEN_ADMIN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@boneguard.com","senha":"admin123"}' | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# Login como paciente
TOKEN_USER=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"paciente@boneguard.com","senha":"user123"}' | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

TOKEN=$TOKEN_ADMIN  # usar admin para os exemplos abaixo

# Cadastrar paciente
curl -s -X POST http://localhost:8080/pacientes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"nome":"Maria Silva","idade":65,"sexo":"F","peso":58.5,
       "historicoFamiliar":true,"nivelAtividade":"SEDENTARIO","alimentacaoCalcio":false}'

# Criar avaliação (score >= 70 dispara alerta via RabbitMQ)
curl -s -X POST http://localhost:8080/avaliacoes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"pacienteId":1,"scoreRisco":82.5}'

# Gerar planos com Spring AI Tooling (protocolos NASA)
curl -s -X POST http://localhost:8080/planos/gerar/1 \
  -H "Authorization: Bearer $TOKEN"

# Consultar base de conhecimento via RAG
curl -s "http://localhost:8080/rag/consultar?pergunta=Qual+a+dose+de+calcio+recomendada" \
  -H "Authorization: Bearer $TOKEN"
```

---

## Classificação de Risco

| Score | Classificação | Ação automática |
|-------|---------------|-----------------|
| 0 – 29.9 | BAIXO | Nenhuma |
| 30 – 69.9 | MODERADO | Nenhuma |
| 70 – 100 | ALTO | Publica `AlertaEvent` na fila RabbitMQ → `notification-service` persiste alerta |

---

## Testes

Testes de unidade com JUnit 5 + Mockito + AssertJ:

```bash
cd boneguard-service
mvn test
```

| Classe de teste | Cobertura |
|----------------|-----------|
| `AvaliacaoServiceImplTest` | 9 testes — score BAIXO/MODERADO/ALTO, validações, alerta RabbitMQ, data, histórico |
| `PacienteServiceImplTest` | 6 testes — criar, buscar existente/inexistente, atualizar dados/inexistente |

---

## Estrutura do Repositório

```
.
├── boneguard-service/          # Serviço principal
│   └── src/
│       ├── main/java/.../
│       │   ├── configs/        # CacheConfig, CorsConfig, McpToolsConfig, OpenApiConfig, RabbitMQConfig, SecurityConfig
│       │   ├── controller/     # AuthController, PacienteController, AvaliacaoController,
│       │   │                   # RadiografiaController, PlanoSaudeController, AlertaController,
│       │   │                   # EvolucaoController, RagController
│       │   ├── service/        # PlanoAIService (Tooling), NasaRagService (RAG), demais services
│       │   ├── external_interface/
│       │   │   ├── feign/      # VisionServiceClient + Fallback
│       │   │   └── rabbitmq/   # AlertaPublisher
│       │   ├── security/       # JwtService, JwtAuthenticationFilter
│       │   └── entities/       # Paciente, Avaliacao, Radiografia, PlanoSaude, Evolucao, Alerta
│       └── test/java/.../
│           └── service/        # AvaliacaoServiceImplTest, PacienteServiceImplTest
├── notification-service/       # Serviço de notificações
│   └── src/main/java/.../
│       └── consumer/           # AlertaConsumer (@RabbitListener)
├── db/
│   ├── ddl/01_create_tables.sql
│   ├── dml/02_insert_data.sql
│   ├── plsql/                  # Functions, Procedures, Triggers, Package, Blocos, Cursores, Relatórios
│   └── nosql/10_modelo_json.md
└── docker-compose.yml
```
