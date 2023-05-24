/*
Création de la vue V_TEMP_C_VERIFICATION_DES_RELATIONS - du projet C de correction de la latéralité des voies -  permettant de vérifier les relations tronçons / voies physiques / voies administratives
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_TEMP_C_VERIFICATION_DES_RELATIONS(
    OBJECTID,
    TYPE_DE_VERIFICATION,
    NBR_ERREUR,
    CONSTRAINT "V_TEMP_C_VERIFICATION_DES_RELATIONS_PK" PRIMARY KEY ("OBJECTID") DISABLE
)
AS
    WITH
        C_1 AS(
            -- Décompte des relations tronçons / voies physiques n'ayant pas de clé parente dans TEMP_C_VOIE_PHYSIQUE
            SELECT
                'Relations tronçons / voies physiques n''ayant pas de clé parente dans TEMP_C_VOIE_PHYSIQUE' AS type_de_verification,
                COUNT(a.objectid) AS nbr_erreur
            FROM
                G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE a
            WHERE
                a.fid_voie_physique NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE)
            GROUP BY
                'Relations tronçons / voies physiques n''ayant pas de clé parente dans TEMP_C_VOIE_PHYSIQUE'
            UNION ALL
            -- Décompte des voies physiques n'appartenant à aucune relation tronçon / voie physique
            SELECT
                'Voies physiques n''ayant pas de clé enfant dans la table TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE' AS type_de_verification,
                COUNT(a.objectid) AS nbr_erreur
            FROM
                G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE a
            WHERE
                a.objectid NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE)
            GROUP BY
                'Voies physiques n''ayant pas de clé enfant dans la table TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE'
            UNION ALL
            -- Décompte des relations voies physiques/ voie administrative dont les voies physiques n'appartiennent à aucune relation tronçon / voie physique
            SELECT
                'Relations voies physiques / voies administratives dont les voies physiques n''ont pas de clé enfant dans la table TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE' AS type_de_verification,
                COUNT(a.objectid) AS nbr_erreur
            FROM
                G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
            WHERE
                a.fid_voie_physique NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE)
            GROUP BY
                'Relations voies physiques / voies administratives dont les voies physiques n''ont pas de clé enfant dans la table TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE'
        )
        
        SELECT
            rownum AS objectid,
            a.type_de_verification,
            a.nbr_erreur
        FROM
            C_1 a;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_C_VERIFICATION_DES_RELATIONS IS 'Vue permettant de répertorier les erreurs de relations tronçons / voies physiques / voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_VERIFICATION_DES_RELATIONS.OBJECTID IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_VERIFICATION_DES_RELATIONS.TYPE_DE_VERIFICATION IS 'Type d''erreur.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_VERIFICATION_DES_RELATIONS.NBR_ERREUR IS 'Nombre d''erreurs.';

/

