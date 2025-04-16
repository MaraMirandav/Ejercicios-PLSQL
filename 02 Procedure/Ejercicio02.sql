-- 2) Codificar un procedimiento que reciba una cadena y la visualice al revés.
SET SERVEROUTPUT ON

-- Procedimiento
CREATE OR REPLACE PROCEDURE voltear_cadena (p_cadena VARCHAR2) IS
v_cadena_volteada VARCHAR2(20) := '';
v_cadena_aux VARCHAR2(1) := '';

BEGIN
    FOR i IN 1..LENGTH(p_cadena) LOOP
        v_cadena_aux := SUBSTR(p_cadena,i,1);
        v_cadena_volteada := v_cadena_aux || v_cadena_volteada;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(v_cadena_volteada);
END;
/

-- Probando el funcionamiento del procedimiento:
EXECUTE voltear_cadena('Ikigai')