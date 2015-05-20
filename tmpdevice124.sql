-- CREATE OR REPLACE VIEW devmod.tmpdevice124 AS 
 SELECT t1.mod_id,
    t1."227",
    t1."228",
    t1."229",
    modifications.mod_price,
    modifications.mod_delivery_time,
    modifications.mod_order_on,
    modifications.price_date
   FROM ( SELECT ct.mod_id,
            ct."227",
            ct."228",
            ct."229"
           FROM crosstab('SELECT modif_param.mod_id, dev_param.dev_param_id, param.param_value 
                 FROM (devmod.modif_param 
                 INNER JOIN devmod.param ON modif_param.param_id = param.param_id) 
                 INNER JOIN devmod.dev_param ON param.dev_param_id = dev_param.dev_param_id 
                 WHERE dev_param.dev_id = 85 AND modif_param.version_num=421384572 
                 GROUP BY modif_param.mod_id, dev_param.dev_param_id, param.param_value 
                 ORDER BY modif_param.mod_id'::text) ct(mod_id character varying, "227" character varying, "228" character varying, "229" character varying)) t1
     JOIN devmod.modifications ON t1.mod_id = modifications.mod_id
  WHERE modifications.version_num = 1 --421384572;
