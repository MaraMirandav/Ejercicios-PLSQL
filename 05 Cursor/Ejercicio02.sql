--2) Codificar un procedimiento que muestre el nombre de cada departamento y el número de empleados que tiene.
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE mostrar_departamentos IS
    CURSOR C1 IS SELECT A.DNAME as Departamento, COUNT(B.EMPNO) AS Empleados
                    FROM DEPT A LEFT JOIN EMP B ON A.DEPTNO = B.DEPTNO
                    GROUP BY A.DNAME;
    CC1 C1%ROWTYPE;

BEGIN
    -- Para mostrar titulo
    DBMS_OUTPUT.PUT_LINE('Nombre de los departamentos y su cantidad de empleados:');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',53, '-'));
    OPEN C1;
    LOOP
        FETCH C1 INTO CC1;
        EXIT WHEN C1%NOTFOUND;
        -- Para visualizar los departamentos y cantidad de empleados
        DBMS_OUTPUT.PUT_LINE(RPAD('| Depto: ' || CC1.Departamento,25) || ' | Cantidad: ' || TO_CHAR(CC1.Empleados) || ' |');
    END LOOP;
    CLOSE C1;
END;
/

-- Probando el funcionamiento del procedimiento
EXECUTE MOSTRAR_DEPARTAMENTOS;