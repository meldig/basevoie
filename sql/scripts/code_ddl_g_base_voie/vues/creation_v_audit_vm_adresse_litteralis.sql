/*
Création de la vue V_AUDIT_VM_ADRESSE_LITTERALIS faisant l'audit de la VM VM_ADRESSE_LITTERALIS et permettant de savoir si elle est diffusable ou si elle contient des erreurs.
*/
/*
DROP VIEW G_BASE_VOIE.V_AUDIT_VM_ADRESSE_LITTERALIS;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_AUDIT_VM_ADRESSE_LITTERALIS" ("OBJECTID", "TYPE_ERREUR", "NOMBRE", 
    CONSTRAINT "V_AUDIT_VM_ADRESSE_LITTERALIS_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
WITH
    C_1 AS(-- Identification des doublons de tuple code_voie, nature, numero, repetition
        SELECT
            code_voie,
            nature,
            numero,
            repetition
        FROM
            G_BASE_VOIE.VM_ADRESSE_LITTERALIS_2023
        GROUP BY
            code_voie,
            nature,
            numero,
            repetition
        HAVING
            COUNT(code_voie) > 1
            AND COUNT(nature) > 1
            AND COUNT(numero) > 1
            AND COUNT(repetition) > 1
    ),
    
    C_2 AS(
        SELECT
            'Doublon du tuple code_voie, nature, numero, repetition' AS type_erreur,
            COUNT(*) AS nombre
        FROM
            C_1
    ),

    C_3 AS(-- Sélection des identifiants de voies administratives présents dans VM_ADRESSE_LITTERALIS_2023 mais absents de VM_TRONCON_LITTERALIS_2023
        SELECT 
            'Voie présente dans VM_ADRESSE_LITTERALIS_2023 mais absente de VM_TRONCON_LITTERALIS_2023' AS type_erreur,
            COUNT(code_voie) AS nombre
        FROM
            G_BASE_VOIE.VM_ADRESSE_LITTERALIS_2023
        WHERE
            code_voie NOT IN(SELECT code_rue_g FROM G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023)
            AND code_voie NOT IN(SELECT code_rue_d FROM G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023)    
    ),

    C_4 AS(
        SELECT
            type_erreur,
            nombre
        FROM
            C_2
        UNION ALL
        SELECT
            type_erreur,
            nombre
        FROM
            C_3
    )
    
    SELECT
        rownum AS objectid,
        type_erreur,
        nombre
    FROM
        C_4;

-- 2. Création des commentaires
COMMENT ON COLUMN "G_BASE_VOIE"."V_AUDIT_VM_ADRESSE_LITTERALIS"."OBJECTID" IS 'Clé primaire de la vue.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_AUDIT_VM_ADRESSE_LITTERALIS"."TYPE_ERREUR" IS 'Type d''erreur.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_AUDIT_VM_ADRESSE_LITTERALIS"."NOMBRE" IS 'Nombre d''entités concernées par l''erreur.';
COMMENT ON TABLE "G_BASE_VOIE"."V_AUDIT_VM_ADRESSE_LITTERALIS"  IS 'Vue faisant l''audit de la VM VM_ADRESSE_LITTERALIS et permettant de savoir si elle est diffusable ou si elle contient des erreurs.';

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_AUDIT_VM_ADRESSE_LITTERALIS TO G_ADMIN_SIG;
/

