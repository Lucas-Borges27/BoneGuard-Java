-- Adiciona coluna role se não existir
DECLARE v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM user_tab_columns
    WHERE table_name = 'TB_PACIENTE_BONEGUARD' AND column_name = 'ROLE';
    IF v_cnt = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE TB_PACIENTE_BONEGUARD ADD (role VARCHAR2(10) DEFAULT ''USER'' NOT NULL)';
    END IF;
END;
/

-- Adiciona constraint de role se não existir
DECLARE v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM user_constraints
    WHERE table_name = 'TB_PACIENTE_BONEGUARD' AND constraint_name = 'CHK_PAC_ROLE';
    IF v_cnt = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE TB_PACIENTE_BONEGUARD ADD CONSTRAINT chk_pac_role CHECK (role IN (''ADMIN'',''USER''))';
    END IF;
END;
/
