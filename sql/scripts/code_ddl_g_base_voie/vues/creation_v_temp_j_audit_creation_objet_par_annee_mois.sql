/*
Création de la vue V_TEMP_J_AUDIT_CREATION_OBJET_PAR_ANNEE_MOIS dénombrant tous les objets de la base voie et de la base adresse par année et mois de création.
*/
/*
DROP VIEW G_BASE_VOIE.V_TEMP_J_AUDIT_CREATION_OBJET_PAR_ANNEE_MOIS;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_TEMP_J_AUDIT_CREATION_OBJET_PAR_ANNEE_MOIS" ("OBJECTID", "TYPE_OBJET", "ANNEE", "MOIS", "NOMBRE", 
    CONSTRAINT "V_TEMP_J_AUDIT_CREATION_OBJET_PAR_ANNEE_MOIS_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
WITH
    C_1 AS(
        SELECT
            'Seuils' AS type_objet,
            EXTRACT(year from date_saisie) AS annee,
            EXTRACT(month from date_saisie) AS mois,
            COUNT(objectid) AS nombre
        FROM
            G_BASE_VOIE.TEMP_J_INFOS_SEUIL
        GROUP BY
            'Seuils',
            EXTRACT(year from date_saisie),
            EXTRACT(month from date_saisie)
        UNION ALL
        SELECT
            'Tronçons' AS type_objet,
            EXTRACT(year from date_saisie) AS annee,
            EXTRACT(month from date_saisie) AS mois,
            COUNT(objectid) AS nombre
        FROM
            G_BASE_VOIE.TEMP_J_TRONCON
        GROUP BY
            'Tronçons',
            EXTRACT(year from date_saisie),
            EXTRACT(month from date_saisie)
        UNION ALL
        SELECT
            'Voies administratives' AS type_objet,
            EXTRACT(year from date_saisie) AS annee,
            EXTRACT(month from date_saisie) AS mois,
            COUNT(objectid) AS nombre
        FROM
            G_BASE_VOIE.TEMP_J_VOIE_ADMINISTRATIVE
        GROUP BY
            'Voies administratives',
            EXTRACT(year from date_saisie),
            EXTRACT(month from date_saisie)
    )

    SELECT
        rownum AS objectid,
        type_objet,
        annee,
        mois,
        nombre 
    FROM
        C_1;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_J_AUDIT_CREATION_OBJET_PAR_ANNEE_MOIS IS 'Vue dénombrant tous les objets de la base voie et de la base adresse par année et mois de création. Cette vue fonctionne directement sur les tables de production, à terme il faudra les adapter aux tables de log.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_J_AUDIT_CREATION_OBJET_PAR_ANNEE_MOIS.objectid IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_J_AUDIT_CREATION_OBJET_PAR_ANNEE_MOIS.type_objet IS 'Type d''objets de la base voie et de la base adresse.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_J_AUDIT_CREATION_OBJET_PAR_ANNEE_MOIS.annee IS 'Année de création.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_J_AUDIT_CREATION_OBJET_PAR_ANNEE_MOIS.mois IS 'Mois de création.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_J_AUDIT_CREATION_OBJET_PAR_ANNEE_MOIS.nombre IS 'Nombre d''objets par année et mois de création.';

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_TEMP_J_AUDIT_CREATION_OBJET_PAR_ANNEE_MOIS TO G_ADMIN_SIG;

/

