/*
Déclencheur permettant de récupérer dans la table TEMP_CORRECTION_PROJET_A_VOIE, les dates de création/modification des entités ainsi que le pnom de l'agent les ayant effectués.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUX_TEMP_CORRECTION_PROJET_A_VOIE_DATE_PNOM
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_VOIE
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    fid_mtd NUMBER(38,0);
    
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TEMP_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TEMP_AGENT WHERE pnom = username;

    -- En cas d'insertion on insère la FK du pnom de l'agent, ayant créé la voie, présent dans TEMP_AGENT.
    IF INSERTING THEN
       :new.fid_pnom_saisie := v_id_agent;
       :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
       :new.fid_pnom_modification := v_id_agent;
       :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
    ELSE
        IF UPDATING THEN -- En cas de mise à jour on édite le champ date_modification avec la date du jour et le champ fid_pnom_modification avec la FK du pnom de l'agent, ayant modifié la voie, présent dans TEMP_AGENT.
            :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
            :new.fid_pnom_modification := v_id_agent;
        END IF;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUX_TEMP_CORRECTION_PROJET_A_VOIE_DATE_PNOM','bjacq@lillemetropole.fr');
END;

/

