-- 5) Dado el siguiente procedimiento:
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE crear_depart (
    v_num_dept dept.deptno%TYPE,
    v_dnombre dept.dname%TYPE DEFAULT 'PROVISIONAL',
    v_loc dept.loc%TYPE DEFAULT 'PROVISIONAL') IS
BEGIN
    INSERT INTO dept
    VALUES (v_num_dept, v_dnombre, v_loc);
END crear_depart;

-- Indicar cuáles de las siguientes llamadas son correctas y cuáles incorrectas, en este último caso escribir la llamada correcta usando la notación posicional (en los casos que se pueda):

-- 1º. crear_depart: Incorrecta, ya que se debe pasar el numero de departamento para que funcione el procedimiento, de lo contrario da error.
EXECUTE crear_depart(); --> da error
SELECT * FROM DEPT;

--Llamada Correcta:
EXECUTE CREAR_DEPART(50,'Compras','Valencia');

-----------------------------------------------------------------------------------------------------------

-- 2º. crear_depart(50): Correcta, ya que se debe pasar el numero de departamento, los demás parametros tienen por defecto "provisional", por lo que, el procedimiento no falla al no entregar estos parametros.
EXECUTE crear_depart(50); --> Funciona
SELECT * FROM DEPT;

-----------------------------------------------------------------------------------------------------------

-- 3º. crear_depart('COMPRAS'): Incorrecta, ya que, al igual que la primera llamada, se necesita el numero de departamento para que funcione el procedimiento. Aunque tenga el nombre del departamento, da error.
EXECUTE crear_depart('COMPRAS'); --> da error
SELECT * FROM DEPT;

--Llamada Correcta:
EXECUTE CREAR_DEPART(50,'Compras');

-----------------------------------------------------------------------------------------------------------

-- 4º. crear_depart(50,'COMPRAS'): Correcta, ya que se ha entregado como párametro el número de departamento, el cual es muy necesario para que el procedimiento funcione. El nombre también se ha asignado como "Compras"
EXECUTE crear_depart(50,'COMPRAS'); --> Funciona
SELECT * FROM DEPT;

-----------------------------------------------------------------------------------------------------------

-- 5º. crear_depart('COMPRAS', 50): Incorrecta, ya que ha asignado al momento de llamar al procedimiento los parámetros en un orden equivocado. El primer párametro por asignar es el número de departamento, luego nombre y localidad de este.
EXECUTE crear_depart('COMPRAS',50); --> da error
SELECT * FROM DEPT;

--Llamada Correcta:
EXECUTE CREAR_DEPART(50,'Compras');

-----------------------------------------------------------------------------------------------------------

-- 6º. crear_depart('COMPRAS', 'VALENCIA'): Incorrecta, ya que no se ha asignado el número de departamento como primer parámetro, aunque haya asignado nombre y localidad, sin indicar el número de departamento, el procedimiento no funciona.
EXECUTE crear_depart('COMPRAS','VALENCIA'); --> da error
SELECT * FROM DEPT;

--Llamada Correcta:
EXECUTE CREAR_DEPART(50,'Compras','Valencia');

-----------------------------------------------------------------------------------------------------------

-- 7º. crear_depart(50, 'COMPRAS', 'VALENCIA'): Correcta, ya que se ha entregado todos los parámetros para rellenar los campos: número de departamento, nombre y localidad.
EXECUTE crear_depart(50,'COMPRAS','VALENCIA'); --> Funciona
SELECT * FROM DEPT;

-----------------------------------------------------------------------------------------------------------

-- 8º. crear_depart('COMPRAS', 50, 'VALENCIA'):Incorrecta, ya que los parámetros se han asignado en un orden equivocado, si no va como primer parámetro el número de departamento, el procedimiento no funciona.
EXECUTE crear_depart('COMPRAS',50, 'VALENCIA'); --> da error
SELECT * FROM DEPT;

--Llamada Correcta:
EXECUTE CREAR_DEPART(50,'Compras','Valencia');

-----------------------------------------------------------------------------------------------------------

-- 9º. crear_depart('VALENCIA', ‘COMPRAS’):Incorrecta,los parámetros se han asignado en un orden equivocado y no ha señalado número de departamento al inicio, por ello, el procedimiento no funciona.
EXECUTE crear_depart('VALENCIA','COMPRAS'); --> da error
SELECT * FROM DEPT;

--Llamada Correcta:
EXECUTE CREAR_DEPART(50,'Compras','Valencia');

-----------------------------------------------------------------------------------------------------------

-- 10º. crear_depart('VALENCIA', 50): Incorrecta, ya que los parámetros se han asignado en un orden equivocado, si no va como primer parámetro el número de departamento, el procedimiento no funciona.
EXECUTE crear_depart('VALENCIA',50); --> da error
SELECT * FROM DEPT;

--Llamada Correcta:
EXECUTE CREAR_DEPART(50,NULL,'Compras');
