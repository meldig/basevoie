/*
Création de la vue matérialisée VM_TEMP_J_AUDIT_TRONCON_NON_JOINTIFS identifiant les tronçons distants de 5cm non-jointifs.
*/
-- Suppression de la VM
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_J_AUDIT_TRONCON_NON_JOINTIFS;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_J_AUDIT_TRONCON_NON_JOINTIFS (
    OBJECTID,
    GEOM
)        
REFRESH FORCE
START WITH TO_DATE('23-05-2023 06:00:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 6/24
DISABLE QUERY REWRITE AS

WITH
    C_1 AS(
        SELECT
            a.objectid AS id1,
            b.objectid AS id2
        FROM
            G_BASE_VOIE.TEMP_J_TRONCON a,
            G_BASE_VOIE.TEMP_J_TRONCON b,
            USER_SDO_GEOM_METADATA m
        WHERE 
            a.objectid < b.objectid
            AND m.table_name = 'TEMP_J_TRONCON'
            AND SDO_WITHIN_DISTANCE(a.geom, b.geom, 'distance = 0.5') = 'TRUE'
            AND SDO_LRS.CONNECTED_GEOM_SEGMENTS(
                    SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom, m.diminfo),
                    SDO_LRS.CONVERT_TO_LRS_GEOM(b.geom, m.diminfo),
                    0.5
                ) <> 'TRUE'
    ),
    
    C_2 AS(
        SELECT
            id1 AS objectid
        FROM
            C_1
        UNION ALL
        SELECT
            id2 AS objectid
        FROM
            C_1
    ),
    
    C_3 AS(
        SELECT DISTINCT
            objectid
        FROM
            C_2
    )
    
    SELECT
        a.objectid,
        b.geom
    FROM
        C_3 a
        INNER JOIN G_BASE_VOIE.TEMP_J_TRONCON b ON b.objectid = a.objectid;
        
-- 2. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_J_AUDIT_TRONCON_NON_JOINTIFS IS 'Vue matérialisée identifiant les tronçons distants de 5cm non-jointifs.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_AUDIT_TRONCON_NON_JOINTIFS.objectid IS 'Identifiants des tronçons correspondant à la clé primaire de la VM.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_AUDIT_TRONCON_NON_JOINTIFS.geom IS 'Géométrie des tronçons.';

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_J_AUDIT_TRONCON_NON_JOINTIFS 
ADD CONSTRAINT VM_TEMP_J_AUDIT_TRONCON_NON_JOINTIFS_PK 
PRIMARY KEY (OBJECTID);

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_J_AUDIT_TRONCON_NON_JOINTIFS',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création des index
-- index spatial
CREATE INDEX VM_TEMP_J_AUDIT_TRONCON_NON_JOINTIFS_SIDX
ON G_BASE_VOIE.VM_TEMP_J_AUDIT_TRONCON_NON_JOINTIFS(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=LINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);
    
-- 5. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_J_AUDIT_TRONCON_NON_JOINTIFS TO G_ADMIN_SIG;

/

