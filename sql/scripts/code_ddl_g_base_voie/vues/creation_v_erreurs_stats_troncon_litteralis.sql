/*
Création de la vue V_ERREURS_STATS_TRONCON_LITTERALIS permettant de connaître les types d''erreur présentes dans l''export LITTERALIS et le nombre d''objets concernés.
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE EDITIONABLE VIEW "G_BASE_VOIE"."V_ERREURS_STATS_TRONCON_LITTERALIS" ("IDENTIFIANT", "TYPE_ERREURS", "NOMBRE_OBJETS", 
 CONSTRAINT "V_ERREURS_STATS_TRONCON_LITTERALIS_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS 
WITH
    C_1 AS(-- Sélection des tronçons en doublons
        SELECT
            code_tronc
        FROM
            VM_TRONCON_LITTERALIS
        GROUP BY
            code_tronc
        HAVING
            COUNT(code_tronc) > 1
    ),
    
    C_2 AS(
        SELECT
            'Tronçons en doublons' AS type_erreurs,
            COUNT(CODE_TRONC) AS nombre_objets
        FROM
            C_1
    ),

    C_3 AS(-- Sélection des tronçons affectés à plusieurs voies
        SELECT
            a.code_tronc,
            COUNT(a.code_rue_g) AS nombre_objets
        FROM
            VM_TRONCON_LITTERALIS a
        GROUP BY
            a.code_tronc
        HAVING
            COUNT(a.code_rue_g) > 1
    ),

    C_4 AS(
        SELECT
            'Tronçons affectés à plusieurs voies' AS type_erreurs,
            COUNT(CODE_TRONC) AS nombre_objets
        FROM
            C_3
    ),

    C_5 AS(--Sélection des doublons absolus
        SELECT
            a.CODE_TRONC, 
            a.CLASSEMENT, 
            a.CODE_RUE_G,
            a.INSEE_G,
            a.CODE_RUE_D,
            a.INSEE_D
        FROM
            VM_TRONCON_LITTERALIS a
        GROUP BY
            a.CODE_TRONC, 
            a.CLASSEMENT, 
            a.CODE_RUE_G,
            a.INSEE_G,
            a.CODE_RUE_D,
            a.INSEE_D
        HAVING
            COUNT(a.CODE_TRONC)>1
            AND COUNT(a.CLASSEMENT)>1
            AND COUNT(a.CODE_RUE_G)>1
            AND COUNT(a.INSEE_G)>1
            AND COUNT(a.CODE_RUE_D)>1
            AND COUNT(a.INSEE_D)>1
    ),
    
    C_6 AS(
        SELECT
            'Doublons absolus' AS type_erreurs,
            COUNT(a.CODE_TRONC) AS nombre_objets
        FROM
            C_5 a
    ),

    C_7 AS(-- Vérification que chaque tronçon dispose d'une domanialité
        SELECT
            a.code_tronc,
            COUNT(a.classement) AS nombre_objets
        FROM
            VM_TRONCON_LITTERALIS a
        GROUP BY
            a.code_tronc
        HAVING
            COUNT(a.classement) > 1
    ),

    C_8 AS(
        SELECT
            'Tronçons disposant de plusieurs domanialités' AS type_erreurs,
            COUNT(code_tronc) AS nombre_objets
        FROM
            C_7
    ),

    C_9 AS(-- Vérification qu'aucune erreur ne se trouve dans les champs des codes INSEE
        SELECT
            code_tronc
        FROM
            VM_TRONCON_LITTERALIS
        WHERE
            INSEE_D IS NULL
            AND INSEE_G IS NULL
            OR INSEE_D = 'error'
            AND INSEE_G = 'error'
    ),

    C_10 AS(
        SELECT
            'Tronçons disposant d''un code INSEE NULL ou en erreur' AS type_erreurs,
            COUNT(code_tronc) AS nombre_objets
        FROM
            C_9
    ),
    
    C_11 AS(-- Sélection de l'identifiant maximum des tronçons
        SELECT
            MAX(a.objectid) AS max_code_troncon
        FROM
            G_BASE_VOIE.TA_TRONCON a
    ),
        
    C_12 AS(-- Sélection des tronçons virtuels
        SELECT
            'Tronçons virtuels (pour le cas où un tronçon est affecté à plusieurs voies) ' AS type_erreurs,
            COUNT(a.code_tronc) as nombre_objets
        FROM
            G_BASE_VOIE.VM_TRONCON_LITTERALIS a,
            C_11 b
        WHERE
            TO_NUMBER(a.code_tronc) > b.max_code_troncon
        GROUP BY
            'Tronçons virtuels (pour le cas où un tronçon est affecté à plusieurs voies) '
    ),

    C_13 AS(
        SELECT
            ID_TRONCON
        FROM
            G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS
        UNION ALL
        SELECT
            ID_TRONCON
        FROM
            G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS
        UNION ALL
        SELECT
            ID_TRONCON
        FROM
            G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS
        UNION ALL
        SELECT
            ID_TRONCON
        FROM
            G_BASE_VOIE.TEMP_TRC_SANS_DOMANIA_LITTERALIS
        UNION ALL
        SELECT
            ID_TRONCON
        FROM
            G_BASE_VOIE.TEMP_TRONCON_AUTRES_LITTERALIS
            
    ) ,

    C_14 AS(-- Sélection du delta entre le nombre de tronçons dans TA_TRONCON et dans VM_TRONCON_LITTERALIS
        SELECT
            'Delta entre le nombre de tronçons dans TA_RELATION_TRONCON_VOIE et dans VM_TRONCON_LITTERALIS ' AS type_erreurs,
            COUNT(a.fid_troncon) as nombre_objets
        FROM
            G_BASE_VOIE.TA_RELATION_TRONCON_VOIE a
        WHERE
           a.fid_troncon NOT IN(
            SELECT DISTINCT
                ID_TRONCON
            FROM
                C_13
           )
        GROUP BY
            'Delta entre le nombre de tronçons dans TA_RELATION_TRONCON_VOIE et dans VM_TRONCON_LITTERALIS '
    ),

    C_18 AS(    
        SELECT
            type_erreurs,
            nombre_objets
        FROM
            C_2
        UNION ALL
        SELECT
            type_erreurs,
            nombre_objets
        FROM
            C_4
        UNION ALL
        SELECT
            type_erreurs,
            nombre_objets
        FROM
            C_6
        UNION ALL
        SELECT
            type_erreurs,
            nombre_objets
        FROM
            C_8
        UNION ALL
        SELECT
            type_erreurs,
            nombre_objets
        FROM
            C_10
        UNION ALL
        SELECT
            type_erreurs,
            nombre_objets
        FROM
            C_12
        UNION ALL
        SELECT
            type_erreurs,
            nombre_objets
        FROM
            C_14
    )

    SELECT
        rownum AS IDENTIFIANT,
        type_erreurs AS TYPE_ERREURS,
        nombre_objets AS NOMBRE_OBJETS
    FROM
        C_18;

-- 2. Création des commentaires
COMMENT ON TABLE "G_BASE_VOIE"."V_ERREURS_STATS_TRONCON_LITTERALIS" IS 'Vue permettant de connaître les types d''erreur présentes dans l''export LITTERALIS et le nombre d''objets concernés.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_ERREURS_STATS_TRONCON_LITTERALIS"."IDENTIFIANT" IS 'Clé primaire de la vue (sans aucune autre signification particulière).';
COMMENT ON COLUMN "G_BASE_VOIE"."V_ERREURS_STATS_TRONCON_LITTERALIS"."TYPE_ERREURS" IS 'Types d''erreurs relevés dans VM_TRONCON_LITTERALIS.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_ERREURS_STATS_TRONCON_LITTERALIS"."NOMBRE_OBJETS" IS 'Nombre d''objets par types d''erreurs.';

-- 3. Création des droits
GRANT SELECT ON G_BASE_VOIE.V_ERREURS_STATS_TRONCON_LITTERALIS TO G_ADMIN_SIG;

/

