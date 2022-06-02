-- Insertion des pnoms des agents
INSERT INTO G_BASE_VOIE.TEMP_A_AGENT(numero_agent, pnom, validite)
    SELECT numero_agent, pnom, validite FROM TEMP_AGENT;
-- Résultat : 5 lignes insérées.

-- Insertion des types de voie
MERGE INTO G_BASE_VOIE.TEMP_A_TYPE_VOIE a
    USING(
        SELECT
            CCODTVO AS code_type_voie,
            LITYVOIE AS libelle
        FROM
            G_BASE_VOIE.TEMP_TYPEVOIE
        WHERE
            LITYVOIE IS NOT NULL
    )t
    ON(a.code_type_voie = t.code_type_voie AND a.libelle = t.libelle)
WHEN NOT MATCHED THEN
    INSERT(a.code_type_voie, a.libelle)
    VALUES(t.code_type_voie, t.libelle);
-- Résultat : 57 lignes fusionnées.

-- Insertion des valeurs de latéralité des voies dans TEMP_A_LIBELLE
INSERT INTO G_BASE_VOIE.TEMP_A_LIBELLE(libelle_court, libelle_long)
SELECT
    'droit' AS libelle_court,
    'côté droit de la voie physique' AS libelle_long
FROM
    DUAL
UNION ALL
SELECT
    'gauche' AS libelle_court,
    'côté gauche de la voie physique' AS libelle_long
FROM
    DUAL
UNION ALL
SELECT
    'les deux côtés' AS libelle_court,
    'les deux côtés de la voie physique' AS libelle_long
FROM
    DUAL;
-- Résultat : 3 lignes fusionnées

-- Insertion des identifiants des voies dans TEMP_A_VOIE_PHYSIQUE
-- Insertion des voies physiques en doublons (pour chaque couple de doublon on n'insère qu'une seule voie
MERGE INTO G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE a
    USING(
        SELECT -- Pour les voies en doublon de géométrie, on ne garde que la voie disposant de l'identifiant minimum
            a.id_voie AS id_voie
        FROM
            G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a,
            G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE b 
        WHERE
            a.id_voie < b.id_voie
            AND SDO_EQUAL(a.geom, b.geom) = 'TRUE'
        -- Résultat : 53 voies
    )t
ON(a.objectid = t.id_voie)
WHEN NOT MATCHED THEN
    INSERT(a.objectid)
    VALUES(id_voie);
-- Résultat : 53 lignes fusionnées.

-- Insertion des voies physiques uniques
MERGE INTO G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE a
    USING(
        WITH
            C_1 AS(
                SELECT -- sélection de l'identifiant minimum pour chaque doublons de voies
                    a.id_voie AS id_voie
                FROM
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a,
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE b 
                WHERE
                    a.id_voie < b.id_voie
                    AND SDO_EQUAL(a.geom, b.geom) = 'TRUE'
                UNION ALL
                SELECT -- sélection de l'identifiant maximum pour chaque doublons de voies
                    b.id_voie AS id_voie
                FROM
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a,
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE b 
                WHERE
                    a.id_voie < b.id_voie
                    AND SDO_EQUAL(a.geom, b.geom) = 'TRUE'
                -- Résultat : 106 voies
            )
            
            SELECT
                id_voie
            FROM
                G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE
            WHERE
                id_voie NOT IN(SELECT id_voie FROM C_1)
    )t
ON(a.objectid = t.id_voie)
WHEN NOT MATCHED THEN
    INSERT(a.objectid)
    VALUES(id_voie);
-- Résultat : 22 052 lignes fusionnées.

-- Insertion des libellés des voies en doublons de géométrie
MERGE INTO G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE a
    USING(
        WITH
            C_1 AS(
                SELECT -- Pour les voies en doublon de géométrie, on ne garde que la voie disposant de l'identifiant minimum
                    a.id_voie AS id_voie,
                    a.geom
                FROM
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a,
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE b 
                WHERE
                    a.id_voie < b.id_voie
                    AND SDO_EQUAL(a.geom, b.geom) = 'TRUE'
            )
            
            SELECT DISTINCT
                a.id_voie AS objectid,
                b.cnominus AS libelle_voie,
                b.cinfos AS complement_nom_voie,
                a.code_insee,
                c.objectid AS fid_type_voie,
                d.id_voie AS fid_voie_physique,
                e.numero_agent AS fid_pnom_saisie,
                e.numero_agent AS fid_pnom_modification,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification
            FROM
                G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a
                INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccomvoi = a.id_voie
                INNER JOIN G_BASE_VOIE.TEMP_A_TYPE_VOIE c ON c.code_type_voie = b.ccodtvo,
                C_1 d,
                G_BASE_VOIE.TEMP_A_AGENT e
            WHERE
                SDO_EQUAL(a.geom, d.geom) = 'TRUE'
                AND e.pnom = 'import_donnees'
    )t
ON(a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique AND a.fid_type_voie = t.fid_type_voie)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.libelle_voie, a.complement_nom_voie, a.code_insee, a.fid_type_voie, a.fid_voie_physique, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification)
    VALUES(t.objectid, t.libelle_voie, t.complement_nom_voie, t.code_insee, t.fid_type_voie, t.fid_voie_physique, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification);
