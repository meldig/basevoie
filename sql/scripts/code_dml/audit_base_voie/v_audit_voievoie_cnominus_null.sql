-- V_AUDIT_VOIEVOIE_CNOMINUS_NULL: champ CNOMINUS NULL dans VOIEVOI (nom de voie). Certaines voies n'ont pas de nom de voie
-- 1. Creation de la vue.
CREATE OR REPLACE FORCE VIEW V_AUDIT_VOIEVOIE_CNOMINUS_NULL (identifiant, code_voie,
CONSTRAINT "V_AUDIT_VOIEVOIE_CNOMINUS_NULL_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS
WITH CTE_1 AS 
    (
    SELECT
        ccomvoi
    FROM
        G_BASE_VOIE.TEMP_VOIEVOI
    WHERE
        cdvalvoi = 'V'
        AND 
        cnominus IS NULL
    )
SELECT
    ROWNUM,
    ccomvoi
FROM
    CTE_1
;


-- 2. Commentaire de la vue.
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_VOIEVOIE_CNOMINUS_NULL  IS 'Vue permettant de reperer les voies sans nom';


-- 3. Commentaire des colonnes.
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_VOIEVOIE_CNOMINUS_NULL.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_VOIEVOIE_CNOMINUS_NULL.code_voie IS 'identifiant de la voie.';
