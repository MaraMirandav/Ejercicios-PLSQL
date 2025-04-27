
-- 2) Escribir un paquete completo para gestionar los empleados. El paquete se llamará gest_emple e incluirá, al menos los siguientes subprogramas:
    -- 1)insertar_nuevo_emple
    -- 2) borrar_emple. Cuando se borra un empleado todos los empleados que dependían de él pasarán a depender del director del empleado borrado.

    -- 3) modificar_oficio_emple
    -- 4) modificar_dept_emple
    -- 5) modificar_dir_emple
    -- 6) modificar_salario_emple
    -- 7) modificar_comision_emple
    -- 8) visualizar_datos_emple. También se incluirá una versión sobrecargada del procedimiento que recibirá el nombre del empleado.
    -- 9) buscar_emple_por_nombre. Función local que recibe el nombre y devuelve el número.
--Todos los procedimientos recibirán el número del empleado seguido de los demás datos necesarios. También se incluirán en el paquete cursores y declaraciones de tipo registro, así como siguientes procedimientos que afectarán a todos los empleados:
    -- 10) subida_salario_pct: incrementará el salario de todos los empleados el porcentaje indicado en la llamada que no podrá ser superior al 25%.
    -- 11) subida_salario_imp: sumará al salario de todos los empleados el importe indicado en la llamada. Antes de proceder a la incrementar los salarios se comprobará que el importe indicado no supera el 25% del salario medio.

    SET SERVEROUTPUT ON

    CREATE OR REPLACE PACKAGE pkg_gest_emple IS
    -- Excepciones:
    ex_departamento_no_existe EXCEPTION;
    ex_salario_excesivo EXCEPTION;
    ex_empleado_no_existe EXCEPTION;
    ex_empleado_existe EXCEPTION;
    ex_porcentaje_excesivo EXCEPTION;
    ex_importe_excesivo EXCEPTION;

    --1)insertar_nuevo_emple
    PROCEDURE insertar_nuevo_emple(p_numero_empleado NUMBER, p_nombre VARCHAR2, p_job VARCHAR2, p_sal NUMBER, p_departamento NUMBER,p_mgr NUMBER DEFAULT NULL, p_comm NUMBER DEFAULT 0, p_fecha_alta DATE DEFAULT SYSDATE);
    FUNCTION departamento_existe(p_departamento NUMBER) RETURN BOOLEAN;
    FUNCTION verificar_salario(p_sal NUMBER) RETURN BOOLEAN;

    --2) borrar_emple: Al borrar, los empleados que dependían de él pasarán a depender del director del empleado borrado.
    PROCEDURE borrar_emple(p_numero_empleado NUMBER);

    -- 3) modificar_oficio_emple
    PROCEDURE modificar_oficio_emple(p_numero_empleado NUMBER, p_nuevo_oficio VARCHAR2);

    -- 4) modificar_dept_emple
    PROCEDURE modificar_dept_emple(p_numero_empleado NUMBER, p_nuevo_deptno VARCHAR2);

    -- 5) modificar_dir_emple
    PROCEDURE modificar_mgr_emple(p_numero_empleado NUMBER, p_nuevo_mgr NUMBER);

    -- 6) modificar_salario_emple
    PROCEDURE modificar_salario_emple(p_numero_empleado NUMBER, p_nuevo_sal NUMBER);

    -- 7) modificar_comision_emple
    PROCEDURE modificar_comm_emple(p_numero_empleado NUMBER, p_nueva_comm NUMBER);

    -- 8) visualizar_datos_emple (sobrecargados)
    PROCEDURE visibilizar_datos_emple_por_numero(p_numero_empleado NUMBER);
    PROCEDURE visibilizar_datos_emple_por_nombre(p_nombre_empleado VARCHAR2);
    FUNCTION empleado_existe(p_numero_empleado NUMBER) RETURN BOOLEAN;

    -- 9) buscar_emple_por_nombre (Función)
    FUNCTION buscar_emple_por_nombre(p_nombre_empleado VARCHAR2) RETURN NUMBER;

    -- 10) subida_salario_pct: Sube salario según porcentaje, no puede ser superior al 25%
    PROCEDURE subida_salario_pct(p_porcentaje NUMBER);

    -- 11) subida_salario_imp: suma salario de empleados el importe, no puede ser superior al 25% del salario medio
    PROCEDURE subida_salario_imp(p_importe NUMBER);
