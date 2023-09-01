
-- Description : Le job - JOB_GESTION_VOIE_PHYSIQUE - déclenché toutes les heures supprime les voies physiques rattachées à aucun tronçon et aucune voie administrative.

DELETE
FROM
    G_BASE_VOIE.TA_VOIE_PHYSIQUE
WHERE
    objectid NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TA_TRONCON)
    AND objectid NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE);

