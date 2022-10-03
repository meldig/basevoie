/*
Création de la VM VM_TEMP_C_BUFFER_VOIE_ADMINISTRATIVE_PAR_COMMUNE - du projet C de correction de la latéralité des voies - contenant les buffers de 10m des voies administratives, dont les voies physiques se partageaient anciennement des tronçons, par commune.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_C_BUFFER_VOIE_ADMINISTRATIVE_PAR_COMMUNE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TEMP_C_BUFFER_VOIE_ADMINISTRATIVE_PAR_COMMUNE';
COMMIT;
*/

-- 1. Création de la vue matérialisée
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TEMP_C_BUFFER_VOIE_ADMINISTRATIVE_PAR_COMMUNE" ("OBJECTID", "ID_VOIE_ADMINISTRATIVE", "CODE_INSEE", "GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(
        SELECT DISTINCT
            c.objectid AS id_voie_physique,
            e.objectid AS id_voie_administrative
        FROM
            G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE b
            INNER JOIN  G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE c ON c.objectid = b.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = c.objectid
            INNER JOIN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE e ON e.objectid = d.fid_voie_administrative
        WHERE
            b.fid_voie_physique <> b.old_id_voie_physique
    ),
    
    C_2 AS(
        SELECT
            a.id_voie_administrative,
            SDO_GEOM.SDO_BUFFER(
                b.geom,
                10,
                0.001
            ) AS geom
        FROM
            C_1 a
            INNER JOIN G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE b ON b.id_voie_administrative = a.id_voie_administrative
    ),
    
    C_3 AS(    
        SELECT
            a.id_voie_administrative,
            b.code_insee,
            SDO_GEOM.SDO_INTERSECTION(
                a.geom,
                b.geom,
                0.005
            ) AS geom
        FROM
            C_2 a,
            G_REFERENTIEL.MEL_COMMUNE_LLH b
    ),
    
    C_4 AS(
        SELECT 
            a.id_voie_administrative,
            a.code_insee,
            a.geom
        FROM
            C_3 a
        WHERE
            a.geom IS NOT NULL
    )
    
    SELECT
        rownum AS objectid,
        a.*
    FROM
        C_4 a;
    
-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_C_BUFFER_VOIE_ADMINISTRATIVE_PAR_COMMUNE IS 'VM contenant les buffers de 5m des voies administratives, dont les voies physiques se partageaient anciennement des tronçons, par commune.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_C_BUFFER_VOIE_ADMINISTRATIVE_PAR_COMMUNE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_C_BUFFER_VOIE_ADMINISTRATIVE_PAR_COMMUNE 
ADD CONSTRAINT VM_TEMP_C_BUFFER_VOIE_ADMINISTRATIVE_PAR_COMMUNE_PK 
PRIMARY KEY (OBJECTID);

-- 6. Création des index
CREATE INDEX VM_TEMP_C_BUFFER_VOIE_ADMINISTRATIVE_PAR_COMMUNE_SIDX
ON G_BASE_VOIE.VM_TEMP_C_BUFFER_VOIE_ADMINISTRATIVE_PAR_COMMUNE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTIPOLYGON, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);
-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_C_BUFFER_VOIE_ADMINISTRATIVE_PAR_COMMUNE TO G_ADMIN_SIG;

/