END pkg_gest_emple;
/
-------------------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY pkg_gest_emple IS
    --1) insertar_nuevo_emple
    PROCEDURE insertar_nuevo_emple(p_numero_empleado NUMBER, p_nombre VARCHAR2, p_job VARCHAR2, p_sal NUMBER, p_departamento NUMBER,p_mgr NUMBER DEFAULT NULL, p_comm NUMBER DEFAULT 0, p_fecha_alta DATE DEFAULT SYSDATE) IS

    -- Verificar existencia de departamento y monto salario
    v_departamento_existe BOOLEAN := DEPARTAMENTO_EXISTE(p_departamento);
    v_salario_en_rango BOOLEAN := VERIFICAR_SALARIO(p_sal);
    v_empleado_existe BOOLEAN := EMPLEADO_EXISTE(p_numero_empleado);

    BEGIN
        IF v_empleado_existe THEN
            RAISE ex_empleado_existe; --> si existe, lanzamos la excepción
        END IF;

        IF NOT v_departamento_existe THEN
            RAISE ex_departamento_no_existe; --> si no existe, lanzamos la excepción
        ELSIF NOT v_salario_en_rango THEN
            RAISE ex_salario_excesivo; --> si no está en rango, lanzamos la excepción
        ELSE
            -- Si se cumple todo, insertamos el nuevo empleado
            INSERT INTO EMP(EMPNO, ENAME, JOB, MGR, SAL, COMM, DEPTNO, HIREDATE)
            VALUES (p_numero_empleado, p_nombre, p_job, p_mgr, p_sal, p_comm, p_departamento, p_fecha_alta);
            DBMS_OUTPUT.PUT_LINE('Nuevo empleado ingresado correctamente');
            DBMS_OUTPUT.PUT_LINE(LPAD('-',40, '-'));
            DBMS_OUTPUT.PUT_LINE(RPAD('-> N° Empleado: ', 20) || ' | '|| TO_CHAR(p_numero_empleado, '9999'));
            DBMS_OUTPUT.PUT_LINE(RPAD('-> Nombre: ', 20) || ' |  '|| p_nombre);
            DBMS_OUTPUT.PUT_LINE(RPAD('-> Trabajo: ', 20) || ' |  ' || p_job);
            DBMS_OUTPUT.PUT_LINE(RPAD('-> N° jefe directo: ', 20) || ' | ' || TO_CHAR(p_mgr, '9999'));
            DBMS_OUTPUT.PUT_LINE(RPAD('-> Salario: € ', 20) || ' | '|| TO_CHAR(p_sal, '9999.99'));
            DBMS_OUTPUT.PUT_LINE(RPAD('-> Comisión: € ', 20) || ' | ' || TO_CHAR(p_comm, '9999.99'));
            DBMS_OUTPUT.PUT_LINE(RPAD('-> Número departamento: ', 20) || ' | ' || TO_CHAR(p_departamento, '99'));
            DBMS_OUTPUT.PUT_LINE(RPAD('-> Fecha de alta: ', 20) || ' | ' || TO_CHAR(p_fecha_alta, 'DD-MM-YYYY'));
        END IF;

        COMMIT;
    EXCEPTION
        WHEN ex_empleado_existe THEN
            DBMS_OUTPUT.PUT_LINE('Error: El número de empleado ' || TO_CHAR(p_numero_empleado) ||' ya existe. Vuelva a intentar el ingreso');
        WHEN ex_departamento_no_existe THEN
            DBMS_OUTPUT.PUT_LINE('Error: El departamento ' || TO_CHAR(p_departamento) ||' no existe. Vuelva a intentar el ingreso');
        WHEN ex_salario_excesivo THEN
            DBMS_OUTPUT.PUT_LINE('Error: El salario ingresado es excesivo, revise nuevamente y vuelva a intentarlo: € ' || TO_CHAR(p_sal));
        WHEN OTHERS THEN ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
    END insertar_nuevo_emple;

    -- Función para verificar si el departamento existe antes de insertar al empleado
    FUNCTION departamento_existe(p_departamento NUMBER) RETURN BOOLEAN IS
        v_departamento DEPT.DEPTNO%TYPE;
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
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END;

    -- Función para verificar que el salario no sea superior al máximo, antes de insertar al empleado
    FUNCTION verificar_salario(p_sal NUMBER) RETURN BOOLEAN IS
        v_salario NUMBER;
        v_salario_en_rango BOOLEAN;
    BEGIN
        --Tomamos el valor máximo de salario existente
        SELECT NVL(MAX(SAL),0) INTO v_salario FROM EMP;

        IF p_sal <= v_salario THEN
            v_salario_en_rango := TRUE;
        ELSE
            v_salario_en_rango := FALSE;
        END IF;
        RETURN v_salario_en_rango;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END;

