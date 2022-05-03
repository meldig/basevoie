/*
Création d'une vue matérialisée transitoire matérialisant la géométrie des voies pour corriger les tronçons affectés à plusieurs voies.
*/
-- 1. Suppression de la VM et de ses métadonnées
/*DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_VOIE_AGGREGEE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TEMP_VOIE_AGGREGEE';
COMMIT;
*/
-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TEMP_VOIE_AGGREGEE" ("ID_VOIE","LIBELLE_VOIE","LONGUEUR","GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
    a.objectid AS id_voie,
    TRIM(UPPER(b.libelle)) ||' '|| TRIM(UPPER(a.libelle_voie)) ||' '|| TRIM(UPPER(a.complement_nom_voie)) AS libelle_voie,
    ROUND(SDO_GEOM.SDO_LENGTH(SDO_AGGR_UNION(SDOAGGRTYPE(d.geom, 0.005)), 0.001), 2) AS longueur,
    SDO_AGGR_UNION(SDOAGGRTYPE(d.geom, 0.005)) AS geom
FROM
    G_BASE_VOIE.TEMP_VOIE a
    INNER JOIN G_BASE_VOIE.TEMP_TYPE_VOIE b ON b.objectid = a.fid_typevoie
    INNER JOIN G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE c ON c.fid_voie = a.objectid
    INNER JOIN G_BASE_VOIE.TEMP_TRONCON d ON d.objectid = c.fid_troncon
WHERE
    a.cdvalvoi = 'V'
    AND c.cvalide = 'V'
    AND d.cdvaltro ='V'
GROUP BY
    a.objectid,
    TRIM(UPPER(b.libelle)) ||' '|| TRIM(UPPER(a.libelle_voie)) ||' '|| TRIM(UPPER(a.complement_nom_voie));
    
-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_VOIE_AGGREGEE IS 'Vue matérialisée transitoire matérialisant la géométrie des voies depuis les tables d''import. Cette VM sert UNIQUEMENT à corriger les tronçons affectés à plusieurs voies avant d''insérer les données dans les tables de production.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_VOIE_AGGREGEE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_VOIE_AGGREGEE 
ADD CONSTRAINT VM_TEMP_VOIE_AGGREGEE_PK 
PRIMARY KEY (ID_VOIE);

-- 6. Création des index
CREATE INDEX VM_TEMP_VOIE_AGGREGEE_SIDX
ON G_BASE_VOIE.VM_TEMP_VOIE_AGGREGEE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_TEMP_VOIE_AGGREGEE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_TEMP_VOIE_AGGREGEE(LIBELLE_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_VOIE_AGGREGEE_LONGUEUR_IDX ON G_BASE_VOIE.VM_TEMP_VOIE_AGGREGEE(LONGUEUR)
    TABLESPACE G_ADT_INDX;
    
-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_VOIE_AGGREGEE TO G_ADMIN_SIG;

/

