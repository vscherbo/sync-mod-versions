SELECT 
   m.dev_id, m.mod_id, m.version_num, 
   m.mod_price --, m.mod_delivery_time
   , mp.dev_param_id, mp.param_id
   --, dp.param_name, dp.dev_param_sort_order
   --, p.param_value
FROM devmod.modifications m
     , devmod.modif_param mp 
     , devmod.dev_param dp
     , devmod.param p
WHERE m.dev_id=85 -- AND m.mod_id='000850000001'
AND m.dev_id=mp.dev_id AND m.mod_id=mp.mod_id AND m.version_num=mp.version_num
AND mp.dev_param_id=dp.dev_param_id AND mp.version_num=dp.version_num
AND dp.dev_param_id=p.dev_param_id AND dp.version_num=p.version_num
AND mp.param_id=p.param_id AND mp.version_num=p.version_num
AND m.version_num=1
ORDER BY m.mod_id