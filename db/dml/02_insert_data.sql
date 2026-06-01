-- =============================================================
-- BONEGUARD -- DML -- Inserção de Dados
-- Mínimo 80 registros distribuídos entre as tabelas
-- Oracle 19c+
-- =============================================================

-- Desabilita triggers de auditoria durante carga inicial (opcional)
-- ALTER TABLE TB_AVALIACAO_BONEGUARD DISABLE ALL TRIGGERS;

-- =============================================================
-- TB_PACIENTE_BONEGUARD (20 pacientes)
-- =============================================================
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('ANA PAULA FERREIRA',       45, 'F', 62.5, 'S', 'SEDENTARIO', 'N', DATE '2025-01-10');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('CARLOS EDUARDO LIMA',      58, 'M', 85.0, 'N', 'MODERADO',   'S', DATE '2025-01-15');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('MARIA JOSE SANTOS',        67, 'F', 55.3, 'S', 'SEDENTARIO', 'N', DATE '2025-02-03');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('ROBERTO ALVES COSTA',      72, 'M', 78.2, 'S', 'SEDENTARIO', 'N', DATE '2025-02-08');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('FERNANDA OLIVEIRA MELO',   38, 'F', 59.0, 'N', 'ATIVO',      'S', DATE '2025-02-20');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('JOSE ANTONIO BARBOSA',     63, 'M', 90.5, 'S', 'SEDENTARIO', 'N', DATE '2025-03-01');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('LUCIA APARECIDA GOMES',    55, 'F', 68.7, 'N', 'MODERADO',   'S', DATE '2025-03-10');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('MARCOS VINICIUS PEREIRA',  41, 'M', 74.0, 'N', 'ATIVO',      'S', DATE '2025-03-15');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('PATRICIA SOUZA NUNES',     50, 'F', 66.2, 'S', 'MODERADO',   'N', DATE '2025-03-22');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('ANTONIO RODRIGUES SILVA',  78, 'M', 69.8, 'S', 'SEDENTARIO', 'N', DATE '2025-04-02');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('CAMILA MARTINS TEIXEIRA',  33, 'F', 57.5, 'N', 'ATIVO',      'S', DATE '2025-04-10');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('PAULO HENRIQUE ARAÚJO',    60, 'M', 82.3, 'S', 'MODERADO',   'N', DATE '2025-04-18');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('SANDRA CRISTINA VIEIRA',   48, 'F', 71.0, 'S', 'SEDENTARIO', 'S', DATE '2025-04-25');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('DIEGO FERNANDEZ ROCHA',    29, 'M', 77.5, 'N', 'ATIVO',      'S', DATE '2025-05-05');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('REGINA CLAUDIA MENDES',    70, 'F', 52.0, 'S', 'SEDENTARIO', 'N', DATE '2025-05-12');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('FABIO LUIS CARVALHO',      44, 'M', 88.0, 'N', 'MODERADO',   'S', DATE '2025-05-20');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('VERONICA SOUSA PINTO',     56, 'F', 64.3, 'S', 'SEDENTARIO', 'N', DATE '2025-06-01');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('LEANDRO BATISTA MOURA',    35, 'M', 79.5, 'N', 'ATIVO',      'S', DATE '2025-06-08');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('ELIANE PATRICIA CORREIA',  62, 'F', 58.8, 'S', 'SEDENTARIO', 'N', DATE '2025-06-15');
INSERT INTO TB_PACIENTE_BONEGUARD (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro)
VALUES ('GUSTAVO HENRIQUE FREITAS', 53, 'M', 93.2, 'S', 'MODERADO',   'N', DATE '2025-06-22');

