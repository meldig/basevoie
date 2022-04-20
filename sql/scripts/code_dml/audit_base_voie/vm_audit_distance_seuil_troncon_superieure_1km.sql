-- VM_AUDIT_DISTANCE_SEUIL_TRONCON_SUPERIEURE_1KM: Seuils dont la distance par rapport à leur tronçon d'appartenance est supérieure à 1km

-- 0. Suppression de l'ancienne vue matérialisée
/*
DROP INDEX VM_AUDIT_DISTANCE_SEUIL_TRONCON_SUPERIEURE_1KM_SIDX;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_AUDIT_DISTANCE_SEUIL_TRONCON_SUPERIEURE_1KM';
DROP MATERIALIZED VIEW VM_AUDIT_DISTANCE_SEUIL_TRONCON_SUPERIEURE_1KM;
*/

-- 1. Création de la vue
CREATE MATERIALIZED VIEW VM_AUDIT_DISTANCE_SEUIL_TRONCON_SUPERIEURE_1KM (identifiant,code_seuil,distance,code_troncon, geom)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
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
        c.cnumtrc,
        a.ora_geometry
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
    cnumtrc,
    ora_geometry
FROM
    CTE_1
;

-- 1. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_SUPERIEURE_1KM
ADD CONSTRAINT VM_AUDIT_DISTANCE_SEUIL_TRONCON_SUPERIEURE_1KM_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commentaire de la vue matérialisée.
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_SUPERIEURE_1KM  IS 'Vue permettant d''identifier les seuils dont la distance par rapport à leur tronçon d''affectation est supérieure à 1000m.';


-- 4. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_SUPERIEURE_1KM.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_SUPERIEURE_1KM.CODE_SEUIL IS 'Identifiant du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_SUPERIEURE_1KM.DISTANCE IS 'Distance entre le seuil et son tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_SUPERIEURE_1KM.CODE_TRONCON IS 'Identifiant du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_SUPERIEURE_1KM.GEOM IS 'Géométrie du seuil de type point.';


-- 5. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_AUDIT_DISTANCE_SEUIL_TRONCON_SUPERIEURE_1KM',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.001), MDSYS.SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.001)), 
    2154
);


-- 6. Création de l'index spatial
CREATE INDEX VM_AUDIT_DISTANCE_SEUIL_TRONCON_SUPERIEURE_1KM_SIDX
ON VM_AUDIT_DISTANCE_SEUIL_TRONCON_SUPERIEURE_1KM(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=POINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);
