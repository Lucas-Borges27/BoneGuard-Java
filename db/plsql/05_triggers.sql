-- =============================================================
-- BONEGUARD -- Triggers
-- Oracle 19c+
-- =============================================================
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- =============================================================
-- TRG_AUDIT_AVALIACAO
-- Loga INSERT/UPDATE/DELETE em TB_AVALIACAO_BONEGUARD na tabela TB_AUDITORIA_BONEGUARD
--   INSERT  → dados_novos      = snapshot novo  | dados_anteriores = NULL
--   UPDATE  → dados_anteriores = snapshot antigo | dados_novos     = snapshot novo
--   DELETE  → dados_anteriores = snapshot antigo | dados_novos     = NULL
-- =============================================================
CREATE OR REPLACE TRIGGER TRG_AUDIT_AVALIACAO
    AFTER INSERT OR UPDATE OR DELETE ON TB_AVALIACAO_BONEGUARD
    FOR EACH ROW
DECLARE
    v_antes  CLOB;
    v_depois CLOB;
    v_op     VARCHAR2(10);
    v_id     NUMBER;
BEGIN
    IF INSERTING THEN
        v_op    := 'INSERT';
        v_id    := :NEW.id;
        v_depois := '{"id":' || :NEW.id ||
                    ',"paciente_id":' || :NEW.paciente_id ||
                    ',"score_risco":' || :NEW.score_risco ||
                    ',"classificacao":"' || :NEW.classificacao || '"' ||
                    ',"data_avaliacao":"' || TO_CHAR(:NEW.data_avaliacao,'YYYY-MM-DD') || '"' ||
                    ',"plano_gerado":"' || :NEW.plano_gerado || '"}';

    ELSIF UPDATING THEN
        v_op    := 'UPDATE';
        v_id    := :NEW.id;
        v_antes  := '{"id":' || :OLD.id ||
                    ',"paciente_id":' || :OLD.paciente_id ||
                    ',"score_risco":' || :OLD.score_risco ||
                    ',"classificacao":"' || :OLD.classificacao || '"' ||
                    ',"data_avaliacao":"' || TO_CHAR(:OLD.data_avaliacao,'YYYY-MM-DD') || '"' ||
                    ',"plano_gerado":"' || :OLD.plano_gerado || '"}';
        v_depois := '{"id":' || :NEW.id ||
                    ',"paciente_id":' || :NEW.paciente_id ||
                    ',"score_risco":' || :NEW.score_risco ||
                    ',"classificacao":"' || :NEW.classificacao || '"' ||
                    ',"data_avaliacao":"' || TO_CHAR(:NEW.data_avaliacao,'YYYY-MM-DD') || '"' ||
                    ',"plano_gerado":"' || :NEW.plano_gerado || '"}';

    ELSIF DELETING THEN
        v_op    := 'DELETE';
        v_id    := :OLD.id;
        v_antes  := '{"id":' || :OLD.id ||
                    ',"paciente_id":' || :OLD.paciente_id ||
                    ',"score_risco":' || :OLD.score_risco ||
                    ',"classificacao":"' || :OLD.classificacao || '"' ||
                    ',"data_avaliacao":"' || TO_CHAR(:OLD.data_avaliacao,'YYYY-MM-DD') || '"' ||
                    ',"plano_gerado":"' || :OLD.plano_gerado || '"}';
    END IF;

    INSERT INTO TB_AUDITORIA_BONEGUARD
        (tabela_afetada, registro_id, operacao, usuario_bd, data_operacao, dados_anteriores, dados_novos)
    VALUES
        ('TB_AVALIACAO_BONEGUARD', v_id, v_op, USER, SYSDATE, v_antes, v_depois);
END TRG_AUDIT_AVALIACAO;
/

-- =============================================================
-- TRG_ALERTA_AUTOMATICO
-- Ao inserir avaliação com classificação ALTO,
-- chama SP_GERAR_ALERTA automaticamente
-- =============================================================
CREATE OR REPLACE TRIGGER TRG_ALERTA_AUTOMATICO
    AFTER INSERT ON TB_AVALIACAO_BONEGUARD
    FOR EACH ROW
DECLARE
    v_alerta_id     NUMBER;
    v_nome          VARCHAR2(150);
    v_mensagem      VARCHAR2(500);
