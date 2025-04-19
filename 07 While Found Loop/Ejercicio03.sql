--11) Diseñar una aplicación que simule un listado de liquidación de los empleados según las siguientes especificaciones:
    -- El listado tendrá el siguiente formato para cada empleado:

 -- **********************************************************************
-- Liquidación del empleado:...................(1)
-- Dpto:.......................................(2)
-- Oficio:.....................................(3)
-- Salario : ..................................(4)
-- Trienios ...................................(5)
-- Comp. Responsabil ..........................(6)
-- Comisión ...................................(7)
-- Total ......................................(8)
-- **********************************************************************

-- Donde:
-- ▪ 1 ,2, 3 y 4 Corresponden al apellido, departamento, oficio y salario del empleado.
-- ▪ 5 Es el importe en concepto de trienios. Cada trienio son tres años completos desde la fecha de alta hasta la de emisión y supone 50€.
-- ▪ 6 Es el complemento por responsabilidad. Será de 100€ por cada empleado que se encuentre directamente a cargo del empleado en cuestión.
-- ▪ 7 Es la comisión. Los valores nulos serán sustituidos por ceros.
-- ▪ 8 Suma de todos los conceptos anteriores.
-- El listado irá ordenado por Apellido.


-- Procedimiento final
CREATE OR REPLACE PROCEDURE confeccion_liquidaciones IS
    CURSOR C1 IS SELECT EMPNO,ENAME, DEPTNO, JOB, SAL, NVL(COMM, 0) AS COMISION, HIREDATE FROM EMP ORDER BY ENAME ASC;
    CC1 C1%ROWTYPE;
    v_cantidad_trienios NUMBER;
    v_complemento_trienios NUMBER;
    v_cantidad_empleados_a_cargo NUMBER;
    v_complemento_responsabilidad NUMBER;
    v_total_conceptos NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Liquidaciones de Sueldo Empleados');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',50, '-'));
    DBMS_OUTPUT.NEW_LINE;
    OPEN C1;
    LOOP
        FETCH C1 INTO CC1;
        EXIT WHEN C1%NOTFOUND;

        -- Para calcular los trienios usaré las funciones creadas en ejercicios ante
        v_cantidad_trienios := CUANTOS_TRIENIOS(CC1.HIREDATE, SYSDATE);
        v_complemento_trienios := v_cantidad_trienios * 50;

        -- Para calcular el cargo por responsabilidad
        SELECT COUNT(MGR) INTO v_cantidad_empleados_a_cargo
        FROM EMP_BK WHERE MGR  = CC1.EMPNO;

        v_complemento_responsabilidad := 100 * NVL(v_cantidad_empleados_a_cargo,0);

        -- Calculo total:
        v_total_conceptos := CC1.SAL + v_complemento_trienios + v_complemento_responsabilidad + CC1.COMISION;

        --Impresión de los cambios por pantalla
        DBMS_OUTPUT.PUT_LINE(LPAD('-',60, '-'));
        DBMS_OUTPUT.NEW_LINE;
        DBMS_OUTPUT.PUT_LINE(RPAD('Liquidación del Empleado:', 45,'.') || ' ' || CC1.ENAME);
        DBMS_OUTPUT.PUT_LINE(RPAD('Depto:', 20, '.') || ' ' || TO_CHAR(CC1.DEPTNO) || RPAD(' Oficio:', 20, '.') || ' ' || CC1.JOB);
        DBMS_OUTPUT.NEW_LINE;
        DBMS_OUTPUT.PUT_LINE(RPAD('Salario:', 40,'.') || ' € ' || TO_CHAR(CC1.SAL,'9,990.90'));
        DBMS_OUTPUT.PUT_LINE(RPAD('Trienios:', 40,'.') || ' € ' || TO_CHAR(v_complemento_trienios,'9,990.90'));
        DBMS_OUTPUT.PUT_LINE(RPAD('Comp. Responsabilidad:', 40,'.') || ' € ' || TO_CHAR(v_complemento_responsabilidad,'9,990.90'));
        DBMS_OUTPUT.PUT_LINE(RPAD('Comisión:', 40,'.') || ' € ' || TO_CHAR(CC1.COMISION,'9,990.90'));
        DBMS_OUTPUT.NEW_LINE;
        DBMS_OUTPUT.PUT_LINE(RPAD('TOTAL:', 40,'.') || ' € ' || TO_CHAR(v_total_conceptos,'9,990.90'));
        DBMS_OUTPUT.NEW_LINE;
        DBMS_OUTPUT.PUT_LINE(LPAD('-',60, '-'));
        DBMS_OUTPUT.NEW_LINE;
    END LOOP;
    CLOSE C1;
END;
/

-- Probando el funcionamiento del procedimiento
EXECUTE CONFECCION_LIQUIDACIONES();

