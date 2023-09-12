-- VM_AUDIT_RESULTAT_DISTANCE_SEUIL_TRONCON_SUPERIEUR_1KM: Seuils dont la distance par rapport à leur tronçon d'appartenance est supérieure à 1km

-- 0. Suppression de l'ancienne vue matérialisée
/*
DROP INDEX VM_AUDIT_RESULTAT_DISTANCE_SEUIL_TRONCON_SUPERIEUR_1KM_SIDX;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_AUDIT_RESULTAT_DISTANCE_SEUIL_TRONCON_SUPERIEUR_1KM';
DROP MATERIALIZED VIEW VM_AUDIT_RESULTAT_DISTANCE_SEUIL_TRONCON_SUPERIEUR_1KM;
*/

-- 1. Création de la vue
CREATE MATERIALIZED VIEW VM_AUDIT_RESULTAT_DISTANCE_SEUIL_TRONCON_SUPERIEUR_1KM (identifiant,code_seuil,distance,code_troncon, geom)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
WITH CTE_1 AS
    (
    SELECT
        a.objectid AS code_seuil,
        ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                        SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
                            SDO_LRS.CONVERT_TO_LRS_GEOM(d.geom, m.diminfo),-- conversion de la ligne en segment LRS
                            SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(d.geom, m.diminfo), a.geom),--
                            0
                        ),
                        a.geom)) AS DISTANCE,
        d.objectid AS code_troncon,
        a.geom
    FROM
        G_BASE_VOIE.TA_SEUIL a
        INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL b ON b.fid_seuil = a.objectid
        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = a.objectid
        INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = c.fid_troncon
        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE e ON e.fid_troncon = d.objectid
        INNER JOIN G_BASE_VOIE.TA_VOIE f ON f.objectid = e.fid_voie,
        USER_SDO_GEOM_METADATA m
    WHERE
        m.TABLE_NAME = 'TA_TRONCON'
        AND ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                        SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
                            SDO_LRS.CONVERT_TO_LRS_GEOM(d.geom, m.diminfo),-- conversion de la ligne en segment LRS
                            SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(d.geom, m.diminfo), a.geom),--
                            0
                        ),
                        a.geom
                    ), 2) >= 1000
    )
SELECT
    rownum,
    code_seuil,
    distance,
    code_troncon,
    geom
FROM
    CTE_1
;

-- 1. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_RESULTAT_DISTANCE_SEUIL_TRONCON_SUPERIEUR_1KM
ADD CONSTRAINT VM_AUDIT_RESULTAT_DISTANCE_SEUIL_TRONCON_SUPERIEUR_1KM_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commentaire de la vue matérialisée.
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_RESULTAT_DISTANCE_SEUIL_TRONCON_SUPERIEUR_1KM  IS 'Vue permettant d''identifier les seuils dont la distance par rapport à leur tronçon d''affectation est supérieure à 1000m.';


-- 4. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_DISTANCE_SEUIL_TRONCON_SUPERIEUR_1KM.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_DISTANCE_SEUIL_TRONCON_SUPERIEUR_1KM.CODE_SEUIL IS 'Identifiant du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_DISTANCE_SEUIL_TRONCON_SUPERIEUR_1KM.DISTANCE IS 'Distance entre le seuil et son tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_DISTANCE_SEUIL_TRONCON_SUPERIEUR_1KM.CODE_TRONCON IS 'Identifiant du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_DISTANCE_SEUIL_TRONCON_SUPERIEUR_1KM.GEOM IS 'Géométrie du seuil de type point.';


-- 5. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_AUDIT_RESULTAT_DISTANCE_SEUIL_TRONCON_SUPERIEUR_1KM',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.001), MDSYS.SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.001)), 
    2154
);


-- 6. Création de l'index spatial
CREATE INDEX VM_AUDIT_RESULTAT_DISTANCE_SEUIL_TRONCON_SUPERIEUR_1KM_SIDX
ON VM_AUDIT_RESULTAT_DISTANCE_SEUIL_TRONCON_SUPERIEUR_1KM(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=POINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);
