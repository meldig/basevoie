/*
Déclencheur permettant de récupérer dans la table TA_TRONCON, les dates de création/modification des entités ainsi que le pnom de l'agent les ayant effectués.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUX_TA_TRONCON_DATE_PNOM
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TA_TRONCON
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);

BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    IF INSERTING THEN -- En cas d'insertion on insère la date du jour dans le champ date_saisie
       :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
       :new.fid_pnom_saisie := v_id_agent;
    ELSE
        IF UPDATING THEN -- En cas de mise à jour on insère/met à jour le champ date_modification avec la date du jour, ainsi à chaque édition ce champ sera mis à jour
             :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
             :new.fid_pnom_modification := v_id_agent; 
        END IF;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - B_IUX_TA_TRONCON_DATE_PNOM','bjacq@lillemetropole.fr');
END;

/
