/*
Objectif : créer un trigger permettant de mettre à jour le nom des voies administratives, dans le cadre de l'homogénéisation des noms de voie.
*/
CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_UXX_TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE
BEFORE UPDATE ON G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_etat NUMBER(38,0);
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;
    SELECT objectid INTO v_id_etat FROM G_BASE_VOIE.TEMP_C_LIBELLE WHERE libelle_court = 'corrigé';
    
    :new.fid_etat := v_id_etat;
    
    UPDATE G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE a
        SET a.libelle_voie = :new.nom_voie, a.date_modification = TO_DATE(sysdate, 'dd/mm/yy'), a.fid_pnom_modification = v_id_agent
    WHERE
        :old.id_voie_administrative = a.objectid;
    
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM || ' Erreur provoquée par l''agent ' || username,'ERREUR TRIGGER - B_UXX_TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE','bjacq@lillemetropole.fr');
END;

/

