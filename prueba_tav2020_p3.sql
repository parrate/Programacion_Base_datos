/* *************************************************************
        PRUEBA N°3 PROGRAMACION DE BASE DE DATOS
        ========================================
        
   DESARROLLADO POR: PEDRO ARRATE MIRANDA - RODRIGO ZULOAGA
**************************************************************** */

--CREA PAKCAGE DE PROCEDIMIENTO PARA INSERTAR ERRORES DE LAS FUNCIONES A TABLA ERRORES
CREATE OR REPLACE 
PACKAGE PK_ERROR AS 
  PROCEDURE PR_ERRORES (v_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE, v_desc ERROR_CALC_REMUN.RUTINA_ERROR%TYPE);
END PK_ERROR;

CREATE OR REPLACE
PACKAGE BODY PK_ERROR AS
  PROCEDURE PR_ERRORES (v_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE, v_desc ERROR_CALC_REMUN.RUTINA_ERROR%TYPE) AS
  BEGIN
    INSERT INTO error_calc_remun VALUES (SEQ_ERROR.NEXTVAL, v_funcion, v_desc); 
  END PR_ERRORES;
END PK_ERROR;


--PRUEBA 3 - EJERCICIO N° 1
/*1.- La primera modificación para el módulo de cálculo de remuneraciones a implementar será la automatización de la
asignación de las comisiones por venta que cada vendedor atienda. Es decir, cada vez que se ingrese, actualice o se elimine
una venta (BOLETA) se deberá calcular automáticamente la comisión de esta venta que corresponde al 15% del monto total
de la boleta. Para ello, debe considerar lo siguiente:*/

-- CREA FUNCION ALMACENADA PARA CALCULO DE COMISION DE VENTA 
-- FUNCION NO SOLICITADA EN PRUEBA, SE USA PARA AGUILIZAR LAS CONSULTAS Y EXTRACCION DE RESULTADOS
CREATE OR REPLACE FUNCTION FN_COMISION_POR_VENTAS
(v_monto_boleta NUMBER) RETURN NUMBER IS v_cal_comision NUMBER := 0;
v_nom_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE := 'FN_COMISION_POR_VENTAS';
v_mens_error ERROR_CALC_REMUN.RUTINA_ERROR%TYPE := SQLERRM;
BEGIN
    v_cal_comision := ROUND(v_monto_boleta * 0.15);
    RETURN v_cal_comision;
    EXCEPTION
      WHEN OTHERS THEN
        PK_ERROR.PR_ERRORES(v_nom_funcion,v_mens_error); 
        RETURN 0;
END FN_COMISION_POR_VENTAS;


/*a) Si se inserta una nueva Boleta, se deberán insertar los valores que corresponden en tabla que almacena los valores
de las comisiones por ventas (el valor de la comisión debe ser redondeado).
b) Si se actualiza el monto de una boleta, se deberá actualizar el valor de la comisión según el nuevo monto de la boleta
(el valor de la comisión debe ser redondeado). Sin embargo, la empresa pensando en el beneficio de sus empleados,
ha establecido como política que si el monto a actualizar de la boleta es menor al monto anterior, se mantiene la
comisión que tenía el empleado. Si el monto a actualizar es mayor que el monto anterior de la boleta, entonces se
debe actualizar el valor de la comisión según el nuevo monto de la boleta.
c) Si se elimina una boleta, se debe eliminar la comisión calculada para esa venta.*/
-- CREA TRIGGER EJERCICIO N° 1.a; 1.b; 1.c
-- 1.a: INSERCION DE DATOS CONTROLADO A TRAVES DE TRIGGER
-- 1.b: ACTUALIZACION DE DATOS CONTROLADO A TRAVES DE TRIGGER
-- 1.c: NO NECESITA INTERVENCION DE TRIGGER YA QUE NO MODIFICA VALORES, SOLO ELIMINA
CREATE OR REPLACE TRIGGER tr_actualiza_comision_ventas
AFTER INSERT OR UPDATE OR DELETE ON boleta
FOR EACH ROW
DECLARE
  v_cal_comision comision_venta.valor_comision%TYPE;
BEGIN
  IF inserting THEN
    v_cal_comision := FN_COMISION_POR_VENTAS(:NEW.monto_boleta);
    INSERT INTO comision_venta VALUES (:NEW.nro_boleta, v_cal_comision);
  
  ELSIF updating THEN
    IF :NEW.monto_boleta > :OLD.monto_boleta THEN
      v_cal_comision := FN_COMISION_POR_VENTAS(:NEW.monto_boleta);
      UPDATE comision_venta
        SET valor_comision = v_cal_comision
      WHERE nro_boleta = :OLD.nro_boleta;
    END IF;
  END IF;
END;


