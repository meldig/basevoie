
/*
Déclencheur permettant de récupérer pour la table TA_VOIE_SUPRA_COMMUNALE, les dates de création/modification des entités ainsi que le pnom de l'agent les ayant effectués.
Il permet aussi de donner un nom à la voie supra-communale.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IXX_TA_VOIE_SUPRA_COMMUNALE_DATE_PNOM
BEFORE INSERT ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TEMP_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- En cas d'insertion on insère la FK du pnom de l'agent, ayant créé la voie supra-communale, présent dans TEMP_AGENT. 
    IF INSERTING THEN 
        :new.fid_pnom_saisie := v_id_agent;
        :new.date_saisie := sysdate;
        :new.fid_pnom_modification := v_id_agent;
        :new.nom := TO_CHAR(:new.objectid);
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IXX_TA_VOIE_SUPRA_COMMUNALE_DATE_PNOM','bjacq@lillemetropole.fr');
END;


/