--------------------------------------------------
    --2) borrar_emple: Al borrar, los empleados que dependían de él pasarán a depender del director del empleado borrado.
    PROCEDURE borrar_emple(p_numero_empleado NUMBER) IS-- revisar
        v_superior EMP.MGR%TYPE;
        v_empleado_existe BOOLEAN := EMPLEADO_EXISTE(p_numero_empleado);
        v_nombre_empleado_a_borrar EMP.ENAME%TYPE;
        v_nombre_jefe_superior EMP.ENAME%TYPE;

    BEGIN
        IF NOT v_empleado_existe THEN
            RAISE ex_empleado_no_existe; --> si no existe, lanzamos la excepción
        ElSE
            -- Obtengo el nombre del empleado a borrar y su jefe superior
            SELECT ENAME, MGR INTO v_nombre_empleado_a_borrar, v_superior
            FROM EMP WHERE EMPNO = p_numero_empleado;

            -- Obtengo el nombre del jefe superior
            SELECT ENAME INTO v_nombre_jefe_superior
            FROM EMP WHERE EMPNO = v_superior;

            -- Si el empleado tiene un jefe superior, se le asignará este a sus empleados a cargo en su reemplazo
            IF v_superior IS NOT NULL THEN
                -- Reasignamos a los empleados a su nuevo jefe
                UPDATE EMP
                SET MGR = v_superior
                WHERE MGR = p_numero_empleado;

                -- Una vez reasignado, se elimina el empleado
                DELETE FROM EMP
                WHERE EMPNO = p_numero_empleado;

                DBMS_OUTPUT.PUT_LINE('Empleado N° ' || TO_CHAR(p_numero_empleado) || ' eliminado exitosamente:');
                DBMS_OUTPUT.PUT_LINE(LPAD('-',83, '-'));
                DBMS_OUTPUT.PUT_LINE('-> Nombre: ' || v_nombre_empleado_a_borrar);
                DBMS_OUTPUT.NEW_LINE;
                DBMS_OUTPUT.PUT_LINE('IMPORTANTE -> Los empleados que tenia asignados ' || v_nombre_empleado_a_borrar ||' pasarán a cargo de su jefe superior: ');
                DBMS_OUTPUT.NEW_LINE;
                DBMS_OUTPUT.PUT_LINE(RPAD('-> Nuevo Jefe: ', 17) || v_nombre_jefe_superior);
                DBMS_OUTPUT.PUT_LINE(RPAD('-> N° Empleado: ', 17) || TO_CHAR(v_superior, '9999'));
            ELSE
                -- Se elimina el empleado
                DELETE FROM EMP
                WHERE EMPNO = p_numero_empleado;

                DBMS_OUTPUT.PUT_LINE('Empleado N° ' || TO_CHAR(p_numero_empleado) || ' eliminado: exitosamente:');
                DBMS_OUTPUT.PUT_LINE(LPAD('-',83, '-'));
                DBMS_OUTPUT.PUT_LINE('-> Nombre: ' || v_nombre_empleado_a_borrar);
                DBMS_OUTPUT.NEW_LINE;
                DBMS_OUTPUT.PUT_LINE('IMPORTANTE -> ' || v_nombre_empleado_a_borrar || ' no tuvo empleados a su cargo...');
            END IF;
        END IF;
    EXCEPTION
    WHEN ex_empleado_no_existe THEN
        DBMS_OUTPUT.PUT_LINE('Error: El empleado N° ' || TO_CHAR(p_numero_empleado) || ' no existe');
    WHEN OTHERS THEN ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
    END borrar_emple;

--------------------------------------------------
    -- 3) modificar_oficio_emple
    PROCEDURE modificar_oficio_emple(p_numero_empleado NUMBER, p_nuevo_oficio VARCHAR2) IS
        v_nombre_empleado EMP.ENAME%TYPE;
    BEGIN
    -- Verificamos si el empleado existe antes de actualizar el oficio
        SELECT ENAME INTO v_nombre_empleado
        FROM EMP WHERE EMPNO = p_numero_empleado;

    -- Actualizamos el oficio del empleado
        UPDATE EMP
        SET JOB = p_nuevo_oficio
        WHERE EMPNO = p_numero_empleado;

        DBMS_OUTPUT.PUT_LINE('Oficio actualizado correctamente: ');
        DBMS_OUTPUT.PUT_LINE(LPAD('-',40, '-'));
        DBMS_OUTPUT.PUT_LINE(RPAD('Nombre empleado: ',20) || v_nombre_empleado);
        DBMS_OUTPUT.PUT_LINE(RPAD('Numero empleado: ',20) || TO_CHAR(p_numero_empleado));
        DBMS_OUTPUT.PUT_LINE(RPAD('Nuevo oficio: ',20) || p_nuevo_oficio);

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE(' El empleado con número ' || TO_CHAR(p_numero_empleado) || ' no existe');
        WHEN OTHERS THEN ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
    END modificar_oficio_emple;

