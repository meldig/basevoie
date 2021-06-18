/*
Import des données corrigées des tables temporaires vers les tables finales de la base voie.
*/

SET SERVEROUTPOUT ON
DECLARE
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
        SUBSTR(CCODRVO, 4, 4)
    FROM
        G_BASE_VOIE.TEMP_VOIEVOI;

    -- 6. Désactivation du trigger de log de la table TA_TRONCON
    EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_TRONCON_LOG DISABLE';

    -- 7. Import des tronçons dans TA_TRONCON
    INSERT INTO G_BASE_VOIE.TA_TRONCON(geom, date_saisie, date_modification)
    SELECT
    	a.geom,
    	a.CDTSTRC,
    	a.CDTMTRC
    FROM
    	G_BASE_VOIE.TEMP_TRONCON a
    WHERE
        a.cdvaltro = 'V';

    -- 8. Désactivation de la contrainte de non-nullité du champ TA_TYPE_VOIE.LIBELLE
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

    -- 9. Import des données dans TA_TYPE_VOIE
    INSERT INTO G_BASE_VOIE.TA_TYPE_VOIE(code_type_voie, libelle)
    SELECT
    	CCODTVO,
    	LITYVOIE
    FROM
    	G_BASE_VOIE.TEMP_TYPEVOIE;

    -- 10. Import des voies dans TA_VOIE
    INSERT INTO G_BASE_VOIE.TA_VOIE(FID_TYPEVOIE, FID_RIVOLI, OBJECTID, COMPLEMENT_NOM_VOIE, LIBELLE_VOIE, FID_GENRE_VOIE, DATE_SAISIE, DATE_MODIFICATION)
            WITH C_1 AS(
                SELECT DISTINCT
                    b.objectid AS FID_TYPE_VOIE,
                    c.objectid AS FID_CODE_RIVOLI,
                    a.CCOMVOI AS NUMERO_VOIE,
                    a.CINFOS AS COMPLEMENT_NOM_VOIE,
                    a.CNOMINUS AS LIBELLE,
                    CASE
                        WHEN a.genre = 'M' AND f.valeur = 'masculin' THEN f.objectid
                        WHEN a.genre = 'F' AND f.valeur = 'féminin' THEN f.objectid
                        WHEN a.genre = 'N' AND f.valeur = 'neutre' THEN f.objectid
                        WHEN a.genre = 'C' AND f.valeur = 'couple' THEN f.objectid
                        WHEN a.genre = 'NI' AND f.valeur = 'non-identifié' THEN f.objectid
                    END AS GENRE,
                    CDTSVOI AS DATE_SAISIE,
                    CDTMVOI AS DATE_MODIFICATION
                FROM
                    G_BASE_VOIE.TEMP_VOIEVOI a
                    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.code_type_voie = a.ccodtvo
                    INNER JOIN G_BASE_VOIE.TA_RIVOLI c ON c.code_rivoli = a.ccodrvo,
                    G_BASE_VOIE.TA_FAMILLE d
                    INNER JOIN G_BASE_VOIE.TA_RELATION_FAMILLE_LIBELLE e ON e.fid_famille = d.objectid
                    INNER JOIN G_BASE_VOIE.TA_LIBELLE f ON f.objectid = e.fid_libelle
                WHERE
                    a.ccomvoi IS NOT NULL 
                    AND a.CDVALVOI = 'V'
                )
            SELECT *
            FROM
                C_1
            WHERE
                GENRE IS NOT NULL;

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
