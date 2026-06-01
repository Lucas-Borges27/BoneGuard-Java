-- =============================================================
-- BONEGUARD -- Functions
-- Oracle 19c+
-- =============================================================

-- =============================================================
-- FN_CLASSIFICAR_RISCO
-- Retorna BAIXO / MODERADO / ALTO com base no score
-- =============================================================
CREATE OR REPLACE FUNCTION FN_CLASSIFICAR_RISCO(
    p_score IN NUMBER
) RETURN VARCHAR2
AS
BEGIN
    IF p_score IS NULL THEN
        RETURN 'INDEFINIDO';
    ELSIF p_score < 30 THEN
        RETURN 'BAIXO';
    ELSIF p_score < 70 THEN
        RETURN 'MODERADO';
    ELSE
        RETURN 'ALTO';
    END IF;
END FN_CLASSIFICAR_RISCO;
/

-- =============================================================
-- FN_MEDIA_SCORE
-- Retorna a média de scores de todas as avaliações do paciente
-- =============================================================
CREATE OR REPLACE FUNCTION FN_MEDIA_SCORE(
    p_paciente_id IN NUMBER
) RETURN NUMBER
AS
    v_media     NUMBER;
    v_existente NUMBER;
BEGIN
    -- Verifica se paciente existe
    SELECT COUNT(*) INTO v_existente
    FROM   TB_PACIENTE_BONEGUARD
    WHERE  id = p_paciente_id;

    IF v_existente = 0 THEN
        RAISE_APPLICATION_ERROR(-20030, 'Paciente ID ' || p_paciente_id || ' não encontrado.');
    END IF;

    SELECT AVG(score_risco)
    INTO   v_media
    FROM   TB_AVALIACAO_BONEGUARD
    WHERE  paciente_id = p_paciente_id;

    RETURN NVL(ROUND(v_media, 2), 0);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END FN_MEDIA_SCORE;
/

-- =============================================================
-- FN_TOTAL_ALERTAS_ATIVOS
-- Retorna count de alertas PENDENTE ou ENVIADO do paciente
-- =============================================================
CREATE OR REPLACE FUNCTION FN_TOTAL_ALERTAS_ATIVOS(
    p_paciente_id IN NUMBER
) RETURN NUMBER
AS
    v_total NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO   v_total
    FROM   TB_ALERTA_BONEGUARD
    WHERE  paciente_id = p_paciente_id
      AND  status IN ('PENDENTE','ENVIADO');

    RETURN NVL(v_total, 0);

EXCEPTION
    WHEN OTHERS THEN
        RETURN -1;
END FN_TOTAL_ALERTAS_ATIVOS;
/

-- =============================================================
-- Teste das Functions
-- =============================================================
SET SERVEROUTPUT ON SIZE UNLIMITED;
DECLARE
    v_classe    VARCHAR2(10);
    v_media     NUMBER;
    v_alertas   NUMBER;
BEGIN
    -- Testa FN_CLASSIFICAR_RISCO
    DBMS_OUTPUT.PUT_LINE('=== FN_CLASSIFICAR_RISCO ===');
    DBMS_OUTPUT.PUT_LINE('Score  15 -> ' || FN_CLASSIFICAR_RISCO(15));
    DBMS_OUTPUT.PUT_LINE('Score  50 -> ' || FN_CLASSIFICAR_RISCO(50));
    DBMS_OUTPUT.PUT_LINE('Score  85 -> ' || FN_CLASSIFICAR_RISCO(85));
    DBMS_OUTPUT.PUT_LINE('Score NULL -> ' || FN_CLASSIFICAR_RISCO(NULL));

    -- Testa FN_MEDIA_SCORE para pacientes com múltiplas avaliações
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== FN_MEDIA_SCORE ===');
    FOR i IN 1..5 LOOP
        v_media := FN_MEDIA_SCORE(i);
        DBMS_OUTPUT.PUT_LINE('Paciente #' || i || ' -> Média: ' ||
                              TO_CHAR(v_media, '990.00') ||
                              ' (' || FN_CLASSIFICAR_RISCO(v_media) || ')');
    END LOOP;

    -- Testa FN_TOTAL_ALERTAS_ATIVOS
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== FN_TOTAL_ALERTAS_ATIVOS ===');
    FOR i IN 1..5 LOOP
        v_alertas := FN_TOTAL_ALERTAS_ATIVOS(i);
        DBMS_OUTPUT.PUT_LINE('Paciente #' || i || ' -> Alertas ativos: ' || v_alertas);
    END LOOP;
END;
/

-- Uso em SELECT
SELECT
    p.nome,
    FN_MEDIA_SCORE(p.id)            AS media_score,
    FN_CLASSIFICAR_RISCO(FN_MEDIA_SCORE(p.id)) AS classe_media,
    FN_TOTAL_ALERTAS_ATIVOS(p.id)   AS alertas_ativos
FROM TB_PACIENTE_BONEGUARD p
ORDER BY FN_MEDIA_SCORE(p.id) DESC;

PROMPT === Functions criadas e testadas com sucesso ===
