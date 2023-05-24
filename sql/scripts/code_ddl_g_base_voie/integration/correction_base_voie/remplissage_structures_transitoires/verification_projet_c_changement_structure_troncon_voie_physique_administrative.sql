/*
Objectif : vérifier que le passage de la structure du projet B à celle du projet C pour les relations tronçons / voies physiques / administratives s'est bien passée.
*/

-- Vérification de la correction des données
-- Tous les tronçons sont reliés à des voies physiques
SELECT
    objectid
FROM
    G_BASE_VOIE.TEMP_C_TRONCON
WHERE
    objectid NOT IN(SELECT fid_troncon FROM G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE);
-- Résultat : 0 tronçon

-- Un tronçon est relié à une et une seule voie physique
SELECT
    fid_troncon
FROM
    G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE
GROUP BY
    fid_troncon
HAVING
    COUNT(fid_troncon) > 1;
-- Résultat : 0 tronçon

-- Toutes les voies physiques sont reliées à des tronçons
SELECT
    a.objectid,
    c.*
FROM
    G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE a
    INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE b ON b.fid_voie_physique = a.objectid
    INNER JOIN  G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE c ON c.objectid = b.fid_voie_administrative
WHERE
    a.objectid NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE);
-- 20 voies physiques

-- Une voie administrative absente de la table des relation voies physiques / administratives
SELECT
    objectid
FROM
    G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE
WHERE
    objectid NOT IN(SELECT fid_voie_administrative FROM G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE);
-- Résultat : 0 voie administrative

-- Vérification qu'une voie physique peut être affectée à plusieurs voies administratives
SELECT
    fid_voie_physique,
    COUNT(objectid) AS nombre
FROM
    G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
GROUP BY
    fid_voie_physique
HAVING
    COUNT(objectid) > 1;
-- Résultat : 281 voies physiques affectées à plusieurs voies administratives

/

