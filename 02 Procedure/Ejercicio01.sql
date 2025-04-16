-- 1) Escribir un procedimiento que reciba dos números y visualice su suma.
SET SERVEROUTPUT ON

--Procedimiento
CREATE OR REPLACE PROCEDURE suma (p_numero1 NUMBER, p_numero2 NUMBER) IS
    v_suma NUMBER := 0;
BEGIN
    v_suma := p_numero1 + p_numero2;
    DBMS_OUTPUT.PUT_LINE('El resultado de la suma es: ' || TO_CHAR(v_suma));
END;
/

-- Probando el funcionamiento del procedimiento
EXECUTE suma(5,3);