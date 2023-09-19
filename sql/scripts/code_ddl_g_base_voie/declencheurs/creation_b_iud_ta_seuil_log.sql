/*
Déclencheur permettant de remplir la table de logs TA_SEUIL_LOG dans laquelle sont enregistrés chaque insertion, 
modification et suppression des données de la table TA_SEUIL avec leur date et le pnom de l'agent les ayant effectuées.
Il permet aussi de remplir les champs date_saisie, date_modificiation, fid_pnom_saisie et fid_pnom_modification de la table TA_SEUIL.
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
        G_BASE_VOIE.TA_LIBELLE a 
    WHERE 
        a.libelle_court = 'insertion';

    SELECT 
        a.objectid INTO v_id_modification 
    FROM 
        G_BASE_VOIE.TA_LIBELLE a 
    WHERE 
        a.libelle_court = 'édition';
            
    SELECT 
        a.objectid INTO v_id_suppression 
    FROM 
        G_BASE_VOIE.TA_LIBELLE a 
    WHERE 
        a.libelle_court = 'suppression';

    IF INSERTING THEN -- En cas d'insertion on insère les valeurs de la table TA_SEUIL_LOG, le numéro d'agent correspondant à l'utilisateur, la date de insertion et le type de modification.
        :new.fid_pnom_saisie := v_id_agent;
        :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
        :new.fid_pnom_modification := v_id_agent;

        INSERT INTO G_BASE_VOIE.TA_SEUIL_LOG(id_seuil, geom, code_insee, id_position, id_lateralite, date_action, fid_type_action, fid_pnom, id_troncon)
            VALUES(
                    :new.objectid, 
                    :new.geom,
                    :new.code_insee,
                    :new.fid_position,
                    :new.fid_lateralite,
                    sysdate,
                    v_id_insertion,
                    v_id_agent,
                    :new.fid_troncon
            );
    ELSE
        IF UPDATING THEN -- En cas de modification on insère les valeurs de la table TA_SEUIL_LOG, le numéro d'agent correspondant à l'utilisateur, la date de modification et le type de modification.
            :new.fid_pnom_modification := v_id_agent;

            INSERT INTO G_BASE_VOIE.TA_SEUIL_LOG(id_seuil, geom, code_insee, id_position, id_lateralite, date_action, fid_type_action, fid_pnom, id_troncon)
            VALUES(
                    :old.objectid,
                    :old.geom,
                    :old.code_insee,
                    :old.fid_position,
                    :old.fid_lateralite,
                    sysdate,
                    v_id_modification,
                    v_id_agent,
                    :old.fid_troncon
            );
        END IF;
    END IF;
    IF DELETING THEN -- En cas de suppression on insère les valeurs de la table TA_SEUIL_LOG, le numéro d'agent correspondant à l'utilisateur, la date de suppression et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_SEUIL_LOG(id_seuil, geom, code_insee, id_position, id_lateralite, date_action, fid_type_action, fid_pnom, id_troncon)
        VALUES(
                :old.objectid,
                :old.geom,
                :old.code_insee, 
                :old.fid_position,
                :old.fid_lateralite,
                sysdate,
                v_id_suppression,
                v_id_agent,
                :old.fid_troncon
        );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('geotrigger@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUD_TA_SEUIL_LOG','geotrigger@lillemetropole.fr');
END;

/

