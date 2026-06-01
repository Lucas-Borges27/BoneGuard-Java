-- =============================================================
-- BONEGUARD -- Plataforma de Rastreio e Prevenção de Osteoporose
-- DDL -- Criação de Tabelas (idempotente — não recria se já existe)
-- Oracle 19c+
-- =============================================================

-- TB_PACIENTE_BONEGUARD
DECLARE v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM user_tables WHERE table_name = 'TB_PACIENTE_BONEGUARD';
    IF v_cnt = 0 THEN
        EXECUTE IMMEDIATE q'[
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
                email               VARCHAR2(200),
                senha               VARCHAR2(200),
                role                VARCHAR2(10)    DEFAULT 'USER' NOT NULL,
                CONSTRAINT uq_pac_email      UNIQUE (email),
                CONSTRAINT chk_pac_sexo      CHECK (sexo IN ('M','F')),
                CONSTRAINT chk_pac_historico CHECK (historico_familiar IN ('S','N')),
                CONSTRAINT chk_pac_nivel     CHECK (nivel_atividade IN ('SEDENTARIO','MODERADO','ATIVO')),
                CONSTRAINT chk_pac_calcio    CHECK (alimentacao_calcio IN ('S','N')),
                CONSTRAINT chk_pac_idade     CHECK (idade BETWEEN 1 AND 130),
                CONSTRAINT chk_pac_peso      CHECK (peso > 0),
                CONSTRAINT chk_pac_role      CHECK (role IN ('ADMIN','USER'))
            )
        ]';
    END IF;
END;
/

-- TB_AVALIACAO_BONEGUARD
DECLARE v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM user_tables WHERE table_name = 'TB_AVALIACAO_BONEGUARD';
    IF v_cnt = 0 THEN
        EXECUTE IMMEDIATE q'[
            CREATE TABLE TB_AVALIACAO_BONEGUARD (
                id              NUMBER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                paciente_id     NUMBER          NOT NULL,
                score_risco     NUMBER(5,2)     NOT NULL,
                classificacao   VARCHAR2(10)    NOT NULL,
                data_avaliacao  DATE            DEFAULT SYSDATE NOT NULL,
                plano_gerado    CHAR(1)         DEFAULT 'N' NOT NULL,
                CONSTRAINT fk_aval_paciente FOREIGN KEY (paciente_id) REFERENCES TB_PACIENTE_BONEGUARD(id),
                CONSTRAINT chk_aval_score   CHECK (score_risco BETWEEN 0 AND 100),
                CONSTRAINT chk_aval_classif CHECK (classificacao IN ('BAIXO','MODERADO','ALTO')),
                CONSTRAINT chk_aval_plano   CHECK (plano_gerado IN ('S','N'))
            )
        ]';
    END IF;
END;
/

-- TB_RADIOGRAFIA_BONEGUARD
DECLARE v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM user_tables WHERE table_name = 'TB_RADIOGRAFIA_BONEGUARD';
    IF v_cnt = 0 THEN
        EXECUTE IMMEDIATE q'[
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
            )
        ]';
    END IF;
END;
/

-- TB_PLANO_SAUDE_BONEGUARD
DECLARE v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM user_tables WHERE table_name = 'TB_PLANO_SAUDE_BONEGUARD';
    IF v_cnt = 0 THEN
        EXECUTE IMMEDIATE q'[
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
            )
        ]';
    END IF;
END;
/

-- TB_EVOLUCAO_BONEGUARD
DECLARE v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM user_tables WHERE table_name = 'TB_EVOLUCAO_BONEGUARD';
    IF v_cnt = 0 THEN
        EXECUTE IMMEDIATE q'[
            CREATE TABLE TB_EVOLUCAO_BONEGUARD (
                id                      NUMBER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                paciente_id             NUMBER          NOT NULL,
                peso_atual              NUMBER(5,2)     NOT NULL,
                nivel_atividade_atual   VARCHAR2(20)    NOT NULL,
                observacoes             VARCHAR2(1000),
                data_registro           DATE            DEFAULT SYSDATE NOT NULL,
                CONSTRAINT fk_evol_paciente FOREIGN KEY (paciente_id) REFERENCES TB_PACIENTE_BONEGUARD(id),
                CONSTRAINT chk_evol_nivel   CHECK (nivel_atividade_atual IN ('SEDENTARIO','MODERADO','ATIVO')),
                CONSTRAINT chk_evol_peso    CHECK (peso_atual > 0)
            )
        ]';
    END IF;
