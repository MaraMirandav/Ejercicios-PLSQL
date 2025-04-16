-- 7) Escribir una función que, haciendo uso de la función anterior devuelva los trienios que hay entre dos fechas. (Un trienio son tres años completos).

-- Función
CREATE OR REPLACE FUNCTION cuantos_trienios(p_fecha1 DATE, p_fecha2 DATE) RETURN NUMBER IS
    v_trienios NUMBER;
    v_anios_completos NUMBER;
BEGIN
    v_anios_completos := cuantos_anios(p_fecha1, p_fecha2); -- ocupando la función del ejercicio anterior
    v_trienios := trunc(v_anios_completos / 3);
    RETURN v_trienios;
END;
/

-- Bloque anónimo de prueba:
DECLARE
    v_trienios NUMBER;
    v_fecha1 DATE;
    v_fecha2 DATE;
BEGIN
    v_fecha1 := TO_DATE('28-04-2016','DD-MM-YYYY');
    v_fecha2 := SYSDATE;
    v_trienios := CUANTOS_TRIENIOS(v_fecha1, v_fecha2);
    DBMS_OUTPUT.PUT_LINE('La cantidad de trienios calculados con las fechas es: ' || v_trienios || ' trienios.');
END;
/