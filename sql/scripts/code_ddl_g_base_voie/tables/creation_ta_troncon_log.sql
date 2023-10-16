/*
Création de la table TA_TRONCON_LOG regroupant toutes les évolutions des tronçons de la base voie situés dans TA_TRONCON.
*/

-- 1. Création de la table TA_TRONCON_LOG
CREATE TABLE G_BASE_VOIE.TA_TRONCON_LOG(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_TRONCON_LOG_OBJECTID.NEXTVAL,
    geom SDO_GEOMETRY NOT NULL,
    id_troncon NUMBER(38,0),
    old_id_troncon NUMBER(38,0),
    id_voie_physique NUMBER(38,0),
    date_action DATE DEFAULT sysdate,
    fid_type_action NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_TRONCON_LOG IS 'Table Table d''historisation des actions effectuées sur les entités de la table TA_TRONCON.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.geom IS 'Géométrie de type ligne simple de chaque tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.id_troncon IS 'Identifiant du tronçon de la table TA_TRONCON.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.old_id_troncon IS 'Ancien identifiant du troncon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.id_voie_physique IS 'Identifiant de la voie physique associée au tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.date_action IS 'date de saisie, modification et suppression du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de catégoriser le type d''action effectuée sur les tronçons.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant d''associer le pnom d''un agent au tronçon qu''il a créé, modifié ou supprimé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_TRONCON_LOG 
ADD CONSTRAINT TA_TRONCON_LOG_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TA_TRONCON_LOG',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_TRONCON_LOG
ADD CONSTRAINT TA_TRONCON_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_TRONCON_LOG
ADD CONSTRAINT TA_TRONCON_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

-- 6. Création des index
CREATE INDEX TA_TRONCON_LOG_SIDX
ON G_BASE_VOIE.TA_TRONCON_LOG(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

CREATE INDEX TA_TRONCON_LOG_ID_TRONCON_IDX ON G_BASE_VOIE.TA_TRONCON_LOG(id_troncon)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_LOG_OLD_ID_TRONCON_IDX ON G_BASE_VOIE.TA_TRONCON_LOG(old_id_troncon)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_LOG_ID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.TA_TRONCON_LOG(id_voie_physique)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_TRONCON_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_TRONCON_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

-- 7. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_TRONCON_LOG TO G_ADMIN_SIG;

/

