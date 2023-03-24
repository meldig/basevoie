/*
Création de la vue V_LITTERALIS_ADRESSE - du jeux d'export du projet LITTERALIS - contenant tous les seuils au format LITTERALIS.
*/
/*
DROP VIEW G_BASE_VOIE.V_LITTERALIS_ADRESSE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'V_LITTERALIS_ADRESSE';
COMMIT;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_LITTERALIS_ADRESSE" ("IDENTIFIANT", "CODE_VOIE", "CODE_POINT", "NATURE", "LIBELLE", "NUMERO", "REPETITION", "COTE", "GEOMETRY", 
    CONSTRAINT "V_LITTERALIS_ADRESSE_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS 
    SELECT
        objectid AS identifiant,
        code_voie,
        code_point,
        nature,
        libelle,
        numero,
        repetition,
        cote,
        geometry
    FROM
        G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE;
        
-- Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_LITTERALIS_ADRESSE IS 'Vue - du jeux d''export du projet LITTERALIS - contenant tous les seuils au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.CODE_VOIE IS 'Liaison avec la vue V_LITTERALIS_TRONCON sur la colonne CODE_RUE_G ou CODE_RUE_D.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.CODE_POINT IS 'Identificateur unique et immuable du point partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.NATURE IS 'Indique la nature du point : ADR = Adresse.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.LIBELLE IS 'Libellé du point affiché dans les textes (dans les actes…).';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.NUMERO IS 'Numéro postal.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.REPETITION IS 'Indique la valeur de répétition d’un numéro sur une rue. La saisie de la répétition est libre.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.COTE IS 'Définit sur quel côté de la voie s’appuie l’adresse : LesDeuxCotes, Impair, Pair.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.GEOMETRY IS 'Géométrie de l''adresse de type point.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_LITTERALIS_ADRESSE',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Affection des droits
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_ADRESSE TO G_ADMIN_SIG;

/

