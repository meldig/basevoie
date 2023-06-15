/*
Remplissage de la table G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE permettant de faire la relation
entre les voies supra-communales et les voies administratives.
*/
MERGE INTO G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE a 
    USING(
        WITH
            C_1 AS(
                SELECT DISTINCT -- Sélection des voies supra-communales absentes de la table EXRD_IDSUPVOIE
                    a.idvoie AS id_voie_supra_communale
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
            ),

            C_2 AS (
                SELECT DISTINCT -- Sélection des relations voies administratives/supra-communales hors EXRD
                    a.idvoie AS id_voie_supra_communale,
                    e.objectid AS id_voie_administrative
                FROM
                    SIREO_LEC.OUT_DOMANIALITE a 
                    INNER JOIN G_BASE_VOIE.TA_TRONCON b ON b.old_objectid = a.cnumtrc
                    INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE c ON c.objectid = b.fid_voie_physique
                    INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = c.objectid
                    INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE e ON e.objectid = d.fid_voie_administrative
                WHERE
                    a.idvoie IN (SELECT id_voie_supra_communale FROM C_1)
                UNION ALL
                SELECT DISTINCT -- Sélection des relations voies administratives/supra-communales présentes dans la table EXRD_IDSUPVOIE
                    a.idsupvoi AS id_voie_supra_communale,
                    f.objectid AS id_voie_administrative
                FROM
                    SIREO_LEC.EXRD_IDSUPVOIE a 
                    INNER JOIN SIREO_LEC.OUT_DOMANIALITE b ON b.idvoie = a.idsupvoi
                    INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.old_objectid = b.cnumtrc
                    INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE d ON d.objectid = c.fid_voie_physique
                    INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE e ON e.fid_voie_physique = d.objectid
                    INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE f ON f.objectid = e.fid_voie_administrative       
            )

            SELECT DISTINCT
                id_voie_supra_communale,
                id_voie_administrative
            FROM 
                C_2            
    )t 
ON(a.fid_voie_supra_communale = t.id_voie_supra_communale AND a.fid_voie_administrative = t.id_voie_administrative)
WHEN NOT MATCHED THEN
    INSERT(a.fid_voie_supra_communale, a.fid_voie_administrative)
    VALUES(t.id_voie_supra_communale, t.id_voie_administrative);
COMMIT;

/

