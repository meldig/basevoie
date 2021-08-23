/*
Déclencheur permettant de remplir la table de logs TA_SEUIL_LOG dans laquelle sont enregistrés chaque insertion, 
modification et suppression des données de la table TA_SEUIL avec leur date et le pnom de l'agent les ayant effectuées.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUD_TA_SEUIL_LOG
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TA_SEUIL
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_insertion NUMBER(38,0);
    v_id_modification NUMBER(38,0);
    v_id_suppression NUMBER(38,0);
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- Sélection des id des actions présentes dans la table TA_LIBELLE
    SELECT 
        a.objectid INTO v_id_insertion 
    FROM 
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long 
    WHERE 
        b.valeur = 'insertion';

    SELECT 
        a.objectid INTO v_id_modification 
    FROM 
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long 
    WHERE 
        b.valeur = 'édition';
            
    SELECT 
        a.objectid INTO v_id_suppression 
    FROM 
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long 
    WHERE 
        b.valeur = 'suppression';

    IF INSERTING THEN -- En cas d'insertion on insère les valeurs de la table TA_SEUIL_LOG, le numéro d'agent correspondant à l'utilisateur, la date de insertion et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_SEUIL_LOG(fid_seuil, geom, code_insee, cote_troncon, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :new.objectid, 
                    :new.geom,
                    GET_CODE_INSEE_CONTAIN_POINT('TA_SEUIL', :new.geom),
                    :new.cote_troncon,
                    sysdate,
                    v_id_insertion,
                    v_id_agent);
    ELSE
        IF UPDATING THEN -- En cas de modification on insère les valeurs de la table TA_SEUIL_LOG, le numéro d'agent correspondant à l'utilisateur, la date de modification et le type de modification.
            INSERT INTO G_BASE_VOIE.TA_SEUIL_LOG(fid_seuil, geom, code_insee, cote_troncon, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :old.objectid,
                    :old.geom,
                    GET_CODE_INSEE_CONTAIN_POINT('TA_SEUIL', :old.geom),
                    :old.cote_troncon,
                    sysdate,
                    v_id_modification,
                    v_id_agent);
        END IF;
    END IF;
    IF DELETING THEN -- En cas de suppression on insère les valeurs de la table TA_SEUIL_LOG, le numéro d'agent correspondant à l'utilisateur, la date de suppression et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_SEUIL_LOG(fid_seuil, geom, code_insee, cote_troncon, date_action, fid_type_action, fid_pnom)
        VALUES(
                :old.objectid,
                :old.geom,
                GET_CODE_INSEE_CONTAIN_POINT('TA_SEUIL', :old.geom), 
                :old.cote_troncon,
                sysdate,
                v_id_suppression,
                v_id_agent);
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUD_TA_SEUIL_LOG','bjacq@lillemetropole.fr');
END;

/