/*d) A través de un bloque anónimo efectué lo siguiente para que probar el proceso creado:
? Inserte boleta 28 con el siguiente detalle:
- Fecha Boleta: 26/06/2017
- Monto Boleta: $258.999
- ID Cliente: 3000
- Rut Vendedor: 12456905
? Actualice el monto de la boleta 24 a $558.590.
? Actualice el monto de la boleta 27 a $60.000
? Elimine la boleta 22.*/
--BLOQUE ANONIMO EJERCICIO N° 1.d
--INSERTA, ACTUALIZA Y ELIMINA DATOS DE LAS TABLAS BOLETA Y COMISION_VENTA
DECLARE
    v_n_boleta boleta.nro_boleta%TYPE;
    v_fec_boleta boleta.fecha_boleta%TYPE;
    v_mont_boleta boleta.monto_boleta%TYPE;
    v_id_cliente boleta.id_cliente%TYPE;
    v_rut_vend boleta.numrut_emp%TYPE;
    v_cal_comision NUMBER;
    v_monto boleta.monto_boleta%TYPE;
BEGIN
    BEGIN --INSERTA BOLETA N° 28
        v_n_boleta := 28;
        v_fec_boleta := '26/06/2017';
        v_mont_boleta := 258999;
        v_id_cliente := 3000;
        v_rut_vend := 12456905;
        INSERT INTO boleta VALUES (v_n_boleta, v_fec_boleta, v_mont_boleta, v_id_cliente, v_rut_vend);
    END;
    BEGIN --ACTUALIZA BOLETA N° 24
        v_n_boleta := 24;
        v_mont_boleta := 558590;        
        UPDATE boleta
            SET monto_boleta = v_mont_boleta
        WHERE nro_boleta = v_n_boleta;
    END;
    BEGIN --ACTUALIZA BOLETA N° 27
        v_n_boleta := 27;
        v_mont_boleta := 60000;        
        UPDATE boleta
            SET monto_boleta = v_mont_boleta
        WHERE nro_boleta = v_n_boleta;
    END;
    BEGIN --ELIMINA BOLETA N° 22
        v_n_boleta := 22;        
        DELETE FROM comision_venta WHERE nro_boleta = v_n_boleta;
        DELETE FROM boleta WHERE nro_boleta = v_n_boleta;
    END;
END;

/*e) Efectuado lo solicitado en letra d), las tablas BOLETA y COMISION_VENTA deberían quedar con los siguientes
valores:*/
--EJERCICIO N° 1.e: CONSULTAS (SELECT) MOSTRANDO DATOS DE TABLAS BOLETA Y COMSION_VENTA CON LOS RESULTADOS OBTENIDOS 
--DESDE BLOQUE ANONIMO DEL EJERCICIO 1.d
--CONSULTA A LA TABLA BOLETA
SELECT * FROM boleta;
--CONSULTA A LA TABLA COMISION_VENTA
SELECT * FROM comision_venta;


--EJERCICIO N°2
/*2.- La Gerencia desea que en esta primera etapa de reingeniería del cálculo de remuneraciones sean considerados los
HABERES que se le pagan a cada empleado considerando todos los problemas que se han presentado desde que el actual
sistema se puso en marcha. Después de una serie de reuniones con el usuario, se requiere que el nuevo sistema de
remuneraciones considere las siguientes especificaciones:
2.1.- REGLAS DEL NEGOCIO
De acuerdo a las entrevistas efectuadas a los usuarios, se lograron identificar las siguientes reglas del negocio:
? El valor de la Asignación Carga Familiar es un monto fijo reajustable anualmente de acuerdo a las políticas definidas
por la empresa. Para el año 2018 se ha definido que el valor de Asignación Carga Familiar es de $4.500 por cada
carga familiar que posea el empleado.*/
--CREA FUNCION PARA EXTRAER LA CANTIDAD DE HIJOS POR EMPLEADO
-- FUNCION NO SOLICITADA EN PRUEBA, SE USA PARA AGUILIZAR LAS CONSULTAS Y EXTRACCION DE RESULTADOS
CREATE OR REPLACE FUNCTION FN_CANT_HIJOS
(v_id EMPLEADO.NUMRUT_EMP%TYPE) RETURN NUMBER IS v_c_hijos NUMBER := 0;
v_rut EMPLEADO.NUMRUT_EMP%TYPE;
v_nom_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE := 'FN_CANT_HIJOS';
v_mens_error ERROR_CALC_REMUN.RUTINA_ERROR%TYPE := SQLERRM;
BEGIN
  SELECT E.NUMRUT_EMP, COUNT(C.NUMRUT_EMP) HIJOS INTO v_rut, v_c_hijos
  FROM EMPLEADO E LEFT JOIN CARGA_FAMILIAR C
  ON(E.NUMRUT_EMP = C.NUMRUT_EMP)
  WHERE E.NUMRUT_EMP = v_id
  GROUP BY E.NUMRUT_EMP;
  RETURN v_c_hijos;
  EXCEPTION
    WHEN OTHERS THEN
      PK_ERROR.PR_ERRORES(v_nom_funcion,v_mens_error);
      RETURN 0;
END FN_CANT_HIJOS;

-- CREA FUNCION PARA CALCULAR EL MONTO DE ASIGNACION FAMILIAR
CREATE OR REPLACE FUNCTION FN_CAL_ASIGNACION_FAMILIAR
(v_rut EMPLEADO.NUMRUT_EMP%TYPE) RETURN NUMBER IS v_monto_asig NUMBER := 0;
v_nom_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE := 'FN_CAL_ASIGNACION_FAMILIAR';
v_mens_error ERROR_CALC_REMUN.RUTINA_ERROR%TYPE := SQLERRM;
BEGIN
  v_monto_asig := FN_CANT_HIJOS(v_rut) * 4500;
  RETURN v_monto_asig;
  EXCEPTION
    WHEN OTHERS THEN
      PK_ERROR.PR_ERRORES(v_nom_funcion,v_mens_error);   
      RETURN 0;
