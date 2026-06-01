-- =============================================================
-- BONEGUARD -- Seed de dados iniciais
-- Senhas BCrypt (strength 10):
--   admin@boneguard.com    → admin123
--   paciente@boneguard.com → user123
-- Idempotente: não insere se o e-mail já existir
-- =============================================================

INSERT INTO TB_PACIENTE_BONEGUARD
    (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro, email, senha, role)
SELECT 'Administrador BoneGuard', 30, 'M', 80.00, 'N', 'ATIVO', 'S', SYSDATE,
       'admin@boneguard.com',
       '$2a$10$WCIomeQq3MSbbIIBfymOMex.Iy280B5HlOb6LlM/uYQJV1Y/EkrC6',
       'ADMIN'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM TB_PACIENTE_BONEGUARD WHERE email = 'admin@boneguard.com')
/

INSERT INTO TB_PACIENTE_BONEGUARD
    (nome, idade, sexo, peso, historico_familiar, nivel_atividade, alimentacao_calcio, data_cadastro, email, senha, role)
SELECT 'Maria Silva', 65, 'F', 62.50, 'S', 'MODERADO', 'N', SYSDATE,
       'paciente@boneguard.com',
       '$2a$10$4/PTVdsgcgEyX1PaeI.80e9HbZQzPVUGqtn0j0PUEy4L5upb0Lrje',
       'USER'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM TB_PACIENTE_BONEGUARD WHERE email = 'paciente@boneguard.com')
/
