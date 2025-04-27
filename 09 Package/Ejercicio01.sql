-- 1.- Ejemplo de cómo crear un paquete.
-- Escribir un paquete completo para gestionar los departamentos. El paquete se llamará gest_depart y deberá incluir, al menos, los siguientes subprogramas:
    -- 1) insertar_nuevo_depart: permite insertar un departamento nuevo. El procedimiento recibe el nombre y la localidad del nuevo departamento. Creará el nuevo departamento comprobando que el nombre no se duplique y le asignará como número de departamento la decena siguiente al último número de departamento utilizado.
    -- 2) borrar_depart: permite borrar un departamento. El procedimiento recibirá dos números de departamento de los cuales el primero corresponde al departamento que queremos borrar y el segundo al departamento al que pasarán los empleados del departamento que se va eliminar. El procedimiento se encargará de realizar los cambios oportunos en los números de departamento de los empleados correspondientes.
    -- 3) modificar_loc_depart: modifica la localidad del departamento. El procedimiento recibirá el número del departamento a modificar y la nueva localidad, y realizará el cambio solicitado.
    -- 4) visualizar_datos_depart: visualizará los datos de un departamento cuyo número se pasará en la llamada. Además de los datos relativos al departamento, se visualizará el número de empleados que pertenecen actualmente al departamento.
    -- 5) visualizar_datos_depart: versión sobrecargada del procedimiento anterior que, en lugar del número del departamento, recibirá el nombre del departamento. Realizará una llamada a la función buscar_depart_por_nombre que se indica en el apartado siguiente.
    -- 6) buscar_depart_por_nombre: función local al paquete. Recibe el nombre de un departamento y devuelve el número del mismo.

CREATE OR REPLACE PACKAGE pkg_gest_depart IS
    -- Excepciones:
    ex_departamento_existente EXCEPTION;
    ex_departamento_no_existe EXCEPTION;

    --Insertar nuevo departamento:
    PROCEDURE insertar_nuevo_depart(p_nombre_depart VARCHAR2, p_localidad VARCHAR2);
    FUNCTION nombre_depart_existe(p_nombre_depart VARCHAR2) RETURN BOOLEAN;

    --Borrar departamento:
    PROCEDURE borrar_depart(p_numero_depart_a_borrar NUMBER, p_numero_depart_a_trasladar NUMBER);

    --Modificar localidad departamento:
    PROCEDURE modificar_loc_depart(p_numero_depart NUMBER, p_nueva_localidad VARCHAR2);

    --Visualizar departamentos:
    PROCEDURE visualizar_datos_por_numero(p_numero_depart NUMBER);
    FUNCTION cantidad_empleados_depart(p_numero_depart NUMBER) RETURN NUMBER;

    --Visualizar departamentos:
    PROCEDURE visualizar_datos_por_nombre(p_nombre_depart VARCHAR2);

    -- buscar_depart_por_nombre: -> Retorna numero_depart
    FUNCTION buscar_depart_por_nombre(p_nombre_depart VARCHAR2) RETURN NUMBER;

    -- buscar_depart_por_numero: -> Retorna nombre_depart
    FUNCTION buscar_depart_por_numero(p_numero_depart NUMBER) RETURN VARCHAR2;
END pkg_gest_depart;
/