--------------------------------------------------
    -- 4) modificar_dept_emple
    PROCEDURE modificar_dept_emple(p_numero_empleado NUMBER, p_nuevo_deptno VARCHAR2) IS
        v_nombre_empleado EMP.ENAME%TYPE;
    BEGIN
    -- Verificamos si el empleado existe antes de actualizar el departamento
        SELECT ENAME INTO v_nombre_empleado
        FROM EMP WHERE EMPNO = p_numero_empleado;

    -- Actualizamos el departamento del empleado
        UPDATE EMP
        SET DEPTNO = p_nuevo_deptno
        WHERE EMPNO = p_numero_empleado;

        DBMS_OUTPUT.PUT_LINE('Departamento actualizado correctamente: ');
        DBMS_OUTPUT.PUT_LINE(LPAD('-',40, '-'));
        DBMS_OUTPUT.PUT_LINE(RPAD('Nombre empleado: ',20) || v_nombre_empleado);
        DBMS_OUTPUT.PUT_LINE(RPAD('Numero empleado: ',20) || TO_CHAR(p_numero_empleado));
        DBMS_OUTPUT.PUT_LINE(RPAD('Nuevo departamento: ',20) || TO_CHAR(p_nuevo_deptno));

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE(' El empleado con número ' || TO_CHAR(p_numero_empleado) || ' no existe');
        WHEN OTHERS THEN ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
    END modificar_dept_emple;

--------------------------------------------------
    -- 5) modificar_dir_emple
    PROCEDURE modificar_mgr_emple(p_numero_empleado NUMBER, p_nuevo_mgr NUMBER) IS
        v_nombre_empleado EMP.ENAME%TYPE;
        v_nombre_superior EMP.ENAME%TYPE;
    BEGIN
    -- Verificamos si el empleado existe antes de actualizar el nuevo jefe
        SELECT ENAME INTO v_nombre_empleado
        FROM EMP WHERE EMPNO = p_numero_empleado;

    -- Verificamos si el superior existe antes de actualizar el nuevo jefe
        SELECT ENAME INTO v_nombre_superior
        FROM EMP WHERE EMPNO = p_nuevo_mgr;

    -- Actualizamos el nuevo jefe del empleado
        UPDATE EMP
        SET mgr = p_nuevo_mgr
        WHERE EMPNO = p_numero_empleado;

        DBMS_OUTPUT.PUT_LINE('Nuevo Superior actualizado correctamente: ');
        DBMS_OUTPUT.PUT_LINE(LPAD('-',40, '-'));
        DBMS_OUTPUT.PUT_LINE(RPAD('Nombre empleado: ',20) || v_nombre_empleado);
        DBMS_OUTPUT.PUT_LINE(RPAD('Numero empleado: ',20) || TO_CHAR(p_numero_empleado));
        DBMS_OUTPUT.PUT_LINE(RPAD('Nombre Superior : ',20) || v_nombre_superior);
        DBMS_OUTPUT.PUT_LINE(RPAD('Número Superior : ',20) || TO_CHAR(p_nuevo_mgr));

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: El empleado o el jefe no existen (Empleado: ' || TO_CHAR(p_numero_empleado) || ', Jefe: ' || TO_CHAR(p_nuevo_mgr) || ').');
        WHEN OTHERS THEN ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
    END modificar_mgr_emple;

