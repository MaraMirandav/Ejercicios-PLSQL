-- a) Ejemplo de como crear un trigger:

-- 1.- Construir un disparador de base de datos que permita auditar las operaciones de inserción o borrado de datos que se realicen en la tabla emple según las siguientes especificaciones:
    -- En primer lugar se creará desde SQL*Plus la tabla auditaremple con la columna col1 VARCHAR2(200).
    -- Cuando se produzca cualquier manipulación se insertará una fila en dicha tabla que contendrá:
        -- Fecha y hora
        -- Número de empleado
        -- Apellido
        -- La operación de actualización INSERCIÓN o BORRADO

SET SERVEROUTPUT ON

-- Crear la tabla auditar_emp

CREATE TABLE auditar_empleados (
    col1 VARCHAR2(1000)
    );

-- Trigger auditoría
CREATE OR REPLACE TRIGGER trg_auditoria
AFTER INSERT OR DELETE ON EMP
FOR EACH ROW

BEGIN
    IF INSERTING THEN --Insertar datos
        INSERT INTO AUDITAR_EMPLEADOS VALUES(
            TO_CHAR(SYSDATE, 'DD-MM-YYYY - HH24:MI:SS') || ':' ||
            ' Número de empleado -> ' || :NEW.EMPNO ||
            ' Apellido -> ' || :NEW.ENAME || ' Estado -> INSERT'
            );

    ELSIF DELETING THEN -- Borrar datos
        INSERT INTO AUDITAR_EMPLEADOS VALUES(
            TO_CHAR(SYSDATE, 'DD-MM-YYYY - HH24:MI:SS') || ':' ||
            ' Número de empleado -> '|| :OLD.EMPNO || ' ' ||
            ' Apellido -> ' || :OLD.ENAME || ' Estado -> DELETE');
    END IF;
END;
/

-- Realizando pruebas para ver el funcionamiento del trigger
INSERT INTO emp VALUES(6616, 'OVALLE', 'CLERK', null, 5000, null, 50, SYSDATE);
DELETE FROM EMP WHERE EMPNO = 6616;

SELECT * FROM auditar_empleados;
select * from emp;



