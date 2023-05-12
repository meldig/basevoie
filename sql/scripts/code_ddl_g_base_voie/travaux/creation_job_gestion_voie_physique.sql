
-- Description : Ce job déclenché toutes les minutes supprime les voies physiques rattachées à aucun tronçon et aucune voie administrative.

DELETE
FROM
    G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE
WHERE
    objectid NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TEMP_J_TRONCON)
    AND objectid NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TEMP_J_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE);

/

