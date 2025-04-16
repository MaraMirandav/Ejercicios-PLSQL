-- 1) Desarrollar un procedimiento que visualice el apellido y la fecha de alta de todos los empleados ordenados por apellido.

SET SERVEROUTPUT ON
--Procedimiento
CREATE OR REPLACE PROCEDURE datos_alta IS
    CURSOR C1 IS SELECT ENAME, HIREDATE FROM EMP ORDER BY ENAME ASC; -- cursor
    v_apellido EMP.ENAME%TYPE;
    v_fecha_alta EMP.HIREDATE%TYPE;
BEGIN
    -- Para mostrar titulo de los datos a mostrar
    DBMS_OUTPUT.PUT_LINE('Apellidos y fecha de alta de los empleados:');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',53, '-'));
    OPEN C1;
    LOOP
        FETCH C1 INTO v_apellido, v_fecha_alta;
        EXIT WHEN C1%NOTFOUND;
        -- Para visualizar los empleados y fecha de alta
        DBMS_OUTPUT.PUT_LINE(RPAD('| Apellido: ' || v_apellido,25) || ' | Fecha alta: ' || TO_CHAR(v_fecha_alta, 'DD-MON-YYYY') || ' |');
    END LOOP;
    CLOSE C1;
END;
/

-- Probando el funcionamiento del procedimiento
EXECUTE DATOS_ALTA;