END FN_CAL_ASIGNACION_FAMILIAR;


/*? A los vendedores se les paga una Comisión por Ventas que corresponde al monto total de las comisiones que posee
en tabla COMISION_VENTA en el mes y año de proceso.*/
--CREA FUNCION COMISION VENTA
CREATE OR REPLACE FUNCTION FN_COMISION_VENTA
(v_rut EMPLEADO.NUMRUT_EMP%TYPE) RETURN NUMBER IS v_comision NUMBER := 0;
v_rut_emp EMPLEADO.NUMRUT_EMP%TYPE;
v_calc NUMBER;
v_nom_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE := 'FN_COMISION_VENTA';
v_mens_error ERROR_CALC_REMUN.RUTINA_ERROR%TYPE := SQLERRM;
BEGIN
  SELECT E.NUMRUT_EMP, SUM(C.VALOR_COMISION) INTO v_rut_emp, v_calc 
  FROM EMPLEADO E LEFT JOIN BOLETA B
  ON(E.NUMRUT_EMP = B.NUMRUT_EMP)
  JOIN COMISION_VENTA C
  ON(B.NRO_BOLETA = C.NRO_BOLETA)
  WHERE E.NUMRUT_EMP = v_rut
  GROUP BY E.NUMRUT_EMP;
  RETURN v_comision;
  EXCEPTION
    WHEN OTHERS THEN
      PK_ERROR.PR_ERRORES(v_nom_funcion,v_mens_error);   
      RETURN 0;
END FN_COMISION_VENTA;

/*? El valor de Movilización es un porcentaje del sueldo base del empleado + valor comisión por ventas + valor
asignación carga. Este porcentaje es reajustado anualmente y para el año 2018 corresponde a 25,8%.
Además, como una forma de nivelar el salario entre los empleados, la empresa ha definido que para los empleados
que NO SON VENDEDORES y que viven en las comunas de La Pintana, Cerro Navia o Peñalolén se le pague un
adicional de $25.000 por movilización y a los empleados NO SON VENDEDORES que viven en las comunas de
Melipilla, María Pinto, Curacaví, Talagante, Isla de Maipo o Paine se les pague un adicional de $40.000 por
conceptos de movilización.*/
--CREA FUNCION MOVILIZACION
CREATE OR REPLACE FUNCTION FN_MOVILIZACION
(v_rut empleado.numrut_emp%TYPE) RETURN NUMBER IS v_porc_mov NUMBER := 0;
v_remp empleado.numrut_emp%TYPE;
v_sb NUMBER;
v_cv NUMBER;
v_af NUMBER;
v_comuna empleado.id_comuna%TYPE;
v_emp empleado.id_categoria_emp%TYPE;
v_calc_mov NUMBER;
v_nom_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE := 'FN_MOVILIZACION';
v_mens_error ERROR_CALC_REMUN.RUTINA_ERROR%TYPE := SQLERRM;
BEGIN
  SELECT NUMRUT_EMP, SUELDO_BASE_EMP, ID_COMUNA, ID_CATEGORIA_EMP, NVL(FN_COMISION_VENTA(NUMRUT_EMP),0), FN_CAL_ASIGNACION_FAMILIAR(NUMRUT_EMP) 
  INTO v_remp, v_sb, v_comuna, v_emp, v_cv, v_af 
  FROM EMPLEADO WHERE NUMRUT_EMP = v_rut;
  v_porc_mov := 0;
  v_calc_mov := 0;
  v_porc_mov := ROUND((v_sb + v_cv + v_af) * 0.258);
  v_calc_mov := CASE
                  WHEN v_emp != 3 AND v_comuna IN (91, 105, 107) THEN (v_porc_mov + 25000)
                  WHEN v_emp != 3 AND v_comuna IN (114, 117, 118, 119, 122, 124) THEN (v_porc_mov + 40000)
                  ELSE v_porc_mov
                END;
  RETURN v_calc_mov;
  EXCEPTION
    WHEN OTHERS THEN
      PK_ERROR.PR_ERRORES(v_nom_funcion,v_mens_error);   
      RETURN 0;
END FN_MOVILIZACION;

