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
        END AS CLASSEMENT
    FROM
        C_1 a;
-- Résultat : 11 entités insérées

-- Insertion des voies administratives sans distinction de latéralité
INSERT INTO G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE(objectid, code_voie, nom_voie, code_insee, geometry)
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
            G_BASE_VOIE.TEMP_I_TRONCON a
            INNER JOIN G_BASE_VOIE.TEMP_I_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TEMP_I_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
            INNER JOIN G_BASE_VOIE.TEMP_I_VOIE_ADMINISTRATIVE d ON d.objectid = c.fid_voie_administrative
            INNER JOIN G_BASE_VOIE.TEMP_I_TYPE_VOIE e ON e.objectid = d.fid_type_voie
            INNER JOIN G_BASE_VOIE.TEMP_I_HIERARCHISATION_VOIE f ON f.fid_voie_secondaire = d.objectid
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
    CAST(a.code_insee AS VARCHAR2(254 BYTE)) AS code_insee,
    a.geom
FROM
    C_1 a
UNION ALL
SELECT -- Sélection et matérialisation des voies principales
    d.objectid,
    CAST(d.objectid AS VARCHAR2(254 BYTE)) AS code_voie,
    CAST(SUBSTR(UPPER(TRIM(e.libelle)), 1, 1) || SUBSTR(LOWER(TRIM(e.libelle)), 2) || CASE WHEN d.libelle_voie IS NOT NULL THEN ' ' || TRIM(d.libelle_voie) ELSE '' END || CASE WHEN d.complement_nom_voie IS NOT NULL THEN ' ' || TRIM(d.complement_nom_voie) ELSE '' END || CASE WHEN d.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN d.code_insee = '59355' THEN ' (Lomme)' END AS VARCHAR2(254)) AS nom_voie,
    CAST(d.code_insee AS VARCHAR2(254 BYTE)) AS code_insee,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS geom
FROM
    G_BASE_VOIE.TEMP_I_TRONCON a
    INNER JOIN G_BASE_VOIE.TEMP_I_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TEMP_I_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
    INNER JOIN G_BASE_VOIE.TEMP_I_VOIE_ADMINISTRATIVE d ON d.objectid = c.fid_voie_administrative
    INNER JOIN G_BASE_VOIE.TEMP_I_TYPE_VOIE e ON e.objectid = d.fid_type_voie
WHERE
    d.objectid NOT IN(SELECT fid_voie_secondaire FROM G_BASE_VOIE.TEMP_H_HIERARCHISATION_VOIE)
GROUP BY
    d.objectid,
    CAST(d.objectid AS VARCHAR2(254 BYTE)),
    CAST(SUBSTR(UPPER(TRIM(e.libelle)), 1, 1) || SUBSTR(LOWER(TRIM(e.libelle)), 2) || CASE WHEN d.libelle_voie IS NOT NULL THEN ' ' || TRIM(d.libelle_voie) ELSE '' END || CASE WHEN d.complement_nom_voie IS NOT NULL THEN ' ' || TRIM(d.complement_nom_voie) ELSE '' END || CASE WHEN d.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN d.code_insee = '59355' THEN ' (Lomme)' END AS VARCHAR2(254)),
    CAST(d.code_insee AS VARCHAR2(254 BYTE));
-- Résultat : 22 164 lignes insérées.

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
            g.libelle_court,
            SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS geom
        FROM
            G_BASE_VOIE.TEMP_I_TRONCON a
            INNER JOIN G_BASE_VOIE.TEMP_I_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TEMP_I_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
            INNER JOIN G_BASE_VOIE.TEMP_I_VOIE_ADMINISTRATIVE d ON d.objectid = c.fid_voie_administrative
            INNER JOIN G_BASE_VOIE.TEMP_I_TYPE_VOIE e ON e.objectid = d.fid_type_voie
            INNER JOIN G_BASE_VOIE.TEMP_I_HIERARCHISATION_VOIE f ON f.fid_voie_secondaire = d.objectid
            INNER JOIN G_BASE_VOIE.TEMP_I_LIBELLE g ON g.objectid = c.fid_lateralite
        GROUP BY
            d.objectid,
            e.libelle,
            d.libelle_voie,
            d.complement_nom_voie,
            d.code_insee,
            g.libelle_court
    )

SELECT -- mise en ordre des voies secondaires en fonction de leur taille (ajout du suffixe ANNEXE 1, 2, 3 en fonction de la taille pour un même libelle_voie et code_insee)
    a.objectid,
    CAST(a.objectid AS VARCHAR2(254 BYTE)) AS code_voie,
    CAST(SUBSTR(UPPER(TRIM(a.libelle)), 1, 1) || SUBSTR(LOWER(TRIM(a.libelle)), 2) || CASE WHEN a.libelle_voie IS NOT NULL THEN ' ' || TRIM(a.libelle_voie) ELSE '' END || CASE WHEN a.complement_nom_voie IS NOT NULL THEN ' ' || TRIM(a.complement_nom_voie) ELSE '' END || CASE WHEN a.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN a.code_insee = '59355' THEN ' (Lomme)' END || ' Annexe ' || ROW_NUMBER() OVER (PARTITION BY (UPPER(TRIM(a.libelle_voie)) || ' ' || a.code_insee) ORDER BY SDO_GEOM.SDO_LENGTH(a.geom, 0.001) DESC) AS VARCHAR2(254)) AS nom_voie,
    CAST(a.code_insee AS VARCHAR2(254 BYTE)) AS code_insee,
    CAST(a.libelle_court AS VARCHAR2(254 BYTE)) AS cote_voie,
    a.geom
