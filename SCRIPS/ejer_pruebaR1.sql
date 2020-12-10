SELECT E.NUMRUT_EMP,
2 MES_PROCESO,
2018 ANNO_PROCESO,
E.SUELDO_BASE_EMP,
ROUND(E.SUELDO_BASE_EMP * PAC.PORC_BONIF) VALOR_ASIG_ANNOS,
(4500 * COUNT(CF.NUMRUT_CARGA)) VALOR_CARGAS_FAM,
CASE
  WHEN E.ID_COMUNA IN (107,105,91) THEN ROUND(25000 + (E.SUELDO_BASE_EMP + ((E.SUELDO_BASE_EMP * PM.PROC_MOV)/100)))
  WHEN E.ID_COMUNA IN (114,117,118,119,124,122) THEN ROUND(40000 + (E.SUELDO_BASE_EMP + ((E.SUELDO_BASE_EMP * PM.PROC_MOV)/100)))
  ELSE ROUND(E.SUELDO_BASE_EMP + ((E.SUELDO_BASE_EMP * PM.PROC_MOV)/100))
END VALOR_MOVILIZACION,
40000 VALOR_COLACION,
SUM(NVL(CV.VALOR_COMISION,0)) VALOR_COM_VENTAS,
ROUND(E.SUELDO_BASE_EMP * AE.PORC_ASIG_ESCOLARIDAD) VALOR_ASIG_ESCOLARIDAD
FROM EMPLEADO E
JOIN PORC_BONIF_ANNOS_CONTRATO PAC ON (ROUND(MONTHS_BETWEEN((SYSDATE - (30*11)),E.FECING_EMP)/12) BETWEEN PAC.ANNOS_INFERIOR AND PAC.ANNOS_SUPERIOR)
LEFT JOIN CARGA_FAMILIAR CF ON(E.NUMRUT_EMP = CF.NUMRUT_EMP)
JOIN PORC_MOVILIZACION PM ON(E.SUELDO_BASE_EMP BETWEEN PM.SUELDO_BASE_INF AND PM.SUELDO_BASE_SUP)
JOIN COMUNA C ON(E.ID_COMUNA = C.ID_COMUNA)
LEFT JOIN BOLETA B ON(E.NUMRUT_EMP = B.NUMRUT_EMP)
LEFT JOIN COMISION_VENTA CV ON (B.NRO_BOLETA = CV.NRO_BOLETA)
JOIN ASIG_ESCOLARIDAD AE ON(E.ID_ESCOLARIDAD = AE.ID_ESCOLARIDAD)
GROUP BY E.NUMRUT_EMP, E.SUELDO_BASE_EMP, ROUND(E.SUELDO_BASE_EMP * PAC.PORC_BONIF),PM.PROC_MOV, E.ID_COMUNA, AE.PORC_ASIG_ESCOLARIDAD;


SELECT * FROM HABER_CALC_MES;
SELECT * FROM COMUNA ORDER BY 2;
SELECT * FROM EMPLEADO;


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