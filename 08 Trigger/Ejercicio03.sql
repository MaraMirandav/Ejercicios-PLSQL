--3.- Escribir un disparador de base de datos que haga fallar cualquier operación de modificación del apellido o del número de un empleado, o que suponga una subida de sueldo superior al 10%.

-- Función para revisar el rango de subida salarial
CREATE OR REPLACE FUNCTION subida_salarial_en_rango(new_sal NUMBER, old_sal NUMBER) RETURN BOOLEAN IS
    v_incremento NUMBER;
    v_maxima_subida NUMBER;
    v_subida_en_rango BOOLEAN;
BEGIN
    -- Calculo de subida salarial del 10% para tomar como medida al evaluar
    v_incremento := old_sal * 0.10;
    v_maxima_subida := old_sal + v_incremento;

    -- Verificamos si el nuevo salario está dentro del rango
    IF new_sal > v_maxima_subida THEN
        v_subida_en_rango := FALSE;
    ELSE
        v_subida_en_rango := TRUE;
    END IF;

    RETURN v_subida_en_rango;
END;
/

-- Trigger
CREATE OR REPLACE TRIGGER trg_revisar_fallos_update
BEFORE UPDATE ON EMP
FOR EACH ROW
DECLARE
    --Boolean para revisar la subida salarial
    v_verificar_subida_salarial BOOLEAN;
    -- Excepciones para controlar los fallos
    ex_subida_salarial_excesiva EXCEPTION;
    ex_intento_cambio_apellido EXCEPTION;
    ex_intento_cambio_numero_empleado EXCEPTION;
BEGIN
    v_verificar_subida_salarial := SUBIDA_SALARIAL_EN_RANGO(:NEW.SAL, :OLD.SAL);
    --Evalua Salario: aumento no puede superar el 10%.
    IF NOT v_verificar_subida_salarial THEN
        RAISE ex_subida_salarial_excesiva;
    END IF;

    --Evalua cambio apellido: No se puede modificar
    IF :OLD.ENAME != :NEW.ENAME THEN
        RAISE ex_intento_cambio_apellido;
    END IF;

    --Evalua cambio numero empleado: No se puede modificar
    IF :OLD.EMPNO != :NEW.EMPNO THEN
        RAISE ex_intento_cambio_numero_empleado;
    END IF;
EXCEPTION
    WHEN ex_subida_salarial_excesiva THEN
        RAISE_APPLICATION_ERROR(-20001, 'El aumento de salario no puede superar el 10% permitido');
    WHEN ex_intento_cambio_apellido THEN
        RAISE_APPLICATION_ERROR(-20002, 'No está permitido modificar el apellido del empleado');
    WHEN ex_intento_cambio_numero_empleado THEN
        RAISE_APPLICATION_ERROR(-20003,'No está permitido modificar el número del empleado');
END;
/

-- Realizando pruebas para ver el funcionamiento del trigger
--Modificación excesiva de salario(20%)
UPDATE EMP
SET SAL = SAL * 1.20
WHERE EMPNO = 7369;

--Modificación de nombre (no permitido)
UPDATE EMP
SET ENAME = 'SMITH'
WHERE EMPNO = 6616;

--Modificación de numero empleado (no permitido)
UPDATE EMP
SET EMPNO = 1021
WHERE EMPNO = 7949;

SELECT * FROM auditar_empleados;
select * from emp;
