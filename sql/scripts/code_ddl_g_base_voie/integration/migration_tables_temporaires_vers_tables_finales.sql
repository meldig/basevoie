/*
Import des données corrigées des tables temporaires vers les tables finales de la base voie.
*/

SET SERVEROUTPUT ON
DECLARE
    v_nbr_objectid NUMBER(38,0);
    v_contrainte VARCHAR2(100);
    v_mtd NUMBER(38,0);
BEGIN

    SAVEPOINT POINT_SAUVEGARDE_REMPLISSAGE;
    
    -- 0. Sélection des métadonnées de la abse voie de la MEL afin de créer une valeur par défaut pour le champ fid_metadonnee de TA_TRONCON et TA_VOIE
    -- 0.1. Sélection de l'identifiant de la MTD
    SELECT
        a.objectid
        INTO v_mtd
    FROM
        G_GEO.TA_METADONNEE a
        INNER JOIN G_GEO.TA_SOURCE b ON b.objectid = a.fid_source
        INNER JOIN G_GEO.TA_METADONNEE_RELATION_ORGANISME c ON c.fid_metadonnee = a.objectid
        INNER JOIN G_GEO.TA_ORGANISME d ON d.objectid = c.fid_organisme
    WHERE
        UPPER(d.acronyme) = UPPER('mel')
        AND UPPER(b.nom_source) = UPPER('base voie');

    -- 0.2. Modification des codes DDL de TA_TRONCON et TA_VOIE
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_TRONCON MODIFY FID_METADONNEE NUMBER(38,0) DEFAULT ' || v_mtd;
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_VOIE MODIFY FID_METADONNEE NUMBER(38,0) DEFAULT ' || v_mtd;

    -- 1. Import des données des agents de la base voie + gestionnaires de données
    INSERT INTO G_BASE_VOIE.TA_AGENT(numero_agent, pnom, validite)
    SELECT numero_agent, pnom, validite FROM TEMP_AGENT;

    -- 5. Insertion du code fantoir dans TEMP_VOIEVOI
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TEMP_VOIEVOI ADD temp_code_fantoir CHAR(11)';
    --COMMENT ON COLUMN G_BASE_VOIE.TEMP_VOIEVOI.temp_code_fantoir IS 'Champ temporaire contenant le VRAI code fantoir des voies.';

    MERGE INTO G_BASE_VOIE.TEMP_VOIEVOI a
    USING(
        SELECT
            b.ccomvoi,
            CASE
                WHEN LENGTH(b.cnumcom) = 2 THEN '0' || b.cnumcom || b.ccodrvo || c.cle_controle
                WHEN LENGTH(b.cnumcom) = 1 THEN '00' || b.cnumcom || b.ccodrvo || c.cle_controle
            ELSE
                b.cnumcom || b.ccodrvo || c.cle_controle
            END AS code_fantoir_et_cle_ctrl
        FROM
            G_BASE_VOIE.TEMP_VOIEVOI b
            INNER JOIN G_BASE_VOIE.TEMP_CODE_FANTOIR c ON SUBSTR(c.code_fantoir, 4, 7) = (CASE 
                                                                                                WHEN LENGTH(b.cnumcom) = 2 THEN '0' || b.cnumcom || b.ccodrvo
                                                                                                WHEN LENGTH(b.cnumcom) = 1 THEN '00' || b.cnumcom || b.ccodrvo
                                                                                                WHEN LENGTH(b.cnumcom) = 3 THEN b.cnumcom || b.ccodrvo
                                                                                            END
                                                                                            )
            
    )t
    ON (a.ccomvoi = t.ccomvoi)
    WHEN MATCHED THEN
        UPDATE SET a.temp_code_fantoir = t.code_fantoir_et_cle_ctrl;

    -- 6. Insertion des codes rivoli dans TA_RIVOLI
    -- 6.1. Insertion des codes rivoli complet (avec clé)
    INSERT INTO G_BASE_VOIE.TA_RIVOLI(code_rivoli, cle_controle)
    SELECT DISTINCT
        SUBSTR(temp_code_fantoir, 4, 4) AS rivoli,
        SUBSTR(temp_code_fantoir, 8, 1) AS cle_f
    FROM
        G_BASE_VOIE.TEMP_VOIEVOI
    WHERE
        temp_code_fantoir IS NOT NULL;
        
    -- 6.2. Insertion de tous les autres codes rivoli (sans clé)
    INSERT INTO G_BASE_VOIE.TA_RIVOLI(code_rivoli)
    SELECT DISTINCT
        ccodrvo
    FROM
        G_BASE_VOIE.TEMP_VOIEVOI
    WHERE
        temp_code_fantoir IS NULL;

    -- 7. Désactivation des triggers pour les tronçons
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_TRONCON_LOG DISABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_TRONCON_DATE_PNOM DISABLE';
    
    -- 8. Import des tronçons valides dans TA_TRONCON
    INSERT INTO G_BASE_VOIE.TA_TRONCON(objectid, geom, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification, fid_metadonnee)
    SELECT
        a.cnumtrc,
        a.ora_geometry,
        a.cdtstrc,
        a.cdtmtrc,
        b.numero_agent AS fid_pnom_saisie,
        b.numero_agent AS fid_pnom_modification,
        c.objectid AS fid_metadonnee
    FROM
        G_BASE_VOIE.TEMP_ILTATRC a,
        G_BASE_VOIE.TA_AGENT b,
        G_GEO.TA_METADONNEE c
        INNER JOIN G_GEO.TA_SOURCE d ON d.objectid = c.fid_source
        INNER JOIN G_GEO.TA_METADONNEE_RELATION_ORGANISME e ON e.fid_metadonnee = c.objectid
        INNER JOIN G_GEO.TA_ORGANISME f ON f.objectid = e.fid_organisme
    WHERE
        a.cdvaltro = 'V'
        AND b.pnom = 'import_donnees'
        AND UPPER(f.acronyme) = UPPER('MEL')
        AND UPPER(d.nom_source) = UPPER('base voie');
        
    -- 9. Import des tronçons valides dans TA_TRONCON_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(geom, fid_troncon, date_action, fid_type_action, fid_pnom, fid_metadonnee)
    SELECT
        a.geom,
        a.objectid,
        b.cdtstrc,
        e.objectid,
        c.numero_agent,
        a.fid_metadonnee
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid,
        G_BASE_VOIE.TA_AGENT c,
        G_GEO.TA_LIBELLE_LONG d
        INNER JOIN G_GEO.TA_LIBELLE e ON e.fid_libelle_long = d.objectid
    WHERE
        b.cdvaltro = 'V'
        AND c.pnom = 'import_donnees'
        AND UPPER(d.valeur) = UPPER('insertion');

    -- 10. Insertion des dates de modification dans TA_TRONCON_LOG pour la modification
    INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(geom, fid_troncon, date_action, fid_type_action, fid_pnom, fid_metadonnee)
    SELECT
        a.geom,
        a.objectid,
        b.cdtmtrc,
        e.objectid,
        c.numero_agent,
        a.fid_metadonnee
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid,
        G_BASE_VOIE.TA_AGENT c,
        G_GEO.TA_LIBELLE_LONG d
        INNER JOIN G_GEO.TA_LIBELLE e ON e.fid_libelle_long = d.objectid
    WHERE
        b.cdvaltro = 'V'
        AND c.pnom = 'import_donnees'
        AND UPPER(d.valeur) = UPPER('édition');

    -- 11. Import des tronçons invalides dans TA_TRONCON pour la création
    INSERT INTO G_BASE_VOIE.TA_TRONCON(objectid, geom, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification, fid_metadonnee)
    SELECT
        a.cnumtrc,
        a.ora_geometry,
        a.cdtstrc,
        a.cdtmtrc,
        b.numero_agent AS fid_pnom_saisie,
        b.numero_agent AS fid_pnom_modification,
        c.objectid AS fid_metadonnee
    FROM
        G_BASE_VOIE.TEMP_ILTATRC a,
        G_BASE_VOIE.TA_AGENT b,
        G_GEO.TA_METADONNEE c
        INNER JOIN G_GEO.TA_SOURCE d ON d.objectid = c.fid_source
        INNER JOIN G_GEO.TA_METADONNEE_RELATION_ORGANISME e ON e.fid_metadonnee = c.objectid
        INNER JOIN G_GEO.TA_ORGANISME f ON f.objectid = e.fid_organisme
    WHERE
        a.cdvaltro = 'F'
        AND b.pnom = 'import_donnees'
        AND UPPER(f.acronyme) = UPPER('MEL')
        AND UPPER(d.nom_source) = UPPER('base voie');

    -- 12. Import des tronçons invalides dans TA_TRONCON_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(geom, fid_troncon, date_action, fid_type_action, fid_pnom, fid_metadonnee)
    SELECT
        a.geom,
        a.objectid,
        b.cdtstrc,
        e.objectid,
        c.numero_agent,
        a.fid_metadonnee
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid,
        G_BASE_VOIE.TA_AGENT c,
        G_GEO.TA_LIBELLE_LONG d
        INNER JOIN G_GEO.TA_LIBELLE e ON e.fid_libelle_long = d.objectid
    WHERE
        b.cdvaltro = 'F'
        AND c.pnom = 'import_donnees'
        AND UPPER(d.valeur) = UPPER('insertion');

    -- 13. Insertion des dates de modification dans TA_TRONCON_LOG pour la suppression des tronçons invalides
    INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(geom, fid_troncon, date_action, fid_type_action, fid_pnom, fid_metadonnee)
    SELECT
        a.geom,
        a.objectid,
        b.cdtmtrc,
        e.objectid,
        c.numero_agent,
        a.fid_metadonnee
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid,
        G_BASE_VOIE.TA_AGENT c,
        G_GEO.TA_LIBELLE_LONG d
        INNER JOIN G_GEO.TA_LIBELLE e ON e.fid_libelle_long = d.objectid
    WHERE
        b.cdvaltro = 'F'
        AND c.pnom = 'import_donnees'
        AND UPPER(d.valeur) = UPPER('suppression');

    -- 14. Suppression des tronçons invalides dans la table TA_TRONCON
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

    -- 15. Modification du numéro de départ de l'incrémentation du champ TA_TRONCON.objectid
    SELECT
        MAX(objectid)+1
        INTO v_nbr_objectid
    FROM
        G_BASE_VOIE.TA_TRONCON;
    
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_TRONCON MODIFY objectid GENERATED BY DEFAULT AS IDENTITY (START WITH ' || v_nbr_objectid  || ' INCREMENT BY 1)';
    
    -- 16. Réactivation des triggers pour les tronçons
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_TRONCON_LOG ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_TRONCON_DATE_PNOM ENABLE';
    
    -- 17. Désactivation de la contrainte de non-nullité du champ TA_TYPE_VOIE.LIBELLE
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
    --ALTER TABLE G_BASE_VOIE.TA_TYPE_VOIE DISABLE CONSTRAINT SYS_C00449210;

    -- 18. Import des données dans TA_TYPE_VOIE
    -- 18.1. Import des type présents dans TYPEVOIE
    INSERT INTO G_BASE_VOIE.TA_TYPE_VOIE(code_type_voie, libelle)
    SELECT
        CCODTVO,
        LITYVOIE
    FROM
        G_BASE_VOIE.TEMP_TYPEVOIE
    WHERE
        LITYVOIE IS NOT NULL;

    INSERT INTO G_BASE_VOIE.TA_TYPE_VOIE(code_type_voie, libelle)
    SELECT
        CCODTVO,
        'Libellé non-renseigné avant la migration'
    FROM
        G_BASE_VOIE.TEMP_TYPEVOIE
    WHERE
        LITYVOIE IS NULL;
    
    -- 18.2. Import des types de voies présents dans VOIEVOI mais absents de TYPEVOIE
    INSERT INTO G_BASE_VOIE.TA_TYPE_VOIE(code_type_voie, libelle)
    SELECT DISTINCT
        a.ccodtvo,
        'type de voie présent dans VOIEVOI mais pas dans TYPEVOIE lors de la migration'
    FROM
        TEMP_VOIEVOI a
    WHERE
        a.ccodtvo NOT IN(SELECT code_type_voie FROM TA_TYPE_VOIE);

    -- 19. Désactivation des triggers pour les voies
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_VOIE_LOG DISABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_VOIE_DATE_PNOM DISABLE';
               
    -- 20. Mise à jour des champs NULL pour les voies invalides
    -- 20.1. Mise à jour du champ "GENRE" de la table TEMP_VOIEVOI en 'NI' (non-identifié) dans TEMP_VOIEVOI pour les voies invalides dont le champ "GENRE" est NULL
    UPDATE G_BASE_VOIE.TEMP_VOIEVOI
    SET GENRE = 'NI'
    WHERE
        CDVALVOI = 'I'
        AND GENRE IS NULL;

    -- 20.2. Mise à jour du champ "CNOMINUS" de la table TEMP_VOIEVOI en 'aucun nom lors de la migration en base' pour toutes les voies ne disposant pas de nom dans "CNOMINUS".
    UPDATE G_BASE_VOIE.TEMP_VOIEVOI
    SET CNOMINUS = 'aucun nom lors de la migration en base'
    WHERE
        CNOMINUS IS NULL;

    -- 21. Import de toutes les voies valides et invalides dans TA_VOIE
    INSERT INTO G_BASE_VOIE.TA_VOIE(FID_TYPEVOIE, OBJECTID, COMPLEMENT_NOM_VOIE, LIBELLE_VOIE, FID_GENRE_VOIE, DATE_SAISIE, DATE_MODIFICATION, FID_PNOM_SAISIE, FID_PNOM_MODIFICATION, FID_METADONNEE)
            WITH C_1 AS(
                SELECT DISTINCT
                    b.objectid AS FID_TYPE_VOIE,
                    a.CCOMVOI AS NUMERO_VOIE,
                    a.CINFOS AS COMPLEMENT_NOM_VOIE,
                    a.CNOMINUS AS LIBELLE,
                    CASE
                        WHEN a.genre = 'M' AND UPPER(d.valeur) = UPPER('masculin') THEN e.objectid
                        WHEN a.genre = 'F' AND UPPER(d.valeur) = UPPER('féminin') THEN e.objectid
                        WHEN a.genre = 'N' AND UPPER(d.valeur) = UPPER('neutre') THEN e.objectid
                        WHEN a.genre = 'C' AND UPPER(d.valeur) = UPPER('couple') THEN e.objectid
                        WHEN a.genre = 'NI' AND UPPER(d.valeur) = UPPER('non-identifié') THEN e.objectid
                        WHEN a.genre IS NULL AND UPPER(d.valeur) = UPPER('non-renseigné') THEN e.objectid
                    END AS GENRE,
                    a.CDTSVOI AS DATE_SAISIE,
                    a.CDTMVOI AS DATE_MODIFICATION,
                    f.numero_agent AS fid_pnom_saisie,
                    f.numero_agent AS fid_pnom_modification,
                    g.objectid AS fid_metadonnee
                FROM
                    G_BASE_VOIE.TEMP_VOIEVOI a
                    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.code_type_voie = a.ccodtvo,
                    G_GEO.TA_LIBELLE_LONG d
                    INNER JOIN G_GEO.TA_LIBELLE e ON e.fid_libelle_long = d.objectid,
                    G_BASE_VOIE.TA_AGENT f,
                    G_GEO.TA_METADONNEE g
                    INNER JOIN G_GEO.TA_SOURCE h ON h.objectid = g.fid_source
                    INNER JOIN G_GEO.TA_METADONNEE_RELATION_ORGANISME i ON i.fid_metadonnee = g.objectid
                    INNER JOIN G_GEO.TA_ORGANISME j ON j.objectid = i.fid_organisme
                WHERE
                    a.ccomvoi IS NOT NULL 
                    AND f.pnom = 'import_donnees'
                    AND UPPER(j.acronyme) = UPPER('MEL')
                    AND UPPER(h.nom_source) = UPPER('base voie')
                )
            SELECT *
            FROM
                C_1
            WHERE
                GENRE IS NOT NULL;
                
    -- 22. Mise à jour de la clé étrangère TA_VOIE.FID_RIVOLI 
    -- 22.1. Pour les voies dont le code fantoir ne disposent pas de clé de contrôle
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
     
    -- 22.2. Pour les voies disposant d'un code fantoir complet
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

    -- 23. Import dans la table TA_VOIE_LOG des données de TA_VOIE
    -- 23.1. Pour la création des voies valides ET invalides
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
            d.objectid AS fid_type_action,
            e.numero_agent AS fid_pnom,
            a.fid_metadonnee
        FROM
            G_BASE_VOIE.TA_VOIE a
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccomvoi = a.objectid,
            G_GEO.TA_LIBELLE_LONG c
            INNER JOIN G_GEO.TA_LIBELLE d ON d.fid_libelle_long = c.objectid,
            G_BASE_VOIE.TA_AGENT e                  
        WHERE
            UPPER(c.valeur) = UPPER('insertion')
            AND e.pnom = 'import_donnees'
    )t
    ON (a.fid_voie = t.objectid)
    WHEN NOT MATCHED THEN
        INSERT(a.libelle_voie, a.complement_nom_voie, a.date_action, a.fid_typevoie, a.fid_genre_voie, a.fid_rivoli, a.fid_voie, a.fid_type_action, a.fid_pnom, a.fid_metadonnee)
        VALUES(t.libelle_voie, t.complement_nom_voie, t.date_action, t.fid_typevoie, t.fid_genre_voie, t.fid_rivoli, t.objectid, t.fid_type_action, t.fid_pnom, t.fid_metadonnee);

    -- 23.2. Pour la modification des voies valides
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
            d.objectid AS fid_type_action,
            e.numero_agent AS fid_pnom,
            a.fid_metadonnee
        FROM
            G_BASE_VOIE.TA_VOIE a
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccomvoi = a.objectid,
            G_GEO.TA_LIBELLE_LONG c
            INNER JOIN G_GEO.TA_LIBELLE d ON d.fid_libelle_long = c.objectid,
            G_BASE_VOIE.TA_AGENT e                 
        WHERE
            UPPER(c.valeur) = UPPER('édition')
            AND e.pnom = 'import_donnees'
            AND b.cdvalvoi = 'V'
    )t
    ON (t.fid_type_action <> (SELECT a.objectid FROM G_GEO.TA_LIBELLE a INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long WHERE UPPER(b.valeur) = UPPER('édition')))
    WHEN NOT MATCHED THEN
        INSERT(a.libelle_voie, a.complement_nom_voie, a.date_action, a.fid_typevoie, a.fid_genre_voie, a.fid_rivoli, a.fid_voie, a.fid_type_action, a.fid_pnom, a.fid_metadonnee)
        VALUES(t.libelle_voie, t.complement_nom_voie, t.date_action, t.fid_typevoie, t.fid_genre_voie, t.fid_rivoli, t.objectid, t.fid_type_action, t.fid_pnom, t.fid_metadonnee);

    -- 23.3. Pour la suppression des voies invalides
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
            d.objectid AS fid_type_action,
            e.numero_agent AS fid_pnom,
            a.fid_metadonnee
        FROM
            G_BASE_VOIE.TA_VOIE a
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccomvoi = a.objectid,
            G_GEO.TA_LIBELLE_LONG c
            INNER JOIN G_GEO.TA_LIBELLE d ON d.fid_libelle_long = c.objectid,
            G_BASE_VOIE.TA_AGENT e                  
        WHERE
            UPPER(c.valeur) = UPPER('suppression')
            AND e.pnom = 'import_donnees'
            AND b.cdvalvoi = 'I'
    )t
    ON (t.fid_type_action <> (SELECT a.objectid FROM G_GEO.TA_LIBELLE a INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long WHERE UPPER(b.valeur) = UPPER('suppression')))
    WHEN NOT MATCHED THEN
        INSERT(a.libelle_voie, a.complement_nom_voie, a.date_action, a.fid_typevoie, a.fid_genre_voie, a.fid_rivoli, a.fid_voie, a.fid_type_action, a.fid_pnom, a.fid_metadonnee)
        VALUES(t.libelle_voie, t.complement_nom_voie, t.date_action, t.fid_typevoie, t.fid_genre_voie, t.fid_rivoli, t.objectid, t.fid_type_action, t.fid_pnom, t.fid_metadonnee);

    -- 24. Suppression des voies invalides dans la table TA_VOIE
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

    -- 25. Réactivation des triggers pour les voies
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_VOIE_LOG ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_VOIE_DATE_PNOM ENABLE';

    -- 26. Désactivation du trigger de log de la table TA_RELATION_TRONCON_VOIE
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_RELATION_TRONCON_VOIE_LOG DISABLE';

    -- 27. Désactivation des contraintes de clé étrangère de la table TA_RELATION_TRONCON_VOIE   
    -- 27.1. Sélection du nom de la contrainte de FK du champ FID_TRONCON
    SELECT
        CONSTRAINT_NAME
        INTO v_contrainte
    FROM
        USER_CONSTRAINTS
    WHERE
        TABLE_NAME = 'TA_RELATION_TRONCON_VOIE'
        AND R_CONSTRAINT_NAME = 'TA_TRONCON_PK';
    
    -- 27.2. Désactivation de la contrainte de FK du champ FID_TRONCON    
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE DISABLE CONSTRAINT ' || v_contrainte;

    -- 27.3. Sélection du nom de la contrainte de FK du champ FID_VOIE
    SELECT
        CONSTRAINT_NAME
        INTO v_contrainte
    FROM
        USER_CONSTRAINTS
    WHERE
        TABLE_NAME = 'TA_RELATION_TRONCON_VOIE'
        AND R_CONSTRAINT_NAME = 'TA_VOIE_PK';

    -- 27.4. Désactivation de la contrainte de FK du champ FID_VOIE    
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE DISABLE CONSTRAINT ' || v_contrainte;

    -- 28. Import des relations tronçon/voie invalides dans TA_RELATION_TRONCON_VOIE
    INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE(FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON, DATE_SAISIE, DATE_MODIFICATION, FID_PNOM_SAISIE, FID_PNOM_MODIFICATION) 
        SELECT
            a.cnumtrc,
            a.ccomvoi,
            a.ccodstr,
            a.cnumtrv,
            a.cdtscvt,
            a.cdtmcvt,
            h.numero_agent AS fid_pnom_saisie,
            h.numero_agent AS fid_pnom_modification
        FROM
            G_BASE_VOIE.TEMP_VOIECVT a,       
            G_BASE_VOIE.TA_AGENT h
        WHERE
            a.CVALIDE = 'I'
            AND h.pnom = 'import_donnees';
    
    -- 29. Import des relations tronçons/voies invalides dans TA_RELATION_TRONCON_VOIE_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG(FID_RELATION_TRONCON_VOIE, FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON, DATE_ACTION, FID_TYPE_ACTION, FID_PNOM) 
        SELECT
            a.objectid,
            a.fid_troncon,
            a.fid_voie,
            a.sens,
            a.ordre_troncon,
            a.date_saisie AS date_action,
            e.objectid AS fid_type_action,
            f.numero_agent AS fid_pnom
        FROM
            G_BASE_VOIE.TA_RELATION_TRONCON_VOIE a,
            G_GEO.TA_LIBELLE_LONG d
            INNER JOIN G_GEO.TA_LIBELLE e ON e.fid_libelle_long = d.objectid,
            G_BASE_VOIE.TA_AGENT f
        WHERE
            UPPER(d.valeur) = UPPER('insertion')
            AND f.pnom = 'import_donnees';
            
    -- 30. Import des relations tronçons/voies invalides dans TA_RELATION_TRONCON_VOIE_LOG pour la modification
    INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG(FID_RELATION_TRONCON_VOIE, FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON, DATE_ACTION, FID_TYPE_ACTION, FID_PNOM) 
        SELECT DISTINCT
            a.objectid,
            a.fid_troncon,
            a.fid_voie,
            a.sens,
            a.ordre_troncon,
            a.date_modification AS date_action,
            e.objectid AS fid_type_action,
            f.numero_agent AS fid_pnom
        FROM
            G_BASE_VOIE.TA_RELATION_TRONCON_VOIE a,
            G_GEO.TA_LIBELLE_LONG d
            INNER JOIN G_GEO.TA_LIBELLE e ON e.fid_libelle_long = d.objectid,
            G_BASE_VOIE.TA_AGENT f
        WHERE
            UPPER(d.valeur) = UPPER('suppression')
            AND f.pnom = 'import_donnees';
            
    -- 31. Suppression des relations troncon/voie invalides de la table TA_RELATION_TRONCON_VOIE
    DELETE
    FROM
        G_BASE_VOIE.TA_RELATION_TRONCON_VOIE;

    -- 32. Import des relations tronçons/voies valides dans la table TA_RELATION_TRONCON_VOIE
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

    -- 33. Import des relations tronçons/voies valides dans la table TA_RELATION_TRONCON_VOIE_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG(FID_RELATION_TRONCON_VOIE, FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON, DATE_ACTION, FID_TYPE_ACTION, FID_PNOM)
    SELECT
        a.objectid AS fid_relation_troncon_voie,
        a.fid_troncon,
        a.fid_voie,
        a.sens,
        a.ordre_troncon,
        a.date_saisie,
        f.objectid AS fid_type_action,
        g.numero_agent AS fid_pnom
    FROM
        G_BASE_VOIE.TA_RELATION_TRONCON_VOIE a,
        G_GEO.TA_LIBELLE_LONG e
        INNER JOIN G_GEO.TA_LIBELLE f ON f.fid_libelle_long = e.objectid,
        G_BASE_VOIE.TA_AGENT g
    WHERE
        g.pnom = 'import_donnees'
        AND UPPER(e.valeur) = UPPER('insertion');

    -- 34. Import des relations tronçons/voies valides dans la table TA_RELATION_TRONCON_VOIE_LOG pour la modification
    INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG(FID_RELATION_TRONCON_VOIE, FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON, DATE_ACTION, FID_TYPE_ACTION, FID_PNOM)
    SELECT
        a.objectid AS fid_relation_troncon_voie,
        a.fid_troncon,
        a.fid_voie,
        a.sens,
        a.ordre_troncon,
        a.date_modification,
        c.objectid AS fid_type_action,
        d.numero_agent AS fid_pnom
    FROM
        G_BASE_VOIE.TA_RELATION_TRONCON_VOIE a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('édition');

    -- 35. Réactivation des contraintes et triggers gérant les relations tronçons/voies
    -- 35.1. Réactivation du trigger de log de la table TA_RELATION_TRONCON_VOIE
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_RELATION_TRONCON_VOIE_LOG ENABLE';

    -- 35.2. Réactivation des contraintes de clé étrangère de la table TA_RELATION_TRONCON_VOIE   
    -- 35.2.1 Sélection du nom de la contrainte de FK du champ FID_TRONCON
    SELECT
        CONSTRAINT_NAME
        INTO v_contrainte
    FROM
        USER_CONSTRAINTS
    WHERE
        TABLE_NAME = 'TA_RELATION_TRONCON_VOIE'
        AND R_CONSTRAINT_NAME = 'TA_TRONCON_PK';
    
    -- 35.2.2. Réactivation de la contrainte de FK du champ FID_TRONCON    
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE ENABLE CONSTRAINT ' || v_contrainte;

    -- 35.2.3. Sélection du nom de la contrainte de FK du champ FID_VOIE
    SELECT
        CONSTRAINT_NAME
        INTO v_contrainte
    FROM
        USER_CONSTRAINTS
    WHERE
        TABLE_NAME = 'TA_RELATION_TRONCON_VOIE'
        AND R_CONSTRAINT_NAME = 'TA_VOIE_PK';

    -- 35.2.4. Réactivation de la contrainte de FK du champ FID_VOIE    
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
    
    -- 36.5. Insertion des autres points géométriques des seuils dans TA_SEUIL  
    MERGE INTO G_BASE_VOIE.TA_SEUIL a
    USING(
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
            AND b.pnom = 'import_donnees'                
    )t
    ON (a.temp_idseui = t.idseui)
    WHEN NOT MATCHED THEN
        INSERT(a.geom, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.temp_idseui)
        VALUES(t.ora_geometry, t.cdtsseuil, t.cdtmseuil, t.fid_pnom_saisie, t.fid_pnom_modification, t.idseui);
    
    -- 36.6. Import des infos des seuils dans TA_INFOS_SEUIL pour les seuils non-concernés par la fusion        
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

    -- 38. Suppression du champ temporaire temp_idseui
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_SEUIL DROP COLUMN TEMP_IDSEUI'; 

