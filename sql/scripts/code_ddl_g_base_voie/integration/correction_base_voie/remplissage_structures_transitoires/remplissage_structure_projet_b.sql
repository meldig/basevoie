-- Insertion des pnoms des agents
INSERT INTO G_BASE_VOIE.TEMP_B_AGENT(numero_agent, pnom, validite)
    SELECT numero_agent, pnom, validite FROM TEMP_AGENT;
-- Résultat : 5 lignes insérées.

-- Insertion des types de voie
MERGE INTO G_BASE_VOIE.TEMP_B_TYPE_VOIE a
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

-- Insertion des valeurs de latéralité des voies dans TEMP_B_LIBELLE
INSERT INTO G_BASE_VOIE.TEMP_B_LIBELLE(libelle_court, libelle_long)
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
    DUAL
UNION ALL
SELECT
    'erreur non-jointif' AS libelle_court,
    'tronçon en erreur car non-jointif avec les tronçons adjacents' AS libelle_long
FROM
    DUAL
UNION ALL
SELECT
    'erreur intersection' AS libelle_court,
    'tronçon en erreur car intersectant un tronçon en-dehors des start/end points.' AS libelle_long
FROM
    DUAL
UNION ALL
SELECT
    'corrigé' AS libelle_court,
    'entité en erreur qui a été corrigé' AS libelle_long
FROM
    DUAL
UNION ALL
SELECT
    'nouvelle entité' AS libelle_court,
    'nouvelle entité créée lors des corrections topologiques' AS libelle_long
FROM
    DUAL;
-- Résultat : 3 lignes fusionnées