BEGIN
    IF :NEW.classificacao = 'ALTO' THEN
        -- Busca nome do paciente
        SELECT nome INTO v_nome
        FROM   TB_PACIENTE_BONEGUARD
        WHERE  id = :NEW.paciente_id;

        -- Monta mensagem contextualizada
        v_mensagem := 'ALERTA AUTOMÁTICO BONEGUARD: Paciente ' || v_nome ||
                      ' apresentou score ' || TO_CHAR(:NEW.score_risco, '990.00') ||
                      ' (ALTO RISCO) em ' || TO_CHAR(:NEW.data_avaliacao, 'DD/MM/YYYY') ||
                      '. Acompanhamento médico urgente necessário.';

        SP_GERAR_ALERTA(
            p_paciente_id  => :NEW.paciente_id,
            p_avaliacao_id => :NEW.id,
            p_mensagem     => v_mensagem,
            p_alerta_id    => v_alerta_id
        );

        DBMS_OUTPUT.PUT_LINE('[TRG_ALERTA_AUTOMATICO] Alerta #' || v_alerta_id ||
                             ' gerado para paciente "' || v_nome || '"');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Log de erro sem bloquear a inserção principal
        DBMS_OUTPUT.PUT_LINE('[WARN TRG_ALERTA_AUTOMATICO] Falha ao gerar alerta: ' || SQLERRM);
END TRG_ALERTA_AUTOMATICO;
/

-- =============================================================
-- TRG_PLANO_GERADO
-- Marca automaticamente plano_gerado = 'S' na avaliação
-- quando um plano de saúde é vinculado a ela
-- =============================================================
CREATE OR REPLACE TRIGGER TRG_PLANO_GERADO
    AFTER INSERT ON TB_PLANO_SAUDE_BONEGUARD
    FOR EACH ROW
BEGIN
    UPDATE TB_AVALIACAO_BONEGUARD
    SET    plano_gerado = 'S'
    WHERE  id           = :NEW.avaliacao_id
      AND  plano_gerado = 'N';  -- evita UPDATE desnecessário se já marcado
END TRG_PLANO_GERADO;
/

-- =============================================================
-- TRG_UPPER_NOME_PACIENTE
-- Formata nome em maiúsculo no INSERT/UPDATE de TB_PACIENTE_BONEGUARD
-- =============================================================
CREATE OR REPLACE TRIGGER TRG_UPPER_NOME_PACIENTE
    BEFORE INSERT OR UPDATE ON TB_PACIENTE_BONEGUARD
    FOR EACH ROW
BEGIN
    :NEW.nome := UPPER(TRIM(:NEW.nome));

    -- Garante que nivel_atividade também seja maiúsculo
    :NEW.nivel_atividade := UPPER(TRIM(:NEW.nivel_atividade));
END TRG_UPPER_NOME_PACIENTE;
/

-- =============================================================
-- Verificação de triggers criados
-- =============================================================
SELECT trigger_name, trigger_type, triggering_event, status
FROM   user_triggers
WHERE  trigger_name IN ('TRG_AUDIT_AVALIACAO','TRG_ALERTA_AUTOMATICO',
                        'TRG_PLANO_GERADO','TRG_UPPER_NOME_PACIENTE')
ORDER  BY trigger_name;

-- =============================================================
-- Teste dos triggers
-- =============================================================
DECLARE
    v_aval_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TESTE: TRG_UPPER_NOME_PACIENTE ===');
    INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio)
    VALUES ('maria teste da silva', 50, 'F', 60.0, 'N', 'sedentario', 'S');
    DBMS_OUTPUT.PUT_LINE('Inserido com nome em minúsculo — trigger deve converter para UPPER.');

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== TESTE: TRG_AUDIT_AVALIACAO + TRG_ALERTA_AUTOMATICO ===');
    -- Insere avaliação ALTO para disparar os dois triggers
    SP_REGISTRAR_AVALIACAO(
        p_paciente_id     => 7,
        p_score           => 82.5,
        p_radio_resultado => 'OSTEOPOROSE',
        p_radio_confianca => 0.935,
        p_avaliacao_id    => v_aval_id
    );

    -- Verifica auditoria
    DECLARE
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM   TB_AUDITORIA_BONEGUARD
        WHERE  tabela_afetada = 'TB_AVALIACAO_BONEGUARD'
          AND  operacao = 'INSERT';
        DBMS_OUTPUT.PUT_LINE('Registros de auditoria gerados: ' || v_count);
    END;

    -- Verifica alerta gerado
    DECLARE
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM   TB_ALERTA_BONEGUARD
        WHERE  avaliacao_id = v_aval_id;
        DBMS_OUTPUT.PUT_LINE('Alertas gerados pelo trigger: ' || v_count);
    END;

    ROLLBACK;
END;
/

-- Verifica nome convertido
SELECT id, nome, nivel_atividade FROM TB_PACIENTE_BONEGUARD WHERE nome = 'MARIA TESTE DA SILVA';

PROMPT === Triggers criados e testados com sucesso ===
