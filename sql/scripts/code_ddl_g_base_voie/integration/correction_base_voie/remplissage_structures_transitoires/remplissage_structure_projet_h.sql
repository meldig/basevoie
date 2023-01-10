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

-- Insertion des seuils
MERGE INTO G_BASE_VOIE.TEMP_H_SEUIL a
    USING(
        SELECT
            a.objectid,
            a.geom,
            a.cote_troncon,
            a.date_saisie,
            a.date_modification,
            a.fid_pnom_saisie,
            a.fid_pnom_modification,
            b.fid_troncon
        FROM
            G_BASE_VOIE.TA_SEUIL a
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL b ON b.fid_seuil = a.objectid
    )t
ON(a.objectid = t.objectid AND a.fid_troncon = t.fid_troncon)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.geom, a.cote_troncon, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.fid_troncon)
    VALUES(t.objectid, t.geom, t.cote_troncon, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification, t.fid_troncon);
-- Résultat : 

-- Insertion des informations des seuils
MERGE INTO G_BASE_VOIE.TEMP_H_INFOS_SEUIL a
    USING(
        SELECT
            a.objectid,
            a.numero_seuil,
            a.numero_parcelle,
            a.complement_numero_seuil,
            a.date_saisie,
            a.date_modification,
            a.fid_seuil,
            a.fid_pnom_saisie,
            a.fid_pnom_modification
        FROM
            G_BASE_VOIE.TA_INFOS_SEUIL a
    )t
ON(a.objectid = t.objectid AND a.fid_type_voie = t.fid_type_voie)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.numero_seuil, a.numero_parcelle, a.complement_numero_seuil, a.date_saisie, a.date_modification, a.fid_seuil, a.fid_pnom_saisie, a.fid_pnom_modification)
    VALUES(t.objectid, t.numero_seuil, t.numero_parcelle, t.complement_numero_seuil, t.date_saisie, t.date_modification, t.fid_seuil, t.fid_pnom_saisie, t.fid_pnom_modification);
COMMIT;
-- Résultat : 

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--------------------------------------------- Vérification import des données -------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
/*
-- Comparaison nombre de voies physiques dans la nouvelle structure et dans l'ancienne
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE;
-- 22112
-- Sélection du nombre de tronçons valides dans l'ancienne structure
SELECT 
    COUNT(DISTINCT a.cnumtrc)
FROM
    G_BASE_VOIE.TEMP_ILTATRC a
    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi
    INNER JOIN G_BASE_VOIE.TEMP_TYPEVOIE d ON d.ccodtvo = c.ccodtvo
WHERE
    a.cdvaltro = 'V'
    AND b.cvalide = 'V'
    AND c.cdvalvoi = 'V'
    AND d.lityvoie IS NOT NULL;
-- 49713
-- Sélection du nombre de tronçons dans TEMP_H_TRONCON
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_H_TRONCON;
-- 49721 tronçons
-- Sélection des tronçons valides de la nouvelle structure, mais absents de l'ancienne
SELECT
    objectid || ','
FROM
    G_BASE_VOIE.TEMP_H_TRONCON
WHERE
    objectid NOT IN(
        SELECT DISTINCT 
            CAST(a.cnumtrc AS NUMBER(38,0))
        FROM
            G_BASE_VOIE.TEMP_ILTATRC a
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi
            INNER JOIN G_BASE_VOIE.TEMP_TYPEVOIE d ON d.ccodtvo = c.ccodtvo
        WHERE
            a.cdvaltro = 'V'
            AND b.cvalide = 'V'
            AND c.cdvalvoi = 'V'
            AND d.lityvoie IS NOT NULL
    );
-- Sélection des tronçons de l'ancienne structure absents de la nouvelle structure
-- Sélection des tronçons valides de la nouvelle structure, mais absents de l'ancienne
SELECT DISTINCT 
    CAST(a.cnumtrc AS NUMBER(38,0))
FROM
    G_BASE_VOIE.TEMP_ILTATRC a
    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi
    INNER JOIN G_BASE_VOIE.TEMP_TYPEVOIE d ON d.ccodtvo = c.ccodtvo
WHERE
    a.cdvaltro = 'V'
    AND b.cvalide = 'V'
    AND c.cdvalvoi = 'V'
    AND d.lityvoie IS NOT NULL
    AND CAST(a.cnumtrc AS NUMBER(38,0)) NOT IN(
        SELECT
            objectid
        FROM
            G_BASE_VOIE.TEMP_H_TRONCON            
    );
-- Résultat : 0
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Décompte du nombre de voies présentes dans la structure d'import
SELECT
    COUNT(DISTINCT a.ccomvoi)
FROM
    TEMP_VOIEVOI a
    INNER JOIN TEMP_TYPEVOIE b ON b.ccodtvo = a.ccodtvo
    INNER JOIN TEMP_VOIECVT c ON c.ccomvoi = a.ccomvoi
WHERE
    b.lityvoie IS NOT NULL
    AND a.cdvalvoi = 'V'
    AND c.cvalide = 'V';
-- Résultat : 22165 voies
-- Décompte du nombre de libellés de voies
SELECT
    COUNT(objectid)
FROM
    TEMP_H_VOIE_ADMINISTRATIVE;
-- Résultat : 22165 libellés de voies
       
SELECT
    COUNT(DISTINCT a.ccomvoi)
FROM
    TEMP_VOIEVOI a
    INNER JOIN TEMP_TYPEVOIE b ON b.ccodtvo = a.ccodtvo
    INNER JOIN TEMP_VOIECVT c ON c.ccomvoi = a.ccomvoi
WHERE
    b.lityvoie IS NOT NULL
    AND a.cdvalvoi = 'V'
    AND c.cvalide = 'V'
    AND CAST(a.ccomvoi AS NUMBER(38,0))  NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE);
*/