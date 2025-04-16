-- 1) Escribir un bloque PL/SQL que escriba el texto ‘Hola’

SET SERVEROUTPUT ON

-- Bloque anónimo para imprimir la cadena:
DECLARE
v_cadena VARCHAR2(20);
BEGIN
    v_cadena := 'Hola';
    DBMS_OUTPUT.PUT_LINE(v_cadena);
END;
/

