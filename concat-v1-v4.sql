SELECT v1.*, v4.* 
FROM devmod.ver1 v1, devmod.ver4 v4
WHERE 
  v4."227" = v1."227"
  AND v4."228" = v1."228"
  AND v4."229" = v1."229"
ORDER BY v1.mod_id