/*
La table TA_INFOS_SEUIL_LOG regroupe toutes les évlutions des objets présents dans la table TA_INFOS_SEUIL de la base voie.
*/

-- 1. Création de la table TA_INFOS_SEUIL_LOG
CREATE TABLE G_BASE_VOIE.TA_INFOS_SEUIL_LOG(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_INFOS_SEUIL_LOG_OBJECTID.NEXTVAL,
    id_infos_seuil NUMBER(38,0) NOT NULL,
    id_seuil NUMBER(38,0) NOT NULL,
    numero_seuil NUMBER(5,0) NOT NULL,
    complement_numero_seuil VARCHAR2(10),
    date_action DATE NOT NULL,
    fid_type_action NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_INFOS_SEUIL_LOG IS 'Table de log permettant d''enregistrer toutes les évlutions des objets présents dans la table TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.id_infos_seuil IS 'Identifiant du seuil dans la table TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.id_seuil IS 'Identifiant de la table TA_SEUIL, permettant d''affecter une géométrie à un ou plusieurs seuils, dans le cas où plusieurs se superposent sur le même point.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.numero_seuil IS 'Numéro de seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.complement_numero_seuil IS 'Complément du numéro de seuil. Exemple : 1 bis';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.date_action IS 'Date de chaque action effectuée sur les objets de la table TA_INFOS_SEUILS.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de catégoriser les actions effectuées sur la table TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé, modifié ou supprimé des données dans TA_INFOS_SEUIL.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_INFOS_SEUIL_LOG 
ADD CONSTRAINT TA_INFOS_SEUIL_LOG_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_INFOS_SEUIL_LOG
ADD CONSTRAINT TA_INFOS_SEUIL_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_INFOS_SEUIL_LOG
ADD CONSTRAINT TA_INFOS_SEUIL_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

-- 5. Création des index sur les clés étrangères et les autres champs
CREATE INDEX TA_INFOS_SEUIL_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_SEUIL_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_SEUIL_LOG_ID_INFOS_SEUIL_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL_LOG(id_infos_seuil)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_SEUIL_LOG_ID_SEUIL_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL_LOG(id_seuil)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_INFOS_SEUIL_LOG TO G_ADMIN_SIG;

/

