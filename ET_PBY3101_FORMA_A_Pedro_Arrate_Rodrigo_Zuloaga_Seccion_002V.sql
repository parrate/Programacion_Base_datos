/* *************************************************************
        EXAMEN TRANSVERSAL PROGRAMACION DE BASE DE DATOS
        ================================================
        
   DESARROLLADO POR: PEDRO ARRATE MIRANDA - RODRIGO ZULOAGA
**************************************************************** */

/*
1.- A contar del mes de agosto de este año BANK SOLUTIONS implementará el Programa de Puntos TODOSUMA orientado a los clientes 
que soliciten algún crédito. Este nuevo beneficio para los clientes del banco va a considerar que por cada $100.000 del monto solicitado
(monto solicitado sin considerar la tasa de interés) le corresponderán 1.200 puntos. Los puntos serán acumulables y el cliente podrá canjearlos
en gifcard o hacer uso de ellos en cualquier centro comercial, de comidas y/o entretenimientos que estén adheridos al Programa de Puntos TODOSUMA 
del banco.
Ud. deberá implementar una solución para que cada vez que a un cliente se le otorgue o anule un crédito se le sumen o descuenten los puntos que le
corresponden al cliente. Esto significa que, si al cliente se le otorgó un crédito, se le deben sumar los puntos que obtuvo según el monto del
crédito otorgado. Por el contrario, si el cliente anula un crédito, se le deben restar los puntos que inicialmente se le asignaron por ese crédito.
El proceso debe ser capaz también de validar que si es la primera vez que al cliente se le asignan puntos debe insertar todos los datos requeridos
Si el cliente ya posee puntos, entonces el proceso debe sumar o restar los puntos obtenidos a los que ya posee.
*/
--SUBPROGRAMA ADICIONAL
CREATE OR REPLACE FUNCTION fn_puntos
(v_nr_cliente credito_cliente.nro_cliente%TYPE) RETURN NUMBER IS
v_calc_puntos NUMBER;
v_cli credito_cliente.nro_cliente%TYPE;
v_monto credito_cliente.monto_credito%TYPE;
v_puntos puntos_todo_suma.total_puntos%TYPE;
v_calc_veces NUMBER;
v_nom_funcion error_creditos_mensuales.rutina_error%TYPE;
v_desc_error error_creditos_mensuales.descrip_error%TYPE;
BEGIN
    SELECT c.nro_cliente, c.monto_credito, TRUNC(c.monto_credito / 100000), NVL(p.total_puntos,0)
    INTO v_cli, v_monto, v_calc_veces, v_puntos
    FROM credito_cliente c LEFT JOIN puntos_todo_suma p
    ON(c.nro_cliente = p.nro_cliente)
    WHERE c.nro_cliente = v_nr_cliente;
    v_calc_puntos := 0;
    v_calc_puntos := (1200 * v_calc_veces);
    RETURN v_calc_puntos;
    EXCEPTION                     
        WHEN OTHERS THEN
            v_nom_funcion := ('Error en FN_SUMAR_PUNTOS en para el cliente ' || TO_CHAR(v_nr_cliente));
            v_desc_error := SQLERRM;
            INSERT INTO error_creditos_mensuales VALUES (SEQ_CREDITO.nextval, v_nom_funcion, v_desc_error);
            RETURN 0;
END fn_puntos;

CREATE OR REPLACE TRIGGER tr_actualiza_puntos_todosuma
AFTER INSERT OR UPDATE OR DELETE ON credito_cliente
FOR EACH ROW
DECLARE
    v_puntos NUMBER;
    v_fec_act DATE := sysdate;
    v_nom_funcion error_creditos_mensuales.rutina_error%TYPE;
    v_desc_error error_creditos_mensuales.descrip_error%TYPE;
BEGIN
  IF inserting THEN
    v_puntos := fn_puntos(:NEW.nro_cliente);
    INSERT INTO puntos_todo_suma VALUES (:NEW.nro_cliente, v_puntos, v_fec_act);
  
  ELSIF updating THEN
    IF :NEW.monto_credito > :OLD.monto_credito THEN
        v_puntos := ((fn_puntos(:NEW.nro_cliente) - fn_puntos(:OLD.nro_cliente)) + fn_puntos(:OLD.nro_cliente));
        UPDATE puntos_todo_suma
            SET total_puntos = v_puntos
        WHERE nro_cliente = :OLD.nro_cliente;
        
    ELSIF :NEW.monto_credito < :OLD.monto_credito THEN
        v_puntos := (fn_puntos(:OLD.nro_cliente) - (fn_puntos(:NEW.nro_cliente) - fn_puntos(:OLD.nro_cliente)));
        UPDATE puntos_todo_suma
            SET total_puntos = v_puntos
        WHERE nro_cliente = :OLD.nro_cliente;  
    END IF;
  END IF;
  EXCEPTION                     
    WHEN OTHERS THEN
        v_nom_funcion := ('Error en tr_actualiza_puntos_todosuma en cliente ' || TO_CHAR(:NEW.nro_cliente));
        v_desc_error := SQLERRM;
        INSERT INTO error_creditos_mensuales VALUES (SEQ_CREDITO.nextval, v_nom_funcion, v_desc_error);  
END;

