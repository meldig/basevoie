-- VM_AUDIT_TYPE_VOIE_DANS_VOIEVOI_MAIS_ABSENT_TYPE_VOIE: Types de voie présents dans VOIEVOI, mais absents de TYPEVOIE: Certains types de voies sont présents dans le champ CCODTVO de VOIEVOIE, mais sont absents de TYPEVOIE. Ce cas correspond aux types de voies qu'on a arrêté de saisir tel que les canaux, les ruisseaux et les rivières. Les types ont été supprimés de TYPEVOIE, mais les tronçons n'ont pas été invalidés.

-- 0. Suppression de l'ancienne vue matérialisée
-- DROP MATERIALIZED VIEW VM_AUDIT_TYPE_VOIE_DANS_VOIEVOI_MAIS_ABSENT_TYPE_VOIE;

-- 1. Creation de la vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TYPE_VOIE_DANS_VOIEVOI_MAIS_ABSENT_TYPE_VOIE (identifiant,code_type)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
WITH CTE_1 AS 
    (
    SELECT
        DISTINCT ccodtvo AS ccodtvo
    FROM 
        G_BASE_VOIE.TEMP_VOIEVOI
    WHERE 
        ccodtvo NOT IN (
                        SELECT 
                            ccodtvo
                        FROM
                            G_BASE_VOIE.TEMP_TYPEVOIE
                        )
    )
SELECT
    rownum,
    ccodtvo
FROM
    CTE_1
;


-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_TYPE_VOIE_DANS_VOIEVOI_MAIS_ABSENT_TYPE_VOIE
ADD CONSTRAINT VM_AUDIT_TYPE_VOIE_DANS_VOIEVOI_MAIS_ABSENT_TYPE_VOIE_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commentaire de la vue matérialisée.
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TYPE_VOIE_DANS_VOIEVOI_MAIS_ABSENT_TYPE_VOIE  IS 'Vue permettant de reperer les types de voies présent dans la table voievoi mais absent de la table typevoie.';

-- 4. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TYPE_VOIE_DANS_VOIEVOI_MAIS_ABSENT_TYPE_VOIE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TYPE_VOIE_DANS_VOIEVOI_MAIS_ABSENT_TYPE_VOIE.code_type IS 'Identifiant du type de voie.';