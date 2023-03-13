-- Insertion des pnoms des agents
INSERT INTO G_BASE_VOIE.TEMP_I_AGENT(numero_agent, pnom, validite)
    SELECT numero_agent, pnom, validite FROM TEMP_H_AGENT;
-- Résultat : 10 lignes insérées.

-- Insertion des types de voie
MERGE INTO G_BASE_VOIE.TEMP_I_TYPE_VOIE a
    USING(
        SELECT
            objectid,
            code_type_voie,
            libelle
        FROM
            G_BASE_VOIE.TEMP_H_TYPE_VOIE
    )t
    ON(a.code_type_voie = t.code_type_voie AND a.libelle = t.libelle)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.code_type_voie, a.libelle)
    VALUES(t.objectid, t.code_type_voie, t.libelle);
-- Résultat : 133 lignes fusionnées.

-- Insertion des valeurs de libellé dans TEMP_I_LIBELLE
INSERT INTO G_BASE_VOIE.TEMP_I_LIBELLE(objectid, libelle_court, libelle_long)
SELECT
    objectid,
    libelle_court,
    libelle_long
FROM
    G_BASE_VOIE.TEMP_H_LIBELLE;
-- Résultat : 5 lignes fusionnées.

-- Insertion des actions à faire dans TEMP_I_LIBELLE
INSERT INTO G_BASE_VOIE.TEMP_I_LIBELLE(libelle_court, libelle_long)
SELECT
    'à inverser' AS libelle_court,
    'inverser le sens géométrique de la voie physique' AS libelle_long
FROM
    DUAL
UNION ALL
SELECT
    'à conserver' AS libelle_court,
    'conserver le sens géométrique de la voie physique' AS libelle_long
FROM
    DUAL;
-- Résultat : 2 lignes fusionnées.


-- Insertion des codes RIVOLI
MERGE INTO G_BASE_VOIE.TEMP_I_RIVOLI a
    USING(
        SELECT
            objectid,
            code_rivoli,
            cle_controle
        FROM
            G_BASE_VOIE.TEMP_H_RIVOLI
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.code_rivoli, a.cle_controle)
    VALUES(t.objectid, t.code_rivoli, t.cle_controle);
-- Résultat : 11 235 lignes fusionnées.

-- Insertion des tronçons
MERGE INTO G_BASE_VOIE.TEMP_I_TRONCON a
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
          G_BASE_VOIE.TEMP_H_TRONCON a
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.old_objectid, a.geom, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.fid_voie_physique)
    VALUES(t.objectid, t.old_objectid, t.geom, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification, t.fid_voie_physique);
-- Résultat : 50 625 lignes fusionnées.

-- Mise à jour de l'état d'avancement des tronçons affectés à des voies situées en limite de commune.
MERGE INTO G_BASE_VOIE.TEMP_I_TRONCON a
    USING(
        WITH
            C_1 AS(
                SELECT DISTINCT
                    fid_voie_physique
                FROM
                    G_BASE_VOIE.TEMP_I_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
                WHERE
                    fid_lateralite IN(1,2)
            )
        
        SELECT
            a.objectid,
            c.objectid AS fid_etat
        FROM
            G_BASE_VOIE.TEMP_I_TRONCON a
            INNER JOIN C_1 b ON b.fid_voie_physique = a.fid_voie_physique,
            G_BASE_VOIE.TEMP_I_LIBELLE c
        WHERE
            c.libelle_court = 'non-vérifié'
    )t
ON(a.objectid = t.objectid)
WHEN MATCHED THEN
    UPDATE SET a.fid_etat = t.fid_etat;
-- Résultat : 1 018 lignes fusionnées.

-- Insertion des voies physiques
MERGE INTO G_BASE_VOIE.TEMP_I_VOIE_PHYSIQUE a
    USING(
            SELECT
                a.objectid
            FROM
              G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE a
        )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid)
    VALUES(t.objectid);
-- Résultat : 22 945  lignes fusionnées.

-- Insertion des relations voies physiques / voies administratives
MERGE INTO G_BASE_VOIE.TEMP_I_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
    USING(
        SELECT
            fid_voie_administrative,
            fid_voie_physique,
            fid_lateralite
        FROM
            G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
    )t
ON(a.fid_voie_administrative = t.fid_voie_administrative AND a.fid_voie_physique = t.fid_voie_physique)
WHEN NOT MATCHED THEN
    INSERT(a.fid_voie_administrative, a.fid_voie_physique, a.fid_lateralite)
    VALUES(t.fid_voie_administrative, t.fid_voie_physique, t.fid_lateralite);
