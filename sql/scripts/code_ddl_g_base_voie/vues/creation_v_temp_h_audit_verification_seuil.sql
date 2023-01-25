/*
Création de la vue V_TEMP_H_AUDIT_VERIFICATION_SEUIL - du projet H de correction des relations tronçons/seuils - permettant de suivre l'évolution de la vérification des relations seuils/tronçon
*/
/*
DROP VIEW G_BASE_VOIE.V_TEMP_H_AUDIT_VERIFICATION_SEUIL;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_TEMP_H_AUDIT_VERIFICATION_SEUIL(
    OBJECTID,
    ETAT_AVANCEMENT,
    NOMBRE,
    CONSTRAINT "V_TEMP_H_AUDIT_VERIFICATION_SEUIL_PK" PRIMARY KEY ("OBJECTID") DISABLE
) 
AS
    WITH
        C_1 AS(
            SELECT 
                'seuils à vérifier' AS type_entite,
                COUNT(*) AS nb
            FROM
                G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION
            WHERE
                fid_etat_verification = 4
            GROUP BY
                'seuils à vérifier'
            UNION ALL
            SELECT 
                'seuils vérifiés' AS type_entite,
                COUNT(*) AS nb
            FROM
                G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION
            WHERE
                fid_etat_verification = 5
            GROUP BY
                'seuils vérifiés'
            UNION ALL
            SELECT 
                'seuils sujet à question' AS type_entite,
                COUNT(*) AS nb
            FROM
                G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION
            WHERE
                doute = 1
            GROUP BY
                'seuils sujet à question'
    )
    
    SELECT
        rownum AS objectid,
        type_entite,
        nb
    FROM
        C_1;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_H_AUDIT_VERIFICATION_SEUIL IS 'Vue du projet H de correction des relations tronçons/seuils permettant de suivre l''évolution de la vérification des relations seuils/tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_AUDIT_VERIFICATION_SEUIL.objectid IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_AUDIT_VERIFICATION_SEUIL.etat_avancement IS 'Etat d''avancement de la correction des seuils.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_AUDIT_VERIFICATION_SEUIL.nombre IS 'Nombre d''entités par état d''avancement.';

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_TEMP_H_AUDIT_VERIFICATION_SEUIL TO G_ADMIN_SIG;

/

