# BoneGuard — Banco de Dados Oracle 19c

> Plataforma de rastreio e prevenção de osteoporose — FIAP Global Solution 2026/1

## Descrição

O BoneGuard analisa raio-x com modelos de IA para gerar um **score de risco ósseo** (0–100) e classificá-lo em BAIXO / MODERADO / ALTO. Com base nesse score, a plataforma gera planos personalizados de exercício e nutrição baseados em protocolos da NASA e dispara alertas automáticos para pacientes em risco alto.

---

## Diagrama Textual de Tabelas e Relacionamentos

```
TB_PACIENTE_BONEGUARD
  id (PK) ──────────────────────────────────────────────────────┐
  nome                                                          │
  idade / sexo / peso                                           │
  historico_familiar / nivel_atividade / alimentacao_calcio     │
  data_cadastro                                                 │
        │                                                       │
        │ 1:N                                                   │ 1:N
        ▼                                                       ▼
  TB_AVALIACAO_BONEGUARD                            TB_EVOLUCAO_BONEGUARD
    id (PK)                                           id (PK)
    paciente_id (FK → TB_PACIENTE_BONEGUARD)          paciente_id (FK → TB_PACIENTE_BONEGUARD)
    score_risco (0–100)                               peso_atual
    classificacao (BAIXO/MODERADO/ALTO)               nivel_atividade_atual
    data_avaliacao / plano_gerado                     observacoes / data_registro
        │
        ├── 1:1 ──────────────────────┐
        │                             ▼
        │                       TB_RADIOGRAFIA_BONEGUARD
        │                         id (PK)
        │                         avaliacao_id (FK → TB_AVALIACAO_BONEGUARD)
        │                         caminho_imagem
        │                         resultado_ia (NORMAL/OSTEOPENIA/OSTEOPOROSE)
        │                         confianca (0–1) / data_analise
        │
        ├── 1:N ──────────────────────┐
        │                             ▼
        │                       TB_PLANO_SAUDE_BONEGUARD
        │                         id (PK)
        │                         avaliacao_id (FK → TB_AVALIACAO_BONEGUARD)
        │                         categoria (EXERCICIO/NUTRICAO)
        │                         descricao / ativo / data_criacao
        │
        └── 1:N ──┐
                  │
    TB_PACIENTE_BONEGUARD ──┘
        id ────────────────────────────────┐
                                           ▼
                                     TB_ALERTA_BONEGUARD
                                       id (PK)
                                       paciente_id  (FK → TB_PACIENTE_BONEGUARD)
                                       avaliacao_id (FK → TB_AVALIACAO_BONEGUARD)
                                       mensagem / status / data_criacao

TB_AUDITORIA_BONEGUARD (sem FK — log genérico)
  id / tabela_afetada / registro_id / operacao / usuario_bd / data_operacao / dados_anteriores / dados_novos
```

---

## Ordem de Execução dos Scripts

```
1. db/ddl/01_create_tables.sql      — Cria as 7 tabelas com constraints e índices
2. db/dml/02_insert_data.sql        — Insere 80+ registros de dados realistas
3. db/plsql/03_functions.sql        — Cria as 3 functions (necessárias para procedures e triggers)
4. db/plsql/04_procedures.sql       — Cria as 3 stored procedures
5. db/plsql/05_triggers.sql         — Cria os 4 triggers (dependem das procedures)
6. db/plsql/06_package.sql          — Cria o package PKG_BONEGUARD (spec + body)
7. db/plsql/07_blocos_anonimos.sql  — Executa os 3 blocos anônimos com IF/LOOP/WHILE
8. db/plsql/08_cursores.sql         — Executa os 2 cursores explícitos
9. db/plsql/09_relatorios.sql       — Executa os 5 relatórios SQL com JOIN
```

> **Importante:** Os scripts 3–6 devem ser executados antes dos blocos anônimos pois estes chamam as functions e procedures.

### Pré-requisitos