-- Résultat : 23 652 lignes fusionnées.

-- Insertion des voies administratives
MERGE INTO G_BASE_VOIE.TEMP_I_VOIE_ADMINISTRATIVE a
    USING(
        SELECT
            a.OBJECTID,
            a.GENRE_VOIE,
            a.LIBELLE_VOIE,
            a.COMPLEMENT_NOM_VOIE,
            a.CODE_INSEE,
            a.DATE_SAISIE,
            a.DATE_MODIFICATION,
            a.FID_PNOM_SAISIE,
            a.FID_PNOM_MODIFICATION,
            a.FID_TYPE_VOIE,
            a.FID_RIVOLI
        FROM
            G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE a
    )t
ON(a.objectid = t.objectid AND a.fid_type_voie = t.fid_type_voie)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.libelle_voie, a.complement_nom_voie, a.code_insee, a.fid_type_voie, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.fid_rivoli)
    VALUES(t.objectid, t.libelle_voie, t.complement_nom_voie, t.code_insee, t.fid_type_voie, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification, t.fid_rivoli);
-- Résultat : 22 165 lignes fusionnées.

-- Import des relations voies principales / secondaires
INSERT INTO G_BASE_VOIE.TEMP_I_HIERARCHISATION_VOIE(fid_voie_principale, fid_voie_secondaire)
        SELECT
            fid_voie_principale,
            fid_voie_secondaire
        FROM
            G_BASE_VOIE.TEMP_H_HIERARCHISATION_VOIE;
-- Résultat : 4330 lignes insérées.
    
-- Remplissage de la table TEMP_I_VOIE_LATERALITE qui sevira à homogénéiser la latéralité des voies
INSERT INTO G_BASE_VOIE.TEMP_I_VOIE_LATERALITE(FID_VOIE_PHYSIQUE,FID_VOIE_ADMINISTRATIVE,CODE_INSEE,NOM_VOIE,FID_LATERALITE,FID_ETAT,GEOM)
WITH
    C_1 AS(
        SELECT
            b.objectid AS id_voie_physique,
            SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS geom
        FROM
            G_BASE_VOIE.TEMP_I_TRONCON a
            INNER JOIN G_BASE_VOIE.TEMP_I_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TEMP_I_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
        GROUP BY
            b.objectid
    )

SELECT
    a.id_voie_physique AS fid_voie_physique,
    c.objectid AS fid_voie_administrative,
    c.code_insee,
    TRIM(SUBSTR(TRIM(UPPER(d.libelle)), 1,1) || SUBSTR(TRIM(LOWER(d.libelle)), 2) || ' ' || TRIM(c.libelle_voie) || ' ' || TRIM(c.complement_nom_voie)) AS nom_voie,
    b.fid_lateralite,
    f.objectid AS fid_etat,
    a.geom
FROM
    C_1 a 
    INNER JOIN G_BASE_VOIE.TEMP_I_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE b ON b.fid_voie_physique = a.id_voie_physique
    INNER JOIN G_BASE_VOIE.TEMP_I_VOIE_ADMINISTRATIVE c ON c.objectid = b.fid_voie_administrative
    INNER JOIN G_BASE_VOIE.TEMP_I_TYPE_VOIE d ON d.objectid = c.fid_type_voie
    INNER JOIN G_BASE_VOIE.TEMP_I_LIBELLE e ON e.objectid = b.fid_lateralite,
    G_BASE_VOIE.TEMP_I_LIBELLE f
WHERE
    f.libelle_court = 'non-vérifié';
-- Résultat : 23 651 lignes insérées.

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
    G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE;
-- 22945

-- Décompte des voies physiques dans la structure cible
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_I_VOIE_PHYSIQUE;
-- 22945

-- Sélection du nombre de tronçons valides dans l'ancienne structure
SELECT 
    COUNT(DISTINCT objectid)
FROM
    G_BASE_VOIE.TEMP_H_TRONCON;
-- 50625

-- Sélection du nombre de tronçons dans TEMP_I_TRONCON
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_I_TRONCON;
-- 50625 tronçons

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Décompte du nombre de voies présentes dans la structure d'import
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE;
-- Résultat : 22165 voies

-- Décompte du nombre de voies présentes dans la structure cible
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_I_VOIE_ADMINISTRATIVE;
-- Résultat : 22165 libellés de voies
    
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Décompte du nombre de relations voies physiques/administratives présentes dans la structure d'import
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE;
-- Résultat : 23652 relations

-- Décompte du nombre de voies présentes dans la structure cible
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_I_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE;
-- Résultat : 23652 relations
    
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
