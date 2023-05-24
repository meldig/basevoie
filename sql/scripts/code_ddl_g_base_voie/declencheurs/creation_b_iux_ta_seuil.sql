/*
Création du trigger B_IXX_TA_SEUIL permettant de renseigner les dates et pnom de saisie/modification des seuils.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUX_TA_SEUIL
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TA_SEUIL
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
BEGIN
    -- Objectif :  de renseigner les dates et pnom de saisie/modification des seuils et de créer une entité correspondante dans la table TA_INFOS_SEUIL.
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- En cas d'insertion on insère la FK du pnom de l'agent, ayant créé le seuil, présent dans TA_AGENT.
    IF INSERTING THEN
       :new.fid_pnom_saisie := v_id_agent;
       :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
       :new.fid_pnom_modification := v_id_agent;
       :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
    END IF;

    IF UPDATING THEN -- En cas de mise à jour on édite le champ date_modification avec la date du jour et le champ fid_pnom_modification avec la FK du pnom de l'agent, ayant modifié le seuil, présent dans TA_AGENT.
        :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
        :new.fid_pnom_modification := v_id_agent;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM || ' Erreur provoquée par ' || username || ' à ' || sysdate,'ERREUR TRIGGER - B_IUX_TA_SEUIL','bjacq@lillemetropole.fr');
END;

/

