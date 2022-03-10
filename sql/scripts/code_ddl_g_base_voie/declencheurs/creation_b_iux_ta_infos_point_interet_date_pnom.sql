/*
Déclencheur permettant de récupérer dans la table TA_INFOS_POINT_INTERET, les dates de création/modification des géométries des POI ainsi que le pnom de l'agent les ayant effectués.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUX_TA_INFOS_POINT_INTERET_DATE_PNOM
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TA_INFOS_POINT_INTERET
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
             
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    IF INSERTING THEN -- En cas d'insertion on insère la FK du pnom de l'agent, ayant créé la géométrie du POI, présent dans TA_AGENT.
       :new.fid_pnom_saisie := v_id_agent;
       :new.fid_pnom_modification := v_id_agent;
    ELSE
        IF UPDATING THEN -- En cas de mise à jour on édite le champ date_modification avec la date du jour et le champ fid_pnom_modification avec la FK du pnom de l'agent, ayant modifié la géométrie du POI, présent dans TA_AGENT.
             :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
             :new.fid_pnom_modification := v_id_agent;
        END IF;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - B_IUX_TA_INFOS_POINT_INTERET_DATE_PNOM','bjacq@lillemetropole.fr');
END;

/
