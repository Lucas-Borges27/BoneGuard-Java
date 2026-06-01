-- =============================================================
-- BONEGUARD -- Stored Procedures
-- Oracle 19c+
-- =============================================================

-- =============================================================
-- SP_REGISTRAR_AVALIACAO
-- Insere avaliação calculando classificação automaticamente
-- =============================================================
CREATE OR REPLACE PROCEDURE SP_REGISTRAR_AVALIACAO(
    p_paciente_id       IN  NUMBER,
    p_score             IN  NUMBER,
    p_radio_resultado   IN  VARCHAR2 DEFAULT NULL,
    p_radio_confianca   IN  NUMBER   DEFAULT NULL,
    p_avaliacao_id      OUT NUMBER
)
AS
    v_classificacao VARCHAR2(10);
    v_paciente_ok   NUMBER;
BEGIN
    -- Valida paciente
    SELECT COUNT(*) INTO v_paciente_ok
    FROM   TB_PACIENTE_BONEGUARD
    WHERE  id = p_paciente_id;

    IF v_paciente_ok = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Paciente ID ' || p_paciente_id || ' não encontrado.');
    END IF;

    -- Valida score
    IF p_score < 0 OR p_score > 100 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Score deve estar entre 0 e 100. Recebido: ' || p_score);
    END IF;

    -- Calcula classificação
    IF p_score < 30 THEN
        v_classificacao := 'BAIXO';
    ELSIF p_score < 70 THEN
        v_classificacao := 'MODERADO';
    ELSE
        v_classificacao := 'ALTO';
    END IF;

    -- Insere avaliação
    INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
    VALUES (p_paciente_id, p_score, v_classificacao, SYSDATE, 'N')
    RETURNING id INTO p_avaliacao_id;

    -- Insere radiografia se fornecida
    IF p_radio_resultado IS NOT NULL THEN
        IF p_radio_resultado NOT IN ('NORMAL','OSTEOPENIA','OSTEOPOROSE') THEN
            RAISE_APPLICATION_ERROR(-20003, 'Resultado de IA inválido: ' || p_radio_resultado);
        END IF;

        INSERT INTO TB_RADIOGRAFIA_BONEGUARD (avaliacao_id, resultado_ia, confianca, data_analise)
        VALUES (p_avaliacao_id, p_radio_resultado, NVL(p_radio_confianca, 0.5), SYSDATE);
    END IF;

    DBMS_OUTPUT.PUT_LINE('[SP_REGISTRAR_AVALIACAO] Avaliação #' || p_avaliacao_id ||
                         ' criada. Score: ' || p_score || ' | Classificação: ' || v_classificacao);
    -- COMMIT/ROLLBACK omitidos: controle de transação é responsabilidade do chamador.
    -- Isso permite que a procedure seja invocada por triggers sem gerar ORA-04092.

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('[ERRO SP_REGISTRAR_AVALIACAO] ' || SQLERRM);
        RAISE;
END SP_REGISTRAR_AVALIACAO;
/

-- =============================================================
-- SP_GERAR_PLANO_SAUDE
-- Cria plano de saúde baseado no score da avaliação
-- =============================================================
CREATE OR REPLACE PROCEDURE SP_GERAR_PLANO_SAUDE(
    p_avaliacao_id  IN NUMBER,
    p_categoria     IN VARCHAR2,
    p_descricao     IN VARCHAR2,
    p_plano_id      OUT NUMBER
)
AS
    v_aval_ok       NUMBER;
    v_classificacao VARCHAR2(10);
BEGIN
    -- Valida avaliação
    SELECT COUNT(*), MAX(classificacao)
    INTO   v_aval_ok, v_classificacao
    FROM   TB_AVALIACAO_BONEGUARD
    WHERE  id = p_avaliacao_id;

    IF v_aval_ok = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Avaliação ID ' || p_avaliacao_id || ' não encontrada.');
    END IF;

    -- Valida categoria
    IF p_categoria NOT IN ('EXERCICIO','NUTRICAO') THEN
        RAISE_APPLICATION_ERROR(-20011, 'Categoria inválida: ' || p_categoria || '. Use EXERCICIO ou NUTRICAO.');
    END IF;

    -- Insere plano
    INSERT INTO TB_PLANO_SAUDE_BONEGUARD (avaliacao_id, categoria, descricao, ativo, data_criacao)
    VALUES (p_avaliacao_id, p_categoria, p_descricao, 'S', SYSDATE)
    RETURNING id INTO p_plano_id;

    -- Marca avaliação como com plano gerado
    UPDATE TB_AVALIACAO_BONEGUARD SET plano_gerado = 'S'
    WHERE  id = p_avaliacao_id;

    DBMS_OUTPUT.PUT_LINE('[SP_GERAR_PLANO_SAUDE] Plano #' || p_plano_id ||
                         ' criado para avaliação #' || p_avaliacao_id ||
                         ' | Categoria: ' || p_categoria ||
                         ' | Classificação paciente: ' || v_classificacao);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('[ERRO SP_GERAR_PLANO_SAUDE] ' || SQLERRM);
        RAISE;
