-- 10) Escribir un procedimiento que suba el sueldo de todos los empleados que ganen menos que el salario medio de su oficio. La subida será del 50% de la diferencia entre el salario del empleado y la media de su oficio. Se deberá asegurar que la transacción no se quede a medias, y se gestionarán los posibles errores.

-- Función para calcular el salario medio
CREATE OR REPLACE FUNCTION salario_medio_oficio(p_oficio VARCHAR2) RETURN NUMBER IS
    v_salario_medio NUMBER;
BEGIN
    SELECT AVG(SAL) INTO v_salario_medio
    FROM EMP_BK WHERE JOB = p_oficio;

    RETURN v_salario_medio;
END;
/

-- Procedimiento final para aumento salario para empleados que ganen menos del salario medio de su oficio
CREATE OR REPLACE PROCEDURE aumento_sueldo IS
    CURSOR C1 IS SELECT ENAME, JOB, SAL FROM EMP;
    CC1 C1%ROWTYPE;
    v_salario_medio_oficio NUMBER; -- obtener salario medio oficio
    v_subida_salarial NUMBER; -- para calcular la subida salarial
    v_salario_actualizado NUMBER; -- subida salarial final
BEGIN
    DBMS_OUTPUT.PUT_LINE('Subida salarial empleados: ');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',40, '-'));
    DBMS_OUTPUT.NEW_LINE;

    OPEN C1;
    LOOP
        FETCH C1 INTO CC1;
        EXIT WHEN C1%NOTFOUND;
        -- Salario medio de su oficio, usando la función
        v_salario_medio_oficio := SALARIO_MEDIO_OFICIO(CC1.JOB);

        IF CC1.SAL < v_salario_medio_oficio THEN
            v_subida_salarial := (v_salario_medio_oficio - CC1.SAL) * 0.50;
            v_salario_actualizado := CC1.SAL + v_subida_salarial;

            --UPDATE para hacer los cambios en la tabla
            UPDATE EMP
            SET SAL = v_salario_actualizado
            WHERE ENAME = CC1.ENAME AND JOB = CC1.JOB;

            -- Para imprimir los resultados
            DBMS_OUTPUT.PUT_LINE(RPAD('-> Empleado: ', 20) || ' | '|| CC1.ENAME);
            DBMS_OUTPUT.PUT_LINE(RPAD('-> Oficio: ', 20) || ' | '|| CC1.JOB);
            DBMS_OUTPUT.PUT_LINE(RPAD('-> Salario Medio: ', 20) || ' | € '|| TO_CHAR(v_salario_medio_oficio,'9999.99'));
            DBMS_OUTPUT.PUT_LINE(RPAD('-> Salario: ', 20) || ' | € '|| TO_CHAR(CC1.SAL,'9999.99'));
            DBMS_OUTPUT.PUT_LINE(RPAD('-> Subida Salarial: ', 20) || ' | € ' || TO_CHAR
            (v_salario_actualizado,'9999.99'));
            DBMS_OUTPUT.PUT_LINE(LPAD('-', 30, '-'));
            DBMS_OUTPUT.NEW_LINE;
        END IF;
    END LOOP;
    CLOSE C1;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
END;
/

-- Probando el funcionamiento del procedimiento
EXECUTE AUMENTO_SUELDO();