/*
Para efectos de las primeras pruebas de su proceso, Ud. ha decido efectuar las siguientes transacciones:
*/
SET SERVEROUTPUT ON;
DECLARE
  TYPE v_cred_cliente IS RECORD
  (v_sol CREDITO_CLIENTE.NRO_SOLIC_CREDITO%TYPE,
  v_ncli CREDITO_CLIENTE.NRO_CLIENTE%TYPE,
  v_f_sol CREDITO_CLIENTE.FECHA_SOLIC_CRED%TYPE,
  v_f_oto CREDITO_CLIENTE.FECHA_OTORGA_CRED%TYPE,
  v_monto_sol CREDITO_CLIENTE.MONTO_SOLICITADO%TYPE,
  v_monto_cred CREDITO_CLIENTE.MONTO_CREDITO%TYPE,
  v_total_cuo CREDITO_CLIENTE.TOTAL_CUOTAS_CREDITO%TYPE,
  v_cod_cred CREDITO_CLIENTE.COD_CREDITO%TYPE,
  v_id_suc CREDITO_CLIENTE.ID_SUCURSAL%TYPE);
  v_puntos_cred NUMBER;
  v_puntos NUMBER;
BEGIN
  /*Ingresar un crédito para el cliente N°5 con los siguientes datos:
  o Número de solicitud: 1111
  o Fecha de solicitud del crédito: 20/03/2019
  o Fecha en que se otorgó el crédito: 22/03/2019
  o Monto solicitado: 3000000
  o Monto del crédito (monto solicitado con la tasa de interés): 3200000
  o Número de cuotas: 48
  o Tipo de crédito: Crédito de Consumo
  o Sucursal en la que se solicitó el crédito: 6011*/
  BEGIN
    v_cred_cliente.v_sol := 1111;
    v_cred_cliente.v_ncli := 5;
    v_cred_cliente.v_f_sol := '20/03/2019';
    v_cred_cliente.v_f_oto := '22/03/2019';
    v_cred_cliente.v_monto_sol := 3000000;
    v_cred_cliente.v_monto_cred := 3200000;
    v_cred_cliente.v_total_cuo := 48;
    v_cred_cliente.v_cod_cred := 2;
    v_cred_cliente.v_id_suc := 6011;
    INSERT INTO credito_cliente VALUES
    (v_cred_cliente.v_sol, v_cred_cliente.v_ncli, v_cred_cliente.v_f_sol, v_cred_cliente.v_f_oto, v_cred_cliente.v_monto_sol,
    v_cred_cliente.v_monto_cred, v_cred_cliente.v_total_cuo, v_cred_cliente.v_cod_cred, v_cred_cliente.v_id_suc);
  END;
  /*? Ingresar un crédito para al cliente N°130 con los siguientes datos:
  o Número de solicitud: 2222
  o Fecha de solicitud del crédito: 12/03/2019
  o Fecha en que se otorgó el crédito: 13/03/2019
  o Monto solicitado: 800000
  o Monto del crédito (monto solicitado con la tasa de interés): 860000
  o Número de cuotas: 36
  o Tipo de crédito: Crédito de Consumo
  o Sucursal en la que se solicitó el crédito: 13132*/
  BEGIN
    v_cred_cliente.v_sol := 2222;
    v_cred_cliente.v_ncli := 130;
    v_cred_cliente.v_f_sol := '12/03/2019';
    v_cred_cliente.v_f_oto := '13/03/2019';
    v_cred_cliente.v_monto_sol := 800000;
    v_cred_cliente.v_monto_cred := 860000;
    v_cred_cliente.v_total_cuo := 36;
    v_cred_cliente.v_cod_cred := 2;
    v_cred_cliente.v_id_suc := 13132;
    INSERT INTO credito_cliente VALUES
    (v_cred_cliente.v_sol, v_cred_cliente.v_ncli, v_cred_cliente.v_f_sol, v_cred_cliente.v_f_oto, v_cred_cliente.v_monto_sol,
    v_cred_cliente.v_monto_cred, v_cred_cliente.v_total_cuo, v_cred_cliente.v_cod_cred, v_cred_cliente.v_id_suc);
  END;
  /*? Ingresar un crédito para el cliente N°130 con los siguientes datos:
  o Número de solicitud: 3333
  o Fecha de solicitud del crédito: 10/03/2019
  o Fecha en que se otorgó el crédito: 13/03/2019
  o Monto solicitado: 12000000
  o Monto del crédito (monto solicitado con la tasa de interés): 14500000
  o Número de cuotas: 36
  o Tipo de crédito: Crédito de Consumo
  o Sucursal en la que se solicitó el crédito: 13132*/
  BEGIN
    v_cred_cliente.v_sol := 3333;
    v_cred_cliente.v_ncli := 130;
    v_cred_cliente.v_f_sol := '10/03/2019';
    v_cred_cliente.v_f_oto := '13/03/2019';
    v_cred_cliente.v_monto_sol := 12000000;
    v_cred_cliente.v_monto_cred := 14500000;
    v_cred_cliente.v_total_cuo := 36;
    v_cred_cliente.v_cod_cred := 2;
    v_cred_cliente.v_id_suc := 13132;
    INSERT INTO credito_cliente VALUES
    (v_cred_cliente.v_sol, v_cred_cliente.v_ncli, v_cred_cliente.v_f_sol, v_cred_cliente.v_f_oto, v_cred_cliente.v_monto_sol,
    v_cred_cliente.v_monto_cred, v_cred_cliente.v_total_cuo, v_cred_cliente.v_cod_cred, v_cred_cliente.v_id_suc);
  END;
  /*? Eliminar el crédito con el número de solicitud 2015.*/
  BEGIN
    v_puntos_cred := 0;
    v_cred_cliente.v_sol := 2015;
    SELECT NRO_CLIENTE INTO v_cred_cliente.v_ncli FROM credito_cliente WHERE nro_solic_credito = v_cred_cliente.v_sol;
    IF v_cred_cliente.v_ncli IS NOT NULL THEN
      v_puntos_cred := FN_PUNTOS(v_cred_cliente.v_ncli);
      SELECT TOTAL_PUNTO INTO v_puntos FROM puntos_todo_suma WHERE nro_cliente = v_cred_cliente.v_ncli;
      IF v_puntos_cred = v_puntos THEN
        DELETE FROM puntos_todo_suma WHERE nro_cliente = v_cred_cliente.v_ncli;
        DELETE FROM credito_cliente WHERE nro_solic_credito = v_cred_cliente.v_sol;
      ELSIF v_puntos_cred <> v_puntos THEN
        UPDATE puntos_todo_suma
            SET total_puntos = (v_puntos - v_puntos_cred),
            fecha_actualizacion = sysdate
        WHERE nro_cliente = v_cred_cliente.v_ncli;
        DELETE FROM credito_cliente WHERE nro_solic_credito = v_cred_cliente.v_sol;
      END IF;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Cliente no existe!!!!!');
    END IF;
  END;  