- Oracle Database 19c ou superior
- Usuário com permissões: `CREATE TABLE`, `CREATE SEQUENCE`, `CREATE PROCEDURE`, `CREATE FUNCTION`, `CREATE TRIGGER`, `CREATE PACKAGE`
- `SET SERVEROUTPUT ON SIZE UNLIMITED` ativo para ver saída do DBMS_OUTPUT

### Execução via Oracle SQL Developer

Abra cada arquivo na ordem acima e execute com `F5` (Run Script) ou `Ctrl+Enter` (Run Statement).

---

## Dicionário de Dados Resumido

### TB_PACIENTE_BONEGUARD

| Coluna | Tipo | Constraints | Descrição |
|---|---|---|---|
| id | NUMBER | PK, IDENTITY | Identificador único |
| nome | VARCHAR2(150) | NOT NULL | Nome completo (uppercase via trigger) |
| idade | NUMBER(3) | NOT NULL, 1–130 | Idade em anos |
| sexo | CHAR(1) | NOT NULL, M/F | Sexo biológico |
| peso | NUMBER(5,2) | NOT NULL, >0 | Peso em kg |
| historico_familiar | CHAR(1) | NOT NULL, S/N | Familiar com osteoporose |
| nivel_atividade | VARCHAR2(20) | NOT NULL | SEDENTARIO/MODERADO/ATIVO |
| alimentacao_calcio | CHAR(1) | NOT NULL, S/N | Dieta rica em cálcio |
| data_cadastro | DATE | NOT NULL, DEFAULT SYSDATE | Data de inclusão |

### TB_AVALIACAO_BONEGUARD

| Coluna | Tipo | Constraints | Descrição |
|---|---|---|---|
| id | NUMBER | PK, IDENTITY | Identificador único |
| paciente_id | NUMBER | FK → TB_PACIENTE_BONEGUARD | Paciente avaliado |
| score_risco | NUMBER(5,2) | NOT NULL, 0–100 | Score gerado pela IA |
| classificacao | VARCHAR2(10) | NOT NULL, BAIXO/MODERADO/ALTO | Classificação automática |
| data_avaliacao | DATE | NOT NULL, DEFAULT SYSDATE | Data da avaliação |
| plano_gerado | CHAR(1) | NOT NULL, S/N | Atualizado automaticamente via TRG_PLANO_GERADO |

### TB_RADIOGRAFIA_BONEGUARD

| Coluna | Tipo | Constraints | Descrição |
|---|---|---|---|
| id | NUMBER | PK, IDENTITY | Identificador único |
| avaliacao_id | NUMBER | FK → TB_AVALIACAO_BONEGUARD | Avaliação vinculada |
| caminho_imagem | VARCHAR2(500) | — | Caminho ou URL do arquivo de raio-x analisado |
| resultado_ia | VARCHAR2(15) | NOT NULL | NORMAL/OSTEOPENIA/OSTEOPOROSE |
| confianca | NUMBER(4,3) | NOT NULL, 0–1 | Confiança do modelo (0 a 1) |
| data_analise | DATE | NOT NULL | Data da análise |

### TB_PLANO_SAUDE_BONEGUARD

| Coluna | Tipo | Constraints | Descrição |
|---|---|---|---|
| id | NUMBER | PK, IDENTITY | Identificador único |
| avaliacao_id | NUMBER | FK → TB_AVALIACAO_BONEGUARD | Avaliação que gerou o plano |
| categoria | VARCHAR2(10) | NOT NULL, EXERCICIO/NUTRICAO | Tipo do plano |
| descricao | VARCHAR2(2000) | NOT NULL | Detalhamento do plano |
| ativo | CHAR(1) | NOT NULL, S/N | Se o plano está vigente |
| data_criacao | DATE | NOT NULL | Data de criação |

### TB_EVOLUCAO_BONEGUARD

