/*
Création de la vue V_LITTERALIS_AUDIT_REGROUPEMENT - de la structure tampon du projet LITTERALIS - vérifiant la présence d''erreur dans la table VM_TAMPON_LITTERALIS_REGROUPEMENT. Les erreurs vérifiées sont celles qui ont été remontées dans les rapports d''erreurs.
*/
/*
DROP VIEW G_BASE_VOIE.V_LITTERALIS_AUDIT_REGROUPEMENT;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE EDITIONABLE VIEW "G_BASE_VOIE"."V_LITTERALIS_AUDIT_REGROUPEMENT" (
    OBJECTID,
    THEMATIQUE, 
    CODE_REGR, 
    NOM, 
    TYPE, 
    CODE_INSEE, 
    CONSTRAINT "V_LITTERALIS_AUDIT_REGROUPEMENT_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
    WITH
        C_1 AS(
            SELECT
                'Regroupement ayant un type non-conforme au cahier des charges' AS thematique,
                code_regr, 
                nom,
                type,
                code_insee
            FROM
                 G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT
            WHERE
                type NOT IN('Secteur', 'Quartier', 'Canton', 'Arrondissement', 'Zone')
        )
        
        SELECT -- Sélection des voies présentes dans les zones particulières, mais absentes de la table des tronçons.
            rownum AS objectid,
            a.thematique,
            a.code_regr,
            a.nom,
            a.type,
            a.code_insee
        FROM
            C_1 a;
        
-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_LITTERALIS_AUDIT_REGROUPEMENT IS 'Vue d''audit - de la structure tampon du projet LITTERALIS - vérifiant la présence d''erreur dans la table VM_TAMPON_LITTERALIS_REGROUPEMENT. Les erreurs vérifiées sont celles qui ont été remontées dans les rapports d''erreurs.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_REGROUPEMENT.OBJECTID IS 'Clé primaire de la vue correspondant à l''identifiant de chaque zone particulière.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_REGROUPEMENT.THEMATIQUE IS 'Thème de l''erreur identifiée.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT.CODE_REGR IS 'Identificateur unique et immuable du regroupement partagé entre Littéralis Expert et le SIG';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT.NOM IS 'Nom du regroupement.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT.TYPE IS 'Type de regroupement.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT.CODE_INSEE IS 'Code INSEE de la commune. Les regroupements pouvant recouvrir plusieurs communes il a été convenu avec le prestataire de ne rien mettre dans ce champ.';

-- 4. Création des droits de lecture
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_AUDIT_REGROUPEMENT TO G_ADMIN_SIG;

/

