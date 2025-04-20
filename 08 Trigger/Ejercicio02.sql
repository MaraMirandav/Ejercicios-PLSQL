-- b) Ejemplo de como crear un trigger cuando actualizamos en la tabla datos:

-- 2.- Escribir un trigger de base de datos un que permita auditar las modificaciones en la tabla empleados insertado en la tabla auditaremple los siguientes datos:
    -- Fecha y hora
    -- Número de empleado
    -- Apellido
    -- La operación de actualización: MODIFICACIÓN.
    -- El valor anterior y el valor nuevo de cada columna modificada. (solo las columnas modificadas)

    CREATE OR REPLACE TRIGGER trg_auditoria_modificaciones
    AFTER UPDATE ON EMP
    FOR EACH ROW
    DECLARE
        v_detalle_modificacion VARCHAR2(500) := '';
    BEGIN
        IF UPDATING THEN -- Modificar Datos
            IF :OLD.JOB != :NEW.JOB THEN
                v_detalle_modificacion := v_detalle_modificacion || ' Oficio modificado: ' || :OLD.JOB || ' a ' ||  :NEW.JOB || ' ';
            END IF;

            IF :OLD.SAL != :NEW.SAL THEN
                v_detalle_modificacion := v_detalle_modificacion || ' Salario modificado: €' || :OLD.SAL || ' a €' || :NEW.SAL || ' ';
            END IF;

            IF :OLD.COMM != :NEW.COMM THEN
                v_detalle_modificacion := v_detalle_modificacion || ' Comisión modificada: €' || NVL(:OLD.COMM,0) || ' a €' || NVL(:NEW.COMM,0) || ' ';
            END IF;

            IF :OLD.DEPTNO != :NEW.DEPTNO THEN
                v_detalle_modificacion := v_detalle_modificacion || 'Departamento modificado:' || :OLD.DEPTNO || ' a ' || :NEW.DEPTNO || ' ';
            END IF;

            INSERT INTO auditar_empleados (col1) VALUES (
                TO_CHAR(SYSDATE, 'DD-MM-YYYY - HH24:MI:SS') || ':' ||
                ' Número de empleado -> ' || :OLD.EMPNO ||
                ' Apellido -> ' || :OLD.ENAME || ' Estado -> UPDATE' ||
                ' Modificación -> ' || v_detalle_modificacion );
        END IF;
    END;
    /

-- Realizando pruebas para ver el funcionamiento del trigger
--Modificamos el oficio
UPDATE EMP
SET JOB = 'SALESMAN'
WHERE EMPNO = 6616;

-- Modificamos la comisión y el salario
UPDATE EMP
SET SAL = 5500, COMM = 300
WHERE EMPNO = 6616;


SELECT * FROM auditar_empleados;
select * from emp;
