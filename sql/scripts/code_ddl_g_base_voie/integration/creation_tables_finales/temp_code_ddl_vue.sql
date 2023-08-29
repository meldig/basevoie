/*
Création de la vue V_STAT_NOMBRE_OBJET dénombrant tous les objets de la base voie et de la base adresse.
*/
/*
DROP VIEW G_BASE_VOIE.V_STAT_NOMBRE_OBJET;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_STAT_NOMBRE_OBJET" ("OBJECTID", "TYPE_OBJET", "NOMBRE", 
    CONSTRAINT "V_STAT_NOMBRE_OBJET_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
    WITH
        C_1 AS(-- Sélection des voies physiques composées d'un seul tronçon
            SELECT
                a.fid_voie_physique
            FROM
                G_BASE_VOIE.TA_TRONCON a
            GROUP BY
                a.fid_voie_physique
            HAVING
                COUNT(a.objectid) = 1
        ),

        C_2 AS(-- Sélection des voies physiques composées de plusieurs tronçons
            SELECT
                a.fid_voie_physique
            FROM
                G_BASE_VOIE.TA_TRONCON a
            GROUP BY
                a.fid_voie_physique
            HAVING
                COUNT(a.objectid) > 1
        ),

        C_3 AS(-- Sélection des voies administratives composées d'une seule voie physique
            SELECT
                a.fid_voie_administrative
            FROM
                G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
            GROUP BY
                a.fid_voie_administrative
            HAVING
                COUNT(a.fid_voie_physique) = 1
        ),

        C_4 AS(-- Sélection des voies administratives composées de plusieurs voies physiques
            SELECT
                a.fid_voie_administrative
            FROM
                G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
            GROUP BY
                a.fid_voie_administrative
            HAVING
                COUNT(a.fid_voie_physique) > 1
        ),

        C_5 AS(
            SELECT
                'Seuils' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_INFOS_SEUIL
            GROUP BY
                'Seuils'
            UNION ALL
            SELECT
                'Géométries de seuil' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_SEUIL
            GROUP BY
                'Géométries de seuil'
            UNION ALL
            SELECT
                'Tronçons' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_TRONCON
            GROUP BY
                'Tronçons'
            UNION ALL
            SELECT
                'Voies physiques' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_VOIE_PHYSIQUE
            GROUP BY
                'Voies physiques'
            UNION ALL
            SELECT
                'Voies administratives' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE
            GROUP BY
                'Voies administratives'
            UNION ALL
            SELECT
                'Type de voie' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_TYPE_VOIE
            GROUP BY
                'Type de voie'
            UNION ALL
            SELECT
                'Relation seuil/tronçon' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_SEUIL
            WHERE
                fid_troncon IS NOT NULL
            GROUP BY
                'Relation seuil/tronçon'
            UNION ALL
            SELECT
                'Relation Tronçon/voie physique' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_TRONCON
            WHERE
                fid_voie_physique IS NOT NULL
            GROUP BY
                'Relation Tronçon/voie physique'
            UNION ALL
            SELECT
                'Relation voie physique/voie administrative' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
            WHERE
                fid_voie_physique IS NOT NULL
                AND fid_voie_administrative IS NOT NULL
            GROUP BY
                'Relation voie physique/voie administrative'
            UNION ALL
            SELECT
                'Voies physiques composées d''un seul tronçon' AS type_objet,
                COUNT(fid_voie_physique) AS nb
            FROM
                C_1
            GROUP BY
                'Voies physiques composées d''un seul tronçon'
            UNION ALL
            SELECT
                'Voies physiques composées de plusieurs tronçons' AS type_objet,
                COUNT(fid_voie_physique) AS nb
            FROM
                C_2
            GROUP BY
                'Voies physiques composées de plusieurs tronçons'
            UNION ALL
            SELECT
                'Voies administratives composées d''une seule voie physique' AS type_objet,
                COUNT(fid_voie_administrative) AS nb
            FROM
                C_3
            GROUP BY
                'Voies administratives composées d''une seule voie physique'
            UNION ALL
            SELECT
                'Voies administratives composées de plusieurs voies physiques' AS type_objet,
                COUNT(fid_voie_administrative) AS nb
            FROM
                C_4
            GROUP BY
                'Voies administratives composées de plusieurs voies physiques'
        )
        
        SELECT
            rownum AS objectid,
            type_objet,
            nb AS nombre
        FROM
            C_5;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_STAT_NOMBRE_OBJET IS 'Vue dénombrant tous les objets de la base voie et de la base adresse.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_OBJET.objectid IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_OBJET.type_objet IS 'Type d''objets de la base voie et de la base adresse.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_OBJET.nombre IS 'Nombre d''objets par type.';

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_STAT_NOMBRE_OBJET TO G_ADMIN_SIG;

/

/*
La vue V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE fait l''audit des relations entre les tronçons, les voies physiques et les voies administratives.
*/
/*
DROP VIEW V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE" ("OBJECTID", "CODE_INSEE", "NOM_COMMUNE", "NOMBRE", 
    CONSTRAINT "V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
	WITH
		C_1 AS(
			SELECT
				b.code_insee,
				b.nom AS nom_commune,
				COUNT(a.objectid) AS nombre
			FROM
				G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE a 
				INNER JOIN G_REFERENTIEL.MEL_COMMUNE_LLH b ON TRIM(b.code_insee) = TRIM(a.code_insee)
			GROUP BY
			    b.code_insee,
			    b.nom
		)

		SELECT
			rownum AS objectid,
			code_insee,
			nom_commune,
			nombre
		FROM
			C_1;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE IS 'Vue dénombrant les voies administratives par commune.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE.objectid IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE.code_insee IS 'Code INSEE de la commune (avec Lomme et Hellemmes-Lille).';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE.nom_commune IS 'Nom de la commune (avec Lomme et Hellemmes-Lille).';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE.nombre IS 'Nombre de voies administratives par commune.';

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE TO G_ADMIN_SIG;

/

/*
Création de la vue V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE permettant de connaître le nombre de voies administratives composées de plusieurs voies physiques et ce, dans le détail.
*/
/*
DROP VIEW G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE" (
    OBJECTID, 
    NBR_VOIE_ADMINISTRATIVE, 
    NBR_VOIE_PHYSIQUE, 
    CONSTRAINT "V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
WITH
    C_1 AS(
        SELECT
            fid_voie_administrative,
            COUNT(fid_voie_physique) AS nb_voie_physique
        FROM
            G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
        GROUP BY
            fid_voie_administrative
    ),
    
    C_2 AS(
        SELECT
            COUNT(fid_voie_administrative) AS nb_voie_administrative,
            nb_voie_physique
        FROM
            C_1
        GROUP BY
            nb_voie_physique
    )
    
    SELECT
        rownum AS objectid,
        nb_voie_administrative,
        nb_voie_physique
    FROM
        C_2;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE IS 'Vue permettant de connaître le nombre de voies administratives réparties par le nombre de voies physiques les composant.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE.objectid IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE.nbr_voie_administrative IS 'Nombre de voies administratives réparties par le nombre de voies physiques les composant.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE.nbr_voie_physique IS 'Nombre de voies physiques.';

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE TO G_ADMIN_SIG;

/

/*
Création de la vue V_STAT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE permettant de connaître le nombre de voies physiques par voie administrative.
*/
/*
DROP VIEW G_BASE_VOIE.V_STAT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_STAT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE" ("ID_VOIE_ADMINISTRATIVE", "NBR_VOIE_PHYSIQUE", 
    CONSTRAINT "V_STAT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE_PK" PRIMARY KEY ("ID_VOIE_ADMINISTRATIVE") DISABLE) AS 
        SELECT
            fid_voie_administrative,
            COUNT(fid_voie_physique) AS nb_voie_physique
        FROM
            G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
        GROUP BY
            fid_voie_administrative;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_STAT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE IS 'Vue permettant de connaître le nombre de voies physiques par voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE.id_voie_administrative IS 'Clé primaire de la vue composée des dentifiants des voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE.nbr_voie_physique IS 'Nombre de voies physiques par voie administrative.';

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_STAT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

/*
Création de la vue V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE dénombrant tous les objets de la base voie et de la base adresse.
*/
/*
DROP VIEW G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE" (
    OBJECTID, 
    NOMBRE, 
    GEOM, 
    CONSTRAINT "V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
    WITH
        C_1 AS(
            SELECT
                a.fid_seuil,
                COUNT(a.objectid) AS nombre
            FROM
                G_BASE_VOIE.TA_INFOS_SEUIL a
            GROUP BY 
                a.fid_seuil
            HAVING
                COUNT(a.objectid) > 1
        )
        
        SELECT
            a.objectid,
            b.nombre,
            a.geom
        FROM
            G_BASE_VOIE.TA_SEUIL a
            INNER JOIN C_1 b ON b.fid_seuil = a.objectid;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE IS 'Vue dénombrant les seuils partageant la même géométrie (seules les géométries associées à plusieurs seuils sont sélectionnées dans cette vue).';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE.objectid IS 'Clé primaire de la vue correspondant aux identifiants des géométries des seuils présents dans G_BASE_VOIE.TA_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE.nombre IS 'Nombre de seuils (de la table G_BASE_VOIE_INFOS_SEUIL) par géométrie. Seuls les géométries associées à plusieurs seuils sont présentes dans cette table.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE.geom IS 'Géométrie de type point.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE TO G_ADMIN_SIG;

/

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

/*
Affectation des droits de lecture et de mise à jour aux vues
*/

GRANT SELECT ON G_BASE_VOIE.V_STAT_NOMBRE_OBJET TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.V_STAT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.V_STAT_CREATION_OBJET_PAR_ANNEE_MOIS TO G_BASE_VOIE_LEC;

/