-- OPCION 2 PARA ESTE CALCULO
/*
CREATE OR REPLACE FUNCTION FN_MOVILIZACION
(v_rut empleado.numrut_emp%TYPE) RETURN NUMBER IS v_porc_mov NUMBER := 0;
v_remp empleado.numrut_emp%TYPE;
v_sb NUMBER;
v_cv NUMBER;
v_af NUMBER;
v_comuna empleado.id_comuna%TYPE;
v_emp empleado.id_categoria_emp%TYPE;
v_calc_mov NUMBER;
v_nom_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE := 'FN_MOVILIZACION';
v_mens_error ERROR_CALC_REMUN.RUTINA_ERROR%TYPE := SQLERRM;
BEGIN
  SELECT NUMRUT_EMP, SUELDO_BASE_EMP, ID_COMUNA, ID_CATEGORIA_EMP, NVL(FN_COMISION_VENTA(NUMRUT_EMP),0), FN_CAL_ASIGNACION_FAMILIAR(NUMRUT_EMP) 
  INTO v_remp, v_sb, v_comuna, v_emp, v_cv, v_af 
  FROM EMPLEADO WHERE NUMRUT_EMP = v_rut;
  v_porc_mov := 0;
  v_calc_mov := 0;
  v_porc_mov := ROUND((v_sb + v_cv + v_af) * 0.258);
  IF v_emp != 3 AND v_comuna IN (91, 105, 107) THEN
    v_calc_mov := (v_porc_mov + 25000);
  ELSIF v_emp != 3 AND v_comuna IN (114, 117, 118, 119, 122, 124) THEN
    v_calc_mov := (v_porc_mov + 40000);
  ELSE
    v_calc_mov := v_porc_mov;
  END IF;
  RETURN v_calc_mov;
  EXCEPTION
    WHEN OTHERS THEN
      PK_ERROR.PR_ERRORES(v_nom_funcion,v_mens_error);   
      RETURN 0;
END FN_MOVILIZACION;
*/

/*? Para los empleados que llevan 2 o más años trabajando en la empresa, existe el pago mensual de una Asignación
Especial por años Contratados de acuerdo a los años que lleva contratado el empleado. Esta asignación corresponde
al 4%, 6%, 7% o 10% del sueldo base del empleado + valor movilización de acuerdo a los tramos existentes en la
tabla PORC_BONIF_ANNOS_CONTRATO*/
--CREA FUNCION PARA CALCULAR LA ANTIGUEDAD DEL EMPLEADO
-- FUNCION NO SOLICITADA EN PRUEBA, SE USA PARA AGUILIZAR LAS CONSULTAS Y EXTRACCION DE RESULTADOS
CREATE OR REPLACE FUNCTION FN_ANTIGUEDAD
(v_fec_cont empleado.fecing_emp%TYPE) RETURN NUMBER IS
v_cal_anios NUMBER := 0;
v_fec_act DATE := sysdate;
v_nom_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE := 'FN_ANTIGUEDAD';
v_mens_error ERROR_CALC_REMUN.RUTINA_ERROR%TYPE := SQLERRM;
BEGIN
  v_cal_anios := TRUNC(MONTHS_BETWEEN(v_fec_act, v_fec_cont)/12);
  RETURN v_cal_anios;
  EXCEPTION
    WHEN OTHERS THEN
      PK_ERROR.PR_ERRORES(v_nom_funcion,v_mens_error);   
      RETURN 0;
END FN_ANTIGUEDAD;

--CREA FUNCION PARA CALCULAR LA SUMA DE BASE + MOVILIZACION
-- FUNCION NO SOLICITADA EN PRUEBA, SE USA PARA AGUILIZAR LAS CONSULTAS Y EXTRACCION DE RESULTADOS
CREATE OR REPLACE FUNCTION FN_BASE_ANTIGUEDAD
(v_rut empleado.numrut_emp%TYPE) RETURN NUMBER IS v_base_ant NUMBER := 0;
v_r empleado.numrut_emp%TYPE;
v_sb NUMBER;
v_mv NUMBER;
v_nom_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE := 'FN_BASE_ANTIGUEDAD';
v_mens_error ERROR_CALC_REMUN.RUTINA_ERROR%TYPE := SQLERRM;
BEGIN
  SELECT numrut_emp, sueldo_base_emp, FN_MOVILIZACION(numrut_emp) INTO v_r, v_sb, v_mv
  FROM empleado
  WHERE numrut_emp = v_rut;
  v_base_ant := (v_sb + v_mv);
  RETURN v_base_ant;
  EXCEPTION
    WHEN OTHERS THEN
      PK_ERROR.PR_ERRORES(v_nom_funcion,v_mens_error);   
      RETURN 0;
END FN_BASE_ANTIGUEDAD;


--CREA FUNCION PARA CALCULAR BONO DE ANTIGUEDAD
CREATE OR REPLACE FUNCTION FN_BONO_ANTIGUEDAD
(v_base_movi NUMBER, v_anios NUMBER) RETURN NUMBER IS
CURSOR c_boni_ant IS SELECT * FROM PORC_BONIF_ANNOS_CONTRATO;
v_bono_ant NUMBER := 0;
v_nom_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE := 'FN_BONO_ANTIGUEDAD';
v_mens_error ERROR_CALC_REMUN.RUTINA_ERROR%TYPE := SQLERRM;
BEGIN
  FOR a IN c_boni_ant
  LOOP
    IF v_anios BETWEEN a.annos_inferior AND a.annos_superior THEN
      v_bono_ant := ROUND(v_base_movi * a.porc_bonif);
    END IF;
  END LOOP;
  RETURN v_bono_ant;
  EXCEPTION
    WHEN OTHERS THEN
      PK_ERROR.PR_ERRORES(v_nom_funcion,v_mens_error);   
      RETURN 0;
END FN_BONO_ANTIGUEDAD;


