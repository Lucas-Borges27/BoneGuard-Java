# BoneGuard — Plataforma de Rastreio e Prevenção de Osteoporose

> **Global Solution 2026/1 — Java Advanced | FIAP**
> Tema: _O Espaço é a Nova Fronteira_ — protocolos NASA de preservação óssea adaptados para pacientes terrestres.

---

## Sumário

1. [Contexto e Problema](#1-contexto-e-problema)
2. [Solução](#2-solução)
3. [Arquitetura](#3-arquitetura)
4. [Stack Tecnológica](#4-stack-tecnológica)
5. [Requisitos Implementados](#5-requisitos-implementados)
6. [Modelo de Dados](#6-modelo-de-dados)
7. [Referência da API](#7-referência-da-api)
8. [Spring AI — RAG, Tooling e MCP](#8-spring-ai--rag-tooling-e-mcp)
9. [Mensageria — RabbitMQ + CloudAMQP](#9-mensageria--rabbitmq--cloudamqp)
10. [Segurança](#10-segurança)
11. [Implantação — Azure + CI/CD](#11-implantação--azure--cicd)
12. [Como Rodar Localmente](#12-como-rodar-localmente)
13. [Variáveis de Ambiente](#13-variáveis-de-ambiente)
14. [Fluxo Completo com cURL](#14-fluxo-completo-com-curl)
15. [Testes](#15-testes)
16. [Estrutura do Repositório](#16-estrutura-do-repositório)
17. [Justificativas de Arquitetura](#17-justificativas-de-arquitetura)

---

## 1. Contexto e Problema

A osteoporose afeta mais de 200 milhões de pessoas no mundo e é responsável por fraturas que reduzem drasticamente a qualidade de vida — especialmente em idosos. O diagnóstico costuma chegar tarde, quando a perda óssea já é severa.

A NASA enfrenta um problema análogo: astronautas em microgravidade perdem de **1 a 2% da massa óssea por mês** — o equivalente ao que um paciente com osteoporose perde em um ano na Terra. Para combater isso, a agência desenvolveu protocolos rigorosos de exercício (ARED) e nutrição que comprovadamente preservam a densidade óssea.

## 2. Solução

O **BoneGuard** é uma plataforma de saúde que:

- Registra pacientes e aplica um **score de risco ósseo** (0–100) baseado em fatores clínicos
- Classifica o risco automaticamente e **dispara alertas** para casos críticos via mensageria assíncrona
- Analisa **radiografias** por IA (API de visão computacional externa)
- Gera **planos personalizados de exercício e nutrição** usando Spring AI com os protocolos NASA como base de conhecimento
- Disponibiliza uma **interface RAG** para consultas em linguagem natural sobre saúde óssea
- Expõe **tools MCP** para integração com agentes de IA externos (Claude Desktop, Cursor, etc.)

---

## 3. Arquitetura

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    CLIENTES (Mobile / Web / MCP Agents)                 │
└───────────────┬────────────────────────────────┬────────────────────────┘
                │ HTTPS + JWT                    │ MCP over SSE
                ▼                                ▼
┌─────────────────────────────────────────────────────────────────────────┐
│          boneguard-service  — Azure Web App (gs-app-boneguard)          │
│                    http://gs-app-boneguard.azurewebsites.net            │
│                                                                         │
│  REST Controllers (HATEOAS + Swagger)                                   │
│  ├── AuthController        POST /auth/register, /auth/login             │
│  ├── PacienteController    CRUD /pacientes  (ADMIN e USER)              │
│  ├── AvaliacaoController   POST/GET /avaliacoes — score + classificação  │
│  ├── RadiografiaController POST /radiografias/upload — análise por IA   │
│  ├── PlanoSaudeController  GET /planos/paciente, POST /planos/gerar     │
│  ├── AlertaController      GET /alertas/paciente, PATCH /alertas/lido   │
│  ├── EvolucaoController    GET/POST /evolucao                           │
│  └── RagController         GET /rag/consultar  ◄── RAG                 │
│                                                                         │
│  Spring AI                                                              │
│  ├── NasaRagService   — RAG: keyword retrieval + augmented generation  │
│  ├── PlanoAIService   — Tooling: 3 @Tool + ChatClient → Groq LLM       │
│  └── McpToolsConfig   — MCP Server via SSE em /mcp/sse                 │
│                                                                         │
│  Integrações externas                                                   │
│  ├── VisionServiceClient — OpenFeign → API Python de radiografias       │
│  └── AlertaPublisher     — RabbitMQ → CloudAMQP (yak.lmq.cloudamqp.com)│
└────────────────┬───────────────────────────────┬───────────────────────┘
                 │ Oracle JDBC                   │ AMQP 0-9-1
                 ▼                               ▼
┌──────────────────────┐      ┌──────────────────────────────────────────┐
│  Oracle Database     │      │   CloudAMQP — yak.lmq.cloudamqp.com     │
│  (oracle.fiap.com.br)│      │   Exchange: boneguard.exchange           │
│                      │      │   Queue:    boneguard.alertas            │
│  7 tabelas TB_*_BG   │      │   Routing:  alerta.alto                 │
└──────────────────────┘      └──────────────────────────────────────────┘
                                               │ AMQP consumer
                                               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│       notification-service — Azure Web App (gs-app-notification)        │
│                  http://gs-app-notification.azurewebsites.net           │
│                                                                         │
│  AlertaConsumer — @RabbitListener("boneguard.alertas")                 │
│  └── Persiste Alerta no Oracle com status PENDENTE                     │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Stack Tecnológica

| Camada | Tecnologia |
|--------|-----------|
| Linguagem | Java 17 |
| Framework | Spring Boot 3.4.4 |
| Segurança | Spring Security 6 + JWT (jjwt 0.12.6) |
| Persistência | Spring Data JPA + Hibernate + Oracle 19c |
| Migrations | Flyway (DDL + seed automático na inicialização) |
| Mensageria | Spring AMQP + RabbitMQ via CloudAMQP |
| Cliente HTTP | Spring Cloud OpenFeign com Resilience4j |
| IA | Spring AI 1.0 — ChatClient (Groq/LLaMA), RAG, Tooling, MCP Server |
| API Docs | springdoc-openapi 2.8.6 (Swagger UI) |
| HATEOAS | Spring HATEOAS — `RepresentationModel` |
| Cache | Spring Cache + ConcurrentMapCacheManager |
| Cloud | Microsoft Azure Web Apps (App Service — Linux, Java 17) |
| CI/CD | Azure Pipelines (deploy automático por push) |
| Monitoramento | Spring Actuator `/actuator/health` |

---

## 5. Requisitos Implementados

| Requisito | Status | Onde |
|-----------|--------|------|
| API REST + boas práticas | ✅ | DTOs por domínio, interfaces de service, `GlobalExceptionHandler`, `@Valid` |
| Persistência relacional | ✅ | Oracle 19c, JPA, Flyway com migrations versionadas |
| Spring Security + JWT | ✅ | `JwtAuthenticationFilter`, sessão stateless, BCrypt, roles USER/ADMIN |
| HATEOAS | ✅ | Todos os 6 controllers de domínio retornam `_links` via `RepresentationModel` |
| Cache | ✅ | `@Cacheable("planos-paciente")` + `@CacheEvict` em `PlanoSaudeServiceImpl` |
| CORS | ✅ | `CorsConfig` com origens configuráveis via env var |
| Swagger / OpenAPI | ✅ | `@Tag` + `@Operation` em todos os controllers — `/swagger-ui.html` |
| Microserviços | ✅ | `boneguard-service` + `notification-service`, cada um no próprio Azure Web App |
| Mensageria | ✅ | `AlertaPublisher` (producer) → CloudAMQP → `AlertaConsumer` (consumer) |
| Funcionalidade REAL | ✅ | Score → classificação → alerta → plano personalizado por IA |
| OpenFeign (justificado) | ✅ | `VisionServiceClient` + `VisionServiceFallback` (circuit breaker habilitado) |
| Spring AI — RAG | ✅ | `NasaRagService`: retrieval em 5 documentos NASA + geração aumentada |
| Spring AI — Tooling | ✅ | `PlanoAIService` com 3 `@Tool` (perfil, histórico, protocolo NASA) |
| Spring AI — MCP | ✅ | `McpToolsConfig` expõe as tools via MCP Server SSE em `/mcp/sse` |

---

## 6. Modelo de Dados

```
TB_USUARIO_BONEGUARD
  id (PK), email (UNIQUE), senha (BCrypt), role

TB_PACIENTE_BONEGUARD
  id (PK), nome, idade, sexo (M/F), peso,
  historico_familiar (S/N), nivel_atividade, alimentacao_calcio (S/N), data_cadastro

TB_AVALIACAO_BONEGUARD
  id (PK), paciente_id (FK), score_risco (0–100), classificacao (BAIXO/MODERADO/ALTO),
  data_avaliacao, plano_gerado (S/N)

TB_RADIOGRAFIA_BONEGUARD
  id (PK), avaliacao_id (FK), caminho_imagem, resultado_ia, confianca, densitometria,
  data_analise

TB_PLANO_SAUDE_BONEGUARD
  id (PK), avaliacao_id (FK), categoria (EXERCICIO/NUTRICAO), descricao (gerada por IA),
  data_geracao, ativo (S/N)

TB_ALERTA_BONEGUARD          ← boneguard-service
  id (PK), paciente_id (FK), avaliacao_id (FK), score, classificacao, mensagem,
  lido (S/N), data_criacao

TB_ALERTA_BONEGUARD          ← notification-service (tabela própria, mesmo schema Oracle)
  id (PK), paciente_id, avaliacao_id, mensagem, status (PENDENTE/PROCESSADO), data_criacao

TB_EVOLUCAO_BONEGUARD
  id (PK), paciente_id (FK), peso_atual, nivel_atividade_atual, observacoes, data_registro
```

### Classificação de Risco

| Score | Classificação | Ação automática |
|-------|---------------|-----------------|
| 0 – 29.9 | `BAIXO` | Nenhuma |
| 30 – 69.9 | `MODERADO` | Nenhuma |
| 70 – 100 | `ALTO` | Publica `AlertaEvent` na fila RabbitMQ → `notification-service` persiste alerta |

---

## 7. Referência da API

**Base URL produção:** `http://gs-app-boneguard.azurewebsites.net`
**Base URL local:** `http://localhost:8080`
**Documentação interativa:** `{base}/swagger-ui.html`

Todos os endpoints (exceto `/auth/**`) exigem header:
```
Authorization: Bearer <token>
```

---

### 7.1 Autenticação

#### Registrar usuário
```
POST /auth/register
```
Request:
```json
{
  "email": "paciente@email.com",
  "senha": "senha123",
  "nome": "Maria Silva",
  "idade": 65,
  "sexo": "F",
  "peso": 58.5,
  "historicoFamiliar": true,
  "nivelAtividade": "SEDENTARIO",
  "alimentacaoCalcio": false
}
```
Response `201 Created`:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

#### Login
```
POST /auth/login
```
Request:
```json
{
  "email": "admin@boneguard.com",
  "senha": "admin123"
}
```
Response `200 OK`:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

**Usuários seed (criados pelo Flyway automaticamente):**

| Role | E-mail | Senha |
|------|--------|-------|
| `ADMIN` | `admin@boneguard.com` | `admin123` |
| `USER` | `paciente@boneguard.com` | `user123` |

---

### 7.2 Pacientes

| Método | Endpoint | Role | Descrição |
|--------|----------|------|-----------|
| `GET` | `/pacientes` | ADMIN | Listar todos |
| `POST` | `/pacientes` | USER/ADMIN | Cadastrar |
| `GET` | `/pacientes/{id}` | USER/ADMIN | Buscar por id |
| `PUT` | `/pacientes/{id}` | USER/ADMIN | Atualizar |
| `DELETE` | `/pacientes/{id}` | ADMIN | Remover |

Request body (`POST` / `PUT`):
```json
{
  "nome": "João Costa",
  "idade": 72,
  "sexo": "M",
  "peso": 70.0,
  "historicoFamiliar": false,
  "nivelAtividade": "MODERADO",
  "alimentacaoCalcio": true
}
```
> **Enums válidos:** `sexo` → `M`, `F` | `nivelAtividade` → `SEDENTARIO`, `MODERADO`, `ATIVO`

Response `201 Created` (com HATEOAS):
```json
{
  "id": 1,
  "nome": "João Costa",
  "idade": 72,
  "sexo": "M",
  "peso": 70.0,
  "historicoFamiliar": false,
  "nivelAtividade": "MODERADO",
  "alimentacaoCalcio": true,
  "dataCadastro": "2026-06-05",
  "_links": {
    "self":      { "href": "http://localhost:8080/pacientes/1" },
    "avaliacoes":{ "href": "http://localhost:8080/avaliacoes/paciente/1" },
    "evolucao":  { "href": "http://localhost:8080/evolucao/1" },
    "alertas":   { "href": "http://localhost:8080/alertas/paciente/1" },
    "planos":    { "href": "/planos/paciente/1" }
  }
}
```

---

### 7.3 Avaliações

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `POST` | `/avaliacoes` | Criar avaliação (dispara alerta se score ≥ 70) |
| `GET` | `/avaliacoes/{id}` | Buscar por id |
| `GET` | `/avaliacoes/paciente/{pacienteId}` | Histórico com tendência |

Request body (`POST`):
```json
{
  "pacienteId": 1,
  "scoreRisco": 82.5
}
```

Response `201 Created`:
```json
{
  "id": 1,
  "pacienteId": 1,
  "pacienteNome": "João Costa",
  "scoreRisco": 82.5,
  "classificacao": "ALTO",
  "dataAvaliacao": "2026-06-05",
  "planoGerado": false,
  "_links": {
    "self":        { "href": "http://localhost:8080/avaliacoes/1" },
    "paciente":    { "href": "http://localhost:8080/pacientes/1" },
    "gerar-planos":{ "href": "http://localhost:8080/planos/gerar/1" }
  }
}
```

> **Score ≥ 70:** publica automaticamente um `AlertaEvent` na fila `boneguard.alertas` do CloudAMQP. O `notification-service` consome e persiste o alerta.

Histórico (`GET /avaliacoes/paciente/1`) retorna também a **tendência**:
```json
{
  "pacienteId": 1,
  "totalAvaliacoes": 3,
  "tendencia": "MELHORA",
  "avaliacoes": [ ... ]
}
```
> **Tendência:** `MELHORA`, `PIORA`, `ESTAVEL`, `SEM_HISTORICO`

---

### 7.4 Planos de Saúde (Spring AI Tooling)

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `POST` | `/planos/gerar/{avaliacaoId}` | Gera 2 planos (EXERCICIO + NUTRICAO) via IA |
| `GET` | `/planos/paciente/{pacienteId}` | Lista planos (resultado em cache) |

Response de `POST /planos/gerar/1`:
```json
[
  {
    "id": 1,
    "avaliacaoId": 1,
    "categoria": "EXERCICIO",
    "descricao": "Risco alto requer protocolo intensivo.\n* Resistência gravitacional 2x/dia com agachamento e leg press\n* Treino aeróbico 30 min/dia em bicicleta ergométrica com resistência\n* Exercícios isométricos para carga vertebral 3x/semana\n* Caminhada com colete lastrado a 70% do peso corporal",
    "dataGeracao": "2026-06-05",
    "ativo": true,
    "_links": {
      "avaliacao":    { "href": "http://localhost:8080/avaliacoes/1" },
      "gerar-planos": { "href": "http://localhost:8080/planos/gerar/1" }
    }
  },
  {
    "id": 2,
    "avaliacaoId": 1,
    "categoria": "NUTRICAO",
    "descricao": "Suplementação e dieta para risco elevado.\n* Cálcio 1.500mg/dia dividido em 2 doses com refeições\n* Vitamina D3 4.000 UI/dia pela manhã com gordura\n* Vitamina K2 MK-7 200mcg/dia para fixação óssea\n* Proteína 1,5g/kg/dia priorizando fontes magras",
    "dataGeracao": "2026-06-05",
    "ativo": true,
    "_links": { ... }
  }
]
```

---

### 7.5 Radiografias (OpenFeign)

```
POST /radiografias/upload
Content-Type: multipart/form-data
```

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `avaliacaoId` | `Long` | ID da avaliação vinculada |
| `imagem` | `File` | Arquivo de imagem da radiografia |

Response `201 Created`:
```json
{
  "id": 1,
  "avaliacaoId": 1,
  "resultadoIA": "SUSPEITO",
  "confianca": 0.87,
  "densitometria": 31.5,
  "dataAnalise": "2026-06-05",
  "_links": { ... }
}
```

> O `VisionServiceClient` (OpenFeign) chama a API Python externa. Se ela estiver offline, o `VisionServiceFallback` retorna `NORMAL` com confiança 0.5 — sem errar para o cliente.

---

### 7.6 Alertas

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/alertas/paciente/{pacienteId}` | Listar alertas do paciente |
| `PATCH` | `/alertas/{id}/lido` | Marcar alerta como lido |

Response de `GET /alertas/paciente/1`:
```json
[
  {
    "id": 1,
    "pacienteId": 1,
    "avaliacaoId": 1,
    "score": 82.5,
    "classificacao": "ALTO",
    "mensagem": "ALERTA ALTO RISCO: João Costa apresenta score 82.5. Consulta médica urgente recomendada.",
    "lido": false,
    "dataCriacao": "2026-06-05",
    "_links": { ... }
  }
]
```

---

### 7.7 Evolução

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/evolucao/{pacienteId}` | Histórico de evolução do paciente |
| `POST` | `/evolucao` | Registrar novo ponto de evolução |

Request body (`POST`):
```json
{
  "pacienteId": 1,
  "pesoAtual": 71.2,
  "nivelAtividadeAtual": "ATIVO",
  "observacoes": "Paciente relatou melhora na mobilidade após 3 meses de protocolo."
}
```

---

### 7.8 RAG — Consulta Inteligente

```
GET /rag/consultar?pergunta={texto}
```

Exemplos de perguntas:
- `"Qual a dose de cálcio recomendada pela NASA?"`
- `"Que exercícios o protocolo ARED indica?"`
- `"Como interpretar o score de risco ósseo?"`
- `"O que é microgravidade e como afeta os ossos?"`

Response `200 OK`:
```json
{
  "pergunta": "Qual a dose de cálcio recomendada pela NASA?",
  "resposta": "A NASA recomenda 1.200 a 1.500 mg de cálcio por dia, combinando alimentos e suplementos, junto com 2.000 a 4.000 UI de vitamina D3 para garantir a absorção."
}
```

---

### 7.9 MCP Server

```
GET  /mcp/sse       Conexão SSE para clientes MCP
POST /mcp/message   Envio de mensagens MCP
```

Tools disponíveis via MCP:
- `buscarPerfilPaciente(pacienteId)` — perfil clínico completo
- `buscarHistoricoAvaliacoes(pacienteId)` — scores e classificações em ordem cronológica
- `buscarProtocoloNASA(categoria)` — protocolos EXERCICIO ou NUTRICAO

---

### 7.10 Endpoints de Infraestrutura

```
GET /swagger-ui.html     Documentação interativa
GET /v3/api-docs         Spec OpenAPI (JSON)
GET /actuator/health     Health check
GET /actuator/info       Info do serviço
```

---

### 7.11 Formato de Erro

Todas as respostas de erro seguem o mesmo formato:

```json
{
  "status": 404,
  "mensagem": "Paciente com id 99 não encontrado.",
  "path": "/pacientes/99"
}
```

| Status | Situação |
|--------|---------|
| `400` | Validação de campo inválido |
| `401` | Token ausente ou expirado |
| `403` | Role sem permissão para o recurso |
| `404` | Recurso não encontrado |
| `500` | Erro interno |

---

## 8. Spring AI — RAG, Tooling e MCP

### RAG (Retrieval-Augmented Generation) — `NasaRagService`

```
Pergunta do usuário
       │
       ▼
[1. RETRIEVAL] Busca por keyword nos 5 documentos NASA em memória
       │   (exercício, nutrição, classificação de risco, microgravidade, densitometria)
       │
       ▼
[2. AUGMENTED] Monta prompt com os documentos recuperados como contexto
       │
       ▼
[3. GENERATION] ChatClient → Groq LLM → resposta fundamentada no contexto NASA
```

### Tooling — `PlanoAIService`

O LLM recebe 3 ferramentas (`@Tool`) que pode invocar durante a geração do plano:

| Tool | Parâmetro | O que retorna |
|------|-----------|---------------|
| `buscarPerfilPaciente` | `pacienteId` | Nome, idade, sexo, peso, nível de atividade, histórico familiar, dieta de cálcio |
| `buscarHistoricoAvaliacoes` | `pacienteId` | Scores e classificações em ordem cronológica |
| `buscarProtocoloNASA` | `"EXERCICIO"` ou `"NUTRICAO"` | Protocolo NASA correspondente |

O modelo consulta as tools, integra os dados ao contexto e gera recomendações práticas — sem expor dados pessoais na resposta final.

### MCP Server

O `McpToolsConfig` registra as mesmas 3 tools como endpoints MCP (Model Context Protocol) via SSE. Qualquer cliente compatível (Claude Desktop, Cursor, agentes customizados) pode se conectar ao BoneGuard como ferramenta de IA:

```json
// claude_desktop_config.json
{
  "mcpServers": {
    "boneguard": {
      "url": "http://gs-app-boneguard.azurewebsites.net/mcp/sse"
    }
  }
}
```

---

## 9. Mensageria — RabbitMQ + CloudAMQP

**Provider:** CloudAMQP — `yak.lmq.cloudamqp.com`

```
boneguard-service                           notification-service
      │                                             │
      │  score >= 70                                │
      │  AlertaPublisher.publicar(event)            │
      │         │                                   │
      │         ▼                                   │
      │  Exchange: boneguard.exchange               │
      │  Routing key: alerta.alto         ──────►  AlertaConsumer
      │                                    AMQP    @RabbitListener
      │  Queue: boneguard.alertas                  persiste Alerta
      │  (durable, bind automático)                status=PENDENTE
```

O `boneguard-service` publica o evento e continua sua execução imediatamente — sem aguardar resposta. O `notification-service` consome de forma independente, com retry automático (até 3 tentativas) em caso de falha na persistência.

---

## 10. Segurança

```
POST /auth/login  →  JwtService.generateToken()  →  token (24h)
         │
         ▼
Requisição com "Authorization: Bearer <token>"
         │
         ▼
JwtAuthenticationFilter
  ├── Valida assinatura (HMAC-SHA256)
  ├── Verifica expiração
  └── Carrega UserDetails → SecurityContext
         │
         ▼
SecurityConfig — regras por role:
  ├── GET /pacientes       → ADMIN apenas
  ├── DELETE /pacientes/** → ADMIN apenas
  └── demais endpoints     → qualquer usuário autenticado
```

Senhas armazenadas com **BCrypt** (fator de custo padrão = 10).

---

## 11. Implantação — Azure + CI/CD

Cada microserviço tem seu próprio pipeline que, a cada push, faz build Maven e deploy automático no Azure Web App:

| Serviço | App Service | URL |
|---------|------------|-----|
| `boneguard-service` | `gs-app-boneguard` | http://gs-app-boneguard.azurewebsites.net |
| `notification-service` | `gs-app-notification` | http://gs-app-notification.azurewebsites.net |

As variáveis sensíveis (senhas, chaves) são configuradas como **Application Settings** no Azure — nunca no repositório.

---

## 12. Como Rodar Localmente

### Pré-requisitos
- JDK 17+
- Maven 3.8+
- Oracle 19c acessível (Flyway cria as tabelas automaticamente)
- RabbitMQ local **ou** conta CloudAMQP gratuita

### Opção A — Docker Compose (RabbitMQ local)

```bash
# Cria o .env a partir do exemplo
cp .env.example .env
# Preencha as variáveis no .env

docker compose up -d
```

### Opção B — Manual (com CloudAMQP)

```bash
# Terminal 1 — boneguard-service
cd boneguard-service
RABBITMQ_HOST=yak.lmq.cloudamqp.com \
RABBITMQ_PORT=5672 \
RABBITMQ_USER=<seu_user> \
RABBITMQ_PASS=<sua_senha> \
RABBITMQ_VHOST=<seu_vhost> \
GROQ_API_KEY=<sua_chave> \
mvn spring-boot:run

# Terminal 2 — notification-service
cd notification-service
RABBITMQ_HOST=yak.lmq.cloudamqp.com \
RABBITMQ_PORT=5672 \
RABBITMQ_USER=<seu_user> \
RABBITMQ_PASS=<sua_senha> \
RABBITMQ_VHOST=<seu_vhost> \
mvn spring-boot:run
```

Acesse `http://localhost:8080/swagger-ui.html` para explorar a API.

---

## 13. Variáveis de Ambiente

### boneguard-service

| Variável | Descrição | Default local |
|----------|-----------|---------------|
| `DATASOURCE_URL` | JDBC URL do Oracle | `jdbc:oracle:thin:@oracle.fiap.com.br:1521:orcl` |
| `DB_USERNAME` | Usuário Oracle | `rm560027` |
| `DB_PASSWORD` | Senha Oracle | — |
| `JWT_SECRET` | Chave HMAC-SHA256 (mín. 32 chars) | *(definir)* |
| `JWT_EXPIRATION_MS` | Expiração do token | `86400000` (24h) |
| `RABBITMQ_HOST` | Host do broker | `localhost` |
| `RABBITMQ_PORT` | Porta AMQP | `5672` |
| `RABBITMQ_USER` | Usuário RabbitMQ | `guest` |
| `RABBITMQ_PASS` | Senha RabbitMQ | `guest` |
| `RABBITMQ_VHOST` | Virtual host (CloudAMQP = username) | `/` |
| `VISION_SERVICE_URL` | URL da API Python de radiografias | `http://localhost:5000` |
| `GROQ_API_KEY` | Chave Groq para Spring AI | *(obrigatório para AI)* |
| `SPRING_PROFILES_ACTIVE` | Perfil ativo | — |

### notification-service

| Variável | Descrição | Default local |
|----------|-----------|---------------|
| `DATASOURCE_URL` | JDBC URL do Oracle | `jdbc:oracle:thin:@oracle.fiap.com.br:1521:orcl` |
| `DB_USERNAME` | Usuário Oracle | `rm560027` |
| `DB_PASSWORD` | Senha Oracle | — |
| `RABBITMQ_HOST` | Host do broker | `localhost` |
| `RABBITMQ_PORT` | Porta AMQP | `5672` |
| `RABBITMQ_USER` | Usuário RabbitMQ | `guest` |
| `RABBITMQ_PASS` | Senha RabbitMQ | `guest` |
| `RABBITMQ_VHOST` | Virtual host (CloudAMQP = username) | `/` |
| `SPRING_PROFILES_ACTIVE` | Perfil ativo | — |

> **CloudAMQP:** o `RABBITMQ_VHOST` deve ser igual ao `RABBITMQ_USER` (ambos são o nome da instância, ex: `wjfgrwdx`).

---

## 14. Fluxo Completo com cURL

```bash
BASE="http://gs-app-boneguard.azurewebsites.net"

# 1. Login como admin
TOKEN=$(curl -s -X POST $BASE/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@boneguard.com","senha":"admin123"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

AUTH="Authorization: Bearer $TOKEN"

# 2. Cadastrar paciente
curl -s -X POST $BASE/pacientes \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"nome":"Maria Silva","idade":65,"sexo":"F","peso":58.5,
       "historicoFamiliar":true,"nivelAtividade":"SEDENTARIO","alimentacaoCalcio":false}'

# 3. Criar avaliação com score ALTO (dispara alerta via RabbitMQ)
curl -s -X POST $BASE/avaliacoes \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"pacienteId":1,"scoreRisco":82.5}'

# 4. Gerar planos com Spring AI + protocolos NASA
curl -s -X POST $BASE/planos/gerar/1 -H "$AUTH"

# 5. Consultar alertas (gerados pelo notification-service)
curl -s $BASE/alertas/paciente/1 -H "$AUTH"

# 6. Consultar RAG sobre saúde óssea
curl -s "$BASE/rag/consultar?pergunta=Que+exercicios+o+protocolo+ARED+indica" \
  -H "$AUTH"

# 7. Ver histórico de avaliações com tendência
curl -s $BASE/avaliacoes/paciente/1 -H "$AUTH"
```

---

## 15. Testes

```bash
cd boneguard-service
mvn test
```

| Classe de teste | Cenários |
|-----------------|---------|
| `AvaliacaoServiceImplTest` | Score BAIXO/MODERADO/ALTO, validação de score inválido, alerta RabbitMQ publicado, data preenchida, histórico por paciente |
| `PacienteServiceImplTest` | Criar, buscar existente, buscar inexistente (404), atualizar dados, atualizar inexistente (404) |

---

## 16. Estrutura do Repositório

```
.
├── boneguard-service/
│   ├── src/main/java/br/com/fiap/boneguard/
│   │   ├── configs/          CacheConfig, CorsConfig, McpToolsConfig,
│   │   │                     OpenApiConfig, RabbitMQConfig, SecurityConfig
│   │   ├── controller/       AuthController, PacienteController, AvaliacaoController,
│   │   │                     RadiografiaController, PlanoSaudeController, AlertaController,
│   │   │                     EvolucaoController, RagController
│   │   ├── service/          PlanoAIService (Tooling), NasaRagService (RAG),
│   │   │                     AvaliacaoServiceImpl, PacienteServiceImpl, ...
│   │   ├── external_interface/
│   │   │   ├── feign/        VisionServiceClient, VisionServiceFallback
│   │   │   └── rabbitmq/     AlertaPublisher, AlertaEvent
│   │   ├── security/         JwtService, JwtAuthenticationFilter, UserDetailsServiceImpl
│   │   ├── entities/         Paciente, Avaliacao, Radiografia, PlanoSaude, Evolucao, Alerta
│   │   ├── dto/              Requests e Responses por domínio
│   │   ├── enums/            Classificacao, Sexo, NivelAtividade, CategoriaPlano, ...
│   │   └── exception/        GlobalExceptionHandler, ResourceNotFoundException, ...
│   ├── src/main/resources/
│   │   ├── application.properties
│   │   └── db/migration/     V1__ddl.sql, V2__alter.sql, V3__seed.sql
│   └── src/test/java/...
│       └── service/          AvaliacaoServiceImplTest, PacienteServiceImplTest
│
├── notification-service/
│   └── src/main/java/br/com/fiap/notification/
│       ├── consumer/         AlertaConsumer (@RabbitListener)
│       ├── configs/          RabbitMQConfig
│       ├── entities/         Alerta
│       └── repositories/     AlertaRepository
│
├── db/
│   ├── ddl/                  Scripts DDL Oracle
│   ├── dml/                  Scripts de seed
│   └── plsql/                Functions, Procedures, Triggers, Package, Cursores
│
├── docker-compose.yml        RabbitMQ local para desenvolvimento
└── README.md
```

---

## 17. Justificativas de Arquitetura

### Microserviços

O BoneGuard foi dividido em dois serviços com **responsabilidades e ciclos de vida independentes**:

- **`boneguard-service`** — domínio principal: autenticação, pacientes, avaliações, IA, radiografias. Escala conforme volume de requisições e processamento de IA.
- **`notification-service`** — responsável exclusivamente por consumir e persistir alertas via RabbitMQ. Uma falha isolada nele não derruba o serviço principal; pode escalar separadamente em cenários de alto volume de alertas.

A comunicação é **assíncrona via RabbitMQ (CloudAMQP)**: o `boneguard-service` publica o evento e retorna imediatamente ao cliente — sem aguardar o processamento do alerta. Isso garante **desacoplamento real** e baixa latência na resposta.

Cada serviço tem seu próprio **pipeline de CI/CD** e **Azure Web App**, refletindo a independência de deploy característica de uma arquitetura de microserviços.

### OpenFeign como cliente HTTP

O `VisionServiceClient` usa **OpenFeign** para consumir a API Python de análise de radiografias porque:

1. **Interface declarativa** — o contrato HTTP é expresso como um método Java simples, sem boilerplate de `RestTemplate` ou `WebClient`.
2. **Resiliência com fallback** — `fallback = VisionServiceFallback.class` garante que, se a API de visão estiver offline, o sistema retorna um resultado padrão sem expor erro ao usuário final.
3. **Circuit breaker integrado** — `spring.cloud.openfeign.circuitbreaker.enabled=true` protege o serviço principal de cascata de falhas na dependência externa.
4. **Configuração por env var** — `${VISION_SERVICE_URL}` permite apontar para ambientes diferentes sem alteração de código.
