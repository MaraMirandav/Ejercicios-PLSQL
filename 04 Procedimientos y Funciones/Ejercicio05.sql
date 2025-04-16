-- 11) Escribir un procedimiento que modifique la localidad de un departamento. El procedimiento recibirá como parámetros el número del departamento y la localidad nueva.

-- Para volver a colocar como localidad original a Valencia
UPDATE DEPT SET LOC = 'VALENCIA'WHERE DEPTNO = 50;

-- Creamos una función para poder obtener los datos del departamento
CREATE OR REPLACE FUNCTION datos_departamento(p_numero_departamento NUMBER) RETURN VARCHAR2 IS
    v_dname DEPT.DNAME%TYPE;
    v_loc DEPT.LOC%TYPE;
    v_datos VARCHAR2(50);
BEGIN
    SELECT DNAME, LOC INTO v_dname, v_loc
    FROM DEPT WHERE DEPTNO = p_numero_departamento;

    v_datos := 'Departamento : ' || TO_CHAR(v_dname) || ' Localidad: ' || TO_CHAR(v_loc);

    RETURN v_datos;
END;
/

-- Procedimiento
CREATE OR REPLACE PROCEDURE modificar_localidad(p_numero_departamento NUMBER, p_nueva_localidad VARCHAR2) IS
    v_datos VARCHAR2(50) := datos_departamento(p_numero_departamento);
    v_nuevos_datos VARCHAR2(50);
BEGIN
    -- Para mostrar los datos y localidad actual
    DBMS_OUTPUT.PUT_LINE('Se va modificar la localidad del departamento número ' || p_numero_departamento);
    DBMS_OUTPUT.PUT_LINE('Se muestra información actual antes del cambio:');
    DBMS_OUTPUT.PUT_LINE(v_datos);
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('La localidad será cambiada por '  || p_nueva_localidad);
    DBMS_OUTPUT.NEW_LINE;

    -- Para modificar la localidad del departamento, mediante numero de departamento
    UPDATE DEPT
    SET LOC = p_nueva_localidad
    WHERE DEPTNO = p_numero_departamento;

    -- Para visualizar los nuevos datos modificados
    v_nuevos_datos := datos_departamento(p_numero_departamento);
    DBMS_OUTPUT.PUT_LINE('Departamento modificado  en a base de datos...');
    DBMS_OUTPUT.PUT_LINE(v_nuevos_datos);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN ROLLBACK;
END;
/


-- Probando el funcionamiento del procedimiento
EXECUTE MODIFICAR_LOCALIDAD(50,'A CORUÑA');

    SELECT * from dept;