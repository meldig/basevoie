/*
La table TEMP_I_TRONCON - du projet i d''homogénéisation des latéralités par voie administrative - regroupe tous les tronçons de la base voie.
*/

-- 1. Création de la table TEMP_I_TRONCON
CREATE TABLE G_BASE_VOIE.TEMP_I_TRONCON(
    geom SDO_GEOMETRY NULL,
    objectid NUMBER(38,0),
    old_objectid NUMBER(38,0),
    date_saisie DATE DEFAULT sysdate NULL,
    date_modification DATE DEFAULT sysdate NULL,
    fid_pnom_saisie NUMBER(38,0) NULL,
    fid_pnom_modification NUMBER(38,0) NULL,
    fid_etat NUMBER(38,0) NULL,
    fid_voie_physique NUMBER(38,0) NOT NULL,
    fid_action NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_I_TRONCON IS 'Table - du projet i d''homogénéisation des latéralités par voie administrative - contenant les tronçons de la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_I_TRONCON.geom IS 'Géométrie de type ligne simple de chaque tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_I_TRONCON.objectid IS 'Clé primaire de la table identifiant chaque tronçon. Cette pk est auto-incrémentée et remplace l''ancien identifiant cnumtrc.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_I_TRONCON.old_objectid IS 'Ancien identifiant correspondant au tronçon avant la correction topologique.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_I_TRONCON.date_saisie IS 'date de saisie du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_I_TRONCON.date_modification IS 'Dernière date de modification du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_I_TRONCON.fid_pnom_saisie IS 'Clé étrangère vers la table TEMP_I_AGENT permettant de récupérer le pnom de l''agent ayant créé un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_I_TRONCON.fid_pnom_modification IS 'Clé étrangère vers la table TEMP_I_AGENT permettant de récupérer le pnom de l''agent ayant modifié un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_I_TRONCON.fid_etat IS 'Etat d''avancement des vérification : non-vérifié, vérifié.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_I_TRONCON.fid_voie_physique IS 'Clé étrangère permettant d''associer un ou plusieurs tronçons à une et une seule voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_I_TRONCON.fid_action IS 'Clé étrangère vers la table TEMP_I_LIBELLE permettant à l''utilisateur d''indiquer l''action à faire sur ce tronçon.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_I_TRONCON 
ADD CONSTRAINT TEMP_I_TRONCON_PK 
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
    'TEMP_I_TRONCON',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_I_TRONCON_SIDX
ON G_BASE_VOIE.TEMP_I_TRONCON(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_I_TRONCON
ADD CONSTRAINT TEMP_I_TRONCON_FID_PNOM_SAISIE_FK 
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TEMP_I_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_I_TRONCON
ADD CONSTRAINT TEMP_I_TRONCON_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TEMP_I_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_I_TRONCON
ADD CONSTRAINT TEMP_I_TRONCON_FID_ETAT_FK
FOREIGN KEY (fid_etat)
REFERENCES G_BASE_VOIE.TEMP_I_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TEMP_I_TRONCON
ADD CONSTRAINT TEMP_I_TRONCON_FID_VOIE_PHYSIQUE_FK
FOREIGN KEY (fid_voie_physique)
REFERENCES G_BASE_VOIE.TEMP_I_VOIE_PHYSIQUE(objectid);

ALTER TABLE G_BASE_VOIE.TEMP_I_TRONCON
ADD CONSTRAINT TEMP_I_TRONCON_FID_ACTION_FK
FOREIGN KEY (fid_action)
REFERENCES G_BASE_VOIE.TEMP_I_LIBELLE(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_I_TRONCON_OLD_OBJECTID_IDX ON G_BASE_VOIE.TEMP_I_TRONCON(old_objectid)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_I_TRONCON_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TEMP_I_TRONCON(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_I_TRONCON_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TEMP_I_TRONCON(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_I_TRONCON_FID_ETAT_IDX ON G_BASE_VOIE.TEMP_I_TRONCON(fid_etat)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_I_TRONCON_FID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.TEMP_I_TRONCON(fid_voie_physique)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_I_TRONCON_FID_ACTION_IDX ON G_BASE_VOIE.TEMP_I_TRONCON(fid_action)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_I_TRONCON TO G_ADMIN_SIG;

/

