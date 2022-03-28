/*
Création d'une vue matérialisée matérialisant la géométrie des voies LITTERALIS.
*/
-- 1. Suppression de la VM et de ses métadonnées
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_VOIE_AGGREGEE_LITTERALIS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_VOIE_AGGREGEE_LITTERALIS';
COMMIT;
*/

-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_VOIE_AGGREGEE_LITTERALIS" ("ID_VOIE","INSEE","LIBELLE_VOIE", "GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
    a.code_rue_g,
    a.insee_g,
    a.nom_rue_g,
    SDO_AGGR_UNION(
        SDOAGGRTYPE(a.geometry, 0.005)
    ) AS geom
FROM
    G_BASE_VOIE.VM_TRONCON_LITTERALIS a
GROUP BY
    a.code_rue_g,
    a.insee_g,
    a.nom_rue_g;

-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_VOIE_AGGREGEE_LITTERALIS IS 'Vue matérialisée matérialisant la géométrie des voies.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_VOIE_AGGREGEE_LITTERALIS',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_VOIE_AGGREGEE_LITTERALIS 
ADD CONSTRAINT VM_VOIE_AGGREGEE_LITTERALIS_PK 
PRIMARY KEY (ID_VOIE);

-- 6. Création des index
CREATE INDEX VM_VOIE_AGGREGEE_LITTERALIS_SIDX
ON G_BASE_VOIE.VM_VOIE_AGGREGEE_LITTERALIS(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_VOIE_AGGREGEE_LITTERALIS_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_VOIE_AGGREGEE_LITTERALIS(LIBELLE_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_VOIE_AGGREGEE_LITTERALIS_IDX ON G_BASE_VOIE.VM_VOIE_AGGREGEE_LITTERALIS(ID_VOIE, INSEE, LIBELLE_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_VOIE_AGGREGEE_LITTERALIS_INSEE_IDX ON G_BASE_VOIE.VM_VOIE_AGGREGEE_LITTERALIS(INSEE)
    TABLESPACE G_ADT_INDX;

-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_VOIE_AGGREGEE_LITTERALIS TO G_ADMIN_SIG;