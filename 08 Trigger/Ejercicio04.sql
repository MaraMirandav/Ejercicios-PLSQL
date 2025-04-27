-- c) Ejemplo de como crear un trigger a partir de una vista.

-- 4.- Suponiendo que disponemos de la vista
    -- CREATE VIEW DEPARTAM AS
    -- SELECT DEPART.DEPT_NO, DNOMBRE, LOC, COUNT(EMP_NO) TOT_EMPLE
    -- FROM EMPLE, DEPART 5
    -- WHERE EMPLE.DEPT_NO (+) = DEPART.DEPT_NO
    -- GROUP BY DEPART.DEPT_NO, DNOMBRE, LOC;

-- Construir un disparador que permita realizar operaciones de actualización en la tabla depart a partir de la vista dptos, de forma similar al ejemplo del trigger t_ges_emplead. Se contemplarán las siguientes operaciones:
    -- Insertar departamento.
    -- Borrar departamento.
    -- Modificar la localidad de un departamento.

SET SERVEROUTPUT ON

-- VISTA -> Adaptada para poder hacer el ejercicio con bd_scott:
CREATE OR REPLACE VIEW DEPARTAM AS
SELECT DEPT.DEPTNO, DEPT.DNAME, DEPT.LOC, COUNT(EMP.EMPNO) TOT_EMP, NVL(ROUND(SUM(EMP.SAL), 2), 0) TOT_SAL
FROM EMP, DEPT
WHERE EMP.DEPTNO (+) = DEPT.DEPTNO
GROUP BY DEPT.DEPTNO, DNAME, LOC
ORDER BY TOT_EMP DESC;

SELECT * from DEPARTAM;

-- Trigger
CREATE OR REPLACE TRIGGER trg_gestion_departamentos
INSTEAD OF INSERT OR DELETE OR UPDATE ON DEPARTAM
FOR EACH ROW
DECLARE
    v_numero_departamento_existe BOOLEAN;

    -- Excepciones
    ex_departamento_existente_insert EXCEPTION;
    ex_departamento_no_existe_delete EXCEPTION;
    ex_departamento_no_existe_update EXCEPTION;

BEGIN
    -- INSERTAR DEPARTAMENTO
    IF INSERTING THEN
        -- Utilizamos función DEPARTAMENTO EXISTE, creada en ejercicios anteriores
        v_numero_departamento_existe := DEPARTAMENTO_EXISTE(:NEW.DEPTNO);

        -- Si el departamento no existe, inserta los datos nuevos
        IF NOT v_numero_departamento_existe THEN
            INSERT INTO DEPT(DEPTNO, DNAME, LOC)
            VALUES (:NEW.DEPTNO, :NEW.DNAME, :NEW.LOC);
        ELSE
            -- Lanza excepción si el número de departamento existe
            RAISE ex_departamento_existente_insert;
        END IF;
    END IF;

    -- DELETE DEPARTAMENTO
    IF DELETING THEN
        -- Utilizamos función DEPARTAMENTO EXISTE, creada en ejercicios anteriores
        v_numero_departamento_existe := DEPARTAMENTO_EXISTE(:OLD.DEPTNO);

        -- Si el departamento existe, elimina el departamento
        IF v_numero_departamento_existe THEN
            DELETE FROM DEPT
            WHERE DEPTNO = :OLD.DEPTNO;
        ELSE
        -- Si el departamento no existe, lanza la excepción
            RAISE ex_departamento_no_existe_delete;
        END IF;
    END IF;

        -- MODIFICAR LOCALIDAD
    IF UPDATING THEN
        -- Utilizamos función DEPARTAMENTO EXISTE, creada en ejercicios anteriores
        v_numero_departamento_existe := DEPARTAMENTO_EXISTE(:OLD.DEPTNO);

        -- Si el departamento existe, modifica la localidad del departamento
        IF v_numero_departamento_existe THEN
            UPDATE DEPT
            SET LOC = :NEW.LOC
            WHERE DEPTNO = :OLD.DEPTNO;
        ELSE
        -- Si el departamento no existe, lanza la excepción
            RAISE ex_departamento_no_existe_update;
        END IF;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No se encontraron los datos para insertar/Borrar/Actualizar');
    WHEN ex_departamento_existente_insert THEN
        DBMS_OUTPUT.PUT_LINE('El número de departamento ya existe, no puedes insertar los datos');
    WHEN ex_departamento_no_existe_delete THEN
        DBMS_OUTPUT.PUT_LINE('El número de departamento no existe, no puedes eliminar los datos');
    WHEN ex_departamento_no_existe_update THEN
        DBMS_OUTPUT.PUT_LINE('El número de departamento no existe, no puedes modificar la localidad del departamento');
END;
/

-- Realizando pruebas para ver el funcionamiento del trigger
--Insertar departamento (funciona)
INSERT INTO DEPARTAM (DEPTNO, DNAME, LOC)
VALUES (80, 'MARKETING', 'MADRID');

--Insertar departamento ya existente (lanza la excepción)
INSERT INTO DEPARTAM (DEPTNO, DNAME, LOC)
VALUES (10, 'MARKETING', 'MADRID');

------------------------------------------------------------
--Eliminar departamento recién creado (funciona)
DELETE FROM DEPARTAM
WHERE DEPTNO = 80;

--Eliminar departamento que no existe (NO lanza la excepción)
DELETE FROM DEPARTAM
WHERE DEPTNO = 90;

------------------------------------------------------------
--Modificar localidad departamento (funciona)
UPDATE DEPARTAM
SET LOC = 'SEVILLA'
WHERE DEPTNO = 60;

--Modificar departamento que no existe (NO lanza la excepción)
UPDATE DEPARTAM
SET LOC = 'SEVILLA'
WHERE DEPTNO = 90;

------------------------------------------------------------

SELECT * from DEPT;
SELECT * FROM DEPARTAM;

--revisar las excepciones