--------------------------------------------------

    -- 6) modificar_salario_emple
    PROCEDURE modificar_salario_emple(p_numero_empleado NUMBER, p_nuevo_sal NUMBER) IS
        v_nombre_empleado EMP.ENAME%TYPE;
    BEGIN
    -- Verificamos si el empleado existe antes de actualizar el salario
        SELECT ENAME INTO v_nombre_empleado
        FROM EMP WHERE EMPNO = p_numero_empleado;

    -- Actualizamos el salario del empleado
        UPDATE EMP
        SET SAL = p_nuevo_sal
        WHERE EMPNO = p_numero_empleado;

        DBMS_OUTPUT.PUT_LINE('Salario actualizado correctamente: ');
        DBMS_OUTPUT.PUT_LINE(LPAD('-',40, '-'));
        DBMS_OUTPUT.PUT_LINE(RPAD('Nombre empleado: ',20) || v_nombre_empleado);
        DBMS_OUTPUT.PUT_LINE(RPAD('Numero empleado: ',20) || TO_CHAR(p_numero_empleado));
        DBMS_OUTPUT.PUT_LINE(RPAD('Nuevo salario: ',20) || '€ ' || TO_CHAR(p_nuevo_sal));

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE(' El empleado con número ' || TO_CHAR(p_numero_empleado) || ' no existe');
        WHEN OTHERS THEN ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
    END modificar_salario_emple;

--------------------------------------------------

    -- 7) modificar_comision_emple
    PROCEDURE modificar_comm_emple(p_numero_empleado NUMBER, p_nueva_comm NUMBER)IS
        v_nombre_empleado EMP.ENAME%TYPE;
    BEGIN
    -- Verificamos si el empleado existe antes de actualizar la comisión
        SELECT ENAME INTO v_nombre_empleado
        FROM EMP WHERE EMPNO = p_numero_empleado;

    -- Actualizamos el comisión del empleado
        UPDATE EMP
        SET COMM = NVL(p_nueva_comm,0)
        WHERE EMPNO = p_numero_empleado;

        DBMS_OUTPUT.PUT_LINE('Comisión actualizada correctamente: ');
        DBMS_OUTPUT.PUT_LINE(LPAD('-',40, '-'));
        DBMS_OUTPUT.PUT_LINE(RPAD('Nombre empleado: ',20) || v_nombre_empleado);
        DBMS_OUTPUT.PUT_LINE(RPAD('Numero empleado: ',20) || TO_CHAR(p_numero_empleado));
        DBMS_OUTPUT.PUT_LINE(RPAD('Nueva comisión: ',20) || '€ '|| TO_CHAR(p_nueva_comm));

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE(' Error: El empleado con número ' || p_numero_empleado || ' no existe');
        WHEN OTHERS THEN ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
    END modificar_comm_emple;

