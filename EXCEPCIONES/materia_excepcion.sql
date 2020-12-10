
set serveroutput on;
declare
v_employee int;
v_err EXCEPTION;
begin
RAISE v_err;
select SALARY / 2 into v_employee 
from employees where employee_id in (0);


RAISE v_err;
INSERT INTO DEPARTMENTS VALUES (50,'TEST',100,1000);

/*
exception 
when TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('ERROR 2 FILAS ' || SQLERRM);
when DUP_VAL_ON_INDEX THEN DBMS_OUTPUT.PUT_LINE('ERROR DUP ' || SQLERRM);
when others THEN DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM);
*/
exception 
when v_err then DBMS_OUTPUT.PUT_LINE('ERROR ' || SQLERRM);
end;