-- Insertion des pnoms des agents
INSERT INTO G_BASE_VOIE.TEMP_H_AGENT(numero_agent, pnom, validite)
    SELECT numero_agent, pnom, validite FROM TEMP_F_AGENT;
-- Résultat : 10 lignes insérées.

-- Insertion des types de voie
MERGE INTO G_BASE_VOIE.TEMP_H_TYPE_VOIE a
    USING(
        SELECT
            objectid,
            code_type_voie,
            libelle
        FROM
            G_BASE_VOIE.TEMP_F_TYPE_VOIE
    )t
    ON(a.code_type_voie = t.code_type_voie AND a.libelle = t.libelle)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.code_type_voie, a.libelle)
    VALUES(t.objectid, t.code_type_voie, t.libelle);
-- Résultat : 132 lignes fusionnées.

-- Insertion des valeurs de latéralité des voies dans TEMP_H_LIBELLE
INSERT INTO G_BASE_VOIE.TEMP_H_LIBELLE(objectid, libelle_court, libelle_long)
SELECT
    objectid,
    libelle_court,
    libelle_long
FROM
    G_BASE_VOIE.TEMP_F_LIBELLE
WHERE
    libelle_court IN('droit', 'gauche', 'les deux côtés');
-- Résultat : 3 lignes fusionnées.

-- Insertion des tronçons
MERGE INTO G_BASE_VOIE.TEMP_H_TRONCON a
    USING(
        SELECT
            a.objectid, 
            a.geom, 
            a.date_saisie, 
            a.date_modification, 
            a.fid_pnom_saisie, 
            a.fid_pnom_modification,
            a.fid_voie_physique
        FROM
          G_BASE_VOIE.TEMP_F_TRONCON a
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.geom, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.fid_voie_physique)
    VALUES(t.objectid, t.geom, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification, t.fid_voie_physique);
-- Résultat : 50 631 lignes fusionnées.

-- Correspondance ancien/nouveau tronçon pour les anciens tronçons (ayant le même objectid, même si la géométrie a changé)
MERGE INTO G_BASE_VOIE.TEMP_H_TRONCON a
    USING(
        SELECT
            a.objectid
        FROM
            G_BASE_VOIE.TEMP_B_TRONCON a
        WHERE
            objectid <= 91014
    )t
ON(a.objectid = t.objectid)
WHEN MATCHED THEN
    UPDATE SET a.old_objectid = t.objectid;
-- Résultat : 49 629 lignes fusionnées

-- Correspondance ancien/nouveau tronçon pour les nouveaux tronçons (ayant un nouvel objectid)
MERGE INTO G_BASE_VOIE.TEMP_H_TRONCON a
    USING(
        SELECT -- Sélection des tronçons découpés ayant un nouvel identifiant
            a.objectid,
            b.cnumtrc
        FROM
            G_BASE_VOIE.TEMP_H_TRONCON a,
            G_BASE_VOIE.TEMP_ILTATRC b
        WHERE
            a.old_objectid IS NULL
            AND b.cdvaltro = 'V'
            AND SDO_WITHIN_DISTANCE(b.ora_geometry, a.geom, 'distance=0.5') = 'TRUE'
            AND SDO_EQUAL(a.geom, b.ora_geometry) <> 'TRUE'
            AND SDO_COVERS(b.ora_geometry, a.geom) = 'TRUE' -- Résultat : 483 tronçons
   )t
ON(a.objectid = t.objectid)
WHEN MATCHED THEN
    UPDATE SET a.old_objectid = t.cnumtrc;
-- Résultat : 483 lignes fusionnées

-- Insertion des voies physiques
MERGE INTO G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE a
    USING(
            SELECT
                a.objectid
            FROM
              G_BASE_VOIE.TEMP_F_VOIE_PHYSIQUE a
        )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid)
    VALUES(t.objectid);
-- Résultat : 22 943  lignes fusionnées.

-- Insertion des relations voies physiques / voies administratives
MERGE INTO G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
    USING(
        SELECT
            a.fid_voie_administrative,
            a.fid_voie_physique,
            CASE
                WHEN
                    b.fid_lateralite IS NULL
                THEN
                    c.objectid
                ELSE
                    b.fid_lateralite
            END AS fid_lateralite
        FROM
            G_BASE_VOIE.TEMP_G_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
            LEFT JOIN G_BASE_VOIE.TEMP_G_VOIE_LATERALITE b ON b.id_voie_physique = a.fid_voie_physique AND b.id_voie_administrative = a.fid_voie_administrative,
            G_BASE_VOIE.TEMP_H_LIBELLE c
        WHERE
            c.libelle_court = 'les deux côtés'
    )t
ON(a.fid_voie_administrative = t.fid_voie_administrative AND a.fid_voie_physique = t.fid_voie_physique)
WHEN NOT MATCHED THEN
    INSERT(a.fid_voie_administrative, a.fid_voie_physique, a.fid_lateralite)
    VALUES(t.fid_voie_administrative, t.fid_voie_physique, t.fid_lateralite);