END;

/*2.- Por cada cliente que ingresa al banco se completa una solitud de inscripción con sus datos personales los que posteriormente son ingresados
a través del Sistema. Opcionalmente él puede presentar una fotografía la que es digitalizada para ser incorporada a sus datos personales. Si al
momento de inscribirse no posee una fotografía, el cliente puede presentarla después si lo desea.
Sin embargo, considerando el aumento exponencial de la cartera de clientes, se van a modificar algunos de los requisitos para efectuar la inscripción
de los clientes. Por ejemplo, ahora el contar con la fotografía del cliente al momento de su inscripción será obligatorio como parte de los datos 
personales que se deben almacenar. Esto comenzará a ser requerido a contar del próximo mes y tiene como objetivo poder evitar fraudes ya que cada
vez que alguien desee solicitar algún crédito, los ejecutivos al consultar sus datos podrán ver la fotografía verificando que son la misma persona.
Esta nueva política, requiere poder contar con un proceso que en forma automática efectúe la incorporación progresiva de las fotografías de todos 
los clientes antiguos. Para ello, se ha definido que las nuevas fotografías que se deben incorporar a la tabla de clientes van a estar siempre en
la carpeta C:\imagenes\ fotos_clientes y el nombre de cada archivo va a corresponder al run (sin dígito verificador) del cliente.
Ud. ha optado por implementar este proceso a través de un Procedimiento Almacenado que será ejecutado a través de un trabajo programado en la Base
de Datos a las 22:00 horas. Efectuar una primera prueba con las fotos que entregan como ANEXO B.*/

-- SE CREA DIRECTORIO Y SE ASIGNA PRIVILEGIO DE LECTURA Y ESCRITURA AL USUARIO EN USO (ESTE PROCESO SE REALIZA E SYSTEM)
CREATE OR REPLACE DIRECTORY FOTOS_CLIENTES AS 'C:\imagenes\fotos_clientes';
GRANT READ, WRITE ON DIRECTORY FOTOS_CLIENTES TO etpby_fa;

--MEDIANTE BLOQUE ANONIMO SE INSERTAN LAS FOTOS A LA TABLA EMPLEADO
CREATE OR REPLACE PROCEDURE PR_ACTUALIZA_FOTO AS
  CURSOR c_fotos IS SELECT * FROM cliente;
  v_blob BLOB;
  v_bfile BFILE;
  v_nombre_archivo VARCHAR2(15 CHAR);
  v_cliente cliente.nro_cliente%TYPE;
  v_nom_funcion error_creditos_mensuales.rutina_error%TYPE;
  v_desc_error error_creditos_mensuales.descrip_error%TYPE;
BEGIN
  FOR a IN c_fotos LOOP
    v_nombre_archivo := (TO_CHAR(a.numrun) || '.JPG');
    SELECT FOTO INTO v_blob FROM cliente WHERE numrun = a.numrun FOR UPDATE;
    v_bfile := BFILENAME ('FOTOS_CLIENTES', v_nombre_archivo);
    DBMS_LOB.OPEN(v_bfile, DBMS_LOB.LOB_READONLY);
    DBMS_LOB.LOADFROMFILE(v_blob, v_bfile, DBMS_LOB.GETLENGTH(v_bfile));
    DBMS_LOB.CLOSE(v_bfile);
    v_cliente := a.nro_cliente;
  END LOOP;
  EXCEPTION                     
    WHEN OTHERS THEN
      v_nom_funcion := ('Error en PR_ACTUALIZA_FOTO en para el cliente ' || TO_CHAR(v_cliente));
            v_desc_error := SQLERRM;
            INSERT INTO error_creditos_mensuales VALUES (SEQ_CREDITO.nextval, v_nom_funcion, v_desc_error);
END PR_ACTUALIZA_FOTO;

