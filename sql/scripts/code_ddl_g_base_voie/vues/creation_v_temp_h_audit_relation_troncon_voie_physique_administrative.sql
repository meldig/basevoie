/*
La vue V_TEMP_H_AUDIT_RELATION_TRONCON_VOIE_PHYSIQUE_ADMINISTRATIVE fait l''audit des relations entre les tronçons, les voies physiques et les voies administratives.
*/
/*
DROP VIEW V_TEMP_H_AUDIT_RELATION_TRONCON_VOIE_PHYSIQUE_ADMINISTRATIVE;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_TEMP_H_AUDIT_RELATION_TRONCON_VOIE_PHYSIQUE_ADMINISTRATIVE" ("OBJECTID", "THEMATIQUE", "NOMBRE", 
    CONSTRAINT "V_TEMP_H_AUDIT_RELATION_TRONCON_VOIE_PHYSIQUE_ADMINISTRATIVE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
WITH 
    C_0 AS (-- Sélection du nombre total de tronçons
        SELECT
            'Nombre total de tronçons' AS thematique,
            COUNT(*) AS nombre
        FROM
            G_BASE_VOIE.TEMP_H_TRONCON
        GROUP BY
            'Nombre total de tronçons'
    ),
    
    C_00 AS (-- Sélection du nombre total de voies physiques
        SELECT
            'Nombre total de voies physiques' AS thematique,
            COUNT(*) AS nombre
        FROM
            G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE
        GROUP BY
            'Nombre total de voies physiques'
    ),
    
    C_000 AS (-- Sélection du nombre total de voies administratives
        SELECT
            'Nombre total de voies administratives' AS thematique,
            COUNT(*) AS nombre
        FROM
            G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE
        GROUP BY
            'Nombre total de voies administratives'
    ),
    
    C_1 AS(-- Sélection des voies physiques composées d'un seul tronçon
        SELECT
            a.fid_voie_physique,
            COUNT(a.objectid) AS nbr_trc
        FROM
            G_BASE_VOIE.TEMP_H_TRONCON a
        GROUP BY
            a.fid_voie_physique
        HAVING
            COUNT(a.objectid) = 1
    ),
    
    C_01 AS(-- Sélection du nombre voies physiques composées d'un seul tronçon
        SELECT
            'Nombre de voies physiques composées d''un seul tronçon' AS thematique,
            COUNT(fid_voie_physique) AS nombre
        FROM
            C_1
        GROUP BY
            'Nombre de voies physiques composées d''un seul tronçon'
    ),

    C_001 AS(-- Sélection du nombre de voies physiques composées de plusieurs tronçons
        SELECT
            'Nombre de voies physiques composées de plusieurs tronçons' AS thematique,
            COUNT(fid_voie_physique) AS nombre
        FROM
            (
                SELECT fid_voie_physique 
                FROM G_BASE_VOIE.TEMP_H_TRONCON 
                GROUP BY fid_voie_physique 
                HAVING COUNT(objectid) > 1
            )
        GROUP BY
            'Nombre de voies physiques composées de plusieurs tronçons'
    ),
    
    C_2 AS(-- Sélection des voies administratives composées de plusieurs voies physiques
        SELECT
            a.fid_voie_administrative
        FROM
            G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
        GROUP BY
            a.fid_voie_administrative
        HAVING
            COUNT(a.fid_voie_physique) > 1
    ),

    C_02 AS(-- Sélection du nombre de voies administratives composées de plusieurs voies physiques
        SELECT
            'Nombre de voies administratives composées de plusieurs voies physiques' AS thematique,
            COUNT(fid_voie_administrative) AS nombre
        FROM
            C_2
        GROUP BY
            'Nombre de voies administratives composées de plusieurs voies physiques'
    ),
    
    C_3 AS(-- Sélection des voies administratives composées d'une seule voie physique
        SELECT
            a.fid_voie_administrative
        FROM
            G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
        GROUP BY
            a.fid_voie_administrative
        HAVING
            COUNT(a.fid_voie_physique) = 1
    ),
    
    C_03 AS(-- Sélection du nombre de voies administratives composées d''une seule voie physique
        SELECT
            'Nombre de voies administratives composées d''une seule voie physique' AS thematique,
            COUNT(fid_voie_administrative) AS nombre
        FROM
            C_3
        GROUP BY
            'Nombre de voies administratives composées d''une seule voie physique'
    ),
    
    C_04 AS(-- Nombre de voies administratives composées d''une seule voie physique composée d''un seul tronçon
        SELECT
            'Nombre de voies administratives composées d''une seule voie physique composée d''un seul tronçon' AS thematique,
            COUNT(a.fid_voie_administrative) AS nombre
        FROM
            C_3 a
            INNER JOIN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE b ON b.fid_voie_administrative = a.fid_voie_administrative
            INNER JOIN C_1 c ON c.fid_voie_physique = b.fid_voie_physique
        GROUP BY
            'Nombre de voies administratives composées d''une seule voie physique composée d''un seul tronçon'
    ),
    
    C_004 AS(-- Nombre de voies administratives composées de plusieurs voie physique dont une au moins est composée d''un seul tronçon
        SELECT
            'Nombre de voies administratives composées de plusieurs voies physiques dont une au moins est composée d''un seul tronçon' AS thematique,
            COUNT(a.fid_voie_administrative) AS nombre
        FROM
            C_2 a
            INNER JOIN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE b ON b.fid_voie_administrative = a.fid_voie_administrative
            INNER JOIN C_1 c ON c.fid_voie_physique = b.fid_voie_physique
        GROUP BY
            'Nombre de voies administratives composées de plusieurs voies physiques dont une au moins est composée d''un seul tronçon'
    ),
    
    C_5 AS(-- Compilation des résultats  
        SELECT
            thematique,
            nombre
        FROM
            C_0
        UNION ALL
        SELECT
            thematique,
            nombre
        FROM
            C_00    
         UNION ALL
        SELECT
            thematique,
            nombre
        FROM
            C_000
        UNION ALL
        SELECT
            thematique,
            nombre
        FROM
            C_01
        UNION ALL
        SELECT
            thematique,
            nombre
        FROM
            C_001
        UNION ALL
        SELECT
            thematique,
            nombre
        FROM
            C_02
        UNION ALL
        SELECT
            thematique,
            nombre
        FROM
            C_03
        UNION ALL
        SELECT
            thematique,
            nombre
        FROM
            C_04
        UNION ALL
        SELECT
            thematique,
            nombre
        FROM
            C_004
    )
    
    SELECT
        rownum AS objectid,
        thematique,
        nombre
    FROM
        C_5;

-- 2. Création des commentaires
COMMENT ON COLUMN "G_BASE_VOIE"."V_TEMP_H_AUDIT_RELATION_TRONCON_VOIE_PHYSIQUE_ADMINISTRATIVE"."OBJECTID" IS 'Clé primaire de la vue.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_TEMP_H_AUDIT_RELATION_TRONCON_VOIE_PHYSIQUE_ADMINISTRATIVE"."NOMBRE" IS 'Nombre d''entités concernées.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_TEMP_H_AUDIT_RELATION_TRONCON_VOIE_PHYSIQUE_ADMINISTRATIVE"."THEMATIQUE" IS 'Thème de l''analyse.';
COMMENT ON TABLE "G_BASE_VOIE"."V_TEMP_H_AUDIT_RELATION_TRONCON_VOIE_PHYSIQUE_ADMINISTRATIVE" IS 'Vue faisant l''audit des relations entre les tronçons, les voies physiques et les voies administratives.';
         
-- 3. Création des droits
GRANT SELECT ON G_BASE_VOIE.V_TEMP_H_AUDIT_RELATION_TRONCON_VOIE_PHYSIQUE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

