/*
La table TA_TRONCON regroupe tous les tronçons de la base voie.
*/

-- 1. Création de la table TA_TRONCON
CREATE TABLE G_BASE_VOIE.TA_TRONCON(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_TRONCON_OBJECTID.NEXTVAL,
    geom SDO_GEOMETRY NULL,
    old_objectid NUMBER(38,0),
    date_saisie DATE NULL,
    date_modification DATE DEFAULT sysdate NULL,
    fid_pnom_saisie NUMBER(38,0) NULL,
    fid_pnom_modification NUMBER(38,0) NULL,
    fid_voie_physique NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_TRONCON IS 'Table contenant les tronçons de la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.objectid IS 'Clé primaire de la table identifiant chaque tronçon. Cette pk est auto-incrémentée et remplace l''ancien identifiant cnumtrc.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.geom IS 'Géométrie de type ligne simple de chaque tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.old_objectid IS 'Ancien identifiant correspondant au tronçon avant la correction topologique.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.date_saisie IS 'date de saisie du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.date_modification IS 'Dernière date de modification du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.fid_voie_physique IS 'Clé étrangère permettant d''associer un ou plusieurs tronçons à une et une seule voie physique.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_TRONCON 
ADD CONSTRAINT TA_TRONCON_PK 
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
    'TA_TRONCON',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TA_TRONCON_SIDX
ON G_BASE_VOIE.TA_TRONCON(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_TRONCON
ADD CONSTRAINT TA_TRONCON_FID_PNOM_SAISIE_FK 
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_TRONCON
ADD CONSTRAINT TA_TRONCON_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_TRONCON
ADD CONSTRAINT TA_TRONCON_FID_VOIE_PHYSIQUE_FK
FOREIGN KEY (fid_voie_physique)
REFERENCES G_BASE_VOIE.TA_VOIE_PHYSIQUE(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TA_TRONCON_OLD_OBJECTID_IDX ON G_BASE_VOIE.TA_TRONCON(old_objectid)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TA_TRONCON(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TA_TRONCON(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_FID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.TA_TRONCON(fid_voie_physique)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_TRONCON TO G_ADMIN_SIG;

/

