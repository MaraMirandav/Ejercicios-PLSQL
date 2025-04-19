-- 6) Escribir un programa que muestre, en formato similar a las rupturas de control o secuencia vistas en SQL*plus los siguientes datos:
-- Para cada empleado: apellido y salario.
-- Para cada departamento: Número de empleados y suma de los salarios del departamento.
-- Al final del listado: Número total de empleados y suma de todos los salarios.

/* Nota: este procedimiento puede escribirse de forma que la visualización de los
resultados resulte mas clara incluyendo líneas de separación, cabeceras de columnas,
etcétera. Por razones didácticas no se han incluido estos elementos ya que pueden
distraer y dificultar la comprensión del código. */

-- Para cada empleado: apellido y salario. -> PROCEDIMIENTO
CREATE OR REPLACE PROCEDURE datos_empleados_salario IS
    CURSOR C1 IS SELECT EMPNO, ENAME, SAL FROM EMP ORDER BY ENAME ASC;
    v_id EMP.EMPNO%TYPE;
    v_nombre_empleado EMP.ENAME%TYPE;
    v_salario_empleado EMP.SAL%TYPE;
BEGIN
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('DATOS CORRESPONDIENTES A LOS EMPLEADOS ');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',68, '-'));
    OPEN C1;
    LOOP
        FETCH C1 INTO v_id, v_nombre_empleado, v_salario_empleado;
        EXIT WHEN C1%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD('| ID Empleado: ' || TO_CHAR(v_id),22) ||
                            RPAD(' | Empleado: ' || v_nombre_empleado,22) ||
                            RPAD(' | Salario: € ' || TO_CHAR(v_salario_empleado,'9999.99'),22) || ' |' );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(LPAD('-',68, '-'));
    CLOSE C1;
END;
/

-- Para cada departamento: Número de empleados y suma de los salarios del departamento. -> PROCEDIMIENTO
CREATE OR REPLACE PROCEDURE datos_departamento_salario IS
    CURSOR C1 IS SELECT A.DEPTNO AS DEPARTAMENTO, MIN(A.DNAME) AS NOMBRE,
                    COUNT(B.EMPNO) AS EMPLEADOS, NVL(SUM(B.SAL),0) AS SALARIO
                    FROM DEPT A LEFT JOIN EMP B ON A.DEPTNO = B.DEPTNO
                    GROUP BY A.DEPTNO
                    ORDER BY A.DEPTNO ASC;
    CC1 C1%ROWTYPE;
BEGIN
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('DATOS CORRESPONDIENTES A CADA DEPARTAMENTO');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',93, '-'));
    OPEN C1;
    LOOP
        FETCH C1 INTO CC1;
        EXIT WHEN C1%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD('| N° Depto: ' || TO_CHAR(CC1.DEPARTAMENTO),15) ||
                            RPAD(' | Departamento: ' || CC1.NOMBRE,27) ||
                            RPAD(' | N° Empleados: ' || TO_CHAR (CC1.EMPLEADOS),20) ||
                            RPAD(' | Total Salarios: € ' || TO_CHAR (CC1.SALARIO, '99999.99'),30) || ' |' );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(LPAD('-',93, '-'));
    CLOSE C1;
END;
/

-- Al final del listado: Número total de empleados y suma de todos los salarios. -> FUNCTION
CREATE OR REPLACE PROCEDURE resumen_empleados_general IS
    v_total_empleados NUMBER;
    v_total_salarios NUMBER;
BEGIN
    SELECT COUNT(EMPNO), NVL(SUM(SAL),0)
    INTO v_total_empleados, v_total_salarios FROM EMP;

    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('LISTADO FINAL CON TOTAL DE EMPLEADOS Y SALARIOS');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',56, '-'));
    DBMS_OUTPUT.PUT_LINE(RPAD('| TOTAL EMPLEADOS: ' || TO_CHAR(v_total_empleados),25) ||
                        ('| TOTAL SALARIOS: € ' || TO_CHAR(v_total_salarios, '99999.99') || ' |'));
    DBMS_OUTPUT.PUT_LINE(LPAD('-',56, '-'));
END;
/

-- PROCEDIMIENTO FINAL --> REUNE TODOS LO SOLICITADO EN EL ENUNCIADO
CREATE OR REPLACE PROCEDURE resumen_final_empresa IS
    v_resumen_final VARCHAR2(400) := RESUMEN_FINAL_EMPLEADOS;
BEGIN
    DBMS_OUTPUT.PUT_LINE(LPAD('-',68, '-'));
    DBMS_OUTPUT.PUT_LINE('Resumen final: Departamento y Empleados de la Empresa');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',68, '-'));

    -- Para cada empleado: apellido y salario.
    datos_empleados_salario();

    -- Para cada departamento: Número de empleados y suma de los salarios del departamento
    datos_departamento_salario();

    -- Al final del listado: Número total de empleados y suma de todos los salarios.
    resumen_empleados_general();
END;
/

-- Probando el funcionamiento del procedimiento
EXECUTE RESUMEN_FINAL_EMPRESA;