create or replace TRIGGER G_BASE_VOIE.B_IUX_TA_TRONCON_DATE
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TA_TRONCON
FOR EACH ROW
    
BEGIN

    IF INSERTING THEN -- En cas d'insertion on insère la date du jour dans le champ date_saisie
       :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
    ELSE
        IF UPDATING THEN -- En cas de mise à jour on insère/met à jour le champ date_modification avec la date du jour, ainsi à chaque édition ce champ sera mis à jour
             :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
        END IF;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - B_IUX_TA_TRONCON_DATE','bjacq@lillemetropole.fr');
END;