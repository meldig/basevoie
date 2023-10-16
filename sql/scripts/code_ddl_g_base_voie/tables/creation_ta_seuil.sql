/*
Création de la table TA_SEUIL regroupant toutes les géométries des seuils de la base voie.
*/
/*
DROP TABLE G_BASE_VOIE.TA_SEUIL CASCADE CONSTRAINTS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'TA_SEUIL';
*/
-- 1. Création de la table TA_SEUIL
CREATE TABLE G_BASE_VOIE.TA_SEUIL(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_SEUIL_OBJECTID.NEXTVAL,
    geom SDO_GEOMETRY,
    code_insee VARCHAR2(5 BYTE),
    date_saisie DATE NULL,
    date_modification DATE DEFAULT sysdate NOT NULL,
    fid_pnom_saisie NUMBER(38,0) NOT NULL,
    fid_pnom_modification NUMBER(38,0) NOT NULL,
    fid_troncon NUMBER(38,0),
    fid_position NUMBER(38,0),
    fid_lateralite NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_SEUIL IS 'Table contenant les géométries des seuils de la Base Voie. Plusieurs seuils peuvent se situer sur le même point géographique. Ancienne table : ILTASEU';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.objectid IS 'Clé primaire auto-incrémentée de la table identifiant chaque seuil. Cette pk remplace l''ancien identifiant idseui.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.geom IS 'Géométrie de type point de chaque seuil présent dans la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.code_insee IS 'Code INSEE de chaque seuil inséré en dur à la saisie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.date_saisie IS 'date de saisie du seuil (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.date_modification IS 'Dernière date de modification du seuil(par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.fid_troncon IS 'Identifiant du tronçon de la table TA_TRONCON associé au seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.fid_position IS 'Clé étrangère vers la table TA_LIBELLE permettant d''indiquer la position de l''adresse (seuil, boîte postale, portail, etc).';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.fid_lateralite IS 'Clé étrangère vers la table G_BASE_VOIE.TA_LIBELLE permettant d''affecter une latéralité à un seuil. Cette latéralité est déterminée par rapport au sens géométrique du tronçon.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_SEUIL 
ADD CONSTRAINT TA_SEUIL_PK 
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
    'TA_SEUIL',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TA_SEUIL_SIDX
ON G_BASE_VOIE.TA_SEUIL(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_SEUIL
ADD CONSTRAINT TA_SEUIL_FID_PNOM_SAISIE_FK
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_SEUIL
ADD CONSTRAINT TA_SEUIL_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_SEUIL
ADD CONSTRAINT TA_SEUIL_FID_TRONCON_FK
FOREIGN KEY (fid_troncon)
REFERENCES G_BASE_VOIE.TA_TRONCON(objectid);

ALTER TABLE G_BASE_VOIE.TA_SEUIL
ADD CONSTRAINT TA_SEUIL_FID_POSITION_FK
FOREIGN KEY (fid_position)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_SEUIL
ADD CONSTRAINT TA_SEUIL_FID_LATERALITE_FK 
FOREIGN KEY(fid_lateralite)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TA_SEUIL_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TA_SEUIL(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TA_SEUIL(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_FID_TRONCON_IDX ON G_BASE_VOIE.TA_SEUIL(fid_troncon)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX TA_SEUIL_CODE_INSEE_IDX ON G_BASE_VOIE.TA_SEUIL(code_insee)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX TA_SEUIL_FID_POSITION_IDX ON G_BASE_VOIE.TA_SEUIL(fid_position)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_FID_LATERALITE_IDX ON G_BASE_VOIE.TA_SEUIL(fid_lateralite)
    TABLESPACE G_ADT_INDX;
    
-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_SEUIL TO G_ADMIN_SIG;

/

