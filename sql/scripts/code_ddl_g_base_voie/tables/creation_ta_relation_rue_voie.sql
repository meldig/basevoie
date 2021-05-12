/*
La table TA_RELATION_RUE_VOIE regroupe toutes les associations voies/rues.
*/

-- 1. Création de la table TA_RELATION_RUE_VOIE
CREATE TABLE G_BASE_VOIE.TA_RELATION_RUE_VOIE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY
    fid_rue NUMBER(38,0) NOT NULL,
    fid_voie NUMBER(38,0) NOT NULL 
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_RELATION_RUE_VOIE IS 'Table pivot permettant d''associer chaque rue à sa/ses voies. Ancienne table TA_RUEVOIE';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_RUE_VOIE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_RUE_VOIE.fid_rue IS 'Clé étrangère vers la table TA_RUE permettant d''associer une rue à une ou plusieurs voies.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_RUE_VOIE.fid_voie IS 'Clé étrangère permettant d''associer une ou plusieurs voies à une rue.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_RELATION_RUE_VOIE 
ADD CONSTRAINT TA_RELATION_RUE_VOIE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_RELATION_RUE_VOIE
ADD CONSTRAINT TA_RELATION_RUE_VOIE_FID_RUE_FK 
FOREIGN KEY (fid_rue)
REFERENCES G_BASE_VOIE.ta_rue(objectid);

ALTER TABLE G_BASE_VOIE.TA_RELATION_RUE_VOIE
ADD CONSTRAINT TA_RELATION_RUE_VOIE_FID_VOIE_FK
FOREIGN KEY (fid_voie)
REFERENCES G_BASE_VOIE.ta_voie(objectid);

-- 5. Création des index sur les clés étrangères
CREATE INDEX TA_RELATION_RUE_VOIE_FID_RUE_IDX ON G_BASE_VOIE.TA_RELATION_RUE_VOIE(fid_rue)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_RELATION_RUE_VOIE_FID_VOIE_IDX ON G_BASE_VOIE.TA_RELATION_RUE_VOIE(fid_voie)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_RELATION_RUE_VOIE TO G_ADMIN_SIG;