-- Résultat : 23 643 lignes fusionnées.

-- Insertion des voies administratives
MERGE INTO G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE a
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
            a.FID_TYPE_VOIE
        FROM
            G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE a
    )t
ON(a.objectid = t.objectid AND a.fid_type_voie = t.fid_type_voie)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.libelle_voie, a.complement_nom_voie, a.code_insee, a.fid_type_voie, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification)
    VALUES(t.objectid, t.libelle_voie, t.complement_nom_voie, t.code_insee, t.fid_type_voie, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification);
-- Résultat : 22 165 lignes fusionnées.

-- Insertion d'un seul point géométrique par groupe de seuils dans un rayon de 50cm max dans la table TEMP_H_SEUIL
INSERT INTO G_BASE_VOIE.TEMP_H_SEUIL(geom, fid_pnom_saisie, date_saisie, fid_pnom_modification, date_modification)
    SELECT
        a.ora_geometry,
        b.numero_agent AS fid_pnom_saisie,
        TO_DATE(sysdate, 'dd/mm/yy') AS date_saisie,
        b.numero_agent AS fid_pnom_modification,
        TO_DATE(sysdate, 'dd/mm/yy') AS date_modification
    FROM
        G_BASE_VOIE.TEMP_FUSION_SEUIL_2023 a,
        G_BASE_VOIE.TEMP_H_AGENT b
    WHERE
        b.pnom =  sys_context('USERENV','OS_USER');
        
--------------------------------------------------
-- Insertion des infos des seuils dans la table TEMP_H_INFOS_SEUIL
    INSERT INTO G_BASE_VOIE.TEMP_H_INFOS_SEUIL(objectid, numero_seuil, numero_parcelle, complement_numero_seuil, fid_seuil, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification)
    SELECT
        a.idseui,
        a.nuseui,
        CASE
            WHEN a.nparcelle IS NOT NULL THEN a.nparcelle
            WHEN a.nparcelle IS NULL THEN 'NR'
        END AS numero_parcelle,
        a.nsseui,
        b.objectid,
        a.cdtsseuil,
        a.cdtmseuil,
        c.numero_agent AS fid_pnom_saisie,
        c.numero_agent AS fid_pnom_modification
    FROM
        G_BASE_VOIE.TEMP_ILTASEU_2023 a,
        G_BASE_VOIE.TEMP_H_SEUIL b,
        G_BASE_VOIE.TEMP_H_AGENT c
    WHERE
        SDO_WITHIN_DISTANCE(b.geom, a.ora_geometry, 'DISTANCE=0.50') = 'TRUE'
        AND c.pnom = 'import_donnees';

-- Insertion des autres points géométriques des seuils dans TEMP_H_SEUIL  
    MERGE INTO G_BASE_VOIE.TEMP_H_SEUIL a
    USING(
        SELECT
            a.idseui,
            a.ora_geometry,
            a.cdtsseuil,
            a.cdtmseuil,
            b.numero_agent AS fid_pnom_saisie,
            b.numero_agent AS fid_pnom_modification,
            c.cdcote,
            d.objectid
        FROM
            G_BASE_VOIE.TEMP_ILTASEU_2023 a
            INNER JOIN G_BASE_VOIE.TEMP_ILTASIT_2023 c ON c.idseui = a.idseui
            INNER JOIN G_BASE_VOIE.TEMP_H_TRONCON d ON d.objectid = c.cnumtrc,
            G_BASE_VOIE.TEMP_H_AGENT b
        WHERE
            a.idseui NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_H_INFOS_SEUIL)
            AND b.pnom = 'import_donnees'                
    )t
    ON (a.temp_idseui = t.idseui)
    WHEN NOT MATCHED THEN
        INSERT(a.geom, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.temp_idseui, a.cote_troncon, a.fid_troncon)
        VALUES(t.ora_geometry, t.cdtsseuil, t.cdtmseuil, t.fid_pnom_saisie, t.fid_pnom_modification, t.idseui, t.cdcote, t.objectid);
-- Résultat : 351 449 lignes fusionnées

-- Import des infos des seuils dans TEMP_H_INFOS_SEUIL pour les seuils non-concernés par la fusion               
        INSERT INTO G_BASE_VOIE.TEMP_H_INFOS_SEUIL(objectid, numero_seuil, numero_parcelle, complement_numero_seuil, fid_seuil, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification)
        SELECT DISTINCT
            a.idseui,
            a.nuseui,
            CASE
                WHEN a.nparcelle IS NOT NULL THEN a.nparcelle
                WHEN a.nparcelle IS NULL THEN 'NR'
            END AS numero_parcelle,
            a.nsseui,
            b.objectid,
            a.cdtsseuil,
            a.cdtmseuil,
            c.numero_agent AS fid_pnom_saisie,
            c.numero_agent AS fid_pnom_modification
        FROM
            G_BASE_VOIE.TEMP_ILTASEU_2023 a
            INNER JOIN G_BASE_VOIE.TEMP_H_SEUIL b ON b.temp_idseui = a.idseui
            INNER JOIN G_BASE_VOIE.TEMP_ILTASIT_2023 d ON d.idseui = b.objectid
            INNER JOIN G_BASE_VOIE.TEMP_H_TRONCON e ON e.objectid = d.cnumtrc,
            G_BASE_VOIE.TEMP_H_AGENT c
        WHERE
            c.pnom = 'import_donnees';
