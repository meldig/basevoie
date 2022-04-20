-- VM_AUDIT_SEUIL_HORS_MEL: Seuils situés hors MEL suite au changement de référentiel commune
-- 1. Création de la vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_SEUIL_HORS_MEL (IDENTIFIANT, CODE_SEUIL, GEOM)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
SELECT
	ROWNUM as identifiant,
	a.idseui,
	a.ora_geometry
FROM
	G_BASE_VOIE.temp_iltaseu a,
	G_REFERENTIEL.MEL b
WHERE
	sdo_anyinteract(a.ora_geometry,b.geom) <> 'TRUE'
	;

-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_SEUIL_HORS_MEL
ADD CONSTRAINT VM_AUDIT_SEUIL_HORS_MEL_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commentaire de la vue materialisée.
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_SEUIL_HORS_MEL  IS 'Seuils situés hors MEL suite au changement de référentiel commune';

-- 4. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_SEUIL_HORS_MEL.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_SEUIL_HORS_MEL.CODE_SEUIL IS 'Identifiant du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_SEUIL_HORS_MEL.GEOM IS 'Géométrie du seuil de type point.';

-- 5. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_AUDIT_SEUIL_HORS_MEL',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.001), MDSYS.SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.001)), 
    2154
);


-- 6. Création de l'index spatial
CREATE INDEX VM_AUDIT_SEUIL_HORS_MEL_SIDX
ON VM_AUDIT_SEUIL_HORS_MEL(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=POINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);