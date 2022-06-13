/*
Création du trigger A_IXX_TEMP_B_TRONCON permettant d'insérer l'identifiant du tronçon dans la table de relation TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE
*/

create or replace TRIGGER A_IXX_TEMP_B_TRONCON
AFTER INSERT ON G_BASE_VOIE.TEMP_B_TRONCON
FOR EACH ROW
DECLARE
BEGIN
    /*
    Objectif : ce trigger permet d'insérer l'identifiant du tronçon dans la table de relation TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE
    */
    -- Création d'un nouveau dossier dans TA_GG_DOSSIER correspondant au périmètre dessiné
    INSERT INTO G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE(fid_troncon)
    VALUES(:new.objectid);

EXCEPTION
    WHEN OTHERS THEN
        mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER A_IXX_TEMP_B_TRONCON','bjacq@lillemetropole.fr');
END;

/