-- =============================================================
-- TB_AVALIACAO_BONEGUARD (20 avaliações)
-- =============================================================
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (1,  78.5, 'ALTO',     DATE '2025-02-01', 'S');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (2,  35.0, 'MODERADO', DATE '2025-02-10', 'S');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (3,  85.2, 'ALTO',     DATE '2025-02-15', 'S');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (4,  91.0, 'ALTO',     DATE '2025-02-20', 'S');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (5,  18.0, 'BAIXO',    DATE '2025-03-05', 'N');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (6,  72.3, 'ALTO',     DATE '2025-03-10', 'S');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (7,  42.7, 'MODERADO', DATE '2025-03-20', 'S');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (8,  22.5, 'BAIXO',    DATE '2025-04-01', 'N');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (9,  55.0, 'MODERADO', DATE '2025-04-05', 'S');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (10, 88.8, 'ALTO',     DATE '2025-04-10', 'S');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (11, 12.0, 'BAIXO',    DATE '2025-04-15', 'N');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (12, 63.5, 'MODERADO', DATE '2025-04-20', 'S');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (13, 76.9, 'ALTO',     DATE '2025-05-01', 'S');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (14, 8.5,  'BAIXO',    DATE '2025-05-06', 'N');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (15, 95.0, 'ALTO',     DATE '2025-05-10', 'S');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (16, 48.2, 'MODERADO', DATE '2025-05-15', 'S');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (17, 81.0, 'ALTO',     DATE '2025-05-20', 'S');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (18, 25.3, 'BAIXO',    DATE '2025-05-25', 'N');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (19, 70.0, 'ALTO',     DATE '2025-06-01', 'S');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (20, 58.5, 'MODERADO', DATE '2025-06-05', 'S');

-- Reavaliações (paciente 1, 3, 10 - acompanhamento)
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (1,  70.0, 'ALTO',     DATE '2025-05-01', 'S');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (3,  80.5, 'ALTO',     DATE '2025-05-15', 'S');
INSERT INTO TB_AVALIACAO_BONEGUARD (paciente_id, score_risco, classificacao, data_avaliacao, plano_gerado)
VALUES (10, 82.0, 'ALTO',     DATE '2026-05-20', 'S');

-- =============================================================
-- TB_RADIOGRAFIA_BONEGUARD (15 registros)
-- =============================================================
INSERT INTO TB_RADIOGRAFIA_BONEGUARD (avaliacao_id, resultado_ia, confianca, data_analise)
VALUES (1,  'OSTEOPOROSE', 0.921, DATE '2025-02-01');
INSERT INTO TB_RADIOGRAFIA_BONEGUARD (avaliacao_id, resultado_ia, confianca, data_analise)
VALUES (2,  'OSTEOPENIA',  0.873, DATE '2025-02-10');
INSERT INTO TB_RADIOGRAFIA_BONEGUARD (avaliacao_id, resultado_ia, confianca, data_analise)
VALUES (3,  'OSTEOPOROSE', 0.956, DATE '2025-02-15');
INSERT INTO TB_RADIOGRAFIA_BONEGUARD (avaliacao_id, resultado_ia, confianca, data_analise)
VALUES (4,  'OSTEOPOROSE', 0.988, DATE '2025-02-20');
INSERT INTO TB_RADIOGRAFIA_BONEGUARD (avaliacao_id, resultado_ia, confianca, data_analise)
VALUES (5,  'NORMAL',      0.945, DATE '2025-03-05');
INSERT INTO TB_RADIOGRAFIA_BONEGUARD (avaliacao_id, resultado_ia, confianca, data_analise)
VALUES (6,  'OSTEOPOROSE', 0.912, DATE '2025-03-10');
INSERT INTO TB_RADIOGRAFIA_BONEGUARD (avaliacao_id, resultado_ia, confianca, data_analise)
VALUES (7,  'OSTEOPENIA',  0.841, DATE '2025-03-20');
INSERT INTO TB_RADIOGRAFIA_BONEGUARD (avaliacao_id, resultado_ia, confianca, data_analise)
VALUES (8,  'NORMAL',      0.967, DATE '2025-04-01');
INSERT INTO TB_RADIOGRAFIA_BONEGUARD (avaliacao_id, resultado_ia, confianca, data_analise)
VALUES (9,  'OSTEOPENIA',  0.889, DATE '2025-04-05');
INSERT INTO TB_RADIOGRAFIA_BONEGUARD (avaliacao_id, resultado_ia, confianca, data_analise)
VALUES (10, 'OSTEOPOROSE', 0.976, DATE '2025-04-10');
INSERT INTO TB_RADIOGRAFIA_BONEGUARD (avaliacao_id, resultado_ia, confianca, data_analise)
VALUES (11, 'NORMAL',      0.993, DATE '2025-04-15');
INSERT INTO TB_RADIOGRAFIA_BONEGUARD (avaliacao_id, resultado_ia, confianca, data_analise)
VALUES (13, 'OSTEOPOROSE', 0.934, DATE '2025-05-01');
INSERT INTO TB_RADIOGRAFIA_BONEGUARD (avaliacao_id, resultado_ia, confianca, data_analise)
VALUES (15, 'OSTEOPOROSE', 0.997, DATE '2025-05-10');
INSERT INTO TB_RADIOGRAFIA_BONEGUARD (avaliacao_id, resultado_ia, confianca, data_analise)
VALUES (17, 'OSTEOPOROSE', 0.903, DATE '2025-05-20');
INSERT INTO TB_RADIOGRAFIA_BONEGUARD (avaliacao_id, resultado_ia, confianca, data_analise)
VALUES (19, 'OSTEOPOROSE', 0.918, DATE '2025-06-01');

