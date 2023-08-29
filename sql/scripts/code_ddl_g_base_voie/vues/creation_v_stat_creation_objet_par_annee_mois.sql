/*
Création de la vue V_STAT_CREATION_OBJET_PAR_ANNEE_MOIS dénombrant tous les objets de la base voie et de la base adresse par année et mois de création.
*/
/*
DROP VIEW G_BASE_VOIE.V_STAT_CREATION_OBJET_PAR_ANNEE_MOIS;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_STAT_CREATION_OBJET_PAR_ANNEE_MOIS" (
    OBJECTID,
    TYPE_OBJET, 
    ANNEE, 
    MOIS, 
    NOMBRE, 
    CONSTRAINT "V_STAT_CREATION_OBJET_PAR_ANNEE_MOIS_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
WITH
    C_1 AS(
        SELECT
            'Seuils' AS type_objet,
            EXTRACT(year from a.date_action) AS annee,
            EXTRACT(month from a.date_action) AS mois,
            COUNT(a.objectid) AS nombre
        FROM
            G_BASE_VOIE.TA_INFOS_SEUIL_LOG a
            INNER JOIN G_BASE_VOIE.TA_LIBELLE b ON b.objectid = a.fid_type_action
        WHERE
            b.libelle_court = 'insertion'           
        GROUP BY
            'Seuils',
            EXTRACT(year from a.date_action),
            EXTRACT(month from a.date_action)
        UNION ALL
        SELECT
            'Tronçons' AS type_objet,
            EXTRACT(year from a.date_action) AS annee,
            EXTRACT(month from a.date_action) AS mois,
            COUNT(a.objectid) AS nombre
        FROM
            G_BASE_VOIE.TA_TRONCON_LOG a
            INNER JOIN G_BASE_VOIE.TA_LIBELLE b ON b.objectid = a.fid_type_action
        WHERE
            b.libelle_court = 'insertion'
        GROUP BY
            'Tronçons',
            EXTRACT(year from a.date_action),
            EXTRACT(month from a.date_action)
        UNION ALL
        SELECT
            'Voies physiques' AS type_objet,
            EXTRACT(year from a.date_action) AS annee,
            EXTRACT(month from a.date_action) AS mois,
            COUNT(a.objectid) AS nombre
        FROM
            G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG a
            INNER JOIN G_BASE_VOIE.TA_LIBELLE b ON b.objectid = a.fid_type_action
        WHERE
            b.libelle_court = 'insertion'
        GROUP BY
            'Voies physiques',
            EXTRACT(year from a.date_action),
            EXTRACT(month from a.date_action)
        UNION ALL
        SELECT
            'Voies administratives' AS type_objet,
            EXTRACT(year from a.date_action) AS annee,
            EXTRACT(month from a.date_action) AS mois,
            COUNT(a.objectid) AS nombre
        FROM
            G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG a
            INNER JOIN G_BASE_VOIE.TA_LIBELLE b ON b.objectid = a.fid_type_action
        WHERE
            b.libelle_court = 'insertion'
        GROUP BY
            'Voies administratives',
            EXTRACT(year from a.date_action),
            EXTRACT(month from a.date_action)
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
COMMENT ON TABLE G_BASE_VOIE.V_STAT_CREATION_OBJET_PAR_ANNEE_MOIS IS 'Vue dénombrant tous les objets de la base voie et de la base adresse par année et mois de création. Cette vue fonctionne à partir des tables de log.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_CREATION_OBJET_PAR_ANNEE_MOIS.objectid IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_CREATION_OBJET_PAR_ANNEE_MOIS.type_objet IS 'Type d''objets de la base voie et de la base adresse.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_CREATION_OBJET_PAR_ANNEE_MOIS.annee IS 'Année de création.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_CREATION_OBJET_PAR_ANNEE_MOIS.mois IS 'Mois de création.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_CREATION_OBJET_PAR_ANNEE_MOIS.nombre IS 'Nombre d''objets par année et mois de création.';

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_STAT_CREATION_OBJET_PAR_ANNEE_MOIS TO G_ADMIN_SIG;

/