-------------------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY pkg_gest_depart IS
-- 1) Insertar nuevo departamento:
    PROCEDURE insertar_nuevo_depart(p_nombre_depart VARCHAR2, p_localidad VARCHAR2) IS
        v_max_deptno NUMBER;
        v_deptno_a_insertar NUMBER;

    BEGIN
        -- Obtenemos el maximo del numero de departamento y sumamos 10
        SELECT NVL(MAX(DEPTNO),0) INTO v_max_deptno
        FROM DEPT;
        v_deptno_a_insertar := v_max_deptno + 10;

        --Evaluamos si el departamento a ingresar existe en la base de datos
        IF nombre_depart_existe(p_nombre_depart) THEN
            RAISE ex_departamento_existente;
        ELSE
            INSERT INTO DEPT(DEPTNO, DNAME, LOC)
            VALUES(v_deptno_a_insertar, p_nombre_depart, p_localidad);

            DBMS_OUTPUT.PUT_LINE('Departamento número ' || v_deptno_a_insertar  ||' ingresado exitosamente :');
            DBMS_OUTPUT.PUT_LINE(LPAD('-',45, '-'));
            DBMS_OUTPUT.PUT_LINE(RPAD('| Número depart: ',20) || ' | ' || RPAD(v_deptno_a_insertar,20) || ' | ');
            DBMS_OUTPUT.PUT_LINE(RPAD('| Nombre depart: ',20) || ' | ' || RPAD(p_nombre_depart,20) || ' | ');
            DBMS_OUTPUT.PUT_LINE(RPAD('| Localidad: ',20) || ' | ' || RPAD(p_localidad,20) || ' | ');
        END IF;

        COMMIT;
    EXCEPTION
        WHEN ex_departamento_existente THEN
            DBMS_OUTPUT.PUT_LINE('Error: El departamento ' || p_nombre_depart || ' ya existe');
        WHEN OTHERS THEN ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
    END insertar_nuevo_depart;

    -- Función para evaluar si el nombre del departamento existe
    FUNCTION nombre_depart_existe(p_nombre_depart VARCHAR2) RETURN BOOLEAN IS
        v_cantidad_departamento NUMBER;
        v_depart_existe BOOLEAN;
    BEGIN
        -- Verificamos si existe el departamento ingresado
        SELECT COUNT(DEPTNO) INTO v_cantidad_departamento
        FROM DEPT WHERE DNAME = p_nombre_depart;

        IF v_cantidad_departamento > 0 THEN
            v_depart_existe := TRUE;
        ELSE
            v_depart_existe := FALSE;
        END IF;
        RETURN v_depart_existe;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END;

-- 2) Borrar departamento:
    PROCEDURE borrar_depart(p_numero_depart_a_borrar NUMBER, p_numero_depart_a_trasladar NUMBER) IS
        CURSOR C1(p_numero_depart NUMBER) IS SELECT * FROM EMP WHERE DEPTNO = p_numero_depart;
        CC1 C1%ROWTYPE;
        v_nombre_depart_a_borrar VARCHAR2(20);
        v_nombre_depart_a_trasladar VARCHAR2(20);

    BEGIN
        --Obtenemos el nombre del departamento, mediante la función
        v_nombre_depart_a_borrar := buscar_depart_por_numero(p_numero_depart_a_borrar);
        v_nombre_depart_a_trasladar := buscar_depart_por_numero(p_numero_depart_a_trasladar);

        -- Evaluamos si el departamento existe para poder borrarlo
        IF v_nombre_depart_a_borrar IS NULL OR v_nombre_depart_a_trasladar IS NULL THEN
            RAISE ex_departamento_no_existe;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Empleados trasladados del depart N° '|| p_numero_depart_a_borrar || ' al depart N° ' || p_numero_depart_a_trasladar || ' exitosamente :');
            DBMS_OUTPUT.PUT_LINE(LPAD('-',83, '-'));
            OPEN C1(p_numero_depart_a_borrar);
                LOOP
                    FETCH C1 INTO CC1;
                    EXIT WHEN C1%NOTFOUND;
                    -- Modificamos y trasladamos a los empleados
                    UPDATE EMP
                    SET DEPTNO = p_numero_depart_a_trasladar
                    WHERE EMPNO = CC1.EMPNO;

                    DBMS_OUTPUT.PUT_LINE(RPAD('| Nombre: ',10) || RPAD(CC1.ENAME,10) || RPAD('| Número depart antiguo: ',27) || RPAD(p_numero_depart_a_borrar,5) || RPAD('| Nombre depart nuevo: ',25) || RPAD(TO_CHAR(p_numero_depart_a_trasladar),5) || ' |');
                END LOOP;
            CLOSE C1;

            -- Una vez trasladados, eliminamos el departamento
            DELETE FROM DEPT
            WHERE DEPTNO = p_numero_depart_a_borrar;

            DBMS_OUTPUT.NEW_LINE;
            DBMS_OUTPUT.PUT_LINE('Depart ' || v_nombre_depart_a_borrar || ' borrado');
        END IF;
        COMMIT;
    EXCEPTION
        WHEN ex_departamento_no_existe THEN
            DBMS_OUTPUT.PUT_LINE('Error: Uno de los departamentos no existe (Origen: ' || TO_CHAR(p_numero_depart_a_borrar) || ' , Destino: ' || TO_CHAR(p_numero_depart_a_trasladar) || ')');
        WHEN OTHERS THEN ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
    END borrar_depart;

