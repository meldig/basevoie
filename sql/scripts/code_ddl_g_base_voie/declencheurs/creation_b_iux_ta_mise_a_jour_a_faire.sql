/*
Création du trigger G_BASE_VOIE.B_IUX_TA_MISE_A_JOUR_A_FAIRE permettant d'insérer les date de création/modification des points à faire.
*/

CREATE OR REPLACE TRIGGER "G_BASE_VOIE"."B_IUX_TA_MISE_A_JOUR_A_FAIRE" 
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_code_insee NUMBER(5,0);

BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- Sélection du code INSEE du point
    SELECT
        TRIM(b.code_insee)
        INTO v_code_insee
    FROM
        G_REFERENTIEL.MEL_COMMUNE_LLH b,
        USER_SDO_GEOM_METADATA m
    WHERE
        m.table_name = 'TA_MISE_A_JOUR_A_FAIRE'
        AND SDO_CONTAINS(
                b.geom,
                :new.geom
            )='TRUE';

    -- En cas d'insertion, on renseigne l'agent ayant fait la création et la date à laquelle il l'a faite ainsi que le code insee de l'entité.
    IF INSERTING THEN 
        :new.fid_pnom_saisie := v_id_agent;
        :new.date_saisie := sysdate;
        :new.code_insee := v_code_insee;
    END IF;

    -- En cas de mise à jour, on renseigne l'agent ayant fait la modification et la date à laquelle il l'a faite ainsi que le code insee de l'entité.
    IF UPDATING THEN 
        :new.fid_pnom_modification := v_id_agent;
        :new.date_modification := sysdate;
        :new.code_insee := v_code_insee;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUX_TA_MISE_A_JOUR_A_FAIRE','bjacq@lillemetropole.fr');
END;


/

