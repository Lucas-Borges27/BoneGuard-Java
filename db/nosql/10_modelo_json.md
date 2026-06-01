# BoneGuard — Modelagem NoSQL (MongoDB)

## Contexto

O BoneGuard utiliza **Oracle 19c** como banco relacional principal para dados estruturados e transacionais (pacientes, avaliações, planos de saúde). Paralelamente, o **MongoDB** é utilizado para dados semi-estruturados e de alto volume: logs de análise de IA, uploads de radiografias e histórico de sessões.

---

## Justificativa para uso do MongoDB

| Critério | Oracle (relacional) | MongoDB (NoSQL) |
|---|---|---|
| Dados de pacientes e avaliações | ✅ Ideal (ACID, FK, integridade) | ❌ Sem ganho |
| Upload de radiografias (binário + metadados variáveis) | ❌ BLOB com estrutura rígida | ✅ GridFS + documentos flexíveis |
| Logs de inferência de IA (JSON variável por modelo) | ❌ Colunas extras ou CLOB | ✅ Schema-free por versão de modelo |
| Sessões e eventos de uso em tempo real | ❌ Overhead transacional | ✅ Inserções rápidas, sem lock |
| Escalabilidade horizontal | ❌ Cara/complexa | ✅ Sharding nativo |

**Casos de uso MongoDB no BoneGuard:**
1. **Logs de inferência da IA** — cada modelo de IA (YOLOv8, ResNet, etc.) gera JSON diferente por versão; o MongoDB armazena sem migração de schema.
2. **Metadados de radiografias** — arquivo DICOM + metadados do equipamento (fabricante, resolução, protocolo de captura) variam por clínica parceira.
3. **Histórico de eventos de auditoria detalhada** — eventos de clique, tempo de sessão, ações na interface — volume alto, consulta eventual.

---

## Coleções MongoDB

### Coleção: `pacientes`

Documento principal que agrega dados do paciente com sua última avaliação e plano ativo (desnormalizado intencionalmente para leitura rápida no app).

```json
{
  "_id": "ObjectId('64f1a2b3c4d5e6f7a8b9c0d1')",
  "paciente_id_oracle": 1,
  "nome": "ANA PAULA FERREIRA",
  "idade": 45,
  "sexo": "F",
  "peso_kg": 62.5,
  "data_cadastro": "2025-01-10T00:00:00Z",
  "fatores_risco": {
    "historico_familiar": true,
    "nivel_atividade": "SEDENTARIO",
    "alimentacao_calcio": false,
    "imc": 22.3,
    "menopausa_precoce": true,
    "tabagismo": false,
    "uso_corticoides": false
  },
  "ultima_avaliacao": {
    "avaliacao_id_oracle": 1,
    "score_risco": 78.5,
    "classificacao": "ALTO",
    "data": "2025-02-01T14:32:10Z",
    "radiografia": {
      "resultado_ia": "OSTEOPOROSE",
      "confianca": 0.921,
      "modelo_ia": "BoneNet-v2.1",
      "arquivo_dicom_id": "GridFS:64f1a2b3..."
    }
  },
  "plano_ativo": {
    "plano_id_oracle": 1,
    "categorias": ["EXERCICIO", "NUTRICAO"],
    "resumo": "Protocolo NASA de resistência óssea + dieta hipercalcêmica",
    "ativo": true,
    "data_criacao": "2025-02-02T09:00:00Z"
  },
  "alertas_pendentes": 2,
  "metadata": {
    "criado_em": "2025-01-10T00:00:00Z",
    "atualizado_em": "2026-05-26T10:00:00Z",
    "origem": "app_mobile",
    "versao_schema": "2.3"
  }
}
```

---

### Coleção: `logs_inferencia_ia`

Cada análise de IA gera um documento com os detalhes técnicos da inferência. O schema varia conforme versão do modelo.

