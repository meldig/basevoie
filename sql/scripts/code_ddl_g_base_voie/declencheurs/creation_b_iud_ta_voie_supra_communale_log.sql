/*
Déclencheur permettant de remplir la table de logs TA_VOIE_SUPRA_COMMUNALE_LOG dans laquelle sont enregistrés chaque insertion, 
modification et suppression des données de la table TA_VOIE_SUPRA_COMMUNALE avec leur date et le pnom de l'agent les ayant effectuées.
Il rempli dans le même temps la table source TA_VOIE_SUPRA_COMMUNALE.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUD_TA_VOIE_SUPRA_COMMUNALE_LOG
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE
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

    IF INSERTING THEN -- En cas d'insertion on insère les valeurs de la table TA_VOIE_SUPRA_COMMUNALE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de insertion et le type de modification.
        -- Remplissage des champs de la table TA_VOIE_SUPRA_COMMUNALE
        :new.fid_pnom_saisie := v_id_agent;
        :new.date_saisie := sysdate;
        :new.fid_pnom_modification := v_id_agent;
        :new.nom := TO_CHAR(:new.objectid);

        INSERT INTO G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(id_voie_supra_communale, id_sireo, nom, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :new.objectid, 
                    :new.id_sireo,
                    :new.nom,
                    sysdate,
                    v_id_insertion,
                    v_id_agent
            );
    ELSE
        IF UPDATING THEN -- En cas de modification on insère les valeurs de la table TA_VOIE_SUPRA_COMMUNALE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de modification et le type de modification.
            INSERT INTO G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(id_voie_supra_communale, id_sireo, nom, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :old.objectid, 
                    :old.id_sireo,
                    :old.nom,
                    sysdate,
                    v_id_modification,
                    v_id_agent
            );
        END IF;
    END IF;
    IF DELETING THEN -- En cas de suppression on insère les valeurs de la table TA_VOIE_SUPRA_COMMUNALE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de suppression et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(id_voie_supra_communale, id_sireo, nom, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :old.objectid, 
                    :old.id_sireo,
                    :old.nom,
                    sysdate,
                    v_id_suppression,
                    v_id_agent
            );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUD_TA_VOIE_SUPRA_COMMUNALE_LOG','bjacq@lillemetropole.fr');
END;

/

