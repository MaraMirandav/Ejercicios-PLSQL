-- 5) Codificar un programa que visualice los dos empleados que ganan menos de cada oficio.

SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE salarios_inferiores IS
    CURSOR C1 IS SELECT ENAME, SAL FROM EMP ORDER BY SAL ASC FETCH FIRST 2 ROWS ONLY;
    CC1 C1%ROWTYPE;
BEGIN
    -- Para imprimir titulo del procedimiento
    DBMS_OUTPUT.PUT_LINE('Dos empleados que tienen salarios más bajos: ');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',53, '-'));
    OPEN C1;
    LOOP
        FETCH C1 INTO CC1;
        EXIT WHEN C1%NOTFOUND;

        -- Para imprimir los empleados y sus salarios
        DBMS_OUTPUT.PUT_LINE(RPAD('| Empleado: ' || CC1.ENAME,25) || RPAD(' | Salario: € ' || TO_CHAR(CC1.SAL,'9999.00'),26) || ' |');
    END LOOP;
    CLOSE C1;
END;
/

-- Probando el funcionamiento del procedimiento
EXECUTE SALARIOS_INFERIORES;