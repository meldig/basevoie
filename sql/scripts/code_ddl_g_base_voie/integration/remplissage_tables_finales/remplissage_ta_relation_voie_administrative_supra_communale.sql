/*
Remplissage de la table G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE permettant de faire la relation
entre les voies supra-communales et les voies administratives.
*/
MERGE INTO G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE a 
    USING(
        WITH
            C_1 AS(
                SELECT DISTINCT -- Sélection des voies supra-communales absentes de la table EXRD_IDSUPVOIE
                    a.idvoie AS id_voie,
                    CASE
                        WHEN SUBSTR(idvoie,0, 2) = 'MD' AND INSTR(SUBSTR(idvoie, 3), '000') = 1
                            THEN 'M' || SUBSTR(idvoie, 6)
                        WHEN SUBSTR(idvoie,0, 2) = 'MD' AND INSTR(SUBSTR(idvoie, 3), '00') = 1
                            THEN 'M' || SUBSTR(idvoie, 5)
                        WHEN SUBSTR(idvoie,0, 2) = 'MD' AND INSTR(SUBSTR(idvoie, 3), '0') = 1
                            THEN 'M' || SUBSTR(idvoie, 4)
                        ELSE
                            a.idvoie
                    END AS nom
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
                    idsupvoi AS id_voie,
                    CASE
                        WHEN SUBSTR(idsupvoi,0, 2) = 'MD' AND INSTR(SUBSTR(idsupvoi, 3), '000') = 1
                            THEN 'M' || SUBSTR(idsupvoi, 6)
                        WHEN SUBSTR(idsupvoi,0, 2) = 'MD' AND INSTR(SUBSTR(idsupvoi, 3), '00') = 1
                            THEN 'M' || SUBSTR(idsupvoi, 5)
                        WHEN SUBSTR(idsupvoi,0, 2) = 'MD' AND INSTR(SUBSTR(idsupvoi, 3), '0') = 1
                            THEN 'M' || SUBSTR(idsupvoi, 4)
                        ELSE
                            idsupvoi
                    END AS nom
                FROM
                    SIREO_LEC.EXRD_IDSUPVOIE
            )
            
            SELECT DISTINCT -- Sélection des relations voies administratives/supra-communales                    
                g.objectid AS id_voie_supra_communale,
                e.objectid AS id_voie_administrative
            FROM
                SIREO_LEC.OUT_DOMANIALITE a 
                INNER JOIN G_BASE_VOIE.TA_TRONCON b ON b.old_objectid = a.cnumtrc
                INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE c ON c.objectid = b.fid_voie_physique
                INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = c.objectid
                INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE e ON e.objectid = d.fid_voie_administrative
                INNER JOIN C_1 f ON f.id_voie = a.idvoie
                INNER JOIN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE g ON g.nom = f.nom          
    )t 
ON(a.fid_voie_supra_communale = t.id_voie_supra_communale AND a.fid_voie_administrative = t.id_voie_administrative)
WHEN NOT MATCHED THEN
    INSERT(a.fid_voie_supra_communale, a.fid_voie_administrative)
    VALUES(t.id_voie_supra_communale, t.id_voie_administrative);
COMMIT;

/

