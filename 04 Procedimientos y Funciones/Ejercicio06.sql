-- 12) Visualizar todos los procedimientos y funciones del usuario almacenados en la base de datos y su situación (valid o invalid).

SELECT
OWNER as BBDD, OBJECT_NAME as NOMBRE,
OBJECT_TYPE as TIPO, STATUS as ESTADO
FROM ALL_OBJECTS
WHERE OWNER = 'BD_SCOTT_ME'
AND OBJECT_TYPE IN ('PROCEDURE','FUNCTION');