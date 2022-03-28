-- V_AUDIT_DISTANCE_SEUILS_TRONCON_SUP_1000_M: Seuils dont la distance par rapport à leur tronçon d'appartenance est supérieure à 1km

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW V_AUDIT_DISTANCE_SEUILS_TRONCON_SUP_1000_M (identifiant,code_seuil,distance,code_troncon,
CONSTRAINT "V_AUDIT_DISTANCE_SEUILS_TRONCON_SUP_1000_M_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS
WITH CTE_1 AS
    (
    SELECT
        a.idseui,
        ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                        SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
                            SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo),-- conversion de la ligne en segment LRS
                            SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo), a.ora_geometry),--
                            0
                        ),
                        a.ora_geometry)) AS DISTANCE,
        c.cnumtrc
    FROM
        G_BASE_VOIE.TEMP_ILTASEU a
        INNER JOIN G_BASE_VOIE.TEMP_ILTASIT b ON b.idseui = a.idseui
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc
        INNER JOIN G_BASE_VOIE.TEMP_VOIECVT d ON d.cnumtrc = c.cnumtrc
        INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI e ON e.ccomvoi = d.ccomvoi,
        USER_SDO_GEOM_METADATA m
    WHERE
        c.cdvaltro = 'V'
        AND d.cvalide = 'V'
        AND e.cdvalvoi = 'V'
        AND m.TABLE_NAME = 'TEMP_ILTATRC'
        AND ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                        SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
                            SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo),-- conversion de la ligne en segment LRS
                            SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo), a.ora_geometry),--
                            0
                        ),
                        a.ora_geometry
                    ), 2) >= 1000
    )
SELECT
    rownum,
    idseui,
    distance,
    cnumtrc
FROM
    CTE_1
;


-- 2. Commentaire de la vue.
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_DISTANCE_SEUILS_TRONCON_SUP_1000_M  IS 'Vue permettant d''identifier les seuils associés troncons dont la distance est supérieur à 1000m.';


-- 3. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DISTANCE_SEUILS_TRONCON_SUP_1000_M.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DISTANCE_SEUILS_TRONCON_SUP_1000_M.CODE_SEUIL IS 'Numéro du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DISTANCE_SEUILS_TRONCON_SUP_1000_M.DISTANCE IS 'Numéro du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DISTANCE_SEUILS_TRONCON_SUP_1000_M.CODE_TRONCON IS 'Numéro du troncons.';