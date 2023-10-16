/*
Création de la table TA_VOIE_ADMINISTRATIVE_LOG regroupant toutes les évolutions des voies administratives de la base voie situés dans TA_VOIE_ADMINISTRATIVE.
*/
/*
DROP TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG CASCADE CONSTRAINTS;
*/
-- 1. Création de la table TA_VOIE_ADMINISTRATIVE_LOG
CREATE TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_VOIE_ADMINISTRATIVE_LOG_OBJECTID.NEXTVAL,
    id_voie_administrative NUMBER(38,0),
    id_genre_voie NUMBER(38,0),
    libelle_voie VARCHAR2(1000 BYTE),
    complement_nom_voie VARCHAR2(200),
    code_insee VARCHAR2(5),
    commentaire VARCHAR2(4000 BYTE),
    id_type_voie NUMBER(38,0),
    id_rivoli NUMBER(38,0),
    date_action DATE DEFAULT sysdate,
    fid_type_action NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG IS 'Table d''historisation des actions effectuées sur les voies administratives de la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.id_voie_administrative IS 'Identifiants des voies administratives de la table TA_VOIE_ADMINISTRATIVE.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.id_genre_voie IS 'Identifiant du genre du nom de la voie (féminin, masculin, neutre, etc).';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.libelle_voie IS 'Nom de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.complement_nom_voie IS 'Complément de nom de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.code_insee IS 'Code insee de la voie "administrative".';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.commentaire IS 'Commentaire de chaque voie, à remplir si besoin, pour une précision ou pour les voies n''ayant pas encore de nom.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.id_type_voie IS 'Identifiant de la table TA_TYPE_VOIE permettant d''associer une voie à un type de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.id_rivoli IS 'Identifiant de la table TA_RIVOLI permettant d''associer un code RIVOLI à chaque voie (cette fk est conservée uniquement dans le cadre de la production du jeu BAL).';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.date_action IS 'date de saisie, modification et suppression de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de catégoriser le type d''action effectuée sur les tronçons.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant d''associer le pnom d''un agent à la voie administrative qu''il a créé, modifié ou supprimé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG 
ADD CONSTRAINT TA_VOIE_ADMINISTRATIVE_LOG_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG
ADD CONSTRAINT TA_VOIE_ADMINISTRATIVE_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG
ADD CONSTRAINT TA_VOIE_ADMINISTRATIVE_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

-- 4. Création des index sur les clés étrangères et autres   
CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_ID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(id_voie_administrative)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_LIBELLE_VOIE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(libelle_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_COMPLEMENT_NOM_VOIE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(complement_nom_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_CODE_INSEE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(code_insee)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_ID_TYPE_VOIE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(id_type_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_ID_RIVOLI_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(id_rivoli)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_ID_GENRE_VOIE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(id_genre_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG TO G_ADMIN_SIG;

/

