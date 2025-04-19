-- 7) Desarrollar un procedimiento que permita insertar nuevos departamentos según las siguientes especificaciones:
    -- Se pasará al procedimiento el nombre del departamento y la localidad.
    -- El procedimiento insertará la fila nueva asignando como número de departamento la decena siguiente al número mayor de la tabla.
    -- Se incluirá gestión de posibles errores. -> Si existe, ver error

SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE nuevo_departamento(p_nombre_depto VARCHAR2 DEFAULT 'PROVISIORIO', p_localidad VARCHAR2 DEFAULT 'PROVISORIO') IS
    v_numero_depto DEPT.DEPTNO%TYPE;
    v_nombre_existe NUMBER;
    v_nuevo_numero_depto NUMBER;
    ex_depto_duplicado EXCEPTION; --Declaramos una excepción
BEGIN
    -- Tomaremos el valor máximo del número de departamento:
    SELECT MAX(DEPTNO) INTO v_numero_depto FROM DEPT;
    v_nuevo_numero_depto := v_numero_depto + 10;

    -- Revisaremos si existe el departamento, para evitar que se inserten valores duplicados
    SELECT count(DNAME) INTO v_nombre_existe
    FROM DEPT WHERE DNAME = p_nombre_depto;

    IF v_nombre_existe > 0 THEN
        RAISE ex_depto_duplicado; -- hacemos uso de la excepción aquí
    ELSE
        -- Insertaremos los datos
        INSERT INTO DEPT(DEPTNO, DNAME, LOC)
        VALUES (v_nuevo_numero_depto, p_nombre_depto, p_localidad);
        DBMS_OUTPUT.PUT_LINE('Nuevo departamento ingresado correctamente');
        DBMS_OUTPUT.PUT_LINE(LPAD('-',68, '-'));
        DBMS_OUTPUT.PUT_LINE(RPAD('-> N° Departamento: ' || v_nuevo_numero_depto,27));
        DBMS_OUTPUT.PUT_LINE(RPAD('-> Nombre: ' || p_nombre_depto,27));
        DBMS_OUTPUT.PUT_LINE(RPAD('-> Localidad: ' || p_localidad,27));
    COMMIT;
    END IF;
EXCEPTION
    WHEN ex_depto_duplicado THEN
        DBMS_OUTPUT.PUT_LINE('Ya tienes un departamento '|| p_nombre_depto || ' creado, modifica ese para crear otro');
    WHEN OTHERS THEN ROLLBACK;
END;
/

-- Probando el funcionamiento del procedimiento
EXECUTE NUEVO_DEPARTAMENTO('BODEGA','VALENCIA');
SELECT * from DEPT;