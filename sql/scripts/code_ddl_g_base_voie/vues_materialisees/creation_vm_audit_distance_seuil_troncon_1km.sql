/*
Vue matérialisée permettant d'identifier les seuils distants d'1km ou plus de leur tronçon d'affectation.
*/
/*
DROP INDEX VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM;
DELETE FROM USER_SDO_GEOM_METADATA WHERE table_name = 'VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM (
    ID_INFOS_SEUIL,
    POSITION_SEUIL,
    CODE_INSEE_SEUIL,
    ID_TRONCON,
    DISTANCE,  
    GEOM
)        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
  SELECT
    b.objectid AS id_infos_seuil,
    d.libelle_court AS position_seuil,
    a.code_insee AS code_insee_seuil,
    c.objectid AS id_troncon,
    ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
        SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
            SDO_LRS.CONVERT_TO_LRS_GEOM(c.geom, m.diminfo),
            SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(c.geom, m.diminfo), a.geom),
            0
        ),
        a.geom
    ), 2) AS distance,
    a.geom
FROM
    G_BASE_VOIE.TA_SEUIL a
    INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL b ON b.fid_seuil = a.objectid
    INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.objectid = a.fid_troncon
    INNER JOIN G_BASE_VOIE.TA_LIBELLE d ON d.objectid = a.fid_position,
    USER_SDO_GEOM_METADATA m
WHERE
    m.table_name = 'TA_TRONCON'
    AND ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
        SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
            SDO_LRS.CONVERT_TO_LRS_GEOM(c.geom, m.diminfo),
            SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(c.geom, m.diminfo), a.geom),
            0
        ),
        a.geom
    ), 2) >=1000;

-- 2. Création des commentaires
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM  IS 'Vue permettant d''identifier les seuils distants d''1km ou plus de leur tronçon d''affectation. Mise à jour tous les samedis à 08h00.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM.id_infos_seuil IS 'Identifiants des seuils utilisés en tant que clé primaire (objectid de TA_INFOS_SEUIL).';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM.position_seuil IS 'Position géographique du seuil (entrée du bâtiment/seuil, boîte postale, entrée de rue, portail, etc).';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM.code_insee_seuil IS 'Code INSEE de la commune dans laquelle se situe le seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM.id_troncon IS 'Identifiant du tronçon affecté au seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM.distance IS 'Distance minimale entre un seuil et le tronçon qui lui est affecté.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM.geom IS 'Champ géométrique de type point contenant la géométrie des seuils.';

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM 
ADD CONSTRAINT VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM_PK 
PRIMARY KEY (ID_INFOS_SEUIL);

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 4. Création des index
-- index spatial
CREATE INDEX VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM_SIDX
ON G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTIPOINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- Autres index  
CREATE INDEX VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM_POSITION_SEUIL_IDX ON G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM(POSITION_SEUIL)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM_CODE_INSEE_SEUIL_IDX ON G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM(CODE_INSEE_SEUIL)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM_ID_TRONCON_IDX ON G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM(ID_TRONCON)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM_DISTANCE_IDX ON G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM(DISTANCE)
    TABLESPACE G_ADT_INDX;
        
-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM TO G_ADMIN_SIG;

/

