-- =============================================================
-- BONEGUARD -- Relatórios SQL com JOIN
-- Oracle 19c+
-- =============================================================

-- =============================================================
-- RELATÓRIO 1: Pacientes com risco ALTO e seus alertas ativos
-- =============================================================
PROMPT
PROMPT === RELATÓRIO 1: Pacientes com Risco ALTO e Alertas Ativos ===
PROMPT

SELECT
    p.id                                        AS paciente_id,
    p.nome,
    p.idade,
    p.sexo,
    a.id                                        AS avaliacao_id,
    TO_CHAR(a.score_risco, '990.00')            AS score_risco,
    a.classificacao,
    TO_CHAR(a.data_avaliacao, 'DD/MM/YYYY')     AS data_avaliacao,
    al.id                                       AS alerta_id,
    al.status                                   AS status_alerta,
    TO_CHAR(al.data_criacao, 'DD/MM/YYYY')      AS data_alerta,
    SUBSTR(al.mensagem, 1, 80) || '...'         AS mensagem_resumida
FROM   TB_PACIENTE_BONEGUARD   p
JOIN   TB_AVALIACAO_BONEGUARD  a  ON a.paciente_id  = p.id
JOIN   TB_ALERTA_BONEGUARD     al ON al.paciente_id = p.id
                       AND al.avaliacao_id = a.id
WHERE  a.classificacao = 'ALTO'
  AND  al.status IN ('PENDENTE','ENVIADO')
ORDER  BY a.score_risco DESC, al.data_criacao DESC;

-- =============================================================
-- RELATÓRIO 2: Histórico completo de avaliações por paciente
--             com radiografia
-- =============================================================
PROMPT
PROMPT === RELATÓRIO 2: Histórico Completo de Avaliações com Radiografia ===
PROMPT

SELECT
    p.id                                        AS paciente_id,
    p.nome,
    p.idade,
    p.sexo,
    p.historico_familiar                        AS hist_familiar,
    p.nivel_atividade,
    a.id                                        AS avaliacao_id,
    TO_CHAR(a.score_risco, '990.00')            AS score,
    a.classificacao,
    TO_CHAR(a.data_avaliacao, 'DD/MM/YYYY')     AS data_aval,
    a.plano_gerado,
    NVL(r.resultado_ia, 'SEM RAIO-X')          AS resultado_ia,
    TO_CHAR(NVL(r.confianca, 0) * 100, '990.0') || '%' AS confianca,
    TO_CHAR(r.data_analise, 'DD/MM/YYYY')       AS data_analise
FROM   TB_PACIENTE_BONEGUARD    p
JOIN   TB_AVALIACAO_BONEGUARD   a ON a.paciente_id  = p.id
LEFT JOIN TB_RADIOGRAFIA_BONEGUARD r ON r.avaliacao_id = a.id
ORDER  BY p.nome, a.data_avaliacao DESC;

-- =============================================================
-- RELATÓRIO 3: Pacientes sem plano de saúde ativo
-- =============================================================
PROMPT
PROMPT === RELATÓRIO 3: Pacientes sem Plano de Saúde Ativo ===
PROMPT

SELECT
    p.id,
    p.nome,
    p.idade,
    p.sexo,
    p.nivel_atividade,
    COUNT(a.id)                                 AS total_avaliacoes,
    MAX(a.score_risco)                          AS score_maximo,
    MAX(a.classificacao)                        AS pior_classificacao,
    TO_CHAR(MAX(a.data_avaliacao), 'DD/MM/YYYY') AS ultima_avaliacao
FROM   TB_PACIENTE_BONEGUARD  p
JOIN   TB_AVALIACAO_BONEGUARD a ON a.paciente_id = p.id
WHERE  NOT EXISTS (
    SELECT 1
    FROM   TB_PLANO_SAUDE_BONEGUARD ps
    JOIN   TB_AVALIACAO_BONEGUARD   av ON av.id = ps.avaliacao_id
    WHERE  av.paciente_id = p.id
      AND  ps.ativo       = 'S'
)
GROUP BY p.id, p.nome, p.idade, p.sexo, p.nivel_atividade
ORDER BY MAX(a.score_risco) DESC;

-- =============================================================
-- RELATÓRIO 4: Ranking de pacientes por score médio de risco
-- =============================================================
PROMPT
PROMPT === RELATÓRIO 4: Ranking de Pacientes por Score Médio ===
PROMPT

SELECT
    RANK() OVER (ORDER BY AVG(a.score_risco) DESC)  AS ranking,
    p.id,
    p.nome,
    p.idade,
    p.sexo,
    p.historico_familiar,
    p.nivel_atividade,
    COUNT(a.id)                                     AS qtd_avaliacoes,
    TO_CHAR(AVG(a.score_risco), '990.00')           AS media_score,
    TO_CHAR(MIN(a.score_risco), '990.00')           AS score_minimo,
    TO_CHAR(MAX(a.score_risco), '990.00')           AS score_maximo,
    FN_CLASSIFICAR_RISCO(AVG(a.score_risco))        AS classificacao_media,
    FN_TOTAL_ALERTAS_ATIVOS(p.id)                   AS alertas_ativos
FROM   TB_PACIENTE_BONEGUARD  p
JOIN   TB_AVALIACAO_BONEGUARD a ON a.paciente_id = p.id
GROUP  BY p.id, p.nome, p.idade, p.sexo, p.historico_familiar, p.nivel_atividade
ORDER  BY AVG(a.score_risco) DESC;

-- =============================================================
-- RELATÓRIO 5: Avaliações com radiografia + resultado IA + confiança
-- =============================================================
PROMPT
PROMPT === RELATÓRIO 5: Avaliações com Radiografia Vinculada ===
PROMPT

SELECT
    p.nome,
    p.idade,
    p.sexo,
    a.id                                        AS avaliacao_id,
    TO_CHAR(a.score_risco, '990.00')            AS score_risco,
    a.classificacao,
    TO_CHAR(a.data_avaliacao, 'DD/MM/YYYY')     AS data_avaliacao,
    r.id                                        AS radiografia_id,
    r.resultado_ia,
    TO_CHAR(r.confianca * 100, '990.0') || '%' AS confianca_ia,
    TO_CHAR(r.data_analise, 'DD/MM/YYYY')       AS data_analise,
    CASE
        WHEN r.confianca >= 0.95 THEN 'ALTA CONFIANÇA'
        WHEN r.confianca >= 0.85 THEN 'CONFIANÇA MODERADA'
        ELSE 'BAIXA CONFIANÇA - REVISAR'
    END                                         AS nivel_confianca,
    CASE
        WHEN a.classificacao = 'ALTO'     AND r.resultado_ia = 'OSTEOPOROSE' THEN 'RISCO CONFIRMADO'
        WHEN a.classificacao = 'MODERADO' AND r.resultado_ia = 'OSTEOPENIA'  THEN 'MONITORAR'
        WHEN a.classificacao = 'BAIXO'    AND r.resultado_ia = 'NORMAL'      THEN 'SAUDÁVEL'
        ELSE 'DIVERGÊNCIA — AVALIAR MANUALMENTE'
    END                                         AS correlacao_score_ia
FROM   TB_PACIENTE_BONEGUARD    p
JOIN   TB_AVALIACAO_BONEGUARD   a ON a.paciente_id  = p.id
JOIN   TB_RADIOGRAFIA_BONEGUARD r ON r.avaliacao_id = a.id
ORDER  BY r.confianca DESC, a.score_risco DESC;

PROMPT
PROMPT === Todos os relatórios executados com sucesso ===
