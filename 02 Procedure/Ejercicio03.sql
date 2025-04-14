-- 3) Escribir una función que reciba una fecha y devuelva el año, en número, correspondiente a esa fecha.
SET SERVEROUTPUT ON

-- Ejercicio realizado como procedimiento:
CREATE OR REPLACE PROCEDURE anio_fecha(p_fecha DATE) IS
    v_anio NUMBER;
BEGIN
    v_anio := TO_NUMBER(EXTRACT(YEAR FROM p_fecha));
    DBMS_OUTPUT.PUT_LINE('El año correspondiente a la fecha es: ' || TO_CHAR(v_anio));
END;
/

EXECUTE anio_fecha(TO_DATE('18-01-1992','DD-MM-YYYY'))

-----------------------------------------------------------------------------------------------------------
-- Ejercicio realizado como función:
CREATE OR REPLACE FUNCTION anio_fechas(p_fecha DATE) RETURN NUMBER IS
    v_anio NUMBER;
BEGIN
    v_anio := TO_NUMBER(EXTRACT(YEAR FROM p_fecha));
    RETURN v_anio;
END;
/

DECLARE
    anio NUMBER;
BEGIN
    anio := anio_fechas(TO_DATE('05-09-1994','DD-MM-YYYY'));
    DBMS_OUTPUT.PUT_LINE('El año correspondiente a la fecha es: ' || TO_CHAR(anio));
END;
/