-- =============================================================
-- TB_PLANO_SAUDE_BONEGUARD (15 registros)
-- =============================================================
INSERT INTO TB_PLANO_SAUDE_BONEGUARD (avaliacao_id, categoria, descricao, ativo, data_criacao)
VALUES (1, 'EXERCICIO', 'Protocolo NASA de resistência óssea: 30min caminhada acelerada 5x/sem, musculação com peso moderado 3x/sem, exercícios de equilíbrio diários.', 'S', DATE '2025-02-02');
INSERT INTO TB_PLANO_SAUDE_BONEGUARD (avaliacao_id, categoria, descricao, ativo, data_criacao)
VALUES (1, 'NUTRICAO',  'Ingestão de 1.200mg cálcio/dia (leite, queijo, sardinha), vitamina D3 2.000UI/dia, proteína 1.2g/kg/dia, redução de cafeína e álcool.', 'S', DATE '2025-02-02');
INSERT INTO TB_PLANO_SAUDE_BONEGUARD (avaliacao_id, categoria, descricao, ativo, data_criacao)
VALUES (2, 'EXERCICIO', 'Caminhada 20min 3x/sem, natação 2x/sem para fortalecimento sem impacto.', 'S', DATE '2025-02-11');
INSERT INTO TB_PLANO_SAUDE_BONEGUARD (avaliacao_id, categoria, descricao, ativo, data_criacao)
VALUES (3, 'EXERCICIO', 'Protocolo intensivo: exercícios de carga diários, fisioterapia 2x/sem, hidroginástica 3x/sem.', 'S', DATE '2025-02-16');
INSERT INTO TB_PLANO_SAUDE_BONEGUARD (avaliacao_id, categoria, descricao, ativo, data_criacao)
VALUES (3, 'NUTRICAO',  'Suplementação de cálcio 1.500mg/dia, vitamina K2 200mcg, magnésio 400mg. Dieta rica em leguminosas e vegetais verdes escuros.', 'S', DATE '2025-02-16');
INSERT INTO TB_PLANO_SAUDE_BONEGUARD (avaliacao_id, categoria, descricao, ativo, data_criacao)
VALUES (4, 'EXERCICIO', 'Programa especial geriátrico: exercícios sentados, uso de faixa elástica, equilíbrio com apoio. Supervisão fisioterapeuta.', 'S', DATE '2025-02-21');
INSERT INTO TB_PLANO_SAUDE_BONEGUARD (avaliacao_id, categoria, descricao, ativo, data_criacao)
VALUES (4, 'NUTRICAO',  'Dieta hipercalcêmica supervisionada: 1.500mg cálcio/dia, proteína animal 1.5g/kg, suplemento de colágeno tipo II.', 'S', DATE '2025-02-21');
INSERT INTO TB_PLANO_SAUDE_BONEGUARD (avaliacao_id, categoria, descricao, ativo, data_criacao)
VALUES (6, 'EXERCICIO', 'Treino funcional 4x/sem com ênfase em membros inferiores. Pilates 2x/sem. Evitar sedentarismo prolongado.', 'S', DATE '2025-03-11');
INSERT INTO TB_PLANO_SAUDE_BONEGUARD (avaliacao_id, categoria, descricao, ativo, data_criacao)
VALUES (7, 'NUTRICAO',  'Aumentar consumo de laticínios e oleaginosas. Meta 1.000mg cálcio/dia através de alimentação natural.', 'S', DATE '2025-03-21');
INSERT INTO TB_PLANO_SAUDE_BONEGUARD (avaliacao_id, categoria, descricao, ativo, data_criacao)
VALUES (9, 'EXERCICIO', 'Yoga e pilates 3x/sem, caminhada matinal 15min diária.', 'S', DATE '2025-04-06');
INSERT INTO TB_PLANO_SAUDE_BONEGUARD (avaliacao_id, categoria, descricao, ativo, data_criacao)
VALUES (10,'EXERCICIO',  'Programa emergencial: fisioterapia diária, exercícios isométricos, prevenção de quedas prioritária.', 'S', DATE '2025-04-11');
INSERT INTO TB_PLANO_SAUDE_BONEGUARD (avaliacao_id, categoria, descricao, ativo, data_criacao)
VALUES (10,'NUTRICAO',   'Suplementação máxima supervisionada. Consulta endocrinologista para avaliação de bifosfonatos.', 'S', DATE '2025-04-11');
INSERT INTO TB_PLANO_SAUDE_BONEGUARD (avaliacao_id, categoria, descricao, ativo, data_criacao)
VALUES (12,'NUTRICAO',   'Adicionar 2 porções de laticínios/dia, ovo caipira diário (vitamina D natural), exposição solar 20min/dia.', 'S', DATE '2025-04-21');
INSERT INTO TB_PLANO_SAUDE_BONEGUARD (avaliacao_id, categoria, descricao, ativo, data_criacao)
VALUES (15,'EXERCICIO',  'Protocolo crítico NASA adaptado: movimentos de resistência gravitacional 2x/dia, fisioterapia 5x/sem.', 'S', DATE '2025-05-11');
INSERT INTO TB_PLANO_SAUDE_BONEGUARD (avaliacao_id, categoria, descricao, ativo, data_criacao)
VALUES (17,'NUTRICAO',   'Dieta mediterrânea adaptada com foco em cálcio e vitamina D. Evitar dieta cetogênica.', 'N', DATE '2025-05-21');

