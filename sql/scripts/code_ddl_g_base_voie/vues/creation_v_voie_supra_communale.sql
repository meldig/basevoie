/*
Création de la vue V_VOIE_SUPRA_COMMUNALE rassemblant toutes les voies supra-communales à partir de la table SIREO_LEC.OUT_DOMANIALITE.
*/
/*
DROP VIEW G_BASE_VOIE.V_VOIE_SUPRA_COMMUNALE;
*/
-- 1. Création de la vue V_VOIE_SUPRA_COMMUNALE permettant de faire l'audit des voies supra-communales
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_VOIE_SUPRA_COMMUNALE" ("OBJECTID", "ID_VOIE", "DOMANIALITE",
    CONSTRAINT "V_VOIE_SUPRA_COMMUNALE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
WITH
    C_1 AS(
        SELECT
            a.idvoie AS id_voie,
            a.domania AS domanialite
        FROM
            SIREO_LEC.OUT_DOMANIALITE a 
            INNER JOIN G_BASE_VOIE.TEMP_J_TRONCON b ON b.old_objectid = a.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE c ON c.objectid = b.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TEMP_J_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = c.objectid
            INNER JOIN G_BASE_VOIE.TEMP_J_VOIE_ADMINISTRATIVE e ON e.objectid = d.fid_voie_administrative
            INNER JOIN G_BASE_VOIE.TEMP_J_TYPE_VOIE f ON f.objectid = e.fid_type_voie
        GROUP BY
            a.idvoie,
            a.domania
        HAVING
            COUNT(DISTINCT e.code_insee) > 1
    )
    
    SELECT
        rownum,
        id_voie,
        domanialite
    FROM
        C_1;
        
-- 2. Création des commentaires
COMMENT ON TABLE "G_BASE_VOIE"."V_VOIE_SUPRA_COMMUNALE"  IS 'Vue rassemblant toutes les voies supra-communales à partir de la table SIREO_LEC.OUT_DOMANIALITE.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_VOIE_SUPRA_COMMUNALE"."OBJECTID" IS 'Clé primaire de la vue.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_VOIE_SUPRA_COMMUNALE"."ID_VOIE" IS 'Identifiant des voies supra-communales.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_VOIE_SUPRA_COMMUNALE"."DOMANIALITE" IS 'Domanialité de chaque voie supra-communale.';

-- 3. Création des droits de lecture
GRANT SELECT ON G_BASE_VOIE.V_VOIE_SUPRA_COMMUNALE TO G_ADMIN_SIG;

/

