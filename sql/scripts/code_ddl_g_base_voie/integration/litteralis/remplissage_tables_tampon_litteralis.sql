-- Insertion des correspondances entre les domanialités de la MEL et les classements de LITTERALIS
INSERT INTO G_BASE_VOIE.TA_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT(domanialite, classement, priorite)
WITH
    C_1 AS(
        SELECT DISTINCT
            domania
        FROM
            SIREO_LEC.OUT_DOMANIALITE
    )

    SELECT
        a.domania,
        CASE 
            WHEN a.domania = 'AUTOROUTE OU VOIE A CARACTERE AUTOROUTIER'
                THEN 'A'
            WHEN a.domania = 'ROUTE NATIONALE'
                THEN 'RN' -- Route Nationale
            WHEN a.domania IN ('VOIE PRIVEE ENTRETENUE PAR LA CUDL','VOIE PRIVEE FERMEE','VOIE PRIVEE OUVERTE','AUTRE VOIE PRIVEE','DECLASSEMENT EN COURS')
                THEN 'VP' -- Voie Privée
            WHEN a.domania = 'CHEMIN RURAL'
                THEN 'CR' -- Chemin Rural
            WHEN a.domania IN ('VOIE METROPOLITAINE','GESTION COMMUNAUTAIRE','AUTRE VOIE PUBLIQUE')
                THEN 'VC' -- Voie Communale
            WHEN a.domania IS NULL
                THEN 'VC' -- Voie Communale
        END AS CLASSEMENT,
        CASE
            WHEN a.domania = 'AUTOROUTE OU VOIE A CARACTERE AUTOROUTIER'
                THEN 1
            WHEN a.domania = 'ROUTE NATIONALE'
                THEN 2
            WHEN a.domania = 'VOIE METROPOLITAINE'
                THEN 3
            WHEN a.domania = 'AUTRE VOIE PUBLIQUE'
                THEN 4
            WHEN a.domania = 'GESTION COMMUNAUTAIRE'
                THEN 5
            WHEN a.domania = 'DECLASSEMENT EN COURS'
                THEN 6
            WHEN a.domania = 'VOIE PRIVEE ENTRETENUE PAR LA CUDL'
                THEN 7
            WHEN a.domania = 'VOIE PRIVEE OUVERTE'
                THEN 8
            WHEN a.domania = 'VOIE PRIVEE FERMEE'
                THEN 9
            WHEN a.domania = 'AUTRE VOIE PRIVEE'
                THEN 10
            WHEN a.domania = 'CHEMIN RURAL'
                THEN 11
            WHEN a.domania IS NULL
                THEN 12
            WHEN a.domania = 'ROUTE DEPARTEMENTALE'
                THEN 13
        END AS PRIORITE
    FROM
        C_1 a;
-- Résultat : 11 entités insérées

-- Insertion des voies administratives principales/secondaires au format LITTERALIS dans TA_TAMPON_LITTERALIS_VOIE
INSERT INTO G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE(objectid, code_voie, nom_voie, code_insee, geometry)
WITH
    C_1 AS(-- Sélection et matérialisation des voies secondaires
        SELECT
            d.objectid,
            e.libelle,
            d.libelle_voie,
            d.complement_nom_voie,
            d.code_insee,
            SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS geom
        FROM
            G_BASE_VOIE.TEMP_H_TRONCON a
            INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
            INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE d ON d.objectid = c.fid_voie_administrative
            INNER JOIN G_BASE_VOIE.TEMP_H_TYPE_VOIE e ON e.objectid = d.fid_type_voie
            INNER JOIN G_BASE_VOIE.TEMP_H_HIERARCHISATION_VOIE f ON f.fid_voie_secondaire = d.objectid
        GROUP BY
            d.objectid,
            e.libelle,
            d.libelle_voie,
            d.complement_nom_voie,
            d.code_insee
    )

SELECT -- mise en ordre des voies secondaires en fonction de leur taille (ajout du suffixe ANNEXE 1, 2, 3 en fonction de la taille pour un même libelle_voie et code_insee)
    a.objectid,
    CAST(a.objectid AS VARCHAR2(254 BYTE)) AS code_voie,
    CAST(SUBSTR(UPPER(TRIM(a.libelle)), 1, 1) || SUBSTR(LOWER(TRIM(a.libelle)), 2) || CASE WHEN a.libelle_voie IS NOT NULL THEN ' ' || TRIM(a.libelle_voie) ELSE '' END || CASE WHEN a.complement_nom_voie IS NOT NULL THEN ' ' || TRIM(a.complement_nom_voie) ELSE '' END || CASE WHEN a.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN a.code_insee = '59355' THEN ' (Lomme)' END || ' Annexe ' || ROW_NUMBER() OVER (PARTITION BY (UPPER(TRIM(a.libelle_voie)) || ' ' || a.code_insee) ORDER BY SDO_GEOM.SDO_LENGTH(a.geom, 0.001) DESC) AS VARCHAR2(254)) AS nom_voie,
    a.code_insee,
    a.geom
