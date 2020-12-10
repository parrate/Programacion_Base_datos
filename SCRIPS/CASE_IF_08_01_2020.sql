SELECT employee_id,
first_name,
last_name,
salary 
FROM employees WHERE salary > 3500;



-- CASE
SET SERVEROUTPUT ON;
DECLARE
  CURSOR v_cursor IS SELECT employee_id, first_name, last_name, salary
  FROM employees WHERE salary > 3500;
  v_paso NUMBER;
BEGIN
  FOR i IN v_cursor LOOP
    i.salary := CASE 
                  WHEN i.salary > 4500 THEN (i.salary * 1.05)
                ELSE
                  i.salary
                END;
    DBMS_OUTPUT.put_line(i.employee_id || ' tiene un sueldo de: ' || i.salary);
  END LOOP;
END;

-- IF
SET SERVEROUTPUT ON;
DECLARE
  CURSOR v_cursor IS SELECT employee_id, first_name, last_name, salary
  FROM employees WHERE salary > 3500;
  v_paso NUMBER;
BEGIN
  FOR i IN v_cursor LOOP
    IF i.salary >= 3000 AND i.salary <= 4000 THEN 
      v_paso := (i.salary * 1.02);
      ELSIF i.salary >= 4001 AND i.salary <= 5000 THEN 
        v_paso := (i.salary * 1.05);
        ELSIF i.salary > 5001 THEN 
          v_paso := (i.salary * 1.10);
    END IF;
    i.salary := v_paso;
    DBMS_OUTPUT.put_line(i.employee_id || ' tiene un sueldo de: ' || i.salary);
  END LOOP;
END;

--MOD(EMPLOYEE_ID,2) != 0; -- CALCULAR IMPARES
SELECT EMPLOYEE_ID FROM EMPLOYEES WHERE MOD(EMPLOYEE_ID,2) != 0; -- CALCULAR IMPARES

SELECT employee_id, salary FROM EMPLOYEES;
SELECT employee_id, salary FROM EMPLOYEES WHERE MOD(employee_id,2) != 0 AND salary < 5000;

-- EJERCICIO CON UPDATE
SET SERVEROUTPUT ON;
DECLARE
  CURSOR v_cursor IS SELECT employee_id, salary FROM EMPLOYEES;
  v_contador INT := 0;
BEGIN
  FOR i IN v_cursor LOOP
  IF MOD(i.employee_id,2) != 0 AND i.salary < 5000 THEN
    UPDATE EMPLOYEES SET salary = (salary * 1.037) WHERE employee_id = i.employee_id;
        v_contador := (v_contador + SQL%ROWCOUNT);
  END IF;
  END LOOP;
  IF v_contador > 0 THEN
    DBMS_OUTPUT.put_line('SE HAN ACTUALIZADO ' || v_contador || ' EMPLEADOS!!!!');
  ELSE
    DBMS_OUTPUT.put_line('NO SE HAN ACTUALIZADO EMPLEADOS!!!!');
  END IF;
--  ROLLBACK; -- LOS CAMBIOS REALIZADOS NO SE GUARDAN EN LA TABLA  
--  COMMIT; --CONFIRMA LOS CAMBIOS
END;