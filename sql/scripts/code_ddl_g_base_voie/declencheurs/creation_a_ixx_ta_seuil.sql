/*
Création du trigger A_IXX_TA_SEUIL permettant de créer une entité dans TA_INFOS_SEUIL, suite à la création du point du seuil dans TA_SEUIL.
*/

CREATE OR REPLACE TRIGGER A_IXX_TA_SEUIL
AFTER INSERT ON G_BASE_VOIE.TA_SEUIL
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);

BEGIN
    /*
    Objectif : ce trigger permet de créer l'identifiant d'un seuil et ses informations de création/édition (les autres informations étant renseignées via l'application dans un second temps).
    */
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_GG_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- Création d'un nouveau dossier dans TA_GG_DOSSIER correspondant au périmètre dessiné
    INSERT INTO G_BASE_VOIE.TA_INFOS_SEUIL(fid_seuil, numero_seuil, fid_pnom_saisie, date_saisie, fid_pnom_modification, date_modification)
    VALUES(:new.objectid, 0, v_id_agent, TO_DATE(sysdate, 'dd/mm/yy'), v_id_agent, TO_DATE(sysdate, 'dd/mm/yy'));

EXCEPTION
    WHEN OTHERS THEN
        mail.sendmail('geotrigger@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER G_BASE_VOIE.A_IXX_TA_SEUIL','geotrigger@lillemetropole.fr');
END;

/

