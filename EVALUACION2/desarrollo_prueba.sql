/* *************************************************************
        PRUEBA N°2 PROGRAMACION DE BASE DE DATOS
        ========================================
        
   DESARROLLADO POR: PEDRO ARRATE MIRANDA - RODRIGO ZULOAGA
**************************************************************** */

--DESARROLLO EJERCICIO 1 

SET SERVEROUTPUT ON;
DECLARE
  v_codigo vendedor.cod_vendedor%TYPE;
  v_nombre vendedor.nom_vendedor%TYPE;
  v_fecnacven vendedor.fechnac_vendedor%TYPE;
  v_edad NUMBER(2);
  v_genero vendedor.sexo%TYPE;
  v_fecha_venta venta.fecha%TYPE;
  v_valor NUMBER;
  v_fecha_calculo DATE := '31/12/2019'; 
  v_anno_calculo NUMBER;
  v_preg NUMBER;
BEGIN
  v_anno_calculo := &ANNO_CALCULO;
  v_preg := &ACTUALIZAR_1si_2_no;
  SELECT v.cod_vendedor, v.nom_vendedor, v.fechnac_vendedor, v.sexo, vt.fecha, vt.valor
  INTO v_codigo, v_nombre, v_fecnacven, v_genero, v_fecha_venta, v_valor
  FROM vendedor v 
  LEFT JOIN venta vt ON(v.cod_vendedor = vt.cod_vendedor)
  WHERE vt.valor = (select MIN(valor) from venta WHERE EXTRACT(YEAR FROM FECHA) = v_anno_calculo)
  GROUP BY v.cod_vendedor, v.nom_vendedor, v.fechnac_vendedor, v.sexo, vt.fecha, vt.valor;
  v_edad := TRUNC(MONTHS_BETWEEN(v_fecha_calculo,v_fecnacven)/12);
  IF v_preg = 2 THEN  
    DBMS_OUTPUT.PUT_LINE('Código: ' || v_codigo);
    DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre);
    DBMS_OUTPUT.PUT_LINE('Edad: ' || v_edad);
    DBMS_OUTPUT.PUT_LINE('Género: ' || v_genero);
    DBMS_OUTPUT.PUT_LINE('No se actualizan registros');
  ELSIF v_preg = 1 THEN  
    UPDATE vendedor SET MINIMO_ANIO = EXTRACT(YEAR FROM v_fecha_venta) 
    WHERE cod_vendedor = v_codigo; 
    DBMS_OUTPUT.PUT_LINE('Código: ' || v_codigo);
    DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre);
    DBMS_OUTPUT.PUT_LINE('Edad: ' || v_edad);
    DBMS_OUTPUT.PUT_LINE('Género: ' || v_genero);
    DBMS_OUTPUT.PUT_LINE('Se actualizo 1 registro');   
  END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
          DBMS_OUTPUT.PUT_LINE ('ERROR EN AÑO A TRABAJAR, FAVOR INGRESAR DATOS DESDE 2017 A 2019');
END;

 
-- DESARROLLO EJERCICIO N° 2
DROP TABLE concesionario_planta_2020;

CREATE TABLE concesionario_planta_2020 
(COD_CONC NUMBER PRIMARY KEY,
NOM_CONC VARCHAR2(100 CHAR),
CANT_PLANTA NUMBER);

SET SERVEROUTPUT ON;
DECLARE
  CURSOR c_conc IS SELECT C.COD_CONC, C.NOMBRE, ci.nombre ciudad, count(v.cod_conc) vendedores
      FROM CONCESIONARIO C
      JOIN CIUDAD CI ON(c.cod_ciudad = ci.cod_ciudad)
      JOIN VENDEDOR V ON(c.cod_conc = v.cod_conc)
      GROUP BY C.COD_CONC, C.NOMBRE, ci.nombre;
  v_codigo concesionario.cod_conc%TYPE;
  v_nombre concesionario.nombre%TYPE;
  v_ciudad ciudad.nombre%TYPE;
  v_vendedores NUMBER;
  v_cont INT := 0;
  v_error EXCEPTION;
BEGIN
  RAISE v_error;
  FOR a IN c_conc LOOP
    v_codigo := a.cod_conc;
    v_nombre := a.nombre;
    v_ciudad := a.ciudad;
    v_vendedores := a.vendedores;
    INSERT INTO concesionario_planta_2020 VALUES (v_codigo, v_nombre, v_vendedores);
    DBMS_OUTPUT.PUT_LINE('Sucursal: ' || v_codigo || ' - ' || v_nombre || ' - ' || v_ciudad);
    DBMS_OUTPUT.PUT_LINE('Fuerza de Trabajo: ' || v_vendedores);
    v_cont := v_cont + 1;
  END LOOP;
    DBMS_OUTPUT.PUT_LINE('Base Instalada: ' || v_cont || ' sucursales');
  EXCEPTION
    WHEN v_error THEN
          DBMS_OUTPUT.PUT_LINE ('ERROR AL EJECUTAR: '|| SQLERRM);
