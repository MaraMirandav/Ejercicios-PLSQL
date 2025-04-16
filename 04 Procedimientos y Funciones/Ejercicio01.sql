-- 8) Codificar un procedimiento que reciba una lista de hasta 5 números y visualice su suma.
SET SERVEROUTPUT ON

-- Creo el varray de números primero, para luego usarlo en el procedimiento
CREATE TYPE numero_varray AS VARRAY(5) OF NUMBER;

-- Procedimiento: Uso in para indicar variable de entrada
CREATE OR REPLACE PROCEDURE sumar_lista_numeros(p_numero_array IN numero_varray) IS
    resultado_suma NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('El listado de números es el siguiente: ');
    FOR i IN 1..p_numero_array.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE( '-> ' || TO_CHAR(p_numero_array(i)));
        resultado_suma := resultado_suma + p_numero_array(i);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('El resultado de la suma del listado de números es: ' || TO_CHAR(resultado_suma));
END;
/

-- Bloque anónimo de prueba:
DECLARE
    LISTADO numero_varray := numero_varray(25, 4, 60, 2, 7);
BEGIN
    SUMAR_LISTA_NUMEROS(LISTADO);
END;
/

