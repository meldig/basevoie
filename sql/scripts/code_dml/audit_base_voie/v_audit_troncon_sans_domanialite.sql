-- V_AUDIT_TRONCON_SANS_DOMANIALITE: vue permettant de connaitre les troncons qui ne n''ont pas de domanialite (absent de la table SIREO_LEC.OUT_DOMANIALITE)
-- 1. Creation de la vue
CREATE OR REPLACE FORCE VIEW V_AUDIT_TRONCON_SANS_DOMANIALITE (identifiant, code_troncon, geom,
CONSTRAINT "V_AUDIT_TRONCON_SANS_DOMANIALITE_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS
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


-- 2. Commentaire de la table
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_TRONCON_SANS_DOMANIALITE  IS 'Vue permettant de connaitre les troncons qui ne n''ont pas de domanialite (absent de la table SIREO_LEC.OUT_DOMANIALITE)';


-- 3. Commentaire des champs
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_SANS_DOMANIALITE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_SANS_DOMANIALITE.CODE_TRONCON IS 'Identifiant du troncon.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_SANS_DOMANIALITE.GEOM IS 'Géométrie du troncon de type linéaire.';