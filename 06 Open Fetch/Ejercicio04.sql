-- 8) Escribir un procedimiento que reciba todos los datos de un nuevo empleado. Procese la transacción de alta, gestionando posibles errores.

    SET SERVEROUTPUT ON
-- Función para poder verificar si el departamento existe
CREATE OR REPLACE FUNCTION departamento_existe(p_departamento NUMBER) RETURN BOOLEAN IS
    v_departamento NUMBER;
    v_depto_existe BOOLEAN;
BEGIN
    -- Verificamos si existe el departamento ingresado
    SELECT COUNT(DEPTNO) INTO v_departamento
    FROM DEPT WHERE DEPTNO = p_departamento;

    IF v_departamento > 0 THEN
        v_depto_existe := TRUE;
    ELSE
        v_depto_existe := FALSE;
    END IF;
    RETURN v_depto_existe;
END;
/

-- Función para poder verificar que el sueldo no sea superior al máximo
CREATE OR REPLACE FUNCTION verificar_salario(p_sal NUMBER) RETURN BOOLEAN IS
    v_salario NUMBER;
    v_salario_en_rango BOOLEAN;
BEGIN
    -- Verificamos si existe el departamento ingresado
    SELECT MAX(SAL) INTO v_salario FROM EMP;

    IF p_sal <= v_salario THEN
        v_salario_en_rango := TRUE;
    ELSE
        v_salario_en_rango := FALSE;
    END IF;
    RETURN v_salario_en_rango;
END;
/

-- Función para poder crear el numero de empleado
CREATE OR REPLACE FUNCTION crear_numero_empleado RETURN NUMBER IS
    v_numero_empleado EMP.EMPNO%TYPE;
    v_nuevo_numero_empleado NUMBER;
BEGIN
    --Tomaremos el valor máximo para manipular el numero de empleado y asignarle uno:
    SELECT MAX(EMPNO) INTO v_numero_empleado
    FROM EMP;

    -- Numero final de empleado asignado
    v_nuevo_numero_empleado := v_numero_empleado + 15;
    RETURN v_nuevo_numero_empleado;
END;
/

-- Procedimiento final para ingresar el empleado
CREATE OR REPLACE PROCEDURE ingresar_empleado(p_nombre VARCHAR2, p_job VARCHAR2, p_sal NUMBER, p_departamento NUMBER,p_mgr NUMBER DEFAULT NULL, p_comm NUMBER DEFAULT 0, p_fecha_alta DATE DEFAULT SYSDATE) IS
    -- Crear el número de empleado
    v_numero_empleado NUMBER := CREAR_NUMERO_EMPLEADO();

    -- Verificar existencia de departamento y monto salario -> Entregará TRUE / FALSE
    v_departamento_existe BOOLEAN := DEPARTAMENTO_EXISTE(p_departamento);
    v_salario_en_rango BOOLEAN := VERIFICAR_SALARIO(p_sal);

    -- Excepciones para controlar posibles errores
    ex_departamento_no_existe EXCEPTION;
    ex_salario_excesivo EXCEPTION;

BEGIN
    IF v_departamento_existe AND v_salario_en_rango THEN
        INSERT INTO EMP(EMPNO, ENAME, JOB, MGR, SAL, COMM, DEPTNO, HIREDATE)
        VALUES (v_numero_empleado, p_nombre, p_job, p_mgr, p_sal, p_comm, p_departamento, p_fecha_alta);
        DBMS_OUTPUT.PUT_LINE('Nuevo empleado ingresado correctamente');
        DBMS_OUTPUT.PUT_LINE(LPAD('-',40, '-'));
        DBMS_OUTPUT.PUT_LINE(RPAD('-> N° Empleado: ', 20) || ' | '|| TO_CHAR(v_numero_empleado, '9999'));
        DBMS_OUTPUT.PUT_LINE(RPAD('-> Nombre: ', 20) || ' | '|| p_nombre);
        DBMS_OUTPUT.PUT_LINE(RPAD('-> Trabajo: ', 20) || ' | ' || p_job);
        DBMS_OUTPUT.PUT_LINE(RPAD('-> N° jefe directo: ', 20) || ' | ' || TO_CHAR(p_mgr, '9999'));
        DBMS_OUTPUT.PUT_LINE(RPAD('-> Salario: € ', 20) || ' | '|| TO_CHAR(p_sal, '9999.99'));
        DBMS_OUTPUT.PUT_LINE(RPAD('-> Comisión: € ', 20) || ' | ' || TO_CHAR(p_comm, '9999.99'));
        DBMS_OUTPUT.PUT_LINE(RPAD('-> Número departamento: ', 20) || ' | ' || TO_CHAR(p_departamento, '99'));
        DBMS_OUTPUT.PUT_LINE(RPAD('-> Fecha de alta: ', 20) || ' | ' || TO_CHAR(p_fecha_alta, 'DD-MM-YYYY'));

    ELSIF NOT v_departamento_existe THEN
        RAISE ex_departamento_no_existe; --> Lanzamos excepción departamento
    ELSIF NOT v_salario_en_rango THEN
        RAISE ex_salario_excesivo; --> Lanzamos excepción salario
    END IF;
    COMMIT;
EXCEPTION
    WHEN ex_departamento_no_existe THEN
        DBMS_OUTPUT.PUT_LINE('Error: El departamento ' || TO_CHAR(p_departamento) ||' no existe. Vuelva a intentar el ingreso');
    WHEN ex_salario_excesivo THEN
        DBMS_OUTPUT.PUT_LINE('Error: El salario ingresado es excesivo, revise nuevamente y vuelva a intentarlo: € ' || TO_CHAR(p_sal,'9999,99'));
    WHEN OTHERS THEN ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
END;
/

-- Bloque anónimo de prueba:
DECLARE
    v_nombre VARCHAR2(9) := 'MIRANDA';
    v_job VARCHAR2(9) := 'SALESMAN';
    v_sal NUMBER := 2500;
    v_departamento NUMBER := 50;

BEGIN
    INGRESAR_EMPLEADO(v_nombre,v_job,v_sal,v_departamento);
END;
/


DELETE FROM emp WHERE ename = 'MIRANDA';
SELECT * FROM EMP;