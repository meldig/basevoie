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

