--EJERCICIO 1.A. PRIMERO REALIZAR CONSULTA PARA OBTENER LOS DATOS
SELECT C.RUTCLIENTE, 
C.NOMBRE, 
COUNT(f.numfactura),
SUM(TOTAL),
AVG(TOTAL),
MAX(TOTAL),
MIN(TOTAL)
FROM CLIENTE C
JOIN FACTURA F
ON(C.RUTCLIENTE = F.RUTCLIENTE)
GROUP BY c.rutcliente, c.nombre
HAVING COUNT(f.numfactura) = (SELECT  MAX(COUNT(1)) FROM FACTURA GROUP BY RUTCLIENTE);

SET SERVEROUTPUT ON;
DECLARE
v_rut CLIENTE.rutcliente%TYPE;
v_nombre CLIENTE.nombre%TYPE;
v_cant_fact int;
v_sum_fact int;
v_prom_fact int;
v_max_fact int;
v_min_fact int;
BEGIN
SELECT C.RUTCLIENTE, C.NOMBRE, COUNT(f.numfactura),SUM(TOTAL), AVG(TOTAL),MAX(TOTAL), MIN(TOTAL)
INTO v_rut, v_nombre, v_cant_fact, v_sum_fact, v_prom_fact,v_max_fact, v_min_fact 
FROM CLIENTE C
JOIN FACTURA F
ON(C.RUTCLIENTE = F.RUTCLIENTE)
GROUP BY c.rutcliente, c.nombre
HAVING COUNT(f.numfactura) = (SELECT MAX(COUNT(1)) FROM FACTURA GROUP BY RUTCLIENTE);
DBMS_OUTPUT.PUT_LINE('RUT DEL CLIENTE: ' || v_rut);
DBMS_OUTPUT.PUT_LINE('NOMBRE DEL CLIENTE: ' || v_nombre);
DBMS_OUTPUT.PUT_LINE('CANTIDAD DE FACTURAS: ' || v_cant_fact);
DBMS_OUTPUT.PUT_LINE('MONTO TOTAL DE FACTURAS: ' || v_sum_fact);
DBMS_OUTPUT.PUT_LINE('MONTO PROMEDIO DE FACTURAS: ' || v_prom_fact);
DBMS_OUTPUT.PUT_LINE('MONTO MAXIMO FACTURAS: ' || v_max_fact);
DBMS_OUTPUT.PUT_LINE('MONTO MINIMO FACTURAS: ' || v_min_fact);
END;

--EJERCICIO 1.B. PRIMERO REALIZAR CONSULTA PARA OBTENER LOS DATOS
SELECT C.RUTCLIENTE, 
C.NOMBRE, 
SUM(TOTAL)
FROM CLIENTE C
JOIN FACTURA F
ON(C.RUTCLIENTE = F.RUTCLIENTE)
GROUP BY c.rutcliente, c.nombre
HAVING SUM(TOTAL) = (SELECT MAX(SUM(TOTAL)) FROM FACTURA GROUP BY RUTCLIENTE);

SELECT C.RUTCLIENTE, 
C.NOMBRE, 
SUM(TOTAL)
FROM CLIENTE C
JOIN FACTURA F
ON(C.RUTCLIENTE = F.RUTCLIENTE)
GROUP BY c.rutcliente, c.nombre
HAVING SUM(TOTAL) = (SELECT MIN(SUM(TOTAL)) FROM FACTURA GROUP BY RUTCLIENTE);

