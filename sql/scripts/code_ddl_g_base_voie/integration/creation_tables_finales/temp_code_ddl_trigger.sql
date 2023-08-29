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
        mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER G_BASE_VOIE.A_IXX_TA_SEUIL','bjacq@lillemetropole.fr');
END;

/

/*
Déclencheur permettant de remplir la table de logs TA_VOIE_ADMINISTRATIVE_LOG dans laquelle sont enregistrés chaque insertion, 
modification et suppression des données de la table TA_VOIE_ADMINISTRATIVE avec leur date et le pnom de l'agent les ayant effectuées.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUD_TA_VOIE_ADMINISTRATIVE_LOG
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_insertion NUMBER(38,0);
    v_id_modification NUMBER(38,0);
    v_id_suppression NUMBER(38,0);

BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- Sélection des id des actions présentes dans la table TA_LIBELLE
    SELECT
        a.objectid INTO v_id_insertion
    FROM
        G_BASE_VOIE.TA_LIBELLE a
    WHERE
        a.libelle_court = 'insertion';

    SELECT
        a.objectid INTO v_id_modification
    FROM
        G_BASE_VOIE.TA_LIBELLE a
    WHERE
        a.libelle_court = 'édition';

    SELECT
        a.objectid INTO v_id_suppression
    FROM
        G_BASE_VOIE.TA_LIBELLE a
    WHERE
        a.libelle_court = 'suppression';

    IF INSERTING THEN -- En cas d'insertion on insère les valeurs de la table TA_VOIE_ADMINISTRATIVE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de insertion et le type de modification.
        :new.fid_pnom_saisie := v_id_agent;
        :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
        :new.fid_pnom_modification := v_id_agent;

        -- Création d'une nouvelle voie physique
        INSERT INTO G_BASE_VOIE.TA_VOIE_PHYSIQUE(fid_action)
           SELECT
                objectid
            FROM
                G_BASE_VOIE.TA_LIBELLE
            WHERE
                libelle_court = 'à déterminer';

        INSERT INTO G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(id_voie_administrative, id_genre_voie, libelle_voie, complement_nom_voie, code_insee, commentaire, id_type_voie, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :new.objectid,
                    :new.fid_genre_voie,
                    :new.libelle_voie,
                    :new.complement_nom_voie,
                    :new.code_insee,
                    :new.commentaire,
                    :new.fid_type_voie,
                    sysdate,
                    v_id_insertion,
                    v_id_agent
            );
    ELSE
        IF UPDATING THEN -- En cas de modification on insère les valeurs de la table TA_VOIE_ADMINISTRATIVE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de modification et le type de modification.
            :new.fid_pnom_modification := v_id_agent;

            INSERT INTO G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(id_voie_administrative, id_genre_voie, libelle_voie, complement_nom_voie, code_insee, commentaire, id_type_voie, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :old.objectid,
                    :old.fid_genre_voie,
                    :old.libelle_voie,
                    :old.complement_nom_voie,
                    :old.code_insee,
                    :old.commentaire,
                    :old.fid_type_voie,
                    sysdate,
                    v_id_modification,
                    v_id_agent
            );
        END IF;
    END IF;
    IF DELETING THEN -- En cas de suppression on insère les valeurs de la table TA_VOIE_ADMINISTRATIVE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de suppression et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(id_voie_administrative, id_genre_voie, libelle_voie, complement_nom_voie, code_insee, commentaire, id_type_voie, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :old.objectid,
                    :old.fid_genre_voie,
                    :old.libelle_voie,
                    :old.complement_nom_voie,
                    :old.code_insee,
                    :old.commentaire,
                    :old.fid_type_voie,
                    sysdate,
                    v_id_suppression,
                    v_id_agent
            );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUD_TA_VOIE_ADMINISTRATIVE_LOG','bjacq@lillemetropole.fr');
END;

/

/*
Création du trigger G_BASE_VOIE.A_IXX_TA_VOIE_ADMINISTRATIVE permettant de créer une voie physique à la création d'une voie administrative et de faire la relation entre les deux.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.A_IXX_TA_VOIE_ADMINISTRATIVE
AFTER INSERT ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_voie_physique NUMBER(38,0);
    v_id_voie_admin NUMBER(38,0);
BEGIN
    -- Objectif : à la création d'une voie administrative, faire la relation entre cette voie et la voie physique créée par le trigger B_IUD_TA_VOIE_ADMINISTRATIVE_LOG.

    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de la voie physique sans voie administrative
    SELECT
        objectid
        INTO v_id_voie_physique
    FROM
        G_BASE_VOIE.TA_VOIE_PHYSIQUE
    WHERE
        objectid NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE);

    -- Sélection de la nouvelle voie administrative
    v_id_voie_admin := :new.objectid;

    -- Création de la relation voie physique / administrative
    INSERT INTO G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE(fid_voie_physique, fid_voie_administrative)
        VALUES(v_id_voie_physique, v_id_voie_admin);

        EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM || ' Erreur provoquée par ' || username || ' à ' || sysdate,'ERREUR TRIGGER - A_IXX_TA_VOIE_ADMINISTRATIVE','bjacq@lillemetropole.fr');
END;

/

/*
Déclencheur permettant de remplir la table de logs TA_INFOS_SEUIL_LOG dans laquelle sont enregistrés chaque insertion, 
modification et suppression des données de la table TA_INFOS_SEUIL avec leur date et le pnom de l'agent les ayant effectuées.
Il permet aussi de remplir les champs date_saisie, date_modificiation, fid_pnom_saisie et fid_pnom_modification de la table TA_INFOS_SEUIL.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUD_TA_INFOS_SEUIL_LOG
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TA_INFOS_SEUIL
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_insertion NUMBER(38,0);
    v_id_modification NUMBER(38,0);
    v_id_suppression NUMBER(38,0);
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- Sélection des id des actions présentes dans la table TA_LIBELLE
    SELECT 
        a.objectid INTO v_id_insertion 
    FROM 
        G_BASE_VOIE.TA_LIBELLE a
    WHERE 
        a.libelle_court = 'insertion';

    SELECT 
        a.objectid INTO v_id_modification 
    FROM 
        G_BASE_VOIE.TA_LIBELLE a
    WHERE 
        a.libelle_court = 'édition';
            
    SELECT 
        a.objectid INTO v_id_suppression 
    FROM 
        G_BASE_VOIE.TA_LIBELLE a
    WHERE 
        a.libelle_court = 'suppression';

    IF INSERTING THEN -- En cas d'insertion on insère les valeurs de la table TA_INFOS_SEUIL, le numéro d'agent correspondant à l'utilisateur, la date de insertion et le type de modification.
        :new.fid_pnom_saisie := v_id_agent;
        :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
        :new.fid_pnom_modification := v_id_agent;

        INSERT INTO G_BASE_VOIE.TA_INFOS_SEUIL_LOG(id_infos_seuil, numero_seuil, complement_numero_seuil, date_action, id_seuil, fid_type_action, fid_pnom)
            VALUES(
                    :new.objectid, 
                    :new.numero_seuil,  
                    :new.complement_numero_seuil, 
                    sysdate,
                    :new.fid_seuil,
                    v_id_insertion,
                    v_id_agent);
    ELSE
        IF UPDATING THEN -- En cas de modification on insère les valeurs de la table TA_INFOS_SEUIL, le numéro d'agent correspondant à l'utilisateur, la date de modification et le type de modification.
            :new.fid_pnom_modification := v_id_agent;
            
            INSERT INTO G_BASE_VOIE.TA_INFOS_SEUIL_LOG(id_infos_seuil, numero_seuil, complement_numero_seuil, date_action, id_seuil, fid_type_action, fid_pnom)
            VALUES(
                    :old.objectid, 
                    :old.numero_seuil, 
                    :old.complement_numero_seuil, 
                    sysdate,
                    :old.fid_seuil,
                    v_id_modification,
                    v_id_agent);
        END IF;
    END IF;
    IF DELETING THEN -- En cas de suppression on insère les valeurs de la table TA_INFOS_SEUIL, le numéro d'agent correspondant à l'utilisateur, la date de suppression et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_INFOS_SEUIL_LOG(id_infos_seuil, numero_seuil, complement_numero_seuil, date_action, id_seuil, fid_type_action, fid_pnom)
        VALUES(
                :old.objectid, 
                :old.numero_seuil,  
                :old.complement_numero_seuil, 
                sysdate,
                :old.fid_seuil,
                v_id_suppression,
                v_id_agent);
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUD_TA_INFOS_SEUIL_LOG','bjacq@lillemetropole.fr');
END;

/

/*
Déclencheur permettant de remplir la table de logs TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG dans laquelle sont enregistrés chaque insertion, 
modification et suppression des données de la table TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE avec leur date et le pnom de l'agent les ayant effectuées.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUD_TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_insertion NUMBER(38,0);
    v_id_modification NUMBER(38,0);
    v_id_suppression NUMBER(38,0);

BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- Sélection des id des actions présentes dans la table TA_LIBELLE
    SELECT
        a.objectid INTO v_id_insertion
    FROM
        G_BASE_VOIE.TA_LIBELLE a
    WHERE
        a.libelle_court = 'insertion';

    SELECT
        a.objectid INTO v_id_modification
    FROM
        G_BASE_VOIE.TA_LIBELLE a
    WHERE
        a.libelle_court = 'édition';

    SELECT
        a.objectid INTO v_id_suppression
    FROM
        G_BASE_VOIE.TA_LIBELLE a
    WHERE
        a.libelle_court = 'suppression';

    IF INSERTING THEN -- En cas d'insertion on insère les valeurs de la table TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de insertion et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG(id_voie_physique, id_voie_administrative, id_lateralite, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :new.fid_voie_physique, 
                    :new.fid_voie_administrative, 
                    :new.fid_lateralite,
                    sysdate,
                    v_id_insertion,
                    v_id_agent
            );
    ELSE
        IF UPDATING THEN -- En cas de modification on insère les valeurs de la table TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de modification et le type de modification.
            INSERT INTO G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG(id_voie_physique, id_voie_administrative, id_lateralite, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :old.fid_voie_physique, 
                    :old.fid_voie_administrative, 
                    :old.fid_lateralite,
                    sysdate,
                    v_id_modification,
                    v_id_agent
            );
        END IF;
    END IF;
    IF DELETING THEN -- En cas de suppression on insère les valeurs de la table TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de suppression et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG(id_voie_physique, id_voie_administrative, id_lateralite, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :old.fid_voie_physique, 
                    :old.fid_voie_administrative, 
                    :old.fid_lateralite,
                    sysdate,
                    v_id_suppression,
                    v_id_agent
            );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUD_TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG','bjacq@lillemetropole.fr');
END;

/

/*
Déclencheur permettant de remplir la table de logs TA_SEUIL_LOG dans laquelle sont enregistrés chaque insertion, 
modification et suppression des données de la table TA_SEUIL avec leur date et le pnom de l'agent les ayant effectuées.
Il permet aussi de remplir les champs date_saisie, date_modificiation, fid_pnom_saisie et fid_pnom_modification de la table TA_SEUIL.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUD_TA_SEUIL_LOG
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TA_SEUIL
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_insertion NUMBER(38,0);
    v_id_modification NUMBER(38,0);
    v_id_suppression NUMBER(38,0);
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- Sélection des id des actions présentes dans la table TA_LIBELLE
    SELECT 
        a.objectid INTO v_id_insertion 
    FROM 
        G_BASE_VOIE.TA_LIBELLE a 
    WHERE 
        a.libelle_court = 'insertion';

    SELECT 
        a.objectid INTO v_id_modification 
    FROM 
        G_BASE_VOIE.TA_LIBELLE a 
    WHERE 
        a.libelle_court = 'édition';
            
    SELECT 
        a.objectid INTO v_id_suppression 
    FROM 
        G_BASE_VOIE.TA_LIBELLE a 
    WHERE 
        a.libelle_court = 'suppression';

    IF INSERTING THEN -- En cas d'insertion on insère les valeurs de la table TA_SEUIL_LOG, le numéro d'agent correspondant à l'utilisateur, la date de insertion et le type de modification.
        :new.fid_pnom_saisie := v_id_agent;
        :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
        :new.fid_pnom_modification := v_id_agent;

        INSERT INTO G_BASE_VOIE.TA_SEUIL_LOG(id_seuil, geom, code_insee, id_position, id_lateralite, date_action, fid_type_action, fid_pnom, id_troncon)
            VALUES(
                    :new.objectid, 
                    :new.geom,
                    :new.code_insee,
                    :new.fid_position,
                    :new.fid_lateralite,
                    sysdate,
                    v_id_insertion,
                    v_id_agent,
                    :new.fid_troncon
            );
    ELSE
        IF UPDATING THEN -- En cas de modification on insère les valeurs de la table TA_SEUIL_LOG, le numéro d'agent correspondant à l'utilisateur, la date de modification et le type de modification.
            :new.fid_pnom_modification := v_id_agent;

            INSERT INTO G_BASE_VOIE.TA_SEUIL_LOG(id_seuil, geom, code_insee, id_position, id_lateralite, date_action, fid_type_action, fid_pnom, id_troncon)
            VALUES(
                    :old.objectid,
                    :old.geom,
                    :old.code_insee,
                    :old.fid_position,
                    :old.fid_lateralite,
                    sysdate,
                    v_id_modification,
                    v_id_agent,
                    :old.fid_troncon
            );
        END IF;
    END IF;
    IF DELETING THEN -- En cas de suppression on insère les valeurs de la table TA_SEUIL_LOG, le numéro d'agent correspondant à l'utilisateur, la date de suppression et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_SEUIL_LOG(id_seuil, geom, code_insee, id_position, id_lateralite, date_action, fid_type_action, fid_pnom, id_troncon)
        VALUES(
                :old.objectid,
                :old.geom,
                :old.code_insee, 
                :old.fid_position,
                :old.fid_lateralite,
                sysdate,
                v_id_suppression,
                v_id_agent,
                :old.fid_troncon
        );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUD_TA_SEUIL_LOG','bjacq@lillemetropole.fr');
END;

/

/*
Déclencheur permettant de remplir la table de logs TA_TRONCON_LOG dans laquelle sont enregistrés chaque insertion, 
modification et suppression des données de la table TA_TRONCON avec leur date et le pnom de l'agent les ayant effectuées.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUD_TA_TRONCON_LOG
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TA_TRONCON
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_insertion NUMBER(38,0);
    v_id_modification NUMBER(38,0);
    v_id_suppression NUMBER(38,0);

BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- Sélection des id des actions présentes dans la table TA_LIBELLE
    SELECT
        a.objectid INTO v_id_insertion
    FROM
        G_BASE_VOIE.TA_LIBELLE a
    WHERE
        a.libelle_court = 'insertion';

    SELECT
        a.objectid INTO v_id_modification
    FROM
        G_BASE_VOIE.TA_LIBELLE a
    WHERE
        a.libelle_court = 'édition';

    SELECT
        a.objectid INTO v_id_suppression
    FROM
        G_BASE_VOIE.TA_LIBELLE a
    WHERE
        a.libelle_court = 'suppression';

    IF INSERTING THEN -- En cas d'insertion on insère les valeurs de la table TA_TRONCON_LOG, le numéro d'agent correspondant à l'utilisateur, la date de insertion et le type de modification.
        :new.fid_pnom_saisie := v_id_agent;
        :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
        :new.fid_pnom_modification := v_id_agent;

        INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(id_troncon, old_id_troncon, geom, date_action, fid_type_action, fid_pnom, id_voie_physique)
            VALUES(
                    :new.objectid,
                    :new.old_objectid,
                    :new.geom,
                    sysdate,
                    v_id_insertion,
                    v_id_agent,
                    :new.fid_voie_physique
            );
    ELSE
        IF UPDATING THEN -- En cas de modification on insère les valeurs de la table TA_TRONCON_LOG, le numéro d'agent correspondant à l'utilisateur, la date de modification et le type de modification.
            :new.fid_pnom_modification := v_id_agent;

            INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(id_troncon, old_id_troncon, geom, date_action, fid_type_action, fid_pnom, id_voie_physique)
            VALUES(
                    :old.objectid,
                    :old.old_objectid,
                    :old.geom,
                    sysdate,
                    v_id_modification,
                    v_id_agent,
                    :old.fid_voie_physique
            );
        END IF;
    END IF;
    IF DELETING THEN -- En cas de suppression on insère les valeurs de la table TA_TRONCON_LOG, le numéro d'agent correspondant à l'utilisateur, la date de suppression et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(id_troncon, old_id_troncon, geom, date_action, fid_type_action, fid_pnom, id_voie_physique)
        VALUES(
                :old.objectid,
                :old.old_objectid,
                :old.geom,
                sysdate,
                v_id_suppression,
                v_id_agent,
                :old.fid_voie_physique
        );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUD_TA_TRONCON_LOG','bjacq@lillemetropole.fr');
END;

/

/*
Déclencheur permettant de remplir la table de logs TA_VOIE_PHYSIQUE_LOG dans laquelle sont enregistrés chaque insertion, 
modification et suppression des données de la table TA_VOIE_PHYSIQUE avec leur date et le pnom de l'agent les ayant effectuées.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUD_TA_VOIE_PHYSIQUE_LOG
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TA_VOIE_PHYSIQUE
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_insertion NUMBER(38,0);
    v_id_modification NUMBER(38,0);
    v_id_suppression NUMBER(38,0);

BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- Sélection des id des actions présentes dans la table TA_LIBELLE
    SELECT
        a.objectid INTO v_id_insertion
    FROM
        G_BASE_VOIE.TA_LIBELLE a
    WHERE
        a.libelle_court = 'insertion';

    SELECT
        a.objectid INTO v_id_modification
    FROM
        G_BASE_VOIE.TA_LIBELLE a
    WHERE
        a.libelle_court = 'édition';

    SELECT
        a.objectid INTO v_id_suppression
    FROM
        G_BASE_VOIE.TA_LIBELLE a
    WHERE
        a.libelle_court = 'suppression';

    IF INSERTING THEN -- En cas d'insertion on insère les valeurs de la table TA_VOIE_PHYSIQUE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de insertion et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG(id_voie_physique, id_action, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :new.objectid, 
                    :new.fid_action,
                    sysdate,
                    v_id_insertion,
                    v_id_agent
            );
    ELSE
        IF UPDATING THEN -- En cas de modification on insère les valeurs de la table TA_VOIE_PHYSIQUE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de modification et le type de modification.
            INSERT INTO G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG(id_voie_physique, id_action, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :old.objectid, 
                    :old.fid_action,
                    sysdate,
                    v_id_modification,
                    v_id_agent
            );
        END IF;
    END IF;
    IF DELETING THEN -- En cas de suppression on insère les valeurs de la table TA_VOIE_PHYSIQUE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de suppression et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG(id_voie_physique, id_action, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :old.objectid, 
                    :old.fid_action,
                    sysdate,
                    v_id_suppression,
                    v_id_agent
            );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUD_TA_VOIE_PHYSIQUE_LOG','bjacq@lillemetropole.fr');
END;

/

/*
Déclencheur permettant de remplir la table de logs TA_VOIE_SUPRA_COMMUNALE_LOG dans laquelle sont enregistrés chaque insertion, 
modification et suppression des données de la table TA_VOIE_SUPRA_COMMUNALE avec leur date et le pnom de l'agent les ayant effectuées.
Il rempli dans le même temps la table source TA_VOIE_SUPRA_COMMUNALE.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUD_TA_VOIE_SUPRA_COMMUNALE_LOG
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_insertion NUMBER(38,0);
    v_id_modification NUMBER(38,0);
    v_id_suppression NUMBER(38,0);

BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- Sélection des id des actions présentes dans la table TA_LIBELLE
    SELECT
        a.objectid INTO v_id_insertion
    FROM
        G_BASE_VOIE.TA_LIBELLE a
    WHERE
        a.libelle_court = 'insertion';

    SELECT
        a.objectid INTO v_id_modification
    FROM
        G_BASE_VOIE.TA_LIBELLE a
    WHERE
        a.libelle_court = 'édition';

    SELECT
        a.objectid INTO v_id_suppression
    FROM
        G_BASE_VOIE.TA_LIBELLE a
    WHERE
        a.libelle_court = 'suppression';

    IF INSERTING THEN -- En cas d'insertion on insère les valeurs de la table TA_VOIE_SUPRA_COMMUNALE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de insertion et le type de modification.
        -- Remplissage des champs de la table TA_VOIE_SUPRA_COMMUNALE
        :new.fid_pnom_saisie := v_id_agent;
        :new.date_saisie := sysdate;
        :new.fid_pnom_modification := v_id_agent;
        :new.nom := TO_CHAR(:new.objectid);

        INSERT INTO G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(id_voie_supra_communale, id_sireo, nom, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :new.objectid, 
                    :new.id_sireo,
                    :new.nom,
                    sysdate,
                    v_id_insertion,
                    v_id_agent
            );
    ELSE
        IF UPDATING THEN -- En cas de modification on insère les valeurs de la table TA_VOIE_SUPRA_COMMUNALE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de modification et le type de modification.
            INSERT INTO G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(id_voie_supra_communale, id_sireo, nom, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :old.objectid, 
                    :old.id_sireo,
                    :old.nom,
                    sysdate,
                    v_id_modification,
                    v_id_agent
            );
        END IF;
    END IF;
    IF DELETING THEN -- En cas de suppression on insère les valeurs de la table TA_VOIE_SUPRA_COMMUNALE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de suppression et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(id_voie_supra_communale, id_sireo, nom, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :old.objectid, 
                    :old.id_sireo,
                    :old.nom,
                    sysdate,
                    v_id_suppression,
                    v_id_agent
            );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUD_TA_VOIE_SUPRA_COMMUNALE_LOG','bjacq@lillemetropole.fr');
END;

/

