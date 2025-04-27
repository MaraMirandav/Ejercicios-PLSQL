-- 1.- Crear un procedimiento que permita consultar todos los datos de la tabla depart a partir de una condición que se indicará en la llamada al procedimiento.

SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE consultar_depart(condicion VARCHAR2,valor VARCHAR2) AS
    id_cursor INTEGER;
    v_comando VARCHAR2(2000);
    v_dummy NUMBER;
    v_dept_no depart.dept_no%TYPE;
    v_dnombre depart.dnombre%TYPE;
    v_loc depart.loc%TYPE;
BEGIN
    id_cursor := DBMS_SQL.OPEN_CURSOR;
    v_comando := 'SELECT dept_no, dnombre, loc FROM depart WHERE ' || condicion || ':val_1';
    DBMS_OUTPUT.PUT_LINE(v_comando);
    DBMS_SQL.PARSE(id_cursor, v_comando, DBMS_SQL.V7);
    DBMS_SQL.BIND_VARIABLE(id_cursor, ':val_1', valor);

    /* A continuación se especifican las variables que recibirán los valores de la selección*/
    DBMS_SQL.DEFINE_COLUMN(id_cursor, 1, v_dept_no);
    DBMS_SQL.DEFINE_COLUMN(id_cursor, 2, v_dnombre,14);
    DBMS_SQL.DEFINE_COLUMN(id_cursor, 3, v_loc, 14);
    v_dummy := DBMS_SQL.EXECUTE(id_cursor);

    /* La función FETCH_ROWS recupera filas y retorna el número de filas que quedan */
    WHILE DBMS_SQL.FETCH_ROWS(id_cursor)>0 LOOP
        /* A continuación se depositarán los valores recuperados en las variables PL/SQL */
        DBMS_SQL.COLUMN_VALUE(id_cursor, 1, v_dept_no);
        DBMS_SQL.COLUMN_VALUE(id_cursor, 2, v_dnombre);
        DBMS_SQL.COLUMN_VALUE(id_cursor, 3, v_loc);
        DBMS_OUTPUT.PUT_LINE(v_dept_no || '*' || v_dnombre || '*' || v_loc);
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(id_cursor);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_SQL.CLOSE_CURSOR(id_cursor);
        RAISE;
END consultar_depart;

-- Debido a que desconozco el funcionamiento de SQL Dinámico y que el procedimiento fue entregado en el enunciado de la actividad, revisaré el codigo y lo iré explicando, según lo que puedo investigar:

    -- 1) SQL Dinámico: Permite crear y ejecutar consultas SQL en tiempo de ejecución con condiciones variables. Es útil cuando la consulta no puede definirse de manera fija, adaptándose a los datos proporcionados por el usuario
    -- 2) DBMS_SQL en ORACLE: Este paquete proporciona funciones y procedimientos para ejecutar sentencias SQL Dinamico
    -- 3) OPEN_CURSOR: Abrimos un cursor dinámico para manejar la consulta SQL
    -- 3) CLOSE_CURSOR: Cerramos el cursor dinámico, después de recuperar los datos
    -- 4) PARSE: Se encarga del análisis de la sentencia. Evalúa y prepara la consulta SQL antes de ejecutarla, asegurando que la sintaxis es válida.
    -- 5) NATIVE: Corresponde al modo de ejecución optimizado. Indica que la sentencia será procesada directamente por el motor PL/SQL, permitiendo una ejecución eficiente dentro de los bloques PL/SQL
    -- 6) DEFINE_COLUMM: Definir columnas. Especifica qué cambios de la consulta serán recuperados, permitiendo extraer sus valores posteriormente
    -- 7) EXECUTE: Ejecuta la consulta que ha sido previamente analizada y preparada. De esta manera, inicia el proceso de recuperación de datos
    -- 8) FETCH_ROWS: Recupera los registros, extrayendo filas del conjunto de resultados, permitiendo obtener cada registro individualmente o en bloques
    -- 9) COLUMM_VALUE: Se encarga de extraer datos específicos. Accede al valor de una columna concreta dentro de una fila recuperada, asignándolo a una variable PL/SQL