/*
Création de la table TA_TRONCON_LOG regroupant toutes les évolutions des voies physiques de la base voie situées dans TA_VOIE_PHYSIQUE.
*/
/*
DROP TABLE TA_VOIE_PHYSIQUE_LOG CASCADE CONSTRAINTS;
*/
-- 1. Création de la table TA_VOIE_PHYSIQUE_LOG
CREATE TABLE G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_VOIE_PHYSIQUE_LOG_OBJECTID.NEXTVAL,
    id_voie_physique NUMBER(38,0),
    id_action NUMBER(38,0),
    date_action DATE DEFAULT sysdate,
    fid_type_action NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG IS 'Table d''historisation des actions effectuées sur les voies physiques de la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG.id_voie_physique IS 'Identifiant des voies physiques de la table TA_VOIE_PHYSIQUE.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG.id_action IS 'Champ permettant de savoir s''il faut inverser le sens géométrique de la voie physique ou non.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG.date_action IS 'date de saisie, modification et suppression du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de catégoriser le type d''action effectuée sur les tronçons.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant d''associer le pnom d''un agent au tronçon qu''il a créé, modifié ou supprimé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG 
ADD CONSTRAINT TA_VOIE_PHYSIQUE_LOG_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG
ADD CONSTRAINT TA_VOIE_PHYSIQUE_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG
ADD CONSTRAINT TA_VOIE_PHYSIQUE_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

-- 5. Création des index
CREATE INDEX TA_VOIE_PHYSIQUE_LOG_ID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG(id_voie_physique)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_PHYSIQUE_LOG_ID_ACTION_IDX ON G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG(id_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_PHYSIQUE_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_PHYSIQUE_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG TO G_ADMIN_SIG;

/

