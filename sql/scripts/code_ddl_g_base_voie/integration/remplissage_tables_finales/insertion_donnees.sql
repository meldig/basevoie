/*
Insertion des données dans la structure de production
*/

-- Insertion des pnoms des agents
MERGE INTO G_BASE_VOIE.TA_AGENT a
    USING(
        SELECT
            numero_agent,
            pnom,
            validite
        FROM
            G_BASE_VOIE.TA_AGENT@DBL_MULTIT_G_BASE_VOIE_MAJ
    )t
    ON(a.numero_agent = t.numero_agent)
WHEN NOT MATCHED THEN
    INSERT(a.numero_agent,a.pnom,a.validite)
    VALUES(t.numero_agent,t.pnom,t.validite);
-- Résultat : 10 lignes insérées.

-- Insertion des types de voie
MERGE INTO G_BASE_VOIE.TA_TYPE_VOIE a
    USING(
        SELECT
            objectid,
            code_type_voie,
            libelle
        FROM
            G_BASE_VOIE.TA_TYPE_VOIE@DBL_MULTIT_G_BASE_VOIE_MAJ
    )t
    ON(a.code_type_voie = t.code_type_voie AND a.libelle = t.libelle)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.code_type_voie, a.libelle)
    VALUES(t.objectid, t.code_type_voie, t.libelle);
-- Résultat : 133 lignes fusionnées.

-- Insertion des valeurs de libellé dans TA_LIBELLE
MERGE INTO G_BASE_VOIE.TA_LIBELLE a
    USING(
        SELECT
            objectid,
            libelle_court,
            libelle_long
        FROM
            G_BASE_VOIE.TA_LIBELLE@DBL_MULTIT_G_BASE_VOIE_MAJ
    )t
    ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.libelle_court, a.libelle_long)
    VALUES(t.objectid, t.libelle_court, t.libelle_long);
-- Résultat : 5 lignes fusionnées.

-- Insertion des codes RIVOLI
MERGE INTO G_BASE_VOIE.TA_RIVOLI a
    USING(
        SELECT
            objectid,
            code_rivoli,
            cle_controle
        FROM
            G_BASE_VOIE.TA_RIVOLI@DBL_MULTIT_G_BASE_VOIE_MAJ
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.code_rivoli, a.cle_controle)
    VALUES(t.objectid, t.code_rivoli, t.cle_controle);
-- Résultat : 11 235 lignes fusionnées.

-- Insertion des tronçons
INSERT INTO G_BASE_VOIE.TA_TRONCON(objectid, old_objectid, geom, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification, fid_voie_physique)
SELECT
    objectid, 
    old_objectid, 
    geom, 
    date_saisie, 
    date_modification, 
    fid_pnom_saisie, 
    fid_pnom_modification, 
    fid_voie_physique
FROM 
    G_BASE_VOIE.TA_TRONCON@DBL_MULTIT_G_BASE_VOIE_MAJ;
-- Résultat : 50 625 lignes fusionnées.

-- Insertion des voies physiques
MERGE INTO G_BASE_VOIE.TA_VOIE_PHYSIQUE a
    USING(
            SELECT
                objectid,
                fid_action
            FROM
              G_BASE_VOIE.TA_VOIE_PHYSIQUE@DBL_MULTIT_G_BASE_VOIE_MAJ
        )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.fid_action)
    VALUES(t.objectid, t.fid_action);
-- Résultat : 22 945  lignes fusionnées.

-- Insertion des relations voies physiques / voies administratives
MERGE INTO G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
    USING(
        SELECT
            objectid,
            fid_voie_administrative,
            fid_voie_physique,
            fid_lateralite
        FROM
            G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE@DBL_MULTIT_G_BASE_VOIE_MAJ
    )t
ON(a.fid_voie_administrative = t.fid_voie_administrative AND a.fid_voie_physique = t.fid_voie_physique)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.fid_voie_administrative, a.fid_voie_physique, a.fid_lateralite)
    VALUES(t.objectid, t.fid_voie_administrative, t.fid_voie_physique, t.fid_lateralite);
-- Résultat : 23 652 lignes fusionnées.

-- Insertion des voies administratives
MERGE INTO G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE a
    USING(
        SELECT
            OBJECTID,
            FID_GENRE_VOIE,
            LIBELLE_VOIE,
            COMPLEMENT_NOM_VOIE,
            CODE_INSEE,
            COMMENTAIRE,
            DATE_SAISIE,
            DATE_MODIFICATION,
            FID_PNOM_SAISIE,
            FID_PNOM_MODIFICATION,
            FID_TYPE_VOIE,
            FID_RIVOLI
        FROM
            G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE@DBL_MULTIT_G_BASE_VOIE_MAJ
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.fid_genre_voie, a.libelle_voie, a.complement_nom_voie, a.code_insee, a.commentaire, a.fid_type_voie, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.fid_rivoli)
    VALUES(t.objectid, t.fid_genre_voie, t.libelle_voie, t.complement_nom_voie, t.code_insee, t.commentaire, t.fid_type_voie, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification, t.fid_rivoli);
