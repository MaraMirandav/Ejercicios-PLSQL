-- 10) Codificar un procedimiento que permita borrar un empleado cuyo número se pasará en la llamada.
--Se ha insertado un nuevo empleado para hacer las pruebas
INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO)
VALUES (8001, 'JUAN', 'ANALYST', 7566, TO_DATE('15-APR-2045', 'DD-MON-YYYY'), 3000, NULL, 20);

SET SERVEROUTPUT ON

-- Creamos una función para poder obtener los datos del empleado a borrar de la base de datos
CREATE OR REPLACE FUNCTION datos_empleados(p_numero_empleado NUMBER) RETURN VARCHAR2 IS
    v_ename EMP.ENAME%TYPE;
    v_job EMP.JOB%TYPE;
    v_datos VARCHAR2(50);

BEGIN
    SELECT ENAME, JOB INTO v_ename, v_job
    FROM EMP
    WHERE EMPNO = p_numero_empleado;

    v_datos := 'Apellido: ' || TO_CHAR(v_ename) || ' Funciones de: ' || TO_CHAR(v_job);

    RETURN v_datos;
END;
/

-- Creamos el procedimiento
CREATE OR REPLACE PROCEDURE delete_empleado(p_numero_empleado NUMBER) IS
    v_datos VARCHAR2(50) := datos_empleados(p_numero_empleado);
BEGIN
    -- Para mostrar los datos del empleado a eliminar
    DBMS_OUTPUT.PUT_LINE('Eliminando al empleado número ' || p_numero_empleado || ' de la base de datos...');
    DBMS_OUTPUT.PUT_LINE(v_datos);

    -- Para borrar al empleado mediante numero de empleado
    DELETE FROM EMP
    WHERE EMPNO = p_numero_empleado;

    DBMS_OUTPUT.PUT_LINE('Empleado eliminado de la base de datos...');
END;
/

-- Probando el funcionamiento del procedimiento
EXECUTE DELETE_EMPLEADO(8001);