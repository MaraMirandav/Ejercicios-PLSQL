-- 3) Escribir un procedimiento que reciba una cadena y visualice el apellido y el número de empleado de todos los empleados cuyo apellido contenga la cadena especificada. Al finalizar visualizar el número de empleados mostrados

SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE buscar_empleados(p_cadena VARCHAR2) IS
    CURSOR C1 IS SELECT ENAME, EMPNO FROM EMP WHERE ENAME LIKE '%' || p_cadena || '%';
    CC1 C1%ROWTYPE;
    v_contador NUMBER := 0; -- para contar resultados
BEGIN
    -- Para mostrar titulo
    DBMS_OUTPUT.PUT_LINE('Búsqueda de empleados "' || p_cadena ||'" :');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',53, '-'));
    OPEN C1;
    LOOP
        FETCH C1 INTO CC1;
        EXIT WHEN C1%NOTFOUND;
        v_contador := v_contador + 1;

        -- Para visualizar los empleados con las coincidencias y el numero de empleado
        DBMS_OUTPUT.PUT_LINE(RPAD('| Empleado: ' || CC1.ENAME,25) || ' | N° Empleado: ' || TO_CHAR(CC1.EMPNO) || ' |');
    END LOOP;
    CLOSE C1;

    --Para validar si la cadena no tiene coincidencias
    IF v_contador = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No hay resultados para "' || p_cadena ||'"');
    END IF;
END;
/

-- Probando el funcionamiento del procedimiento
EXECUTE buscar_empleados('AR');


