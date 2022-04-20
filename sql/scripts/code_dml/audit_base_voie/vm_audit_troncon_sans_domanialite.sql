-- VM_AUDIT_TRONCON_SANS_DOMANIALITE: vue permettant de connaitre les troncons qui ne n''ont pas de domanialite (absent de la table SIREO_LEC.OUT_DOMANIALITE)
-- 1. Creation de la vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TRONCON_SANS_DOMANIALITE (IDENTIFIANT, CODE_TRONCON, GEOM)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
SELECT
    rownum AS identifiant,
    a.cnumtrc AS code_troncon,
    a.ora_geometry
FROM
    G_BASE_VOIE.TEMP_ILTATRC a
WHERE
    a.cdvaltro = 'V'
    AND a.cnumtrc NOT IN 
        (
            SELECT
                cnumtrc
            FROM 
                SIREO_LEC.OUT_DOMANIALITE
        );


-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_TRONCON_SANS_DOMANIALITE
ADD CONSTRAINT VM_AUDIT_TRONCON_SANS_DOMANIALITE_PK 
PRIMARY KEY (IDENTIFIANT);


-- 3. Commentaire de la vue matérialisée.
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TRONCON_SANS_DOMANIALITE  IS 'Vue permettant de connaitre les troncons qui ne n''ont pas de domanialite (absent de la table SIREO_LEC.OUT_DOMANIALITE)';


-- 4. Commentaire des champs
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_SANS_DOMANIALITE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_SANS_DOMANIALITE.CODE_TRONCON IS 'Identifiant du troncon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_SANS_DOMANIALITE.GEOM IS 'Géométrie du troncon de type linéaire.';


-- 5. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_AUDIT_TRONCON_SANS_DOMANIALITE',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.001), MDSYS.SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.001)), 
    2154
);


-- 6. Création de l'index spatial
CREATE INDEX VM_AUDIT_TRONCON_SANS_DOMANIALITE_SIDX
ON VM_AUDIT_TRONCON_SANS_DOMANIALITE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=LINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);