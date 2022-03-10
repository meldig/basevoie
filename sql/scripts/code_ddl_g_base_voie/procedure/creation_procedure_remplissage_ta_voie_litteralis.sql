create or replace Procedure REMPLISSAGE_TA_VOIE_LITTERALIS
    IS
    BEGIN
        SAVEPOINT POINT_SAUVERGARDE_REMPLISSAGE_TA_VOIE_LITTERALIS;

        /*
        L'objectif de cette procédure est de corriger dans la table de travail G_BASE_VOIE.TA_VOIE_LITTERALIS(duplicata de G_BASE_VOIE.TA_VOIE avec contraintes, etc) les voies qui ont le type de voie et le libelle_voie en doublon.
        Cette procédure est nécessaire en raison de la présence de "voies secondaires" taguées en 9000 dans les quatres derniers chiffres du champ TA_VOIE.OBJECTID. Ces voies ont le même type de voie et le même libelle_voie que la "voie principale" dont elles ne sont que des annexes.
        Exemple : l'Avenue du Peuple Belge se compose de l'avenue centrale (voie principale) et de petites voies perpendiculaires ayant le même type et le même libelle (voies secondaires) 
        
        Le procédure permet de corriger les cas suivants :
        1. Voies secondaires dont le complément_nom_voie est en doublon => le complément_nom_voie et le suffixe Annexe 1, 2, etc sont ajoutés (le numéro dépend du nombre de doublon de complément ayant le même type et libelle de voie) au libelle_voie ;
        2. Voies secondaires dont le complément_nom_voie est unique => le complément_nom_voie est ajouté au libelle_voie ;
        3. Voies secondaires dont le complément_nom_voie est null => le suffixe Annexe 1, 2, etc est ajouté (le numéro dépend du nombre de doublon de complément ayant le même type et libelle de voie) au libelle_voie;
        4. Voies secondaires uniques dont le complément_nom_voie est NULL => libelle + libelle_voie (ce sont peut-être des voies principales) ;
        5. Voies principales uniques => le libelle_voie reste tel quel ;
        6. Voies principales uniques dont le complement_nom_voie est NULL ;
        7. Voies principales en doublons => au sein des doublons, le libelle_voie de la voie la plus longue reste inchangé, celui des autres se voit ajouter le suffixe Annexe 1, 2, etc en fonction de leur longueur par ordre décroissant ;
        8. Voies principales en doublons de nom, type, complément et taille => type de voie + libelle de voie +  "1, 2, etc" ;
        9. Voies principales en doublons dont le complement_nom_voie est NULL => au sein des doublons, le libelle_voie de la voie la plus longue reste inchangé, celui des autres se voit ajouter le suffixe "1, 2, etc" en fonction de leur longueur par ordre décroissant ;
        10. Voies secondaires en doublons restant avec un complement_nom_voie NULL => libelle + libelle_voie + "1, 2, etc"
        */

        DELETE FROM G_BASE_VOIE.TA_VOIE_LITTERALIS;
        --------------------------------------------------------------------------------------------------------------------------------
        -- 1. Insertion dans G_BASE_VOIE.TA_VOIE_LITTERALIS des voies secondaires dont le complément est en doublon (libelle_voie devient la concaténation du libelle_voie + complement_nom_voie + Annexe...)
        MERGE INTO G_BASE_VOIE.TA_VOIE_LITTERALIS a
            USING(
                WITH
                    C_1 AS(-- Sélection des voies secondaires dont le complément de nom est en doublon
                        SELECT
                            UPPER(TRIM(b.libelle)) AS libelle,
                            UPPER(TRIM(a.libelle_voie)) AS libelle_voie,
                            UPPER(TRIM(a.complement_nom_voie)) AS complement_nom_voie
                        FROM
                            G_BASE_VOIE.TA_VOIE a
                            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                            INNER JOIN G_BASE_VOIE.VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE c ON c.code_voie = a.objectid
                        WHERE
                            a.complement_nom_voie IS NOT NULL
                            AND SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) >= 9000
                            AND SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) < 10000
                            AND UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
                        GROUP BY
                            UPPER(TRIM(b.libelle)),
                            UPPER(TRIM(a.libelle_voie)),
                            UPPER(TRIM(a.complement_nom_voie))
                        HAVING
                            COUNT(UPPER(TRIM(b.libelle)))>1
                            AND COUNT(UPPER(TRIM(a.libelle_voie)))>1
                            AND COUNT(UPPER(TRIM(a.complement_nom_voie))) > 1
                    )
                SELECT
                    b.objectid,
                    a.libelle || ' ' || a.libelle_voie || ' ' || a.complement_nom_voie || ' ANNEXE ' || ROW_NUMBER() OVER (PARTITION BY (UPPER(TRIM(c.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie))) ORDER BY b.objectid) AS nom_voie,
                    UPPER(TRIM(a.complement_nom_voie)) AS complement_nom_voie,
                    b.date_saisie,
                    b.date_modification,
                    b.fid_pnom_saisie,
                    b.fid_pnom_modification,
                    b.fid_typevoie,
                    b.fid_genre_voie,
                    b.fid_rivoli,
                    b.fid_metadonnee
                FROM
                    C_1 a
                    INNER JOIN G_BASE_VOIE.TA_VOIE b ON UPPER(TRIM(b.libelle_voie)) = a.libelle_voie AND UPPER(TRIM(b.complement_nom_voie)) = a.complement_nom_voie
                    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE c ON c.objectid = b.fid_typevoie AND UPPER(TRIM(c.libelle)) = a.libelle
                WHERE
                    TRIM(b.complement_nom_voie) IS NOT NULL
                    AND SUBSTR(b.objectid,LENGTH(b.objectid)-3,4) >= 9000
                    AND SUBSTR(b.objectid,LENGTH(b.objectid)-3,4) < 10000
            )t
        ON(a.objectid = t.objectid AND a.libelle_voie = t.nom_voie)
        WHEN NOT MATCHED THEN
        INSERT(a.objectid,a.libelle_voie,a.complement_nom_voie,a.date_saisie,a.date_modification,a.fid_pnom_saisie,a.fid_pnom_modification,a.fid_typevoie,a.fid_genre_voie,a.fid_rivoli,a.fid_metadonnee)
        VALUES(t.objectid,t.nom_voie,t.complement_nom_voie,t.date_saisie,t.date_modification,t.fid_pnom_saisie,t.fid_pnom_modification,t.fid_typevoie,t.fid_genre_voie,t.fid_rivoli,t.fid_metadonnee);
        -- Résultat : 138 doublons
        --------------------------------------------------------------------------------------------------------------------------------
        
        -- 2. Insertion dans G_BASE_VOIE.TA_VOIE_LITTERALIS des voies secondaires uniques dont le complément est non null
        MERGE INTO G_BASE_VOIE.TA_VOIE_LITTERALIS a
            USING(
                WITH
                    C_1 AS(-- Sélection des voies secondaires dont le complément de nom est en doublon
                        SELECT DISTINCT
                            a.fid_typevoie,
                            UPPER(TRIM(a.libelle_voie)) AS libelle_voie,
                            UPPER(TRIM(a.complement_nom_voie)) AS complement_nom_voie
                        FROM
                            G_BASE_VOIE.TA_VOIE a
                            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                        WHERE
                            SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) >= 9000
                            AND SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) < 10000
                            AND UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
                        GROUP BY
                            a.fid_typevoie,
                            UPPER(TRIM(a.libelle_voie)),
                            UPPER(TRIM(a.complement_nom_voie))
                        HAVING
                            COUNT(a.fid_typevoie)=1
                            AND COUNT(UPPER(TRIM(a.libelle_voie)))=1
                            AND COUNT(UPPER(TRIM(a.complement_nom_voie))) = 1
                    )
                SELECT DISTINCT
                    b.objectid,
                    UPPER(TRIM(c.libelle)) || ' ' || a.libelle_voie || ' ' || a.complement_nom_voie AS nom_voie,
                    UPPER(a.complement_nom_voie) AS complement_nom_voie,
                    b.date_saisie,
                    b.date_modification,
                    b.fid_pnom_saisie,
                    b.fid_pnom_modification,
                    b.fid_typevoie,
                    b.fid_genre_voie,
                    b.fid_rivoli,
                    b.fid_metadonnee
                FROM
                    C_1 a
                    INNER JOIN G_BASE_VOIE.TA_VOIE b ON UPPER(TRIM(b.libelle_voie)) = a.libelle_voie AND UPPER(TRIM(b.complement_nom_voie)) = a.complement_nom_voie AND b.fid_typevoie = a.fid_typevoie
                    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE c ON c.objectid = b.fid_typevoie
                WHERE
                    SUBSTR(b.objectid,LENGTH(b.objectid)-3,4) >= 9000
                    AND SUBSTR(b.objectid,LENGTH(b.objectid)-3,4) < 10000
            )t
        ON(a.objectid = t.objectid AND a.libelle_voie = t.nom_voie)
        WHEN NOT MATCHED THEN
        INSERT(a.objectid,a.libelle_voie,a.complement_nom_voie,a.date_saisie,a.date_modification,a.fid_pnom_saisie,a.fid_pnom_modification,a.fid_typevoie,a.fid_genre_voie,a.fid_rivoli,a.fid_metadonnee)
        VALUES(t.objectid,t.nom_voie,t.complement_nom_voie,t.date_saisie,t.date_modification,t.fid_pnom_saisie,t.fid_pnom_modification,t.fid_typevoie,t.fid_genre_voie,t.fid_rivoli,t.fid_metadonnee);
        -- Résultat : 5 505 voies fusionnées
        --------------------------------------------------------------------------------------------------------------------------------
        
        -- 3. Insertion dans G_BASE_VOIE.TA_VOIE_LITTERALIS des voies secondaires dont le complément est NULL
        MERGE INTO G_BASE_VOIE.TA_VOIE_LITTERALIS a
            USING(
                WITH
                    C_1 AS(-- Sélection des voies principales
                        SELECT DISTINCT
                            a.objectid,
                            UPPER(TRIM(b.libelle)) AS libelle,
                            UPPER(TRIM(a.libelle_voie)) AS libelle_voie,
                            UPPER(TRIM(a.complement_nom_voie)) AS complement_nom_voie,
                            UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie)) AS nom_voie
                        FROM
                            G_BASE_VOIE.TA_VOIE a
                            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                        WHERE
                            UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
                            AND SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) < 9000
                            OR SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) >= 10000
                            AND UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
                    )
                    
                    -- Sélection des voies secondaires dont le complément de nom est null et dont le libelle et le type sont égaux aux libelle et type des voies principales
                    SELECT DISTINCT
                        a.objectid,
                        UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie)) || ' ' || UPPER(TRIM(a.complement_nom_voie)) || ' ANNEXE ' || ROW_NUMBER() OVER (PARTITION BY (UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie))) ORDER BY a.objectid) AS nom_voie,
                        a.complement_nom_voie AS complement_nom_voie,
                        a.date_saisie,
                        a.date_modification,
                        a.fid_pnom_saisie,
                        a.fid_pnom_modification,
                        a.fid_typevoie,
                        a.fid_genre_voie,
                        a.fid_rivoli,
                        a.fid_metadonnee             
                    FROM
                        G_BASE_VOIE.TA_VOIE a
                        INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                    WHERE
                        a.complement_nom_voie IS NULL
                        AND SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) >= 9000
                        AND SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) < 10000
                        AND UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
                        AND UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie)) IN(SELECT nom_voie FROM C_1)
            )t
        ON(a.objectid = t.objectid AND a.libelle_voie = t.nom_voie)
        WHEN NOT MATCHED THEN
        INSERT(a.objectid,a.libelle_voie,a.complement_nom_voie,a.date_saisie,a.date_modification,a.fid_pnom_saisie,a.fid_pnom_modification,a.fid_typevoie,a.fid_genre_voie,a.fid_rivoli,a.fid_metadonnee)
        VALUES(t.objectid,t.nom_voie,t.complement_nom_voie,t.date_saisie,t.date_modification,t.fid_pnom_saisie,t.fid_pnom_modification,t.fid_typevoie,t.fid_genre_voie,t.fid_rivoli,t.fid_metadonnee);           
        -- Résultat : 457 voies fusionnées            
        ------------------------------------------------------------------------------------------------------------------------           
        
        -- 4. Voies secondaires uniques dont le complément_nom_voie est NULL => libelle + libelle_voie ;
        MERGE INTO G_BASE_VOIE.TA_VOIE_LITTERALIS a
            USING(
                WITH
                    C_1 AS(-- Sélection des voies secondaires
                        SELECT
                            UPPER(TRIM(b.libelle)) AS libelle,
                            a.fid_typevoie,
                            UPPER(TRIM(a.libelle_voie)) AS libelle_voie,
                            UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie)) AS nom_voie
                        FROM
                            G_BASE_VOIE.TA_VOIE a
                            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                        WHERE
                            UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
                            AND a.complement_nom_voie IS NULL
                            AND SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) >= 9000
                            AND SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) < 10000
                            AND a.objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TA_VOIE_LITTERALIS)
                            AND (UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie))) NOT IN (SELECT libelle_voie FROM G_BASE_VOIE.TA_VOIE_LITTERALIS)
                        GROUP BY
                            UPPER(TRIM(b.libelle)),
                            a.fid_typevoie,
                            UPPER(TRIM(a.libelle_voie)),
                            UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie))
                        HAVING
                            COUNT(UPPER(TRIM(b.libelle)))=1
                            AND COUNT(a.fid_typevoie)=1
                            AND COUNT(UPPER(TRIM(a.libelle_voie)))=1
                            AND COUNT((UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie))))=1
                        
                    )
                    
                    -- Sélection des voies secondaires dont le complément de nom est null et dont le libelle et le type sont égaux aux libelle et type des voies principales
                    SELECT
                        a.objectid,
                        UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie)) AS nom_voie,
                        UPPER(TRIM(a.complement_nom_voie)) AS complement_nom_voie,
                        a.date_saisie,
                        a.date_modification,
                        a.fid_pnom_saisie,
                        a.fid_pnom_modification,
                        a.fid_typevoie,
                        a.fid_genre_voie,
                        a.fid_rivoli,
                        a.fid_metadonnee             
                    FROM
                        G_BASE_VOIE.TA_VOIE a
                        INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                        INNER JOIN C_1 c ON c.libelle_voie = UPPER(TRIM(a.libelle_voie)) AND c.fid_typevoie = a.fid_typevoie
                    WHERE
                        a.complement_nom_voie IS NULL
            )t
        ON(a.objectid = t.objectid AND a.libelle_voie = t.nom_voie)
        WHEN NOT MATCHED THEN
        INSERT(a.objectid,a.libelle_voie,a.complement_nom_voie,a.date_saisie,a.date_modification,a.fid_pnom_saisie,a.fid_pnom_modification,a.fid_typevoie,a.fid_genre_voie,a.fid_rivoli,a.fid_metadonnee)
        VALUES(t.objectid,t.nom_voie,t.complement_nom_voie,t.date_saisie,t.date_modification,t.fid_pnom_saisie,t.fid_pnom_modification,t.fid_typevoie,t.fid_genre_voie,t.fid_rivoli,t.fid_metadonnee);           
        -- Résultat : 3 267 lignes fusionnées
        
        --------------------------------------------------------------------------------------------------------------------------------            
        
        -- 5. Insertion dans G_BASE_VOIE.TA_VOIE_LITTERALIS des voies principales uniques
        MERGE INTO G_BASE_VOIE.TA_VOIE_LITTERALIS a
            USING(
                WITH
                    C_1 AS(-- Sélection des voies principales uniques
                        SELECT
                            UPPER(TRIM(a.libelle_voie)) AS libelle_voie,
                            UPPER(TRIM(b.libelle)) AS libelle,
                            UPPER(TRIM(a.complement_nom_voie)) AS complement_nom_voie
                        FROM
                            G_BASE_VOIE.TA_VOIE a
                            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                        GROUP BY
                            UPPER(TRIM(a.libelle_voie)),
                            UPPER(TRIM(b.libelle)),
                            UPPER(TRIM(a.complement_nom_voie))
                        HAVING
                            COUNT(UPPER(TRIM(a.libelle_voie))) = 1
                            AND COUNT(UPPER(TRIM(b.libelle))) = 1
                            AND COUNT(UPPER(TRIM(a.complement_nom_voie))) = 1
                    )
                
                    SELECT DISTINCT
                        a.objectid,
                        c.libelle || ' ' || c.libelle_voie || ' ' || c.complement_nom_voie AS nom_voie,
                        c.complement_nom_voie,
                        a.date_saisie,
                        a.date_modification,
                        a.fid_pnom_saisie,
                        a.fid_pnom_modification,
                        a.fid_typevoie,
                        a.fid_genre_voie,
                        a.fid_rivoli,
                        a.fid_metadonnee             
                    FROM
                        G_BASE_VOIE.TA_VOIE a
                        INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                        INNER JOIN C_1 c ON c.libelle_voie = UPPER(TRIM(a.libelle_voie)) AND c.libelle = UPPER(TRIM(b.libelle)) AND c.complement_nom_voie = UPPER(TRIM(a.complement_nom_voie))
                    WHERE
                        UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
                        AND SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) < 9000
                        OR SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) >= 10000
                        AND UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
            )t
        ON(a.objectid = t.objectid AND a.libelle_voie = t.nom_voie)
        WHEN NOT MATCHED THEN
        INSERT(a.objectid,a.libelle_voie,a.complement_nom_voie,a.date_saisie,a.date_modification,a.fid_pnom_saisie,a.fid_pnom_modification,a.fid_typevoie,a.fid_genre_voie,a.fid_rivoli,a.fid_metadonnee)
        VALUES(t.objectid,t.nom_voie,t.complement_nom_voie,t.date_saisie,t.date_modification,t.fid_pnom_saisie,t.fid_pnom_modification,t.fid_typevoie,t.fid_genre_voie,t.fid_rivoli,t.fid_metadonnee);           
        -- Résultat : 1 367 voies
        ------------------------------------------------------------------------------------------------------------------------
        
        -- 6. Insertion dans G_BASE_VOIE.TA_VOIE_LITTERALIS des voies principales uniques dont le complement_nom_voie est NULL
        MERGE INTO G_BASE_VOIE.TA_VOIE_LITTERALIS a
            USING(
                WITH
                    C_1 AS(-- Sélection des voies principales uniques
                        SELECT
                            UPPER(TRIM(a.libelle_voie)) AS libelle_voie,
                            UPPER(TRIM(b.libelle)) AS libelle
                        FROM
                            G_BASE_VOIE.TA_VOIE a
                            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                        WHERE
                            a.complement_nom_voie IS NULL
                        GROUP BY
                            UPPER(TRIM(a.libelle_voie)),
                            UPPER(TRIM(b.libelle))
                        HAVING
                            COUNT(UPPER(TRIM(a.libelle_voie))) = 1
                            AND COUNT(UPPER(TRIM(b.libelle))) = 1
                    )
                
                    SELECT DISTINCT
                        a.objectid,
                        c.libelle || ' ' || c.libelle_voie AS nom_voie,
                        a.complement_nom_voie,
                        a.date_saisie,
                        a.date_modification,
                        a.fid_pnom_saisie,
                        a.fid_pnom_modification,
                        a.fid_typevoie,
                        a.fid_genre_voie,
                        a.fid_rivoli,
                        a.fid_metadonnee             
                    FROM
                        G_BASE_VOIE.TA_VOIE a
                        INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                        INNER JOIN C_1 c ON c.libelle_voie = UPPER(TRIM(a.libelle_voie)) AND c.libelle = UPPER(TRIM(b.libelle))
                    WHERE
                        UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
                        AND a.complement_nom_voie IS NULL
                        AND SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) < 9000
                        OR SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) >= 10000
                        AND a.complement_nom_voie IS NULL
                        AND UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
            )t
        ON(a.objectid = t.objectid OR a.libelle_voie = t.nom_voie)
        WHEN NOT MATCHED THEN
        INSERT(a.objectid,a.libelle_voie,a.complement_nom_voie,a.date_saisie,a.date_modification,a.fid_pnom_saisie,a.fid_pnom_modification,a.fid_typevoie,a.fid_genre_voie,a.fid_rivoli,a.fid_metadonnee)
        VALUES(t.objectid,t.nom_voie,t.complement_nom_voie,t.date_saisie,t.date_modification,t.fid_pnom_saisie,t.fid_pnom_modification,t.fid_typevoie,t.fid_genre_voie,t.fid_rivoli,t.fid_metadonnee);           
        -- Résultat : 5 379 voies fusionnées
        --------------------------------------------------------------------------------------------------------------------------------   
        
        -- 7. Voies principales en doublons de type, libelle et complément => au sein des doublons, le libelle_voie de la voie la plus longue reste inchangé, celui des autres se voie ajouté le suffixe 1, 2, etc en fonction de leur longueur par ordre décroissant
        MERGE INTO G_BASE_VOIE.TA_VOIE_LITTERALIS a
            USING(
                WITH
                    C_1 AS(-- Sélection des voies principales en doublon de libelle_voie, complement_nom_voie et libelle (type de voie)
                        SELECT
                            UPPER(TRIM(a.libelle_voie)) AS libelle_voie,
                            UPPER(TRIM(b.libelle)) AS libelle,
                            UPPER(TRIM(a.complement_nom_voie)) AS complement_nom_voie,
                            UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie)) || ' ' || UPPER(TRIM(a.complement_nom_voie)) AS nom_voie
                        FROM
                            G_BASE_VOIE.TA_VOIE a
                            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                        WHERE
                            UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
                            AND SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) < 9000
                            OR SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) >= 10000
                            AND UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
                        GROUP BY
                            UPPER(TRIM(a.libelle_voie)),
                            UPPER(TRIM(b.libelle)),
                            UPPER(TRIM(a.complement_nom_voie)),
                            UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie)) || ' ' || UPPER(TRIM(a.complement_nom_voie))
                        HAVING
                            COUNT(UPPER(TRIM(a.libelle_voie))) > 1
                            AND COUNT(UPPER(TRIM(b.libelle))) > 1
                            AND COUNT(UPPER(TRIM(a.complement_nom_voie))) > 1
                    ),
                    
                    C_2 AS(-- Sélection du code voie des voies principales en doublons et de leur taille
                        SELECT
                            a.objectid,
                            c.libelle_voie,
                            c.libelle,
                            c.complement_nom_voie,
                            c.nom_voie,
                            ROUND(SDO_GEOM.SDO_LENGTH(d.geom, m.diminfo),2) AS mesure_voie
                        FROM
                            G_BASE_VOIE.TA_VOIE a
                            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                            INNER JOIN C_1 c ON c.nom_voie = UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie)) || ' ' || UPPER(TRIM(a.complement_nom_voie))
                            INNER JOIN G_BASE_VOIE.VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE d ON d.code_voie = a.objectid,
                            USER_SDO_GEOM_METADATA m
                        WHERE
                            m.TABLE_NAME = 'VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE'
                            AND TRIM(a.complement_nom_voie) IS NOT NULL
                    ),
                    
                    C_3 AS(-- Sélection noms des voies dont la taille est maximale au sein des doublons
                        SELECT
                            a.nom_voie,
                            MAX(a.mesure_voie) AS mesure_voie_max
                        FROM
                            C_2 a
                        GROUP BY
                            a.nom_voie
                    )
                    
                    SELECT -- Sélection des voies dont la taille est inférieure à la taille maximale repérée au sein des doublons et ajout du suffixe '1, 2, 3, etc) par ordre de taille décroissant
                        a.objectid,
                        a.nom_voie || ' PARTIE ' || ROW_NUMBER() OVER (PARTITION BY (a.nom_voie) ORDER BY a.mesure_voie DESC) AS nom_voie,
                        UPPER(TRIM(b.complement_nom_voie)) AS complement_nom_voie,
                        b.date_saisie,
                        b.date_modification,
                        b.fid_pnom_saisie,
                        b.fid_pnom_modification,
                        b.fid_typevoie,
                        b.fid_genre_voie,
                        b.fid_rivoli,
                        b.fid_metadonnee
                    FROM
                        C_2 a
                        INNER JOIN G_BASE_VOIE.TA_VOIE b ON b.objectid = a.objectid
                        INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE c ON c.objectid = b.fid_typevoie
                    WHERE
                        a.mesure_voie NOT IN(SELECT mesure_voie_max FROM C_3)
                    UNION ALL
                    SELECT -- Sélection de toutes les infos des voies dont la taille, au sein des doublons, est maximale. Le libelle_voie est concaténé au complement_nom_voie
                        a.objectid,
                        a.nom_voie,
                        UPPER(TRIM(c.complement_nom_voie)) AS complement_nom_voie,
                        c.date_saisie,
                        c.date_modification,
                        c.fid_pnom_saisie,
                        c.fid_pnom_modification,
                        c.fid_typevoie,
                        c.fid_genre_voie,
                        c.fid_rivoli,
                        c.fid_metadonnee
                    FROM
                        C_2 a
                        INNER JOIN C_3 b ON b.mesure_voie_max = a.mesure_voie AND b.nom_voie = a.nom_voie
                        INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = a.objectid
                        INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE d ON d.objectid = c.fid_typevoie
            )t
        ON(a.objectid = t.objectid OR a.libelle_voie = t.nom_voie)
        WHEN NOT MATCHED THEN
        INSERT(a.objectid,a.libelle_voie,a.complement_nom_voie,a.date_saisie,a.date_modification,a.fid_pnom_saisie,a.fid_pnom_modification,a.fid_typevoie,a.fid_genre_voie,a.fid_rivoli,a.fid_metadonnee)
        VALUES(t.objectid,t.nom_voie,t.complement_nom_voie,t.date_saisie,t.date_modification,t.fid_pnom_saisie,t.fid_pnom_modification,t.fid_typevoie,t.fid_genre_voie,t.fid_rivoli,t.fid_metadonnee);           
        -- Résultat : 63 voies dont un doublon créé en raison d'une taille identique (le doublon RUE DE REIMS M145 est absolu)
        ------------------------------------------------------------------------------------------------------------------------
        
        -- 8. Voies principales en doublons de nom, type, complément et de TAILLE => le libelle_voie se voie ajouté le type et préfixe et "1, 2, etc" en suffixe ;
        MERGE INTO G_BASE_VOIE.TA_VOIE_LITTERALIS a
            USING(
                WITH
                    C_1 AS(-- Sélection des voies principales en doublon de libelle_voie et libelle (type de voie) dont le complement_nom_voie est NULL
                        SELECT
                            UPPER(TRIM(a.libelle_voie)) AS libelle_voie,
                            UPPER(TRIM(b.libelle)) AS libelle,
                            UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie)) AS nom_voie
                        FROM
                            G_BASE_VOIE.TA_VOIE a
                            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                        WHERE
                            a.complement_nom_voie IS NULL
                            AND UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
                            AND SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) < 9000
                            OR SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) >= 10000
                            AND a.complement_nom_voie IS NULL
                            AND UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
                        GROUP BY
                            UPPER(TRIM(a.libelle_voie)),
                            UPPER(TRIM(b.libelle)),
                            UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie))
                        HAVING
                            COUNT(UPPER(TRIM(a.libelle_voie))) > 1
                            AND COUNT(UPPER(TRIM(b.libelle))) > 1
                    ),
                    
                    C_2 AS(-- Sélection du code voie des voies principales en doublons de taille
                        SELECT
                            c.libelle_voie,
                            c.libelle,
                            a.fid_typevoie,
                            c.nom_voie,
                            ROUND(SDO_GEOM.SDO_LENGTH(d.geom, m.diminfo),2) AS mesure_voie
                        FROM
                            G_BASE_VOIE.TA_VOIE a
                            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                            INNER JOIN C_1 c ON c.nom_voie = UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie))
                            INNER JOIN G_BASE_VOIE.VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE d ON d.code_voie = a.objectid,
                            USER_SDO_GEOM_METADATA m
                        WHERE
                            m.TABLE_NAME = 'VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE'
                            AND a.complement_nom_voie IS NULL
                        GROUP BY
                            c.libelle_voie,
                            c.libelle,
                            a.fid_typevoie,
                            c.nom_voie,
                            ROUND(SDO_GEOM.SDO_LENGTH(d.geom, m.diminfo),2)
                        HAVING
                            COUNT(c.libelle_voie) > 1
                            AND COUNT(c.libelle) > 1
                            AND COUNT(a.fid_typevoie) > 1
                            AND COUNT(c.nom_voie) > 1
                            AND COUNT(ROUND(SDO_GEOM.SDO_LENGTH(d.geom, m.diminfo),2)) > 1
                    )
                    
                    SELECT -- Sélection de toutes les informations des voies en doublon auxquelles on ajoute en suffixe 1, 2, etc 
                        c.objectid,
                        a.nom_voie || ' PARTIE ' || ROW_NUMBER() OVER (PARTITION BY (a.nom_voie) ORDER BY c.objectid DESC) AS nom_voie,
                        UPPER(c.complement_nom_voie) AS complement_nom_voie,
                        c.date_saisie,
                        c.date_modification,
                        c.fid_pnom_saisie,
                        c.fid_pnom_modification,
                        c.fid_typevoie,
                        c.fid_genre_voie,
                        c.fid_rivoli,
                        c.fid_metadonnee
                    FROM
                        C_2 a
                        INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON UPPER(b.libelle) = UPPER(a.libelle)
                        INNER JOIN G_BASE_VOIE.TA_VOIE c ON UPPER(TRIM(c.libelle_voie)) = UPPER(a.libelle_voie) AND c.fid_typevoie = a.fid_typevoie                   
                    WHERE
                        c.complement_nom_voie IS NULL
            )t
        ON(a.objectid = t.objectid OR a.libelle_voie = t.nom_voie)
        WHEN NOT MATCHED THEN
        INSERT(a.objectid,a.libelle_voie,a.complement_nom_voie,a.date_saisie,a.date_modification,a.fid_pnom_saisie,a.fid_pnom_modification,a.fid_typevoie,a.fid_genre_voie,a.fid_rivoli,a.fid_metadonnee)
        VALUES(t.objectid,t.nom_voie,t.complement_nom_voie,t.date_saisie,t.date_modification,t.fid_pnom_saisie,t.fid_pnom_modification,t.fid_typevoie,t.fid_genre_voie,t.fid_rivoli,t.fid_metadonnee);           
        -- Résultat : 93
        ------------------------------------------------------------------------------------------------------------------------
        
        -- 9. Voies principales en doublons dont le complement_nom_voie est NULL et dont les tailles sont différentes => au sein des doublons, le libelle_voie de la voie la plus longue reste inchangé, celui des autres se voie ajouté le suffixe Annexe 1, 2, etc en fonction de leur longueur par ordre décroissant
        MERGE INTO G_BASE_VOIE.TA_VOIE_LITTERALIS a
            USING(
                WITH
                    C_1 AS(-- Sélection des voies principales en doublon de libelle_voie et libelle (type de voie) dont le complement_nom_voie est NULL
                        SELECT
                            UPPER(TRIM(a.libelle_voie)) AS libelle_voie,
                            UPPER(TRIM(b.libelle)) AS libelle,
                            UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie)) AS nom_voie
                        FROM
                            G_BASE_VOIE.TA_VOIE a
                            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                        WHERE
                            a.complement_nom_voie IS NULL
                            AND UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
                            AND SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) < 9000
                            OR SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) >= 10000
                            AND a.complement_nom_voie IS NULL
                            AND UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
                        GROUP BY
                            UPPER(TRIM(a.libelle_voie)),
                            UPPER(TRIM(b.libelle)),
                            UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie))
                        HAVING
                            COUNT(UPPER(TRIM(a.libelle_voie))) > 1
                            AND COUNT(UPPER(TRIM(b.libelle))) > 1
                    ),
                    
                    C_2 AS(-- Sélection du code voie des voies principales en doublons et de leur taille
                        SELECT
                            a.objectid,
                            c.libelle_voie,
                            c.libelle,
                            c.nom_voie,
                            ROUND(SDO_GEOM.SDO_LENGTH(d.geom, m.diminfo),2) AS mesure_voie
                        FROM
                            G_BASE_VOIE.TA_VOIE a
                            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                            INNER JOIN C_1 c ON c.nom_voie = UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie))
                            INNER JOIN G_BASE_VOIE.VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE d ON d.code_voie = a.objectid,
                            USER_SDO_GEOM_METADATA m
                        WHERE
                            m.TABLE_NAME = 'VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE'
                            AND a.complement_nom_voie IS NULL
                            AND a.objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TA_VOIE_LITTERALIS)
                    ),
                    
                    C_3 AS(-- Sélection noms des voies dont la taille est maximale au sein des doublons
                        SELECT
                            a.nom_voie,
                            MAX(a.mesure_voie) AS mesure_voie_max
                        FROM
                            C_2 a
                        GROUP BY
                            a.nom_voie
                    )
                    
                    SELECT -- Sélection des voies dont la taille est inférieure à la taille maximale repérée au sein des doublons et ajout du suffixe 'ANNEXE 1, 2, 3, etc) par ordre de taille décroissant
                        a.objectid,
                        a.nom_voie || ' PARTIE ' || ROW_NUMBER() OVER (PARTITION BY (a.nom_voie) ORDER BY a.mesure_voie DESC) AS nom_voie,
                        b.complement_nom_voie AS complement_nom_voie,
                        b.date_saisie,
                        b.date_modification,
                        b.fid_pnom_saisie,
                        b.fid_pnom_modification,
                        b.fid_typevoie,
                        b.fid_genre_voie,
                        b.fid_rivoli,
                        b.fid_metadonnee
                    FROM
                        C_2 a
                        INNER JOIN G_BASE_VOIE.TA_VOIE b ON b.objectid = a.objectid
                        INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE c ON c.objectid = b.fid_typevoie
                    WHERE
                        b.complement_nom_voie IS NULL
                        AND a.mesure_voie NOT IN(SELECT mesure_voie_max FROM C_3)
                    UNION ALL
                    SELECT -- Sélection de toutes les infos des voies dont la taille, au sein des doublons, est maximale. Le libelle_voie est concaténé au complement_nom_voie
                        a.objectid,
                        a.nom_voie,
                        c.complement_nom_voie AS complement_nom_voie,
                        c.date_saisie,
                        c.date_modification,
                        c.fid_pnom_saisie,
                        c.fid_pnom_modification,
                        c.fid_typevoie,
                        c.fid_genre_voie,
                        c.fid_rivoli,
                        c.fid_metadonnee
                    FROM
                        C_2 a
                        INNER JOIN C_3 b ON b.mesure_voie_max = a.mesure_voie AND b.nom_voie = a.nom_voie
                        INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = a.objectid
                        INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE d ON d.objectid = c.fid_typevoie
                    WHERE
                        c.complement_nom_voie IS NULL
            )t
        ON(a.objectid = t.objectid AND a.libelle_voie = t.nom_voie)
        WHEN NOT MATCHED THEN
        INSERT(a.objectid,a.libelle_voie,a.complement_nom_voie,a.date_saisie,a.date_modification,a.fid_pnom_saisie,a.fid_pnom_modification,a.fid_typevoie,a.fid_genre_voie,a.fid_rivoli,a.fid_metadonnee)
        VALUES(t.objectid,t.nom_voie,t.complement_nom_voie,t.date_saisie,t.date_modification,t.fid_pnom_saisie,t.fid_pnom_modification,t.fid_typevoie,t.fid_genre_voie,t.fid_rivoli,t.fid_metadonnee);           
        -- Résultat : 5 247
        ------------------------------------------------------------------------------------------------------------------------
        
        -- 10. Voies secondaires en doublons restant avec un complement_nom_voie NULL => libelle + libelle_voie + "1, 2, etc"
        MERGE INTO G_BASE_VOIE.TA_VOIE_LITTERALIS a
            USING(
                WITH
                    C_1 AS(-- Sélection des voies secondaires dont le complément de nom est NULL
                        SELECT
                            UPPER(TRIM(b.libelle)) AS libelle,
                            a.fid_typevoie,
                            UPPER(TRIM(a.libelle_voie)) AS libelle_voie
                        FROM
                            G_BASE_VOIE.TA_VOIE a
                            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                        WHERE
                            a.complement_nom_voie IS NULL
                            AND a.objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TA_VOIE_LITTERALIS)
                            AND SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) >= 9000
                            AND SUBSTR(a.objectid,LENGTH(a.objectid)-3,4) < 10000
                            AND UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'                            
                        GROUP BY
                            UPPER(TRIM(b.libelle)),
                            a.fid_typevoie,
                            UPPER(TRIM(a.libelle_voie))
                        HAVING
                            COUNT(UPPER(TRIM(b.libelle)))>1
                            AND COUNT(a.fid_typevoie) > 1
                            AND COUNT(UPPER(TRIM(a.libelle_voie)))>1
                    )
                SELECT
                    b.objectid,
                    a.libelle || ' ' || a.libelle_voie || ' ' || ROW_NUMBER() OVER (PARTITION BY (a.libelle || ' ' || a.libelle_voie) ORDER BY b.objectid) AS nom_voie,
                    b.complement_nom_voie,
                    b.date_saisie,
                    b.date_modification,
                    b.fid_pnom_saisie,
                    b.fid_pnom_modification,
                    b.fid_typevoie,
                    b.fid_genre_voie,
                    b.fid_rivoli,
                    b.fid_metadonnee
                FROM
                    C_1 a
                    INNER JOIN G_BASE_VOIE.TA_VOIE b ON UPPER(TRIM(b.libelle_voie)) = a.libelle_voie AND a.fid_typevoie = b.fid_typevoie
                    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE c ON c.objectid = b.fid_typevoie AND UPPER(TRIM(c.libelle)) = a.libelle
                WHERE
                    b.complement_nom_voie IS NULL
                    AND b.objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TA_VOIE_LITTERALIS)
                    AND SUBSTR(b.objectid,LENGTH(b.objectid)-3,4) >= 9000
                    AND SUBSTR(b.objectid,LENGTH(b.objectid)-3,4) < 10000
            )t
        ON(a.objectid = t.objectid AND a.libelle_voie = t.nom_voie)
        WHEN NOT MATCHED THEN
        INSERT(a.objectid,a.libelle_voie,a.complement_nom_voie,a.date_saisie,a.date_modification,a.fid_pnom_saisie,a.fid_pnom_modification,a.fid_typevoie,a.fid_genre_voie,a.fid_rivoli,a.fid_metadonnee)
        VALUES(t.objectid,t.nom_voie,t.complement_nom_voie,t.date_saisie,t.date_modification,t.fid_pnom_saisie,t.fid_pnom_modification,t.fid_typevoie,t.fid_genre_voie,t.fid_rivoli,t.fid_metadonnee);           
        -- Résultat : 310 lignes fusionnées
        ------------------------------------------------------------------------------------------------------------------------
        
        -- 11. Sélection de toutes les voies principales n'étant pas encore dans TA_VOIE_LITTERALIS et dont le complement de nom est NULL => libelle + libelle_voie
        MERGE INTO G_BASE_VOIE.TA_VOIE_LITTERALIS a
            USING(
                    SELECT
                        a.objectid,
                        UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie)) AS nom_voie,
                        TRIM(a.complement_nom_voie) AS complement_nom_voie,
                        a.date_saisie,
                        a.date_modification,
                        a.fid_pnom_saisie,
                        a.fid_pnom_modification,
                        a.fid_typevoie,
                        a.fid_genre_voie,
                        a.fid_rivoli,
                        a.fid_metadonnee
                    FROM
                        G_BASE_VOIE.TA_VOIE a
                        INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
                    WHERE
                        a.objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TA_VOIE_LITTERALIS)
                        AND UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie)) NOT IN(SELECT libelle_voie FROM G_BASE_VOIE.TA_VOIE_LITTERALIS)
                        AND a.complement_nom_voie IS NULL
                        AND UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
            )t
            ON(a.objectid = t.objectid AND a.libelle_voie = t.nom_voie)
        WHEN NOT MATCHED THEN
        INSERT(a.objectid,a.libelle_voie,a.complement_nom_voie,a.date_saisie,a.date_modification,a.fid_pnom_saisie,a.fid_pnom_modification,a.fid_typevoie,a.fid_genre_voie,a.fid_rivoli,a.fid_metadonnee)
        VALUES(t.objectid,t.nom_voie,t.complement_nom_voie,t.date_saisie,t.date_modification,t.fid_pnom_saisie,t.fid_pnom_modification,t.fid_typevoie,t.fid_genre_voie,t.fid_rivoli,t.fid_metadonnee);      
        -- Résulat = 158 lignes fusionnées
        
        -- Sélection de voies secondaires encore récalcitrantes (leur objectid n'est pas dans TA_VOIE_LITTERALIS, mais leur libelle_voie (avant correction) si)
        MERGE INTO G_BASE_VOIE.TA_VOIE_LITTERALIS a
            USING(
                    WITH
                        C_1 AS(-- Sélection des noms de voies présentes dans TA_VOIE_LITTERALIS, mais dont il reste des objectid absents de la table
                            SELECT 'AVENUE DE LA MARNE%' AS nom_test FROM DUAL UNION ALL
                            SELECT 'BOULEVARD DE L''OUEST%' AS nom_test FROM DUAL UNION ALL
                            SELECT 'BOULEVARD DE RONCQ%' AS nom_test FROM DUAL UNION ALL
                            SELECT 'BOULEVARD ROBERT SCHUMAN%' AS nom_test FROM DUAL UNION ALL
                            SELECT 'CITE BUISINE%' AS nom_test FROM DUAL UNION ALL
                            SELECT 'ROUTE D''AUBERS%' AS nom_test FROM DUAL UNION ALL
                            SELECT 'ROUTE DE LILLE%' AS nom_test FROM DUAL UNION ALL
                            SELECT 'RUE DE LA HAIE PLOUVIER%' AS nom_test FROM DUAL UNION ALL
                            SELECT 'RUE DE MESSINES%' AS nom_test FROM DUAL UNION ALL
                            SELECT 'RUE DES POSTES%' AS nom_test FROM DUAL UNION ALL
                            SELECT 'RUE DU FORT%' AS nom_test FROM DUAL UNION ALL
                            SELECT 'RUE LEO FERRE%' AS nom_test FROM DUAL UNION ALL
                            SELECT 'RUE MARCEL DASSAULT ZI%' AS nom_test FROM DUAL UNION ALL
                            SELECT 'RUE NICOLAS APPERT%' AS nom_test FROM DUAL
                        )
                    SELECT DISTINCT
                        a.objectid,
                        UPPER(TRIM(b.libelle)) || ' ' || UPPER(TRIM(a.libelle_voie)) || ' ' || UPPER(TRIM(a.complement_nom_voie)) || ' ANNEXE 1' AS nom_voie,
                        TRIM(a.complement_nom_voie) AS complement_nom_voie,
                        a.date_saisie,
                        a.date_modification,
                        a.fid_pnom_saisie,
                        a.fid_pnom_modification,
                        a.fid_typevoie,
                        a.fid_genre_voie,
                        a.fid_rivoli,
                        a.fid_metadonnee
                    FROM
                        G_BASE_VOIE.TA_VOIE a
                        INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie,
                        G_BASE_VOIE.TA_VOIE_LITTERALIS c,
                        C_1 d
                    WHERE
                        b.libelle <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
                        AND a.objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TA_VOIE_LITTERALIS)
                        AND c.libelle_voie LIKE d.nom_test
            )t
            ON (a.objectid = t.objectid AND a.libelle_voie = t.nom_voie)
        WHEN NOT MATCHED THEN
        INSERT(a.objectid,a.libelle_voie,a.complement_nom_voie,a.date_saisie,a.date_modification,a.fid_pnom_saisie,a.fid_pnom_modification,a.fid_typevoie,a.fid_genre_voie,a.fid_rivoli,a.fid_metadonnee)
        VALUES(t.objectid,t.nom_voie,t.complement_nom_voie,t.date_saisie,t.date_modification,t.fid_pnom_saisie,t.fid_pnom_modification,t.fid_typevoie,t.fid_genre_voie,t.fid_rivoli,t.fid_metadonnee);      
        -- Résulat = 14 lignes fusionnées

EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('une erreur est survenue, un rollback va être effectué: ' || SQLCODE || ' : '  || SQLERRM(SQLCODE));
    ROLLBACK TO POINT_SAUVERGARDE_REMPLISSAGE_TA_VOIE_LITTERALIS;
END REMPLISSAGE_TA_VOIE_LITTERALIS;