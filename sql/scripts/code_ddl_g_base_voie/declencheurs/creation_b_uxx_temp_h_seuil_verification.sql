create or replace TRIGGER G_BASE_VOIE.B_UXX_TEMP_H_SEUIL_VERIFICATION
BEFORE UPDATE ON G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION
FOR EACH ROW
DECLARE

BEGIN
    -- Objectif : reporter les corrections d'affectation seuil/tronçon effectuées dans la table TEMP_H_SEUIL_VERIFICATION vers la table TEMP_H_SEUIL_VISUALISATION_TEST
    UPDATE G_BASE_VOIE.TEMP_H_SEUIL_VISUALISATION_TEST
        SET id_troncon = :new.fid_troncon
    WHERE
        id_seuil = :new.objectid;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_UXX_TEMP_H_SEUIL_VERIFICATION','bjacq@lillemetropole.fr','sysdig@lillemetropole.fr');
END;

/

