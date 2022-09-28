/*
La table TEMP_B_TRONCON_SAUVEGARDE regroupe tous les tronçons de la base voie.
*/

-- 1. Création de la table TEMP_B_TRONCON_SAUVEGARDE
CREATE TABLE G_BASE_VOIE.TEMP_B_TRONCON_SAUVEGARDE(
    objectid NUMBER(38,0),
    geom SDO_GEOMETRY NULL,
    date_saisie DATE DEFAULT sysdate NULL,
    date_modification DATE DEFAULT sysdate NULL,
    fid_pnom_saisie NUMBER(38,0) NULL,
    fid_pnom_modification NUMBER(38,0) NULL,
    fid_etat NUMBER(38,0) NULL,
    ouvrage_art VARCHAR2(10) NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_B_TRONCON_SAUVEGARDE IS 'Table de sauvegarde de la table TEMP_B_TRONCON_B. La dernière mise à jour de la table TEMP_B_TRONCON_SAUVEGARDE date du 28/09/2022.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_TRONCON_SAUVEGARDE.objectid IS 'Clé primaire de la table identifiant chaque tronçon. Cette pk est auto-incrémentée et remplace l''ancien identifiant cnumtrc.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_TRONCON_SAUVEGARDE.geom IS 'Géométrie de type ligne simple de chaque tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_TRONCON_SAUVEGARDE.date_saisie IS 'date de saisie du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_TRONCON_SAUVEGARDE.date_modification IS 'Dernière date de modification du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_TRONCON_SAUVEGARDE.fid_pnom_saisie IS 'Clé étrangère vers la table TEMP_B_AGENT permettant de récupérer le pnom de l''agent ayant créé un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_TRONCON_SAUVEGARDE.fid_pnom_modification IS 'Clé étrangère vers la table TEMP_B_AGENT permettant de récupérer le pnom de l''agent ayant modifié un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_TRONCON_SAUVEGARDE.fid_etat IS 'Etat d''avancement des corrections : en erreur, corrigé, correct.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_TRONCON_SAUVEGARDE.ouvrage_art IS 'Champ permettant de distinguer attributairement les tronçons situés sur un ouvrage d''art ou l''intersectant, des autres.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_B_TRONCON_SAUVEGARDE 
ADD CONSTRAINT TEMP_B_TRONCON_SAUVEGARDE_PK 
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
    'TEMP_B_TRONCON_SAUVEGARDE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_B_TRONCON_SAUVEGARDE_SIDX
ON G_BASE_VOIE.TEMP_B_TRONCON_SAUVEGARDE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_B_TRONCON_SAUVEGARDE_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TEMP_B_TRONCON_SAUVEGARDE(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_B_TRONCON_SAUVEGARDE_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TEMP_B_TRONCON_SAUVEGARDE(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_B_TRONCON_SAUVEGARDE_FID_ETAT_IDX ON G_BASE_VOIE.TEMP_B_TRONCON_SAUVEGARDE(fid_etat)
    TABLESPACE G_ADT_INDX;

-- Cet index dispose d'une fonction permettant d'accélérer la récupération du code INSEE de la commune d'appartenance du tronçon. 
-- Il créé également un champ virtuel dans lequel on peut aller chercher ce code INSEE.
CREATE INDEX TEMP_B_TRONCON_SAUVEGARDE_CODE_INSEE_IDX
ON G_BASE_VOIE.TEMP_B_TRONCON_SAUVEGARDE(GET_CODE_INSEE_TRONCON('TEMP_B_TRONCON_SAUVEGARDE', geom))
TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_B_TRONCON_SAUVEGARDE TO G_ADMIN_SIG;

/

