/*
Fichier de requêtes permettant d'analyser les données de la base voie.
Attention, par défaut toutes les requêtes ci-dessous tapent sur le schéma G_SIDU.
Vous pouvez faire fonctionner ces requêtes sur SIDU, à condition de changer le schéma dans le FROM (sauf pour requêtes spatiales).
*/


-- 1. Validité / invalidité des données
-- validité des tronçons dans ILTADTN pour lesquels la date de fin de validité est antérieure à la date du jour dans ILTATRC 
SELECT
    COUNT(DISTINCT a.cnumtrc) AS Nombre,
    CASE
        WHEN a.cdvaldtn = 'V'
            THEN 'valide'
        WHEN a.cdvaldtn = 'F'
            THEN 'invalide'
    END AS Validite_ILTADTN,
    CASE
        WHEN b.cdvaltro = 'V'
            THEN 'valide'
        WHEN b.cdvaltro = 'F'
            THEN 'invalide'
    END AS Validite_ILTATRC
FROM
    G_SIDU.ILTADTN a
    INNER JOIN G_SIDU.ILTATRC b ON b.cnumtrc = a.cnumtrc
WHERE
    TO_DATE(b.cdtftrc, 'dd/mm/yy') < TO_DATE(sysdate, 'dd/mm/yy')
GROUP BY
    a.cdvaldtn,
    b.cdvaltro;
    
-- validité des tronçons dans ILTADTN pour lesquels la date de fin de validité est antérieure à la date de saisie dans ILTATRC 
SELECT
    COUNT(DISTINCT a.cnumtrc) AS Nombre,
    CASE
        WHEN a.cdvaldtn = 'V'
            THEN 'valide'
        WHEN a.cdvaldtn = 'F'
            THEN 'invalide'
    END AS Validite_ILTADTN,
    CASE
        WHEN b.cdvaltro = 'V'
            THEN 'valide'
        WHEN b.cdvaltro = 'F'
            THEN 'invalide'
    END AS Validite_ILTATRC
FROM
    G_SIDU.ILTADTN a
    INNER JOIN G_SIDU.ILTATRC b ON b.cnumtrc = a.cnumtrc
WHERE
    TO_DATE(b.cdtftrc, 'dd/mm/yy') < TO_DATE(b.cdtstrc, 'dd/mm/yy')
GROUP BY
    a.cdvaldtn,
    b.cdvaltro;
    
-- validité des tronçons dans ILTADTN pour lesquels la date de fin de validité est antérieure à la date de début de validité dans ILTATRC 
SELECT
    COUNT(DISTINCT a.cnumtrc) AS Nombre,
    CASE
        WHEN a.cdvaldtn = 'V'
            THEN 'valide'
        WHEN a.cdvaldtn = 'F'
            THEN 'invalide'
    END AS Validite_ILTADTN,
    CASE
        WHEN b.cdvaltro = 'V'
            THEN 'valide'
        WHEN b.cdvaltro = 'F'
            THEN 'invalide'
    END AS Validite_ILTATRC
FROM
    G_SIDU.ILTADTN a
    INNER JOIN G_SIDU.ILTATRC b ON b.cnumtrc = a.cnumtrc
WHERE
    TO_DATE(b.cdtftrc, 'dd/mm/yy') < TO_DATE(b.cdtdtrc, 'dd/mm/yy')
GROUP BY
    a.cdvaldtn,
    b.cdvaltro;

-- Décompte du nombre de tronçons valides dans ILTATRC
 SELECT
    COUNT(cnumtrc)
FROM
    G_SIDU.ILTATRC
WHERE
    cdvaltro = 'V';

-- Décompte du nombre de tronçons valides dans ILTADTN 
SELECT
    COUNT(DISTINCT cnumtrc)
FROM
    G_SIDU.ILTADTN
WHERE
    cdvaldtn = 'V';

-- Décompte du nombre de tronçons invalides dans ILTATRC
 SELECT
    COUNT(cnumtrc)
FROM
    G_SIDU.ILTATRC
WHERE
    cdvaltro = 'F';

-- Décompte du nombre de tronçons invalides dans ILTADTN
SELECT
    COUNT(DISTINCT cnumtrc)
FROM
    G_SIDU.ILTADTN
WHERE
    cdvaldtn = 'F';

-- 2. Vérification des noeuds par tronçon
-- Nombre de tronçons valides sans noeud de début    
SELECT
    COUNT(a.cnumtrc)
FROM
    G_SIDU.ILTADTN a
WHERE
    a.ccoddft = 'D'
    AND a.cdvaldtn = 'V'
HAVING
    COUNT(a.ccoddft) < 1;
    
-- Nombre de tronçons valides sans noeud de fin    
SELECT
    COUNT(a.cnumtrc)
FROM
    G_SIDU.ILTADTN a
WHERE
    a.ccoddft = 'F'
    AND a.cdvaldtn = 'V'
HAVING
    COUNT(a.ccoddft) < 1;

 -- Sélection des tronçons valides avec plus d'un startpoint
SELECT
    a.cnumtrc,
    a.ccoddft AS "STARTPOINT",
    COUNT(a.cnumtrc) AS nombre
FROM
    G_SIDU.ILTADTN a
WHERE
    a.ccoddft = 'D'
    AND a.cdvaldtn = 'V'
GROUP BY
    a.cnumtrc,
    a.ccoddft
HAVING
    COUNT(a.cnumtrc) > 1;

-- Sélection des tronçons valides avec plus d'un endpoint
SELECT
    a.cnumtrc,
    a.ccoddft AS "ENDPOINT",
    COUNT(a.cnumtrc) AS nombre
FROM
    G_SIDU.ILTADTN a
WHERE
    a.ccoddft = 'F'
    AND a.cdvaldtn = 'V'
GROUP BY
    a.cnumtrc,
    a.ccoddft
HAVING
    COUNT(a.cnumtrc) > 1;

-- Sélection des tronçons n'ayant qu'une seul noeud, mais étant pourtant tagués en valide
WITH
    C_1 AS(
        SELECT
            cnumtrc
        FROM
            G_SIDU.ILTADTN
        WHERE
            cdvaldtn = 'V'
        GROUP BY
            cnumtrc
        HAVING
            COUNT(cnumptz) <2
    )
SELECT
    COUNT(DISTINCT a.cnumtrc)
FROM
    C_1 a
    INNER JOIN G_SIDU.ILTADTN b ON b.cnumtrc = a.cnumtrc
WHERE
    b.cdvaldtn = 'V'
    AND b.CCODDFT = 'D'
;

-- 3. Vérification des connexions entre tronçons
-- Nombre de mauvaises connexions entre tronçons
SELECT
    COUNT(a.cnumtrc)/2 -- cette division est nécessaire puisque la fonction SDO_LRS.CONNECTED_GEOM_SEGMENTS vérifie si le tronçon A est connecté au tronçon B et vice versa. Il y a donc deux vérififcations pour chaque connexion.
FROM
    G_SIDU.ILTATRC a,
    G_SIDU.ILTATRC b
WHERE
    a.cnumtrc <> b.cnumtrc
    AND a.cdvaltro = 'V'
    AND b.cdvaltro = 'V'
    AND SDO_WITHIN_DISTANCE(
        b.geom, 
        a.geom, 
        'distance = 0.005'
    ) = 'TRUE'
    AND SDO_LRS.CONNECTED_GEOM_SEGMENTS(
            SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom), 
            SDO_LRS.CONVERT_TO_LRS_GEOM(b.geom),
            0.005
        ) = 'FALSE';