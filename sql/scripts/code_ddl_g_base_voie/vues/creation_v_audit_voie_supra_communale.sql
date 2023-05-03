/*
Création de la vue faisant l''audit des voies supra-communales à partir de la table SIREO_LEC.OUT_DOMANIALITE.
*/
/*
DROP VIEW G_BASE_VOIE.V_AUDIT_VOIE_SUPRA_COMMUNALE;
*/
-- 1. Création de la vue V_AUDIT_VOIE_SUPRA_COMMUNALE permettant de faire l'audit des voies supra-communales
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_AUDIT_VOIE_SUPRA_COMMUNALE" ("OBJECTID", "THEME", "NOMBRE", 
    CONSTRAINT "V_AUDIT_VOIE_SUPRA_COMMUNALE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
WITH
    C_1 AS(
        SELECT
            a.idvoie AS id_voie_supra_communale,
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
    ),
    
    C_2 AS(
        SELECT
            'Nombre de voies supra-communales' AS theme,
            COUNT(DISTINCT id_voie_supra_communale) AS nombre_voies
        FROM
            C_1
        GROUP BY
            'Nombre de voies supra-communales'
    ),
    
    C_3 AS(
        SELECT
            'Nombre de voies par domanialité de type : '|| a.domanialite AS theme,
            COUNT(a.id_voie_supra_communale) AS nombre_voies
        FROM
            C_1 a
        GROUP BY
            'Nombre de voies par domanialité de type : '|| a.domanialite
    ),
    
    C_4 AS(
        SELECT
            id_voie_supra_communale
        FROM
            C_1
        GROUP BY
            id_voie_supra_communale
        HAVING
            COUNT(domanialite) > 1
    ),
    
    C_5 AS(
        SELECT
            'Nombre de voies supra-communales associées à plusieurs domanialités' AS theme,
            COUNT(id_voie_supra_communale) AS nombre_voies
        FROM
            C_4
        GROUP BY
            'Nombre de voies supra-communales associées à plusieurs domanialités'
    ),
    
    C_6 AS(
        SELECT
            theme,
            nombre_voies
        FROM
            C_2
        UNION ALL
        SELECT
            theme,
            nombre_voies
        FROM
            C_5
        UNION ALL
        SELECT
            theme,
            nombre_voies
        FROM
            C_3
    )
    
    SELECT
        rownum,
        theme,
        nombre_voies
    FROM
        C_6;
        
-- 2. Création des commentaires
COMMENT ON TABLE "G_BASE_VOIE"."V_AUDIT_VOIE_SUPRA_COMMUNALE"  IS 'Vue faisant l''audit des voies supra-communales à partir de la table SIREO_LEC.OUT_DOMANIALITE.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_AUDIT_VOIE_SUPRA_COMMUNALE"."OBJECTID" IS 'Clé primaire de la vue.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_AUDIT_VOIE_SUPRA_COMMUNALE"."THEME" IS 'Thème d''étude.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_AUDIT_VOIE_SUPRA_COMMUNALE"."NOMBRE" IS 'Nombre de voies résultant de l''étude.';

-- 3. Création des droits de lecture
GRANT SELECT ON G_BASE_VOIE.V_AUDIT_VOIE_SUPRA_COMMUNALE TO G_ADMIN_SIG;

/

