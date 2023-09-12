-- V_AUDIT_TYPE_VOIE_SANS_LITY_VOIE: Type de voie disposant d'un code mais pas de libellé: Certains types de voies de TYPEVOIE disposent d'un CCODTVO, mais pas d'un LITYVOIE (libelle)

-- 1. Création de la vue.
CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_AUDIT_TYPE_VOIE_SANS_LITY_VOIE (identifiant, code_type, libelle_type,cdclatvo,
CONSTRAINT "V_AUDIT_TYPE_VOIE_SANS_LITY_VOIE_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS
WITH CTE_1 AS (
    SELECT
        ccodtvo,
        lityvoie,
        cdclatvo
    FROM
        G_BASE_VOIE.TEMP_TYPEVOIE
    WHERE
        lityvoie IS NULL
    )
SELECT
        rownum,
        ccodtvo,
        lityvoie,
        cdclatvo
FROM
    CTE_1
;


-- 2. Commetaire de la vue.
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_TYPE_VOIE_SANS_LITY_VOIE  IS 'Vue permettant de reperer les types de voies de la table typevoie sans libelle.';

-- 3. Commentaire des colonnes.
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TYPE_VOIE_SANS_LITY_VOIE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TYPE_VOIE_SANS_LITY_VOIE.code_type IS 'Identifiant du type de voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TYPE_VOIE_SANS_LITY_VOIE.libelle_type IS 'Libelle du type de voie.';