END SP_GERAR_PLANO_SAUDE;
/

-- =============================================================
-- SP_GERAR_ALERTA
-- Cria alerta com status PENDENTE
-- =============================================================
CREATE OR REPLACE PROCEDURE SP_GERAR_ALERTA(
    p_paciente_id   IN  NUMBER,
    p_avaliacao_id  IN  NUMBER,
    p_mensagem      IN  VARCHAR2,
    p_alerta_id     OUT NUMBER
)
AS
    v_pac_ok    NUMBER;
BEGIN
    -- Valida paciente (leitura segura — tabela diferente da que disparou o trigger)
    SELECT COUNT(*) INTO v_pac_ok FROM TB_PACIENTE_BONEGUARD WHERE id = p_paciente_id;

    IF v_pac_ok = 0 THEN
        RAISE_APPLICATION_ERROR(-20020, 'Paciente ID ' || p_paciente_id || ' não encontrado.');
    END IF;

    -- Validação de TB_AVALIACAO_BONEGUARD removida: a FK em TB_ALERTA_BONEGUARD.avaliacao_id
    -- já garante integridade referencial. Manter o SELECT causaria ORA-04091 (mutating table)
    -- quando esta procedure é chamada pelo trigger TRG_ALERTA_AUTOMATICO.

    -- Insere alerta
    INSERT INTO TB_ALERTA_BONEGUARD (paciente_id, avaliacao_id, mensagem, status, data_criacao)
    VALUES (p_paciente_id, p_avaliacao_id,
            NVL(p_mensagem, 'Alerta automático gerado pelo BoneGuard.'),
            'PENDENTE', SYSDATE)
    RETURNING id INTO p_alerta_id;

    DBMS_OUTPUT.PUT_LINE('[SP_GERAR_ALERTA] Alerta #' || p_alerta_id ||
                         ' criado para paciente #' || p_paciente_id ||
                         ' (avaliação #' || p_avaliacao_id || ')');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('[ERRO SP_GERAR_ALERTA] ' || SQLERRM);
        RAISE;
END SP_GERAR_ALERTA;
/

-- =============================================================
-- Teste das procedures
-- =============================================================
SET SERVEROUTPUT ON SIZE UNLIMITED;
DECLARE
    v_aval_id   NUMBER;
    v_plano_id  NUMBER;
    v_alert_id  NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TESTANDO SP_REGISTRAR_AVALIACAO ===');
    SP_REGISTRAR_AVALIACAO(
        p_paciente_id     => 5,
        p_score           => 75.0,
        p_radio_resultado => 'OSTEOPOROSE',
        p_radio_confianca => 0.910,
        p_avaliacao_id    => v_aval_id
    );

    DBMS_OUTPUT.PUT_LINE('=== TESTANDO SP_GERAR_PLANO_SAUDE ===');
    SP_GERAR_PLANO_SAUDE(
        p_avaliacao_id => v_aval_id,
        p_categoria    => 'EXERCICIO',
        p_descricao    => 'Plano teste: caminhada e musculação leve 3x/sem.',
        p_plano_id     => v_plano_id
    );

    DBMS_OUTPUT.PUT_LINE('=== TESTANDO SP_GERAR_ALERTA ===');
    SP_GERAR_ALERTA(
        p_paciente_id  => 5,
        p_avaliacao_id => v_aval_id,
        p_mensagem     => 'Teste de alerta: paciente atingiu risco ALTO.',
        p_alerta_id    => v_alert_id
    );

    COMMIT; -- controle de transação no chamador, não nas procedures
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('[ERRO BLOCO TESTE] ' || SQLERRM);
        RAISE;
END;
/

PROMPT === Procedures criadas e testadas com sucesso ===
