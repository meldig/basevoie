-- VM_AUDIT_RESULTAT_TYPE_VOIE_SANS_LITY_VOIE: Type de voie disposant d'un code mais pas de libellé: Certains types de voies de TYPEVOIE disposent d'un CCODTVO, mais pas d'un LITYVOIE (libelle)

-- 0. Suppression de l'ancienne vue matérialisée
-- DROP MATERIALIZED VIEW VM_AUDIT_TYPE_VOIE_DANS_VOIEVOI_MAIS_ABSENT_TYPE_VOIE;

-- 1. Création de la vue.
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_RESULTAT_TYPE_VOIE_SANS_LITY_VOIE (identifiant, code_type_voie, libelle)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
    SELECT
        objectid,
        code_type_voie,
        libelle
    FROM
        G_BASE_VOIE.TA_TYPE_VOIE
    WHERE
        libelle IS NULL
;


-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_RESULTAT_TYPE_VOIE_SANS_LITY_VOIE
ADD CONSTRAINT VM_AUDIT_RESULTAT_TYPE_VOIE_SANS_LITY_VOIE_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commetaire de la vue matérialisée.
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_RESULTAT_TYPE_VOIE_SANS_LITY_VOIE  IS 'Vue permettant de reperer les types de voies de la table typevoie sans libelle.';

-- 4. Commentaire des colonnes.
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_TYPE_VOIE_SANS_LITY_VOIE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_TYPE_VOIE_SANS_LITY_VOIE.code_type_voie IS 'Identifiant du type de voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_TYPE_VOIE_SANS_LITY_VOIE.libelle IS 'Libelle du type de voie.';