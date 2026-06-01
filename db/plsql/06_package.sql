-- =============================================================
-- BONEGUARD -- Package PKG_BONEGUARD
-- Specification + Body
-- Oracle 19c+
-- =============================================================
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- =============================================================
-- PACKAGE SPECIFICATION
-- =============================================================
CREATE OR REPLACE PACKAGE PKG_BONEGUARD AS

    -- Constantes de classificação
    C_RISCO_BAIXO    CONSTANT VARCHAR2(10) := 'BAIXO';
    C_RISCO_MODERADO CONSTANT VARCHAR2(10) := 'MODERADO';
    C_RISCO_ALTO     CONSTANT VARCHAR2(10) := 'ALTO';

    C_LIMIAR_BAIXO   CONSTANT NUMBER := 30;
    C_LIMIAR_ALTO    CONSTANT NUMBER := 70;

    -- Tipo para retorno de relatório
    TYPE t_rec_paciente IS RECORD (
        paciente_id     NUMBER,
        nome            VARCHAR2(150),
        media_score     NUMBER,
        classificacao   VARCHAR2(10),
        total_alertas   NUMBER
    );

    -- Procedures
    PROCEDURE SP_REGISTRAR_AVALIACAO(
        p_paciente_id       IN  NUMBER,
        p_score             IN  NUMBER,
        p_radio_resultado   IN  VARCHAR2 DEFAULT NULL,
        p_radio_confianca   IN  NUMBER   DEFAULT NULL,
        p_avaliacao_id      OUT NUMBER
    );

    PROCEDURE SP_GERAR_ALERTA(
        p_paciente_id   IN  NUMBER,
        p_avaliacao_id  IN  NUMBER,
        p_mensagem      IN  VARCHAR2,
        p_alerta_id     OUT NUMBER
    );

    -- Functions
    FUNCTION FN_CLASSIFICAR_RISCO(
        p_score IN NUMBER
    ) RETURN VARCHAR2;

    FUNCTION FN_MEDIA_SCORE(
        p_paciente_id IN NUMBER
    ) RETURN NUMBER;

    -- Procedure de diagnóstico (exclusiva do package)
    PROCEDURE SP_DIAGNOSTICO_PACIENTE(
        p_paciente_id IN NUMBER
    );

END PKG_BONEGUARD;
/

