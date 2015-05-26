-- Function: devmod.mods_update(integer, integer, integer)

-- DROP FUNCTION devmod.mods_update(integer, integer, integer);

CREATE OR REPLACE FUNCTION devmod.mods_update(
    a_dev_id integer,
    a_ver_from integer,
    a_ver_to integer)
  RETURNS void AS
$BODY$DECLARE
  sql_mods_from VARCHAR;
  sql_mods_to VARCHAR;
  mod RECORD;
  cnt INTEGER;
  tmp_name_from VARCHAR = 'tmp_' || a_dev_id || '_' || a_ver_from ;
  tmp_name_to   VARCHAR = 'tmp_' || a_dev_id || '_' || a_ver_to ;
  debug1 VARCHAR;
  sql_join VARCHAR;
  sql_where VARCHAR;
  sql_on VARCHAR;
  sql_update VARCHAR;
  mods_from_cols INTEGER[];
  mods_to_cols INTEGER[];
  shared_cols INTEGER[];
  col INTEGER;
BEGIN
  SELECT devmod.gen_mods_cross_sql(a_dev_id, a_ver_from) INTO sql_mods_from;
  SELECT devmod.gen_mods_cross_sql(a_dev_id, a_ver_to) INTO sql_mods_to;

  -- debug1 := 'CREATE TEMPORARY TABLE ' || tmp_name_from || ' ON COMMIT DROP AS ' || sql_mods_from ;
  -- RAISE NOTICE 'tmp_name=%', tmp_name;
  -- RAISE NOTICE 'sql=%', debug1;
  EXECUTE 'CREATE TEMPORARY TABLE ' || tmp_name_from || ' ON COMMIT DROP AS ' || sql_mods_from ;
  EXECUTE 'CREATE TEMPORARY TABLE ' || tmp_name_to || ' ON COMMIT DROP AS ' || sql_mods_to ;

/*
 1. количество и имена (фактически, dev_param_id) столбцов во временных таблицах совпадают
 2. количество совпадает, имена отличаются (было удаление одного параметра и добавление другого)
 3. в новой версии количество больше
 4. в новой версии количество меньше
*/

  SELECT ARRAY(select column_name::INTEGER from information_schema.columns where table_name=tmp_name_from AND column_name <> 'mod_id') INTO mods_from_cols ;
  SELECT ARRAY(select column_name::INTEGER from information_schema.columns where table_name=tmp_name_to AND column_name <> 'mod_id') INTO mods_to_cols ;
  shared_cols := mods_from_cols & mods_to_cols ;
  /**/
  RAISE NOTICE 'mods_from_cols=%', mods_from_cols;
  RAISE NOTICE 'mods_to_cols=%', mods_to_cols;
  RAISE NOTICE 'shared_cols=%', shared_cols;
  /**/
  -- IF icol(mods_from_cols) == icol(mods_to_cols)
  IF mods_from_cols =  mods_to_cols THEN -- вариант 1
    sql_where := 'WHERE ';
    FOREACH col IN ARRAY mods_from_cols LOOP
        sql_where := sql_where || format('mods_from."%s"::VARCHAR=mods_to."%s"::VARCHAR AND ', col, col);
    END LOOP;
    sql_where := sql_where || 'TRUE';
  
    RAISE NOTICE 'sql_where=%', sql_where;

    sql_join := format('SELECT mods_from.mod_id AS mod_id_from, mods_to.mod_id AS mod_id_to FROM %s mods_from, %s mods_to %s ORDER BY mods_from.mod_id;', 
                     tmp_name_from, tmp_name_to, sql_where);
    RAISE NOTICE 'sql_join=%', sql_join;

  ELSIF FALSE THEN -- вариант 2
        NULL;
  ELSIF (mods_from_cols <@  mods_to_cols) OR (mods_from_cols @>  mods_to_cols) THEN -- вариант 3,4
        sql_on := 'ON ';
        FOREACH col IN ARRAY shared_cols LOOP
            sql_on := sql_on || format('mods_from."%s"::VARCHAR=mods_to."%s"::VARCHAR AND ', col, col);
        END LOOP;
        sql_on := sql_on || 'TRUE';
        RAISE NOTICE 'sql_on=%', sql_on;
        sql_join := format('SELECT mods_from.mod_id AS mod_id_from, mods_to.mod_id AS mod_id_to FROM %s mods_from LEFT JOIN %s mods_to %s ORDER BY mods_from.mod_id;', 
                     tmp_name_from, tmp_name_to, sql_on);
        RAISE NOTICE 'sql_join=%', sql_join;

        cnt := 1;
        FOR mod in EXECUTE sql_join LOOP
            -- RAISE NOTICE 'N=%, mod_from=%, mod_to=%', cnt, mod.mod_id_from, mod.mod_id_to;
            sql_update := format('UPDATE devmod.modifications m 
                SET mod_price = mfrom.mod_price, 
                mod_delivery_time = mfrom.mod_delivery_time,
                dm_valuta = mfrom.dm_valuta,
                dm_kurs = mfrom.dm_kurs
                FROM devmod.modifications mfrom
                WHERE 
                    mfrom.mod_id=%s AND mfrom.version_num=%s
                    AND m.mod_id=%s AND m.version_num=%s;', quote_literal(mod.mod_id_from), a_ver_from, quote_literal(mod.mod_id_to), a_ver_to);
            RAISE NOTICE 'N=%, sql_update=%', cnt, sql_update;
            /************************************************/
            -- EXECUTE sql_update;
            /************************************************/
            cnt := cnt + 1;
        END LOOP;
  -- ELSIF mods_from_cols @>  mods_to_cols THEN -- вариант 4
        -- NULL;      
  END IF;

    
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION devmod.mods_update(integer, integer, integer)
  OWNER TO arc_energo;
