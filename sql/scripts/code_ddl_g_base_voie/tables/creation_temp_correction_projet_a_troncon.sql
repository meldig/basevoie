/*
La table TEMP_CORRECTION_PROJET_A_TRONCON regroupe tous les tronçons de la base voie. C'est une table transitoire qui permet la correction des données avant leur insertion dans les tables de production.
*/

-- 1. Création de la table TEMP_CORRECTION_PROJET_A_TRONCON
CREATE TABLE G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON(
    objectid NUMBER(38,0),
    geom SDO_GEOMETRY NOT NULL,
    cdvaltro VARCHAR2(1 BYTE),
    date_saisie DATE DEFAULT sysdate NULL,
    date_modification DATE DEFAULT sysdate NULL,
    fid_voie NUMBER(38,0),
    fid_pnom_saisie NUMBER(38,0) NULL,
    fid_pnom_modification NUMBER(38,0) NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON IS 'Table transitoire permettant les corrections pour ensuite intégrer les données dans les tables de production. Elle contient les tronçons de la base voie qui servent à constituer les rues qui elles-mêmes constituent les voies. Ancienne table : ILTATRC.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON.objectid IS 'Clé primaire de la table identifiant chaque tronçon. Cette pk est auto-incrémentée et remplace l''ancien identifiant cnumtrc.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON.geom IS 'Géométrie de type ligne simple de chaque tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON.cdvaltro IS 'Champ permettant de distinguer les tronçons valides des tronçons invalides.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON.date_saisie IS 'date de saisie du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON.date_modification IS 'Dernière date de modification du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON.fid_voie IS 'Clé étrangère vers la table TA_VOIE permettant d''associer une voie à un ou plusieurs tronçons. Ancien champ : CCOMVOI.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON 
ADD CONSTRAINT TEMP_CORRECTION_PROJET_A_TRONCON_PK 
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
    'TEMP_CORRECTION_PROJET_A_TRONCON',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_CORRECTION_PROJET_A_TRONCON_SIDX
ON G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 7. Création des index 
CREATE INDEX TEMP_CORRECTION_PROJET_A_TRONCON_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_CORRECTION_PROJET_A_TRONCON_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_CORRECTION_PROJET_A_TRONCON_FID_VOIE_IDX ON G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON(fid_voie)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON TO G_ADMIN_SIG;

/

