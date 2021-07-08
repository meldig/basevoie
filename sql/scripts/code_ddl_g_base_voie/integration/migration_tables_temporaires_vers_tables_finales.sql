/*
Import des données corrigées des tables temporaires vers les tables finales de la base voie.
*/

SET SERVEROUTPUT ON
DECLARE
    v_nbr_objectid NUMBER(38,0);
    v_contrainte VARCHAR2(100);
BEGIN

    SAVEPOINT POINT_SAUVEGARDE_REMPLISSAGE;

    -- 1. Import des données des agents de la base voie + gestionnaires de données
    INSERT INTO G_BASE_VOIE.TA_AGENT(numero_agent, pnom, validite)
    SELECT numero_agent, pnom, validite FROM TEMP_AGENT;

    -- 2. Import des libellés dans TA_FAMILLE
    INSERT INTO G_BASE_VOIE.TA_FAMILLE(valeur)
    SELECT valeur FROM TEMP_FAMILLE;

    -- 3. Import des libellés dans TA_LIBELLE
    INSERT INTO G_BASE_VOIE.TA_LIBELLE(valeur)
    SELECT valeur FROM TEMP_LIBELLE;

    -- 4. Import des relations dans TA_RELATION_FAMILLE_LIBELLE
    -- 4.1. Pour les types d'actions
    INSERT INTO G_BASE_VOIE.TA_RELATION_FAMILLE_LIBELLE(fid_famille, fid_libelle)
    SELECT
        a.objectid,
        b.objectid
    FROM
        G_BASE_VOIE.TA_FAMILLE a,
        G_BASE_VOIE.TA_LIBELLE b
    WHERE
        a.valeur = 'action'
        AND b.valeur IN('insertion', 'édition', 'suppression');

    -- 4.2. Pour les genres de voie
    INSERT INTO G_BASE_VOIE.TA_RELATION_FAMILLE_LIBELLE(fid_famille, fid_libelle)
    SELECT
        a.objectid,
        b.objectid
    FROM
        G_BASE_VOIE.TA_FAMILLE a,
        G_BASE_VOIE.TA_LIBELLE b
    WHERE
        a.valeur = 'genre du nom des voies'
        AND b.valeur IN('masculin', 'féminin', 'neutre', 'couple', 'non-identifié', 'non-renseigné');

    -- 5. Insertion des codes rivoli dans TA_RIVOLI
    -- 5.1. Insertion des codes rivoli complet (avec clé)
    INSERT INTO G_BASE_VOIE.TA_RIVOLI(code_rivoli, cle_controle)
    SELECT DISTINCT
        SUBSTR(temp_code_fantoir, 4, 4) AS rivoli,
        SUBSTR(temp_code_fantoir, 8, 1) AS cle_f
    FROM
        G_BASE_VOIE.TEMP_VOIEVOI
    WHERE
        temp_code_fantoir IS NOT NULL;
        
    -- 5.2. Insertion de tous les autres codes rivoli (sans clé)
    INSERT INTO G_BASE_VOIE.TA_RIVOLI(code_rivoli)
    SELECT DISTINCT
        ccodrvo
    FROM
        G_BASE_VOIE.TEMP_VOIEVOI
    WHERE
        temp_code_fantoir IS NULL;

    -- 6. Désactivation des triggers pour les tronçons
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_TRONCON_LOG DISABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_TRONCON_DATE_PNOM DISABLE';
    
    -- 7. Import des tronçons valides dans TA_TRONCON
    INSERT INTO G_BASE_VOIE.TA_TRONCON(objectid, geom, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification)
    SELECT
        a.cnumtrc,
        a.ora_geometry,
        a.cdtstrc,
        a.cdtmtrc,
        b.numero_agent AS fid_pnom_saisie,
        b.numero_agent AS fid_pnom_modification
    FROM
        G_BASE_VOIE.TEMP_ILTATRC a,
        G_BASE_VOIE.TA_AGENT b
    WHERE
        a.cdvaltro = 'V'
        AND b.pnom = 'import_donnees';
        
    -- 8. Import des tronçons valides dans TA_TRONCON_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(geom, fid_troncon, date_action, fid_type_action, fid_pnom)
    SELECT
        a.geom,
        a.objectid,
        b.cdtstrc,
        d.objectid,
        c.numero_agent
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid,
        G_BASE_VOIE.TA_AGENT c,
        G_BASE_VOIE.TA_LIBELLE d
    WHERE
        b.cdvaltro = 'V'
        AND c.pnom = 'import_donnees'
        AND d.valeur = 'insertion';

    -- 9. Insertion des dates de modification dans TA_TRONCON_LOG pour la modification
    INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(geom, fid_troncon, date_action, fid_type_action, fid_pnom)
    SELECT
        a.geom,
        a.objectid,
        b.cdtmtrc,
        d.objectid,
        c.numero_agent
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid,
        G_BASE_VOIE.TA_AGENT c,
        G_BASE_VOIE.TA_LIBELLE d
    WHERE
        b.cdvaltro = 'V'
        AND c.pnom = 'import_donnees'
        AND d.valeur = 'édition';

    -- 10. Import des tronçons invalides dans TA_TRONCON pour la création
    INSERT INTO G_BASE_VOIE.TA_TRONCON(objectid, geom, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification)
    SELECT
        a.cnumtrc,
        a.ora_geometry,
        a.cdtstrc,
        a.cdtmtrc,
        b.numero_agent AS fid_pnom_saisie,
        b.numero_agent AS fid_pnom_modification
    FROM
        G_BASE_VOIE.TEMP_ILTATRC a,
        G_BASE_VOIE.TA_AGENT b
    WHERE
        a.cdvaltro = 'F'
        AND b.pnom = 'import_donnees';

    -- 11. Import des tronçons invalides dans TA_TRONCON_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(geom, fid_troncon, date_action, fid_type_action, fid_pnom)
    SELECT
        a.geom,
        a.objectid,
        b.cdtstrc,
        d.objectid,
        c.numero_agent
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid,
        G_BASE_VOIE.TA_AGENT c,
        G_BASE_VOIE.TA_LIBELLE d
    WHERE
        b.cdvaltro = 'F'
        AND c.pnom = 'import_donnees'
        AND d.valeur = 'insertion';

    -- 12. Insertion des dates de modification dans TA_TRONCON_LOG pour la modification
    INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(geom, fid_troncon, date_action, fid_type_action, fid_pnom)
    SELECT
        a.geom,
        a.objectid,
        b.cdtmtrc,
        d.objectid,
        c.numero_agent
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid,
        G_BASE_VOIE.TA_AGENT c,
        G_BASE_VOIE.TA_LIBELLE d
    WHERE
        b.cdvaltro = 'F'
        AND c.pnom = 'import_donnees'
        AND d.valeur = 'suppression';

    -- 13. Suppression des tronçons invalides dans la table TA_TRONCON
    DELETE 
    FROM G_BASE_VOIE.TA_TRONCON a 
    WHERE
        a.objectid IN(
            SELECT
                cnumtrc
            FROM
                G_BASE_VOIE.TEMP_ILTATRC
            WHERE
                cdvaltro = 'F'
        );

    -- 14. Modification du numéro de départ de l'incrémentation du champ TA_TRONCON.objectid
    SELECT
        MAX(objectid)+1
        INTO v_nbr_objectid
    FROM
        G_BASE_VOIE.TA_TRONCON;
    
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_TRONCON MODIFY objectid GENERATED BY DEFAULT AS IDENTITY (START WITH ' || v_nbr_objectid  || ' INCREMENT BY 1)';
    
    -- 15. Réactivation des triggers pour les tronçons
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_TRONCON_LOG ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_TRONCON_DATE_PNOM ENABLE';
    
    -- 16. Désactivation de la contrainte de non-nullité du champ TA_TYPE_VOIE.LIBELLE
    SELECT
        CONSTRAINT_NAME
        INTO v_contrainte
    FROM
        USER_CONSTRAINTS
    WHERE
        TABLE_NAME = 'TA_TYPE_VOIE'
        AND CONSTRAINT_TYPE = 'C'
        AND SEARCH_CONDITION_VC LIKE '%LIBELLE%';

    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_TYPE_VOIE DISABLE CONSTRAINT ' || v_contrainte;

    -- 17. Import des données dans TA_TYPE_VOIE
    -- 17.1. Import des type présents dans TYPEVOIE
    INSERT INTO G_BASE_VOIE.TA_TYPE_VOIE(code_type_voie, libelle)
    SELECT
        CCODTVO,
        LITYVOIE
    FROM
        G_BASE_VOIE.TEMP_TYPEVOIE;
    
    -- 17.2. Import des types de voies présents dans VOIEVOI mais absents de TYPEVOIE
    INSERT INTO G_BASE_VOIE.TA_TYPE_VOIE(code_type_voie, libelle)
    SELECT DISTINCT
        a.ccodtvo,
        'type de voie présent dans VOIEVOI mais pas dans TYPEVOIE lors de la migration'
    FROM
        TEMP_VOIEVOI a
    WHERE
        a.ccodtvo NOT IN(SELECT code_type_voie FROM TA_TYPE_VOIE);

    -- 18. Désactivation des triggers pour les voies
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_VOIE_LOG DISABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_VOIE_DATE_PNOM DISABLE';
               
    -- 19. Mise à jour des champs NULL pour les voies invalides
    -- 19.1. Mise à jour du champ "GENRE" de la table TEMP_VOIEVOI en 'NI' (non-identifié) dans TEMP_VOIEVOI pour les voies invalides dont le champ "GENRE" est NULL
    UPDATE G_BASE_VOIE.TEMP_VOIEVOI
    SET GENRE = 'NI'
    WHERE
        CDVALVOI = 'I'
        AND GENRE IS NULL;

    -- 19.2. Mise à jour du champ "CNOMINUS" de la table TEMP_VOIEVOI en 'aucun nom lors de la migration en base' pour toutes les voies ne disposant pas de nom dans "CNOMINUS".
    UPDATE G_BASE_VOIE.TEMP_VOIEVOI
    SET CNOMINUS = 'aucun nom lors de la migration en base'
    WHERE
        CNOMINUS IS NULL;

    -- 20. Import de toutes les voies valides et invalides dans TA_VOIE
    INSERT INTO G_BASE_VOIE.TA_VOIE(FID_TYPEVOIE, OBJECTID, COMPLEMENT_NOM_VOIE, LIBELLE_VOIE, FID_GENRE_VOIE, DATE_SAISIE, DATE_MODIFICATION, FID_PNOM_SAISIE, FID_PNOM_MODIFICATION)
            WITH C_1 AS(
                SELECT DISTINCT
                    b.objectid AS FID_TYPE_VOIE,
                    a.CCOMVOI AS NUMERO_VOIE,
                    a.CINFOS AS COMPLEMENT_NOM_VOIE,
                    a.CNOMINUS AS LIBELLE,
                    CASE
                        WHEN a.genre = 'M' AND d.valeur = 'masculin' THEN d.objectid
                        WHEN a.genre = 'F' AND d.valeur = 'féminin' THEN d.objectid
                        WHEN a.genre = 'N' AND d.valeur = 'neutre' THEN d.objectid
                        WHEN a.genre = 'C' AND d.valeur = 'couple' THEN d.objectid
                        WHEN a.genre = 'NI' AND d.valeur = 'non-identifié' THEN d.objectid
                        WHEN a.genre IS NULL AND d.valeur = 'non-renseigné'THEN d.objectid
                    END AS GENRE,
                    a.CDTSVOI AS DATE_SAISIE,
                    a.CDTMVOI AS DATE_MODIFICATION,
                    e.numero_agent AS fid_pnom_saisie,
                    e.numero_agent AS fid_pnom_modification
                FROM
                    G_BASE_VOIE.TEMP_VOIEVOI a
                    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.code_type_voie = a.ccodtvo,
                    G_BASE_VOIE.TA_LIBELLE d,
                    G_BASE_VOIE.TA_AGENT e
                WHERE
                    a.ccomvoi IS NOT NULL 
                    AND e.pnom = 'import_donnees'
                )
            SELECT *
            FROM
                C_1
            WHERE
                GENRE IS NOT NULL;
                
    -- 21. Mise à jour de la clé étrangère TA_VOIE.FID_RIVOLI 
    -- 21.1. Pour les voies disposant d'un code fantoir complet
    MERGE INTO G_BASE_VOIE.TA_VOIE a
    USING(
        SELECT
            b.ccomvoi,
            a.objectid
        FROM
            G_BASE_VOIE.TA_RIVOLI a
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccodrvo = a.code_rivoli
        WHERE
            a.cle_controle IS NULL
            AND b.temp_code_fantoir IS NULL
    )t
    ON (a.objectid = t.ccomvoi)
    WHEN MATCHED THEN
    UPDATE SET a.fid_rivoli = t.objectid;
     
    -- 21.2. Pour les voies dont le code fantoir ne disposant pas de clé de contrôle
    MERGE INTO G_BASE_VOIE.TA_VOIE a
    USING(
        SELECT
            b.ccomvoi,
            a.objectid
        FROM
            G_BASE_VOIE.TA_RIVOLI a
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON SUBSTR(b.temp_code_fantoir, 4, 5) = a.code_rivoli || a.cle_controle
        WHERE
            a.cle_controle IS NOT NULL
            AND b.temp_code_fantoir IS NOT NULL
    )t
    ON (a.objectid = t.ccomvoi)
    WHEN MATCHED THEN
    UPDATE SET a.fid_rivoli = t.objectid;

    -- 22. Import dans la table TA_VOIE_LOG des données de TA_VOIE
    -- 22.1. Pour la création des voies valides ET invalides
    MERGE INTO G_BASE_VOIE.TA_VOIE_LOG a
    USING(
        SELECT DISTINCT
            a.objectid,
            a.libelle_voie,
            a.complement_nom_voie,
            a.fid_typevoie,
            a.fid_genre_voie,
            a.fid_rivoli,
            a.date_saisie AS DATE_ACTION,
            c.objectid AS fid_type_action,
            d.numero_agent AS fid_pnom
        FROM
            G_BASE_VOIE.TA_VOIE a
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccomvoi = a.objectid,
            G_BASE_VOIE.TA_LIBELLE c,
            G_BASE_VOIE.TA_AGENT d                  
        WHERE
            c.valeur = 'insertion'
            AND d.pnom = 'import_donnees'
    )t
    ON (a.fid_voie = t.objectid)
    WHEN NOT MATCHED THEN
        INSERT(libelle_voie, complement_nom_voie, date_action, fid_typevoie, fid_genre_voie, fid_rivoli, fid_voie, fid_type_action, fid_pnom)
        VALUES(t.libelle_voie, t.complement_nom_voie, t.date_action, t.fid_typevoie, t.fid_genre_voie, t.fid_rivoli, t.objectid, t.fid_type_action, t.fid_pnom);

    -- 22.2. Pour la modification des voies valides
    MERGE INTO G_BASE_VOIE.TA_VOIE_LOG a
    USING(
        SELECT DISTINCT
            a.objectid,
            a.libelle_voie,
            a.complement_nom_voie,
            a.fid_typevoie,
            a.fid_genre_voie,
            a.fid_rivoli,
            a.date_modification AS DATE_ACTION,
            c.objectid AS fid_type_action,
            d.numero_agent AS fid_pnom
        FROM
            G_BASE_VOIE.TA_VOIE a
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccomvoi = a.objectid,
            G_BASE_VOIE.TA_LIBELLE c,
            G_BASE_VOIE.TA_AGENT d                  
        WHERE
            c.valeur = 'édition'
            AND d.pnom = 'import_donnees'
            AND b.cdvalvoi = 'V'
    )t
    ON (t.fid_type_action <> (SELECT objectid FROM G_BASE_VOIE.TA_LIBELLE WHERE valeur = 'édition'))
    WHEN NOT MATCHED THEN
        INSERT(libelle_voie, complement_nom_voie, date_action, fid_typevoie, fid_genre_voie, fid_rivoli, fid_voie, fid_type_action, fid_pnom)
        VALUES(t.libelle_voie, t.complement_nom_voie, t.date_action, t.fid_typevoie, t.fid_genre_voie, t.fid_rivoli, t.objectid, t.fid_type_action, t.fid_pnom);

    -- 22.3. Pour la suppression des voies invalides
    MERGE INTO G_BASE_VOIE.TA_VOIE_LOG a
    USING(
        SELECT DISTINCT
            a.objectid,
            a.libelle_voie,
            a.complement_nom_voie,
            a.fid_typevoie,
            a.fid_genre_voie,
            a.fid_rivoli,
            a.date_modification AS DATE_ACTION,
            c.objectid AS fid_type_action,
            d.numero_agent AS fid_pnom
        FROM
            G_BASE_VOIE.TA_VOIE a
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccomvoi = a.objectid,
            G_BASE_VOIE.TA_LIBELLE c,
            G_BASE_VOIE.TA_AGENT d                  
        WHERE
            c.valeur = 'suppression'
            AND d.pnom = 'import_donnees'
            AND b.cdvalvoi = 'I'
    )t
    ON (t.fid_type_action <> (SELECT objectid FROM G_BASE_VOIE.TA_LIBELLE WHERE valeur = 'suppression'))
    WHEN NOT MATCHED THEN
        INSERT(libelle_voie, complement_nom_voie, date_action, fid_typevoie, fid_genre_voie, fid_rivoli, fid_voie, fid_type_action, fid_pnom)
        VALUES(t.libelle_voie, t.complement_nom_voie, t.date_action, t.fid_typevoie, t.fid_genre_voie, t.fid_rivoli, t.objectid, t.fid_type_action, t.fid_pnom);

    -- 23. Suppression des voies invalides dans la table TA_VOIE
    DELETE
    FROM
        G_BASE_VOIE.TA_VOIE
    WHERE
        objectid IN(
            SELECT
                a.ccomvoi
            FROM
                G_BASE_VOIE.TEMP_VOIEVOI a
                INNER JOIN G_BASE_VOIE.TA_VOIE b ON b.objectid = a.ccomvoi
            WHERE
                a.cdvalvoi = 'I'
        );

    -- 24. Réactivation des triggers pour les voies
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_VOIE_LOG ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_VOIE_DATE_PNOM ENABLE';

    -- 25. Désactivation du trigger de log de la table TA_RELATION_TRONCON_VOIE
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_RELATION_TRONCON_VOIE_LOG DISABLE';

    -- 26. Désactivation des contraintes de clé trangère de la table TA_RELATION_TRONCON_VOIE   
    -- 26.1. Sélection du nom de la contrainte de FK du champ FID_TRONCON
    SELECT
        CONSTRAINT_NAME
        INTO v_contrainte
    FROM
        USER_CONSTRAINTS
    WHERE
        TABLE_NAME = 'TA_RELATION_TRONCON_VOIE'
        AND R_CONSTRAINT_NAME = 'TA_TRONCON_PK';
    
    -- 26.2. Désactivation de la contrainte de FK du champ FID_TRONCON    
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE DISABLE CONSTRAINT ' || v_contrainte;

    -- 26.3. Sélection du nom de la contrainte de FK du champ FID_VOIE
    SELECT
        CONSTRAINT_NAME
        INTO v_contrainte
    FROM
        USER_CONSTRAINTS
    WHERE
        TABLE_NAME = 'TA_RELATION_TRONCON_VOIE'
        AND R_CONSTRAINT_NAME = 'TA_VOIE_PK';

    -- 26.4. Désactivation de la contrainte de FK du champ FID_VOIE    
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE DISABLE CONSTRAINT ' || v_contrainte;
    
    -- 27. Import des relations tronçon/voie invalides dans TA_RELATION_TRONCON_VOIE
    INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE(FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON, DATE_SAISIE, DATE_MODIFICATION, FID_PNOM_SAISIE, FID_PNOM_MODIFICATION) 
        SELECT
            a.cnumtrc,
            a.ccomvoi,
            a.ccodstr,
            a.cnumtrv,
            a.cdtscvt,
            a.cdtmcvt,
            f.numero_agent AS fid_pnom_saisie,
            f.numero_agent AS fid_pnom_modification
        FROM
            G_BASE_VOIE.TEMP_VOIECVT a
            INNER JOIN G_BASE_VOIE.TA_TRONCON_LOG b ON a.cnumtrc = b.fid_troncon
            INNER JOIN G_BASE_VOIE.TA_VOIE_LOG c ON c.fid_voie = a.ccomvoi
            INNER JOIN G_BASE_VOIE.TA_LIBELLE d ON d.objectid = b.fid_type_action
            INNER JOIN G_BASE_VOIE.TA_LIBELLE e ON d.objectid = c.fid_type_action,
            G_BASE_VOIE.TA_AGENT f
        WHERE
            a.CVALIDE = 'I'
            AND d.valeur = 'insertion'
            AND e.valeur = 'insertion'
            AND f.pnom = 'import_donnees';
    
    -- 28. Import des relations tronçons/voies invalides dans TA_RELATION_TRONCON_VOIE_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG(FID_RELATION_TRONCON_VOIE, FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON, DATE_ACTION, FID_TYPE_ACTION, FID_PNOM) 
        SELECT
            a.objectid,
            a.fid_troncon,
            a.fid_voie,
            a.sens,
            a.ordre_troncon,
            a.date_saisie AS date_action,
            d.objectid AS fid_type_action,
            e.numero_agent AS fid_pnom
        FROM
            G_BASE_VOIE.TA_RELATION_TRONCON_VOIE a,
            G_BASE_VOIE.TA_LIBELLE d,
            G_BASE_VOIE.TA_AGENT e
        WHERE
            d.valeur = 'insertion'
            AND e.pnom = 'import_donnees';
            
    -- 31. Import des relations tronçons/voies invalides dans TA_RELATION_TRONCON_VOIE_LOG pour la modification
    INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG(FID_RELATION_TRONCON_VOIE, FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON, DATE_ACTION, FID_TYPE_ACTION, FID_PNOM) 
        SELECT DISTINCT
            a.objectid,
            a.fid_troncon,
            a.fid_voie,
            a.sens,
            a.ordre_troncon,
            a.date_modification AS date_action,
            d.objectid AS fid_type_action,
            e.numero_agent AS fid_pnom
        FROM
            G_BASE_VOIE.TA_RELATION_TRONCON_VOIE a,
            G_BASE_VOIE.TA_LIBELLE d,
            G_BASE_VOIE.TA_AGENT e
        WHERE
            d.valeur = 'suppression'
            AND e.pnom = 'import_donnees';
            
    -- 32. Suppression des relations troncon/voie invalides de la table TA_RELATION_TRONCON_VOIE
    DELETE
    FROM
        G_BASE_VOIE.TA_RELATION_TRONCON_VOIE;

    -- 33. Import des relations tronçons/voies dans la table TA_RELATION_TRONCON_VOIE
    INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE(FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON, DATE_SAISIE, DATE_MODIFICATION, FID_PNOM_SAISIE, FID_PNOM_MODIFICATION)
    SELECT
        a.objectid AS fid_troncon,
        c.objectid AS fid_voie,
        b.CCODSTR AS sens,
        b.CNUMTRV AS ordre_troncon,
        b.cdtscvt AS date_saisie,
        b.cdtmcvt AS date_modification,
        d.numero_agent AS fid_pnom_saisie,
        d.numero_agent AS fid_pnom_modification
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.objectid
        INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = b.ccomvoi,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        b.CVALIDE = 'V'
        AND d.pnom = 'import_donnees';

    -- 34. Import des relations tronçons/voies valides dans la table TA_RELATION_TRONCON_VOIE_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG(FID_RELATION_TRONCON_VOIE, FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON, DATE_ACTION, FID_TYPE_ACTION, FID_PNOM)
    SELECT
        a.objectid AS fid_relation_troncon_voie,
        a.fid_troncon,
        a.fid_voie,
        a.sens,
        a.ordre_troncon,
        a.date_saisie,
        e.objectid AS fid_type_action,
        f.numero_agent AS fid_pnom
    FROM
        G_BASE_VOIE.TA_RELATION_TRONCON_VOIE a,
        G_BASE_VOIE.TA_LIBELLE e,
        G_BASE_VOIE.TA_AGENT f
    WHERE
        f.pnom = 'import_donnees'
        AND e.valeur = 'insertion';

    -- 35. Import des relations tronçons/voies valides dans la table TA_RELATION_TRONCON_VOIE_LOG pour la modification
    INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG(FID_RELATION_TRONCON_VOIE, FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON, DATE_ACTION, FID_TYPE_ACTION, FID_PNOM)
    SELECT
        a.objectid AS fid_relation_troncon_voie,
        a.fid_troncon,
        a.fid_voie,
        a.sens,
        a.ordre_troncon,
        a.date_modification,
        e.objectid AS fid_type_action,
        f.numero_agent AS fid_pnom
    FROM
        G_BASE_VOIE.TA_RELATION_TRONCON_VOIE a,
        G_BASE_VOIE.TA_LIBELLE e,
        G_BASE_VOIE.TA_AGENT f
    WHERE
        f.pnom = 'import_donnees'
        AND e.valeur = 'édition';

    -- 36. Réactivation des contraintes et triggers gérant les relations tronçons/voies
    -- 36.1. Réactivation du trigger de log de la table TA_RELATION_TRONCON_VOIE
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_RELATION_TRONCON_VOIE_LOG ENABLE';

    -- 36.3. Réactivation des contraintes de clé étrangère de la table TA_RELATION_TRONCON_VOIE   
    -- 36.3.1 Sélection du nom de la contrainte de FK du champ FID_TRONCON
    SELECT
        CONSTRAINT_NAME
        INTO v_contrainte
    FROM
        USER_CONSTRAINTS
    WHERE
        TABLE_NAME = 'TA_RELATION_TRONCON_VOIE'
        AND R_CONSTRAINT_NAME = 'TA_TRONCON_PK';
    
    -- 36.3.2. Réactivation de la contrainte de FK du champ FID_TRONCON    
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE ENABLE CONSTRAINT ' || v_contrainte;

    -- 36.3.3. Sélection du nom de la contrainte de FK du champ FID_VOIE
    SELECT
        CONSTRAINT_NAME
        INTO v_contrainte
    FROM
        USER_CONSTRAINTS
    WHERE
        TABLE_NAME = 'TA_RELATION_TRONCON_VOIE'
        AND R_CONSTRAINT_NAME = 'TA_VOIE_PK';

    -- 36.3.4. Réactivation de la contrainte de FK du champ FID_VOIE    
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE ENABLE CONSTRAINT ' || v_contrainte;

    -- 36. Insertion des seuils
    -- 36.1. Désactivation du trigger de remplissage des tables de logs et des dates/pnoms pour les seuils
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_SEUIL_LOG DISABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_INFOS_SEUIL_LOG DISABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_INFOS_SEUIL_DATE_PNOM DISABLE';

    -- 36.2. Insertion d'un seul point géométrique par groupe de seuils dans un rayon de 50cm max dans la table TA_SEUIL
    INSERT INTO G_BASE_VOIE.TA_SEUIL(geom)
    SELECT
        a.ora_geometry
    FROM
        G_BASE_VOIE.TEMP_FUSION_SEUIL a;

    -- 36.3. Insertion des infos des seuils dans la table TA_INFOS_SEUIL
    INSERT INTO G_BASE_VOIE.TA_INFOS_SEUIL(objectid, numero_seuil, numero_parcelle, complement_numero_seuil, fid_seuil, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification)
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
        G_BASE_VOIE.TEMP_ILTASEU a,
        G_BASE_VOIE.TA_SEUIL b,
        G_BASE_VOIE.TA_AGENT c
    WHERE
        SDO_WITHIN_DISTANCE(b.geom, a.ora_geometry, 'DISTANCE=0.50') = 'TRUE'
        AND c.pnom = 'import_donnees';

    -- 36.4. Désactivation du trigger B_IUX_TA_SEUIL_DATE_PNOM
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_SEUIL_DATE_PNOM DISABLE';
    
    -- 36.6. Insertion des autres points géométriques des seuils dans TA_SEUIL
        INSERT INTO G_BASE_VOIE.TA_SEUIL(geom, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification, temp_idseui)
        SELECT
            a.ora_geometry,
            a.cdtsseuil,
            a.cdtmseuil,
            b.numero_agent AS fid_pnom_saisie,
            b.numero_agent AS fid_pnom_modification,
            a.idseui
        FROM
            G_BASE_VOIE.TEMP_ILTASEU a,
            G_BASE_VOIE.TA_AGENT b
        WHERE
            a.idseui NOT IN(SELECT objectid FROM G_BASE_VOIE.TA_INFOS_SEUIL)
            AND b.pnom = 'import_donnees';
    
    -- 36.7. Import des infos des seuils dans TA_INFOS_SEUIL pour les seuils non-concernés par la fusion
        INSERT INTO G_BASE_VOIE.TA_INFOS_SEUIL(objectid, numero_seuil, numero_parcelle, complement_numero_seuil, fid_seuil, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification)
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
            G_BASE_VOIE.TEMP_ILTASEU a
            INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.temp_idseui = a.idseui,
            G_BASE_VOIE.TA_AGENT c
        WHERE
            c.pnom = 'import_donnees';

    -- 37. Import des relation tronçons - seuils dans TA_RELATION_TRONCON_SEUIL
    INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL(fid_seuil, fid_troncon)
    SELECT DISTINCT
        a.objectid AS fid_seuil,
        d.objectid AS fid_troncon
    FROM
        G_BASE_VOIE.TA_SEUIL a
        INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL b ON b.fid_seuil = a.objectid
        INNER JOIN G_BASE_VOIE.TEMP_ILTASIT c ON c.idseui = b.objectid
        INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = c.cnumtrc;

    -- 38. Insertion des points d'intérêt
    -- 38.1. Désactivation du trigger de remplissage de la table de log
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_POINT_INTERET_LOG DISABLE';

    -- 38.2. Import des données invalides dans la table TA_POINT_INTERET
    INSERT INTO G_BASE_VOIE.TA_POINT_INTERET(objectid, geom, complement_infos, nom, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification, fid_libelle)
    SELECT
        a.cnumlpu,
        a.ora_geometry,
        a.cinfos,
        a.cliblpu,
        a.cdtslpu,
        a.cdtmlpu,
        c.numero_agent AS fid_pnom_saisie,
        c.numero_agent AS fid_pnom_modification,
        b.objectid
    FROM
        G_BASE_VOIE.TEMP_ILTALPU a
        INNER JOIN G_BASE_VOIE.TA_LIBELLE b ON UPPER(b.valeur) = a.libelle_court,
        G_BASE_VOIE.TA_AGENT c
    WHERE
        b.valeur IN('mairie', 'mairie annexe', 'mairie quartier')
        AND c.numero_agent = 99999
        AND a.cdvallpu = 'I';

    -- 38.3. Import des POI invalides dans TA_POINT_INTERET_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_POINT_INTERET_LOG(GEOM, COMPLEMENT_INFOS, CODE_INSEE, NOM, DATE_ACTION, FID_LIBELLE, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.geom,
        a.complement_infos,
        a.code_insee,
        a.nom,
        a.date_saisie,
        a.fid_libelle,
        a.objectid,
        b.objectid,
        c.numero_agent
    FROM
        G_BASE_VOIE.TA_POINT_INTERET a,
        G_BASE_VOIE.TA_LIBELLE b,
        G_BASE_VOIE.TA_AGENT c
    WHERE
        c.pnom = 'import_donnees'
        AND b.valeur = 'insertion';

    -- 38.4. Import des POI invalides dans TA_POINT_INTERET_LOG pour la suppression
    INSERT INTO G_BASE_VOIE.TA_POINT_INTERET_LOG(GEOM, COMPLEMENT_INFOS, CODE_INSEE, NOM, DATE_ACTION, FID_LIBELLE, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.geom,
        a.complement_infos,
        a.code_insee,
        a.nom,
        a.date_modification,
        a.fid_libelle,
        a.objectid,
        b.objectid,
        c.numero_agent
    FROM
        G_BASE_VOIE.TA_POINT_INTERET a,
        G_BASE_VOIE.TA_LIBELLE b,
        G_BASE_VOIE.TA_AGENT c
    WHERE
        c.pnom = 'import_donnees'
        AND b.valeur = 'suppression';

    -- 38.5. Suppression des POI invalides dans la table TA_POINT_INTERET
    DELETE FROM G_BASE_VOIE.TA_POINT_INTERET;

    -- 38.6. Insertion des données valides dans la table TA_POINT_INTERET
    INSERT INTO G_BASE_VOIE.TA_POINT_INTERET(objectid, geom, complement_infos, nom, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification, fid_libelle)
    SELECT
        a.cnumlpu,
        a.ora_geometry,
        a.cinfos,
        a.cliblpu,
        a.cdtslpu,
        a.cdtmlpu,
        c.numero_agent AS fid_pnom_saisie,
        c.numero_agent AS fid_pnom_modification,
        b.objectid
    FROM
        G_BASE_VOIE.TEMP_ILTALPU a
        INNER JOIN G_BASE_VOIE.TA_LIBELLE b ON UPPER(b.valeur) = a.libelle_court,
        G_BASE_VOIE.TA_AGENT c
    WHERE
        b.valeur IN('mairie', 'mairie annexe', 'mairie quartier')
        AND c.numero_agent = 99999
        AND a.cdvallpu = 'V';

    -- 38.7. Import des POI invalides dans TA_POINT_INTERET_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_POINT_INTERET_LOG(GEOM, COMPLEMENT_INFOS, CODE_INSEE, NOM, DATE_ACTION, FID_LIBELLE, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.geom,
        a.complement_infos,
        a.code_insee,
        a.nom,
        a.date_saisie,
        a.fid_libelle,
        a.objectid,
        b.objectid,
        c.numero_agent
    FROM
        G_BASE_VOIE.TA_POINT_INTERET a,
        G_BASE_VOIE.TA_LIBELLE b,
        G_BASE_VOIE.TA_AGENT c
    WHERE
        c.pnom = 'import_donnees'
        AND b.valeur = 'insertion';

    -- 38.8. Import des POI invalides dans TA_POINT_INTERET_LOG pour la suppression
    INSERT INTO G_BASE_VOIE.TA_POINT_INTERET_LOG(GEOM, COMPLEMENT_INFOS, CODE_INSEE, NOM, DATE_ACTION, FID_LIBELLE, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.geom,
        a.complement_infos,
        a.code_insee,
        a.nom,
        a.date_modification,
        a.fid_libelle,
        a.objectid,
        b.objectid,
        c.numero_agent
    FROM
        G_BASE_VOIE.TA_POINT_INTERET a,
        G_BASE_VOIE.TA_LIBELLE b,
        G_BASE_VOIE.TA_AGENT c
    WHERE
        c.pnom = 'import_donnees'
        AND b.valeur = 'édition';

    -- 39. Réactivation de tous les triggers désactivés au cours de la procédure
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_POINT_INTERET_LOG ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_TRONCON_LOG ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_SEUIL_LOG ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_SEUIL_DATE_PNOM ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_INFOS_SEUIL_LOG ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_INFOS_SEUIL_DATE_PNOM ENABLE';

    -- 40. Réactivation de la contrainte de non-nullité du champ TA_TYPE_VOIE.LIBELLE
    SELECT
        CONSTRAINT_NAME
        INTO v_contrainte
    FROM
        USER_CONSTRAINTS
    WHERE
        TABLE_NAME = 'TA_TYPE_VOIE'
        AND CONSTRAINT_TYPE = 'C'
        AND SEARCH_CONDITION_VC LIKE '%LIBELLE%';

    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_TYPE_VOIE ENABLE CONSTRAINT ' || v_contrainte;

    -- En cas d'erreur une exception est levée et un rollback effectué, empêchant ainsi toute insertion de se faire et de retourner à l'état des tables précédent l'insertion.
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('L''erreur ' || SQLCODE || 'est survenue. Un rollback a été effectué : ' || SQLERRM(SQLCODE));
            ROLLBACK TO POINT_SAUVEGARDE_REMPLISSAGE;
END;