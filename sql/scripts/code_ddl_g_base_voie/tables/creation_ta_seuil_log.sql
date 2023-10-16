/*
La table TA_SEUIL_LOG  permet d''avoir l''historique de toutes les évolutions des seuils de la base voie.
*/

-- 1. Création de la table TA_SEUIL_LOG
CREATE TABLE G_BASE_VOIE.TA_SEUIL_LOG(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_SEUIL_LOG_OBJECTID.NEXTVAL,
    geom SDO_GEOMETRY NOT NULL,
    id_seuil NUMBER(38,0),
    code_insee VARCHAR2(5),
    id_troncon NUMBER(38,0),
    id_position NUMBER(38,0),
    id_lateralite NUMBER(38,0),
    date_action DATE DEFAULT sysdate,
    fid_type_action NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_SEUIL_LOG IS 'Table d''historisation des actions effectuées sur les seuils.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.geom IS 'Géométrie de type point de chaque seuil présent dans la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.id_seuil IS 'Identifiant du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.code_insee IS 'Code INSEE du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.id_troncon IS 'Identifiant du tronçon affecté au seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.id_position IS 'Identifiant de la table G_BASE_VOIE.TA_LIBELLE permettant d''affecter une position à un seuil. Cette position désigne le lieu physique de l''adresse (seuil, boîte postale, portail, entrée de rue, etc).';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.id_lateralite IS 'Identifiant de la table G_BASE_VOIE.TA_LIBELLE permettant d''affecter une latéralité à un seuil. Cette latéralité est déterminée par rapport au sens géométrique du tronçon au sein d''une commune et par rapport à la latéralité de sa voie en limites de commune.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.date_action IS 'Date de création, modification ou suppression d''un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de savoir quelle action a été effectuée sur le seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant d''associer le pnom d''un agent au seuil qu''il a créé, modifié ou supprimé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_SEUIL_LOG 
ADD CONSTRAINT TA_SEUIL_LOG_PK 
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
    'TA_SEUIL_LOG',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_SEUIL_LOG
ADD CONSTRAINT TA_SEUIL_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_SEUIL_LOG
ADD CONSTRAINT TA_SEUIL_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

-- 6. Création des index
CREATE INDEX TA_SEUIL_LOG_SIDX
ON G_BASE_VOIE.TA_SEUIL_LOG(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

CREATE INDEX TA_SEUIL_LOG_ID_SEUIL_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(id_seuil)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_LOG_CODE_INSEE_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(code_insee)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_LOG_ID_TRONCON_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(id_troncon)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_LOG_ID_POSITION_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(id_position)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_LOG_ID_LATERALITE_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(id_lateralite)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX TA_SEUIL_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

-- 7. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_SEUIL_LOG TO G_ADMIN_SIG;

/