FROM
    C_1 a
UNION ALL
SELECT -- Sélection et matérialisation des voies principales
    d.objectid,
    CAST(d.objectid AS VARCHAR2(254 BYTE)) AS code_voie,
    CAST(SUBSTR(UPPER(TRIM(e.libelle)), 1, 1) || SUBSTR(LOWER(TRIM(e.libelle)), 2) || CASE WHEN d.libelle_voie IS NOT NULL THEN ' ' || TRIM(d.libelle_voie) ELSE '' END || CASE WHEN d.complement_nom_voie IS NOT NULL THEN ' ' || TRIM(d.complement_nom_voie) ELSE '' END || CASE WHEN d.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN d.code_insee = '59355' THEN ' (Lomme)' END AS VARCHAR2(254)) AS nom_voie,
    CAST(d.code_insee AS VARCHAR2(254 BYTE)) AS code_insee,
    CAST(f.libelle_court AS VARCHAR2(254 BYTE)) AS cote_voie,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS geom
FROM
    G_BASE_VOIE.TEMP_I_TRONCON a
    INNER JOIN G_BASE_VOIE.TEMP_I_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TEMP_I_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
    INNER JOIN G_BASE_VOIE.TEMP_I_VOIE_ADMINISTRATIVE d ON d.objectid = c.fid_voie_administrative
    INNER JOIN G_BASE_VOIE.TEMP_I_TYPE_VOIE e ON e.objectid = d.fid_type_voie
    INNER JOIN G_BASE_VOIE.TEMP_I_LIBELLE f ON f.objectid = c.fid_lateralite
WHERE
    d.objectid NOT IN(SELECT fid_voie_secondaire FROM G_BASE_VOIE.TEMP_H_HIERARCHISATION_VOIE)
GROUP BY
    d.objectid,
    CAST(d.objectid AS VARCHAR2(254 BYTE)),
    CAST(SUBSTR(UPPER(TRIM(e.libelle)), 1, 1) || SUBSTR(LOWER(TRIM(e.libelle)), 2) || CASE WHEN d.libelle_voie IS NOT NULL THEN ' ' || TRIM(d.libelle_voie) ELSE '' END || CASE WHEN d.complement_nom_voie IS NOT NULL THEN ' ' || TRIM(d.complement_nom_voie) ELSE '' END || CASE WHEN d.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN d.code_insee = '59355' THEN ' (Lomme)' END AS VARCHAR2(254)),
    CAST(d.code_insee AS VARCHAR2(254 BYTE)),
    CAST(f.libelle_court AS VARCHAR2(254 BYTE));
-- Résultat : 22 587 lignes insérées.

-- Insertion des tronçons au format LITTERALIS
INSERT INTO G_BASE_VOIE.TA_TAMPON_LITTERALIS_TRONCON(GEOMETRY, OBJECTID, CODE_TRONC, CLASSEMENT, ID_VOIE_DROITE, ID_VOIE_GAUCHE, CODE_INSEE_VOIE_DROITE, CODE_INSEE_VOIE_GAUCHE, NOM_VOIE_DROITE, NOM_VOIE_GAUCHE)
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
            c.classement,
            b.fid_voie_physique,
            d.fid_voie_administrative,
            d.fid_lateralite
        FROM
            C_4 a
            INNER JOIN SIREO_LEC.OUT_DOMANIALITE b ON b.cnumtrc = a.cnumtrc
            INNER JOIN G_BASE_VOIE.TA_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT c ON c.domanialite = b.domania
            INNER JOIN G_BASE_VOIE.TEMP_I_TRONCON b ON a.cnumtrc = b.objectid
            INNER JOIN G_BASE_VOIE.TEMP_I_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = b.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TEMP_I_LIBELLE e ON e.objectid = d.fid_lateralite
        UNION ALL
        SELECT
            a.cnumtrc AS objectid,
            CAST(a.cnumtrc AS VARCHAR2(254 BYTE)) AS code_tronc,
            a.classement,
            b.fid_voie_physique,
            d.fid_voie_administrative,
            d.fid_lateralite
        FROM
            C_3 a
            INNER JOIN G_BASE_VOIE.TEMP_I_TRONCON b ON a.cnumtrc = b.objectid
            INNER JOIN G_BASE_VOIE.TEMP_I_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = b.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TEMP_I_LIBELLE e ON e.objectid = d.fid_lateralite
    ),
    
    C_6 AS(-- Récupération des informations complémentaires (hors géométrie)
        SELECT
            a.objectid,
            a.code_tronc,
            a.classement,
            CASE
                WHEN a.fid_lateralite = 1
                    THEN 'Droit'
                WHEN a.fid_lateralite = 2
                    THEN 'Gauche'
                WHEN a.fid_lateralite = 3
                    THEN 'LesDeuxCotes'
            END AS lateralite,
            b.objectid AS id_voie,
            b.code_insee AS code_insee_voie,
            b.nom_voie AS nom_voie
        FROM
            C_5 a
            INNER JOIN G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE b ON b.objectid = a.fid_voie_administrative
    )
    
    SELECT
        b.geom,
        a.objectid,
        a.code_tronc,
        a.classement,
        a.id_voie AS id_voie_droite,
        c.id_voie AS id_voie_gauche,
        a.code_insee_voie AS code_insee_voie_droite,
        c.code_insee_voie AS code_insee_voie_gauche,
        a.nom_voie AS nom_voie_droite,
        c.nom_voie AS nom_voie_gauche
    FROM
        C_6 a
        INNER JOIN G_BASE_VOIE.TEMP_H_TRONCON b ON b.objectid = a.objectid
        INNER JOIN C_6 c ON c.objectid = b.objectid
    WHERE
        a.lateralite IN('Droit', 'LesDeuxCotes')
        AND c.lateralite IN('Gauche', 'LesDeuxCotes');
