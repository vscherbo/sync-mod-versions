SELECT  * FROM crosstab('
SELECT mp.mod_id, mp.dev_param_id, p.param_id
FROM devmod.modifications m
     , devmod.modif_param mp 
     , devmod.dev_param dp
     , devmod.param p
WHERE 
  m.dev_id=mp.dev_id AND m.mod_id=mp.mod_id AND m.version_num=mp.version_num
  AND mp.dev_param_id=dp.dev_param_id AND mp.version_num=dp.version_num
  AND dp.dev_param_id=p.dev_param_id AND dp.version_num=p.version_num
  AND mp.param_id=p.param_id AND mp.version_num=p.version_num
  AND m.dev_id=85 AND m.version_num=421384572
ORDER BY m.mod_id, mp.dev_param_id
'::text) AS ct(mod_id character varying, "227" integer, "228" integer, "229" integer)
