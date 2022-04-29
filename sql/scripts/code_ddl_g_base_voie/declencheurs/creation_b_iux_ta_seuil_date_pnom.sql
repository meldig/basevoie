/*
Déclencheur permettant de récupérer dans la table TA_SEUIL, les dates de création/modification des entités ainsi que le pnom de l'agent les ayant effectués.
*/

create or replace TRIGGER G_BASE_VOIE.B_IUX_TEST_MIGRATION_SEUIL_DATE_PNOM
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TEST_MIGRATION_SEUIL
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_troncon NUMBER(38,0);
    
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TEST_MIGRATION_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TEST_MIGRATION_AGENT WHERE pnom = username;

    -- Sélection du tronçon le plus proche
    WITH
        C_1 AS(-- Sélection des tronçons et de la distance seuil/tronçon dans un rayon de 50 mètres autours du seuil
            SELECT
                b.objectid AS id_troncon,
                SDO_NN_DISTANCE(1) AS distance
            FROM
                G_BASE_VOIE.TEST_MIGRATION_TRONCON b
            WHERE
                SDO_NN(b.geom, :new.geom, 'sdo_batch_size=10 distance=500 unit=meter', 1) = 'TRUE'
    
        ),
        
        C_2 AS(-- Sélection de la distance seuil/tronçon minimum
            SELECT
                MIN(distance) AS distance
            FROM
                C_1
        )
        
        SELECT -- Récupération du tronçon situé à la distance minimum du seuil
            a.id_troncon INTO v_id_troncon
        FROM
            C_1 a
            INNER JOIN C_2 b ON b.distance = a.distance;
    
    IF INSERTING THEN -- En cas d'insertion on insère la FK du pnom de l'agent, ayant créé le seuil, présent dans TEST_MIGRATION_AGENT.
       :new.fid_pnom_saisie := v_id_agent;
       :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
       :new.fid_pnom_modification := v_id_agent;
       :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
       :new.fid_troncon := v_id_troncon;
    ELSE
        IF UPDATING THEN -- En cas de mise à jour on édite le champ date_modification avec la date du jour et le champ fid_pnom_modification avec la FK du pnom de l'agent, ayant modifié le seuil, présent dans TEST_MIGRATION_AGENT.
            :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
            :new.fid_pnom_modification := v_id_agent;
        END IF;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUX_TEST_MIGRATION_SEUIL_DATE_PNOM','bjacq@lillemetropole.fr');
END;

/

