set serveroutput on
declare
x varchar2(100);
begin
for i in (select * from user_tables where table_name in ('AUTO','CONCESIONARIO','CLIENTE','DISTRIBUCION','COLOR','VENTA','CIUDAD','MARCA','REGION','VENDEDOR','COLOR')) loop
x:='drop table '||i.table_name||' cascade constraints';
execute immediate x;
dbms_output.put_line(x);
end loop;
end;
/

CREATE TABLE REGION
(
cod_region NUMBER NOT NULL,
nombre_region VARCHAR(20) NOT NULL,
CONSTRAINT region_pk PRIMARY KEY (cod_region)
);
INSERT INTO REGION VALUES(1,'Atacama');
INSERT INTO REGION VALUES(2,'Coquimbo');
INSERT INTO REGION VALUES(3,'RM');
INSERT INTO REGION VALUES(4,'Bio-Bio');

CREATE TABLE CIUDAD
(
cod_ciudad NUMBER NOT NULL,
nombre VARCHAR(20) NOT NULL,
cod_region NUMBER NOT NULL,
CONSTRAINT ciudad_pk PRIMARY KEY (cod_ciudad),
CONSTRAINT ciudad_region_fk FOREIGN KEY (cod_region) REFERENCES REGION (cod_region)
);
INSERT INTO CIUDAD VALUES(1,'Tocopilla',1);
INSERT INTO CIUDAD VALUES(2,'La Serena',2);
INSERT INTO CIUDAD VALUES(3,'Coquimbo',2);
INSERT INTO CIUDAD VALUES(4,'Buin',3);
INSERT INTO CIUDAD VALUES(5,'Concepcion',4);

CREATE TABLE CONCESIONARIO
(
cod_conc NUMBER NOT NULL,
nombre VARCHAR(20) NOT NULL,
cod_ciudad NUMBER NOT NULL,
CONSTRAINT concesionario_pk PRIMARY KEY (cod_conc),
CONSTRAINT concesionario_ciudad_fk FOREIGN KEY (cod_ciudad) REFERENCES CIUDAD (cod_ciudad)
);
INSERT INTO CONCESIONARIO VALUES(1,'Arkano Cars',2);
INSERT INTO CONCESIONARIO VALUES(2,'Bonilla Automobile',2);
INSERT INTO CONCESIONARIO VALUES(3,'Cicero Motors',3);
INSERT INTO CONCESIONARIO VALUES(4,'Dangelos Racing',1);
INSERT INTO CONCESIONARIO VALUES(5,'Enzo Speedster',5);

CREATE TABLE VENDEDOR
(
cod_vendedor VARCHAR2 (4) NOT NULL ,
nom_vendedor VARCHAR2 (30) NOT NULL ,
fechnac_vendedor DATE NOT NULL ,
sexo         CHAR(1) NOT NULL,
cod_conc     NUMBER NOT NULL,
minimo_anio  NUMBER(4) NULL,
CONSTRAINT vendedor_pk PRIMARY KEY ( cod_vendedor ),
CONSTRAINT vendedor_concesionario_fk FOREIGN KEY (cod_conc) REFERENCES CONCESIONARIO (cod_conc)
);

INSERT INTO VENDEDOR VALUES ('A100','Rodrigo Alvarez',to_date('03/10/1965','DD/MM/YYYY'),'M',1,NULL);
insert into vendedor values ('A290','Ernesto Barrera',to_date('19/12/1970','DD/MM/YYYY'),'M',2,NULL);
insert into vendedor values ('M560','Miguel Chavez',to_date('04/09/1985','DD/MM/YYYY'),'M',5,NULL);
insert into vendedor values ('A400','Victor Mendoza',to_date('03/10/1965','DD/MM/YYYY'),'M',1,NULL);
insert into vendedor values ('M640','Paula Meza',to_date('19/12/1970','DD/MM/YYYY'),'F',2,NULL);
insert into vendedor values ('M620','Ivan Millan',to_date('3/07/1980','DD/MM/YYYY'),'M',3,NULL);
insert into vendedor values ('C400','Pedro Muga',to_date('20/07/1978','DD/MM/YYYY'),'M',4,NULL);
insert into vendedor values ('R400','Loreto Valenzuela',to_date('03/08/1978','DD/MM/YYYY'),'F',1,NULL);
insert into vendedor values ('R600','Guadalupe Vidal',to_date('07/07/1972','DD/MM/YYYY'),'F',3,NULL);

