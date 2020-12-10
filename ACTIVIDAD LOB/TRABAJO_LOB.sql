
-- VER DIRECTORIO (ESTE PROCESO SE REALIZA EN SYSTEM)
SELECT * FROM DBA_DIRECTORIES;

-- SE ASIGNA PRIVILEGIO DE LECTURA Y ESCRITURA AL USUARIO PRUEBA (ESTE PROCESO SE REALIZA E SYSTEM)
GRANT READ, WRITE ON DIRECTORY ORACLECLRDIR TO PRUEBA;

-- SE CREA TABLA PRODUCTO_IMG
DROP TABLE PRODUCTO_IMG;

CREATE TABLE PRODUCTO_IMG (
CODPRODUCTO NUMBER(3) NOT NULL PRIMARY KEY,
FOTO BLOB DEFAULT empty_blob());
COMMIT;

-- SE AGREGA NUEVA COLUMNA (FOTO) A TABLA PRODUCTO
ALTER TABLE PRODUCTO ADD FOTO BLOB DEFAULT empty_blob();


SELECT * FROM PRODUCTO_IMG;
SELECT * FROM PRODUCTO;

DROP SEQUENCE SEQ_CPROD;

CREATE SEQUENCE SEQ_CPROD;

SET SERVEROUTPUT ON;
DECLARE
    CURSOR c_prod IS SELECT * FROM PRODUCTO;
    v_blob BLOB;
    v_bfile BFILE;
BEGIN
    INSERT INTO PRODUCTO_IMG (CODPRODUCTO, FOTO)
    VALUES (1, EMPTY_BLOB()) RETURNING FOTO INTO v_blob;
    v_bfile := BFILENAME ('ORACLECLRDIR', '1.PNG');
    DBMS_LOB.OPEN(v_bfile, DBMS_LOB.LOB_READONLY);
    DBMS_LOB.LOADFROMFILE(v_blob, v_bfile, DBMS_LOB.GETLENGTH(v_bfile));
    DBMS_LOB.CLOSE(v_bfile);  
    COMMIT;
    FOR a IN c_prod LOOP
        SELECT FOTO INTO v_blob FROM PRODUCTO WHERE CODPRODUCTO = a FOR UPDATE;
        v_bfile := BFILENAME ('ORACLECLRDIR', '1.PNG');
        DBMS_LOB.OPEN(v_bfile, DBMS_LOB.LOB_READONLY);
        DBMS_LOB.LOADFROMFILE(v_blob, v_bfile, DBMS_LOB.GETLENGTH(v_bfile));
        DBMS_LOB.CLOSE(v_bfile);
    END LOOP;
    COMMIT;
END;