/*? El valor de total de haberes corresponde a la sumatoria de todos los cálculos solicitados en los puntos anteriores.*/
--CREA PROCEDIMIENTO ALMACENADO QUE CALCULA E INSERTA LOS DATOS EN TABLA HABER_CALC_MES
/*? PROCEDIMIENTO ALMACENADO principal para efectuar el cálculo de las remuneraciones de todos los
empleados. Este procedimiento debe integrar el uso de los constructores del Package y de las Funciones
Almacenadas para construir la solución requerida. Los valores calculados por cada empleado deben ser
almacenados en la tabla HABER_CALC_MES.*/

CREATE OR REPLACE PROCEDURE PR_PRINCIPAL AS
CURSOR c_empleados IS SELECT * FROM EMPLEADO;
v_mes haber_calc_mes.mes_proceso%TYPE := 06;
v_anio haber_calc_mes.anno_proceso%TYPE := 2018;
v_colacion haber_calc_mes.valor_colacion%TYPE := 40000; --? El valor de Colación es un monto fijo que se reajusta en forma anula. Para el año 2018 es de $40000.
v_asig_annos NUMBER;
v_asig_fam NUMBER;
v_mov NUMBER;
v_ventas NUMBER;
v_haberes NUMBER;
BEGIN
  FOR a IN c_empleados
  LOOP
    v_asig_annos := FN_BONO_ANTIGUEDAD(FN_BASE_ANTIGUEDAD(a.numrut_emp), FN_ANTIGUEDAD(a.fecing_emp));
    v_asig_fam := FN_CAL_ASIGNACION_FAMILIAR(a.numrut_emp);
    v_mov := FN_MOVILIZACION(a.NUMRUT_EMP);
    v_ventas := FN_COMISION_VENTA(a.NUMRUT_EMP);
    v_haberes := (a.sueldo_base_emp + v_asig_annos + v_asig_fam + v_mov + v_colacion + v_ventas);
    INSERT INTO HABER_CALC_MES VALUES 
    (a.numrut_emp, v_mes, v_anio, a.sueldo_base_emp, v_asig_annos, v_asig_fam, v_mov, v_colacion, v_ventas, v_haberes);
  END LOOP;
END PR_PRINCIPAL;

--EJECUTA PROCESO PRINCIPAL
EXEC PR_PRINCIPAL;

--PROCESO PARA VER DATOS EN TABLA HABERES
SELECT * FROM HABER_CALC_MES;


/*? Añadir columna a empleado blob y agregue foto a cada uno utilizando como nombre del archivo de imagen el “run
del empleado.png”.*/
-- SE ASIGNA PRIVILEGIO DE LECTURA Y ESCRITURA AL USUARIO EN USO (ESTE PROCESO SE REALIZA E SYSTEM)
GRANT READ, WRITE ON DIRECTORY ORACLECLRDIR TO tav2020_p3;

-- SE AGREGA NUEVA COLUMNA (FOTO) A TABLA PRODUCTO
ALTER TABLE EMPLEADO ADD FOTO BLOB DEFAULT empty_blob();

--MEDIANTE BLOQUE ANONIMO SE INSERTAN LAS FOTOS A LA TABLA EMPLEADO
DECLARE
    CURSOR c_fotos IS SELECT * FROM EMPLEADO;
    v_blob BLOB;
    v_bfile BFILE;
    v_nombre_archivo VARCHAR2(15 CHAR);
BEGIN
    FOR a IN c_fotos LOOP
        v_nombre_archivo := (TO_CHAR(a.numrut_emp) || '.PNG');
        SELECT FOTO INTO v_blob FROM EMPLEADO WHERE numrut_emp = a.numrut_emp FOR UPDATE;
        v_bfile := BFILENAME ('ORACLECLRDIR', v_nombre_archivo);
        DBMS_LOB.OPEN(v_bfile, DBMS_LOB.LOB_READONLY);
        DBMS_LOB.LOADFROMFILE(v_blob, v_bfile, DBMS_LOB.GETLENGTH(v_bfile));
        DBMS_LOB.CLOSE(v_bfile);
    END LOOP;
END;