COMMIT;
-- Résultat : 106 lignes fusionnées.

-- Insertion des voies pour lesquelles un tronçon est affecté à une voie
MERGE INTO G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE a
    USING (
        WITH
            C_1 AS (-- Sélection des tronçons affectés à une et une seule voie
                SELECT
                    a.cnumtrc
                FROM
                    G_BASE_VOIE.TEMP_VOIECVT a
                    INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.cnumtrc
                    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = a.ccomvoi
                WHERE
                    a.cvalide = 'V'
                    AND b.cdvaltro = 'V'
                    AND c.cdvalvoi = 'V'
                GROUP BY
                    a.cnumtrc
                HAVING
                    COUNT(a.cnumtrc) = 1
            )
            
            SELECT DISTINCT -- Sélection de toutes les libellés des voies auxquelles un tronçon est affecté une et une seule fois
                c.ccomvoi AS objectid,
                c.cnominus AS libelle_voie,
                c.cinfos AS complement_nom_voie,
                CASE
                        WHEN LENGTH(b.cnumcom) = 1
                            THEN '5900' || b.cnumcom
                        WHEN LENGTH(b.cnumcom) = 2
                            THEN '590' || b.cnumcom
                        WHEN LENGTH(b.cnumcom) = 3
                            THEN '59' || b.cnumcom
                    END AS code_insee,
                f.objectid AS fid_lateralite,
                e.objectid AS fid_type_voie,
                d.objectid AS fid_voie_physique,
                d.numero_agent AS fid_pnom_saisie,
                d.numero_agent AS fid_pnom_modification,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification
            FROM
                C_1 a
                INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
                INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi
                INNER JOIN G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE d ON d.objectid = c.ccomvoi
                INNER JOIN G_BASE_VOIE.TEMP_A_TYPE_VOIE e ON e.code_type_voie = c.ccodtvo,
                G_BASE_VOIE.TEMP_A_AGENT d,
                G_BASE_VOIE.TEMP_A_libelle f
            WHERE
                b.cvalide = 'V'
                AND c.cdvalvoi = 'V'
                AND d.pnom = 'import_donnees'
                AND f.libelle_court = 'les deux côtés'
    )t
ON(a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique AND a.fid_type_voie = t.fid_type_voie)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.libelle_voie, a.complement_nom_voie, a.code_insee, a.fid_lateralite, a.fid_type_voie, a.fid_voie_physique, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification)
    VALUES(t.objectid, t.libelle_voie, t.complement_nom_voie, t.code_insee, t.fid_lateralite, t.fid_type_voie, t.fid_voie_physique, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification);
COMMIT;        
-- Résultat : 21 859 lignes fusionnées.

-- Insertion des voies restantes, c'est-à-dire des voies disposant de tronçons affectés à plusieurs voie dont la géométrie n'est pas identique
MERGE INTO G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE a
    USING (
        SELECT
            a.id_voie AS objectid,
            b.cnominus AS libelle_voie,
            b.cinfos AS complement_nom_voie,
            a.code_insee,
            c.objectid AS fid_type_voie,
            a.id_voie AS fid_voie_physique,
            d.numero_agent AS fid_pnom_saisie,
            d.numero_agent AS fid_pnom_modification,
            TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
            TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification
        FROM
            G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccomvoi = a.id_voie
            INNER JOIN G_BASE_VOIE.TEMP_A_TYPE_VOIE c ON c.code_type_voie = b.ccodtvo,
            G_BASE_VOIE.TEMP_A_AGENT d
        WHERE
            a.id_voie NOT IN(SELECT objectid FROM TEMP_A_VOIE_ADMINISTRATIVE)
            AND d.pnom = 'import_donnees'
    )t
ON(a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique AND a.fid_type_voie = t.fid_type_voie)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.libelle_voie, a.complement_nom_voie, a.code_insee, a.fid_type_voie, a.fid_voie_physique, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification)
    VALUES(t.objectid, t.libelle_voie, t.complement_nom_voie, t.code_insee, t.fid_type_voie, t.fid_voie_physique, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification);
COMMIT;
-- Résultat : 193 lignes fusionnées.

