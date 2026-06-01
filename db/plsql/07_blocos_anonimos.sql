-- =============================================================
-- BONEGUARD -- Blocos Anônimos PL/SQL
-- Oracle 19c+
-- =============================================================
-- Requisitos atendidos neste arquivo:
--   * 3 blocos anônimos com DECLARE, SELECT INTO, DBMS_OUTPUT
--   * 2 estruturas condicionais: IF/ELSIF/ELSE (Blocos 1 e 2)
--   * 2 estruturas de repetição: FOR LOOP (Bloco 1) e WHILE LOOP (Bloco 2 e 3)
--   * 1 CASE expression (Bloco 1)
-- =============================================================
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- =============================================================
-- BLOCO 1
-- Objetivo : Buscar avaliações com classificação ALTO e exibir
--            relatório detalhado com DBMS_OUTPUT
-- Estruturas: IF/ELSIF/ELSE + CASE + FOR LOOP (cursor)
-- =============================================================
DECLARE
    v_total      NUMBER       := 0;
    v_msg        VARCHAR2(200);
    v_urgencia   VARCHAR2(20);
    v_nome_pac   VARCHAR2(150);
    v_score_max  NUMBER;

    -- SELECT INTO: busca o maior score registrado no banco
    -- (realizado abaixo no BEGIN)

    CURSOR c_alto IS
        SELECT a.id            AS aval_id,
               p.nome,
               p.idade,
               a.score_risco,
               a.classificacao,
               a.data_avaliacao
        FROM   TB_AVALIACAO_BONEGUARD a
        JOIN   TB_PACIENTE_BONEGUARD  p ON p.id = a.paciente_id
        WHERE  a.classificacao = 'ALTO'
        ORDER  BY a.score_risco DESC;
BEGIN
    -- SELECT INTO: busca nome do paciente com maior score
    SELECT p.nome, MAX(a.score_risco)
    INTO   v_nome_pac, v_score_max
    FROM   TB_AVALIACAO_BONEGUARD a
    JOIN   TB_PACIENTE_BONEGUARD  p ON p.id = a.paciente_id
    WHERE  a.classificacao = 'ALTO'
    GROUP  BY p.nome
    ORDER  BY MAX(a.score_risco) DESC
    FETCH FIRST 1 ROW ONLY;

    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('  RELATÓRIO — PACIENTES COM RISCO ALTO ');
    DBMS_OUTPUT.PUT_LINE('  Maior score: ' || TO_CHAR(v_score_max,'990.00') ||
                         ' (' || v_nome_pac || ')');
    DBMS_OUTPUT.PUT_LINE('========================================');

    -- FOR LOOP: percorre cada avaliação com classificação ALTO
    FOR r IN c_alto LOOP
        v_total := v_total + 1;

        -- ESTRUTURA CONDICIONAL 1: IF/ELSIF/ELSE
        -- Classifica nível de urgência com base no score
        IF r.score_risco >= 90 THEN
            v_urgencia := 'CRÍTICO';
        ELSIF r.score_risco >= 80 THEN
            v_urgencia := 'URGENTE';
        ELSIF r.score_risco >= 70 THEN
            v_urgencia := 'ALTO';
        ELSE
            v_urgencia := 'MONITORAR';
        END IF;

        -- CASE expression: monta mensagem de ação
        v_msg := CASE
                     WHEN r.score_risco >= 90 THEN 'Internação preventiva. Contatar familiar imediatamente.'
                     WHEN r.score_risco >= 80 THEN 'Encaminhar para reumatologista com urgência.'
                     WHEN r.score_risco >= 70 THEN 'Agendar consulta especializada em até 7 dias.'
                     ELSE 'Acompanhar evolução mensalmente.'
                 END;

        DBMS_OUTPUT.PUT_LINE('---');
        DBMS_OUTPUT.PUT_LINE('Paciente  : ' || r.nome);
        DBMS_OUTPUT.PUT_LINE('Idade     : ' || r.idade || ' anos');
        DBMS_OUTPUT.PUT_LINE('Score     : ' || TO_CHAR(r.score_risco, '990.00'));
        DBMS_OUTPUT.PUT_LINE('Urgência  : ' || v_urgencia);
        DBMS_OUTPUT.PUT_LINE('Avaliação : ' || TO_CHAR(r.data_avaliacao, 'DD/MM/YYYY'));
        DBMS_OUTPUT.PUT_LINE('Ação      : ' || v_msg);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Total de avaliações ALTO: ' || v_total);
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

