/*
Remplissage de la structure finale
*/
-- Insertion des pnoms des agents
INSERT INTO G_BASE_VOIE.TA_AGENT(numero_agent, pnom, validite)
    SELECT numero_agent, pnom, validite FROM TEMP_J_AGENT;
-- Résultat : 10 lignes insérées.

-- Insertion des types de voie
MERGE INTO G_BASE_VOIE.TA_TYPE_VOIE a
    USING(
        SELECT
            objectid,
            code_type_voie,
            libelle
        FROM
            G_BASE_VOIE.TEMP_J_TYPE_VOIE
    )t
    ON(a.code_type_voie = t.code_type_voie AND a.libelle = t.libelle)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.code_type_voie, a.libelle)
    VALUES(t.objectid, t.code_type_voie, t.libelle);
-- Résultat : 133 lignes fusionnées.

-- Insertion des valeurs de libellé dans TA_LIBELLE
INSERT INTO G_BASE_VOIE.TA_LIBELLE(objectid, libelle_court, libelle_long)
SELECT
    objectid,
    libelle_court,
    libelle_long
FROM
    G_BASE_VOIE.TEMP_J_LIBELLE;
-- Résultat : 12 lignes fusionnées.

-- Insertion des types d'action pour les tables de log
INSERT INTO G_BASE_VOIE.TA_LIBELLE(libelle_court, libelle_long)
SELECT
    'insertion' AS libelle_court,
    'Type d''action' AS libelle_long
FROM
    DUAL
UNION ALL
SELECT
    'suppression' AS libelle_court,
    'Type d''action' AS libelle_long
FROM
    DUAL
UNION ALL
SELECT
    'édition' AS libelle_court,
    'Type d''action' AS libelle_long
FROM
    DUAL;
-- Résultat : 3 lignes insérées.

-- Insertion des codes RIVOLI
MERGE INTO G_BASE_VOIE.TA_RIVOLI a
    USING(
        SELECT
            objectid,
            code_rivoli,
            cle_controle
        FROM
            G_BASE_VOIE.TEMP_J_RIVOLI
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.code_rivoli, a.cle_controle)
    VALUES(t.objectid, t.code_rivoli, t.cle_controle);
-- Résultat : 11 235 lignes fusionnées.

-- Insertion des tronçons
MERGE INTO G_BASE_VOIE.TA_TRONCON a
    USING(
        SELECT
            a.objectid, 
            a.old_objectid,
            a.geom, 
            a.date_saisie, 
            a.date_modification, 
            a.fid_pnom_saisie, 
            a.fid_pnom_modification,
            a.fid_voie_physique
        FROM
          G_BASE_VOIE.TEMP_J_TRONCON a
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.old_objectid, a.geom, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.fid_voie_physique)
    VALUES(t.objectid, t.old_objectid, t.geom, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification, t.fid_voie_physique);
-- Résultat : 50 629 lignes fusionnées.

-- Insertion des voies physiques
MERGE INTO G_BASE_VOIE.TA_VOIE_PHYSIQUE a
    USING(
            SELECT
                a.objectid,
                a.fid_action
            FROM
              G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE a
        )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.fid_action)
    VALUES(t.objectid, t.fid_action);
-- Résultat : 22 762  lignes fusionnées.

-- Insertion des relations voies physiques / voies administratives
MERGE INTO G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
    USING(
        SELECT
            fid_voie_administrative,
            fid_voie_physique,
            fid_lateralite
        FROM
            G_BASE_VOIE.TEMP_J_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
    )t
ON(a.fid_voie_administrative = t.fid_voie_administrative AND a.fid_voie_physique = t.fid_voie_physique)
WHEN NOT MATCHED THEN
    INSERT(a.fid_voie_administrative, a.fid_voie_physique, a.fid_lateralite)
    VALUES(t.fid_voie_administrative, t.fid_voie_physique, t.fid_lateralite);
-- Résultat : 23 656 lignes fusionnées.

-- Insertion des voies administratives
MERGE INTO G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE a
    USING(
        SELECT
            a.OBJECTID,
            a.LIBELLE_VOIE,
            a.COMPLEMENT_NOM_VOIE,
            a.CODE_INSEE,
            a.DATE_SAISIE,
            a.DATE_MODIFICATION,
            a.FID_PNOM_SAISIE,
            a.FID_PNOM_MODIFICATION,
            a.FID_TYPE_VOIE,
            a.FID_GENRE_VOIE,
            a.FID_RIVOLI
        FROM
            G_BASE_VOIE.TEMP_J_VOIE_ADMINISTRATIVE a
    )t
ON(a.objectid = t.objectid AND a.fid_type_voie = t.fid_type_voie)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.libelle_voie, a.complement_nom_voie, a.code_insee, a.fid_type_voie, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.fid_rivoli, a.fid_genre_voie)
    VALUES(t.objectid, t.libelle_voie, t.complement_nom_voie, t.code_insee, t.fid_type_voie, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification, t.fid_rivoli, t.fid_genre_voie);