| Coluna | Tipo | Constraints | Descrição |
|---|---|---|---|
| id | NUMBER | PK, IDENTITY | Identificador único |
| paciente_id | NUMBER | FK → TB_PACIENTE_BONEGUARD | Paciente monitorado |
| peso_atual | NUMBER(5,2) | NOT NULL, >0 | Peso no momento do registro |
| nivel_atividade_atual | VARCHAR2(20) | NOT NULL | SEDENTARIO/MODERADO/ATIVO |
| observacoes | VARCHAR2(1000) | — | Observações clínicas |
| data_registro | DATE | NOT NULL | Data do registro |

### TB_ALERTA_BONEGUARD

| Coluna | Tipo | Constraints | Descrição |
|---|---|---|---|
| id | NUMBER | PK, IDENTITY | Identificador único |
| paciente_id | NUMBER | FK → TB_PACIENTE_BONEGUARD | Paciente destinatário |
| avaliacao_id | NUMBER | FK → TB_AVALIACAO_BONEGUARD | Avaliação que gerou o alerta |
| mensagem | VARCHAR2(500) | NOT NULL | Texto do alerta |
| status | VARCHAR2(10) | NOT NULL | PENDENTE/ENVIADO/LIDO |
| data_criacao | DATE | NOT NULL | Data de criação |

### TB_AUDITORIA_BONEGUARD

| Coluna | Tipo | Constraints | Descrição |
|---|---|---|---|
| id | NUMBER | PK, IDENTITY | Identificador único |
| tabela_afetada | VARCHAR2(50) | NOT NULL | Nome da tabela modificada |
| registro_id | NUMBER | — | PK do registro afetado na tabela de origem |
| operacao | VARCHAR2(10) | NOT NULL | INSERT/UPDATE/DELETE |
| usuario_bd | VARCHAR2(100) | NOT NULL, DEFAULT USER | Usuário Oracle que executou |
| data_operacao | DATE | NOT NULL, DEFAULT SYSDATE | Timestamp da operação |
| dados_anteriores | CLOB | — | JSON com dados antes da alteração (UPDATE/DELETE) |
| dados_novos | CLOB | — | JSON com dados após a operação (INSERT/UPDATE) |

---

## Objetos PL/SQL

| Tipo | Nome | Descrição |
|---|---|---|
| Function | FN_CLASSIFICAR_RISCO | Retorna BAIXO/MODERADO/ALTO dado um score |
| Function | FN_MEDIA_SCORE | Média de scores de um paciente |
| Function | FN_TOTAL_ALERTAS_ATIVOS | Count de alertas pendentes/enviados |
| Procedure | SP_REGISTRAR_AVALIACAO | Insere avaliação + radiografia opcional |
| Procedure | SP_GERAR_PLANO_SAUDE | Cria plano de exercício ou nutrição |
| Procedure | SP_GERAR_ALERTA | Cria alerta com status PENDENTE |
| Trigger | TRG_AUDIT_AVALIACAO | Log de INSERT/UPDATE/DELETE em TB_AVALIACAO_BONEGUARD |
| Trigger | TRG_ALERTA_AUTOMATICO | Alerta automático para classificação ALTO |
| Trigger | TRG_PLANO_GERADO | Atualiza plano_gerado = 'S' ao inserir em TB_PLANO_SAUDE_BONEGUARD |
| Trigger | TRG_UPPER_NOME_PACIENTE | Formata nome em maiúsculo no INSERT/UPDATE de TB_PACIENTE_BONEGUARD |
| Package | PKG_BONEGUARD | Agrupa procedures e functions principais |

---

## Modelagem NoSQL

Consulte [nosql/10_modelo_json.md](nosql/10_modelo_json.md) para o modelo MongoDB com:
- Coleção `pacientes` — documento desnormalizado para acesso rápido
- Coleção `logs_inferencia_ia` — logs de análise de IA por versão de modelo
- Coleção `radiografias_metadata` — metadados DICOM + referência GridFS
- Justificativa técnica do uso de MongoDB complementar ao Oracle
