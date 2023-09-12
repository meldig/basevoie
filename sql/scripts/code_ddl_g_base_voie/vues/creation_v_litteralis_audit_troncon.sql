/*
Création de la vue V_LITTERALIS_AUDIT_TRONCON - de la structure tampon du projet LITTERALIS - vérifiant la présence d''erreur dans la table VM_TAMPON_LITTERALIS_TRONCON. Les erreurs vérifiées sont celles qui ont été remontées dans les rapports d''erreurs.
*/
/*
DROP VIEW G_BASE_VOIE.V_LITTERALIS_AUDIT_TRONCON;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_LITTERALIS_AUDIT_TRONCON" (
    OBJECTID, 
    THEMATIQUE, 
    ID_TRONCON, 
    CLASSEMENT, 
    CODE_INSEE, 
    CONSTRAINT "V_LITTERALIS_AUDIT_TRONCON_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS
WITH
    C_1 AS(-- Sélection des tronçon dont le code INSEE est en erreur (absent de la couche des communes ou NULL)
        SELECT
            objectid,
            code_insee_voie_gauche AS code_insee
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON
        WHERE
            code_insee_voie_gauche NOT IN(SELECT code_insee FROM G_REFERENTIEL.MEL_COMMUNE_LLH)
            OR code_insee_voie_gauche IS NULL
        UNION ALL
        SELECT
            objectid,
            code_insee_voie_gauche AS code_insee
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON
        WHERE
            code_insee_voie_gauche NOT IN(SELECT code_insee FROM G_REFERENTIEL.MEL_COMMUNE_LLH)
            OR code_insee_voie_droite IS NULL
    ),
    
    C_2 AS(-- Mise en forme des tronçons dont le code INSEE est en erreur
        SELECT
            'Code INSEE en erreur' AS thematique,
            objectid AS id_troncon,
            '' AS classement,
            code_insee
        FROM
            C_1
    ),
    
    C_3 AS(-- Sélection des doublons d'identifiant de tronçons
        SELECT
            'Doublons d''dentifiants de tronçon' AS thematique,
            objectid AS id_troncon,
            '' AS classement,
            '' AS code_insee
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON
        GROUP BY
            'Doublons d''dentifiants de tronçon',
            objectid,
            '',
            ''
        HAVING
            COUNT(objectid) > 1
    ),
    
    C_4 AS(-- Sélection des doublons de géométrie pour des tronçons ayant un identifiant différent
        SELECT
            a.objectid AS id_troncon_1,
            b.objectid AS id_troncon_2
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON a,
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON b
        WHERE
            SDO_EQUAL(a.geometry, b.geometry) = 'TRUE'
            AND a.objectid < b.objectid
    ),
    
    C_5 AS(-- Mise en forme des tronçons en doublon de géométrie mais d'identifiant différent
        SELECT
            'Doublons de Géométrie de tronçons ayant un identifiant différent : ' || id_troncon_1 || ' - ' || id_troncon_2 AS thematique,
            id_troncon_1 AS id_troncon,
            '' AS classement,
            '' AS code_insee
        FROM
            C_4
    ),

    C_6 AS(-- Sélection des classements absents du cahier des charges
        SELECT
            'Classement non-conforme au cahier des charges' AS thematique,
            objectid AS id_troncon,
            classement,
            '' AS code_insee
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON
        WHERE
            classement NOT IN(SELECT classement FROM G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT)
    ),
    
    C_7 AS(
        SELECT
            thematique,
            id_troncon,
            classement,
            code_insee
        FROM
            C_2
        UNION ALL
        SELECT
            thematique,
            id_troncon,
            classement,
            code_insee
        FROM
            C_3
        UNION ALL
        SELECT
            thematique,
            id_troncon,
            classement,
            code_insee
        FROM
            C_5
        UNION ALL
        SELECT
            thematique,
            id_troncon,
            classement,
            code_insee
        FROM
            C_6
    )
    
    SELECT
        rownum AS objectid,
        thematique,
        id_troncon,
        classement,
        code_insee
    FROM
        C_7;
        
-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_LITTERALIS_AUDIT_TRONCON IS 'Vue d''audit - de la structure tampon du projet LITTERALIS - vérifiant la présence d''erreur dans la table VM_TAMPON_LITTERALIS_TRONCON. Les erreurs vérifiées sont celles qui ont été remontées dans les rapports d''erreurs.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_TRONCON.OBJECTID IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_TRONCON.THEMATIQUE IS 'Thème de l''erreur identifiée.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_TRONCON.ID_TRONCON IS 'Identifiant des tronçons.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_TRONCON.CLASSEMENT IS 'Classement des tronçons.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_TRONCON.CODE_INSEE IS 'Code INSEE des tronçons.';

-- 3. Création des droits de lecture
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_AUDIT_TRONCON TO G_ADMIN_SIG;

/

