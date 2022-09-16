/*
création de la VM VM_TEMP_C_VOIE_PHYSIQUE - du projet C de correction de la latéralité des voies - matérialisant la géométrie des voies administratrives partageant la même voie physique.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_C_VOIE_PHYSIQUE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TEMP_C_VOIE_PHYSIQUE';
COMMIT;
*/
-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TEMP_C_VOIE_PHYSIQUE" ("ID_VOIE_PHYSIQUE","GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
    d.objectid AS id_voie_physique,
    SDO_AGGR_UNION(
        SDOAGGRTYPE(b.geom, 0.005)
    ) AS geom
FROM
    G_BASE_VOIE.TEMP_C_TRONCON b
    INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE c ON c.fid_troncon = b.objectid
    INNER JOIN G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE d ON d.objectid = c.fid_voie_physique
WHERE
    d.objectid > 6700320
GROUP BY
    d.objectid;

-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_C_VOIE_PHYSIQUE IS 'VM matérialisant la géométrie des voies physiques.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_C_VOIE_PHYSIQUE.ID_VOIE_PHYSIQUE IS 'Identifiant de la voie physique présente dans TEMP_C_VOIE_PHYSIQUE.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_C_VOIE_PHYSIQUE.GEOM IS 'Géométrie de type multiligne des voies physiques.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_C_VOIE_PHYSIQUE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_C_VOIE_PHYSIQUE 
ADD CONSTRAINT VM_TEMP_C_VOIE_PHYSIQUE_PK 
PRIMARY KEY (ID_VOIE_PHYSIQUE);

-- 6. Création des index
CREATE INDEX VM_TEMP_C_VOIE_PHYSIQUE_SIDX
ON G_BASE_VOIE.VM_TEMP_C_VOIE_PHYSIQUE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_C_VOIE_PHYSIQUE TO G_ADMIN_SIG;

/