/*3.- A contar de enero del próximo año entrará en vigencia la Ley de Créditos que obliga a todos los Bancos e Instituciones Financieras a aportar
un porcentaje de las ganancias de los créditos otorgados para la implementación de proyectos de formación de capital humano que permita insertar a 
Chile en la sociedad del conocimiento, dando así un impulso definitivo al desarrollo económico, social y cultural de nuestro país. Estos fondos serán
administrados por la Superintendencia de Bancos e Instituciones Financieras de Chile (SBIF) y por lo tanto va a solicitar, a todas las entidades de
estos rubros, disponibilizar mensualmente información de los créditos que se han otorgado.
De acuerdo con las políticas definidas por el SBIF, la información se debe obtener los días 11 de cada mes y debe permitir saber en detalle los créditos
que fueron otorgados en el mes anterior a la fecha de ejecución del proceso. Por ejemplo, si el proceso se ejecuta el 11 de enero del 2019, se deberá 
generar la información del mes de diciembre del 2018. Además, se debe enviar información resumida totalizando los valores por cada día en que se 
otorgaron créditos.
Ud. ha definido que el proceso que construirá será ejecutado automáticamente el día 11 de cada mes a la 1 AM y la información que se enviará a la SIBF
será a través de las tablas DETALLE_CREDITOS_MENSUALES y RESUMEN_CREDITOS_MENSUALES.
La información generada por este proceso, en conjunto con los procesos construidos en los puntos 1 y 2, van a permitir que el Banco cuente con 
información confiable y de calidad para, en una segunda etapa del proyecto, rediseñar los procesos de cobros de las tarjetas de créditos, productos 
de inversión, productos de ahorro y créditos.
3.1.- REGLAS DEL NEGOCIO A CONSIDERAR EN EL PROCESO
a) El banco tiene un plazo máximo de 5 días, a contar de la fecha de solicitud del crédito, para aprobar o no el crédito y el crédito rige a contar de
su fecha de otorgación.
b) La ley de Créditos considera que el aporte de los bancos e instituciones financieras a la SBIF estará basado en el monto total del crédito, es decir,
el monto del crédito con la tasa de interés aplicada.
c) La ley de Créditos define que el valor del aporte de los bancos e instituciones financieras a la SBIF será de la siguiente manera:

+-------------------------------+------------------------------------+
?   MONTO DEL CRÉDITO          ?  APORTE PARA ENTREGAR A LA SIBF   ?
+-------------------------------+------------------------------------+
?Entre $100.000 y $1.000.000   ?    1% del monto del crédito       ?
?Entre $1.000.001 y $2.000.000 ?    2% del monto del crédito       ?
?Entre $2.000.001 y $4.000.000 ?    3% del monto del crédito       ?
?Entre $4.000.001 y $6.000.000 ?    4% del monto del crédito       ?
?Mayor a $6.000.000            ?    7% del monto del crédito       ?
+-------------------------------+------------------------------------+

3.2.- REQUERIMIENTOS MÍNIMOS, EN TÉRMINOS DE DISEÑO, PARA CONSTRUIR EL PROCESO
a) Construir un Package que contenga como mínimo 2 funciones públicas y 4 variables públicas:
  ? Una función que debe obtener la fecha de vencimiento de la primera cuota del crédito del cliente.
  ? Una función que debe obtener la fecha de vencimiento de la última cuota del crédito del cliente.
  ? Las variables públicas deben ser usadas para asignar los porcentajes del monto del crédito que se debe entregar al SIBF.*/

--SUBPROGRAMA ADICIONAL
CREATE OR REPLACE FUNCTION fn_nro_cuotas
  (v_n_sol_cred cuota_credito_cliente.nro_solic_credito%TYPE) RETURN NUMBER IS
  v_cuotas NUMBER;
  v_nom_funcion error_creditos_mensuales.rutina_error%TYPE;
  v_desc_error error_creditos_mensuales.descrip_error%TYPE;
BEGIN
  SELECT COUNT(NRO_SOLIC_CREDITO) INTO v_cuotas FROM CUOTA_CREDITO_CLIENTE WHERE NRO_SOLIC_CREDITO = v_n_sol_cred;  
  RETURN v_cuotas;
  EXCEPTION                     
    WHEN OTHERS THEN
      v_nom_funcion := ('Error en FN_NRO_CUOTAS en para Crédito N° ' || TO_CHAR(v_n_sol_cred));
      v_desc_error := SQLERRM;
      INSERT INTO error_creditos_mensuales VALUES (SEQ_CREDITO.nextval, v_nom_funcion, v_desc_error);
      RETURN 0;
END fn_nro_cuotas;

--CREA PACKAGE CON 2 FUNCIONES DE OBTENCION DE FECHAS Y VARIABLES PUBLICAS
CREATE OR REPLACE 
PACKAGE PK_VARIABLES_Y_FECHAS AS 
  v_porc_monto_1 NUMBER;
  v_porc_monto_2 NUMBER;
  v_porc_monto_3 NUMBER;
  v_porc_monto_4 NUMBER;
  v_porc_monto_5 NUMBER;
  FUNCTION FN_CALC_FECHA_CUOTA_INI (v_n_sol_cred cuota_credito_cliente.nro_solic_credito%TYPE) RETURN DATE;
  FUNCTION FN_CALC_FECHA_CUOTA_FIN (v_n_sol_cred cuota_credito_cliente.nro_solic_credito%TYPE) RETURN DATE;
END PK_VARIABLES_Y_FECHAS;

