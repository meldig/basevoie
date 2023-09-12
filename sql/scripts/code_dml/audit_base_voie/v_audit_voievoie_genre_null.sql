-- V_AUDIT_VOIEVOIE_GENRE_NULL: Genre des voies valides NULL Le genre de certaines voies valides n'est pas renseigné (hors c'était une demande des élus)

--1. Creation de la vue
CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_AUDIT_VOIEVOIE_GENRE_NULL (IDENTIFIANT, CODE_VOIE,
CONSTRAINT "V_AUDIT_VOIEVOIE_GENRE_NULL_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS
WITH CTE_1 AS
    (
    SELECT
        CCOMVOI
    FROM
        G_BASE_VOIE.TEMP_VOIEVOI
    WHERE
        genre IS NULL
    AND
        cdvalvoi = 'V'
    )
SELECT
    rownum,
    ccomvoi
FROM
    CTE_1
;


-- 2. Commentaire de la vue
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_VOIEVOIE_GENRE_NULL  IS 'Vue permettant de reperer les voies dont le genre est NULL';


-- 3. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_VOIEVOIE_GENRE_NULL.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_VOIEVOIE_GENRE_NULL.code_voie IS 'identifiant de la voie.';