-- Insertion des identifiants des voies dans TEMP_B_VOIE_PHYSIQUE
-- Insertion des voies physiques en doublons (pour chaque couple de doublon on n'insère qu'une seule voie
MERGE INTO G_BASE_VOIE.TEMP_B_VOIE_PHYSIQUE a
    USING(
        SELECT -- Pour les voies en doublon de géométrie, on ne garde que la voie disposant de l'identifiant minimum
            CAST(a.id_voie AS NUMBER(38,0)) AS id_voie
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

-- Insertion des libellés des voies en doublons de géométrie
MERGE INTO G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE a
    USING(
        SELECT
            OBJECTID,
            GENRE_VOIE,
            LIBELLE_VOIE,
            COMPLEMENT_NOM_VOIE,
            FID_LATERALITE,
            CODE_INSEE,
            DATE_SAISIE,
            DATE_MODIFICATION,
            FID_PNOM_SAISIE,
            FID_PNOM_MODIFICATION,
            FID_VOIE_PHYSIQUE,
            FID_TYPE_VOIE
        FROM
            G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE
    )t
ON(a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique AND a.fid_type_voie = t.fid_type_voie)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.libelle_voie, a.complement_nom_voie, a.code_insee, a.fid_type_voie, a.fid_voie_physique, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.fid_lateralite)
    VALUES(t.objectid, t.libelle_voie, t.complement_nom_voie, t.code_insee, t.fid_type_voie, t.fid_voie_physique, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification, t.fid_lateralite);
COMMIT;
-- Résultat : 106 lignes fusionnées.

-- Insertion des autres voies physiques
MERGE INTO G_BASE_VOIE.TEMP_B_VOIE_PHYSIQUE a
    USING (
        SELECT DISTINCT
             d.ccomvoi AS objectid
        FROM
            G_BASE_VOIE.TEMP_ILTATRC b
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT c ON c.cnumtrc = b.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI d ON d.ccomvoi = c.ccomvoi
            INNER JOIN G_BASE_VOIE.TEMP_TYPEVOIE e ON e.ccodtvo = d.ccodtvo
        WHERE
            b.cdvaltro = 'V'
            AND c.cvalide = 'V'
            AND cdvalvoi = 'V'
            AND e.lityvoie IS NOT NULL
            AND CAST(d.ccomvoi AS NUMBER(38,0)) NOT IN (SELECT objectid FROM G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE)
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
INSERT(a.objectid)
VALUES(t.objectid);
-- Résultat : 22 059 voies fusionnées

-- Insertion des voies à la géométrie unique et pour lesquelles un tronçon lui est spécifiquement attribué
MERGE INTO G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE a
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
                CAST(c.ccomvoi AS NUMBER(38,0)) AS objectid,
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
                CAST(d.objectid AS NUMBER(38,0)) AS fid_voie_physique,
                d.numero_agent AS fid_pnom_saisie,
                d.numero_agent AS fid_pnom_modification,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification
            FROM
                C_1 a
                INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
                INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi
                INNER JOIN G_BASE_VOIE.TEMP_B_VOIE_PHYSIQUE d ON d.objectid = CAST(c.ccomvoi AS NUMBER(38,0))
                INNER JOIN G_BASE_VOIE.TEMP_B_TYPE_VOIE e ON e.code_type_voie = c.ccodtvo,
                G_BASE_VOIE.TEMP_B_AGENT d,
                G_BASE_VOIE.TEMP_B_libelle f
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
-- Résultat : 21 867 lignes fusionnées.
    
-- Insertion des tronçons affectés à plusieurs voies administratives de même géométrie
MERGE INTO G_BASE_VOIE.TEMP_B_TRONCON a
    USING(
        SELECT *
        FROM
            G_BASE_VOIE.TEMP_A_TRONCON
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.geom, a.date_saisie, a.fid_pnom_saisie, a.date_modification, a.fid_pnom_modification)
    VALUES(t.objectid, t.geom, t.date_saisie, t.fid_pnom_saisie, t.date_modification, t.fid_pnom_modification);
COMMIT;
-- Résultat : 166 lignes fusionnées

-- Insertion des liens tronçon/voie physique pour les tronçons affectés à plusieurs voies administratives de même géométrie
MERGE INTO G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE a
    USING(
        SELECT
            objectid AS fid_troncon,
            fid_voie_physique,
            sens
        FROM
            G_BASE_VOIE.TEMP_A_TRONCON
    )t
ON(a.fid_troncon = t.fid_troncon AND a.fid_voie_physique = t.fid_voie_physique)
WHEN NOT MATCHED THEN
    INSERT(a.fid_troncon, a.fid_voie_physique, a.sens)
    VALUES(t.fid_troncon, t.fid_voie_physique, t.sens);
COMMIT;
-- Résultat : 166 lignes mises à jour

-- Insertion des tronçons affectés à une et une seule voie
MERGE INTO G_BASE_VOIE.TEMP_B_TRONCON a
    USING (
        WITH
            C_1 AS(
                SELECT -- Sélection des tronçons affectés à une et une seule voie
                    a.cnumtrc AS objectid            
                FROM
                    G_BASE_VOIE.TEMP_ILTATRC a
                    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
                    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi
                WHERE
                    a.cdvaltro = 'V'
                    AND b.cvalide = 'V'
                    AND c.cdvalvoi = 'V'
                GROUP BY
                    a.cnumtrc
                HAVING
                    COUNT(a.cnumtrc) = 1
            )

        SELECT
            CAST(a.objectid AS NUMBER(38,0)) AS objectid,
            b.ora_geometry AS geom,
            TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
            e.numero_agent AS fid_pnom_saisie,
            TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification,
            e.numero_agent AS fid_pnom_modification
        FROM
            C_1 a
            INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT c ON c.cnumtrc = b.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI d ON d.ccomvoi = c.ccomvoi,
            G_BASE_VOIE.TEMP_B_AGENT e
        WHERE
            e.pnom = 'import_donnees'
            AND b.cdvaltro = 'V'
            AND c.cvalide = 'V'
            AND cdvalvoi = 'V'
            AND CAST(b.cnumtrc AS NUMBER(38,0)) NOT IN (SELECT objectid FROM G_BASE_VOIE.TEMP_B_TRONCON)
            AND b.cnumtrc NOT IN(169,201,202,203,204,226,231,233,236,237,239,243,246,247,251,258,259,262,263,282,294,312,313,327)
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
INSERT(a.objectid, a.geom, a.date_saisie, a.fid_pnom_saisie, a.date_modification, a.fid_pnom_modification)
VALUES(t.objectid, t.geom, t.date_saisie, t.fid_pnom_saisie, t.date_modification, t.fid_pnom_modification);
-- Résultat : 48 576 lignes fusionnées.

-- Insertion des tronçons affectés à plusieurs voies de taille différente
MERGE INTO G_BASE_VOIE.TEMP_B_TRONCON a
    USING (
         WITH
            C_1 AS(
                SELECT DISTINCT 
                    a.cnumtrc
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
                    AND CAST(a.cnumtrc AS NUMBER(38,0)) NOT IN (SELECT objectid FROM G_BASE_VOIE.TEMP_B_TRONCON)
                    AND a.cnumtrc NOT IN(169,201,202,203,204,226,231,233,236,237,239,243,246,247,251,258,259,262,263,282,294,312,313,327)
            )
         
         SELECT
            CAST(a.cnumtrc AS NUMBER(38,0)) AS objectid,
            a.ora_geometry AS geom,
            TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
            g.numero_agent AS fid_pnom_saisie,
            TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification,
            g.numero_agent AS fid_pnom_modification
        FROM
            C_1 z
            INNER JOIN G_BASE_VOIE.TEMP_ILTATRC a ON a.cnumtrc = z.cnumtrc,
            G_BASE_VOIE.TEMP_B_AGENT g
        WHERE
            a.cdvaltro = 'V'
            AND g.pnom = 'import_donnees'
            AND CAST(a.cnumtrc AS NUMBER(38,0)) NOT IN(SELECT objectid FROM TEMP_B_TRONCON)
            AND a.cnumtrc NOT IN(169,201,202,203,204,226,231,233,236,237,239,243,246,247,251,258,259,262,263,282,294,312,313,327)
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.geom, a.date_saisie, a.fid_pnom_saisie, a.date_modification, a.fid_pnom_modification)
    VALUES(t.objectid, t.geom, t.date_saisie, t.fid_pnom_saisie, t.date_modification, t.fid_pnom_modification);
-- Résultat : 1003 tronçons fusionnés

-- Insertion des liens tronçon/voie physique pour les tronçons affectés à plusieurs voies administratives de taille différente
MERGE INTO G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE a
    USING (
         WITH
            C_1 AS(
                SELECT DISTINCT 
                    a.cnumtrc
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
                    AND CAST(a.cnumtrc AS NUMBER(38,0)) NOT IN (SELECT fid_troncon FROM G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE)
            )
         
         SELECT
            CAST(a.cnumtrc AS NUMBER(38,0)) AS fid_troncon,
            CAST(b.ccomvoi AS NUMBER(38,0)) AS fid_voie_physique,
            b.ccodstr AS sens
        FROM
            C_1 a
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
        WHERE
            b.cvalide = 'V'
            AND CAST(a.cnumtrc AS NUMBER(38,0)) NOT IN(SELECT fid_troncon FROM TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE)
            AND CAST(b.ccomvoi AS NUMBER(38,0)) IN (SELECT objectid FROM G_BASE_VOIE.TEMP_B_VOIE_PHYSIQUE)
    )t
ON(a.fid_troncon = t.fid_troncon AND a.fid_voie_physique = t.fid_voie_physique)
WHEN NOT MATCHED THEN
    INSERT(a.fid_troncon, a.fid_voie_physique, a.sens)
    VALUES(t.fid_troncon, t.fid_voie_physique, t.sens);
-- Résultat : 1 840 lignes fusionnées.

-- Insertion des voies administratives composées de tronçons affectés à plusieurs voies, mais dont la géométrie des voies est différente et n'étant pas encore dans TEMP_B_VOIE_ADMINISTRATIVE
MERGE INTO G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE a
    USING( 
        WITH
            C_1 AS(-- Sélection des tronçons affectés à plusieurs voies
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
                    COUNT(a.cnumtrc) > 1
            ),
            
            C_2 AS(-- Sélection des voies auxquelles sont affectés les tronçons identifés en C_1 et dont la longueur en différente
            SELECT DISTINCT
                c.ccomvoi AS objectid,
                c.cnominus AS libelle_voie,
                c.cinfos AS complement_nom_voie,
                d.code_insee,               
                e.objectid AS fid_type_voie,
                c.ccomvoi AS fid_voie_physique,
                g.objectid AS fid_lateralite,
                f.numero_agent AS fid_pnom_saisie,
                f.numero_agent AS fid_pnom_modification,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification
            FROM
                C_1 a
                INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
                INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON CAST(c.ccomvoi AS NUMBER(38,0)) = b.ccomvoi
                INNER JOIN G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE d ON d.id_voie = c.ccomvoi
                INNER JOIN G_BASE_VOIE.TEMP_A_TYPE_VOIE e ON e.code_type_voie = c.ccodtvo,
                G_BASE_VOIE.TEMP_B_AGENT f,
                G_BASE_VOIE.TEMP_B_LIBELLE g
            WHERE
                b.cvalide = 'V'
                AND c.cdvalvoi = 'V'
                AND  f.pnom = 'import_donnees'
                AND g.libelle_court = 'les deux côtés'
                AND CAST(c.ccomvoi AS NUMBER(38,0)) NOT IN(SELECT id_voie FROM G_BASE_VOIE.VM_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE)
        )
        
        SELECT
            a.*
        FROM
            C_2 a
        WHERE
            a.objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE)
    )t
ON(a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique AND a.fid_type_voie = t.fid_type_voie)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.libelle_voie, a.complement_nom_voie, a.code_insee, a.fid_lateralite, a.fid_type_voie, a.fid_voie_physique, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification)
    VALUES(t.objectid, t.libelle_voie, t.complement_nom_voie, t.code_insee, t.fid_lateralite, t.fid_type_voie, t.fid_voie_physique, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification);      
-- Résultat : 192 lignes fusionnées.

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
    G_BASE_VOIE.TEMP_B_VOIE_PHYSIQUE;
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

-- Sélection du nombre de tronçons dans TEMP_B_TRONCON
SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TEMP_B_TRONCON;
-- 49721 tronçons

-- Sélection des tronçons valides de la nouvelle structure, mais absents de l'ancienne
SELECT
    objectid || ','
FROM
    G_BASE_VOIE.TEMP_B_TRONCON
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
            G_BASE_VOIE.TEMP_B_TRONCON            
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
    TEMP_B_VOIE_ADMINISTRATIVE;
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
    AND CAST(a.ccomvoi AS NUMBER(38,0))  NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE);
*/