```json
{
  "_id": "ObjectId('64f1a2b3c4d5e6f7a8b9c0d2')",
  "avaliacao_id_oracle": 1,
  "paciente_id_oracle": 1,
  "timestamp": "2025-02-01T14:32:10.453Z",
  "modelo": {
    "nome": "BoneNet",
    "versao": "2.1.0",
    "framework": "PyTorch 2.1",
    "checkpoint": "bonenet_v2.1_epoch_180.pt"
  },
  "entrada": {
    "arquivo_id": "GridFS:64f1a2b3...",
    "formato": "DICOM",
    "resolucao_px": [2048, 2048],
    "equipamento": "Siemens SOMATOM Drive",
    "protocolo_captura": "OP-STD-LUMBAR"
  },
  "saida": {
    "resultado": "OSTEOPOROSE",
    "confianca": 0.921,
    "scores_por_classe": {
      "NORMAL": 0.043,
      "OSTEOPENIA": 0.036,
      "OSTEOPOROSE": 0.921
    },
    "regioes_detectadas": [
      {
        "vertebra": "L1",
        "densidade_relativa": 0.312,
        "anomalia_detectada": true,
        "bbox": [420, 380, 680, 650]
      },
      {
        "vertebra": "L2",
        "densidade_relativa": 0.298,
        "anomalia_detectada": true,
        "bbox": [422, 655, 681, 925]
      },
      {
        "vertebra": "L3",
        "densidade_relativa": 0.341,
        "anomalia_detectada": false,
        "bbox": [423, 928, 682, 1190]
      }
    ],
    "heatmap_url": "s3://boneguard-heatmaps/2025/02/01/pac1_aval1.png"
  },
  "performance": {
    "tempo_inferencia_ms": 847,
    "gpu": "NVIDIA A10G",
    "memoria_gpu_mb": 4096
  },
  "auditoria": {
    "usuario_api": "sistema_boneguard_prod",
    "ip_origem": "10.0.1.42",
    "sessao_id": "sess_abc123xyz"
  }
}
```

---

### Coleção: `radiografias_metadata`

Armazena metadados do arquivo DICOM com referência ao arquivo no GridFS. O arquivo binário fica no GridFS do próprio MongoDB.

```json
{
  "_id": "ObjectId('64f1a2b3c4d5e6f7a8b9c0d3')",
  "avaliacao_id_oracle": 1,
  "paciente_id_oracle": 1,
  "gridfs_file_id": "ObjectId('64f1a2b3c4d5e6f7a8b9c0d4')",
  "dicom_tags": {
    "StudyDate": "20250201",
    "Modality": "CR",
    "BodyPartExamined": "LUMBAR SPINE",
    "InstitutionName": "Clínica BoneGuard SP",
    "ManufacturerModelName": "Siemens SOMATOM Drive",
    "PixelSpacing": [0.148, 0.148],
    "Rows": 2048,
    "Columns": 2048,
    "BitsAllocated": 16,
    "KVP": 80,
    "ExposureTime": 100
  },
  "upload": {
    "realizado_em": "2025-02-01T14:30:05Z",
    "tamanho_bytes": 8388608,
    "formato_original": "DICOM",
    "hash_sha256": "a1b2c3d4e5f6...",
    "via": "app_clinica_v3.2"
  },
  "status_processamento": "PROCESSADO",
  "tentativas_ia": 1
}
```

---

## Índices recomendados no MongoDB

```javascript
// Busca rápida por paciente no Oracle (sincronização)
db.pacientes.createIndex({ "paciente_id_oracle": 1 }, { unique: true });

// Consulta de logs por avaliação
db.logs_inferencia_ia.createIndex({ "avaliacao_id_oracle": 1 });

// Busca logs por timestamp (últimas análises)
db.logs_inferencia_ia.createIndex({ "timestamp": -1 });

// Busca por resultado e modelo
db.logs_inferencia_ia.createIndex({ "saida.resultado": 1, "modelo.versao": 1 });

// Busca radiografias não processadas (fila de IA)
db.radiografias_metadata.createIndex({ "status_processamento": 1, "upload.realizado_em": 1 });
```

---

## Integração Oracle ↔ MongoDB

```
┌──────────────────────────────────────────────────────────┐
│                     BoneGuard API (Python/FastAPI)        │
│                                                          │
│   ┌─────────────────┐      ┌──────────────────────────┐  │
│   │   Oracle 19c    │      │       MongoDB             │  │
│   │                 │      │                          │  │
│   │ TB_PACIENTE     │◄────►│ coleção: pacientes        │  │
│   │ TB_AVALIACAO    │      │ (desnormalizado p/ app)  │  │
│   │ TB_RADIOGRAFIA  │◄────►│ coleção: radiografias_   │  │
│   │ TB_PLANO_SAUDE  │      │   metadata + GridFS      │  │
│   │ TB_ALERTA       │      │                          │  │
│   │ TB_AUDITORIA    │      │ coleção: logs_inferencia_│  │
│   │                 │      │   ia (schema-free)       │  │
│   └─────────────────┘      └──────────────────────────┘  │
│         ACID, integridade        Alta velocidade,        │
│         relacional, joins        flexibilidade, escala   │
└──────────────────────────────────────────────────────────┘
```

**Regra de sincronização:** O `paciente_id_oracle` e `avaliacao_id_oracle` presentes nos documentos MongoDB são as chaves que permitem joins na camada de aplicação quando necessário relatório consolidado.
