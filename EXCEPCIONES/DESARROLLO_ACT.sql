DECLARE

CURSOR v_cursor_emp IS select * from empleado;
CURSOR v_cursor_grat_aniguedad IS select * from PORC_ANTIGUEDAD_EMPLEADO;
CURSOR v_cursor_mov IS select * from porc_movilizacion;
v_grati number;
v_asig_fam number;
v_asig_col number;
v_mov number;
BEGIN
for mes in 1..12 loop
for i in v_cursor_emp loop
   BEGIN 
    begin  -- gratificacion
        v_grati := 0;
        for grat in v_cursor_grat_aniguedad loop
            if trunc(months_between(sysdate,i.fecha_contrato)/12)  
             between grat.annos_antiguedad_inf and grat.annos_antiguedad_sup then
                v_grati := round((i.sueldo_base * grat.PORC_ANTIGUEDAD)/100);
            end if;    
        end loop; 
    end;
    
    v_asig_fam := case  
                    when i.sueldo_base <= 289608 then 11337
                    when i.sueldo_base > 289608 and i.sueldo_base <= 423004 then 6957
                    when i.sueldo_base > 423004 and i.sueldo_base <= 659743 then 2199
                    when i.sueldo_base > 659743 then 0
                  end;
        v_asig_col := case  
                    when i.sueldo_base <= 289608 then 3000
                    when i.sueldo_base > 289608 and i.sueldo_base <= 423004 then 4500
                    when i.sueldo_base > 423004 and i.sueldo_base <= 659743 then 7500
                    when i.sueldo_base > 659743 then 14000
                  end;
        begin -- MOVILIZACION
            for m in v_cursor_mov loop
                v_mov := 0;
                if i.sueldo_base between m.sueldo_base_inf and m.sueldo_base_sup then
                    v_mov :=  round((i.sueldo_base * m.porc_movilizacion)/100);
                 end if;   
            end loop;
        end;
        insert into haberes_pago_mensual values('0'||mes||'2018'
        ,i.rutempleado,i.sueldo_base,v_grati,v_asig_fam,v_asig_col
        ,v_mov,0,0,0,0);
        exception
            when others then 
                insert into ERROR_CALC values (SEQ_ERROR.NEXTVAL
                ,'bloque anonimo'
                ,'BARRO');            
         END;       
end loop;
end loop;
END;