--------------------------------------------------

    -- 8) visualizar_datos_emple por número (sobrecarga)
    PROCEDURE visibilizar_datos_emple_por_numero(p_numero_empleado NUMBER) IS
        v_nombre EMP.ENAME%TYPE;
        v_job EMP.ENAME%TYPE;
        v_mgr EMP.MGR%TYPE;
        v_sal EMP.SAL%TYPE;
        v_comm EMP.COMM%TYPE;
        v_deptno EMP.DEPTNO%TYPE;
        v_hiredate EMP.HIREDATE%TYPE;
    BEGIN
        -- Obtenemos los datos a mostrar del empleado
        SELECT ENAME, JOB, MGR, SAL, NVL(COMM,0) COMM, DEPTNO,HIREDATE INTO v_nombre, v_job, v_mgr, v_sal, v_comm, v_deptno, v_hiredate
        FROM EMP WHERE EMPNO = p_numero_empleado;

        IF empleado_existe(p_numero_empleado) THEN
            --Para mostrarlos por pantalla
            DBMS_OUTPUT.PUT_LINE('Los datos del empleado N° '|| TO_CHAR(p_numero_empleado) || ' son los siguientes: ');
            DBMS_OUTPUT.PUT_LINE(LPAD('-',53, '-'));
            DBMS_OUTPUT.PUT_LINE(RPAD('Nombre: ',20) || v_nombre);
            DBMS_OUTPUT.PUT_LINE(RPAD('Oficio: ',20) || v_job);
            DBMS_OUTPUT.PUT_LINE(RPAD('Superior: ',20) || TO_CHAR(v_mgr));
            DBMS_OUTPUT.PUT_LINE(RPAD('Salario: ',20) || '€ ' ||TO_CHAR(v_sal));
            DBMS_OUTPUT.PUT_LINE(RPAD('Comisión: ',20) || '€ ' ||TO_CHAR(v_comm));
            DBMS_OUTPUT.PUT_LINE(RPAD('Departamento: ',20) || TO_CHAR(v_deptno));
            DBMS_OUTPUT.PUT_LINE(RPAD('Fecha Alta: ',20) || TO_CHAR(v_hiredate, 'DD-MM-YYYY'));
        ELSE
            RAISE ex_empleado_no_existe;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: No se encontró el empleado N° ' || TO_CHAR(p_numero_empleado));
        WHEN ex_empleado_no_existe THEN
            DBMS_OUTPUT.PUT_LINE('Error: El empleado N° ' || TO_CHAR(p_numero_empleado) || ' no existe');
    END visibilizar_datos_emple_por_numero;


    -- 8) visualizar_datos_emple por nombre (sobrecarga)
    PROCEDURE visibilizar_datos_emple_por_nombre(p_nombre_empleado VARCHAR2) IS
        v_numero_empleado EMP.EMPNO%TYPE;
        v_job EMP.ENAME%TYPE;
        v_mgr EMP.MGR%TYPE;
        v_sal EMP.SAL%TYPE;
        v_comm EMP.COMM%TYPE;
        v_deptno EMP.DEPTNO%TYPE;
        v_hiredate EMP.HIREDATE%TYPE;
    BEGIN
        -- Obtenemos el numero de empleado mediante función
        v_numero_empleado := BUSCAR_EMPLE_POR_NOMBRE(p_nombre_empleado);

        -- Obtenemos los datos a mostrar del empleado
        SELECT JOB, MGR, SAL, NVL(COMM,0) COMM, DEPTNO,HIREDATE INTO v_job, v_mgr, v_sal, v_comm, v_deptno, v_hiredate
        FROM EMP WHERE ENAME = p_nombre_empleado;

        IF empleado_existe(v_numero_empleado) THEN
            --Para mostrarlos por pantalla
            DBMS_OUTPUT.PUT_LINE('Los datos del empleado '|| p_nombre_empleado || ' son los siguientes: ');
            DBMS_OUTPUT.PUT_LINE(LPAD('-',53, '-'));
            DBMS_OUTPUT.PUT_LINE(RPAD('N° Empleado: ',20) || TO_CHAR(v_numero_empleado));
            DBMS_OUTPUT.PUT_LINE(RPAD('Oficio: ',20) || v_job);
            DBMS_OUTPUT.PUT_LINE(RPAD('Superior: ',20) || TO_CHAR(v_mgr));
            DBMS_OUTPUT.PUT_LINE(RPAD('Salario: ',20) || '€ ' ||TO_CHAR(v_sal));
            DBMS_OUTPUT.PUT_LINE(RPAD('Comisión: ',20) || '€ ' ||TO_CHAR(v_comm));
            DBMS_OUTPUT.PUT_LINE(RPAD('Departamento: ',20) || TO_CHAR(v_deptno));
            DBMS_OUTPUT.PUT_LINE(RPAD('Fecha Alta: ',20) || TO_CHAR(v_hiredate, 'DD-MM-YYYY'));
        ELSE
            RAISE ex_empleado_no_existe;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: No se encontró el empleado de nombre ' || p_nombre_empleado);
        WHEN ex_empleado_no_existe THEN
            DBMS_OUTPUT.PUT_LINE('Error: El empleado de nombre ' || p_nombre_empleado || ' no existe');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
    END visibilizar_datos_emple_por_nombre;

    -- Función para evaluar si el empleado existe
    FUNCTION empleado_existe(p_numero_empleado NUMBER) RETURN BOOLEAN IS
        v_empleado NUMBER;
        v_empleado_existe BOOLEAN;
    BEGIN
        -- Verificamos si existe el departamento ingresado
        SELECT COUNT(EMPNO) INTO v_empleado
        FROM EMP WHERE EMPNO = p_numero_empleado;

        IF v_empleado > 0 THEN
            v_empleado_existe := TRUE;
        ELSE
            v_empleado_existe := FALSE;
        END IF;

        RETURN v_empleado_existe;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN FALSE;
    END empleado_existe;

--------------------------------------------------
    -- 9) buscar_emple_por_nombre (Función)
    FUNCTION buscar_emple_por_nombre(p_nombre_empleado VARCHAR2) RETURN NUMBER IS
        v_numero_empleado EMP.EMPNO%TYPE;
    BEGIN
            SELECT EMPNO INTO v_numero_empleado
            FROM EMP WHERE ENAME = p_nombre_empleado;

            RETURN v_numero_empleado;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
        WHEN OTHERS THEN
            RETURN NULL;
    END buscar_emple_por_nombre;

