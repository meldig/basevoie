/*
Création de la VM VM_TEMP_H_VOIE_ADMINISTRATIVE_MATERIALISEE matérialisant la géométrie des voies administrative.
*/
-- 1. Suppression de la VM et de ses métadonnées
/*DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_H_VOIE_ADMINISTRATIVE_MATERIALISEE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TEMP_H_VOIE_ADMINISTRATIVE_MATERIALISEE';
COMMIT;
*/
-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TEMP_H_VOIE_ADMINISTRATIVE_MATERIALISEE" ("ID_VOIE_ADMINISTRATIVE","NOM_VOIE","CODE_INSEE", "GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
    d.objectid AS id_voie_administrative,
    SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 1) || ' ' || d.libelle_voie || ' ' || d.complement_nom_voie AS nom_voie,
    d.code_insee,
    SDO_AGGR_UNION(
        SDOAGGRTYPE(a.geom, 0.005)
    ) AS geom
FROM
    G_BASE_VOIE.TEMP_H_TRONCON a
    INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE b ON b.objectid = a.fid_troncon
    INNER JOIN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
    INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE d ON d.objectid = c.fid_voie_administrative
GROUP BY
    d.objectid,
    SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 1) || ' ' || d.libelle_voie || ' ' || d.complement_nom_voie,
    d.code_insee;


-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_H_VOIE_ADMINISTRATIVE_MATERIALISEE IS 'Vue matérialisée matérialisant la géométrie des voies administrative.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_H_VOIE_ADMINISTRATIVE_MATERIALISEE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_H_VOIE_ADMINISTRATIVE_MATERIALISEE 
ADD CONSTRAINT VM_TEMP_H_VOIE_ADMINISTRATIVE_MATERIALISEE_PK 
PRIMARY KEY (ID_VOIE_ADMINISTRATIVE);

-- 6. Création des index
CREATE INDEX VM_TEMP_H_VOIE_ADMINISTRATIVE_MATERIALISEE_SIDX
ON G_BASE_VOIE.VM_TEMP_H_VOIE_ADMINISTRATIVE_MATERIALISEE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_TEMP_H_VOIE_ADMINISTRATIVE_MATERIALISEE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_TEMP_H_VOIE_ADMINISTRATIVE_MATERIALISEE(NOM_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_H_VOIE_ADMINISTRATIVE_MATERIALISEE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_TEMP_H_VOIE_ADMINISTRATIVE_MATERIALISEE(CODE_INSEE)
    TABLESPACE G_ADT_INDX;

-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_H_VOIE_ADMINISTRATIVE_MATERIALISEE TO G_ADMIN_SIG;

/

