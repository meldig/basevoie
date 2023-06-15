/*
Création du trigger B_IUX_TEMP_J_VOIE_ADMINISTRATIVE permettant de renseigner les dates et pnom de saisie/modification des voies administratives et de créer une nouvelle voie physique à la création d'une voie administrative.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUX_TEMP_J_VOIE_ADMINISTRATIVE
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TEMP_J_VOIE_ADMINISTRATIVE
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_voie_physique NUMBER(38,0);

BEGIN
    -- Objectif :  de renseigner les dates et pnom de saisie/modification des voies administratives et de créer une nouvelle voie physique à la création d'une voie administrative.
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TEMP_J_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TEMP_J_AGENT WHERE pnom = username;

    -- En cas d'insertion on insère la FK du pnom de l'agent, ayant créé la voie, présent dans TEMP_J_AGENT.
    IF INSERTING THEN
       :new.fid_pnom_saisie := v_id_agent;
       :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
       :new.fid_pnom_modification := v_id_agent;
       :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
    
    -- Création d'une nouvelle voie physique
        INSERT INTO G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE(fid_action)
           SELECT
                objectid
            FROM
                G_BASE_VOIE.TEMP_J_LIBELLE
            WHERE
                libelle_court = 'à déterminer';
    END IF;
    IF UPDATING THEN -- En cas de mise à jour on édite le champ date_modification avec la date du jour et le champ fid_pnom_modification avec la FK du pnom de l'agent, ayant modifié la voie, présent dans TEMP_J_AGENT.
        :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
        :new.fid_pnom_modification := v_id_agent;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM || ' Erreur provoquée par ' || username || ' à ' || sysdate,'ERREUR TRIGGER - B_IUX_TEMP_J_VOIE_ADMINISTRATIVE','bjacq@lillemetropole.fr');
END;

/