--------------------------------------------------
    -- 10) subida_salario_pct: Sube salario según porcentaje, no puede ser superior al 25%
    PROCEDURE subida_salario_pct(p_porcentaje NUMBER) IS
        CURSOR C1 IS SELECT * FROM EMP;
        CC1 C1%ROWTYPE;
        v_subida_final NUMBER;
    BEGIN
        IF p_porcentaje > 25 THEN
            RAISE ex_porcentaje_excesivo;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Aumento salarial del ' || TO_CHAR(p_porcentaje) || ' % a los empleados: ');
            DBMS_OUTPUT.PUT_LINE(LPAD('-',53, '-'));
            OPEN C1;
            LOOP
                FETCH C1 INTO CC1;
                EXIT WHEN C1%NOTFOUND;

                DBMS_OUTPUT.PUT_LINE(RPAD('Empleado: ',20) || CC1.ENAME);
                DBMS_OUTPUT.PUT_LINE(RPAD('Salario antiguo: ',20) || '€ ' || TO_CHAR(CC1.SAL,'9999.99'));

                v_subida_final := CC1.SAL + (CC1.SAL * (p_porcentaje / 100));

                UPDATE EMP
                SET SAL = v_subida_final
                WHERE EMPNO = CC1.EMPNO;

                DBMS_OUTPUT.PUT_LINE(RPAD('Salario actual: ',20) || '€ ' ||TO_CHAR(v_subida_final,'9999.99'));
                DBMS_OUTPUT.NEW_LINE;
            END LOOP;
            CLOSE C1;
        END IF;

        COMMIT;
    EXCEPTION
        WHEN ex_porcentaje_excesivo THEN
            DBMS_OUTPUT.PUT_LINE('Error: El porcentaje de aumento salarial no puede ser superior al 25%');
        WHEN OTHERS THEN ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
    END subida_salario_pct;

--------------------------------------------------

    -- 11) subida_salario_imp: suma salario de empleados el importe, no puede ser superior al 25% del salario medio
    PROCEDURE subida_salario_imp(p_importe NUMBER) IS
        CURSOR C1 IS SELECT * FROM EMP;
        CC1 C1%ROWTYPE;
        v_subida_final NUMBER;
        v_salario_medio NUMBER;
        v_porcentaje_salario_medio NUMBER;
    BEGIN
        -- Obtenemos el salario medio de los empleados
        SELECT AVG(SAL) INTO v_salario_medio FROM EMP;

        -- Calculamos el 25% del salario medio, que será el tope para realizar los aumentos salariales
        v_porcentaje_salario_medio := v_salario_medio * 0.25;

        -- Si el importe es mayor al 25% del salario medio, lanza la excepción
        IF p_importe > v_porcentaje_salario_medio THEN
            RAISE ex_importe_excesivo;
        ELSE
            -- Si cumple el importe, se realiza
            DBMS_OUTPUT.PUT_LINE('Aumento salarial a los empleados, mediante importe de € ' || TO_CHAR(p_importe) || ' : ');
            DBMS_OUTPUT.PUT_LINE(LPAD('-',53, '-'));
            OPEN C1;
            LOOP
                FETCH C1 INTO CC1;
                EXIT WHEN C1%NOTFOUND;

                DBMS_OUTPUT.PUT_LINE(RPAD('Empleado: ',20) || CC1.ENAME);
                DBMS_OUTPUT.PUT_LINE(RPAD('Salario antiguo: ',20) || '€ ' || TO_CHAR(CC1.SAL,'9999.99'));

                v_subida_final := CC1.SAL + p_importe;

                UPDATE EMP
                SET SAL = v_subida_final
                WHERE EMPNO = CC1.EMPNO;

                DBMS_OUTPUT.PUT_LINE(RPAD('Salario actual: ',20) || '€ ' ||TO_CHAR(v_subida_final, '9999.99'));
                DBMS_OUTPUT.NEW_LINE;
            END LOOP;
            CLOSE C1;
        END IF;

        COMMIT;
    EXCEPTION
        WHEN ex_importe_excesivo THEN
            DBMS_OUTPUT.PUT_LINE('Error: El importe no puede superar el 25% del salario medio de los empleados');
        WHEN OTHERS THEN ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: No se pudo realizar la operación ' || SQLERRM);
    END subida_salario_imp;
END pkg_gest_emple;
/


-- Realizando pruebas para ver el funcionamiento del package