-- Résultat : 22 168 lignes fusionnées.

-- Import des relations voies principales / secondaires
INSERT INTO G_BASE_VOIE.TA_HIERARCHISATION_VOIE(fid_voie_principale, fid_voie_secondaire)
        SELECT
            fid_voie_principale,
            fid_voie_secondaire
        FROM
            G_BASE_VOIE.TEMP_J_HIERARCHISATION_VOIE;
-- Résultat : 4 331 lignes insérées.

-- Insertion des géométries des seuils
MERGE INTO G_BASE_VOIE.TA_SEUIL a
    USING(
        SELECT
            a.GEOM,
            a.OBJECTID,
            a.CODE_INSEE,
            a.DATE_SAISIE,
            a.DATE_MODIFICATION,
            a.FID_PNOM_SAISIE,
            a.FID_PNOM_MODIFICATION,
            a.FID_TRONCON,
            a.FID_POSITION
        FROM
            G_BASE_VOIE.TEMP_J_SEUIL a
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.geom, a.objectid, a.code_insee, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.fid_troncon, a.fid_position)
    VALUES(t.geom, t.objectid, t.code_insee, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification, t.fid_troncon, t.fid_position);
-- Résultat : 351 458 lignes fusionnées.

-- Insertion des informations des seuils
MERGE INTO G_BASE_VOIE.TA_INFOS_SEUIL a
    USING(
        SELECT
            a.OBJECTID,
            a.NUMERO_SEUIL,
            a.COMPLEMENT_NUMERO_SEUIL,
            a.DATE_SAISIE,
            a.DATE_MODIFICATION,
            a.FID_PNOM_SAISIE,
            a.FID_PNOM_MODIFICATION,
            a.FID_SEUIL
        FROM
            G_BASE_VOIE.TEMP_J_INFOS_SEUIL a
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.numero_seuil, a.complement_numero_seuil, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.fid_seuil)
    VALUES(t.objectid, t.numero_seuil, t.complement_numero_seuil, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification, t.fid_seuil);
-- Résultat : 351 467 lignes fusionnées.

-----------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--------------------------------------------- Vérification import des données -------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
/*
-- Décompte des voies physiques dans la structure d'import
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE;
-- 22762

-- Décompte des voies physiques dans la structure cible
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TA_VOIE_PHYSIQUE;
-- 22762

-- Sélection du nombre de tronçons valides dans l'ancienne structure
SELECT 
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_J_TRONCON;
-- 50629

-- Sélection du nombre de tronçons dans TA_TRONCON
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TA_TRONCON;
-- 50629 tronçons

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Décompte du nombre de voies présentes dans la structure d'import
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_J_VOIE_ADMINISTRATIVE;
-- Résultat : 22168 voies

-- Décompte du nombre de voies présentes dans la structure cible
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE;
-- Résultat : 22168 libellés de voies
    
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Décompte du nombre de relations voies physiques/administratives présentes dans la structure d'import
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_J_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE;
-- Résultat : 23656 relations

-- Décompte du nombre de voies présentes dans la structure cible
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE;
-- Résultat : 23656 relations
    
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Vérification de la présence d'une action pour toutes les voies physiques
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TA_VOIE_PHYSIQUE
WHERE
    fid_action IS NULL;
-- Résultat : 1 voie physique

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Décompte du nombre de relations voies physiques/administratives sans latéralité
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
WHERE
    fid_lateralite IS NULL;
-- Résultat : 1 voie
    
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Décompte des entités n'ayant pas de date de saisie
SELECT
    'TA_TRONCON' AS nom_table,
    COUNT(*) AS nbr
FROM
    G_BASE_VOIE.TA_TRONCON
WHERE
    date_saisie IS NULL
GROUP BY
    'TA_TRONCON'
UNION ALL
SELECT
    'TA_VOIE_ADMINISTRATIVE' AS nom_table,
    COUNT(*) AS nbr
FROM
    G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE
WHERE
    date_saisie IS NULL
GROUP BY
    'TA_VOIE_ADMINISTRATIVE'
UNION ALL
SELECT
    'TA_SEUIL' AS nom_table,
    COUNT(*) AS nbr
FROM
    G_BASE_VOIE.TA_SEUIL
WHERE
    date_saisie IS NULL
GROUP BY
    'TA_SEUIL'
UNION ALL
SELECT
    'TA_INFOS_SEUIL' AS nom_table,
    COUNT(*) AS nbr
FROM
    G_BASE_VOIE.TA_INFOS_SEUIL
WHERE
    date_saisie IS NULL
GROUP BY
    'TA_INFOS_SEUIL';
    
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/