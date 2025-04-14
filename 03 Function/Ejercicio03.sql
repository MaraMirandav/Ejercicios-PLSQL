-- 6) Desarrollar una función que devuelva el número de años completos que hay entre dos fechas que se pasan como argumentos.
SET SERVEROUTPUT ON
CREATE OR REPLACE FUNCTION cuantos_anios(p_fecha1 DATE, p_fecha2 DATE) RETURN NUMBER IS
    v_anios_completos NUMBER;
BEGIN
    v_anios_completos := ABS(TRUNC(MONTHS_BETWEEN(p_fecha1, p_fecha2) / 12));
    RETURN v_anios_completos;
END;
/

DECLARE
    v_anios NUMBER;
    v_fecha1 DATE := TO_DATE('28-04-2016','DD-MM-YYYY');
    v_fecha2 DATE := SYSDATE; --fecha de hoy
BEGIN
    v_anios := CUANTOS_ANIOS(v_fecha1, v_fecha2);
    DBMS_OUTPUT.PUT_LINE('El número de años transcurridos entre las fechas es: ' || TO_CHAR(v_anios) || ' años.');
END;
/