CREATE OR REPLACE
PACKAGE BODY PK_VARIABLES_Y_FECHAS AS
  FUNCTION FN_CALC_FECHA_CUOTA_INI
    (v_n_sol_cred cuota_credito_cliente.nro_solic_credito%TYPE) RETURN DATE IS
    v_fec_vec_cou_ini DATE;
    v_n_sol cuota_credito_cliente.nro_solic_credito%TYPE;
    v_n_cuota cuota_credito_cliente.nro_cuota%TYPE;
    v_nom_funcion error_creditos_mensuales.rutina_error%TYPE;
    v_desc_error error_creditos_mensuales.descrip_error%TYPE;
  BEGIN
    SELECT NRO_SOLIC_CREDITO, NRO_CUOTA, FECHA_VENC_CUOTA INTO v_n_sol, v_n_cuota,v_fec_vec_cou_ini
    FROM CUOTA_CREDITO_CLIENTE
    WHERE NRO_SOLIC_CREDITO = v_n_sol_cred AND NRO_CUOTA = 1;
    RETURN v_fec_vec_cou_ini;
    EXCEPTION                     
      WHEN OTHERS THEN
        v_nom_funcion := ('Error en FN_CALC_FECHA_CUOTA_INI (PACKAGE) en para Crédito N° ' || TO_CHAR(v_n_sol_cred));
        v_desc_error := SQLERRM;
        INSERT INTO error_creditos_mensuales VALUES (SEQ_CREDITO.nextval, v_nom_funcion, v_desc_error);
        RETURN NULL;
  END FN_CALC_FECHA_CUOTA_INI;

  FUNCTION FN_CALC_FECHA_CUOTA_FIN
    (v_n_sol_cred cuota_credito_cliente.nro_solic_credito%TYPE) RETURN DATE IS
    v_fec_vec_cou_ini DATE;
    v_n_sol cuota_credito_cliente.nro_solic_credito%TYPE;
    v_n_cuota cuota_credito_cliente.nro_cuota%TYPE;
    v_nom_funcion error_creditos_mensuales.rutina_error%TYPE;
    v_desc_error error_creditos_mensuales.descrip_error%TYPE;
  BEGIN
    SELECT NRO_SOLIC_CREDITO, NRO_CUOTA, FECHA_VENC_CUOTA INTO v_n_sol, v_n_cuota,v_fec_vec_cou_ini
    FROM CUOTA_CREDITO_CLIENTE
    WHERE NRO_SOLIC_CREDITO = v_n_sol_cred AND NRO_CUOTA = FN_NRO_CUOTAS(v_n_sol_cred);
    RETURN v_fec_vec_cou_ini;
    EXCEPTION                     
      WHEN OTHERS THEN
        v_nom_funcion := ('Error en FN_CALC_FECHA_CUOTA_FIN (PACKAGE) en para Crédito N° ' || TO_CHAR(v_n_sol_cred));
        v_desc_error := SQLERRM;
        INSERT INTO error_creditos_mensuales VALUES (SEQ_CREDITO.nextval, v_nom_funcion, v_desc_error);
        RETURN NULL;
  END FN_CALC_FECHA_CUOTA_FIN;
END PK_VARIABLES_Y_FECHAS;

--b) Construir una Función Almacenada que debe obtener la región en la se encuentra la sucursal que le otorgó el crédito al cliente.
CREATE OR REPLACE FUNCTION FN_OBT_REGION
  (v_idsuc sucursal_banco.id_sucursal%TYPE) RETURN VARCHAR2 IS
  v_region VARCHAR2(50 BYTE);
  v_id sucursal_banco.id_sucursal%TYPE;
  v_cod sucursal_banco.cod_region%TYPE;
  v_nom_funcion error_creditos_mensuales.rutina_error%TYPE;
  v_desc_error error_creditos_mensuales.descrip_error%TYPE;
BEGIN
  SELECT S.ID_SUCURSAL, S.COD_REGION, R.NOMBRE_REGION
  INTO v_id, v_cod, v_region
  FROM SUCURSAL_BANCO S LEFT JOIN REGION R
  ON(S.COD_REGION = R.COD_REGION)
  WHERE S.ID_SUCURSAL = v_idsuc;
  RETURN v_region;
  EXCEPTION                     
    WHEN OTHERS THEN
      v_nom_funcion := ('Error en FN_OBT_REGION para la sucursal ' || TO_CHAR(v_idsuc));
      v_desc_error := SQLERRM;
      INSERT INTO error_creditos_mensuales VALUES (SEQ_CREDITO.nextval, v_nom_funcion, v_desc_error);
      RETURN NULL;
END FN_OBT_REGION;

--c) Construir una Función Almacenada que debe obtener la provincia en la que se encuentra la sucursal que le otorgó el crédito al cliente.
CREATE OR REPLACE FUNCTION FN_OBT_PROVINCIA
  (v_idsuc sucursal_banco.id_sucursal%TYPE, v_region sucursal_banco.cod_region%TYPE) RETURN VARCHAR2 IS
  v_provincia VARCHAR2(50 BYTE);
  v_id sucursal_banco.id_sucursal%TYPE;
  v_reg sucursal_banco.cod_region%TYPE;
  v_cod sucursal_banco.cod_provincia%TYPE;
  v_nom_funcion error_creditos_mensuales.rutina_error%TYPE;
  v_desc_error error_creditos_mensuales.descrip_error%TYPE;
BEGIN
  SELECT S.ID_SUCURSAL, S.COD_PROVINCIA, P.COD_REGION, P.NOMBRE_PROVINCIA
  INTO v_id, v_cod, v_reg, v_provincia
  FROM SUCURSAL_BANCO S LEFT JOIN PROVINCIA P
  ON(S.COD_PROVINCIA = P.COD_PROVINCIA)
  WHERE S.ID_SUCURSAL = v_idsuc AND P.COD_REGION = v_region;
  RETURN v_provincia;
  EXCEPTION                     
    WHEN OTHERS THEN
      v_nom_funcion := ('Error en FN_OBT_PROVINCIA para la sucursal ' || TO_CHAR(v_idsuc));
      v_desc_error := SQLERRM;
      INSERT INTO error_creditos_mensuales VALUES (SEQ_CREDITO.nextval, v_nom_funcion, v_desc_error);
      RETURN NULL;
END FN_OBT_PROVINCIA;

--d) Construir una Función Almacenada que debe obtener la comuna en la que se encuentra la sucursal que le otorgó el crédito al cliente.
CREATE OR REPLACE FUNCTION FN_OBT_COMUNA
  (v_idsuc sucursal_banco.id_sucursal%TYPE, v_region sucursal_banco.cod_region%TYPE, v_provi sucursal_banco.cod_provincia%TYPE) RETURN VARCHAR2 IS
  v_comuna VARCHAR2(50 BYTE);
  v_id sucursal_banco.id_sucursal%TYPE;
  v_reg sucursal_banco.cod_region%TYPE;
  v_prov sucursal_banco.cod_provincia%TYPE;
  v_com sucursal_banco.cod_comuna%TYPE;
  v_nom_funcion error_creditos_mensuales.rutina_error%TYPE;
  v_desc_error error_creditos_mensuales.descrip_error%TYPE;