-- Résultat : 22 165 lignes fusionnées.

-- Import des relations voies principales / secondaires
MERGE INTO G_BASE_VOIE.TA_HIERARCHISATION_VOIE a
    USING(
        SELECT
            fid_voie_principale,
            fid_voie_secondaire
        FROM
            G_BASE_VOIE.TA_HIERARCHISATION_VOIE@DBL_MULTIT_G_BASE_VOIE_MAJ
    )t
ON(a.fid_voie_principale = t.fid_voie_principale AND a.fid_voie_secondaire = t.fid_voie_secondaire)
WHEN NOT MATCHED THEN
    INSERT(a.fid_voie_principale, a.fid_voie_secondaire)
    VALUES(t.fid_voie_principale, t.fid_voie_secondaire);
-- Résultat : 4330 lignes insérées.
    
-- Insertion des voies supra-communales
MERGE INTO G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE a
    USING(
        SELECT
            objectid,
            id_sireo,
            nom,
            date_saisie,
            date_modification,
            fid_pnom_saisie,
            fid_pnom_modification
        FROM 
            G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE@DBL_MULTIT_G_BASE_VOIE_MAJ
    )t
ON(t.objectid = a.objectid AND t.id_sireo = a.id_sireo)
WHEN NOT MATCHED THEN
    INSERT(a.objectid,a.id_sireo,a.nom,a.date_saisie,a.date_modification,a.fid_pnom_saisie,a.fid_pnom_modification)
    VALUES(t.objectid,t.id_sireo,t.nom,t.date_saisie,t.date_modification,t.fid_pnom_saisie,t.fid_pnom_modification);

-- Insertion des relations voies administratives / voies supra-communales
MERGE INTO G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE a
    USING(
        SELECT
            fid_voie_administrative,
            fid_voie_supra_communale
        FROM 
            G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE@DBL_MULTIT_G_BASE_VOIE_MAJ
    )t
ON(t.fid_voie_administrative = a.fid_voie_administrative AND t.fid_voie_supra_communale = a.fid_voie_supra_communale)
WHEN NOT MATCHED THEN
    INSERT(a.fid_voie_administrative,a.fid_voie_supra_communale)
    VALUES(t.fid_voie_administrative,t.fid_voie_supra_communale);

-- Insertion des seuils
INSERT INTO G_BASE_VOIE.TA_SEUIL(objectid, geom, code_insee, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification, fid_troncon, fid_position, fid_lateralite)
    SELECT
        objectid, 
        geom, 
        code_insee, 
        date_saisie, 
        date_modification, 
        fid_pnom_saisie, 
        fid_pnom_modification, 
        fid_troncon, 
        fid_position, 
        fid_lateralite
    FROM 
        G_BASE_VOIE.TA_SEUIL@DBL_MULTIT_G_BASE_VOIE_MAJ;

-- Insertion des seuils
MERGE INTO G_BASE_VOIE.TA_INFOS_SEUIL a
    USING(
        SELECT
            objectid,
            numero_seuil,
            complement_numero_seuil,
            date_saisie,
            date_modification,
            fid_pnom_saisie,
            fid_pnom_modification,
            fid_seuil
        FROM 
            G_BASE_VOIE.TA_INFOS_SEUIL@DBL_MULTIT_G_BASE_VOIE_MAJ
    )t
ON(t.objectid = a.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.numero_seuil, a.complement_numero_seuil, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.fid_seuil)
    VALUES(t.objectid, t.numero_seuil, t.complement_numero_seuil, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification, t.fid_seuil);

-- Insertion des tronçons
INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(objectid, geom, id_troncon, old_id_troncon, id_voie_physique, date_action, fid_type_action, fid_pnom)
    SELECT
        objectid,
        geom,
        id_troncon,
        old_id_troncon,
        id_voie_physique,
        date_action,
        fid_type_action,
        fid_pnom
    FROM
      G_BASE_VOIE.TA_TRONCON_LOG@DBL_MULTIT_G_BASE_VOIE_MAJ;
-- Résultat : 50 625 lignes fusionnées.

-- Insertion des voies physiques
MERGE INTO G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG a
    USING(
            SELECT
                objectid,
                id_voie_physique,
                id_action,
                date_action,
                fid_type_action,
                fid_pnom
            FROM
              G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG@DBL_MULTIT_G_BASE_VOIE_MAJ
        )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.id_voie_physique, a.id_action, a.date_action, a.fid_type_action, a.fid_pnom)
    VALUES(t.objectid, t.id_voie_physique, t.id_action, t.date_action, t.fid_type_action, t.fid_pnom);
