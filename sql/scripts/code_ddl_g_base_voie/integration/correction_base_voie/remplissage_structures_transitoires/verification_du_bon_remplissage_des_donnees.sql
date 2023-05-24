/*
Vérification du bon import des données d'une structure à l'autre + correction des données au besoin
*/
-- 1. Comparaison du nombre d'entités d'une structure à l'autre afin de vérifeir que l'insertion s'est bien passée
WITH
    C_1 AS(-- Décompte des entités source
        SELECT
            'Tronçon' AS type_entite,
            COUNT(a.objectid) AS nbr_entite_source
        FROM
            G_BASE_VOIE.TEMP_F_TRONCON a
        GROUP BY
            'Tronçon'
        UNION ALL
        SELECT
            'Voie physique' AS type_entite,
            COUNT(*) AS nbr_entite_source
        FROM
            G_BASE_VOIE.TEMP_F_VOIE_PHYSIQUE
        GROUP BY
            'Voie physique'
        UNION ALL
        SELECT
            'Relation voie physique / administrative' AS type_entite,
            COUNT(*) AS nbr_entite_source
        FROM
            G_BASE_VOIE.TEMP_F_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
        GROUP BY
            'Relation voie physique / administrative'
        UNION ALL
        SELECT
            'Voie administrative' AS type_entite,
            COUNT(*) AS nbr_entite_source
        FROM
            G_BASE_VOIE.TEMP_F_VOIE_ADMINISTRATIVE
        GROUP BY
            'Voie administrative'
        UNION ALL
        SELECT
            'Type de voie' AS type_entite,
            COUNT(*) AS nbr_entite_source
        FROM
            G_BASE_VOIE.TEMP_F_TYPE_VOIE
        GROUP BY
            'Type de voie'
    ),
    
    C_2 AS(-- Décompte des entités source
        SELECT
            'Tronçon' AS type_entite,
            COUNT(a.objectid) AS nbr_entite_cible
        FROM
            G_BASE_VOIE.TEMP_G_TRONCON a
        GROUP BY
            'Tronçon'
        UNION ALL
        SELECT
            'Voie physique' AS type_entite,
            COUNT(*) AS nbr_entite_cible
        FROM
            G_BASE_VOIE.TEMP_G_VOIE_PHYSIQUE
        GROUP BY
            'Voie physique'
        UNION ALL
        SELECT
            'Relation voie physique / administrative' AS type_entite,
            COUNT(*) AS nbr_entite_cible
        FROM
            G_BASE_VOIE.TEMP_G_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
        GROUP BY
            'Relation voie physique / administrative'
        UNION ALL
        SELECT
            'Voie administrative' AS type_entite,
            COUNT(*) AS nbr_entite_cible
        FROM
            G_BASE_VOIE.TEMP_G_VOIE_ADMINISTRATIVE
        GROUP BY
            'Voie administrative'
        UNION ALL
        SELECT
            'Type de voie' AS type_entite,
            COUNT(*) AS nbr_entite_cible
        FROM
            G_BASE_VOIE.TEMP_G_TYPE_VOIE
        GROUP BY
            'Type de voie'
    )
    
    SELECT
        a.type_entite,
        a.nbr_entite_source,
        b.nbr_entite_cible
    FROM
        C_1 a
        INNER JOIN C_2 b ON b.type_entite = a.type_entite;
/* WARNING !!!
Si les chiffres de la requête ci-dessus correspondent entre la structure source et la structure cible, il est inutile d'utiliser les requêtes ci-dessous, si et seulement si, 
la requête ci-dessus a été utilisée juste après l'insertion des données dans la structure cible et que la structure source n'a pas été modifiée entre temps.        
*/

-- 2. Sélection des entités de la structure source absentes de la structure cible
-- Sélection de tous les tronçons de la structure source absents de la structure cible
SELECT
    objectid || ',',
    geom,
    date_saisie,
    date_modification,
    fid_pnom_saisie,
    fid_pnom_modification,
    fid_voie_physique
FROM
    G_BASE_VOIE.TEMP_F_TRONCON
WHERE
    objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_G_TRONCON);
        
-- Sélection de toutes les voies physiques de la structure source absentes de la structure cible
SELECT
    objectid || ','
FROM
    G_BASE_VOIE.TEMP_F_VOIE_PHYSIQUE
WHERE
    objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_G_VOIE_PHYSIQUE);
    
-- Sélection de toutes les relation voies physiques / voies administratives de la structure source absentes de la structure cible
SELECT
    objectid || ',',
    fid_voie_physique,
    fid_voie_administrative
FROM
    G_BASE_VOIE.TEMP_F_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
WHERE
    objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_G_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE);
    