BEGIN
  SELECT S.ID_SUCURSAL, C.COD_REGION, C.COD_PROVINCIA, C.COD_COMUNA, C.NOMBRE_COMUNA
  INTO v_id, v_reg, v_prov, v_com, v_comuna
  FROM SUCURSAL_BANCO S LEFT JOIN COMUNA C
  ON(S.COD_COMUNA = C.COD_COMUNA)
  WHERE S.ID_SUCURSAL = v_idsuc AND C.COD_REGION = v_region AND C.COD_PROVINCIA = v_provi;
  RETURN v_comuna;
  EXCEPTION                     
    WHEN OTHERS THEN
      v_nom_funcion := ('Error en FN_OBT_COMUNA para la sucursal ' || TO_CHAR(v_idsuc));
      v_desc_error := SQLERRM;
      INSERT INTO error_creditos_mensuales VALUES (SEQ_CREDITO.nextval, v_nom_funcion, v_desc_error);
      RETURN NULL;
END FN_OBT_COMUNA;

/*e) Construir un Procedimiento Almacenado principal para genere la información detallada y resumida de los créditos otorgados en el mes y que debe 
ser enviada a la SIBF.
El procedimiento debe integrar el uso de los constructores provistos en el Package y Funciones Almacenadas. Este procedimiento debe almacenar los
resultados en las tablas:
  ? DETALLE_CREDITOS_MENSUALES: la información debe estar ordenada por fecha de otorgamiento del crédito, identificación de la sucursal, región, 
  provincia, comuna y run del cliente
  ? RESUMEN_CREDITOS_MENSUALES: la información debe estar ordenada por fecha de otorgamiento del crédito.*/

--SE CREA SECUENCIA PARA LLENADO EN TABLA DETALLE_CREDITOS_MENSUALES
CREATE SEQUENCE SEQ_DET_CREDITO;
--SE CREA SECUENCIA PARA LLENADO EN TABLA DETALLE_CREDITOS_MENSUALES
CREATE SEQUENCE SEQ_RES_CREDITO;

--SE CREA PROCEDIMIENTO SOLICITADO PARA INGRESO DE DATOS EN TABLAS DETALLE_CREDITOS_MENSUALES Y RESUMEN_CREDITOS_MENSUALES
CREATE OR REPLACE PROCEDURE PR_ENTREGA_SIBF AS
  CURSOR c_detalle_cred IS 
  SELECT C.NRO_SOLIC_CREDITO, C.NRO_CLIENTE, C.FECHA_SOLIC_CRED, C.FECHA_OTORGA_CRED,
    C.MONTO_SOLICITADO, C.MONTO_CREDITO, C.COD_CREDITO, C.ID_SUCURSAL, S.COD_REGION, 
    S.COD_PROVINCIA, S.COD_COMUNA
    FROM CREDITO_CLIENTE C 
    LEFT JOIN SUCURSAL_BANCO S
    ON(C.ID_SUCURSAL = S.ID_SUCURSAL)
    WHERE C.FECHA_OTORGA_CRED = (sysdate-30);
  v_fecha_porc DATE := (sysdate-30);
  v_region DETALLE_CREDITOS_MENSUALES.REGION%TYPE;
  v_provincia DETALLE_CREDITOS_MENSUALES.PROVINCIA%TYPE;
  v_comuna DETALLE_CREDITOS_MENSUALES.COMUNA%TYPE;
  v_tipocred DETALLE_CREDITOS_MENSUALES.TIPO_CREDITO%TYPE;
  v_rut DETALLE_CREDITOS_MENSUALES.RUN_CLIENTE%TYPE;
  v_nombrecli DETALLE_CREDITOS_MENSUALES.NOMBRE_CLIENTE%TYPE;
  v_cuotas NUMBER;
  v_fechainicial DATE;
  v_fechafinal DATE;
  v_monto_sbif NUMBER;
  v_nom_funcion error_creditos_mensuales.rutina_error%TYPE;
  v_desc_error error_creditos_mensuales.descrip_error%TYPE;
