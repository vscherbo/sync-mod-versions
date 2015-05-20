-- Function: devmod.gen_mods_list(integer, integer)

-- DROP FUNCTION devmod.gen_mods_list(integer, integer);

CREATE OR REPLACE FUNCTION devmod.gen_mods_list(
    a_dev_id integer,
    a_ver integer)
  RETURNS void AS
$BODY$DECLARE
  sql_mods VARCHAR;
  mod RECORD;
  cnt INTEGER;
BEGIN
  SELECT devmod.gen_mods_cross_sql(a_dev_id, a_ver) INTO sql_mods;

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