END;
/

-- TB_ALERTA_BONEGUARD
DECLARE v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM user_tables WHERE table_name = 'TB_ALERTA_BONEGUARD';
    IF v_cnt = 0 THEN
        EXECUTE IMMEDIATE q'[
            CREATE TABLE TB_ALERTA_BONEGUARD (
                id              NUMBER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                paciente_id     NUMBER          NOT NULL,
                avaliacao_id    NUMBER          NOT NULL,
                mensagem        VARCHAR2(500)   NOT NULL,
                status          VARCHAR2(10)    DEFAULT 'PENDENTE' NOT NULL,
                data_criacao    DATE            DEFAULT SYSDATE NOT NULL,
                CONSTRAINT fk_alerta_paciente  FOREIGN KEY (paciente_id)  REFERENCES TB_PACIENTE_BONEGUARD(id),
                CONSTRAINT fk_alerta_avaliacao FOREIGN KEY (avaliacao_id) REFERENCES TB_AVALIACAO_BONEGUARD(id),
                CONSTRAINT chk_alerta_status   CHECK (status IN ('PENDENTE','ENVIADO','LIDO'))
            )
        ]';
    END IF;
END;
/

-- TB_AUDITORIA_BONEGUARD
DECLARE v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM user_tables WHERE table_name = 'TB_AUDITORIA_BONEGUARD';
    IF v_cnt = 0 THEN
        EXECUTE IMMEDIATE q'[
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
            )
        ]';
    END IF;
END;
/

-- Índices (verifica user_indexes antes de criar)
DECLARE v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM user_indexes WHERE index_name = 'IDX_AVAL_PACIENTE';
    IF v_cnt = 0 THEN EXECUTE IMMEDIATE 'CREATE INDEX idx_aval_paciente ON TB_AVALIACAO_BONEGUARD(paciente_id)'; END IF;
END;
/

DECLARE v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM user_indexes WHERE index_name = 'IDX_AVAL_CLASSIF';
    IF v_cnt = 0 THEN EXECUTE IMMEDIATE 'CREATE INDEX idx_aval_classif ON TB_AVALIACAO_BONEGUARD(classificacao)'; END IF;
END;
/

DECLARE v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM user_indexes WHERE index_name = 'IDX_RADIO_AVAL';
    IF v_cnt = 0 THEN EXECUTE IMMEDIATE 'CREATE INDEX idx_radio_aval ON TB_RADIOGRAFIA_BONEGUARD(avaliacao_id)'; END IF;
END;
/

DECLARE v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM user_indexes WHERE index_name = 'IDX_PLANO_AVAL';
    IF v_cnt = 0 THEN EXECUTE IMMEDIATE 'CREATE INDEX idx_plano_aval ON TB_PLANO_SAUDE_BONEGUARD(avaliacao_id)'; END IF;
END;
/

DECLARE v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM user_indexes WHERE index_name = 'IDX_EVOL_PACIENTE';
    IF v_cnt = 0 THEN EXECUTE IMMEDIATE 'CREATE INDEX idx_evol_paciente ON TB_EVOLUCAO_BONEGUARD(paciente_id)'; END IF;
END;
/

DECLARE v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM user_indexes WHERE index_name = 'IDX_ALERTA_STATUS_PAC';
    IF v_cnt = 0 THEN EXECUTE IMMEDIATE 'CREATE INDEX idx_alerta_status_pac ON TB_ALERTA_BONEGUARD(status, paciente_id)'; END IF;
END;
/

DECLARE v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM user_indexes WHERE index_name = 'IDX_ALERTA_PACIENTE';
    IF v_cnt = 0 THEN EXECUTE IMMEDIATE 'CREATE INDEX idx_alerta_paciente ON TB_ALERTA_BONEGUARD(paciente_id)'; END IF;
END;
/
