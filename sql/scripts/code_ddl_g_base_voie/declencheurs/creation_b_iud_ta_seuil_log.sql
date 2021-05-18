create or replace TRIGGER G_BASE_VOIE.B_IUD_TA_SEUIL_LOG
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TA_SEUIL_LOG
FOR EACH ROW
    DECLARE
        username VARCHAR2(100);
        v_id_agent NUMBER(38,0);
        v_id_creation NUMBER(38,0);
        v_id_modification NUMBER(38,0);
        v_id_suppression NUMBER(38,0);
BEGIN
    -- Sélection du pcote_troncon
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pcote_troncon correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pcote_troncon = username;

    -- Sélection des id des actions présentes dans la table TA_LIBELLE
    SELECT a.objectid INTO v_id_creation FROM G_BASE_VOIE.TA_LIBELLE a WHERE a.valeur = 'création';
    SELECT a.objectid INTO v_id_modification FROM G_BASE_VOIE.TA_LIBELLE a WHERE a.valeur = 'modification';
    SELECT a.objectid INTO v_id_suppression FROM G_BASE_VOIE.TA_LIBELLE a WHERE a.valeur = 'suppression';

    IF INSERTING THEN -- En cas d'insertion on insère les valeurs de la table TA_SEUIL_LOG, le numéro d'agent correspondant à l'utilisateur, la date de création et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_SEUIL_LOG(fid_seuil, fid_infos_seuil, cote_troncon, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :new.objectid, 
                    :old.fid_infos_seuil, 
                    :old.cote_troncon,
                    sysdate,
                    v_id_creation,
                    v_id_agent);
    ELSE
        IF UPDATING THEN -- En cas de modification on insère les valeurs de la table TA_SEUIL_LOG, le numéro d'agent correspondant à l'utilisateur, la date de modification et le type de modification.
            INSERT INTO G_BASE_VOIE.TA_SEUIL_LOG(fid_seuil, fid_infos_seuil, cote_troncon, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :new.objectid, 
                    :old.fid_infos_seuil, 
                    :old.cote_troncon,
                    sysdate,
                    v_id_modification,
                    v_id_agent);
        END IF;
    END IF;
    IF DELETING THEN -- En cas de suppression on insère les valeurs de la table TA_SEUIL_LOG, le numéro d'agent correspondant à l'utilisateur, la date de suppression et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_SEUIL_LOG(fid_seuil, fid_infos_seuil, cote_troncon, date_action, fid_type_action, fid_pnom)
        VALUES(
                :new.objectid, 
                :old.fid_infos_seuil, 
                :old.cote_troncon,
                sysdate,
                v_id_suppression,
                v_id_agent);
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUD_TA_SEUIL_LOG','bjacq@lillemetropole.fr');
END;