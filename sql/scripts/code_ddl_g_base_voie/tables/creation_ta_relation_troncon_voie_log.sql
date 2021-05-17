/*
La table TA_RELATION_TRONCON_VOIE_LOG regroupant tous les types et états permettant de catégoriser les objets de la base voie.
*/

-- 1. Création de la table TA_RELATION_TRONCON_VOIE_LOG
CREATE TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    fid_relation_troncon_voie NUMBER(38,0) NOT NULL,
    fid_voie NUMBER(38,0) NOT NULL,
    fid_troncon NUMBER(38,0) NOT NULL,
    date_action DATE NOT NULL,
    fid_type_action NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG IS 'Table de log enregistrant l''évolution des associations voies / tronçons.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG.fid_relation_troncon_voie IS 'Clé étrangère vers la table TA_RELATION_TRONCON_VOIE permettant d''identifier les relations tronçon/voies.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG.fid_voie IS 'Identifiant des voies permettant d''associer une voie à un ou plusieurs tronçons.
Ancien champ : CCOMVOI.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG.fid_troncon IS 'Identifiant des tronçons permettant d''associer un ou plusieurs tronçons à une voie.
Ancien champ : CNUMTRC.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG.date_action IS 'Date de création, modification ou suppression de la voie avec ce tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de savoir quelle action a été effectuée sur l''association tronçon / voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant d''associer le pnom d''un agent à l''association voie / tronçon qu''il a créé, modifié ou supprimé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG 
ADD CONSTRAINT TA_RELATION_TRONCON_VOIE_LOG_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG
ADD CONSTRAINT TA_RELATION_TRONCON_VOIE_LOG_FID_RELATION_TRONCON_VOIE_FK
FOREIGN KEY (fid_relation_troncon_voie)
REFERENCES G_BASE_VOIE.TA_RELATION_TRONCON_VOIE(objectid);

ALTER TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG
ADD CONSTRAINT TA_RELATION_TRONCON_VOIE_LOG_FID_TYPE_ACTION_FK
FOREIGN KEY (fid_type_action)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG
ADD CONSTRAINT TA_RELATION_TRONCON_VOIE_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

-- 5. Création des index sur les clés étrangères
CREATE INDEX TA_RELATION_TRONCON_VOIE_LOG_FID_RELATION_TRONCON_VOIE_IDX ON G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG(fid_relation_troncon_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_RELATION_TRONCON_VOIE_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_RELATION_TRONCON_VOIE_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG TO G_ADMIN_SIG;