-- 38. Insertion des points d'intérêt
    -- 38.1. Désactivation des triggers
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_POINT_INTERET_LOG DISABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_POINT_INTERET_DATE_PNOM DISABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_INFOS_POINT_INTERET_LOG DISABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_INFOS_POINT_INTERET_DATE_PNOM DISABLE';

    -- 38.2. Import des données invalides dans la table TA_POINT_INTERET
    INSERT INTO G_BASE_VOIE.TA_POINT_INTERET(geom, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification, temp_idpoi)
    SELECT
        a.ora_geometry,
        a.cdtslpu,
        a.cdtmlpu,
        c.numero_agent AS fid_pnom_saisie,
        c.numero_agent AS fid_pnom_modification,
        a.cnumlpu
    FROM
        G_BASE_VOIE.TEMP_ILTALPU a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON UPPER(b.valeur) = UPPER(a.libelle_court),
        G_BASE_VOIE.TA_AGENT c
    WHERE
        UPPER(b.valeur) IN(UPPER('mairie'), UPPER('mairie annexe'), UPPER('mairie quartier'))
        AND c.numero_agent = 99999
        AND a.cdvallpu = 'I';

    -- 38.3. Import des POI invalides dans TA_POINT_INTERET_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_POINT_INTERET_LOG(GEOM, CODE_INSEE, DATE_ACTION, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.geom,
        GET_CODE_INSEE_CONTAIN_POINT('TA_POINT_INTERET', a.geom) AS code_insee,
        a.date_saisie,
        a.objectid AS fid_point_interet,
        c.objectid AS fid_type_action,
        d.numero_agent
    FROM
        G_BASE_VOIE.TA_POINT_INTERET a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('insertion');

    -- 38.4. Import des POI invalides dans TA_POINT_INTERET_LOG pour la suppression
    INSERT INTO G_BASE_VOIE.TA_POINT_INTERET_LOG(GEOM, CODE_INSEE, DATE_ACTION, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.geom,
        GET_CODE_INSEE_CONTAIN_POINT('TA_POINT_INTERET', a.geom) AS code_insee,
        a.date_modification,
        a.objectid AS fid_point_interet,
        c.objectid AS fid_type_action,
        d.numero_agent
    FROM
        G_BASE_VOIE.TA_POINT_INTERET a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('suppression');

     -- Insertion des informations des point d'intérêts invalides   
    INSERT INTO G_BASE_VOIE.TA_INFOS_POINT_INTERET(objectid, nom, complement_infos, date_saisie, date_modification, fid_libelle, fid_point_interet, fid_pnom_saisie, fid_pnom_modification)
        SELECT
            a.cnumlpu,
            a.cliblpu,
            a.cinfos,
            a.cdtslpu,
            a.cdtmlpu,
            d.objectid AS fid_libelle,
            b.objectid AS fid_point_interet,
            e.numero_agent AS fid_pnom_saisie,
            e.numero_agent AS fid_pnom_modification
        FROM
            G_BASE_VOIE.TEMP_ILTALPU a
            INNER JOIN G_BASE_VOIE.TA_POINT_INTERET b ON b.temp_idpoi = a.cnumlpu
            INNER JOIN G_GEO.TA_LIBELLE_LONG c ON UPPER(c.valeur) = UPPER(a.libelle_court)
            INNER JOIN G_GEO.TA_LIBELLE d ON d.fid_libelle_long = c.objectid,
            G_BASE_VOIE.TA_AGENT e
        WHERE
            UPPER(c.valeur) IN(UPPER('mairie'), UPPER('mairie annexe'), UPPER('mairie quartier'))
            AND e.numero_agent = 99999
            AND a.cdvallpu = 'I';
        
    -- Import des POI invalides dans TA_INFOS_POINT_INTERET_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG(NOM, COMPLEMENT_INFOS, DATE_ACTION, FID_INFOS_POINT_INTERET, FID_LIBELLE, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.nom,
        a.complement_infos,
        a.date_saisie,
        a.objectid AS fid_infos_point_interet,
        a.fid_libelle,
        a.fid_point_interet,
        c.objectid AS fid_type_action,
        d.numero_agent
    FROM
        G_BASE_VOIE.TA_INFOS_POINT_INTERET a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('insertion');

    -- Import des POI invalides dans TA_INFOS_POINT_INTERET_LOG pour la suppression
    INSERT INTO G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG(NOM, COMPLEMENT_INFOS, DATE_ACTION, FID_INFOS_POINT_INTERET, FID_LIBELLE, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.nom,
        a.complement_infos,
        a.date_modification,
        a.objectid AS fid_infos_point_interet,
        a.fid_libelle,
        a.fid_point_interet,
        c.objectid AS fid_type_action,
        d.numero_agent
    FROM
        G_BASE_VOIE.TA_INFOS_POINT_INTERET a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('suppression');
        
    -- Suppression des POI invalides de la table TA_INFOS_POINT_INTERET
    DELETE FROM G_BASE_VOIE.TA_INFOS_POINT_INTERET;

    -- 38.5. Suppression des POI invalides dans la table TA_POINT_INTERET
    DELETE FROM G_BASE_VOIE.TA_POINT_INTERET;

    -- 38.6. Insertion des données valides dans la table TA_POINT_INTERET
    INSERT INTO G_BASE_VOIE.TA_POINT_INTERET(geom, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification, temp_idpoi)
    SELECT
        a.ora_geometry,
        a.cdtslpu,
        a.cdtmlpu,
        c.numero_agent AS fid_pnom_saisie,
        c.numero_agent AS fid_pnom_modification,
        a.cnumlpu
    FROM
        G_BASE_VOIE.TEMP_ILTALPU a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON UPPER(b.valeur) = UPPER(a.libelle_court),
        G_BASE_VOIE.TA_AGENT c
    WHERE
        UPPER(b.valeur) IN(UPPER('mairie'), UPPER('mairie annexe'), UPPER('mairie quartier'))
        AND c.numero_agent = 99999
        AND a.cdvallpu = 'V';

    -- 38.7. Import des POI valides dans TA_POINT_INTERET_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_POINT_INTERET_LOG(GEOM, CODE_INSEE, DATE_ACTION, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.geom,
        GET_CODE_INSEE_CONTAIN_POINT('TA_POINT_INTERET', a.geom) AS code_insee,
        a.date_saisie,
        a.objectid AS fid_point_interet,
        c.objectid AS fid_type_action,
        d.numero_agent
    FROM
        G_BASE_VOIE.TA_POINT_INTERET a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('insertion');

    -- 38.8. Import des POI valides dans TA_POINT_INTERET_LOG pour la modification
    INSERT INTO G_BASE_VOIE.TA_POINT_INTERET_LOG(GEOM, CODE_INSEE, DATE_ACTION, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)    
    SELECT
        a.geom,
        GET_CODE_INSEE_CONTAIN_POINT('TA_POINT_INTERET', a.geom) AS code_insee,
        a.date_modification,
        a.objectid AS fid_point_interet,
        c.objectid AS fid_type_action,
        d.numero_agent
    FROM
        G_BASE_VOIE.TA_POINT_INTERET a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('édition');
              
    -- Insertion des informations des point d'intérêts valides   
    INSERT INTO G_BASE_VOIE.TA_INFOS_POINT_INTERET(objectid, nom, complement_infos, date_saisie, date_modification, fid_libelle, fid_point_interet, fid_pnom_saisie, fid_pnom_modification)
        SELECT
            a.cnumlpu,
            a.cliblpu,
            a.cinfos,
            a.cdtslpu,
            a.cdtmlpu,
            d.objectid AS fid_libelle,
            b.objectid AS fid_point_interet,
            e.numero_agent AS fid_pnom_saisie,
            e.numero_agent AS fid_pnom_modification
        FROM
            G_BASE_VOIE.TEMP_ILTALPU a
            INNER JOIN G_BASE_VOIE.TA_POINT_INTERET b ON b.temp_idpoi = a.cnumlpu
            INNER JOIN G_GEO.TA_LIBELLE_LONG c ON UPPER(c.valeur) = UPPER(a.libelle_court)
            INNER JOIN G_GEO.TA_LIBELLE d ON d.fid_libelle_long = c.objectid,
            G_BASE_VOIE.TA_AGENT e
        WHERE
            UPPER(c.valeur) IN(UPPER('mairie'), UPPER('mairie annexe'), UPPER('mairie quartier'))
            AND e.numero_agent = 99999
            AND a.cdvallpu = 'V';
            
    -- Import des POI valides dans TA_INFOS_POINT_INTERET_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG(NOM, COMPLEMENT_INFOS, DATE_ACTION, FID_INFOS_POINT_INTERET, FID_LIBELLE, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.nom,
        a.complement_infos,
        a.date_saisie,
        a.objectid AS fid_infos_point_interet,
        a.fid_libelle,
        a.fid_point_interet,
        c.objectid AS fid_type_action,
        d.numero_agent
    FROM
        G_BASE_VOIE.TA_INFOS_POINT_INTERET a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('insertion');

    -- Import des POI invalides dans TA_INFOS_POINT_INTERET_LOG pour la modification
    INSERT INTO G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG(NOM, COMPLEMENT_INFOS, DATE_ACTION, FID_INFOS_POINT_INTERET, FID_LIBELLE, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.nom,
        a.complement_infos,
        a.date_modification,
        a.objectid AS fid_infos_point_interet,
        a.fid_libelle,
        a.fid_point_interet,
        c.objectid AS fid_type_action,
        d.numero_agent
    FROM
        G_BASE_VOIE.TA_INFOS_POINT_INTERET a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('édition');

    -- 39. Réactivation de tous les triggers désactivés au cours de la procédure
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_POINT_INTERET_LOG ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_TRONCON_LOG ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_SEUIL_LOG ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_SEUIL_DATE_PNOM ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_INFOS_SEUIL_LOG ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_INFOS_SEUIL_DATE_PNOM ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_POINT_INTERET_DATE_PNOM ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_INFOS_POINT_INTERET_LOG ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_INFOS_POINT_INTERET_DATE_PNOM ENABLE';
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_POINT_INTERET DROP COLUMN TEMP_IDPOI';
    
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