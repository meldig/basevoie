/*
Création d'une vue matérialisée matérialisant la géométrie des voies.
*/
-- 1. Suppression de la VM et de ses métadonnées
/*DROP MATERIALIZED VIEW G_BASE_VOIE.VM_VOIE_AGGREGEE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_VOIE_AGGREGEE';
COMMIT;
*/
-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_VOIE_AGGREGEE" ("ID_VOIE","TYPE_DE_VOIE","LIBELLE_VOIE","COMPLEMENT_NOM_VOIE", "GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
    a.objectid AS id_voie,
    UPPER(TRIM(d.libelle)) AS type_de_voie,
    UPPER(TRIM(a.libelle_voie)) AS libelle_voie,
    UPPER(TRIM(a.complement_nom_voie)) AS complement_nom_voie,
    SDO_AGGR_UNION(
        SDOAGGRTYPE(c.geom, 0.005)
    ) AS geom
FROM
    G_BASE_VOIE.TA_VOIE a
    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_voie = a.objectid
    INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.objectid = b.fid_troncon
    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE d ON d.objectid = a.fid_typevoie
GROUP BY
    a.objectid,
    UPPER(TRIM(d.libelle)),
    UPPER(TRIM(a.libelle_voie)),
    UPPER(TRIM(a.complement_nom_voie))
;

-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_VOIE_AGGREGEE IS 'Vue matérialisée matérialisant la géométrie des voies.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_VOIE_AGGREGEE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_VOIE_AGGREGEE 
ADD CONSTRAINT VM_VOIE_AGGREGEE_PK 
PRIMARY KEY (ID_VOIE);

-- 6. Création des index
CREATE INDEX VM_VOIE_AGGREGEE_SIDX
ON G_BASE_VOIE.VM_VOIE_AGGREGEE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_VOIE_AGGREGEE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_VOIE_AGGREGEE(LIBELLE_VOIE)
    TABLESPACE G_ADT_INDX;

-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_VOIE_AGGREGEE TO G_ADMIN_SIG;

