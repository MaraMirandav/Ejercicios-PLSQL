-- 4) Escribir un bloque PL/SQL que haga uso de la función anterior.
SET SERVEROUTPUT ON

-- Bloque anónimo para probar la función anio_fechas:
DECLARE
    anio NUMBER;
BEGIN
    anio := anio_fechas(TO_DATE('05-09-1994','DD-MM-YYYY'));
    DBMS_OUTPUT.PUT_LINE('El año correspondiente a la fecha es: ' || TO_CHAR(anio));
END;
/