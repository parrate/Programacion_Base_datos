DECLARE 
CURSOR v_cursor_emp IS select e.numrut_emp,count(cf.numrut_emp) numero_carga from empleado e
left join carga_familiar cf on cf.numrut_emp = e.numrut_emp
group by e.numrut_emp;
v_colacion number := 40000; 
cursor  v_cursor_movi IS select * from porc_movilizacion;
v_movi number := 0;
v_antemp number := 0;
v_montoantiguedad number := 0;
cursor  v_cursor_bonifant IS select * from PORC_BONIF_ANNOS_CONTRATO;
begin 
for i in  v_cursor_emp loop
    select sueldo_base_emp, id_comuna , trunc(months_between(sysdate, fecing_emp)/12) 
    into v_base,v_cod_comuna,v_antemp from empleado where numrut_emp = i.numrut_emp;
    
    for j in v_cursor_movi loop
        if v_base >= j.sueldo_base_inf and v_base <= j.sueldo_base_sup then
            v_movi := round((v_base * j.porc_mov)/ 100);
          end if;  
    end loop;
    
    v_movi := case when v_cod_comuna in (105,107,91) then v_movi + 25000
        when v_cod_comuna in (117,118,119,122,124)  then v_movi + 40000
        else v_movi end;
    
    for x in v_cursor_bonifant loop
        if v_antemp between j.annos_comt_inf and annos_cont_sup then
            v_montoantiguedad :=  round((v_antemp * j.porcentaje)/100);
           end if; 
          
      /* for otro crso
         ciclos pequeños para realizar el calculo 
         
         */  
    end loop;

end loop;


end;