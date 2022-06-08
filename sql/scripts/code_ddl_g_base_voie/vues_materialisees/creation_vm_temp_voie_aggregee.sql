/*
Création d'une vue matérialisée matérialisant la géométrie des voies pour corriger les tronçons affectés à plusieurs voies.
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
    a.ccomvoi AS id_voie,
    TRIM(UPPER(b.LITYVOIE)) ||' '|| TRIM(UPPER(a.cnominus)) ||' '|| TRIM(UPPER(a.cinfos)) AS libelle_voie,
    ROUND(SDO_GEOM.SDO_LENGTH(SDO_AGGR_UNION(SDOAGGRTYPE(d.ora_geometry, 0.005)), 0.001), 2) AS longueur,
    SDO_AGGR_UNION(SDOAGGRTYPE(d.ora_geometry, 0.005)) AS geom
FROM
    G_BASE_VOIE.TEMP_VOIEVOI a
    INNER JOIN G_BASE_VOIE.TEMP_TYPEVOIE b ON b.ccodtvo = a.ccodtvo
    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT c ON c.ccomvoi = a.ccomvoi
    INNER JOIN G_BASE_VOIE.TEMP_ILTATRC d ON d.cnumtrc = c.cnumtrc
WHERE
    a.cdvalvoi = 'V'
    AND c.cvalide = 'V'
    AND d.cdvaltro ='V'
GROUP BY
    a.ccomvoi,
    TRIM(UPPER(b.LITYVOIE)) ||' '|| TRIM(UPPER(a.cnominus)) ||' '|| TRIM(UPPER(a.cinfos));
    
-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_VOIE_AGGREGEE IS 'Vue matérialisée matérialisant la géométrie des voies depuis les tables d''import. Cette VM sert UNIQUEMENT à corriger les tronçons affectés à plusieurs voies.';

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

