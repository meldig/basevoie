-- V_LONGUEUR_TRONCON: longueur des troncons

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW V_LONGUEUR_TRONCON(identifiant,longueur, geom,
CONSTRAINT "V_LONGUEUR_TRONCON_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS
SELECT
    cnumtrc AS numero_troncon,
    SDO_LRS.GEOM_SEGMENT_LENGTH
    (
     ora_geometry
    ),
    ora_geometry
FROM
    G_BASE_VOIE.TEMP_ILTATRC
WHERE
    CDVALTRO = 'V'
;


-- 2. Commentaire de la vue.
COMMENT ON TABLE G_BASE_VOIE.V_LONGUEUR_TRONCON  IS 'Vue qui présente la longueur des troncons valides';

-- 3. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.V_LONGUEUR_TRONCON.IDENTIFIANT IS 'Clé primaire de la vue, numero du troncon.';
COMMENT ON COLUMN G_BASE_VOIE.V_LONGUEUR_TRONCON.LONGUEUR IS 'longueur du troncon.';
COMMENT ON COLUMN G_BASE_VOIE.V_LONGUEUR_TRONCON.GEOM IS 'Géométrie du troncon de type ligne.';