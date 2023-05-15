/*
Vue matérialisée permettant d'identifier les seuils distants d'1km ou plus de leur tronçon d'affectation.
*/

DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_J_AUDIT_DISTANCE_SEUIL_TRONCON_1KM;
DELETE FROM USER_SDO_GEOM_METADATA WHERE table_name = 'VM_TEMP_J_AUDIT_DISTANCE_SEUIL_TRONCON_1KM';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_J_AUDIT_DISTANCE_SEUIL_TRONCON_1KM (
    ID_INFOS_SEUIL,
    CODE_INSEE_SEUIL,
    ID_TRONCON,
    DISTANCE,  
    GEOM
)        
REFRESH FORCE
START WITH TO_DATE('12-05-2023 20:00:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 1
DISABLE QUERY REWRITE AS
  SELECT
    b.objectid AS id_infos_seuil,
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
    G_BASE_VOIE.TEMP_J_SEUIL a
    INNER JOIN G_BASE_VOIE.TEMP_J_INFOS_SEUIL b ON b.fid_seuil = a.objectid
    INNER JOIN G_BASE_VOIE.TEMP_J_TRONCON c ON c.objectid = a.fid_troncon,
    USER_SDO_GEOM_METADATA m
WHERE
    m.table_name = 'TEMP_J_TRONCON'
    AND ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
        SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
            SDO_LRS.CONVERT_TO_LRS_GEOM(c.geom, m.diminfo),
            SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(c.geom, m.diminfo), a.geom),
            0
        ),
        a.geom
    ), 2) >=1000;

-- 2. Création des commentaires
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_J_AUDIT_DISTANCE_SEUIL_TRONCON_1KM"."ID_INFOS_SEUIL" IS 'Identifiants des seuils utilisés en tant que clé primaire (objectid de TEMP_J_INFOS_SEUIL).';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_J_AUDIT_DISTANCE_SEUIL_TRONCON_1KM"."ID_TRONCON" IS 'Identifiant du tronçon affecté au seuil.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_J_AUDIT_DISTANCE_SEUIL_TRONCON_1KM"."CODE_INSEE" IS 'Code INSEE de la commune dans laquelle se situe le seuil.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_J_AUDIT_DISTANCE_SEUIL_TRONCON_1KM"."DISTANCE" IS 'Distance minimale entre un seuil et le tronçon qui lui est affecté.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_J_AUDIT_DISTANCE_SEUIL_TRONCON_1KM"."GEOM" IS 'Champ géométrique de type point contenant la géométrie des seuils.';
COMMENT ON MATERIALIZED VIEW "G_BASE_VOIE"."VM_TEMP_J_AUDIT_DISTANCE_SEUIL_TRONCON_1KM"  IS 'Vue permettant d''identifier les seuils distants d''1km ou plus de leur tronçon d''affectation.';


-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_J_AUDIT_DISTANCE_SEUIL_TRONCON_1KM 
ADD CONSTRAINT VM_TEMP_J_AUDIT_DISTANCE_SEUIL_TRONCON_1KM_PK 
PRIMARY KEY (ID_INFOS_SEUIL);

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_J_AUDIT_DISTANCE_SEUIL_TRONCON_1KM',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 4. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_J_AUDIT_DISTANCE_SEUIL_TRONCON_1KM TO G_ADMIN_SIG;

/