SET SERVEROUTPUT ON;
DECLARE
v_rut CLIENTE.rutcliente%TYPE;
v_nombre CLIENTE.nombre%TYPE;
v_monto int;
BEGIN
SELECT C.RUTCLIENTE, C.NOMBRE, SUM(TOTAL)
INTO v_rut, v_nombre, v_monto
FROM CLIENTE C
JOIN FACTURA F
ON(C.RUTCLIENTE = F.RUTCLIENTE)
GROUP BY c.rutcliente, c.nombre
HAVING SUM(TOTAL) = (SELECT MAX(SUM(TOTAL)) FROM FACTURA GROUP BY RUTCLIENTE);
DBMS_OUTPUT.PUT_LINE('CLIENTE CON MAYOR FACTURACION: ' || v_rut);
DBMS_OUTPUT.PUT_LINE('-------------------------------');
DBMS_OUTPUT.PUT_LINE('RUT: ' || v_rut || '- NOMBRE: '|| v_nombre || '- MONTO FACTURADO: ' || v_monto );
SELECT C.RUTCLIENTE, C.NOMBRE, SUM(TOTAL)
INTO v_rut, v_nombre, v_monto
FROM CLIENTE C
JOIN FACTURA F
ON(C.RUTCLIENTE = F.RUTCLIENTE)
GROUP BY c.rutcliente, c.nombre
HAVING SUM(TOTAL) = (SELECT MIN(SUM(TOTAL)) FROM FACTURA GROUP BY RUTCLIENTE);
DBMS_OUTPUT.PUT_LINE('CLIENTE CON MENOR FACTURACION: ' || v_rut);
DBMS_OUTPUT.PUT_LINE('-------------------------------');
DBMS_OUTPUT.PUT_LINE('RUT: ' || v_rut || '- NOMBRE: '|| v_nombre || '- MONTO FACTURADO: ' || v_monto );
END;

--EJERCICIO 1.C. PRIMERO REALIZAR CONSULTA PARA OBTENER LOS DATOS

--EJERCICIO 1.D. PRIMERO REALIZAR CONSULTA PARA OBTENER LOS DATOS
SELECT * FROM PRODUCTO P
JOIN UNIDAD_MEDIDA UM
ON(UM.CODUNIDAD = P.CODUNIDAD);

SELECT p.codproducto,
P.DESCRIPCION,
um.descriunidad,
p.totalstock,
p.stkseguridad,
SUM(DF.CANTIDAD)
, CASE
    WHEN P.PROCEDENCIA = 'N' THEN 'NACIONAL' ELSE 'INTERNACIONAL'
END    
FROM PRODUCTO P
JOIN detalle_factura DF
ON(DF.CODPRODUCTO = P.CODPRODUCTO)
JOIN unidad_medida UM
ON(UM.CODUNIDAD = P.CODUNIDAD)
GROUP BY p.codproducto, P.DESCRIPCION, um.descriunidad, P.PROCEDENCIA, p.totalstock, p.stkseguridad
HAVING SUM(DF.CANTIDAD) = (SELECT MAX(SUM(CANTIDAD)) FROM detalle_factura GROUP BY CODPRODUCTO);

SET SERVEROUTPUT ON;
DECLARE
v_cod producto.codproducto%type;
v_desc producto.descripcion%type;
v_unidad unidad_medida.descriunidad%type;
v_stock producto.totalstock%type;
v_segu producto.stkseguridad%type;
v_total int;
v_proce producto.procedencia%type;
BEGIN
SELECT p.codproducto,
P.DESCRIPCION,
um.descriunidad,
p.totalstock,
p.stkseguridad,
SUM(DF.CANTIDAD)
, CASE
    WHEN P.PROCEDENCIA = 'N' THEN 'NACIONAL' ELSE 'INTERNACIONAL'
END    
INTO v_cod, v_desc, v_unidad, v_stock, v_segu, v_total, v_proce
FROM PRODUCTO P
JOIN detalle_factura DF
ON(DF.CODPRODUCTO = P.CODPRODUCTO)
JOIN unidad_medida UM
ON(UM.CODUNIDAD = P.CODUNIDAD)
GROUP BY p.codproducto, P.DESCRIPCION, um.descriunidad, P.PROCEDENCIA, p.totalstock, p.stkseguridad
HAVING SUM(DF.CANTIDAD) = (SELECT MAX(SUM(CANTIDAD)) FROM detalle_factura GROUP BY CODPRODUCTO);
DBMS_OUTPUT.PUT_LINE('Informe de Ranking de Venta de Productos');
DBMS_OUTPUT.PUT_LINE('___________________________________________________________________________________________________');
DBMS_OUTPUT.PUT_LINE('CODPRODUCTO: ' || v_cod || 