-- =============================================================
-- TB_EVOLUCAO_BONEGUARD (10 registros)
-- =============================================================
INSERT INTO TB_EVOLUCAO_BONEGUARD (paciente_id, peso_atual, nivel_atividade_atual, observacoes, data_registro)
VALUES (1,  61.0, 'MODERADO',   'Iniciou programa de caminhada. Relata melhora no sono.', DATE '2025-04-01');
INSERT INTO TB_EVOLUCAO_BONEGUARD (paciente_id, peso_atual, nivel_atividade_atual, observacoes, data_registro)
VALUES (3,  54.5, 'SEDENTARIO', 'Dificuldade de mobilidade. Encaminhada para fisioterapia.', DATE '2025-04-15');
INSERT INTO TB_EVOLUCAO_BONEGUARD (paciente_id, peso_atual, nivel_atividade_atual, observacoes, data_registro)
VALUES (4,  77.8, 'SEDENTARIO', 'Queda leve sem fratura. Avaliação domiciliar realizada.', DATE '2025-04-20');
INSERT INTO TB_EVOLUCAO_BONEGUARD (paciente_id, peso_atual, nivel_atividade_atual, observacoes, data_registro)
VALUES (6,  89.0, 'MODERADO',   'Aderiu ao plano de exercícios. Redução de 1.5kg no mês.', DATE '2025-05-01');
INSERT INTO TB_EVOLUCAO_BONEGUARD (paciente_id, peso_atual, nivel_atividade_atual, observacoes, data_registro)
VALUES (10, 68.5, 'SEDENTARIO', 'Paciente relatou dores nas costas. Reavaliação agendada.', DATE '2025-05-10');
INSERT INTO TB_EVOLUCAO_BONEGUARD (paciente_id, peso_atual, nivel_atividade_atual, observacoes, data_registro)
VALUES (13, 70.5, 'MODERADO',   'Melhora significativa após inicio do plano de fisioterapia.', DATE '2025-06-01');
INSERT INTO TB_EVOLUCAO_BONEGUARD (paciente_id, peso_atual, nivel_atividade_atual, observacoes, data_registro)
VALUES (15, 51.0, 'SEDENTARIO', 'Paciente com mobilidade muito reduzida. Cadeirante parcial.', DATE '2025-06-05');
INSERT INTO TB_EVOLUCAO_BONEGUARD (paciente_id, peso_atual, nivel_atividade_atual, observacoes, data_registro)
VALUES (17, 63.5, 'MODERADO',   'Adherência ao plano nutricional em 80%. Progresso satisfatório.', DATE '2025-06-10');
INSERT INTO TB_EVOLUCAO_BONEGUARD (paciente_id, peso_atual, nivel_atividade_atual, observacoes, data_registro)
VALUES (1,  60.2, 'ATIVO',      'Excelente evolução. Score de risco reduziu nas últimas avaliações.', DATE '2025-06-20');
INSERT INTO TB_EVOLUCAO_BONEGUARD (paciente_id, peso_atual, nivel_atividade_atual, observacoes, data_registro)
VALUES (19, 79.0, 'MODERADO',   'Mantém rotina de exercícios. Vitamina D normalizada.', DATE '2025-06-25');