FROM
    C_1 a
UNION ALL
SELECT -- Sélection et matérialisation des voies principales
    d.objectid,
    CAST(d.objectid AS VARCHAR2(254 BYTE)) AS code_voie,
    CAST(SUBSTR(UPPER(TRIM(e.libelle)), 1, 1) || SUBSTR(LOWER(TRIM(e.libelle)), 2) || CASE WHEN d.libelle_voie IS NOT NULL THEN ' ' || TRIM(d.libelle_voie) ELSE '' END || CASE WHEN d.complement_nom_voie IS NOT NULL THEN ' ' || TRIM(d.complement_nom_voie) ELSE '' END || CASE WHEN d.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN d.code_insee = '59355' THEN ' (Lomme)' END AS VARCHAR2(254)) AS nom_voie,
    d.code_insee,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS geom
FROM
    G_BASE_VOIE.TEMP_H_TRONCON a
    INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
    INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE d ON d.objectid = c.fid_voie_administrative
    INNER JOIN G_BASE_VOIE.TEMP_H_TYPE_VOIE e ON e.objectid = d.fid_type_voie
WHERE
    d.objectid NOT IN(SELECT fid_voie_secondaire FROM G_BASE_VOIE.TEMP_H_HIERARCHISATION_VOIE)
GROUP BY
    d.objectid,
    CAST(d.objectid AS VARCHAR2(254 BYTE)),
    CAST(SUBSTR(UPPER(TRIM(e.libelle)), 1, 1) || SUBSTR(LOWER(TRIM(e.libelle)), 2) || CASE WHEN d.libelle_voie IS NOT NULL THEN ' ' || TRIM(d.libelle_voie) ELSE '' END || CASE WHEN d.complement_nom_voie IS NOT NULL THEN ' ' || TRIM(d.complement_nom_voie) ELSE '' END || CASE WHEN d.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN d.code_insee = '59355' THEN ' (Lomme)' END AS VARCHAR2(254)),
    d.code_insee;
-- Résultat : 22 165 lignes insérées.

-- Insertion des tronçons au format LITTERALIS
INSERT INTO G_BASE_VOIE.TA_TAMPON_LITTERALIS_TRONCON(OBJECTID,CODE_TRONC,CLASSEMENT,GEOMETRY)
WITH
    C_1 AS(-- Sélection des tronçons composés de plusieurs sous-tronçons de domanialités différentes
        SELECT
            cnumtrc
        FROM
            SIREO_LEC.OUT_DOMANIALITE
        GROUP BY
            cnumtrc
        HAVING
            COUNT(DISTINCT domania) > 1
    ),
    
    C_2 AS(-- Mise en concordance des domanialités de la DEPV et des classements de LITTERALIS
        SELECT
            a.cnumtrc,
            c.classement
        FROM
            C_1 a
            INNER JOIN SIREO_LEC.OUT_DOMANIALITE b ON b.cnumtrc = a.cnumtrc
            INNER JOIN G_BASE_VOIE.TA_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT c ON c.domanialite = b.domania
    ),
    
    C_3 AS(-- Si un tronçon se compose de plusieurs sous-tronçons de domanialités différentes, alors on utilise le système de priorité de la DEPV (présent dans G_BASE_VOIE.TA_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT) pour déterminer une domanialité pour le tronçon
        SELECT
            a.cnumtrc,
            CASE
                WHEN a.classement IN('VC', 'VP')
                    THEN 'VC'
                WHEN a.classement IN('VC', 'CR')
                    THEN 'VC'
                WHEN a.classement IN('A', 'RN')
                    THEN 'A'
            END AS classement
        FROM
            C_2 a
        GROUP BY
            a.cnumtrc,
            CASE
                WHEN a.classement IN('VC', 'VP')
                    THEN 'VC'
                WHEN a.classement IN('VC', 'CR')
                    THEN 'VC'
                WHEN a.classement IN('A', 'RN')
                    THEN 'A'
            END
    ),
    
    C_4 AS(-- Sélection des tronçons n'ayant qu'une seule domanialité
        SELECT
            cnumtrc
        FROM
            SIREO_LEC.OUT_DOMANIALITE
        GROUP BY
            cnumtrc
        HAVING
            COUNT(DISTINCT domania) = 1  
    ),
    
    C_5 AS(-- Mise en forme des tronçons ayant une seule domanialité et compilation avec ceux disposant de deux domanialités dans les tables source 
        SELECT DISTINCT --Le DISTINCT est indispensable car certains tronçons peuvent être composés de plusieurs sous-tronçons de même domanialité
            a.cnumtrc AS objectid,
            CAST(a.cnumtrc AS VARCHAR2(254 BYTE)) AS code_tronc,
            c.classement
        FROM
            C_4 a
            INNER JOIN SIREO_LEC.OUT_DOMANIALITE b ON b.cnumtrc = a.cnumtrc
            INNER JOIN G_BASE_VOIE.TA_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT c ON c.domanialite = b.domania
        UNION ALL
        SELECT
            a.cnumtrc AS objectid,
            CAST(a.cnumtrc AS VARCHAR2(254 BYTE)) AS code_tronc,
            a.classement
        FROM
            C_3 a
    )
    
    -- Récupération des géométries des tronçons
    SELECT
        a.objectid,
        a.code_tronc,
        a.classement,
        b.geom
    FROM
        C_5 a
        INNER JOIN G_BASE_VOIE.TEMP_H_TRONCON b ON b.objectid = a.objectid;