-- 3) Modificar localidad departamento:
    PROCEDURE modificar_loc_depart(p_numero_depart NUMBER, p_nueva_localidad VARCHAR2) IS
        v_nombre_depart DEPT.DNAME%TYPE;
    BEGIN
        -- Obtenemos el nombre del departamento para poder validar que existe
        SELECT DNAME INTO v_nombre_depart
        FROM DEPT WHERE DEPTNO = p_numero_depart;

        -- Validamos que exista el departamento en primera instancia para modificar la localidad
        IF nombre_depart_existe(v_nombre_depart) THEN
            UPDATE DEPT
            SET LOC = p_nueva_localidad
            WHERE DEPTNO = p_numero_depart;

            -- Imprimir los cambios por pantalla
            DBMS_OUTPUT.PUT_LINE('Localidad del depart N° '|| p_numero_depart || ' cambiada exitosamente:');
            DBMS_OUTPUT.PUT_LINE(LPAD('-',71, '-'));
            DBMS_OUTPUT.PUT_LINE(RPAD('Nombre depart: ',20) || RPAD(v_nombre_depart,14) || RPAD('| Nueva localidad: ',20) || RPAD(p_nueva_localidad,14));
        ELSE
            RAISE ex_departamento_no_existe;
        END IF;
        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: No se encontraron datos del departamento ' || TO_CHAR(p_numero_depart));
        WHEN ex_departamento_no_existe THEN
            DBMS_OUTPUT.PUT_LINE('Error: El departamento ' || p_numero_depart || ' no existe');
        WHEN OTHERS THEN ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
    END modificar_loc_depart;

-- 4) Visualizar departamentos -> mediante número de departamento (sobrecarga)
    PROCEDURE visualizar_datos_por_numero(p_numero_depart NUMBER) IS
        v_nombre DEPT.DNAME%TYPE;
        v_loc DEPT.LOC%TYPE;
        v_cantidad_empleados NUMBER;
    BEGIN
        -- Obtenemos el numero de departamento y la localidad para mostrar los datos
        SELECT DNAME, LOC INTO v_nombre, v_loc
        FROM DEPT WHERE DEPTNO = p_numero_depart;

        -- Obtenemos la cantidad de empleados mediante función cantidad_empleados_depart
        v_cantidad_empleados := cantidad_empleados_depart(p_numero_depart);

        IF nombre_depart_existe(v_nombre) THEN
            --Para mostrarlos por pantalla
            DBMS_OUTPUT.PUT_LINE('Los datos del departamento son los siguientes: ');
            DBMS_OUTPUT.PUT_LINE(LPAD('-',53, '-'));
            DBMS_OUTPUT.PUT_LINE(RPAD('Número depart: ',20) || p_numero_depart);
            DBMS_OUTPUT.PUT_LINE(RPAD('Nombre depart: ',20) || v_nombre);
            DBMS_OUTPUT.PUT_LINE(RPAD('Localidad: ',20) || v_loc);
            DBMS_OUTPUT.PUT_LINE(RPAD('Cantidad empleados: ',20) || v_cantidad_empleados);
        ELSE
            RAISE ex_departamento_no_existe;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: No se encontró el departamento ' || TO_CHAR(p_numero_depart));
        WHEN ex_departamento_no_existe THEN
            DBMS_OUTPUT.PUT_LINE('Error: El departamento ' || TO_CHAR(p_numero_depart) || ' no existe');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
    END visualizar_datos_por_numero;

    -- Función para devolver la cantidad de empleados de departamento
    FUNCTION cantidad_empleados_depart(p_numero_depart NUMBER) RETURN NUMBER IS
        v_cantidad_empleados NUMBER;
    BEGIN
        SELECT COUNT(EMPNO) INTO v_cantidad_empleados
        FROM EMP WHERE DEPTNO = p_numero_depart;

        RETURN v_cantidad_empleados;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END cantidad_empleados_depart;

