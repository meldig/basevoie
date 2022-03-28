-- V_AUDIT_TRONCON_HORS_MEL: Troncons situés hors MEL suite au changement de référentiel commune

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW V_AUDIT_TRONCON_HORS_MEL(identifiant,code_troncon,
CONSTRAINT "V_AUDIT_TRONCON_HORS_MEL_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS
SELECT
	ROWNUM as identifiant,
	a.cnumtrc
FROM
	G_BASE_VOIE.temp_iltatrc a,
	G_REFERENTIEL.MEL b
WHERE
	sdo_anyinteract(a.ora_geometry,b.geom) <> 'TRUE'
AND
    a.cdvaltro = 'V'
	;


-- 2. Commentaire de la vue.
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_TRONCON_HORS_MEL  IS 'Troncons situés hors MEL suite au changement de référentiel commune';

-- 3. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_HORS_MEL.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_HORS_MEL.CODE_TRONCON IS 'Numéro du troncon.';