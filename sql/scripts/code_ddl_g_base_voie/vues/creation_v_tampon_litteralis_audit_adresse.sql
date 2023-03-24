/*
Création de la vue V_TAMPON_LITTERALIS_AUDIT_ADRESSE - de la structure tampon du projet LITTERALIS - vérifiant la présence d''erreur dans la table TA_TAMPON_LITTERALIS_ADRESSE. Les erreurs vérifiées sont celles qui ont été remontées dans les rapports d''erreurs.
*/
/*
DROP VIEW G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ADRESSE;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_TAMPON_LITTERALIS_AUDIT_ADRESSE" ("OBJECTID", "THEMATIQUE", "ID_ADRESSE", "CODE_VOIE", "NATURE", "NUMERO", "REPETITION", "DISTANCE", 
    CONSTRAINT "V_TAMPON_LITTERALIS_AUDIT_ADRESSE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS
WITH
    C_1 AS(-- Sélection des doublons de code_voie, nature, numero, repetition
        SELECT
            code_voie,
            nature,
            numero,
            repetition
        FROM
           G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE
        GROUP BY
            code_voie,
            nature,
            numero,
            repetition
        HAVING
            COUNT(objectid) > 1
    ),
    
    C_2 AS(-- Mise en forme des doublons de code_voie, nature, numero, repetition
        SELECT
            'Doublons de code_voie, nature, numero, repetition' AS thematique,
            b.objectid AS id_adresse,
            b.code_voie,
            b.nature,
            b.numero,
            CASE 
                WHEN a.repetition IS NULL 
                    THEN '' 
                WHEN a.repetition IS NOT NULL AND a.repetition = b.repetition 
                    THEN a.repetition 
            END AS repetition,
            0 AS distance
        FROM
            C_1 a
            INNER JOIN G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE b ON b.code_voie = a.code_voie AND b.nature = a.nature AND b.numero = a.numero
    ),
    
    C_3 AS(-- Sélection des adresses situées à 1km ou plus de leur voie
        SELECT
            'Adresse située à 1km ou plus de sa voie' AS thematique,
            a.objectid AS id_adresse,
            a.code_voie,
            a.nature,
            a.numero,
            a.repetition,
            ROUND(SDO_GEOM.SDO_DISTANCE(
                a.geometry,
                SDO_LRS.PROJECT_PT(
                    SDO_LRS.CONVERT_TO_LRS_GEOM(b.geometry, m.diminfo),
                    a.geometry,
                    0.005
                )
            ), 2) AS distance
        FROM
            G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE a
            INNER JOIN G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE b ON b.objectid = a.fid_voie,
            USER_SDO_GEOM_METADATA m
        WHERE
            m.TABLE_NAME = 'TA_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE'
            AND ROUND(SDO_GEOM.SDO_DISTANCE(
                a.geometry,
                SDO_LRS.PROJECT_PT(
                    SDO_LRS.CONVERT_TO_LRS_GEOM(b.geometry, m.diminfo),
                    a.geometry,
                    0.005
                )
            ),2) >=1000
    ),
    
    C_4 AS(-- Sélection des adresses n''ayant pas de numéro
        SELECT
            'Adresse sans numéro' AS thematique,
            objectid AS id_adresse,
            code_voie,
            nature,
            numero,
            repetition,
            0 AS distance
        FROM
            G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE
        WHERE
            numero IS NULL
    ),

    C_5 AS(-- Sélection des voies présentes dans la table des tronçons
        SELECT
            id_voie_gauche AS code_voie
        FROM
            G_BASE_VOIE.TA_TAMPON_LITTERALIS_TRONCON
        UNION ALL
        SELECT
            id_voie_droite AS code_voie
        FROM
            G_BASE_VOIE.TA_TAMPON_LITTERALIS_TRONCON
    ),

    C_6 AS(-- Sélection des voies associées aux adresses absentes de la table des tronçons
        SELECT
            'Voie absente de la table des tronçons' AS thematique,
            objectid AS id_adresse,
            code_voie,
            nature,
            numero,
            repetition,
            0 AS distance
        FROM
            G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE
        WHERE
            code_voie NOT IN(SELECT DISTINCT code_voie FROM C_5)
    ),
    
    C_7 AS(-- Mise en forme des données
        SELECT
            thematique,
            id_adresse,
            code_voie,
            nature,
            numero,
            repetition,
            distance
        FROM
            C_2
        UNION ALL
        SELECT
            thematique,
            id_adresse,
            code_voie,
            nature,
            numero,
            repetition,
            distance
        FROM
            C_3
        UNION ALL
        SELECT
            thematique,
            id_adresse,
            code_voie,
            nature,
            numero,
            repetition,
            distance
        FROM
            C_4
        UNION ALL
        SELECT
            thematique,
            id_adresse,
            code_voie,
            nature,
            numero,
            repetition,
            distance
        FROM
            C_6
    )
    
    SELECT
        rownum AS objectid,
        thematique,
        id_adresse,
        code_voie,
        nature,
        numero,
        repetition,
        distance
    FROM
        C_7
    ORDER BY
        thematique,
        code_voie,
        numero,
        repetition;
        
-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ADRESSE IS 'Vue d''audit - de la structure tampon du projet LITTERALIS - vérifiant la présence d''erreur dans la table TA_TAMPON_LITTERALIS_ADRESSE. Les erreurs vérifiées sont celles qui ont été remontées dans les rapports d''erreurs.';
COMMENT ON COLUMN G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ADRESSE.OBJECTID IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ADRESSE.THEMATIQUE IS 'Thème de l''erreur identifiée.';
COMMENT ON COLUMN G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ADRESSE.ID_ADRESSE IS 'Identifiant des adresses (présents dans TA_INFOS_SEUIL).';
COMMENT ON COLUMN G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ADRESSE.CODE_VOIE IS 'Identifiant de la voie associée à l''adresse.';
COMMENT ON COLUMN G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ADRESSE.NATURE IS 'Nature de l''adresse';
COMMENT ON COLUMN G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ADRESSE.NUMERO IS 'Numéro de l''adresse';
COMMENT ON COLUMN G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ADRESSE.REPETITION IS 'Complément de numéro de l''adresse.';
COMMENT ON COLUMN G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ADRESSE.DISTANCE IS 'Valeur en erreur.';

-- 3. Création des droits de lecture
GRANT SELECT ON G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ADRESSE TO G_ADMIN_SIG;

/

