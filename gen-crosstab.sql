SELECT DISTINCT
   'CREATE OR REPLACE VIEW devmod.ver4 AS SELECT * FROM crosstab('''
   || 'SELECT mp.mod_id, mp.dev_param_id, p.param_id'
   || ' FROM devmod.modifications m, devmod.modif_param mp, devmod.dev_param dp, devmod.param p'
   || ' WHERE m.dev_id=mp.dev_id AND m.mod_id=mp.mod_id AND m.version_num=mp.version_num'
   || ' AND mp.dev_param_id=dp.dev_param_id AND mp.version_num=dp.version_num'
   || ' AND dp.dev_param_id=p.dev_param_id AND dp.version_num=p.version_num'
   || ' AND mp.param_id=p.param_id AND mp.version_num=p.version_num'
   || ' AND dp.dev_id=85 AND dp.version_num=421384572'
   || ' ORDER BY m.mod_id, mp.dev_param_id'
   || '''::TEXT) AS ct(mod_id character varying,'
   || string_agg(DISTINCT ' "' || dp.dev_param_id || '" integer', ',')
   || ');'
FROM devmod.dev_param dp 
WHERE dp.dev_id=85

