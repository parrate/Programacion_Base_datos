 --LETRA A
set SERVEROUTPUT ON;
declare
v_rutcliente factura.rutcliente%type;
v_nombre cliente.nombre%type;
v_cant int;
v_suma int;
v_prome int;
v_maxi int;
v_mini int;
begin

select c.rutcliente,c.nombre,count(numfactura)
,sum(total)
,avg(total)
,max(total)
,min(total)
into v_rutcliente,v_nombre,v_cant,v_suma,v_prome,v_maxi,v_mini
from cliente c
join factura f  on c.rutcliente = f.rutcliente
group by c.rutcliente,c.nombre
HAVING COUNT(NUMFACTURA) 
= (select MAX(count(1)) from factura group by rutcliente);
DBMS_OUTPUT.put_line('Rut de Cliente : '|| v_rutcliente);
DBMS_OUTPUT.put_line('Nombre de Cliente : '|| v_nombre);
DBMS_OUTPUT.put_line('Cantidad Factura : '|| v_cant);
DBMS_OUTPUT.put_line('Monto Total Facturas : '|| v_suma);
DBMS_OUTPUT.put_line('Monto Promedio Facturas : '|| v_prome);
DBMS_OUTPUT.put_line('Monto Máximo Facturas : '|| v_maxi);
DBMS_OUTPUT.put_line('Monto Mínimo Facturas : '|| v_mini);
end;

-- LETRA B

set SERVEROUTPUT ON;
declare
v_rut varchar(50);
v_nombre varchar(50);
v_monto int;
begin
select c.rutcliente,c.nombre,sum(total)
into v_rut,v_nombre,v_monto
from cliente c
join factura f  on c.rutcliente = f.rutcliente
group by c.rutcliente,c.nombre
having sum(total) = (select MAX(sum(total)) from factura
group by rutcliente);
DBMS_OUTPUT.put_line('Cliente con MAYOR Facturación');
DBMS_OUTPUT.put_line('--------------------------------');
DBMS_OUTPUT.put_line('Rut: '|| v_rut ||' - '|| 'Nombre : '|| v_nombre
|| ' - ' || 'Monto Facturado: '|| v_monto);


select c.rutcliente,c.nombre,sum(total)
into v_rut,v_nombre,v_monto
from cliente c
join factura f  on c.rutcliente = f.rutcliente
group by c.rutcliente,c.nombre
having sum(total) = (select MIN(sum(total)) from factura
group by rutcliente);
DBMS_OUTPUT.put_line('Cliente con MENOR Facturación');
DBMS_OUTPUT.put_line('----------------------------------');
DBMS_OUTPUT.put_line('Rut: '|| v_rut ||' - '|| 'Nombre : '|| v_nombre
|| ' - ' || 'Monto Facturado: '|| v_monto);

end;

--LETRA C
set SERVEROUTPUT ON;
declare
v_rut varchar(25);
v_nombre varchar(25);
v_cred int;
v_saldo int;
v_comuna varchar(25);
v_total int;
v_dire varchar(25);
begin
select c.rutcliente,c.direccion,c.nombre,c.credito,c.saldo,co.descripcion,sum(total)
into v_rut,v_dire,v_nombre,v_cred,v_saldo,v_comuna,v_total
from cliente c
join factura f  on c.rutcliente = f.rutcliente
left join comuna co on co.codcomuna = c.codcomuna
group by c.rutcliente,c.direccion,c.nombre,c.credito,c.saldo,co.descripcion
HAVING sum(total)
= (select MAX(sum(total)) from factura group by rutcliente);
DBMS_OUTPUT.put_line('ANTECEDENTES DE CLIENTE CON MAYOR FACTURACIÓN');
DBMS_OUTPUT.put_line('--------------------------------------------------------');
DBMS_OUTPUT.put_line('Rut de Cliente : '|| v_rut || '    Nombre de Cliente : '|| v_nombre);

DBMS_OUTPUT.put_line('Dirección : '|| v_dire || '   Comuna : '|| v_comuna);

DBMS_OUTPUT.put_line('Credito Aprobado : '|| v_cred || '        Saldo Crédito : '|| v_saldo);


-- LETRA D 
set SERVEROUTPUT ON;

declare
v_cod int;
v_desc varchar(50);
v_unidad varchar(50);
v_stock int;
v_segu int;
v_total int;
v_proce varchar(50) ;
begin
select p.codproducto,p.descripcion,um.descriunidad
,p.totalstock
,p.stkseguridad
,sum(df.cantidad) 
,CASE when p.procedencia = 'N' then 'Nacional' else 'Internacional' end
into v_cod,v_desc,v_unidad,v_stock,v_segu,v_total,v_proce
from producto p
join detalle_factura df on df.codproducto = p.codproducto
join unidad_medida um on um.codunidad = p.codunidad
group by p.codproducto,p.descripcion,um.descriunidad,p.procedencia,p.totalstock
,p.stkseguridad
having sum(df.cantidad) = (select max(sum(cantidad)) 
from detalle_factura group by codproducto);
DBmS_OUTPUT.PUT_LINE('CODPRODUCTO :'|| v_cod || '-' || ' DESCRIPCION : '|| v_desc || '-' || ' UNIDAD MEDIDA :' || v_unidad || '-' || ' PROCEDENCIA : ' || v_proce || '-' || ' TOTAL STOCK :'|| v_stock || '-' || ' STOCK SEGURIDAD : '|| v_segu || 'TOTAL FACTURADO : '|| v_total);
end;


end;


