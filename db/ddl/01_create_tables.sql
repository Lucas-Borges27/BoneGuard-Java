-- =============================================================
-- BONEGUARD -- Plataforma de Rastreio e Prevenção de Osteoporose
-- DDL -- Criação de Tabelas
-- Oracle 19c+
-- =============================================================

-- Remove objetos anteriores (ordem inversa de FK)
BEGIN
    FOR t IN (SELECT table_name FROM user_tables
              WHERE table_name IN (
                'TB_AUDITORIA_BONEGUARD','TB_ALERTA_BONEGUARD','TB_EVOLUCAO_BONEGUARD',
                'TB_PLANO_SAUDE_BONEGUARD','TB_RADIOGRAFIA_BONEGUARD','TB_AVALIACAO_BONEGUARD','TB_PACIENTE_BONEGUARD'))
    LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
END;
/

-- =============================================================
-- TB_PACIENTE_BONEGUARD
-- =============================================================
CREATE TABLE TB_PACIENTE_BONEGUARD (
    id                  NUMBER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome                VARCHAR2(150)   NOT NULL,
    idade               NUMBER(3)       NOT NULL,
    sexo                CHAR(1)         NOT NULL,
    peso                NUMBER(5,2)     NOT NULL,
    historico_familiar  CHAR(1)         DEFAULT 'N' NOT NULL,
    nivel_atividade     VARCHAR2(20)    DEFAULT 'SEDENTARIO' NOT NULL,
    alimentacao_calcio  CHAR(1)         DEFAULT 'N' NOT NULL,
    data_cadastro       DATE            DEFAULT SYSDATE NOT NULL,
    CONSTRAINT chk_pac_sexo         CHECK (sexo IN ('M','F')),
    CONSTRAINT chk_pac_historico    CHECK (historico_familiar IN ('S','N')),
    CONSTRAINT chk_pac_nivel        CHECK (nivel_atividade IN ('SEDENTARIO','MODERADO','ATIVO')),
    CONSTRAINT chk_pac_calcio       CHECK (alimentacao_calcio IN ('S','N')),
    CONSTRAINT chk_pac_idade        CHECK (idade BETWEEN 1 AND 130),
    CONSTRAINT chk_pac_peso         CHECK (peso > 0)
);

COMMENT ON TABLE  TB_PACIENTE_BONEGUARD IS 'Cadastro de pacientes monitorados pelo BoneGuard';
COMMENT ON COLUMN TB_PACIENTE_BONEGUARD.nivel_atividade IS 'SEDENTARIO | MODERADO | ATIVO';
COMMENT ON COLUMN TB_PACIENTE_BONEGUARD.historico_familiar IS 'S = histórico de osteoporose na família';

-- =============================================================
-- TB_AVALIACAO_BONEGUARD
-- =============================================================
CREATE TABLE TB_AVALIACAO_BONEGUARD (
    id              NUMBER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    paciente_id     NUMBER          NOT NULL,
    score_risco     NUMBER(5,2)     NOT NULL,
    classificacao   VARCHAR2(10)    NOT NULL,
    data_avaliacao  DATE            DEFAULT SYSDATE NOT NULL,
    plano_gerado    CHAR(1)         DEFAULT 'N' NOT NULL,
    CONSTRAINT fk_aval_paciente  FOREIGN KEY (paciente_id) REFERENCES TB_PACIENTE_BONEGUARD(id),
    CONSTRAINT chk_aval_score    CHECK (score_risco BETWEEN 0 AND 100),
    CONSTRAINT chk_aval_classif  CHECK (classificacao IN ('BAIXO','MODERADO','ALTO')),
    CONSTRAINT chk_aval_plano    CHECK (plano_gerado IN ('S','N'))
);

COMMENT ON TABLE  TB_AVALIACAO_BONEGUARD IS 'Avaliações de risco ósseo geradas pela IA';
COMMENT ON COLUMN TB_AVALIACAO_BONEGUARD.score_risco IS '0 a 100; quanto maior, maior o risco';

-- =============================================================
-- TB_RADIOGRAFIA_BONEGUARD
-- =============================================================
CREATE TABLE TB_RADIOGRAFIA_BONEGUARD (
    id              NUMBER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    avaliacao_id    NUMBER          NOT NULL,
    caminho_imagem  VARCHAR2(500),
    resultado_ia    VARCHAR2(15)    NOT NULL,
    confianca       NUMBER(4,3)     NOT NULL,
    data_analise    DATE            DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_radio_avaliacao  FOREIGN KEY (avaliacao_id) REFERENCES TB_AVALIACAO_BONEGUARD(id),
    CONSTRAINT chk_radio_resultado CHECK (resultado_ia IN ('NORMAL','OSTEOPENIA','OSTEOPOROSE')),
    CONSTRAINT chk_radio_confianca CHECK (confianca BETWEEN 0 AND 1)
);

COMMENT ON TABLE  TB_RADIOGRAFIA_BONEGUARD IS 'Resultados da análise de raio-x por IA';
COMMENT ON COLUMN TB_RADIOGRAFIA_BONEGUARD.caminho_imagem IS 'Caminho ou URL do arquivo de imagem analisado pela IA';

