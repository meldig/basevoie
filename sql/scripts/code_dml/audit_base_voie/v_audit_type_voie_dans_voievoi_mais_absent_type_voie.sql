-- V_AUDIT_TYPE_VOIE_DANS_VOIEVOI_MAIS_ABSENT_TYPE_VOIE: Types de voie présents dans VOIEVOI, mais absents de TYPEVOIE: Certains types de voies sont présents dans le champ CCODTVO de VOIEVOIE, mais sont absents de TYPEVOIE. Ce cas correspond aux types de voies qu'on a arrêté de saisir tel que les canaux, les ruisseaux et les rivières. Les types ont été supprimés de TYPEVOIE, mais les tronçons n'ont pas été invalidés.
-- 1. Creation de la vue
CREATE OR REPLACE FORCE VIEW V_AUDIT_TYPE_VOIE_DANS_VOIEVOI_MAIS_ABSENT_TYPE_VOIE (identifiant,code_type,
CONSTRAINT "V_AUDIT_TYPE_VOIE_DANS_VOIEVOI_MAIS_ABSENT_TYPE_VOIE_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS
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


-- 2. Commentaire de la vue
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_TYPE_VOIE_DANS_VOIEVOI_MAIS_ABSENT_TYPE_VOIE  IS 'Vue permettant de reperer les types de voies présent dans la table voievoi mais absent de la table typevoie.';


-- 3. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TYPE_VOIE_DANS_VOIEVOI_MAIS_ABSENT_TYPE_VOIE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TYPE_VOIE_DANS_VOIEVOI_MAIS_ABSENT_TYPE_VOIE.code_type IS 'Identifiant du type de voie.';