-- Résultat : 303 321 lignes fusionnées

-- Insertion des infos des seuils restantes
MERGE INTO G_BASE_VOIE.TEMP_H_INFOS_SEUIL a
    USING(
        SELECT DISTINCT
            a.idseui AS objectid,
            a.nuseui AS numero_seuil,
            CASE
                WHEN a.nparcelle IS NOT NULL THEN a.nparcelle
                WHEN a.nparcelle IS NULL THEN 'NR'
            END AS numero_parcelle,
            a.nsseui AS complement_numero_seuil,
            d.objectid AS fid_seuil,
            a.cdtsseuil AS date_saisie,
            a.cdtmseuil AS date_modification,
            e.numero_agent AS fid_pnom_saisie,
            e.numero_agent AS fid_pnom_modification
        FROM
            G_BASE_VOIE.TEMP_ILTASEU_2023 a
            INNER JOIN G_BASE_VOIE.TEMP_ILTASIT_2023 b ON b.idseui = a.idseui
            INNER JOIN G_BASE_VOIE.TEMP_H_TRONCON c ON c.objectid = b.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_H_SEUIL d ON d.temp_idseui = a.idseui,
            G_BASE_VOIE.TEMP_H_AGENT e
        WHERE
            a.idseui NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_H_INFOS_SEUIL)
            AND e.pnom = 'import_donnees'
    )t
ON(a.objectid = t.objectid AND a.fid_seuil = t.fid_seuil)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.numero_seuil, a.numero_parcelle, a.complement_numero_seuil, a.fid_seuil, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification)
    VALUES(t.objectid, t.numero_seuil, t.numero_parcelle, t.complement_numero_seuil, t.fid_seuil, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification);
-- Résultat : 48 128 lignes fusionnées.
COMMIT;

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
    G_BASE_VOIE.TEMP_G_VOIE_PHYSIQUE;
-- 22944

-- Décompte des voies physiques dans la structure cible
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE;
-- 22944

-- Sélection du nombre de tronçons valides dans l'ancienne structure
SELECT 
    COUNT(DISTINCT objectid)
FROM
    G_BASE_VOIE.TEMP_F_TRONCON;
-- 50631

-- Sélection du nombre de tronçons dans TEMP_H_TRONCON
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_H_TRONCON;
-- 50631 tronçons

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Décompte du nombre de voies présentes dans la structure d'import
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_G_VOIE_ADMINISTRATIVE;
-- Résultat : 22165 voies

-- Décompte du nombre de voies présentes dans la structure cible
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE;
-- Résultat : 22165 libellés de voies
    
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Décompte des seuils dans la table d'import et les tables d'export
SELECT 
    'TEMP_ILTASEU_2023' AS source,
    COUNT(*) AS nbr
FROM
    TEMP_ILTASEU_2023
GROUP BY
    'TEMP_ILTASEU_2023' -- 352046
UNION ALL
SELECT 
    'TEMP_H_INFOS_SEUIL'  AS source,
    COUNT(*) AS nbr
FROM
    TEMP_H_INFOS_SEUIL
GROUP BY
    'TEMP_H_INFOS_SEUIL'-- 351468
UNION ALL
SELECT 
    'TEMP_H_SEUIL'  AS source,
    COUNT(*) AS nbr
FROM
    TEMP_H_SEUIL
GROUP BY
    'TEMP_H_SEUIL';-- 351459

-- Vérification que la géométrie des seuils correspond à leur identifiant entre les tables source et cible
-- méthode 1 :
SELECT
    a.idseui,
    b.objectid,
    b.temp_idseui
FROM
    G_BASE_VOIE.TEMP_ILTASEU_2023 a
    INNER JOIN G_BASE_VOIE.TEMP_H_SEUIL b ON b.temp_idseui = a.idseui
WHERE
    SDO_EQUAL(a.ora_geometry, b.geom) <> 'TRUE';

-- méthode 2
SELECT
    a.idseui,
    b.objectid,
    b.temp_idseui
FROM
    G_BASE_VOIE.TEMP_ILTASEU_2023 a
    INNER JOIN G_BASE_VOIE.TEMP_H_SEUIL b ON b.temp_idseui = a.idseui
WHERE
    a.ora_geometry.sdo_point.x <> b.geom.sdo_point.x
    AND a.ora_geometry.sdo_point.y <> b.geom.sdo_point.y;
-- Résultat : tout est bon
*/

