-- VM_AUDIT_TRONCON_HORS_MEL: Troncons situés hors MEL suite au changement de référentiel commune

-- 0. Suppression de l'ancienne vue matérialisée
/*
DROP INDEX VM_AUDIT_TRONCON_HORS_MEL_SIDX;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_AUDIT_TRONCON_HORS_MEL';
DROP MATERIALIZED VIEW VM_AUDIT_TRONCON_HORS_MEL;
*/

-- 1. Création de la vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TRONCON_HORS_MEL (IDENTIFIANT,CODE_TRONCON, GEOM)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
SELECT
	ROWNUM as identifiant,
	a.cnumtrc,
	a.ora_geometry
FROM
	G_BASE_VOIE.temp_iltatrc a,
	G_REFERENTIEL.MEL b
WHERE
	sdo_anyinteract(a.ora_geometry,b.geom) <> 'TRUE'
AND
    a.cdvaltro = 'V'
	;

-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_TRONCON_HORS_MEL
ADD CONSTRAINT VM_AUDIT_TRONCON_HORS_MEL_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commentaire de la vue materialisée.
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TRONCON_HORS_MEL  IS 'Troncons situés hors MEL suite au changement de référentiel commune';

-- 4. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_HORS_MEL.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_HORS_MEL.CODE_TRONCON IS 'Numéro du troncon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_HORS_MEL.GEOM IS 'Géométrie du troncon de type linéaire.';

-- 5. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_AUDIT_TRONCON_HORS_MEL',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.001), MDSYS.SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.001)), 
    2154
);


-- 6. Création de l'index spatial
CREATE INDEX VM_AUDIT_TRONCON_HORS_MEL_SIDX
ON VM_AUDIT_TRONCON_HORS_MEL(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=LINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);