-- =============================================================
-- BLOCO 2
-- Objetivo : Calcular média de score de um paciente e exibir
--            análise de tendência de evolução
-- Estruturas: IF/ELSIF/ELSE + WHILE LOOP (coleta scores via cursor)
-- =============================================================
DECLARE
    v_paciente_id   NUMBER       := 1;   -- ajuste para outro paciente
    v_nome          VARCHAR2(150);
    v_media         NUMBER;
    v_total_aval    NUMBER;
    v_classificacao VARCHAR2(20);
    v_tendencia     VARCHAR2(60);
    v_score_primeiro NUMBER;
    v_score_ultimo   NUMBER;
    v_score_iter     NUMBER;
    v_contador       NUMBER := 0;

    -- Cursor para scores em ordem cronológica
    CURSOR c_scores IS
        SELECT score_risco
        FROM   TB_AVALIACAO_BONEGUARD
        WHERE  paciente_id = v_paciente_id
        ORDER  BY data_avaliacao ASC;
BEGIN
    -- SELECT INTO: busca nome do paciente
    SELECT nome INTO v_nome
    FROM   TB_PACIENTE_BONEGUARD
    WHERE  id = v_paciente_id;

    -- SELECT INTO: calcula média e total de avaliações
    SELECT AVG(score_risco), COUNT(*)
    INTO   v_media, v_total_aval
    FROM   TB_AVALIACAO_BONEGUARD
    WHERE  paciente_id = v_paciente_id;

    -- ESTRUTURA CONDICIONAL 2: IF/ELSIF/ELSE
    -- Classifica a média de score do paciente
    IF v_media IS NULL OR v_total_aval = 0 THEN
        v_classificacao := 'SEM AVALIAÇÕES';
    ELSIF v_media < 30 THEN
        v_classificacao := 'BAIXO RISCO';
    ELSIF v_media < 70 THEN
        v_classificacao := 'RISCO MODERADO';
    ELSE
        v_classificacao := 'ALTO RISCO';
    END IF;

    -- WHILE LOOP: percorre cursor de scores para capturar primeiro e último
    -- e contar total de avaliações iteradas
    OPEN c_scores;
    FETCH c_scores INTO v_score_iter;

    WHILE c_scores%FOUND LOOP
        v_contador := v_contador + 1;

        IF v_contador = 1 THEN
            v_score_primeiro := v_score_iter;   -- primeiro score (mais antigo)
        END IF;

        v_score_ultimo := v_score_iter;         -- sempre atualiza; ao fim terá o último

        FETCH c_scores INTO v_score_iter;
    END LOOP;   -- fim do WHILE LOOP

    CLOSE c_scores;

    -- Determina tendência comparando primeiro x último score
    IF v_contador >= 2 THEN
        IF v_score_ultimo > v_score_primeiro + 5 THEN
            v_tendencia := 'PIORANDO — score subiu ' ||
                           TO_CHAR(v_score_ultimo - v_score_primeiro, '990.0') || ' pontos';
        ELSIF v_score_ultimo < v_score_primeiro - 5 THEN
            v_tendencia := 'MELHORANDO — score caiu ' ||
                           TO_CHAR(v_score_primeiro - v_score_ultimo, '990.0') || ' pontos';
        ELSE
            v_tendencia := 'ESTÁVEL (variação < 5 pontos)';
        END IF;
    ELSE
        v_tendencia := 'Avaliação única — tendência indisponível';
    END IF;

    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('  ANÁLISE DE EVOLUÇÃO — ' || v_nome);
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Total de avaliações : ' || v_total_aval);
    DBMS_OUTPUT.PUT_LINE('Média de score      : ' || TO_CHAR(NVL(v_media, 0), '990.00'));
    DBMS_OUTPUT.PUT_LINE('Classificação média : ' || v_classificacao);
    DBMS_OUTPUT.PUT_LINE('Score mais antigo   : ' || TO_CHAR(NVL(v_score_primeiro, 0), '990.00'));
    DBMS_OUTPUT.PUT_LINE('Score mais recente  : ' || TO_CHAR(NVL(v_score_ultimo, 0), '990.00'));
    DBMS_OUTPUT.PUT_LINE('Tendência           : ' || v_tendencia);
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

