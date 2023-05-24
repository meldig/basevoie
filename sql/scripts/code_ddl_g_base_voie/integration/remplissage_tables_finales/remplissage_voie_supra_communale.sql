/*
Remplissage de la table G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE.
*/

DROP INDEX TA_VOIE_SUPRA_COMMUNALE_ID_VOIE_SUPRA_COMMUNALE_IDX;
DROP INDEX TA_VOIE_SUPRA_COMMUNALE_FID_VOIE_ADMINISTRATIVE_IDX;
DROP INDEX TA_VOIE_SUPRA_COMMUNALE_DOMANIALITE_SUPRA_COMMUNALE_IDX;
DROP INDEX TA_VOIE_SUPRA_COMMUNALE_CODE_INSEE_IDX;
DROP INDEX TA_VOIE_SUPRA_COMMUNALE_SIDX;

/

MERGE INTO G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE a 
	USING(
		WITH
		    C_1 AS(
		        SELECT
		            a.idvoie AS id_voie_supra_communale,
                    a.domania AS domanialite
		        FROM
		            SIREO_LEC.OUT_DOMANIALITE a 
		            INNER JOIN G_BASE_VOIE.TA_TRONCON b ON b.old_objectid = a.cnumtrc
		            INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE c ON c.objectid = b.fid_voie_physique
		            INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = c.objectid
		            INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE e ON e.objectid = d.fid_voie_administrative
		        GROUP BY
		            a.idvoie,
                    a.domania
		        HAVING
		            COUNT(DISTINCT e.code_insee) > 1
		    ),
            
            C_2 AS(
                SELECT
                    d.objectid AS id_voie_administrative,
                    TRIM(SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 2) || ' ' || TRIM(d.libelle_voie) || ' ' || TRIM(d.complement_nom_voie)) AS nom_voie,
                    CASE WHEN COALESCE(g.fid_voie_secondaire, 0) = 0 THEN 'Voie Principale' ELSE 'Voie secondaire' END AS hierarchie,
                    d.code_insee,
                    SDO_AGGR_UNION(
                        SDOAGGRTYPE(a.geom, 0.005)
                    ) AS geom
                FROM
                    G_BASE_VOIE.TA_TRONCON a
                    INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
                    INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
                    INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE d ON d.objectid = c.fid_voie_administrative
                    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE e ON e.objectid = d.fid_type_voie
                    INNER JOIN G_BASE_VOIE.TA_LIBELLE f ON f.objectid = c.fid_lateralite
                    LEFT JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE g ON g.fid_voie_secondaire = d.objectid
                GROUP BY
                    d.code_insee,
                    CASE WHEN COALESCE(g.fid_voie_secondaire, 0) = 0 THEN 'Voie Principale' ELSE 'Voie secondaire' END,
                    TRIM(SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 2) || ' ' || TRIM(d.libelle_voie) || ' ' || TRIM(d.complement_nom_voie)),
                    d.objectid
            ),
            
            C_3 AS(
                SELECT DISTINCT
                    f.id_voie_supra_communale,
                    e.id_voie_administrative,
                    e.nom_voie,
                    e.code_insee,
                    a.domania AS domanialite_supra_communale
                FROM
                    SIREO_LEC.OUT_DOMANIALITE a 
                    INNER JOIN C_1 f ON f.id_voie_supra_communale = a.idvoie
                    INNER JOIN G_BASE_VOIE.TA_TRONCON b ON b.old_objectid = a.cnumtrc
                    INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE c ON c.objectid = b.fid_voie_physique
                    INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = c.objectid
                    RIGHT JOIN C_2 e ON e.id_voie_administrative = d.fid_voie_administrative
            )
            
            SELECT
                a.id_voie_supra_communale,
                a.id_voie_administrative,
                b.nom_voie,
                a.code_insee,
                a.domanialite_supra_communale,
                b.geom
            FROM
                C_3 a
                INNER JOIN C_2 b ON b.id_voie_administrative = a.id_voie_administrative
	)t 
ON(a.id_voie_supra_communale = t.id_voie_supra_communale AND a.fid_voie_administrative = t.id_voie_administrative)
WHEN NOT MATCHED THEN
	INSERT(a.id_voie_supra_communale, a.fid_voie_administrative, a.domanialite_supra_communale, a.code_insee, a.geom)
	VALUES(t.id_voie_supra_communale, t.id_voie_administrative, t.domanialite_supra_communale, t.code_insee, t.geom);
-- Résultat : 22 288 lignes fusionnées.

/
