-- 9.2) Implementar un procedimiento que reciba un importe y visualice el desglose del cambio en unidades monetarias de 1, 5, 10, 25, 50, 100, 200, 500, 1000, 2000, 5000 Ptas. en orden inverso al que aparecen aquí enumeradas.

SET SERVEROUTPUT ON
-- Procedimiento
CREATE OR REPLACE PROCEDURE desglose_importe(p_importe NUMBER) IS
    -- Varray con el valor de las monedas
    TYPE c_varray IS VARRAY(11) OF NUMBER;
    v_monedas_array c_varray := c_varray(1, 5, 10, 25, 50, 100, 200, 500, 1000, 2000, 5000);

    -- Type RECORD para almacenar la moneda y cantidad
    TYPE rec_cajero IS RECORD (moneda NUMBER, cantidad NUMBER);
    v_cajero rec_cajero;

    -- Corresponde al resto del importe
    v_resto NUMBER := p_importe;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Desglose del importe: ' || TO_CHAR(p_importe,'9999.99') || ' Ptas: ');
    DBMS_OUTPUT.PUT_LINE(LPAD('-',44, '-'));

    FOR i IN REVERSE 1..v_monedas_array.COUNT LOOP
        v_cajero.moneda := v_monedas_array(i); -- Valor de la moneda
        v_cajero.cantidad := TRUNC(v_resto / v_cajero.moneda); -- Cuántas unidades de la moneda caben en el resto

        IF v_cajero.cantidad > 0 THEN
            DBMS_OUTPUT.PUT_LINE(RPAD(' Moneda -> : ' || TO_CHAR(v_cajero.moneda,'9999.99') || ' ptas',30) || ' Cantidad -> ' || TO_CHAR(v_cajero.cantidad));
        END IF;

        -- Actualizamos el resto para usar la siguiente moneda
        v_resto := v_resto - (v_cajero.cantidad * v_cajero.moneda);
    END LOOP;
END;
/

-- Bloque anónimo de prueba:
DECLARE
    v_importe NUMBER := 6543;
    -- 7896;
BEGIN
    DESGLOSE_IMPORTE(v_importe);
END;
/

