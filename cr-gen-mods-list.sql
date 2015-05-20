-- Function: devmod.gen_mods_list(integer, integer)

-- DROP FUNCTION devmod.gen_mods_list(integer, integer);

CREATE OR REPLACE FUNCTION devmod.gen_mods_list(
    a_dev_id integer,
    a_ver integer)
  RETURNS void AS
$BODY$DECLARE
  sql_cmd VARCHAR;
  a_dev_id INTEGER;
  cross_select VARCHAR = 'SELECT mp.mod_id, mp.dev_param_id, p.param_id';
  cross_from VARCHAR = ' FROM devmod.modifications m, devmod.modif_param mp, devmod.dev_param dp, devmod.param p';
  cross_where1 VARCHAR = ' WHERE m.dev_id=mp.dev_id AND m.mod_id=mp.mod_id AND m.version_num=mp.version_num';
  cross_where2 VARCHAR = ' AND mp.dev_param_id=dp.dev_param_id AND mp.version_num=dp.version_num';
  cross_where3 VARCHAR = ' AND dp.dev_param_id=p.dev_param_id AND dp.version_num=p.version_num';
  cross_where4 VARCHAR = ' AND mp.param_id=p.param_id AND mp.version_num=p.version_num';
  cross_where5 VARCHAR = ' AND dp.dev_id=%s AND dp.version_num=%s';
  cross_order VARCHAR = ' ORDER BY m.mod_id, mp.dev_param_id';
  cross_sql VARCHAR;
  str_aggr VARCHAR;
  res VARCHAR;
  dev_params_item VARCHAR = ''' "'' || ' || 'dp.dev_param_id' || ' || ''" integer''';
  dev_params VARCHAR = 'string_agg(' || dev_params_item || ', '','') || ';
  cross_columns VARCHAR;
  sql_mods VARCHAR;
  mod RECORD;
  cnt INTEGER;
BEGIN
  cross_sql := cross_select || cross_from || cross_where1 || cross_where2 || cross_where3 || cross_where4 || format(cross_where5, a_dev_id, a_ver) || cross_order;
  str_aggr := 'string_agg('' "'' || devmod.dev_param.dev_param_id || ''" integer'', '','' ORDER BY devmod.dev_param.dev_param_id)';
  sql_cmd := format('SELECT %s FROM devmod.dev_param WHERE dev_id=%s AND version_num=%s', str_aggr, a_dev_id, a_ver);
  EXECUTE sql_cmd INTO cross_columns;
  sql_mods := 'SELECT * FROM crosstab(''' || cross_sql || '''::TEXT) AS ct(mod_id character varying,' || cross_columns || ');';
  
  -- RAISE NOTICE 'sql_cmd=%', sql_cmd;
  -- RAISE NOTICE 'cross_columns=%', cross_columns;
  -- RAISE NOTICE 'sql_mods=%', sql_mods;
  cnt := 1;
  FOR mod in EXECUTE sql_mods LOOP
    RAISE NOTICE 'N=%, mod=%', cnt, mod;
    cnt := cnt + 1;
  END LOOP;
    
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION devmod.gen_mods_list(integer, integer)
  OWNER TO arc_energo;