CREATE TABLE MARCA
(
cod_marca NUMBER NOT NULL,
nombre VARCHAR(20) NOT NULL,
CONSTRAINT marca_pk PRIMARY KEY (cod_marca)
);
INSERT INTO MARCA VALUES(1,'Seat');
INSERT INTO MARCA VALUES(2,'Renault');
INSERT INTO MARCA VALUES(3,'Citroen');
INSERT INTO MARCA VALUES(4,'Audi');
INSERT INTO MARCA VALUES(5,'Opel');
INSERT INTO MARCA VALUES(6,'Bmw');

CREATE TABLE AUTO
(
cod_auto NUMBER NOT NULL,
modelo VARCHAR(20) NOT NULL,
auto_version VARCHAR(10) NOT NULL,
cod_marca NUMBER NOT NULL,
CONSTRAINT auto_pk PRIMARY KEY (cod_auto),
CONSTRAINT auto_marca_fk FOREIGN KEY (cod_marca) REFERENCES MARCA (cod_marca)
);
INSERT INTO AUTO VALUES (1,'ibiza','16V',1);
INSERT INTO AUTO VALUES (2,'ibiza','tsi',1);
INSERT INTO AUTO VALUES (3,'ibiza','tdi',1);
INSERT INTO AUTO VALUES (4,'leon','Style Copa',1);
INSERT INTO AUTO VALUES (5,'altea','ecomotive',1);
INSERT INTO AUTO VALUES (6,'megane','GT Line',2);
INSERT INTO AUTO VALUES (7,'megane','gti',2);
INSERT INTO AUTO VALUES (8,'laguna','Berlina',2);
INSERT INTO AUTO VALUES (9,'laguna','coupé',3);
INSERT INTO AUTO VALUES (10,'c4','16V',3);
INSERT INTO AUTO VALUES (11,'c4','hdi',3);
INSERT INTO AUTO VALUES (12,'c5','hdi',4);
INSERT INTO AUTO VALUES (13,'a4','1.8',4);
INSERT INTO AUTO VALUES (14,'a4','2.8',5);
INSERT INTO AUTO VALUES (15,'astra','caravan',5);
INSERT INTO AUTO VALUES (16,'astra','gti',5);
INSERT INTO AUTO VALUES (17,'corsa','1.4',5);
INSERT INTO AUTO VALUES (18,'3','318d',6);
INSERT INTO AUTO VALUES (19,'5','520d',6);
INSERT INTO AUTO VALUES (20,'7','730d',6);

CREATE TABLE COLOR
(
cod_color NUMBER NOT NULL,
color VARCHAR(10) NOT NULL,
CONSTRAINT color_pk PRIMARY KEY (cod_color)
);
INSERT INTO COLOR VALUES(1,'blanco');
INSERT INTO COLOR VALUES(2,'rojo');
INSERT INTO COLOR VALUES(3,'gris');
INSERT INTO COLOR VALUES(4,'azul');
INSERT INTO COLOR VALUES(5,'amarillo');
INSERT INTO COLOR VALUES(6,'verde');

CREATE TABLE DISTRIBUCION
(
cod_conc NUMBER NOT NULL,
cod_auto NUMBER NOT NULL,
cantidad NUMBER NOT NULL,
CONSTRAINT distribucion_pk PRIMARY KEY(cod_conc,cod_auto),
CONSTRAINT distribucion_auto_fk FOREIGN KEY (cod_auto) REFERENCES AUTO,
CONSTRAINT distribucion_concesionario_fk FOREIGN KEY (cod_conc) REFERENCES CONCESIONARIO
);
INSERT INTO DISTRIBUCION VALUES (1,1,3);
INSERT INTO DISTRIBUCION VALUES (1,5,7);
INSERT INTO DISTRIBUCION VALUES (1,6,7);
INSERT INTO DISTRIBUCION VALUES (1,7,5);
INSERT INTO DISTRIBUCION VALUES (1,8,10);
INSERT INTO DISTRIBUCION VALUES (2,9,10);
INSERT INTO DISTRIBUCION VALUES (2,10,5);
INSERT INTO DISTRIBUCION VALUES (2,11,3);
INSERT INTO DISTRIBUCION VALUES (2,12,5);
INSERT INTO DISTRIBUCION VALUES (3,13,10);
INSERT INTO DISTRIBUCION VALUES (3,14,5);
INSERT INTO DISTRIBUCION VALUES (3,15,10);
INSERT INTO DISTRIBUCION VALUES (3,16,20);
INSERT INTO DISTRIBUCION VALUES (3,17,8);