BEGIN
  FOR a IN c_detalle_cred
  LOOP
    v_region := FN_OBT_REGION(a.id_sucursal);
    v_provincia := FN_OBT_PROVINCIA(a.id_sucursal, a.cod_region);
    v_comuna := FN_OBT_COMUNA(a.id_sucursal, a.cod_region, a.cod_provincia);
    SELECT C.NOMBRE_CREDITO INTO v_tipocred 
      FROM CREDITO_CLIENTE CL JOIN CREDITO C
      ON(CL.COD_CREDITO = C.COD_CREDITO) WHERE C.COD_CREDITO = a.cod_credito;
    SELECT (TO_CHAR(NUMRUN, '99G999G999') || '-' || DVRUN) INTO v_rut
      FROM CLIENTE WHERE NRO_CLIENTE = a.nro_cliente;
    SELECT INITCAP(PNOMBRE || ' ' || SNOMBRE || ' ' || APPATERNO || ' ' || APMATERNO) INTO v_nombrecli
      FROM CLIENTE WHERE NRO_CLIENTE = a.nro_cliente;
    v_cuotas := FN_NRO_CUOTAS(a.nro_solic_credito);
    v_fechainicial := PK_VARIABLES_Y_FECHAS.FN_CALC_FECHA_CUOTA_INI(a.nro_solic_credito);
    v_fechafinal := PK_VARIABLES_Y_FECHAS.FN_CALC_FECHA_CUOTA_FIN(a.nro_solic_credito);
    PK_VARIABLES_Y_FECHAS.v_porc_monto_1 := 0.01;
    PK_VARIABLES_Y_FECHAS.v_porc_monto_2 := 0.02;
    PK_VARIABLES_Y_FECHAS.v_porc_monto_3 := 0.03;
    PK_VARIABLES_Y_FECHAS.v_porc_monto_4 := 0.04;
    PK_VARIABLES_Y_FECHAS.v_porc_monto_5 := 0.07;
    v_monto_sbif := CASE
                      WHEN a.monto_credito BETWEEN 100000 AND 1000000 THEN 
                        ROUND(a.monto_credito * PK_VARIABLES_Y_FECHAS.v_porc_monto_1)
                      WHEN a.monto_credito BETWEEN 1000001 AND 2000000 THEN 
                        ROUND(a.monto_credito * PK_VARIABLES_Y_FECHAS.v_porc_monto_2)
                      WHEN a.monto_credito BETWEEN 2000001 AND 4000000 THEN 
                        ROUND(a.monto_credito * PK_VARIABLES_Y_FECHAS.v_porc_monto_3)
                      WHEN a.monto_credito BETWEEN 4000001 AND 6000000 THEN 
                        ROUND(a.monto_credito * PK_VARIABLES_Y_FECHAS.v_porc_monto_4)
                      WHEN a.monto_credito > 6000000  THEN 
                        ROUND(a.monto_credito * PK_VARIABLES_Y_FECHAS.v_porc_monto_5)
                      ELSE 0
                    END;
  /*? DETALLE_CREDITOS_MENSUALES: la información debe estar ordenada por fecha de otorgamiento del crédito, identificación de la sucursal, región, 
  provincia, comuna y run del cliente*/
    INSERT INTO DETALLE_CREDITOS_MENSUALES VALUES
      (SEQ_DET_CREDITO.NEXTVAL, TO_CHAR(v_fecha_porc, 'MM/YYYY'), a.fecha_otorga_cred, a.id_sucursal, v_region, v_provincia, v_comuna,
      a.nro_solic_credito, v_tipocred, a.nro_cliente, v_rut, v_nombrecli, a.monto_solicitado, a.monto_credito, v_cuotas, v_fechainicial,
      v_fechafinal, v_monto_sbif);
--? RESUMEN_CREDITOS_MENSUALES: la información debe estar ordenada por fecha de otorgamiento del crédito.
    INSERT INTO RESUMEN_CREDITOS_MENSUALES VALUES
      (SEQ_RES_CREDITO.NEXTVAL, TO_CHAR(v_fecha_porc, 'MM/YYYY'), a.fecha_otorga_cred, a.monto_solicitado, a.monto_credito, v_monto_sbif);
  END LOOP;
  EXCEPTION                     
    WHEN OTHERS THEN
      v_nom_funcion := ('Error en PR_ENTREGA_SIBF al Insertar Datos ');
        v_desc_error := SQLERRM;
        INSERT INTO error_creditos_mensuales VALUES (SEQ_CREDITO.nextval, v_nom_funcion, v_desc_error);
END PR_ENTREGA_SIBF;

--f) Mínimo en 2 programas PL/SQL se debe implementar el uso de SQL Dinámico para recuperar información.
--SQL DINAMICO VER REGISTROS EN TABLA  DETALLES_CREDITOS_MESUALES
CREATE OR REPLACE PROCEDURE PR_SQLDIN_1 AS
  v_nom_funcion error_creditos_mensuales.rutina_error%TYPE;
  v_desc_error error_creditos_mensuales.descrip_error%TYPE;
BEGIN
  EXECUTE IMMEDIATE 'SELECT * FROM DETALLES_CREDITOS_MESUALES';
  EXCEPTION                     
    WHEN OTHERS THEN
      v_nom_funcion := ('Error en PR_SQLDIN_1 ');
      v_desc_error := SQLERRM;
      INSERT INTO error_creditos_mensuales VALUES (SEQ_CREDITO.nextval, v_nom_funcion, v_desc_error);
END PR_SQLDIN_1;

--SQL DINAMICO VER REGISTROS EN TABLA  RESUMEN_CREDITOS_MESUALES
CREATE OR REPLACE PROCEDURE PR_SQLDIN_2 AS
  v_nom_funcion error_creditos_mensuales.rutina_error%TYPE;
  v_desc_error error_creditos_mensuales.descrip_error%TYPE;
BEGIN
  EXECUTE IMMEDIATE 'SELECT * FROM RESUMEN_CREDITOS_MESUALES';
  EXCEPTION                     
    WHEN OTHERS THEN
      v_nom_funcion := ('Error en PR_SQLDIN_2 ');
      v_desc_error := SQLERRM;
      INSERT INTO error_creditos_mensuales VALUES (SEQ_CREDITO.nextval, v_nom_funcion, v_desc_error);
END PR_SQLDIN_2;