-- =============================================================
-- BLOCO 3
-- Objetivo : Verificar plano de saúde ativo do paciente e
--            processar alertas PENDENTES em lote
-- Estruturas: IF/ELSIF/ELSE + WHILE LOOP (processa alertas pendentes)
-- =============================================================
DECLARE
    v_paciente_id   NUMBER       := 6;
    v_nome          VARCHAR2(150);
    v_qtd_planos    NUMBER       := 0;
    v_qtd_alertas   NUMBER       := 0;
    v_alerta_id     NUMBER;
    v_mensagem      VARCHAR2(500);
    v_ultima_aval   VARCHAR2(10);
    v_score_atual   NUMBER;
    v_classe_atual  VARCHAR2(10);

    CURSOR c_alertas_pendentes IS
        SELECT id, mensagem
        FROM   TB_ALERTA_BONEGUARD
        WHERE  paciente_id = v_paciente_id
          AND  status      = 'PENDENTE'
        ORDER  BY data_criacao ASC;
BEGIN
    -- SELECT INTO: dados do paciente
    SELECT nome INTO v_nome
    FROM   TB_PACIENTE_BONEGUARD
    WHERE  id = v_paciente_id;

    -- SELECT INTO: planos ativos
    SELECT COUNT(*)
    INTO   v_qtd_planos
    FROM   TB_PLANO_SAUDE_BONEGUARD ps
    JOIN   TB_AVALIACAO_BONEGUARD   av ON av.id = ps.avaliacao_id
    WHERE  av.paciente_id = v_paciente_id
      AND  ps.ativo       = 'S';

    -- SELECT INTO: última avaliação do paciente
    SELECT TO_CHAR(MAX(data_avaliacao),'DD/MM/YYYY'),
           MAX(score_risco),
           MAX(classificacao)
    INTO   v_ultima_aval, v_score_atual, v_classe_atual
    FROM   TB_AVALIACAO_BONEGUARD
    WHERE  paciente_id = v_paciente_id;

    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('  STATUS DO PACIENTE: ' || v_nome);
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Última avaliação: ' || NVL(v_ultima_aval,'N/A') ||
                         ' | Score: ' || TO_CHAR(NVL(v_score_atual,0),'990.00') ||
                         ' | Classe: ' || NVL(v_classe_atual,'N/A'));

    -- ESTRUTURA CONDICIONAL: IF/ELSIF/ELSE — status do plano
    IF v_qtd_planos > 1 THEN
        DBMS_OUTPUT.PUT_LINE('Planos ativos: ' || v_qtd_planos ||
                             ' planos — acompanhamento completo.');
    ELSIF v_qtd_planos = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Planos ativos: 1 plano — acompanhamento parcial.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Planos ativos: NENHUM — gerar plano urgente!');
    END IF;

    -- WHILE LOOP: processa TODOS os alertas PENDENTES do paciente
    DBMS_OUTPUT.PUT_LINE('--- Processando Alertas Pendentes ---');
    OPEN c_alertas_pendentes;
    FETCH c_alertas_pendentes INTO v_alerta_id, v_mensagem;

    WHILE c_alertas_pendentes%FOUND LOOP
        v_qtd_alertas := v_qtd_alertas + 1;

        -- Atualiza status do alerta para ENVIADO
        UPDATE TB_ALERTA_BONEGUARD
        SET    status = 'ENVIADO'
        WHERE  id     = v_alerta_id;

        DBMS_OUTPUT.PUT_LINE('[' || v_qtd_alertas || '] Alerta #' || v_alerta_id ||
                             ' marcado ENVIADO: ' ||
                             SUBSTR(v_mensagem, 1, 70) || '...');

        FETCH c_alertas_pendentes INTO v_alerta_id, v_mensagem;
    END LOOP;   -- fim do WHILE LOOP

    CLOSE c_alertas_pendentes;

    IF v_qtd_alertas = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum alerta pendente encontrado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE(v_qtd_alertas || ' alerta(s) processados com sucesso.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('========================================');
    COMMIT;
END;
/

PROMPT === Blocos Anônimos executados com sucesso ===