CREATE TABLE CLIENTE
(
rut VARCHAR(10) NOT NULL,
nombre VARCHAR(20) NOT NULL,
apellidop VARCHAR(30) NOT NULL,
apellidom VARCHAR(30) NOT NULL,
direccion VARCHAR(100) NOT NULL,
telefono NUMBER(8) NOT NULL,
email VARCHAR(255) NOT NULL,
fecha_nacimiento date NOT NULL,
sexo CHAR(1) NOT NULL,
cod_ciudad NUMBER NOT NULL,
CONSTRAINT cliente_pk PRIMARY KEY (rut),
CONSTRAINT cliente_ciudad_fk FOREIGN KEY (cod_ciudad) REFERENCES CIUDAD (cod_ciudad)
);
INSERT INTO CLIENTE VALUES('08798234-9','Luis','Garcia','Ramirez','Málaga 753',78452378,'lgarcia@gmail.com',to_date('12041977','ddmmyyyy'),'M',1);
INSERT INTO CLIENTE VALUES('12378095-8','Antonio','Lopez','Tapia','Bravante 1345',97642378,'alt@hotmail.com',to_date('18071985','ddmmyyyy'),'M',4);
INSERT INTO CLIENTE VALUES('13453473-7','Juan','Martin','Subiabre','Esposito 9865',23568945,'jumarsu@mixmail.com',to_date('11101963','ddmmyyyy'),'M',1);
INSERT INTO CLIENTE VALUES('09578984-k','Maria','Garcia','Faundez','America Sur 92',36789032,'mariagarciafaundez@gmail.com',to_date('23051959','ddmmyyyy'),'F',2);
INSERT INTO CLIENTE VALUES('15564879-1','Gaston','Jordan','Borquez','Frison 8898',98765432,'gjordanb@hotmail.com',to_date('13031987','ddmmyyyy'),'M',2);

CREATE TABLE VENTA
(
cod_venta NUMBER NOT NULL,
cod_vendedor VARCHAR2 (4) NOT NULL ,
rut VARCHAR(20) NOT NULL,
cod_auto INT NOT NULL,
cod_color NUMBER NOT NULL,
fecha DATE NOT NULL,
valor NUMBER NOT NULL,
CONSTRAINT venta_pk PRIMARY KEY (cod_venta),
CONSTRAINT venta_vendedor_fk FOREIGN KEY (cod_vendedor) REFERENCES VENDEDOR (cod_vendedor),
CONSTRAINT venta_cliente_fk FOREIGN KEY (rut) REFERENCES CLIENTE (rut),
CONSTRAINT venta_auto_fk FOREIGN KEY (cod_auto) REFERENCES AUTO (cod_auto),
CONSTRAINT venta_color_fk FOREIGN KEY (cod_color) REFERENCES COLOR (cod_color)
);
INSERT INTO VENTA VALUES(10,'A100','08798234-9',1,1,to_date('17032017','ddmmyyyy'),9990000);
INSERT INTO VENTA VALUES(20,'A400','12378095-8',5,2,to_date('29052019','ddmmyyyy'),17490000);
INSERT INTO VENTA VALUES(30,'A290','13453473-7',8,1,to_date('24072019','ddmmyyyy'),10990000);
INSERT INTO VENTA VALUES(35,'A290','08798234-9',6,2,to_date('19092019','ddmmyyyy'),18790000);
INSERT INTO VENTA VALUES(25,'M640','08798234-9',19,2,to_date('13092019','ddmmyyyy'),12390000);
INSERT INTO VENTA VALUES(15,'C400','09578984-k',11,5,to_date('04012018','ddmmyyyy'),11590000);
INSERT INTO VENTA VALUES(43,'R600','09578984-k',14,6,to_date('10032017','ddmmyyyy'),15990000);

commit;