-- =============================================================
-- BONEGUARD -- Cursores Explícitos
-- Oracle 19c+
-- =============================================================
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- =============================================================
-- CURSOR 1: Avaliações da última semana por paciente
-- =============================================================
DECLARE
    -- Cursor parametrizado para avaliações recentes
    CURSOR c_aval_recente (p_dias NUMBER := 7) IS
        SELECT
            p.id            AS paciente_id,
            p.nome,
            p.idade,
            a.id            AS avaliacao_id,
            a.score_risco,
            a.classificacao,
            a.data_avaliacao,
            r.resultado_ia,
            r.confianca
        FROM   TB_AVALIACAO_BONEGUARD  a
        JOIN   TB_PACIENTE_BONEGUARD   p ON p.id = a.paciente_id
        LEFT JOIN TB_RADIOGRAFIA_BONEGUARD r ON r.avaliacao_id = a.id
        WHERE  a.data_avaliacao >= SYSDATE - p_dias
        ORDER  BY a.data_avaliacao DESC, p.nome;

    -- Variáveis de trabalho
    v_rec           c_aval_recente%ROWTYPE;
    v_total         NUMBER := 0;
    v_alto_count    NUMBER := 0;

BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('  AVALIAÇÕES DOS ÚLTIMOS 7 DIAS           ');
    DBMS_OUTPUT.PUT_LINE('==========================================');

    OPEN c_aval_recente(7);

    LOOP
        FETCH c_aval_recente INTO v_rec;
        EXIT WHEN c_aval_recente%NOTFOUND;

        v_total := v_total + 1;

        IF v_rec.classificacao = 'ALTO' THEN
            v_alto_count := v_alto_count + 1;
        END IF;

        DBMS_OUTPUT.PUT_LINE('Paciente  : ' || v_rec.nome || ' (' || v_rec.idade || ' anos)');
        DBMS_OUTPUT.PUT_LINE('Avaliação : #' || v_rec.avaliacao_id ||
                             ' | Score: ' || TO_CHAR(v_rec.score_risco,'990.00') ||
                             ' | Classe: ' || v_rec.classificacao);
        DBMS_OUTPUT.PUT_LINE('Data      : ' || TO_CHAR(v_rec.data_avaliacao,'DD/MM/YYYY'));

        IF v_rec.resultado_ia IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('Raio-X IA : ' || v_rec.resultado_ia ||
                                 ' (confiança: ' || TO_CHAR(v_rec.confianca * 100,'990.0') || '%)');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Raio-X IA : Sem radiografia vinculada');
        END IF;
        DBMS_OUTPUT.PUT_LINE('---');
    END LOOP;

    CLOSE c_aval_recente;

    IF v_total = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nenhuma avaliação realizada nos últimos 7 dias.');
        DBMS_OUTPUT.PUT_LINE('(Dica: ajuste p_dias no cursor ou verifique os dados de carga)');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Total de avaliações: ' || v_total);
        DBMS_OUTPUT.PUT_LINE('Com classificação ALTO: ' || v_alto_count);
    END IF;

    DBMS_OUTPUT.PUT_LINE('==========================================');
END;
/

-- =============================================================
-- CURSOR 2: Pacientes sem plano de saúde ativo
-- =============================================================
DECLARE
    CURSOR c_sem_plano IS
        SELECT
            p.id,
            p.nome,
            p.idade,
            p.sexo,
            p.nivel_atividade,
            a.score_risco,
            a.classificacao,
            a.data_avaliacao
        FROM   TB_PACIENTE_BONEGUARD p
        JOIN   TB_AVALIACAO_BONEGUARD a ON a.paciente_id = p.id
        WHERE  NOT EXISTS (
            SELECT 1
            FROM   TB_PLANO_SAUDE_BONEGUARD ps
            JOIN   TB_AVALIACAO_BONEGUARD   av2 ON av2.id = ps.avaliacao_id
            WHERE  av2.paciente_id = p.id
              AND  ps.ativo        = 'S'
        )
        -- Pega a avaliação mais recente de cada paciente
        AND a.data_avaliacao = (
            SELECT MAX(a2.data_avaliacao)
            FROM   TB_AVALIACAO_BONEGUARD a2
            WHERE  a2.paciente_id = p.id
        )
        ORDER BY a.score_risco DESC;

    v_pac       c_sem_plano%ROWTYPE;
    v_total     NUMBER  := 0;
    v_urgente   NUMBER  := 0;
    v_prioridade VARCHAR2(20);

BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('  PACIENTES SEM PLANO DE SAÚDE ATIVO      ');
    DBMS_OUTPUT.PUT_LINE('==========================================');

    OPEN c_sem_plano;

    LOOP
        FETCH c_sem_plano INTO v_pac;
        EXIT WHEN c_sem_plano%NOTFOUND;

        v_total := v_total + 1;

        -- Define prioridade para gerar o plano
        CASE v_pac.classificacao
            WHEN 'ALTO'     THEN v_prioridade := '*** URGENTE ***';
            WHEN 'MODERADO' THEN v_prioridade := '* IMPORTANTE';
            ELSE                 v_prioridade := 'ROTINA';
        END CASE;

        IF v_pac.classificacao = 'ALTO' THEN
            v_urgente := v_urgente + 1;
        END IF;

        DBMS_OUTPUT.PUT_LINE(LPAD(v_total, 2, '0') || '. ' || v_pac.nome);
        DBMS_OUTPUT.PUT_LINE('    Idade      : ' || v_pac.idade || ' | Sexo: ' || v_pac.sexo ||
                             ' | Atividade: ' || v_pac.nivel_atividade);
        DBMS_OUTPUT.PUT_LINE('    Último score: ' || TO_CHAR(v_pac.score_risco,'990.00') ||
                             ' (' || v_pac.classificacao || ')');
        DBMS_OUTPUT.PUT_LINE('    Avaliação  : ' || TO_CHAR(v_pac.data_avaliacao,'DD/MM/YYYY'));
        DBMS_OUTPUT.PUT_LINE('    Prioridade : ' || v_prioridade);
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;

    CLOSE c_sem_plano;

    IF v_total = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Todos os pacientes com avaliação possuem plano ativo!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Total sem plano: ' || v_total);
        DBMS_OUTPUT.PUT_LINE('Casos urgentes (ALTO): ' || v_urgente);
        DBMS_OUTPUT.PUT_LINE('Ação recomendada: Executar SP_GERAR_PLANO_SAUDE para cada um.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('==========================================');
END;
/

PROMPT === Cursores executados com sucesso ===
