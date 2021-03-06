-- Function: devmod.gen_mods_cross_sql(integer, integer)

-- DROP FUNCTION devmod.gen_mods_cross_sql(integer, integer);

CREATE OR REPLACE FUNCTION devmod.gen_mods_cross_sql(
    a_dev_id integer,
    a_ver integer)
  RETURNS character varying AS
$BODY$DECLARE
  sql_cmd VARCHAR;
  cross_select VARCHAR = 'SELECT mp.mod_id, mp.dev_param_id, p.param_id';
  cross_from VARCHAR = ' FROM devmod.modifications m, devmod.modif_param mp, devmod.dev_param dp, devmod.param p';
  cross_where1 VARCHAR = ' WHERE m.dev_id=mp.dev_id AND m.mod_id=mp.mod_id AND m.version_num=mp.version_num';
  cross_where2 VARCHAR = ' AND mp.dev_param_id=dp.dev_param_id AND mp.version_num=dp.version_num';
  cross_where3 VARCHAR = ' AND dp.dev_param_id=p.dev_param_id AND dp.version_num=p.version_num';
  cross_having VARCHAR = ' AND dp.dev_param_id IN (SELECT h.dev_param_id FROM (SELECT dev_param_id, COUNT(dev_param_id) FROM devmod.param WHERE dev_id=%s and version_num=%s GROUP BY dev_param_id, version_num HAVING count(param_id) > 1) AS h )';
  cross_where4 VARCHAR = ' AND mp.param_id=p.param_id AND mp.version_num=p.version_num';
  cross_where5 VARCHAR = ' AND dp.dev_id=%s AND dp.version_num=%s';
  cross_order VARCHAR = ' ORDER BY m.mod_id, mp.dev_param_id';
  cross_sql VARCHAR;
  str_aggr VARCHAR;
  cross_columns VARCHAR;
  sql_mods VARCHAR;
  into_table VARCHAR;
  tmp_table VARCHAR;
BEGIN
  cross_sql := cross_select || cross_from 
               || cross_where1 || cross_where2 || cross_where3 
               || format(cross_having, a_dev_id, a_ver)
               || cross_where4 || format(cross_where5, a_dev_id, a_ver) || cross_order;
  str_aggr := 'string_agg('' "'' || dp.dev_param_id || ''" integer'', '','' ORDER BY dp.dev_param_id)';
  sql_cmd := format('SELECT %s FROM devmod.dev_param dp WHERE dp.dev_id=%s AND dp.version_num=%s'
                    || format(cross_having, a_dev_id, a_ver)
                    , str_aggr, a_dev_id, a_ver);
  EXECUTE sql_cmd INTO cross_columns;
  sql_mods := 'SELECT * FROM crosstab(''' || cross_sql || '''::TEXT) AS ct(mod_id character varying,' || cross_columns || ');';
  
  RETURN sql_mods;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION devmod.gen_mods_cross_sql(integer, integer)
  OWNER TO arc_energo;