-- 5) Visualizar departamentos, mediante nombre del departamento(sobrecarga)
    PROCEDURE visualizar_datos_por_nombre(p_nombre_depart VARCHAR2) IS
        v_deptno NUMBER;
        v_loc DEPT.LOC%TYPE;
        v_cantidad_empleados NUMBER;
    BEGIN
        -- Obtenemos el numero de departamento y la localidad para mostrar los datos
        v_deptno := buscar_depart_por_nombre(p_nombre_depart);

        SELECT LOC INTO v_loc
        FROM DEPT WHERE DNAME = p_nombre_depart;

        -- Obtenemos la cantidad de empleados mediante función cantidad_empleados_depart
        v_cantidad_empleados := cantidad_empleados_depart(v_deptno);

        IF nombre_depart_existe(p_nombre_depart) THEN
            --Para mostrarlos por pantalla
            DBMS_OUTPUT.PUT_LINE('Los datos del departamento son los siguientes: ');
            DBMS_OUTPUT.PUT_LINE(LPAD('-',53, '-'));
            DBMS_OUTPUT.PUT_LINE(RPAD('Número depart: ',20) || v_deptno);
            DBMS_OUTPUT.PUT_LINE(RPAD('Nombre depart: ',20) || p_nombre_depart);
            DBMS_OUTPUT.PUT_LINE(RPAD('Localidad: ',20) || v_loc);
            DBMS_OUTPUT.PUT_LINE(RPAD('Cantidad empleados: ',20) || v_cantidad_empleados);
        ELSE
            RAISE ex_departamento_no_existe;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: No se encontró el departamento ' || p_nombre_depart);
        WHEN ex_departamento_no_existe THEN
            DBMS_OUTPUT.PUT_LINE('Error: El departamento ' || p_nombre_depart || ' no existe');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
    END visualizar_datos_por_nombre;

-- 6) Buscar_depart_por_nombre: -> Retorna numero_depart
    FUNCTION buscar_depart_por_nombre(p_nombre_depart VARCHAR2) RETURN NUMBER IS
        v_numero_depart DEPT.DEPTNO%TYPE;
    BEGIN
        SELECT DEPTNO INTO v_numero_depart
        FROM DEPT WHERE DNAME = p_nombre_depart;

        RETURN v_numero_depart;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END buscar_depart_por_nombre;

    -- Buscar_depart_por_numero: -> Retorna nombre_depart
    FUNCTION buscar_depart_por_numero(p_numero_depart NUMBER) RETURN VARCHAR2 IS
        v_nombre_depart DEPT.DNAME%TYPE;
    BEGIN
        SELECT DNAME INTO v_nombre_depart
        FROM DEPT WHERE DEPTNO = p_numero_depart;

        RETURN v_nombre_depart;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END buscar_depart_por_numero;

END pkg_gest_depart;
/


-- Realizando pruebas para ver el funcionamiento del package
------------------------------------------------------------
-- 1) insertar_nuevo_depart (Excepcion funciona)
EXECUTE PKG_GEST_DEPART.insertar_nuevo_depart('MARKETING','MADRID');

------------------------------------------------------------
-- 2) borrar_depart (Excepcion funciona)
EXECUTE PKG_GEST_DEPART.borrar_depart(60,80);

------------------------------------------------------------
-- 3) modificar_loc_depart (funciona)
EXECUTE PKG_GEST_DEPART.modificar_loc_depart(90,'A CORUÑA');

------------------------------------------------------------
-- 4) visualizar_datos_depart (funciona)
EXECUTE PKG_GEST_DEPART.visualizar_datos_por_numero(90);

------------------------------------------------------------
-- 5) visualizar_datos_depart(Excepción funciona)
EXECUTE PKG_GEST_DEPART.visualizar_datos_por_nombre('PRODUCCIONN');

------------------------------------------------------------
-- 6) buscar_depart_por_nombre (Funciona)
DECLARE
    v_depart NUMBER;
BEGIN
    v_depart := PKG_GEST_DEPART.buscar_depart_por_nombre('VENTAS');
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(v_depart));
END;
------------------------------------------------------------
-- 7) buscar_depart_por_numero (Funciona)
DECLARE
    v_depart VARCHAR2(20);
BEGIN
    v_depart := PKG_GEST_DEPART.buscar_depart_por_numero(10);
    DBMS_OUTPUT.PUT_LINE(v_depart);
END;


SELECT * FROM DEPARTAM;