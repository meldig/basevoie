-- VM_AUDIT_TYPE_VOIE_SANS_LITY_VOIE: Type de voie disposant d'un code mais pas de libellé: Certains types de voies de TYPEVOIE disposent d'un CCODTVO, mais pas d'un LITYVOIE (libelle)

-- 0. Suppression de l'ancienne vue matérialisée
-- DROP MATERIALIZED VIEW VM_AUDIT_TYPE_VOIE_SANS_LITY_VOIE;

-- 1. Création de la vue.
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TYPE_VOIE_SANS_LITY_VOIE (identifiant, code_type, libelle_type, cdclatvo)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
    SELECT
        rownum,
        ccodtvo,
        lityvoie,
        cdclatvo
    FROM
        G_BASE_VOIE.TEMP_TYPEVOIE
    WHERE
        lityvoie IS NULL
;


-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_TYPE_VOIE_SANS_LITY_VOIE
ADD CONSTRAINT VM_AUDIT_TYPE_VOIE_SANS_LITY_VOIE_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commetaire de la vue matérialisée.
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TYPE_VOIE_SANS_LITY_VOIE  IS 'Vue permettant de reperer les types de voies de la table typevoie sans libelle.';

-- 4. Commentaire des colonnes.
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TYPE_VOIE_SANS_LITY_VOIE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TYPE_VOIE_SANS_LITY_VOIE.code_type IS 'Identifiant du type de voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TYPE_VOIE_SANS_LITY_VOIE.libelle_type IS 'Libelle du type de voie.';