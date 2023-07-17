/*
Objectif : remplissage de la table TA_VOIE_SUPRA_COMMUNALE afin d'avoir dans une table hébergée sur le schéma G_BASE_VOIE 
toutes les voies supra-communales, afin que leur gestion se fasse désormais du côté DDIG et non plus DEPV.
Le remplissage des objectid, dates de saisie/modification + pnom se font automatiquement par des triggers ou des séquences.
*/

MERGE INTO G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE a
    USING(
        SELECT DISTINCT -- Sélection des voies supra-communales absentes de la table EXRD_IDSUPVOIE
            a.idvoie AS nom
        FROM
            SIREO_LEC.OUT_DOMANIALITE a 
            INNER JOIN G_BASE_VOIE.TA_TRONCON b ON b.old_objectid = a.cnumtrc
            INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE c ON c.objectid = b.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = c.objectid
            INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE e ON e.objectid = d.fid_voie_administrative
        WHERE
            a.idvoie NOT IN(SELECT idsupvoi FROM SIREO_LEC.EXRD_IDSUPVOIE)
        GROUP BY
            a.idvoie
        HAVING
            COUNT(DISTINCT e.code_insee) > 1
        UNION ALL
        SELECT DISTINCT -- Sélection des relations voies administratives/supra-communales présentes dans la table EXRD_IDSUPVOIE
            idsupvoi AS nom
        FROM
            SIREO_LEC.EXRD_IDSUPVOIE
    )t
ON (a.nom = t.nom)
WHEN NOT MATCHED THEN
INSERT(a.nom)
VALUES(t.nom);

/