-- =============================================================
-- PACKAGE BODY
-- =============================================================
CREATE OR REPLACE PACKAGE BODY PKG_BONEGUARD AS

    -- -------------------------------------------------------
    -- SP_REGISTRAR_AVALIACAO (reimplementação no package)
    -- -------------------------------------------------------
    PROCEDURE SP_REGISTRAR_AVALIACAO(
        p_paciente_id       IN  NUMBER,
        p_score             IN  NUMBER,
        p_radio_resultado   IN  VARCHAR2 DEFAULT NULL,
        p_radio_confianca   IN  NUMBER   DEFAULT NULL,
        p_avaliacao_id      OUT NUMBER
    ) AS
        v_classificacao VARCHAR2(10);
        v_paciente_ok   NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_paciente_ok
        FROM   TB_PACIENTE_BONEGUARD WHERE id = p_paciente_id;

        IF v_paciente_ok = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Paciente ID ' || p_paciente_id || ' não encontrado.');
        END IF;

        IF p_score < 0 OR p_score > 100 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Score inválido: ' || p_score);
        END IF;

        v_classificacao := FN_CLASSIFICAR_RISCO(p_score);

        INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
        VALUES (p_paciente_id, p_score, v_classificacao, SYSDATE, 'N')
        RETURNING id INTO p_avaliacao_id;

        IF p_radio_resultado IS NOT NULL THEN
            INSERT INTO TB_RADIOGRAFIA_BONEGUARD (avaliacao_id, resultado_ia, confianca, data_analise)
            VALUES (p_avaliacao_id, p_radio_resultado, NVL(p_radio_confianca, 0.5), SYSDATE);
        END IF;

        DBMS_OUTPUT.PUT_LINE('[PKG_BONEGUARD.SP_REGISTRAR_AVALIACAO] Avaliação #' ||
                              p_avaliacao_id || ' | Score: ' || p_score ||
                              ' | Classe: ' || v_classificacao);
        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('[ERRO] ' || SQLERRM);
            RAISE;
    END SP_REGISTRAR_AVALIACAO;

    -- -------------------------------------------------------
    -- SP_GERAR_ALERTA (reimplementação no package)
    -- -------------------------------------------------------
    PROCEDURE SP_GERAR_ALERTA(
        p_paciente_id   IN  NUMBER,
        p_avaliacao_id  IN  NUMBER,
        p_mensagem      IN  VARCHAR2,
        p_alerta_id     OUT NUMBER
    ) AS
        v_pac_ok    NUMBER;
        v_aval_ok   NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_pac_ok  FROM TB_PACIENTE_BONEGUARD  WHERE id = p_paciente_id;
        SELECT COUNT(*) INTO v_aval_ok FROM TB_AVALIACAO_BONEGUARD WHERE id = p_avaliacao_id;

        IF v_pac_ok = 0 THEN
            RAISE_APPLICATION_ERROR(-20020, 'Paciente ID ' || p_paciente_id || ' não encontrado.');
        END IF;
        IF v_aval_ok = 0 THEN
            RAISE_APPLICATION_ERROR(-20021, 'Avaliação ID ' || p_avaliacao_id || ' não encontrada.');
        END IF;

        INSERT INTO TB_ALERTA_BONEGUARD (paciente_id, avaliacao_id, mensagem, status, data_criacao)
        VALUES (p_paciente_id, p_avaliacao_id,
                NVL(p_mensagem, 'Alerta automático BoneGuard.'),
                'PENDENTE', SYSDATE)
        RETURNING id INTO p_alerta_id;

        DBMS_OUTPUT.PUT_LINE('[PKG_BONEGUARD.SP_GERAR_ALERTA] Alerta #' || p_alerta_id ||
                              ' criado para paciente #' || p_paciente_id);
        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('[ERRO] ' || SQLERRM);
            RAISE;
    END SP_GERAR_ALERTA;

    -- -------------------------------------------------------
    -- FN_CLASSIFICAR_RISCO
    -- -------------------------------------------------------
    FUNCTION FN_CLASSIFICAR_RISCO(
        p_score IN NUMBER
    ) RETURN VARCHAR2 AS
    BEGIN
        IF p_score IS NULL THEN
            RETURN 'INDEFINIDO';
        ELSIF p_score < C_LIMIAR_BAIXO THEN
            RETURN C_RISCO_BAIXO;
        ELSIF p_score < C_LIMIAR_ALTO THEN
            RETURN C_RISCO_MODERADO;
        ELSE
            RETURN C_RISCO_ALTO;
        END IF;
    END FN_CLASSIFICAR_RISCO;

    -- -------------------------------------------------------
    -- FN_MEDIA_SCORE
    -- -------------------------------------------------------
    FUNCTION FN_MEDIA_SCORE(
        p_paciente_id IN NUMBER
    ) RETURN NUMBER AS
        v_media NUMBER;
    BEGIN
        SELECT AVG(score_risco)
        INTO   v_media
        FROM   TB_AVALIACAO_BONEGUARD
        WHERE  paciente_id = p_paciente_id;

        RETURN NVL(ROUND(v_media, 2), 0);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
    END FN_MEDIA_SCORE;

    -- -------------------------------------------------------
    -- SP_DIAGNOSTICO_PACIENTE (exclusivo do package)
    -- Gera resumo completo do paciente
    -- -------------------------------------------------------
    PROCEDURE SP_DIAGNOSTICO_PACIENTE(
        p_paciente_id IN NUMBER
    ) AS
        v_nome          VARCHAR2(150);
        v_idade         NUMBER;
        v_media         NUMBER;
        v_classe        VARCHAR2(10);
        v_alertas       NUMBER;
        v_ultima_aval   DATE;
        v_ultima_class  VARCHAR2(10);
        v_planos_ativos NUMBER;
    BEGIN
        SELECT nome, idade INTO v_nome, v_idade
        FROM   TB_PACIENTE_BONEGUARD WHERE id = p_paciente_id;

        v_media  := FN_MEDIA_SCORE(p_paciente_id);
        v_classe := FN_CLASSIFICAR_RISCO(v_media);

        SELECT COUNT(*) INTO v_alertas
        FROM   TB_ALERTA_BONEGUARD
        WHERE  paciente_id = p_paciente_id
          AND  status IN ('PENDENTE','ENVIADO');

        SELECT MAX(data_avaliacao), MAX(classificacao)
        INTO   v_ultima_aval, v_ultima_class
        FROM   TB_AVALIACAO_BONEGUARD
        WHERE  paciente_id = p_paciente_id;

        SELECT COUNT(*) INTO v_planos_ativos
        FROM   TB_PLANO_SAUDE_BONEGUARD ps
        JOIN   TB_AVALIACAO_BONEGUARD av ON av.id = ps.avaliacao_id
        WHERE  av.paciente_id = p_paciente_id AND ps.ativo = 'S';

        DBMS_OUTPUT.PUT_LINE('╔══════════════════════════════════════╗');
        DBMS_OUTPUT.PUT_LINE('║   DIAGNÓSTICO BONEGUARD              ║');
        DBMS_OUTPUT.PUT_LINE('╠══════════════════════════════════════╣');
        DBMS_OUTPUT.PUT_LINE('║ Paciente     : ' || RPAD(v_nome, 22)    || '║');
        DBMS_OUTPUT.PUT_LINE('║ Idade        : ' || RPAD(v_idade || ' anos', 22) || '║');
        DBMS_OUTPUT.PUT_LINE('║ Média Score  : ' || RPAD(TO_CHAR(v_media,'990.00'), 22) || '║');
        DBMS_OUTPUT.PUT_LINE('║ Classe Média : ' || RPAD(v_classe, 22)  || '║');
        DBMS_OUTPUT.PUT_LINE('║ Última Aval  : ' || RPAD(TO_CHAR(v_ultima_aval,'DD/MM/YYYY'), 22) || '║');
        DBMS_OUTPUT.PUT_LINE('║ Última Classe: ' || RPAD(NVL(v_ultima_class,'N/A'), 22) || '║');
        DBMS_OUTPUT.PUT_LINE('║ Planos Ativos: ' || RPAD(v_planos_ativos, 22) || '║');
        DBMS_OUTPUT.PUT_LINE('║ Alertas Atv. : ' || RPAD(v_alertas, 22) || '║');
        DBMS_OUTPUT.PUT_LINE('╚══════════════════════════════════════╝');

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('[ERRO] Paciente ID ' || p_paciente_id || ' não encontrado.');
    END SP_DIAGNOSTICO_PACIENTE;

