-- EJERCICIO 2
DROP TABLE cliente_gestion;
DROP TABLE seq_cliente;

-- SE CREA TABLA
CREATE TABLE cliente_gestion (
  id_cliente NUMBER(6) NOT NULL PRIMARY KEY,
  rutcliente VARCHAR2(10 CHAR) NOT NULL,
  nombre VARCHAR2(30 CHAR) NOT NULL,
  direccion VARCHAR2(95 CHAR) NOT NULL,
  credito NUMBER(8) NOT NULL,
  saldo NUMBER(8) NOT NULL,
  comportamiento_cliente VARCHAR2(50 CHAR) NOT NULL
);

-- SE CREA SECUENCIA
CREATE SEQUENCE SEQ_CLIENTE;

/* CREA LLAVE PRIMARIA
ALTER TABLE cliente_gestion
  ADD CONSTRAINT id_cliente_pk PRIMARY KEY (id_cliente);
*/

-- SE REALIZA LA CONSULTA PARA EXTRER LOS DATOS
SELECT c.rutcliente AS rut, c.nombre AS nombre, c.direccion || ' ' || com.descripcion || ' ' || ciu.descripcion,  c.credito AS credito, c.saldo AS saldo,
CASE
  WHEN (c.credito - c.saldo) <= 500000 THEN 'Cliente realiza muchas compras'
  WHEN (c.credito - c.saldo) BETWEEN 500001 AND 1000000 THEN 'Cliente Medio, respecto a compras'
  WHEN (c.credito - c.saldo) > 1000000 THEN 'Cliente no compra, candidato a capaña de marketing'
END AS comportamiento
FROM cliente c
LEFT JOIN comuna com 
ON(c.codcomuna = com.codcomuna)
LEFT JOIN ciudad ciu
ON(com.codciudad = ciu.codciudad);  

SET SERVEROUTPUT ON;
DECLARE
  CURSOR v_cursor IS 
  SELECT rutcliente, 
  nombre, 
  direccion || ' ' || NVL(co.descripcion,' ') || ' ' || NVL(ci.descripcion,' ') AS domicilio, 
  credito, 
  saldo,
  CASE
        WHEN (credito - saldo) <= 500000 THEN 'Cliente realiza muchas compras'
        WHEN (credito - saldo) BETWEEN 500001 AND 1000000 THEN 'Cliente Medio, respecto a compras'
        ELSE 'Cliente no compra, candidato a capaña de marketing'
  END AS comportamiento  
  FROM cliente c
  LEFT JOIN comuna co USING(codcomuna) 
  LEFT JOIN ciudad ci USING(codciudad);
  v_cont INT := 0; 
BEGIN
  FOR i IN v_cursor LOOP
    INSERT INTO cliente_gestion VALUES (SEQ_CLIENTE.NEXTVAL, i.rutcliente, i.nombre, i.domicilio, i.credito, i.saldo, i.comportamiento);
    v_cont := v_cont + SQL%ROWCOUNT;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Se han insertado '|| v_cont || ' Clientes');
END;

SELECT * FROM cliente_gestion;

-- EJERCICIO 3
SELECT * FROM resumen_venta_mes;

SELECT rutvendedor,
COUNT(1) AS cantr_venta,
TO_CHAR(fecha, 'mm/yyyy') AS mes,
'BOL' AS tipo_doc,
ROUND(SUM(total * 0.81)) AS montoneto,
SUM(total) AS monto_total,
CASE
    WHEN SUM(total) < 100000 THEN 0
    WHEN SUM(total) BETWEEN 100000 AND 200000 THEN (SUM(total) * 0.1)
    WHEN SUM(total) BETWEEN 200001 AND 300000 THEN (SUM(total) * 0.15)
    WHEN SUM(total) BETWEEN 300001 AND 400000 THEN (SUM(total) * 0.2)
    ELSE (SUM(total) * 0.25)
END bonometa
FROM boleta
GROUP BY rutvendedor, TO_CHAR(fecha, 'mm/yyyy')
UNION ALL
SELECT rutvendedor,
COUNT(1) AS cantr_venta,
TO_CHAR(fecha, 'mm/yyyy') AS mes,
'FAC' AS tipo_doc,
SUM(neto) AS montoneto,
SUM(total) AS montototal,
CASE
    WHEN SUM(total) < 100000 THEN 0
    WHEN SUM(total) BETWEEN 100000 AND 200000 THEN (SUM(total) * 0.1)
    WHEN SUM(total) BETWEEN 200001 AND 300000 THEN (SUM(total) * 0.15)
    WHEN SUM(total) BETWEEN 300001 AND 400000 THEN (SUM(total) * 0.2)
    ELSE (SUM(total) * 0.25)
END bonometa
FROM factura
GROUP BY rutvendedor, TO_CHAR(fecha, 'mm/yyyy');
