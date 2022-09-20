-- Insertion des pnoms des agents
INSERT INTO G_BASE_VOIE.TEMP_C_AGENT(numero_agent, pnom, validite)
    SELECT numero_agent, pnom, validite FROM TEMP_B_AGENT;
-- Résultat : 5 lignes insérées.

-- Insertion des types de voie
MERGE INTO G_BASE_VOIE.TEMP_C_TYPE_VOIE a
    USING(
        SELECT
            objectid,
            code_type_voie,
            libelle
        FROM
            G_BASE_VOIE.TEMP_B_TYPE_VOIE
    )t
    ON(a.code_type_voie = t.code_type_voie AND a.libelle = t.libelle)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.code_type_voie, a.libelle)
    VALUES(t.objectid, t.code_type_voie, t.libelle);
-- Résultat : 57 lignes fusionnées.

-- Insertion des valeurs de latéralité des voies dans TEMP_C_LIBELLE
INSERT INTO G_BASE_VOIE.TEMP_C_LIBELLE(objectid, libelle_court, libelle_long)
SELECT
    objectid,
    libelle_court,
    libelle_long
FROM
    G_BASE_VOIE.TEMP_B_LIBELLE
WHERE
    libelle_court IN('droit', 'gauche', 'les deux côtés');
-- Résultat : 3 lignes fusionnées

-- Insertion des relations tronçons / voies physiques pour lesquelles un tronçon est affecté à plusieurs voies physiques
MERGE INTO G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE a
    USING(
        WITH
            C_1 AS(-- Sélection des tronçons affectés à plusieurs voies physiques
                SELECT
                    fid_troncon
                FROM
                    G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE
                GROUP BY
                    fid_troncon
                HAVING
                    COUNT(fid_troncon) > 1
            ),

            C_2 AS(-- sélection des voies physiques dont, plusieurs d'entre elles, sont affectées au même tronçon
                SELECT
                    a.fid_voie_physique
                FROM
                    G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE a
                    INNER JOIN C_1 b ON b.fid_troncon = a.fid_troncon
            )
            
            SELECT DISTINCT -- sélection de toutes les entités de la table TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE
                a.*
            FROM
                G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE a
                INNER JOIN C_2 b ON b.fid_voie_physique = a.fid_voie_physique
    )t
ON(a.fid_voie_physique = t.fid_voie_physique AND a.fid_troncon = t.fid_troncon)
WHEN NOT MATCHED THEN
    INSERT(a.fid_voie_physique, a.fid_troncon)
    VALUES(t.fid_voie_physique, t.fid_troncon);
-- Résultat : 3 808 lignes fusionnées

-- Insertion des tronçons
MERGE INTO G_BASE_VOIE.TEMP_C_TRONCON a
    USING(
        SELECT
            a.objectid, 
            a.geom, 
            a.date_saisie, 
            a.date_modification, 
            a.fid_pnom_saisie, 
            a.fid_pnom_modification
        FROM
          G_BASE_VOIE.TEMP_B_TRONCON a
          INNER JOIN (SELECT DISTINCT fid_troncon FROM G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE) b ON b.fid_troncon = a.objectid
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.geom, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification)
    VALUES(t.objectid, t.geom, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification);
-- Résultat :  2 971 lignes fusionnées.

-- Insertion des voies physiques
MERGE INTO G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE a
    USING(
        SELECT DISTINCT
            a.objectid
        FROM
          G_BASE_VOIE.TEMP_B_VOIE_PHYSIQUE a
          INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE b ON b.fid_voie_physique = a.objectid
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid)
    VALUES(t.objectid);
-- Résultat : 602  lignes fusionnées.

-- Insertion des relations voies physiques / voies administratives
MERGE INTO G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
    USING(
        SELECT
            a.objectid AS fid_voie_administrative,
            a.fid_voie_physique
        FROM
            G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE a
            INNER JOIN G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
    )t
ON(a.fid_voie_administrative = t.fid_voie_administrative AND a.fid_voie_physique = t.fid_voie_physique)
WHEN NOT MATCHED THEN
    INSERT(a.fid_voie_administrative, a.fid_voie_physique)
    VALUES(t.fid_voie_administrative, t.fid_voie_physique);
-- Résultat : 602 lignes fusionnées.

-- Insertion des voies administratives
MERGE INTO G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE a
    USING(
        SELECT
            a.OBJECTID,
            a.GENRE_VOIE,
            a.LIBELLE_VOIE,
            a.COMPLEMENT_NOM_VOIE,
            a.FID_LATERALITE,
            a.CODE_INSEE,
            a.DATE_SAISIE,
            a.DATE_MODIFICATION,
            a.FID_PNOM_SAISIE,
            a.FID_PNOM_MODIFICATION,
            a.FID_TYPE_VOIE
        FROM
            G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE a
            INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE b ON b.fid_voie_administrative = a.objectid
    )t
ON(a.objectid = t.objectid AND a.fid_type_voie = t.fid_type_voie)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.libelle_voie, a.complement_nom_voie, a.code_insee, a.fid_type_voie, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.fid_lateralite)
    VALUES(t.objectid, t.libelle_voie, t.complement_nom_voie, t.code_insee, t.fid_type_voie, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification, t.fid_lateralite);
COMMIT;
-- Résultat : 602 lignes fusionnées.

-- Insertion des 

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
    G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE;
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
-- Sélection du nombre de tronçons dans TEMP_C_TRONCON
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_C_TRONCON;
-- 49721 tronçons
-- Sélection des tronçons valides de la nouvelle structure, mais absents de l'ancienne
SELECT
    objectid || ','
FROM
    G_BASE_VOIE.TEMP_C_TRONCON
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
            G_BASE_VOIE.TEMP_C_TRONCON            
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
    TEMP_C_VOIE_ADMINISTRATIVE;
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
    AND CAST(a.ccomvoi AS NUMBER(38,0))  NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE);
*/
