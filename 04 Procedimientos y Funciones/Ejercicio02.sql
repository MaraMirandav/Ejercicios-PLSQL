-- 9.1) Escribir una función que devuelva solamente caracteres alfabéticos sustituyendo cualquier otro carácter por blancos a partir de una cadena que se pasará en la llamada.

SET SERVEROUTPUT ON

-- Función
CREATE OR REPLACE FUNCTION caracteres_alfabeticos(p_cadena VARCHAR2) RETURN VARCHAR2 IS
    -- Usando expresiones regulares para filtrar correctamente y armar la nueva cadena
    v_patron VARCHAR2(50) := '^[A-Za-z]+$';
    v_caracter VARCHAR2(1) := '';
    v_nueva_cadena VARCHAR2(50) := '';
BEGIN
    FOR i IN 1..LENGTH(p_cadena) LOOP
        v_caracter := SUBSTR(p_cadena,i,1);
        IF REGEXP_LIKE(v_caracter,v_patron) THEN
            v_nueva_cadena := v_nueva_cadena || v_caracter;
        ELSE
            v_nueva_cadena := v_nueva_cadena || ' ';
        END IF;
    END LOOP;
    RETURN v_nueva_cadena;
END;
/

-- Bloque anónimo de prueba:
DECLARE
    v_cadena VARCHAR2(10) := 'Hol@_MuNd0';
    v_cadena_nueva VARCHAR2(10);
BEGIN
    v_cadena_nueva := caracteres_alfabeticos(v_cadena);
    DBMS_OUTPUT.PUT_LINE(v_cadena);
    DBMS_OUTPUT.PUT_LINE(v_cadena_nueva);
END;
/