-- Sélection de toutes les voies administratives de la structure source absentes de la structure cible
SELECT
    objectid || ',',
    genre_voie,
    libelle_voie,
    complement_nom_voie,
    fid_lateralite,
    code_insee,
    commentaire,
    date_saisie,
    date_modification,
    fid_pnom_saisie,
    fid_pnom_modification,
    fid_type_voie
FROM
    G_BASE_VOIE.TEMP_F_VOIE_ADMINISTRATIVE
WHERE
    objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_G_VOIE_ADMINISTRATIVE);    
    
-- 3. Insertion des entités de la structure cible absentes de la structure source
-- Insertion de toutes les voies physiques de la structure source absentes de la structure cible
MERGE INTO G_BASE_VOIE.TEMP_G_VOIE_PHYSIQUE a
    USING(
        SELECT
            objectid
        FROM
            G_BASE_VOIE.TEMP_F_VOIE_PHYSIQUE
        WHERE
            objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_G_VOIE_PHYSIQUE)
    )t
ON (a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid)
    VALUES(t.objectid);

-- Insertion de tous les tronçons de la structure source absents de la structure cible
MERGE INTO G_BASE_VOIE.TEMP_G_TRONCON a
    USING(
        SELECT
            objectid,
            geom,
            date_saisie,
            date_modification,
            fid_pnom_saisie,
            fid_pnom_modification,
            fid_voie_physique
        FROM
            G_BASE_VOIE.TEMP_F_TRONCON
        WHERE
            objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_G_TRONCON)
    )t
ON (a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.geom, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.fid_voie_physique)
    VALUES(t.objectid, t.geom, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification, t.fid_voie_physique);
    
-- Insertion de toutes les relation voies physiques / voies administratives de la structure source absentes de la structure cible
MERGE INTO G_BASE_VOIE.TEMP_G_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
    USING(
        SELECT
            objectid,
            fid_voie_physique,
            fid_voie_administrative
        FROM
            G_BASE_VOIE.TEMP_F_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
        WHERE
            objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_G_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE)
    )t
ON (a.fid_voie_physique = t.fid_voie_physique AND a.fid_voie_administrative = t.fid_voie_administrative)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.fid_voie_physique, a.fid_voie_administrative)
    VALUES(t.objectid, t.fid_voie_physique, t.fid_voie_administrative);
    
-- Insertion de toutes les voies administratives de la structure source absentes de la structure cible
MERGE INTO G_BASE_VOIE.TEMP_G_VOIE_ADMINISTRATIVE a
    USING(
        SELECT
            objectid,
            genre_voie,
            libelle_voie,
            complement_nom_voie,
            fid_lateralite,
            code_insee,
            commentaire,
            date_saisie,
            date_modification,
            fid_pnom_saisie,
            fid_pnom_modification,
            fid_type_voie
        FROM
            G_BASE_VOIE.TEMP_F_VOIE_ADMINISTRATIVE
        WHERE
            objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_G_VOIE_ADMINISTRATIVE)
    )t
ON (a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.genre_voie, a.libelle_voie, a.complement_nom_voie, a.fid_lateralite, a.code_insee, a.commentaire, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.fid_type_voie)
    VALUES(t.objectid, t.genre_voie, t.libelle_voie, t.complement_nom_voie, t.fid_lateralite, t.code_insee, t.commentaire, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification, t.fid_type_voie);
    
-- 4. Sélection des entités de la structure cible absentes de la structure source
-- Sélection de tous les tronçons de la structure cible absents de la structure source
SELECT
    objectid || ',',
    geom,
    date_saisie,
    date_modification,
    fid_pnom_saisie,
    fid_pnom_modification,
    fid_voie_physique
FROM
    G_BASE_VOIE.TEMP_G_TRONCON
WHERE
    objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_F_TRONCON);
        
-- Sélection de toutes les voies physiques de la structure cible absentes de la structure source
SELECT
    objectid || ','
FROM
    G_BASE_VOIE.TEMP_G_VOIE_PHYSIQUE
WHERE
    objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_F_VOIE_PHYSIQUE);
    
-- Sélection de toutes les relation voies physiques / voies administratives de la structure cible absentes de la structure source
SELECT
    objectid || ',',
    fid_voie_physique,
    fid_voie_administrative
FROM
    G_BASE_VOIE.TEMP_G_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
WHERE
    objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_F_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE);
    
-- Sélection de toutes les voies administratives de la structure cible absentes de la structure source
SELECT
    objectid || ',',
    genre_voie,
    libelle_voie,
    complement_nom_voie,
    fid_lateralite,
    code_insee,
    commentaire,
    date_saisie,
    date_modification,
    fid_pnom_saisie,
    fid_pnom_modification,
    fid_type_voie
FROM
    G_BASE_VOIE.TEMP_G_VOIE_ADMINISTRATIVE
WHERE
    objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_F_VOIE_ADMINISTRATIVE);    