/*
-- COMPETENCIAS DE EMPLEABILIDAD - 2° OPCION MEDIANTE PACKAGE DE FUNCIONES NO SOLICITADAS QUE AYUDAN A RESOLVER LAS SOLICITUDES

CREATE OR REPLACE 
PACKAGE PK_FN_APOYO AS 
  FUNCTION FN_AP_COMISION_POR_VENTAS (v_monto_boleta NUMBER) RETURN NUMBER;
  FUNCTION FN_AP_CANT_HIJOS (v_id EMPLEADO.NUMRUT_EMP%TYPE) RETURN NUMBER;
  FUNCTION FN_AP_ANTIGUEDAD (v_fec_cont empleado.fecing_emp%TYPE) RETURN NUMBER;
  FUNCTION FN_AP_BASE_ANTIGUEDAD (v_rut empleado.numrut_emp%TYPE) RETURN NUMBER;
END PK_FN_APOYO;

CREATE OR REPLACE
PACKAGE BODY PK_FN_APOYO AS
  FUNCTION FN_AP_COMISION_POR_VENTAS
    (v_monto_boleta NUMBER) RETURN NUMBER IS v_cal_comision NUMBER := 0;
    v_nom_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE := 'FN_AP_COMISION_POR_VENTAS';
    v_mens_error ERROR_CALC_REMUN.RUTINA_ERROR%TYPE := SQLERRM;
  BEGIN
    v_cal_comision := ROUND(v_monto_boleta * 0.15);
    RETURN v_cal_comision;
    EXCEPTION
      WHEN OTHERS THEN
        PK_ERROR.PR_ERRORES(v_nom_funcion,v_mens_error); 
        RETURN 0;
  END FN_AP_COMISION_POR_VENTAS;
  
  FUNCTION FN_AP_CANT_HIJOS
    (v_id EMPLEADO.NUMRUT_EMP%TYPE) RETURN NUMBER IS v_c_hijos NUMBER := 0;
    v_rut EMPLEADO.NUMRUT_EMP%TYPE;
    v_nom_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE := 'FN_AP_CANT_HIJOS';
    v_mens_error ERROR_CALC_REMUN.RUTINA_ERROR%TYPE := SQLERRM;
  BEGIN
    SELECT E.NUMRUT_EMP, COUNT(C.NUMRUT_EMP) HIJOS INTO v_rut, v_c_hijos
    FROM EMPLEADO E LEFT JOIN CARGA_FAMILIAR C
    ON(E.NUMRUT_EMP = C.NUMRUT_EMP)
    WHERE E.NUMRUT_EMP = v_id
    GROUP BY E.NUMRUT_EMP;
    RETURN v_c_hijos;
    EXCEPTION
      WHEN OTHERS THEN
        PK_ERROR.PR_ERRORES(v_nom_funcion,v_mens_error);
        RETURN 0;
  END FN_AP_CANT_HIJOS;
  
  FUNCTION FN_AP_ANTIGUEDAD
    (v_fec_cont empleado.fecing_emp%TYPE) RETURN NUMBER IS
    v_cal_anios NUMBER := 0;
    v_fec_act DATE := sysdate;
    v_nom_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE := 'FN_AP_ANTIGUEDAD';
    v_mens_error ERROR_CALC_REMUN.RUTINA_ERROR%TYPE := SQLERRM;
  BEGIN
    v_cal_anios := TRUNC(MONTHS_BETWEEN(v_fec_act, v_fec_cont)/12);
    RETURN v_cal_anios;
    EXCEPTION
      WHEN OTHERS THEN
        PK_ERROR.PR_ERRORES(v_nom_funcion,v_mens_error);   
        RETURN 0;
  END FN_AP_ANTIGUEDAD;

  FUNCTION FN_AP_BASE_ANTIGUEDAD
    (v_rut empleado.numrut_emp%TYPE) RETURN NUMBER IS v_base_ant NUMBER := 0;
    v_r empleado.numrut_emp%TYPE;
    v_sb NUMBER;
    v_mv NUMBER;
    v_nom_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE := 'FN_AP_BASE_ANTIGUEDAD';
    v_mens_error ERROR_CALC_REMUN.RUTINA_ERROR%TYPE := SQLERRM;
  BEGIN
    SELECT numrut_emp, sueldo_base_emp, FN_MOVILIZACION(numrut_emp) INTO v_r, v_sb, v_mv
    FROM empleado
    WHERE numrut_emp = v_rut;
    v_base_ant := (v_sb + v_mv);
    RETURN v_base_ant;
    EXCEPTION
      WHEN OTHERS THEN
        PK_ERROR.PR_ERRORES(v_nom_funcion,v_mens_error);   
        RETURN 0;
  END FN_AP_BASE_ANTIGUEDAD;
END PK_FN_APOYO;

--CREA TRIGGER
CREATE OR REPLACE TRIGGER tr_actualiza_comision_ventas
AFTER INSERT OR UPDATE OR DELETE ON boleta
FOR EACH ROW
DECLARE
  v_cal_comision comision_venta.valor_comision%TYPE;
BEGIN
  IF inserting THEN
    v_cal_comision := PK_FN_APOYO.FN_AP_COMISION_POR_VENTAS(:NEW.monto_boleta);
    INSERT INTO comision_venta VALUES (:NEW.nro_boleta, v_cal_comision);
  
  ELSIF updating THEN
    IF :NEW.monto_boleta > :OLD.monto_boleta THEN
      v_cal_comision := PK_FN_APOYO.FN_AP_COMISION_POR_VENTAS(:NEW.monto_boleta);
      UPDATE comision_venta
        SET valor_comision = v_cal_comision
      WHERE nro_boleta = :OLD.nro_boleta;
    END IF;
  END IF;
END;

--BLOQUE ANONIMO EJERCICIO N° 1.d
--INSERTA, ACTUALIZA Y ELIMINA DATOS DE LAS TABLAS BOLETA Y COMISION_VENTA
DECLARE
    v_n_boleta boleta.nro_boleta%TYPE;
    v_fec_boleta boleta.fecha_boleta%TYPE;
    v_mont_boleta boleta.monto_boleta%TYPE;
    v_id_cliente boleta.id_cliente%TYPE;
    v_rut_vend boleta.numrut_emp%TYPE;
    v_cal_comision NUMBER;
    v_monto boleta.monto_boleta%TYPE;
BEGIN
    BEGIN --INSERTA BOLETA N° 28
        v_n_boleta := 28;
        v_fec_boleta := '26/06/2017';
        v_mont_boleta := 258999;
        v_id_cliente := 3000;
        v_rut_vend := 12456905;
        INSERT INTO boleta VALUES (v_n_boleta, v_fec_boleta, v_mont_boleta, v_id_cliente, v_rut_vend);
    END;
    BEGIN --ACTUALIZA BOLETA N° 24
        v_n_boleta := 24;
        v_mont_boleta := 558590;        
        UPDATE boleta
            SET monto_boleta = v_mont_boleta
        WHERE nro_boleta = v_n_boleta;
    END;
    BEGIN --ACTUALIZA BOLETA N° 27
        v_n_boleta := 27;
        v_mont_boleta := 60000;        
        UPDATE boleta
            SET monto_boleta = v_mont_boleta
        WHERE nro_boleta = v_n_boleta;
    END;
    BEGIN --ELIMINA BOLETA N° 22
        v_n_boleta := 22;        
        DELETE FROM comision_venta WHERE nro_boleta = v_n_boleta;
        DELETE FROM boleta WHERE nro_boleta = v_n_boleta;
    END;
END;

--EJERCICIO N° 1.e: CONSULTAS (SELECT) MOSTRANDO DATOS DE TABLAS BOLETA Y COMSION_VENTA CON LOS RESULTADOS OBTENIDOS 
--DESDE BLOQUE ANONIMO DEL EJERCICIO 1.d
--CONSULTA A LA TABLA BOLETA
SELECT * FROM boleta;
--CONSULTA A LA TABLA COMISION_VENTA
SELECT * FROM comision_venta;



--EJERCICIO N°2
-- CREA FUNCION PARA CALCULAR EL MONTO DE ASIGNACION FAMILIAR
CREATE OR REPLACE FUNCTION FN_CAL_ASIGNACION_FAMILIAR
(v_rut EMPLEADO.NUMRUT_EMP%TYPE) RETURN NUMBER IS v_monto_asig NUMBER := 0;
v_nom_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE := 'FN_CAL_ASIGNACION_FAMILIAR';
v_mens_error ERROR_CALC_REMUN.RUTINA_ERROR%TYPE := SQLERRM;
BEGIN
  v_monto_asig := PK_FN_APOYO.FN_AP_CANT_HIJOS(v_rut) * 4500;
  RETURN v_monto_asig;
  EXCEPTION
    WHEN OTHERS THEN
      PK_ERROR.PR_ERRORES(v_nom_funcion,v_mens_error);   
      RETURN 0;
END FN_CAL_ASIGNACION_FAMILIAR;

--CREA FUNCION COMISION VENTA
CREATE OR REPLACE FUNCTION FN_COMISION_VENTA
(v_rut EMPLEADO.NUMRUT_EMP%TYPE) RETURN NUMBER IS v_comision NUMBER := 0;
v_rut_emp EMPLEADO.NUMRUT_EMP%TYPE;
v_calc NUMBER;
v_nom_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE := 'FN_COMISION_VENTA';
v_mens_error ERROR_CALC_REMUN.RUTINA_ERROR%TYPE := SQLERRM;
BEGIN
  SELECT E.NUMRUT_EMP, SUM(C.VALOR_COMISION) INTO v_rut_emp, v_calc 
  FROM EMPLEADO E LEFT JOIN BOLETA B
  ON(E.NUMRUT_EMP = B.NUMRUT_EMP)
  JOIN COMISION_VENTA C
  ON(B.NRO_BOLETA = C.NRO_BOLETA)
  WHERE E.NUMRUT_EMP = v_rut
  GROUP BY E.NUMRUT_EMP;
  RETURN v_comision;
  EXCEPTION
    WHEN OTHERS THEN
      PK_ERROR.PR_ERRORES(v_nom_funcion,v_mens_error);   
      RETURN 0;
END FN_COMISION_VENTA;

--CREA FUNCION MOVILIZACION
CREATE OR REPLACE FUNCTION FN_MOVILIZACION
(v_rut empleado.numrut_emp%TYPE) RETURN NUMBER IS v_porc_mov NUMBER := 0;
v_remp empleado.numrut_emp%TYPE;
v_sb NUMBER;
v_cv NUMBER;
v_af NUMBER;
v_comuna empleado.id_comuna%TYPE;
v_emp empleado.id_categoria_emp%TYPE;
v_calc_mov NUMBER;
v_nom_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE := 'FN_MOVILIZACION';
v_mens_error ERROR_CALC_REMUN.RUTINA_ERROR%TYPE := SQLERRM;
BEGIN
  SELECT NUMRUT_EMP, SUELDO_BASE_EMP, ID_COMUNA, ID_CATEGORIA_EMP, NVL(FN_COMISION_VENTA(NUMRUT_EMP),0), FN_CAL_ASIGNACION_FAMILIAR(NUMRUT_EMP) 
  INTO v_remp, v_sb, v_comuna, v_emp, v_cv, v_af 
  FROM EMPLEADO WHERE NUMRUT_EMP = v_rut;
  v_porc_mov := 0;
  v_calc_mov := 0;
  v_porc_mov := ROUND((v_sb + v_cv + v_af) * 0.258);
  v_calc_mov := CASE
                  WHEN v_emp != 3 AND v_comuna IN (91, 105, 107) THEN (v_porc_mov + 25000)
                  WHEN v_emp != 3 AND v_comuna IN (114, 117, 118, 119, 122, 124) THEN (v_porc_mov + 40000)
                  ELSE v_porc_mov
                END;
  RETURN v_calc_mov;
  EXCEPTION
    WHEN OTHERS THEN
      PK_ERROR.PR_ERRORES(v_nom_funcion,v_mens_error);   
      RETURN 0;
END FN_MOVILIZACION;

--CREA FUNCION PARA CALCULAR BONO DE ANTIGUEDAD
CREATE OR REPLACE FUNCTION FN_BONO_ANTIGUEDAD
(v_base_movi NUMBER, v_anios NUMBER) RETURN NUMBER IS
CURSOR c_boni_ant IS SELECT * FROM PORC_BONIF_ANNOS_CONTRATO;
v_bono_ant NUMBER := 0;
v_nom_funcion ERROR_CALC_REMUN.DESCRIP_ERROR%TYPE := 'FN_BONO_ANTIGUEDAD';
v_mens_error ERROR_CALC_REMUN.RUTINA_ERROR%TYPE := SQLERRM;
BEGIN
  FOR a IN c_boni_ant
  LOOP
    IF v_anios BETWEEN a.annos_inferior AND a.annos_superior THEN
      v_bono_ant := ROUND(v_base_movi * a.porc_bonif);
    END IF;
  END LOOP;
  RETURN v_bono_ant;
  EXCEPTION
    WHEN OTHERS THEN
      PK_ERROR.PR_ERRORES(v_nom_funcion,v_mens_error);   
      RETURN 0;
END FN_BONO_ANTIGUEDAD;

--CREA PROCEDIMIENTO ALMACENADO QUE CALCULA E INSERTA LOS DATOS EN TABLA HABER_CALC_MES
CREATE OR REPLACE PROCEDURE PR_PRINCIPAL AS
CURSOR c_empleados IS SELECT * FROM EMPLEADO;
v_mes haber_calc_mes.mes_proceso%TYPE := 06;
v_anio haber_calc_mes.anno_proceso%TYPE := 2018;
v_colacion haber_calc_mes.valor_colacion%TYPE := 40000;
v_asig_annos NUMBER;
v_asig_fam NUMBER;
v_mov NUMBER;
v_ventas NUMBER;
v_haberes NUMBER;
BEGIN
  FOR a IN c_empleados
  LOOP
    v_asig_annos := FN_BONO_ANTIGUEDAD(PK_FN_APOYO.FN_AP_BASE_ANTIGUEDAD(a.numrut_emp), PK_FN_APOYO.FN_AP_ANTIGUEDAD(a.fecing_emp));
    v_asig_fam := FN_CAL_ASIGNACION_FAMILIAR(a.numrut_emp);
    v_mov := FN_MOVILIZACION(a.NUMRUT_EMP);
    v_ventas := FN_COMISION_VENTA(a.NUMRUT_EMP);
    v_haberes := (a.sueldo_base_emp + v_asig_annos + v_asig_fam + v_mov + v_colacion + v_ventas);
    INSERT INTO HABER_CALC_MES VALUES 
    (a.numrut_emp, v_mes, v_anio, a.sueldo_base_emp, v_asig_annos, v_asig_fam, v_mov, v_colacion, v_ventas, v_haberes);
  END LOOP;
END PR_PRINCIPAL;

--EJECUTA PROCESO PRINCIPAL
EXEC PR_PRINCIPAL;

--PROCESO PARA VER DATOS EN TABLA HABERES
SELECT * FROM HABER_CALC_MES;


-- SE ASIGNA PRIVILEGIO DE LECTURA Y ESCRITURA AL USUARIO EN USO (ESTE PROCESO SE REALIZA E SYSTEM)
GRANT READ, WRITE ON DIRECTORY ORACLECLRDIR TO tav2020_p3;

-- SE AGREGA NUEVA COLUMNA (FOTO) A TABLA PRODUCTO
ALTER TABLE EMPLEADO ADD FOTO BLOB DEFAULT empty_blob();

--MEDIANTE BLOQUE ANONIMO SE INSERTAN LAS FOTOS A LA TABLA EMPLEADO
DECLARE
    CURSOR c_fotos IS SELECT * FROM EMPLEADO;
    v_blob BLOB;
    v_bfile BFILE;
    v_nombre_archivo VARCHAR2(15 CHAR);
BEGIN
    FOR a IN c_fotos LOOP
        v_nombre_archivo := (TO_CHAR(a.numrut_emp) || '.PNG');
        SELECT FOTO INTO v_blob FROM EMPLEADO WHERE numrut_emp = a.numrut_emp FOR UPDATE;
        v_bfile := BFILENAME ('ORACLECLRDIR', v_nombre_archivo);
        DBMS_LOB.OPEN(v_bfile, DBMS_LOB.LOB_READONLY);
        DBMS_LOB.LOADFROMFILE(v_blob, v_bfile, DBMS_LOB.GETLENGTH(v_bfile));
        DBMS_LOB.CLOSE(v_bfile);
    END LOOP;
END;

*/