-- =============================================================
-- TB_ALERTA_BONEGUARD (12 registros)
-- =============================================================
INSERT INTO TB_ALERTA_BONEGUARD (paciente_id, avaliacao_id, mensagem, status, data_criacao)
VALUES (1,  1,  'ALERTA ALTO RISCO: Ana Paula Ferreira apresenta score 78.5. Consulta médica urgente recomendada.', 'LIDO',    DATE '2025-02-01');
INSERT INTO TB_ALERTA_BONEGUARD (paciente_id, avaliacao_id, mensagem, status, data_criacao)
VALUES (3,  3,  'ALERTA ALTO RISCO: Maria Jose Santos apresenta score 85.2. Encaminhar para reumatologista.', 'LIDO',    DATE '2025-02-15');
INSERT INTO TB_ALERTA_BONEGUARD (paciente_id, avaliacao_id, mensagem, status, data_criacao)
VALUES (4,  4,  'ALERTA ALTO RISCO: Roberto Alves Costa, 72 anos, score 91.0. Risco de fratura elevado.', 'ENVIADO', DATE '2025-02-20');
INSERT INTO TB_ALERTA_BONEGUARD (paciente_id, avaliacao_id, mensagem, status, data_criacao)
VALUES (6,  6,  'ALERTA ALTO RISCO: Jose Antonio Barbosa score 72.3. Iniciar protocolo urgente.', 'PENDENTE', DATE '2025-03-10');
INSERT INTO TB_ALERTA_BONEGUARD (paciente_id, avaliacao_id, mensagem, status, data_criacao)
VALUES (10, 10, 'ALERTA ALTO RISCO: Antonio Rodrigues Silva, 78 anos, score 88.8. Supervisão constante necessária.', 'PENDENTE', DATE '2025-04-10');
INSERT INTO TB_ALERTA_BONEGUARD (paciente_id, avaliacao_id, mensagem, status, data_criacao)
VALUES (13, 13, 'ALERTA ALTO RISCO: Sandra Cristina Vieira score 76.9. Plano de saúde gerado automaticamente.', 'ENVIADO', DATE '2025-05-01');
INSERT INTO TB_ALERTA_BONEGUARD (paciente_id, avaliacao_id, mensagem, status, data_criacao)
VALUES (15, 15, 'ALERTA CRÍTICO: Regina Claudia Mendes score 95.0. Internação preventiva sugerida ao médico.', 'PENDENTE', DATE '2025-05-10');
INSERT INTO TB_ALERTA_BONEGUARD (paciente_id, avaliacao_id, mensagem, status, data_criacao)
VALUES (17, 17, 'ALERTA ALTO RISCO: Eliane Patricia Correia score 81.0. Fisioterapia emergencial agendada.', 'ENVIADO', DATE '2025-05-20');
INSERT INTO TB_ALERTA_BONEGUARD (paciente_id, avaliacao_id, mensagem, status, data_criacao)
VALUES (19, 19, 'ALERTA ALTO RISCO: Leandro Batista Moura score 70.0. Monitoramento intensivo iniciado.', 'PENDENTE', DATE '2025-06-01');
INSERT INTO TB_ALERTA_BONEGUARD (paciente_id, avaliacao_id, mensagem, status, data_criacao)
VALUES (1,  21, 'ALERTA ALTO RISCO: Ana Paula Ferreira score 70.0 na reavaliação. Manter protocolo intensivo.', 'LIDO',    DATE '2025-05-01');
INSERT INTO TB_ALERTA_BONEGUARD (paciente_id, avaliacao_id, mensagem, status, data_criacao)
VALUES (3,  22, 'ALERTA ALTO RISCO: Maria Jose Santos score 80.5 na reavaliação. Sem melhora significativa.', 'ENVIADO', DATE '2025-05-15');
INSERT INTO TB_ALERTA_BONEGUARD (paciente_id, avaliacao_id, mensagem, status, data_criacao)
VALUES (10, 23, 'ALERTA ALTO RISCO: Antonio Rodrigues Silva score 82.0. Risco agravado. Contato com familiar.', 'PENDENTE', DATE '2026-05-20');

COMMIT;

PROMPT === DML concluído: 20 pacientes, 23 avaliações, 15 radiografias, 15 planos, 10 evoluções, 12 alertas ===