-- Insertion des tronçons affectés à une et une seule voie
MERGE INTO G_BASE_VOIE.TEMP_A_TRONCON a
    USING (
        WITH
            C_1 AS(
                SELECT -- Sélection des tronçons affectés à une et une seule voie
                    a.cnumtrc AS objectid            
                FROM
                    G_BASE_VOIE.TEMP_ILTATRC a
                    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
                WHERE
                    a.cdvaltro = 'V'
                    AND b.cvalide = 'V'
                GROUP BY
                    a.cnumtrc
                HAVING
                    COUNT(a.cnumtrc) = 1
            )

        SELECT
            a.objectid,
            b.ora_geometry AS geom,
            TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
            e.numero_agent AS fid_pnom_saisie,
            TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification,
            e.numero_agent AS fid_pnom_modification,
            d.objectid AS fid_voie_physique
        FROM
            C_1 a
            INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT c ON c.cnumtrc = b.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE d ON d.objectid = c.ccomvoi,
            G_BASE_VOIE.TEMP_A_AGENT e
        WHERE
            e.pnom = 'import_donnees'
    )t
ON(a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique)
WHEN NOT MATCHED THEN
INSERT(a.objectid, a.geom, a.date_saisie, a.fid_pnom_saisie, a.date_modification, a.fid_pnom_modification, a.fid_voie_physique)
VALUES(t.objectid, t.geom, t.date_saisie, t.fid_pnom_saisie, t.date_modification, t.fid_pnom_modification, t.fid_voie_physique);
-- Résultat : 49 431 lignes fusionnées.

-- Insertion des tronçons affectés à plusieurs voies ayant la même géométrie
MERGE INTO G_BASE_VOIE.TEMP_A_TRONCON a
    USING(
        WITH
            C_1 AS(
                SELECT -- Pour les voies en doublon de géométrie, on ne garde que la voie disposant de l'identifiant minimum
                    a.id_voie AS id_voie,
                    a.geom
                FROM
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a,
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE b 
                WHERE
                    a.id_voie < b.id_voie
                    AND SDO_EQUAL(a.geom, b.geom) = 'TRUE'
            ),
            
            C_2 AS(
                SELECT DISTINCT
                    c.cnumtrc AS objectid,
                    d.id_voie AS fid_voie_physique,
                    e.numero_agent AS fid_pnom_saisie,
                    e.numero_agent AS fid_pnom_modification,
                    TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
                    TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification
                FROM
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a
                    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.ccomvoi = a.id_voie
                    INNER JOIN G_BASE_VOIE.TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc,
                    C_1 d,
                    G_BASE_VOIE.TEMP_A_AGENT e
                WHERE
                    c.cdvaltro = 'V'
                    AND b.cvalide = 'V'
                    AND e.pnom = 'import_donnees'
                    AND SDO_EQUAL(a.geom, d.geom) = 'TRUE'
            )
            
            SELECT
                a.*,
                b.ora_geometry AS geom
            FROM
                C_2 a
                INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid
            WHERE
                b.cdvaltro = 'V'
    )t
ON(a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.geom, a.date_saisie, a.fid_pnom_saisie, a.date_modification, a.fid_pnom_modification, a.fid_voie_physique)
    VALUES(t.objectid, t.geom, t.date_saisie, t.fid_pnom_saisie, t.date_modification, t.fid_pnom_modification, t.fid_voie_physique);
COMMIT;
-- Résultat : 166 lignes fusionnées.

-- Insertion des tronçons affectés à plusieurs voies de tailles différentes
MERGE INTO G_BASE_VOIE.TEMP_A_TRONCON a
    USING(
        WITH
            C_1 AS(
                SELECT -- Sélection des tronçons affectés à plusieurs voies
                    a.cnumtrc AS objectid            
                FROM
                    G_BASE_VOIE.TEMP_ILTATRC a
                    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
                WHERE
                    a.cdvaltro = 'V'
                    AND b.cvalide = 'V'
                GROUP BY
                    a.cnumtrc
                HAVING
                    COUNT(a.cnumtrc) > 1
            ),
            
            C_2 AS(
                SELECT -- Sélection des id des voies en doublon de géométrie
                    a.id_voie AS id_voie_min,
                    b.id_voie AS id_voie_max, 
                    a.geom
                FROM
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a,
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE b 
                WHERE
                    a.id_voie < b.id_voie
                    AND SDO_EQUAL(a.geom, b.geom) = 'TRUE'
            ),
            
            C_3 AS(
                SELECT
                    id_voie_min AS id_voie
                FROM
                    C_2
                UNION ALL
                SELECT
                    id_voie_max AS id_voie
                FROM
                    C_2
            )
        
            SELECT
                a.objectid,
                c.ccodstr AS sens,
                b.ora_geometry AS geom,
                g.objectid AS fid_voie_physique,
                f.numero_agent AS fid_pnom_saisie,
                f.numero_agent AS fid_pnom_modification,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification
            FROM
                C_1 a
                INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid
                INNER JOIN G_BASE_VOIE.TEMP_VOIECVT c ON c.cnumtrc = b.cnumtrc
                INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI d ON d.ccomvoi = c.ccomvoi
                INNER JOIN G_BASE_VOIE.TEMP_TYPEVOIE e ON e.ccodtvo = d.ccodtvo
                INNER JOIN G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE f ON f.objectid = d.ccomvoi
                INNER JOIN G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE g ON g.objectid = f.fid_voie_physique,
                G_BASE_VOIE.TEMP_A_AGENT f
            WHERE
                b.cdvaltro = 'V'
                AND c.cvalide = 'V'
                AND d.cdvalvoi = 'V'
                AND f.pnom = 'import_donnees'
                AND e.lityvoie IS NOT NULL
                AND d.ccomvoi NOT IN(SELECT id_voie FROM C_3)
        )t
