/*
Création du trigger G_BASE_VOIE.A_IXX_TEMP_J_VOIE_ADMINISTRATIVE permettant de créer une voie physique à la création d'une voie administrative et de faire la relation entre les deux.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.A_IXX_TEMP_J_VOIE_ADMINISTRATIVE
AFTER INSERT ON G_BASE_VOIE.TEMP_J_VOIE_ADMINISTRATIVE
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_voie_physique NUMBER(38,0);
    v_id_voie_admin NUMBER(38,0);
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de la voie physique sans voie administrative
    SELECT
        objectid
        INTO v_id_voie_physique
    FROM
        G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE
    WHERE
        objectid NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TEMP_J_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE);
    
    -- Sélection de la nouvelle voie administrative
    v_id_voie_admin := :new.objectid;
        
    -- Création de la relation voie physique / administrative
    INSERT INTO G_BASE_VOIE.TEMP_J_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE(fid_voie_physique, fid_voie_administrative)
        VALUES(v_id_voie_physique, v_id_voie_admin);
    
        EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM || ' Erreur provoquée par ' || username || ' à ' || sysdate,'ERREUR TRIGGER - A_IXX_TEMP_J_VOIE_ADMINISTRATIVE','bjacq@lillemetropole.fr');
END;

/

