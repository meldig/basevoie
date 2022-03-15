/*
Vérification des tronçons du projet LITTERALIS.
OBJECTIF :
- Vérifier que tous les tronçons sont dans les tables LITTERALIS ;
- Vérifier qu'aucun doublon n'existe au sein des tables LITTERALIS ;
- Vérifier que tous les tronçons disposent d'un code INSEE valide ;
- Vérifier que tous les tronçons disposent d'une domanialité ;
*/
-- Sélection des tronçons provenant de la table TA_TRONCON et des tables temporaires de LITTERALIS
WITH
    C_1 AS(
        SELECT 
            'TEMP_TRONCON_CORRECT_LITTERALIS' AS nom_table,
            COUNT(*) AS nombre
        FROM
            G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS
        GROUP BY
            'TEMP_TRONCON_CORRECT_LITTERALIS'
        UNION ALL
        SELECT 
            'TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS' AS nom_table,
            COUNT(*) AS nombre
        FROM
            G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS
        GROUP BY
            'TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS'
        UNION ALL
        SELECT
            'TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS' AS nom_table,
            COUNT(*) AS nombre
        FROM
            G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS
        GROUP BY
            'TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS'
    )
    SELECT 
        'TA_TRONCON' AS nom_table,
        COUNT(*) AS nombre
    FROM
        G_BASE_VOIE.TA_TRONCON
    GROUP BY
        'TA_TRONCON'
    UNION ALL
    SELECT 
        'TEMP_TRONCON_CORRECT_LITTERALIS' AS nom_table,
        COUNT(*) AS nombre
    FROM
        G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS
    GROUP BY
        'TEMP_TRONCON_CORRECT_LITTERALIS'
    UNION ALL
    SELECT 
        'TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS' AS nom_table,
        COUNT(*) AS nombre
    FROM
        G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS
    GROUP BY
        'TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS'
    UNION ALL
    SELECT
        'TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS' AS nom_table,
        COUNT(*) AS nombre
    FROM
        G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS
    GROUP BY
        'TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS'
    UNION ALL
    SELECT
        'TOTAL' AS nomtable,
        SUM(nombre)
    FROM
        C_1
    GROUP BY
        'TOTAL';

-- Sélection des tronçons présents dans plusieurs tables temporaires LITTERALIS
SELECT
    'tronçon présent dans TEMP_TRONCON_CORRECT_LITTERALIS et TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS'
    id_troncon
FROM
    G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS
WHERE
    id_troncon IN(SELECT id_troncon FROM G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS)
UNION ALL
SELECT
    'tronçon présent dans TEMP_TRONCON_CORRECT_LITTERALIS et TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS'
    id_troncon
FROM
    G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS
WHERE
    id_troncon IN(SELECT id_troncon FROM G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS)
UNION ALL
SELECT
    'tronçon présent dans TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS et TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS'
    id_troncon
FROM
    G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS
WHERE
    id_troncon IN(SELECT id_troncon FROM G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS);
-- Résultat : 0

-- Création d'une vue regroupant les identifiants des tronçons de toutes les tables temporaires de LITTERALIS
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_LITTERALIS_TRONCON_TABLE_TEMP" ("ID_TRONCON", 
    CONSTRAINT "V_LITTERALIS_TRONCON_TABLE_TEMP_PK" PRIMARY KEY ("ID_TRONCON") DISABLE) AS 
    SELECT 
        id_troncon
    FROM
        G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS
    UNION ALL
    SELECT 
        id_troncon
    FROM
        G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS
    UNION ALL
    SELECT
        id_troncon
    FROM
        G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS;

-- Sélection du nombre de tronçons absents des tables temporaires de LITTERALIS
SELECT
    COUNT(DISTINCT objectid)
FROM
    G_BASE_VOIE.TA_TRONCON
WHERE
    objectid NOT IN(
        SELECT
            id_troncon
        FROM
            G_BASE_VOIE.V_LITTERALIS_TRONCON_TABLE_TEMP
    );
-- Résultat : 1431
    
-- Vérification que les tronçons manquants disposent tous d'un code INSEE valide
SELECT
    objectid
FROM
    G_BASE_VOIE.TA_TRONCON
WHERE
    GET_CODE_INSEE_TRONCON('TA_TRONCON', geom)  = 'error'
    AND objectid NOT IN(
        SELECT
            id_troncon
        FROM
            G_BASE_VOIE.V_LITTERALIS_TRONCON_TABLE_TEMP
    );
-- Résultat : 0
  
-- Vérification que les tronçons manquants disposent d'une et une seule domanialité
SELECT
    a.objectid
FROM
    G_BASE_VOIE.TA_TRONCON a
    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
    INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE c ON c.id_voie = b.fid_voie
    INNER JOIN SIREO_LEC.OUT_DOMANIALITE d ON d.cnumtrc = a.objectid
WHERE
    a.objectid NOT IN(
                                SELECT
                                    id_troncon
                                FROM
                                    G_BASE_VOIE.V_LITTERALIS_TRONCON_TABLE_TEMP
                            )
GROUP BY
    a.objectid
HAVING
    COUNT(a.objectid) > 1
    AND COUNT(DISTINCT b.fid_voie) = 1
    AND COUNT(DISTINCT d.domania) > 1;
-- Résultat : 0

-- Vérification que les tronçons manquants sont affectés à une et une seule voie
SELECT
    a.objectid
FROM
    G_BASE_VOIE.TA_TRONCON a
    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
    INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE c ON c.id_voie = b.fid_voie
    INNER JOIN SIREO_LEC.OUT_DOMANIALITE d ON d.cnumtrc = a.objectid
WHERE
    a.objectid NOT IN(
                                SELECT
                                    id_troncon
                                FROM
                                    G_BASE_VOIE.V_LITTERALIS_TRONCON_TABLE_TEMP
                            )
GROUP BY
    a.objectid
HAVING
    COUNT(a.objectid) > 1
    AND COUNT(DISTINCT d.objectid) = 1
    AND COUNT(GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', c.geom)) > 1
    AND COUNT(DISTINCT c.id_voie) > 1;
-- Résultat : 0

-- Sélection du nombre de tronçons affectés à une voie dans les tables de production
SELECT
    COUNT(DISTINCT fid_troncon)
FROM
    G_BASE_VOIE.TA_RELATION_TRONCON_VOIE;
-- Résultat : 49663

-- Sélection du nombre de tronçon non affectés à une voie dans les tables de production
SELECT
    objectid
FROM
    G_BASE_VOIE.TA_TRONCON
WHERE
    objectid NOT IN(SELECT fid_troncon FROM G_BASE_VOIE.TA_RELATION_TRONCON_VOIE);
-- Résultat : 1 tronçon

-- Sélection du nombre de tronçons ne disposant pas de domanialité
SELECT
    COUNT(a.objectid)
FROM
    G_BASE_VOIE.TA_TRONCON a
WHERE
    a.objectid NOT IN(SELECT cnumtrc FROM SIREO_LEC.OUT_DOMANIALITE);
-- Résultat : 1368 tronçons