ON(a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.geom, a.date_saisie, a.fid_pnom_saisie, a.date_modification, a.fid_pnom_modification, a.fid_voie_physique)
    VALUES(t.objectid, t.geom, t.date_saisie, t.fid_pnom_saisie, t.date_modification, t.fid_pnom_modification, t.fid_voie_physique);
COMMIT;
-- Résultat : 1 686 lignes fusionnées.

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--------------------------------------------- Vérification import des données ------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
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
-- Résultat : 22158 voies

-- Décompte du nombre de libellés de voies
SELECT
    COUNT(objectid)
FROM
    TEMP_A_VOIE_ADMINISTRATIVE;
-- Résultat : 22158 libellés de voies

-- Décompte du nombre de voies présentes dans TEMP_A_TRONCON.FID_VOIE. Ces voies correspondent à celles pour lesquelles un tronçon affecté à une et une seule voie
SELECT
    COUNT(DISTINCT fid_voie_physique)
FROM
    G_BASE_VOIE.TEMP_A_TRONCON;
-- Résultat : 21860 voies distinctes (1 de plus ?)

-- Décompte du nombre de tronçons associés à plusieurs voies ayant la même géométrie
WITH
    C_1 AS(
        SELECT -- Pour les voies en doublon de géométrie, on ne garde que la voie disposant de l'identifiant minimum
            a.id_voie AS id_voie,
            a.geom
        FROM
            G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a,
            G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE b 
        WHERE
            a.id_voie < b.id_voie
            AND SDO_EQUAL(a.geom, b.geom) = 'TRUE'
    )
    
    SELECT
        COUNT(DISTINCT c.cnumtrc)
    FROM
        G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a
        INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.ccomvoi = a.id_voie
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc,
        C_1 d
    WHERE
        b.cvalide = 'V'
        AND c.cdvaltro = 'V'
        AND SDO_EQUAL(a.geom, d.geom) = 'TRUE';
-- Résultat : 166 tronçons

-- Décompte du nombre de tronçons valides affectés à des voies valides dans l'ancienne structure
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
-- Résultat : 49 692 tronçons

-- Décompte du nombre de tronçons dans la nouvelle structure
SELECT
    COUNT(objectid)
FROM
    TEMP_A_TRONCON;
-- Résultat : 51283 tronçons

SELECT
    a.*
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
    AND a.cnumtrc NOT IN(SELECT objectid FROM TEMP_A_TRONCON)
ORDER BY
    a.cnumtrc;
    
SELECT objectid
FROM
    TEMP_A_TRONCON
GROUP BY
    objectid
HAVING
    COUNT(objectid) > 1;
    
MERGE INTO G_BASE_VOIE.TEMP_A_TRONCON a
    USING(
        WITH
            C_1 AS(-- Sélection des tronçons pas encore insérés dans les tables de transition
                SELECT
                    a.*,
                    b.ccodstr,
                    c.ccomvoi
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
                    AND a.cnumtrc NOT IN(SELECT objectid FROM TEMP_A_TRONCON)
            )
            
            SELECT
                a.cnumtrc AS objectid,
                a.ccodstr AS sens,
                c.objectid AS fid_voie_physique,
                b.objectid AS id_voie_administrative,
                d.numero_agent AS fid_pnom_saisie,
                d.numero_agent AS fid_pnom_modification,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification,
                a.ora_geometry AS geom
            FROM
                C_1 a
                INNER JOIN G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE b ON b.objectid = a.ccomvoi
                INNER JOIN G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE c ON c.objectid = b.fid_voie_physique,
                G_BASE_VOIE.TEMP_A_AGENT d
    )t
ON(a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique)
WHEN NOT MATCHED THEN
INSERT(a.objectid, a.geom, a.date_saisie, a.fid_pnom_saisie, a.date_modification, a.fid_pnom_modification, a.fid_voie_physique)
VALUES(t.objectid, t.geom, t.date_saisie, t.fid_pnom_saisie, t.date_modification, t.fid_pnom_modification, t.fid_voie_physique);
        