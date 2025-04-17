-- 4) Escribir un programa que visualice el apellido y el salario de los cinco empleados que tienen el salario más alto.

SET SERVEROUTPUT ON
-- Procedimientos
CREATE OR REPLACE PROCEDURE mejores_salarios IS
    CURSOR C1 IS SELECT ENAME, SAL FROM EMP ORDER BY SAL DESC FETCH FIRST 5 ROWS ONLY;
    CC1 C1%ROWTYPE;
BEGIN
    -- Para mostrar titulo
    DBMS_OUTPUT.PUT_LINE('Cinco empleados que tienen salario más alto: ');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',53, '-'));
    OPEN C1;
    LOOP
        FETCH C1 INTO CC1;
        EXIT WHEN C1%NOTFOUND;

        -- Para visualizar los empleados y sus salarios
        DBMS_OUTPUT.PUT_LINE(RPAD('| Empleado: ' || CC1.ENAME,25) || RPAD(' | Salario: € ' || TO_CHAR(CC1.SAL,'9999.99'),26) || ' |');
    END LOOP;
    CLOSE C1;
END;
/

-- Probando el funcionamiento del procedimiento
EXECUTE mejores_salarios;