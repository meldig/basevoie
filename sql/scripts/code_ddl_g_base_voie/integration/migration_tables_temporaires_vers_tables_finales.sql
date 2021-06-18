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
    INSERT INTO G_BASE_VOIE.TA_RELATION_FAMILLE_LIBELLE(fid_famille, fid_libelle)
    SELECT
        a.objectid,
        b.objectid
    FROM
        G_BASE_VOIE.TA_FAMILLE a,
        G_BASE_VOIE.TA_LIBELLE b
    WHERE
        a.valeur = 'action';

    -- 5. Insertion des codes rivoli dans TA_RIVOLI
    INSERT INTO G_BASE_VOIE.TA_RIVOLI(code_rivoli)
    SELECT DISTINCT
        CCODRVO
    FROM
        G_BASE_VOIE.TEMP_VOIEVOI;

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
    INSERT INTO G_BASE_VOIE.TA_TYPE_VOIE(code_type_voie, libelle)
    SELECT
        CCODTVO,
        LITYVOIE
    FROM
        G_BASE_VOIE.TEMP_TYPEVOIE;
        
    -- 18. Désactivation des triggers pour les voies
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_VOIE_LOG DISABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_VOIE_DATE_PNOM DISABLE';
    
    -- 19 désactivation des contraintes de non-nullité de la tble TA_VOIE
    -- 19.1. Contrainte de non-nullité des genres
    SELECT
        CONSTRAINT_NAME
        INTO v_contrainte
    FROM
        USER_CONSTRAINTS
    WHERE
        TABLE_NAME = 'TA_VOIE'
        AND CONSTRAINT_TYPE = 'C'
        AND SEARCH_CONDITION_VC LIKE '%FID_GENRE_VOIE%';

    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_VOIE DISABLE CONSTRAINT ' || v_contrainte;
    
    -- 19.2. Contrainte de non-nullité des libellés des voies (noms)
    SELECT
        CONSTRAINT_NAME
        INTO v_contrainte
    FROM
        USER_CONSTRAINTS
    WHERE
        TABLE_NAME = 'TA_VOIE'
        AND CONSTRAINT_TYPE = 'C'
        AND SEARCH_CONDITION_VC LIKE '%LIBELLE_VOIE%';

    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_VOIE DISABLE CONSTRAINT ' || v_contrainte;
    
    -- 19. Import des voies valides dans TA_VOIE
    INSERT INTO G_BASE_VOIE.TA_VOIE(FID_TYPEVOIE, FID_RIVOLI, OBJECTID, COMPLEMENT_NOM_VOIE, LIBELLE_VOIE, FID_GENRE_VOIE, DATE_SAISIE, DATE_MODIFICATION, FID_PNOM_SAISIE, FID_PNOM_MODIFICATION)
            WITH C_1 AS(
                SELECT DISTINCT
                    b.objectid AS FID_TYPE_VOIE,
                    c.objectid AS FID_CODE_RIVOLI,
                    a.CCOMVOI AS NUMERO_VOIE,
                    a.CINFOS AS COMPLEMENT_NOM_VOIE,
                    a.CNOMINUS AS LIBELLE,
                    CASE
                        WHEN a.genre = 'M' AND d.valeur = 'masculin' THEN d.objectid
                        WHEN a.genre = 'F' AND d.valeur = 'féminin' THEN d.objectid
                        WHEN a.genre = 'N' AND d.valeur = 'neutre' THEN d.objectid
                        WHEN a.genre = 'C' AND d.valeur = 'couple' THEN d.objectid
                        WHEN a.genre = 'NI' AND d.valeur = 'non-identifié' THEN d.objectid
                    END AS GENRE,
                    a.CDTSVOI AS DATE_SAISIE,
                    a.CDTMVOI AS DATE_MODIFICATION,
                    e.numero_agent AS fid_pnom_saisie,
                    e.numero_agent AS fid_pnom_modification
                FROM
                    G_BASE_VOIE.TEMP_VOIEVOI a
                    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.code_type_voie = a.ccodtvo
                    INNER JOIN G_BASE_VOIE.TA_RIVOLI c ON c.code_rivoli = a.ccodrvo,
                    G_BASE_VOIE.TA_LIBELLE d,
                    G_BASE_VOIE.TA_AGENT e
                WHERE
                    a.ccomvoi IS NOT NULL 
                    AND a.CDVALVOI = 'V'
                    AND e.pnom = 'import_donnees'
                )
            SELECT *
            FROM
                C_1
            WHERE
                GENRE IS NOT NULL;

    -- 20. Import des voies valides dans TA_VOIE_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_VOIE_LOG(FID_VOIE, LIBELLE_VOIE, COMPLEMENT_NOM_VOIE, FID_TYPEVOIE, FID_GENRE_VOIE, FID_RIVOLI, DATE_ACTION, FID_TYPE_ACTION, FID_PNOM)
            WITH C_1 AS(
                SELECT DISTINCT
                    a.objectid,
                    a.libelle_voie,
                    a.complement_nom_voie,
                    a.fid_typevoie,
                    a.fid_genre_voie,
                    a.fid_rivoli,
                    a.date_saisie,
                    c.objectid AS fid_type_action,
                    d.numero_agent AS fid_pnom
                FROM
                    G_BASE_VOIE.TA_VOIE a
                    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccomvoi = a.objectid,
                    G_BASE_VOIE.TA_LIBELLE c,
                    G_BASE_VOIE.TA_AGENT d                  
                WHERE
                    b.CDVALVOI = 'V'
                    AND c.valeur = 'insertion'
                    AND d.pnom = 'import_donnees'
                )
            SELECT *
            FROM
                C_1
            WHERE
                fid_genre_voie IS NOT NULL;
                
    -- 21. Import des voies valides dans TA_VOIE_LOG pour la modification
    INSERT INTO G_BASE_VOIE.TA_VOIE_LOG(FID_VOIE, LIBELLE_VOIE, COMPLEMENT_NOM_VOIE, FID_TYPEVOIE, FID_GENRE_VOIE, FID_RIVOLI, DATE_ACTION, FID_TYPE_ACTION, FID_PNOM)
            WITH C_1 AS(
                SELECT DISTINCT
                    a.objectid,
                    a.libelle_voie,
                    a.complement_nom_voie,
                    a.fid_typevoie,
                    a.fid_genre_voie,
                    a.fid_rivoli,
                    a.date_modification,
                    c.objectid AS fid_type_action,
                    d.numero_agent AS fid_pnom
                FROM
                    G_BASE_VOIE.TA_VOIE a
                    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccomvoi = a.objectid,
                    G_BASE_VOIE.TA_LIBELLE c,
                    G_BASE_VOIE.TA_AGENT d                  
                WHERE
                    b.CDVALVOI = 'V'
                    AND c.valeur = 'édition'
                    AND d.pnom = 'import_donnees'
            )
            SELECT *
            FROM
                C_1
            WHERE
                fid_genre_voie IS NOT NULL;
               
    -- 22. Import des voies invalides dans TA_VOIE afin de pouvoir les stocker dans la table de logs
    INSERT INTO G_BASE_VOIE.TA_VOIE(FID_TYPEVOIE, FID_RIVOLI, OBJECTID, COMPLEMENT_NOM_VOIE, LIBELLE_VOIE, FID_GENRE_VOIE, DATE_SAISIE, DATE_MODIFICATION, FID_PNOM_SAISIE, FID_PNOM_MODIFICATION)
    WITH C_1 AS(
        SELECT DISTINCT
            b.objectid AS FID_TYPE_VOIE,
            c.objectid AS FID_CODE_RIVOLI,
            a.CCOMVOI AS NUMERO_VOIE,
            a.CINFOS AS COMPLEMENT_NOM_VOIE,
            a.CNOMINUS AS LIBELLE,
            a.genre,
            /*CASE
                WHEN a.genre = 'M' AND d.valeur = 'masculin' THEN d.objectid
                WHEN a.genre = 'F' AND d.valeur = 'féminin' THEN d.objectid
                WHEN a.genre = 'N' AND d.valeur = 'neutre' THEN d.objectid
                WHEN a.genre = 'C' AND d.valeur = 'couple' THEN d.objectid
                WHEN a.genre = 'NI' AND d.valeur = 'non-identifié' THEN d.objectid
            END AS GENRE*/
            a.CDTSVOI AS DATE_SAISIE,
            a.CDTMVOI AS DATE_MODIFICATION,
            e.numero_agent AS fid_pnom_saisie,
            e.numero_agent AS fid_pnom_modification
        FROM
            G_BASE_VOIE.TEMP_VOIEVOI a
            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.code_type_voie = a.ccodtvo
            INNER JOIN G_BASE_VOIE.TA_RIVOLI c ON c.code_rivoli = a.ccodrvo,
            G_BASE_VOIE.TA_LIBELLE d,
            G_BASE_VOIE.TA_AGENT e
        WHERE
            a.ccomvoi IS NOT NULL 
            AND a.CDVALVOI = 'I'
            AND e.pnom = 'import_donnees'
            --AND a.ccomvoi NOT IN(SELECT objectid FROM G_BASE_VOIE.TA_VOIE)
    )
    SELECT
        a.FID_TYPE_VOIE,
        a.FID_CODE_RIVOLI,
        a.NUMERO_VOIE,
        a.COMPLEMENT_NOM_VOIE,
        a.LIBELLE,
        CASE
            WHEN a.genre = 'M' AND d.valeur = 'masculin' THEN d.objectid
            WHEN a.genre = 'F' AND d.valeur = 'féminin' THEN d.objectid
            WHEN a.genre = 'N' AND d.valeur = 'neutre' THEN d.objectid
            WHEN a.genre = 'C' AND d.valeur = 'couple' THEN d.objectid
            WHEN a.genre = 'NI' AND d.valeur = 'non-identifié' THEN d.objectid
        END AS GENRE,
        a.DATE_SAISIE,
        a.DATE_MODIFICATION,
        a.fid_pnom_saisie,
        a.fid_pnom_modification
    FROM
        C_1 a,
        G_BASE_VOIE.TA_LIBELLE d
    ;
                
    -- 22. Import des voies invalides dans TA_VOIE_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_VOIE_LOG(FID_VOIE, LIBELLE_VOIE, COMPLEMENT_NOM_VOIE, FID_TYPEVOIE, FID_GENRE_VOIE, FID_RIVOLI, DATE_ACTION, FID_TYPE_ACTION, FID_PNOM)
            WITH C_1 AS(
                SELECT DISTINCT
                    a.objectid,
                    a.libelle_voie,
                    a.complement_nom_voie,
                    a.fid_typevoie,
                    a.fid_genre_voie,
                    a.fid_rivoli,
                    a.date_modification,
                    c.objectid AS fid_type_action,
                    d.numero_agent AS fid_pnom
                FROM
                    G_BASE_VOIE.TA_VOIE a
                    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccomvoi = a.objectid,
                    G_BASE_VOIE.TA_LIBELLE c,
                    G_BASE_VOIE.TA_AGENT d                  
                WHERE
                    b.CDVALVOI = 'V'
                    AND c.valeur = 'édition'
                    AND d.pnom = 'import_donnees'
                )
            SELECT *
            FROM
                C_1
            WHERE
                fid_genre_voie IS NOT NULL;

    -- 11. Désactivation du trigger de log de la table TA_RELATION_TRONCON_VOIE
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_RELATION_TRONCON_VOIE_LOG DISABLE';

    INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE(FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON)
    SELECT
        a.objectid AS fid_troncon,
        c.objectid AS fid_voie,
        b.CCODSTR AS sens,
        b.CNUMTRV AS ordre_troncon
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.objectid
        INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = b.ccomvoi
    WHERE
        b.CVALIDE = 'V';

    -- 13. Insertion des seuils
    -- 13.1. Désactivation du trigger de remplissage des tables de logs et des dates/pnoms pour les seuils
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_SEUIL_LOG DISABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_SEUIL_DATE_PNOM DISABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_INFOS_SEUIL_LOG DISABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_INFOS_SEUIL_DATE_PNOM DISABLE';

    -- 13.2. Insertion d'un seul point géométrique par groupe de seuils dans un rayon de 50cm max dans la table TA_SEUIL
    INSERT INTO G_BASE_VOIE.TA_SEUIL(cote_troncon, geom)
    SELECT
        a.cdcote,
        a.ora_geometry
    FROM
        G_BASE_VOIE.TEMP_FUSION_SEUIL;

    -- 13.3. Insertion des infos des seuils dans la table TA_INFOS_SEUIL
    INSERT INTO G_BASE_VOIE.TA_INFOS_SEUIL(objectid, numero_seuil, numero_parcelle, complement_numero_seuil, fid_seuil, date_modification, date_saisie)
    SELECT
        a.idseui,
        a.nuseui,
        a.nparcelle,
        a.nsseui,
        b.objectid,
        a.cdtmseuil,
        a.cdtsseuil
    FROM
        G_BASE_VOIE.TEMP_ILTASEU a,
        G_BASE_VOIE.TA_SEUIL b
    WHERE
        SDO_WITHIN_DISTANCE(b.geom, a.ora_geometry, 'DISTANCE=0.50') = 'TRUE';

    -- 13.4. Insertion des autres points géométriques des seuils dans TA_SEUIL
    INSERT INTO G_BASE_VOIE.TA_SEUIL(cote_troncon, geom, date_saisie, date_modification)
    SELECT
        a.cdcote,
        a.ora_geometry,
        a.cdtsseuil,
        a.cdtmseuil
    FROM
        G_BASE_VOIE.TEMP_ILTASEU a
    WHERE
        a.idseui NOT IN(SELECT objectid FROM G_BASE_VOIE.TA_INFOS_SEUIL);

    -- 13.5. Insertion des informations des autres seuils dans TA_INFOS_SEUIL
    INSERT INTO G_BASE_VOIE.TA_INFOS_SEUIL(objectid, numero_seuil, numero_parcelle, complement_numero_seuil, fid_seuil, date_saisie, date_modification)
    SELECT DISTINCT
        a.idseui,
        a.nuseui,
        a.nparcelle,
        a.nsseui,
        c.objectid,
        a.cdtsseuil,
        a.cdtmseuil
    FROM
        G_BASE_VOIE.TEMP_ILTASEU a,
        G_BASE_VOIE.TA_INFOS_SEUIL b,
        G_BASE_VOIE.TA_SEUIL c
    WHERE
        a.idseui NOT IN(SELECT objectid FROM G_BASE_VOIE.TA_INFOS_SEUIL)
        AND a.ora_geometry.sdo_point.x = c.geom.sdo_point.x
        AND a.ora_geometry.sdo_point.y = c.geom.sdo_point.y;

    -- 14. Réactivation de tous les triggers et contraintes désacitivées au cours de la procédure
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_TRONCON_LOG ENABLE';
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_TYPE_VOIE ENABLE CONSTRAINT ' || v_contrainte;
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_RELATION_TRONCON_VOIE_LOG ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_SEUIL_LOG ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_SEUIL_DATE_PNOM ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_INFOS_SEUIL_LOG ENABLE';
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_INFOS_SEUIL_DATE_PNOM ENABLE';


-- En cas d'erreur une exception est levée et un rollback effectué, empêchant ainsi toute insertion de se faire et de retourner à l'état des tables précédent l'insertion.
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('L''erreur ' || SQLCODE || 'est survenue. Un rollback a été effectué : ' || SQLERRM(SQLCODE));
        ROLLBACK TO POINT_SAUVEGARDE_REMPLISSAGE;
END;