END;


--DESARROLLO EJERCICIO N° 3
DROP TABLE rendimiento_general;

CREATE TABLE rendimiento_general(
codigo NUMBER(5) PRIMARY KEY,
nombre_concesionario VARCHAR2(20 CHAR),
nombre_vendedor VARCHAR2(30 CHAR),
cantidad_ventas NUMBER(6),
bono NUMBER(9)
);

CREATE SEQUENCE SEQ_CODIGO;

SET SERVEROUTPUT ON;
DECLARE
  CURSOR c_principal IS  
    SELECT C.NOMBRE CON , V.NOM_VENDEDOR VEN , COUNT(VN.COD_VENDEDOR) VENTAS, NVL(VN.COD_COLOR,0) COLOR, NVL(A.COD_MARCA,0) MARCA, NVL(VN.VALOR,0) VAL
    FROM VENDEDOR V
    JOIN CONCESIONARIO C ON(V.COD_CONC = C.COD_CONC)
    LEFT JOIN VENTA VN ON(V.COD_VENDEDOR = VN.COD_VENDEDOR)
    LEFT JOIN AUTO A ON(VN.COD_AUTO = A.COD_AUTO)
    GROUP BY V.COD_VENDEDOR, V.NOM_VENDEDOR, C.NOMBRE, NVL(VN.COD_COLOR,0), NVL(A.COD_MARCA,0), NVL(VN.VALOR,0)
    ORDER BY 1;  
  v_bono NUMBER;
  v_cont NUMBER := 0;
  v_error EXCEPTION;
BEGIN
  RAISE v_error;
  FOR a IN c_principal LOOP    
    v_bono := 0;    
    IF a.ventas > 0 THEN  
      v_bono := CASE
                  WHEN a.MARCA = 6 AND a.color = 2 THEN ((a.val * 11)/100)
                  WHEN a.MARCA = 6 AND a.color = 1 THEN ((a.val * 4)/100)
                  WHEN a.MARCA = 6 AND a.color = 3 THEN ((a.val * 4)/100)
                  WHEN a.MARCA = 6 AND a.color = 4 THEN ((a.val * 4)/100)
                  WHEN a.MARCA = 6 AND a.color = 5 THEN ((a.val * 4)/100)
                  WHEN a.MARCA = 6 AND a.color = 6 THEN ((a.val * 4)/100)
                  WHEN a.MARCA = 1 AND a.color = 2 THEN ((a.val * 7)/100)
                  WHEN a.MARCA = 1 AND a.color = 1 THEN ((a.val * 4)/100)
                  WHEN a.MARCA = 1 AND a.color = 3 THEN ((a.val * 4)/100)
                  WHEN a.MARCA = 1 AND a.color = 4 THEN ((a.val * 4)/100)
                  WHEN a.MARCA = 1 AND a.color = 5 THEN ((a.val * 4)/100)
                  WHEN a.MARCA = 1 AND a.color = 6 THEN ((a.val * 4)/100)
                  WHEN a.MARCA = 2 AND a.color = 1 THEN ((a.val * 9)/100)
                  WHEN a.MARCA = 2 AND a.color = 2 THEN ((a.val * 3)/100)
                  WHEN a.MARCA = 2 AND a.color = 3 THEN ((a.val * 3)/100)
                  WHEN a.MARCA = 2 AND a.color = 4 THEN ((a.val * 3)/100)
                  WHEN a.MARCA = 2 AND a.color = 5 THEN ((a.val * 3)/100)
                  WHEN a.MARCA = 2 AND a.color = 6 THEN ((a.val * 3)/100)
                  WHEN a.MARCA = 3 AND a.color = 1 THEN ((a.val * 6)/100)
                  WHEN a.MARCA = 3 AND a.color = 2 THEN ((a.val * 3)/100)
                  WHEN a.MARCA = 3 AND a.color = 3 THEN ((a.val * 3)/100)
                  WHEN a.MARCA = 3 AND a.color = 4 THEN ((a.val * 3)/100)
                  WHEN a.MARCA = 3 AND a.color = 5 THEN ((a.val * 3)/100)
                  WHEN a.MARCA = 3 AND a.color = 6 THEN ((a.val * 3)/100)
                  ELSE ((a.val * 1)/100)
                END; 
       ELSE v_bono := 0;
      END IF;
    INSERT INTO rendimiento_general VALUES (SEQ_CODIGO.NEXTVAL, a.con, a.ven, a.ventas, v_bono);  
    v_cont := v_cont + 1;
  END LOOP;  
  DBMS_OUTPUT.PUT_LINE('Se procesaron ' || v_cont || ' vendedores'); 
  EXCEPTION 
    WHEN v_error THEN
          DBMS_OUTPUT.PUT_LINE ('ERROR AL EJECUTAR: '|| SQLERRM);
END;

