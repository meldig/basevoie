/*
La table TA_VOIE_SUPRA_COMMUNALE_LOG  permet d''avoir l''historique de toutes les évolutions des voies supra-communales de la base voie.
*/
/*
DROP TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG CASCADE CONSTRAINTS;
*/

-- 1. Création de la table TA_VOIE_SUPRA_COMMUNALE_LOG
CREATE TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_VOIE_SUPRA_COMMUNALE_LOG_OBJECTID.NEXTVAL,
    id_voie_supra_communale NUMBER(38,0),
    id_sireo VARCHAR2(50 BYTE),
    nom VARCHAR2(50 BYTE) NULL,
    date_action DATE DEFAULT sysdate,
    fid_type_action NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG IS 'Table d''historisation des actions effectuées sur les voies supra-communales.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG.id_voie_supra_communale IS 'Identifiant de la voie supra-communale.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG.id_sireo IS 'Identifiants des anciennes voies départementales et voies supra-communales antérieures à la migration et mis en place par SIREO.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG.date_action IS 'Date de création, modification ou suppression d''une voie supra-communale.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de savoir quelle action a été effectuée sur la voie supra-communale.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant d''associer le pnom d''un agent à la voie supra-communale qu''il a créé, modifié ou supprimé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG 
ADD CONSTRAINT TA_VOIE_SUPRA_COMMUNALE_LOG_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG
ADD CONSTRAINT TA_VOIE_SUPRA_COMMUNALE_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG
ADD CONSTRAINT TA_VOIE_SUPRA_COMMUNALE_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

-- 5. Création des index
CREATE INDEX TA_VOIE_SUPRA_COMMUNALE_LOG_ID_VOIE_SUPRA_COMMUNALE_IDX ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(id_voie_supra_communale)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_SUPRA_COMMUNALE_LOG_ID_SIREO_IDX ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(id_sireo)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX TA_VOIE_SUPRA_COMMUNALE_LOG_NOM_IDX ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(nom)
    TABLESPACE G_ADT_INDX;
  
CREATE INDEX TA_VOIE_SUPRA_COMMUNALE_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_SUPRA_COMMUNALE_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

-- 7. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG TO G_ADMIN_SIG;
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG TO G_BASE_VOIE_R;

/

