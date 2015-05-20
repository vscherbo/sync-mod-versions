SELECT 'SELECT v1.*, v4.* FROM devmod.ver1 v1, devmod.ver4 v4 WHERE ' || string_agg(DISTINCT ' v4."' || dp.dev_param_id::VARCHAR || '"=v1."' || dp.dev_param_id::VARCHAR , '" AND ') || '" ORDER BY v1.mod_id'
FROM devmod.dev_param dp 
WHERE dp.dev_id=85
-- JOIN