--1)insertar_nuevo_emple:
-- empleado válido (Funciona)
EXECUTE PKG_GEST_EMPLE.insertar_nuevo_emple(8000,'JUAN','ANALYST',3000,20,7566,NULL,SYSDATE);
-- empleado con un número ya existente (funciona)
EXECUTE PKG_GEST_EMPLE.insertar_nuevo_emple(7369,'MARIA','CLERK',1500,10);
-- empleado con salario excesivo (funciona)
EXECUTE PKG_GEST_EMPLE.insertar_nuevo_emple(8001,'MARIA','CLERK',8000,10);
-- empleado con un departamento inexistente (funciona)
EXECUTE PKG_GEST_EMPLE.insertar_nuevo_emple(8000,'MARIA','CLERK',1500,90);

------------------------------------------------------------
--2) borrar_emple:
-- empleado existente (funciona)
EXECUTE PKG_GEST_EMPLE.borrar_emple(8000);
-- empleado inexistente (funciona)
EXECUTE PKG_GEST_EMPLE.borrar_emple(9999);

------------------------------------------------------------
-- 3) modificar_oficio_emple
-- empleado existente (funciona)
EXECUTE PKG_GEST_EMPLE.modificar_oficio_emple(6616, 'MANAGER');
-- empleado inexistente (funciona)
EXECUTE PKG_GEST_EMPLE.modificar_oficio_emple(9999, 'SALESMAN');

------------------------------------------------------------
-- 4) modificar_dept_emple
-- empleado existente (funciona)
EXECUTE PKG_GEST_EMPLE.modificar_dept_emple(6616, 40);
-- empleado inexistente (funciona)
EXECUTE PKG_GEST_EMPLE.modificar_dept_emple(9999, 70);

------------------------------------------------------------
-- 5) modificar_dir_emple
-- empleado existente (funciona)
EXECUTE PKG_GEST_EMPLE.modificar_mgr_emple(7949, 6616);
-- empleado inexistente (funciona)
EXECUTE PKG_GEST_EMPLE.modificar_mgr_emple(9999, 7839);

------------------------------------------------------------
-- 6) modificar_salario_emple
-- empleado existente (funciona)
EXECUTE PKG_GEST_EMPLE.modificar_salario_emple(7949, 4100);

-- empleado inexistente (funciona)
EXECUTE PKG_GEST_EMPLE.modificar_salario_emple(9999, 5000);

------------------------------------------------------------
-- 7) modificar_comision_emple
-- empleado existente (funciona)
EXECUTE PKG_GEST_EMPLE.modificar_comm_emple(7949, 200);
-- empleado inexistente (funciona)
EXECUTE PKG_GEST_EMPLE.modificar_comm_emple(9999, 300);

------------------------------------------------------------
-- 8) visualizar_datos_emple (sobrecarga de ambos procedimientos)

-- a) Por número
-- empleado existente (funciona)
EXECUTE PKG_GEST_EMPLE.visibilizar_datos_emple_por_numero(7369);
-- empleado inexistente (funciona)
EXECUTE PKG_GEST_EMPLE.visibilizar_datos_emple_por_numero(9999);

--b) Por nombre
-- empleado existente (funciona)
EXECUTE PKG_GEST_EMPLE.visibilizar_datos_emple_por_nombre('SMITH');
-- empleado inexistente (funciona)
EXECUTE PKG_GEST_EMPLE.visibilizar_datos_emple_por_nombre('JUAN');

------------------------------------------------------------
-- 9) buscar_emple_por_nombre
-- empleado existente (funciona)
DECLARE
    v_empno NUMBER;
BEGIN
    v_empno := PKG_GEST_EMPLE.buscar_emple_por_nombre('KING');
    DBMS_OUTPUT.PUT_LINE('Número de empleado: ' || TO_CHAR(v_empno));
END;

-- empleado inexistente (funciona)
DECLARE
    v_empno NUMBER;
BEGIN
    v_empno := PKG_GEST_EMPLE.buscar_emple_por_nombre('JUAN');
    IF v_empno IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('El empleado no existe.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Número de empleado: ' || TO_CHAR(v_empno));
    END IF;
END;

------------------------------------------------------------
-- 10) subida_salario_pct
-- Todos los empleados en un 1% (funciona)
EXECUTE PKG_GEST_EMPLE.subida_salario_pct(1);
-- porcentaje superior al 25% (funciona)
EXECUTE PKG_GEST_EMPLE.subida_salario_pct(30);

------------------------------------------------------------
-- 11) subida_salario_imp
-- empleados en 10 euros (funciona)
EXECUTE PKG_GEST_EMPLE.subida_salario_imp(10);
-- importe que exceda el 25% del salario medio (funciona)
EXECUTE PKG_GEST_EMPLE.subida_salario_imp(2000);

------------------------------------------------------------