-- Résultat : 48 681 lignes insérées.

-- Insertion des adresses
INSERT INTO G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE(geometry, objectid, code_point, code_voie, nature, libelle, numero, repetition, cote, fid_voie)
WITH
    C_1 AS(
        SELECT DISTINCT
            a.objectid AS id_seuil,
            b.objectid AS objectid,
            CAST(f.objectid AS VARCHAR2(254 BYTE)) AS code_voie,
            CAST(b.objectid AS VARCHAR2(254)) AS CODE_POINT,
            f.objectid AS ID_VOIE,
            c.objectid AS id_troncon,
            d.objectid AS id_voie_physique,
            CAST('ADR' AS VARCHAR2(254)) AS NATURE,
            CAST(CASE WHEN LENGTH(CAST(TRIM(b.numero_seuil) AS VARCHAR2(254 BYTE))) = 1 THEN '0' || CAST(TRIM(b.numero_seuil) AS VARCHAR2(254 BYTE)) ELSE CAST(b.numero_seuil AS VARCHAR2(254 BYTE)) END || ' ' || TRIM(b.complement_numero_seuil) AS VARCHAR2(254)) AS LIBELLE,
            CAST(b.numero_seuil  AS NUMBER(8,0)) AS NUMERO,
            CAST(TRIM(b.complement_numero_seuil) AS VARCHAR2(254)) AS REPETITION,
            CASE
                WHEN e.fid_lateralite = 1
                    THEN 'Pair'
                WHEN e.fid_lateralite = 2
                    THEN 'Impair'
                ELSE
                    'LesDeuxCotes' 
            END AS COTE
        FROM
            G_BASE_VOIE.TEMP_H_SEUIL a
            INNER JOIN G_BASE_VOIE.TEMP_H_INFOS_SEUIL b ON b.fid_seuil = a.objectid
            INNER JOIN G_BASE_VOIE.TEMP_H_TRONCON c ON c.objectid = a.fid_troncon
            INNER JOIN G_BASE_VOIE.TEMP_I_VOIE_PHYSIQUE d ON d.objectid = c.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TEMP_I_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE e ON e.fid_voie_physique = d.objectid    
            INNER JOIN G_BASE_VOIE.TEMP_I_VOIE_ADMINISTRATIVE f ON f.objectid = e.fid_voie_administrative AND f.code_insee = a.code_insee
            --INNER JOIN G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE f ON f.id_voie = e.fid_voie_administrative AND f.code_insee = a.code_insee
        WHERE
            -- Cette condition est nécessaire car le numéro 97T est en doublon (doublon aussi dans la BdTopo). Ce numéro est affecté à deux parcelles.
            a.objectid <> 241295
    )
    
    SELECT
        b.GEOM,
        a.OBJECTID,
        a.CODE_POINT,
        a.CODE_VOIE,
        a.NATURE,
        a.LIBELLE,
        a.NUMERO,
        a.REPETITION,
        a.COTE,
        a.ID_VOIE
    FROM
        C_1 a
        INNER JOIN G_BASE_VOIE.TEMP_H_SEUIL b ON b.objectid = a.id_seuil;
-- Résultat : 351 177 lignes insérées.

-- Insertion des secteurs de la DEPV dans G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR
INSERT INTO G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR(geometry, objectid, nom)
SELECT
    geom,
    objectid,
    nom
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
INSERT INTO G_BASE_VOIE.TA_TAMPON_LITTERALIS_UNITE_TERRITORIALE(objectid, nom, geometry)
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
        1 AS objectid,
        nom,
        geometry
    FROM
        C_2
    UNION ALL
    SELECT
        2 AS objectid,
        nom,
        geometry
    FROM
        C_4
    UNION ALL
    SELECT
        3 AS objectid,
        nom,
        geometry
    FROM
        C_6
    UNION ALL
    SELECT
        4 AS objectid,
        nom,
        geometry
    FROM
        C_8;
-- Résultat : 4 lignes insérées.