END PKG_BONEGUARD;
/

-- =============================================================
-- Verificação e testes do Package
-- =============================================================
SELECT object_name, object_type, status
FROM   user_objects
WHERE  object_name = 'PKG_BONEGUARD'
ORDER  BY object_type;

-- Teste do package
DECLARE
    v_aval_id   NUMBER;
    v_alerta_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TESTE PKG_BONEGUARD ===');

    -- Classificações
    DBMS_OUTPUT.PUT_LINE('FN_CLASSIFICAR_RISCO(20): ' || PKG_BONEGUARD.FN_CLASSIFICAR_RISCO(20));
    DBMS_OUTPUT.PUT_LINE('FN_CLASSIFICAR_RISCO(55): ' || PKG_BONEGUARD.FN_CLASSIFICAR_RISCO(55));
    DBMS_OUTPUT.PUT_LINE('FN_CLASSIFICAR_RISCO(90): ' || PKG_BONEGUARD.FN_CLASSIFICAR_RISCO(90));

    -- Média de scores
    DBMS_OUTPUT.PUT_LINE('FN_MEDIA_SCORE(1): '  || PKG_BONEGUARD.FN_MEDIA_SCORE(1));
    DBMS_OUTPUT.PUT_LINE('FN_MEDIA_SCORE(10): ' || PKG_BONEGUARD.FN_MEDIA_SCORE(10));

    -- Diagnóstico completo
    DBMS_OUTPUT.PUT_LINE('');
    PKG_BONEGUARD.SP_DIAGNOSTICO_PACIENTE(1);
    PKG_BONEGUARD.SP_DIAGNOSTICO_PACIENTE(10);
    PKG_BONEGUARD.SP_DIAGNOSTICO_PACIENTE(15);
END;
/

PROMPT === Package PKG_BONEGUARD criado e testado com sucesso ===
