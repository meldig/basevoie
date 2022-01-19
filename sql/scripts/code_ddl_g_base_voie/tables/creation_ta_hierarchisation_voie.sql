/*
La table TA_HIERARCHISATION_VOIE permet de hiérarchiser les voies en associant les voies secondaires à leur voie principale.
*/

-- 1. Création de la table TA_HIERARCHISATION_VOIE
CREATE TABLE G_BASE_VOIE.TA_HIERARCHISATION_VOIE(
    fid_voie_principale NOT NULL,
    fid_voie_secondaire NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_HIERARCHISATION_VOIE IS 'Table permettant de hiérarchiser les voies en associant les voies secondaires à leur voie principale.';
COMMENT ON COLUMN G_BASE_VOIE.TA_HIERARCHISATION_VOIE.fid_voie_principale IS 'Clé primaire (partie 1) de la table et clé étrangère vers TA_VOIE permettant d''associer une voie principale à une voie secondaire';
COMMENT ON COLUMN G_BASE_VOIE.TA_HIERARCHISATION_VOIE.fid_voie_secondaire IS 'Clé primaire (partie 2) et clé étrangère vers TA_VOIE permettant d''associer une voie secondaire à une voie principale.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_HIERARCHISATION_VOIE 
ADD CONSTRAINT TA_HIERARCHISATION_VOIE_PK 
PRIMARY KEY("fid_voie_principale", "fid_voie_secondaire") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_HIERARCHISATION_VOIE
ADD CONSTRAINT TA_HIERARCHISATION_VOIE_FID_VOIE_PRINCIPALE_FK 
FOREIGN KEY (fid_voie_principale)
REFERENCES G_BASE_VOIE.ta_voie(objectid);

ALTER TABLE G_BASE_VOIE.TA_HIERARCHISATION_VOIE
ADD CONSTRAINT TA_HIERARCHISATION_VOIE_FID_VOIE_SECONDAIRE_FK 
FOREIGN KEY (fid_voie_secondaire)
REFERENCES G_BASE_VOIE.ta_voie(objectid);

-- 5. Création des index sur les clés étrangères et autres champs
CREATE INDEX TA_HIERARCHISATION_VOIE_FID_VOIE_PRINCIPALE_IDX ON G_BASE_VOIE.TA_HIERARCHISATION_VOIE(fid_voie_principale)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_HIERARCHISATION_VOIE_FID_VOIE_SECONDAIRE_IDX ON G_BASE_VOIE.TA_HIERARCHISATION_VOIE(fid_voie_secondaire)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_HIERARCHISATION_VOIE TO G_ADMIN_SIG;

/

