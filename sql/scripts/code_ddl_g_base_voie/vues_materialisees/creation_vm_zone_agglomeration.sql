/*
Création de la VM VM_ZONE_AGGLOMERATION faisant la fusion de toutes les zones d'agglomération permettant d'accélérer la distinction des voies en/hors zone d'agglomération.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_ZONE_AGGLOMERATION;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_ZONE_AGGLOMERATION';
COMMIT;
*/

CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_ZONE_AGGLOMERATION(OBJECTID, GEOM)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
    WITH
        C_1 AS(
            SELECT 
                SDO_AGGR_UNION(SDOAGGRTYPE(geom, 0.005)) AS geom
            FROM
                G_VOIRIE.SIVR_ZONE_AGGLO
        )
        
        SELECT
            rownum,
            SDO_GEOM.SDO_SELF_UNION(geom, 0.001)
        FROM
            C_1;

-- 2. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_ZONE_AGGLOMERATION IS 'Vue matérialisée faisant la fusion de toutes les zones d''agglomération de la voirie.';

-- 3. Remplissage des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_ZONE_AGGLOMERATION',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_ZONE_AGGLOMERATION 
ADD CONSTRAINT VM_ZONE_AGGLOMERATION_PK 
PRIMARY KEY (OBJECTID);

-- 5. Création de l'index spatial
CREATE INDEX VM_ZONE_AGGLOMERATION_SIDX
ON G_BASE_VOIE.VM_ZONE_AGGLOMERATION(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTIPOLYGON, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 6. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_ZONE_AGGLOMERATION TO G_ADMIN_SIG;

/

