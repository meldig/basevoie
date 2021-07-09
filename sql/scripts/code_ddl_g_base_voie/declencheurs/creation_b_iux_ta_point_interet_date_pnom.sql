/*
Déclencheur permettant de récupérer dans la table TA_POINT_INTERET le pnom de l'agent ayant effectué la création et l'édition des objets.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUX_POINT_INTERET_DATE_PNOM
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TA_POINT_INTERET
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
             
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    IF INSERTING THEN -- En cas d'insertion on insère la FK du pnom de l'agent, ayant créé le POI, présent dans TA_AGENT.
       :new.fid_pnom_saisie := v_id_agent;
       :new.fid_pnom_modification := v_id_agent;
    ELSE
        IF UPDATING THEN -- En cas de mise à jour on édite le champ fid_pnom_modification avec la FK du pnom de l'agent, ayant modifié le POI, présent dans TA_AGENT.
             :new.fid_pnom_modification := v_id_agent;
        END IF;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - B_IUX_TA_POINT_INTERET_DATE_PNOM','bjacq@lillemetropole.fr');
END;

/