-- Résultat : 48 684 lignes insérées.

-- Insertion des secteurs de la DEPV dans G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR
INSERT INTO G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR(objectid, nom, geometry)
SELECT
    objectid,
    nom,
    geom
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE;
-- Résultat : 31 lignes insérées.
    
-- Insertion des territoires de la DEPV dans G_BASE_VOIE.TA_TAMPON_LITTERALIS_TERRITOIRE
INSERT INTO G_BASE_VOIE.TA_TAMPON_LITTERALIS_TERRITOIRE(nom, geometry)
SELECT
    'LILLOIS OUEST - UTLS 4' AS NOM,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR a
WHERE
    a.NOM IN(
        'LILLE OUEST',
        'LILLE SUD'
    )
UNION ALL
SELECT
    'LILLOIS EST - UTLS 3' AS NOM,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR a
WHERE
    a.NOM IN(
        'LILLE NORD',
        'LILLE CENTRE'
    )
UNION ALL
SELECT
    'COURONNE SUD-EST - UTLS 1' AS NOM,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR a
WHERE
    a.NOM IN(
        'RONCHIN',
        'COURONNE SUD'
    )
UNION ALL
SELECT
    'COURONNE SUD-OUEST - UTLS 2' AS NOM,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR a
WHERE
    a.NOM IN(
        'CCHD-SECLIN',
        'COURONNE OUEST'
    )
UNION ALL
SELECT
    'WEPPES SUD - UTML 1' AS NOM,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR a
WHERE
    a.NOM IN(
        'HAUBOURDIN',
        'WAVRIN',
        'BASSEEN'
    )
UNION ALL
SELECT
    'WEPPES NORD - UTML 2' AS NOM,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR a
WHERE
    a.NOM IN(
        'WEPPES',
        'MARCQUOIS'
    )
UNION ALL
SELECT
    'COURONNE NORD - UTML 3' AS NOM,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR a
WHERE
    a.NOM IN(
        'LAMBERSART',
        'WAMBRECHIES'
    )
UNION ALL
SELECT
    'ROUBAISIEN - UTRV 1' AS NOM,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR a
WHERE
    a.NOM IN(
        'WATTRELOS',
        'ROUBAIX OUEST',
        'ROUBAIX EST'
    )
UNION ALL
SELECT
    'COURONNE ROUBAISIENNE - UTRV 2' AS NOM,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR a
WHERE
    a.NOM IN(
        'CROIX',
        'LANNOY',
        'LEERS'
    )
UNION ALL
SELECT
    'EST - UTRV 3' AS NOM,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR a
WHERE
    a.NOM IN(
        'VA OUEST',
        'VA EST',
        'MELANTOIS'
    )
UNION ALL
SELECT
    'LA LYS - UTTA 1' AS NOM,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR a
WHERE
    a.NOM IN(
        'ARMENTIERES',
        'HOUPLINES'
    )
UNION ALL
SELECT
    'COMINOIS - UTTA 2' AS NOM,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR a