-- EMPLEABILIDAD 2° OPCION PARA PROCEDIMIENTO PRINCIPAL
CREATE OR REPLACE PROCEDURE PR_ENTREGA_SIBF AS
  CURSOR c_detalle_cred IS 
  SELECT C.NRO_SOLIC_CREDITO, C.NRO_CLIENTE, C.FECHA_SOLIC_CRED, C.FECHA_OTORGA_CRED,
    C.MONTO_SOLICITADO, C.MONTO_CREDITO, C.COD_CREDITO, C.ID_SUCURSAL, S.COD_REGION, 
    S.COD_PROVINCIA, S.COD_COMUNA
    FROM CREDITO_CLIENTE C 
    LEFT JOIN SUCURSAL_BANCO S
    ON(C.ID_SUCURSAL = S.ID_SUCURSAL)
    WHERE C.FECHA_OTORGA_CRED = (sysdate-30);
  v_fecha_porc DATE := (sysdate-30);
  v_region DETALLE_CREDITOS_MENSUALES.REGION%TYPE;
  v_provincia DETALLE_CREDITOS_MENSUALES.PROVINCIA%TYPE;
  v_comuna DETALLE_CREDITOS_MENSUALES.COMUNA%TYPE;
  v_tipocred DETALLE_CREDITOS_MENSUALES.TIPO_CREDITO%TYPE;
  v_rut DETALLE_CREDITOS_MENSUALES.RUN_CLIENTE%TYPE;
  v_nombrecli DETALLE_CREDITOS_MENSUALES.NOMBRE_CLIENTE%TYPE;
  v_cuotas NUMBER;
  v_fechainicial DATE;
  v_fechafinal DATE;
  v_monto_sbif NUMBER;
  v_nom_funcion error_creditos_mensuales.rutina_error%TYPE;
  v_desc_error error_creditos_mensuales.descrip_error%TYPE;
BEGIN
  FOR a IN c_detalle_cred
  LOOP
    v_region := FN_OBT_REGION(a.id_sucursal);
    v_provincia := FN_OBT_PROVINCIA(a.id_sucursal, a.cod_region);
    v_comuna := FN_OBT_COMUNA(a.id_sucursal, a.cod_region, a.cod_provincia);
    SELECT C.NOMBRE_CREDITO INTO v_tipocred 
      FROM CREDITO_CLIENTE CL JOIN CREDITO C
      ON(CL.COD_CREDITO = C.COD_CREDITO) WHERE C.COD_CREDITO = a.cod_credito;
    SELECT (TO_CHAR(NUMRUN, '99G999G999') || '-' || DVRUN) INTO v_rut
      FROM CLIENTE WHERE NRO_CLIENTE = a.nro_cliente;
    SELECT INITCAP(PNOMBRE || ' ' || SNOMBRE || ' ' || APPATERNO || ' ' || APMATERNO) INTO v_nombrecli
      FROM CLIENTE WHERE NRO_CLIENTE = a.nro_cliente;
    v_cuotas := FN_NRO_CUOTAS(a.nro_solic_credito);
    v_fechainicial := PK_VARIABLES_Y_FECHAS.FN_CALC_FECHA_CUOTA_INI(a.nro_solic_credito);
    v_fechafinal := PK_VARIABLES_Y_FECHAS.FN_CALC_FECHA_CUOTA_FIN(a.nro_solic_credito);
    PK_VARIABLES_Y_FECHAS.v_porc_monto_1 := 1;
    PK_VARIABLES_Y_FECHAS.v_porc_monto_2 := 2;
    PK_VARIABLES_Y_FECHAS.v_porc_monto_3 := 3;
    PK_VARIABLES_Y_FECHAS.v_porc_monto_4 := 4;
    PK_VARIABLES_Y_FECHAS.v_porc_monto_5 := 7;
    IF a.monto_credito BETWEEN 100000 AND 1000000 THEN
      v_monto_sbif := ROUND((a.monto_credito * PK_VARIABLES_Y_FECHAS.v_porc_monto_1)/100);
    ELSIF a.monto_credito BETWEEN 1000001 AND 2000000 THEN 
      v_monto_sbif := ROUND((a.monto_credito * PK_VARIABLES_Y_FECHAS.v_porc_monto_2)/100);
    ELSIF a.monto_credito BETWEEN 2000001 AND 4000000 THEN 
      v_monto_sbif := ROUND((a.monto_credito * PK_VARIABLES_Y_FECHAS.v_porc_monto_3)/100);
    ELSIF a.monto_credito BETWEEN 4000001 AND 6000000 THEN 
      v_monto_sbif := ROUND((a.monto_credito * PK_VARIABLES_Y_FECHAS.v_porc_monto_4)/100);
    ELSIF a.monto_credito > 6000000  THEN 
      v_monto_sbif := ROUND((a.monto_credito * PK_VARIABLES_Y_FECHAS.v_porc_monto_5)/100);
    ELSE 
      v_monto_sbif := 0;
    END IF;
  /*? DETALLE_CREDITOS_MENSUALES: la información debe estar ordenada por fecha de otorgamiento del crédito, identificación de la sucursal, región, 
  provincia, comuna y run del cliente*/
    INSERT INTO DETALLE_CREDITOS_MENSUALES VALUES
      (SEQ_DET_CREDITO.NEXTVAL, TO_CHAR(v_fecha_porc, 'MM/YYYY'), a.fecha_otorga_cred, a.id_sucursal, v_region, v_provincia, v_comuna,
      a.nro_solic_credito, v_tipocred, a.nro_cliente, v_rut, v_nombrecli, a.monto_solicitado, a.monto_credito, v_cuotas, v_fechainicial,
      v_fechafinal, v_monto_sbif);
--? RESUMEN_CREDITOS_MENSUALES: la información debe estar ordenada por fecha de otorgamiento del crédito.
    INSERT INTO RESUMEN_CREDITOS_MENSUALES VALUES
      (SEQ_RES_CREDITO.NEXTVAL, TO_CHAR(v_fecha_porc, 'MM/YYYY'), a.fecha_otorga_cred, a.monto_solicitado, a.monto_credito, v_monto_sbif);
  END LOOP;
  EXCEPTION                     
    WHEN OTHERS THEN
      v_nom_funcion := ('Error en PR_ENTREGA_SIBF al Insertar Datos ');
        v_desc_error := SQLERRM;
        INSERT INTO error_creditos_mensuales VALUES (SEQ_CREDITO.nextval, v_nom_funcion, v_desc_error);
END PR_ENTREGA_SIBF;
