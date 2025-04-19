--9) Codificar un procedimiento reciba como parámetros un numero de departamento, un importe y un porcentaje; y suba el salario a todos los empleados del departamento indicado en la llamada. La subida será el porcentaje o el importe indicado en la llamada (el que sea más beneficioso para el empleado en cada caso empleado).

-- Función para calcular el aumento mediante porcentaje del salario
CREATE OR REPLACE FUNCTION aumento_salario_porcentaje(p_salario NUMBER, p_porcentaje NUMBER) RETURN NUMBER IS
    v_subida_porcentaje NUMBER;
BEGIN
    v_subida_porcentaje := p_salario * (p_porcentaje / 100);
    RETURN v_subida_porcentaje;
END;
/

CREATE OR REPLACE PROCEDURE aumento_sueldo_departamento(p_numero_depto NUMBER, p_importe NUMBER, p_porcentaje NUMBER) IS
    CURSOR C1(depto EMP.DEPTNO%TYPE) IS SELECT ENAME, SAL FROM EMP WHERE DEPTNO = depto;
    CC1 C1%ROWTYPE;
    v_subida_porcentaje NUMBER;
    v_subida_definitiva NUMBER;
    v_departamento_existe BOOLEAN := DEPARTAMENTO_EXISTE(p_numero_depto); -- Reutilizo una función del ejercicio anterior, para comprobar si existe el departamento ingresado
    ex_departamento_no_existe EXCEPTION;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Subida salarial: Departamento N° ' || p_numero_depto);
    DBMS_OUTPUT.PUT_LINE(LPAD('-',40, '-'));
    OPEN C1(p_numero_depto);
    LOOP
        FETCH C1 INTO CC1;
        EXIT WHEN C1%NOTFOUND;
        --Calculo del porcentaje mediante la función
        v_subida_porcentaje := AUMENTO_SALARIO_PORCENTAJE(CC1.SAL, p_porcentaje);

        --Condicional para evaluar lo más conveniente para el empleado
        IF v_departamento_existe THEN
            IF v_subida_porcentaje > p_importe THEN
                v_subida_definitiva := CC1.SAL + v_subida_porcentaje;
                --Impresión de los cambios por pantalla
                DBMS_OUTPUT.PUT_LINE(RPAD('-> Empleado: ', 20) || ' | '|| CC1.ENAME);
                DBMS_OUTPUT.PUT_LINE(RPAD('-> Salario: ', 20) || ' | € '|| TO_CHAR(CC1.SAL,'9999.99'));
                DBMS_OUTPUT.PUT_LINE(RPAD('-> Subida Salarial: ', 20) || ' | € ' || TO_CHAR(v_subida_definitiva,'9999.99'));
                DBMS_OUTPUT.PUT_LINE(RPAD('-> Porcentaje subida: ', 20) || ' | ' || TO_CHAR(p_porcentaje,'99') || '%');
                DBMS_OUTPUT.NEW_LINE;
            ELSE
                v_subida_definitiva := CC1.SAL + p_importe;
                --Impresión de los cambios por pantalla
                DBMS_OUTPUT.PUT_LINE(RPAD('-> Empleado: ', 20) || ' | '|| CC1.ENAME);
                DBMS_OUTPUT.PUT_LINE(RPAD('-> Salario: ', 20) || ' | € '|| TO_CHAR(CC1.SAL,'9999.99'));
                DBMS_OUTPUT.PUT_LINE(RPAD('-> Subida Salarial: ', 20) || ' | € ' || TO_CHAR(v_subida_definitiva,'9999.99'));
                DBMS_OUTPUT.PUT_LINE(RPAD('-> Importe: ', 20) || ' | € ' || TO_CHAR(p_importe, '999.99'));
                DBMS_OUTPUT.NEW_LINE;
            END IF;
        ELSE
            RAISE ex_departamento_no_existe;
        END IF;

        --UPDATE para hacer los cambios en la tabla
        UPDATE EMP
        SET SAL = v_subida_definitiva WHERE ENAME = CC1.ENAME
        AND DEPTNO = p_numero_depto;
    END LOOP;
    CLOSE C1;

    COMMIT;
EXCEPTION
    WHEN ex_departamento_no_existe THEN
        DBMS_OUTPUT.PUT_LINE('Error: El departamento ' || TO_CHAR(p_numero_depto) ||' no existe. Vuelva a intentarlo');
    WHEN OTHERS THEN ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
END;
/

-- Probando el funcionamiento del procedimiento
EXECUTE AUMENTO_SUELDO_DEPARTAMENTO(50,500,5);