WHERE
    a.NOM IN(
        'COMINES HALLUIN',
        'BONDUES'
    )
UNION ALL
SELECT
    'TOURQUENNOIS - UTTA 3' AS NOM,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR a
WHERE
    a.NOM IN(
        'TOURCOING NORD',
        'TOURCOING SUD',
        'MOUVAUX-NEUVILLE'
    );
-- Résultat : 13 lignes insérées.
    
-- Insertion des unités Territoriales de la DEPV dans G_BASE_VOIE.TA_TAMPON_LITTERALIS_UNITE_TERRITOIRE
/*
La méthode d'aggrégation des Unités Territoriales utilisée, par blocs, permet de contourner l'erreur de dépassement des capacités de mémoire qu'une requête plus condensée génèrait.
*/
INSERT INTO G_BASE_VOIE.TA_TAMPON_LITTERALIS_UNITE_TERRITORIALE(nom, geometry)
WITH 
    C_1 AS(-- Création de l'UT LS
    SELECT
        SUBSTR(nom, LENGTH(nom)-5, 4) AS nom,
        SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS geometry
    FROM
        G_BASE_VOIE.TA_TAMPON_LITTERALIS_TERRITOIRE a
    WHERE
        a.nom IN('LILLOIS OUEST - UTLS 4', 'LILLOIS EST - UTLS 3', 'COURONNE SUD-EST - UTLS 1')
    GROUP BY
        SUBSTR(nom, LENGTH(nom)-5, 4)
    ),

    C_2 AS(
    SELECT
        a.nom, 
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        C_1 a,
        G_BASE_VOIE.TA_TAMPON_LITTERALIS_TERRITOIRE b
    WHERE
        b.nom = 'COURONNE SUD-OUEST - UTLS 2'
    ),
    
    C_3 AS(-- Création de l'UT ML
    SELECT
        SUBSTR(a.nom, LENGTH(a.nom)-5, 4) AS nom, 
        'Unité Territoriale' AS TYPE,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        G_BASE_VOIE.TA_TAMPON_LITTERALIS_TERRITOIRE a,
        G_BASE_VOIE.TA_TAMPON_LITTERALIS_TERRITOIRE b
    WHERE
        a.nom = 'WEPPES SUD - UTML 1'
        AND b.nom = 'WEPPES NORD - UTML 2'
    ),
    
    C_4 AS(
    SELECT
        a.nom, 
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        C_3 a,
        G_BASE_VOIE.TA_TAMPON_LITTERALIS_TERRITOIRE b
    WHERE
        b.nom = 'COURONNE NORD - UTML 3'
    ),
    
    C_5 AS(-- Création de l'UT RV
    SELECT
        SUBSTR(a.nom, LENGTH(a.nom)-5, 4) AS NOM,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        G_BASE_VOIE.TA_TAMPON_LITTERALIS_TERRITOIRE a,
        G_BASE_VOIE.TA_TAMPON_LITTERALIS_TERRITOIRE b
    WHERE
        a.nom = 'ROUBAISIEN - UTRV 1'
        AND b.nom = 'COURONNE ROUBAISIENNE - UTRV 2'
    ),
    
    C_6 AS(
    SELECT
        a.nom,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        C_5 a,
        G_BASE_VOIE.TA_TAMPON_LITTERALIS_TERRITOIRE b
    WHERE
        b.nom = 'EST - UTRV 3'
    ),
    
    C_7 AS(-- Création de l'UT TA
    SELECT
        SUBSTR(a.nom, LENGTH(a.nom)-5, 4) AS nom,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        G_BASE_VOIE.TA_TAMPON_LITTERALIS_TERRITOIRE a,
        G_BASE_VOIE.TA_TAMPON_LITTERALIS_TERRITOIRE b
    WHERE
        a.nom = 'LA LYS - UTTA 1'
        AND b.nom = 'COMINOIS - UTTA 2'
    ),
    
    C_8 AS(
    SELECT
        a.nom,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        C_7 a,
        G_BASE_VOIE.TA_TAMPON_LITTERALIS_TERRITOIRE b
    WHERE
        b.nom = 'TOURQUENNOIS - UTTA 3'
    )
    
    SELECT
        nom,
        geometry
    FROM
        C_2
    UNION ALL
    SELECT
        nom,
        geometry
    FROM
        C_4
    UNION ALL
    SELECT
        nom,
        geometry
    FROM
        C_6
    UNION ALL
    SELECT
        nom,
        geometry
    FROM
        C_8;
-- Résultat : 4 lignes insérées.