-- =============================================================
-- TB_PLANO_SAUDE_BONEGUARD
-- =============================================================
CREATE TABLE TB_PLANO_SAUDE_BONEGUARD (
    id              NUMBER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    avaliacao_id    NUMBER          NOT NULL,
    categoria       VARCHAR2(10)    NOT NULL,
    descricao       VARCHAR2(2000)  NOT NULL,
    ativo           CHAR(1)         DEFAULT 'S' NOT NULL,
    data_criacao    DATE            DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_plano_avaliacao  FOREIGN KEY (avaliacao_id) REFERENCES TB_AVALIACAO_BONEGUARD(id),
    CONSTRAINT chk_plano_categoria CHECK (categoria IN ('EXERCICIO','NUTRICAO')),
    CONSTRAINT chk_plano_ativo     CHECK (ativo IN ('S','N'))
);

COMMENT ON TABLE  TB_PLANO_SAUDE_BONEGUARD IS 'Planos personalizados de exercício e nutrição';

-- =============================================================
-- TB_EVOLUCAO_BONEGUARD
-- =============================================================
CREATE TABLE TB_EVOLUCAO_BONEGUARD (
    id                      NUMBER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    paciente_id             NUMBER          NOT NULL,
    peso_atual              NUMBER(5,2)     NOT NULL,
    nivel_atividade_atual   VARCHAR2(20)    NOT NULL,
    observacoes             VARCHAR2(1000),
    data_registro           DATE            DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_evol_paciente    FOREIGN KEY (paciente_id) REFERENCES TB_PACIENTE_BONEGUARD(id),
    CONSTRAINT chk_evol_nivel      CHECK (nivel_atividade_atual IN ('SEDENTARIO','MODERADO','ATIVO')),
    CONSTRAINT chk_evol_peso       CHECK (peso_atual > 0)
);

COMMENT ON TABLE  TB_EVOLUCAO_BONEGUARD IS 'Evolução clínica periódica do paciente';

-- =============================================================
-- TB_ALERTA_BONEGUARD
-- =============================================================
CREATE TABLE TB_ALERTA_BONEGUARD (
    id              NUMBER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    paciente_id     NUMBER          NOT NULL,
    avaliacao_id    NUMBER          NOT NULL,
    mensagem        VARCHAR2(500)   NOT NULL,
    status          VARCHAR2(10)    DEFAULT 'PENDENTE' NOT NULL,
    data_criacao    DATE            DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_alerta_paciente   FOREIGN KEY (paciente_id)  REFERENCES TB_PACIENTE_BONEGUARD(id),
    CONSTRAINT fk_alerta_avaliacao  FOREIGN KEY (avaliacao_id) REFERENCES TB_AVALIACAO_BONEGUARD(id),
    CONSTRAINT chk_alerta_status    CHECK (status IN ('PENDENTE','ENVIADO','LIDO'))
);

COMMENT ON TABLE  TB_ALERTA_BONEGUARD IS 'Alertas gerados para pacientes em situação de risco';

-- =============================================================
-- TB_AUDITORIA_BONEGUARD
-- =============================================================
CREATE TABLE TB_AUDITORIA_BONEGUARD (
    id               NUMBER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tabela_afetada   VARCHAR2(50)    NOT NULL,
    registro_id      NUMBER,
    operacao         VARCHAR2(10)    NOT NULL,
    usuario_bd       VARCHAR2(100)   DEFAULT USER NOT NULL,
    data_operacao    DATE            DEFAULT SYSDATE NOT NULL,
    dados_anteriores CLOB,
    dados_novos      CLOB,
    CONSTRAINT chk_audit_operacao CHECK (operacao IN ('INSERT','UPDATE','DELETE'))
);

COMMENT ON TABLE  TB_AUDITORIA_BONEGUARD IS 'Log de auditoria de operações DML nas tabelas críticas';
COMMENT ON COLUMN TB_AUDITORIA_BONEGUARD.registro_id      IS 'PK do registro afetado na tabela de origem';
COMMENT ON COLUMN TB_AUDITORIA_BONEGUARD.dados_anteriores IS 'Snapshot JSON do registro antes da operação (UPDATE/DELETE)';
COMMENT ON COLUMN TB_AUDITORIA_BONEGUARD.dados_novos      IS 'Snapshot JSON do registro após a operação (INSERT/UPDATE)';

-- =============================================================
-- Índices para performance
-- =============================================================
CREATE INDEX idx_aval_paciente   ON TB_AVALIACAO_BONEGUARD  (paciente_id);
CREATE INDEX idx_aval_classif    ON TB_AVALIACAO_BONEGUARD  (classificacao);
CREATE INDEX idx_radio_aval      ON TB_RADIOGRAFIA_BONEGUARD(avaliacao_id);
CREATE INDEX idx_plano_aval      ON TB_PLANO_SAUDE_BONEGUARD(avaliacao_id);
CREATE INDEX idx_evol_paciente   ON TB_EVOLUCAO_BONEGUARD   (paciente_id);
-- Índice composto: filtragens mais comuns são por status + paciente
CREATE INDEX idx_alerta_status_pac ON TB_ALERTA_BONEGUARD (status, paciente_id);
CREATE INDEX idx_alerta_paciente   ON TB_ALERTA_BONEGUARD (paciente_id);

COMMIT;

PROMPT === DDL concluído com sucesso ===
