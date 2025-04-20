-- 12) Crear la tabla T_liquidacion con las columnas apellido, departamento, oficio, salario, trienios, comp_responsabilidad, comisión y total; y modificar la aplicación anterior para que en lugar de realizar el listado directamente en pantalla, guarde los datos en la tabla. Se controlarán todas las posibles incidencias que puedan ocurrir durante el proceso.

CREATE TABLE T_liquidacion(
    Apellido VARCHAR2(20) NOT NULL,
    Departamento NUMBER NOT NULL,
    Oficio VARCHAR2(20) NOT NULL,
    Salario NUMBER NOT NULL,
    Trienios NUMBER,
    Complemento_Responsabilidad NUMBER,
    Comision NUMBER,
    Total NUMBER NOT NULL
)

-- Procedimiento modificado para la insertar los datos a la tabla T_Liquidación
CREATE OR REPLACE PROCEDURE insertar_liquidaciones_tabla IS
    CURSOR C1 IS SELECT EMPNO,ENAME, DEPTNO, JOB, SAL, NVL(COMM, 0) AS COMISION, HIREDATE FROM EMP ORDER BY ENAME ASC;
    CC1 C1%ROWTYPE;
    v_cantidad_trienios NUMBER;
    v_complemento_trienios NUMBER;
    v_cantidad_empleados_a_cargo NUMBER;
    v_complemento_responsabilidad NUMBER;
    v_total_conceptos NUMBER;
BEGIN
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

        --Insertar los datos en la tabla T_Liquidación
        INSERT INTO T_liquidacion(Apellido,Departamento, Oficio, Salario, Trienios, Complemento_Responsabilidad, Comision, Total)
        VALUES(CC1.ENAME, CC1.DEPTNO, CC1.JOB, CC1.SAL, v_complemento_trienios, v_complemento_responsabilidad, CC1.COMISION, v_total_conceptos);
    END LOOP;
    CLOSE C1;

        COMMIT;
        --Confirmación de los cambios por pantalla
        DBMS_OUTPUT.PUT_LINE('Datos ingresados con éxito en la tabla T_Liquidación');

EXCEPTION
    WHEN OTHERS THEN ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
END;
/

-- Probando el funcionamiento del procedimiento
EXECUTE insertar_liquidaciones_tabla();

-- Comprobando en la tabla si se han insertado correctamente los datos
SELECT * FROM T_LIQUIDACION;