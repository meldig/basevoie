/*
La table TA_VOIE_SUPRA_COMMUNALE faisant le lien entre la table des voies administratives (TA_VOIE_ADMINISTRATIVE) et celle des voies supra-communales de la DEPV (OUT_DOMANIALITE).
*/
/*
DROP TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE CASCADE CONSTRAINTS;
*/
-- 1. Création de la table TA_VOIE_SUPRA_COMMUNALE
CREATE TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_VOIE_SUPRA_COMMUNALE_OBJECTID.NEXTVAL,
    id_sireo VARCHAR2(50 BYTE),
    nom VARCHAR2(50 BYTE) NULL,
    date_saisie DATE,
    date_modification DATE DEFAULT sysdate,
    fid_pnom_saisie NUMBER(38,0),
    fid_pnom_modification NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE IS 'Table contenant toutes les voies supra-communales (EX-RD ou non).';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE.id_sireo IS 'Identifiants des anciennes voies départementales et voies supra-communales antérieures à la migration et mis en place par SIREO.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE.nom IS 'Nom de la voie supra-communale - nom de l''Ex-RD ou laissez ce champ vide - Exemple : MD0750, MD0006D DGIR3.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE.date_saisie IS 'Date de saisie de la voie supra-communale en base.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE.date_modification IS 'Date de modification de la voie supra-communale en base.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant inséré en base une voie supra-communale.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié en base une voie supra-communale.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE 
ADD CONSTRAINT TA_VOIE_SUPRA_COMMUNALE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE
ADD CONSTRAINT TA_VOIE_SUPRA_COMMUNALE_FID_PNOM_SAISIE_FK 
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE
ADD CONSTRAINT TA_VOIE_SUPRA_COMMUNALE_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

-- 5. Création des index sur les clés étrangères et autres
CREATE INDEX TA_VOIE_SUPRA_COMMUNALE_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_SUPRA_COMMUNALE_ID_SIREO_IDX ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE(id_sireo)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_SUPRA_COMMUNALE_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE TO G_ADMIN_SIG;

/