-- Résultat : 22 945  lignes fusionnées.

-- Insertion des relations voies physiques / voies administratives
MERGE INTO G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG a
    USING(
        SELECT
            objectid,
            id_voie_physique,
            id_voie_administrative,
            id_lateralite,
            date_action,
            fid_type_action,
            fid_pnom
        FROM
            G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG@DBL_MULTIT_G_BASE_VOIE_MAJ
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.id_voie_physique, a.id_voie_administrative, a.id_lateralite, a.date_action, a.fid_type_action, a.fid_pnom)
    VALUES(t.objectid, t.id_voie_physique, t.id_voie_administrative, t.id_lateralite, t.date_action, t.fid_type_action, t.fid_pnom);
-- Résultat : 23 652 lignes fusionnées.

-- Insertion des voies administratives
MERGE INTO G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG a
    USING(
        SELECT
            objectid,
            id_voie_administrative,
            id_genre_voie,
            libelle_voie,
            complement_nom_voie,
            code_insee,
            commentaire,
            id_type_voie,
            id_rivoli,
            date_action,
            fid_type_action,
            fid_pnom
        FROM
            G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG@DBL_MULTIT_G_BASE_VOIE_MAJ
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.id_voie_administrative, a.id_genre_voie, a.libelle_voie, a.complement_nom_voie, a.code_insee, a.commentaire, a.id_type_voie, a.id_rivoli, a.date_action, a.fid_type_action, a.fid_pnom)
    VALUES(t.objectid, t.id_voie_administrative, t.id_genre_voie, t.libelle_voie, t.complement_nom_voie, t.code_insee, t.commentaire, t.id_type_voie, t.id_rivoli, t.date_action, t.fid_type_action, t.fid_pnom);
-- Résultat : 22 165 lignes fusionnées.
    
-- Insertion des voies supra-communales
MERGE INTO G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG a
    USING(
        SELECT
            objectid,
            id_voie_supra_communale,
            id_sireo,
            nom,
            date_action,
            fid_type_action,
            fid_pnom
        FROM 
            G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG@DBL_MULTIT_G_BASE_VOIE_MAJ
    )t
ON(t.objectid = a.objectid AND t.id_sireo = a.id_sireo)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.id_voie_supra_communale, a.id_sireo, a.nom, a.date_action, a.fid_type_action, a.fid_pnom)
    VALUES(t.objectid, t.id_voie_supra_communale, t.id_sireo, t.nom, t.date_action, t.fid_type_action, t.fid_pnom);

-- Insertion des seuils
INSERT INTO G_BASE_VOIE.TA_SEUIL_LOG a
    SELECT
        objectid,
        geom,
        id_seuil,
        code_insee,
        id_troncon,
        id_position,
        id_lateralite,
        date_action,
        fid_type_action,
        fid_pnom
    FROM 
        G_BASE_VOIE.TA_SEUIL_LOG@DBL_MULTIT_G_BASE_VOIE_MAJ;

-- Insertion des seuils
MERGE INTO G_BASE_VOIE.TA_INFOS_SEUIL_LOG a
    USING(
        SELECT
            objectid,
            id_infos_seuil,
            id_seuil,
            numero_seuil,
            complement_numero_seuil,
            date_action,
            fid_type_action,
            fid_pnom
        FROM 
            G_BASE_VOIE.TA_INFOS_SEUIL_LOG@DBL_MULTIT_G_BASE_VOIE_MAJ
    )t
ON(t.objectid = a.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.id_infos_seuil, a.id_seuil, a.numero_seuil, a.complement_numero_seuil, a.date_action, a.fid_type_action, a.fid_pnom)
    VALUES(t.objectid, t.id_infos_seuil, t.id_seuil, t.numero_seuil, t.complement_numero_seuil, t.date_action, t.fid_type_action, t.fid_pnom);

INSERT INTO G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE(objectid,id_seuil,id_troncon,id_voie_administrative,code_insee,explication,date_saisie,date_edition,fid_pnom_saisie,fid_pnom_modification,fid_etat_avancement,geom)
SELECT
    objectid,
    id_seuil,
    id_troncon,
    id_voie_administrative,
    code_insee,
    explication,
    date_saisie,
    date_edition,
    fid_pnom_saisie,
    fid_pnom_modification,
    fid_etat_avancement,
    geom
FROM
    G_BASE_VOIE.TEMP_MISE_A_JOUR_A_FAIRE@DBL_MULTIT_G_BASE_VOIE_MAJ;

COMMIT;