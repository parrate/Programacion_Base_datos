-- VARIABLE COMPUESTA
SET SERVEROUTPUT ON;
DECLARE
TYPE tipo_compuesto IS RECORD (
nombre VARCHAR(25),
apellido VARCHAR(25),
sueldo NUMBER
);
i tipo_compuesto;
BEGIN
SELECT first_name, last_name, salary
INTO i.nombre, i.apellido, i.sueldo
FROM employees WHERE employee_id = 180;
DBMS_OUTPUT.PUT_LINE('El Nombre es: ' || i.nombre);
DBMS_OUTPUT.PUT_LINE('El Apellido es: ' || i.apellido);
DBMS_OUTPUT.PUT_LINE('El Sueldo es: ' || i.sueldo);
END;

-- ROWTYPE
SET SERVEROUTPUT ON;
DECLARE
v_empleado EMPLOYEES%ROWTYPE;
BEGIN
SELECT * 
INTO v_empleado
FROM EMPLOYEES WHERE EMPLOYEE_ID = 170;
DBMS_OUTPUT.PUT_LINE(v_empleado.first_name || ' ' || v_empleado.last_name);
END;

-- CICLO FOR
SET SERVEROUTPUT ON;
DECLARE
v_nombre EMPLOYEES.FIRST_NAME%TYPE;
BEGIN
/* FORMATO FOR
DONDE i ES LA VARIABLE QUE SE INICIALIZA CON EL PRIMER VALOR
*/
FOR i IN 100..110 LOOP
SELECT first_name INTO v_nombre
FROM EMPLOYEES WHERE EMPLOYEE_ID = i;
DBMS_OUTPUT.put_line(i || ' Nombre Empleado: ' || v_nombre);
END LOOP;
END;