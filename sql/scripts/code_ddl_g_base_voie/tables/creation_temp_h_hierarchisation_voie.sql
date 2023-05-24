/*
La table TEMP_H_HIERARCHISATION_VOIE - du projet H de correction des relations tronçons/seuils - permet de hiérarchiser les voies en associant les voies secondaires à leur voie principale.
*/

-- 1. Création de la table TEMP_H_HIERARCHISATION_VOIE
CREATE TABLE G_BASE_VOIE.TEMP_H_HIERARCHISATION_VOIE(
    fid_voie_principale NUMBER(38,0) NOT NULL,
    fid_voie_secondaire NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_H_HIERARCHISATION_VOIE IS 'Table permettant de hiérarchiser les voies en associant les voies secondaires à leur voie principale.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_HIERARCHISATION_VOIE.fid_voie_principale IS 'Clé primaire (partie 1) de la table et clé étrangère vers TEMP_H_VOIE_ADMINISTRATIVE permettant d''associer une voie principale à une voie secondaire';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_HIERARCHISATION_VOIE.fid_voie_secondaire IS 'Clé primaire (partie 2) et clé étrangère vers TEMP_H_VOIE_ADMINISTRATIVE permettant d''associer une voie secondaire à une voie principale.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_H_HIERARCHISATION_VOIE 
ADD CONSTRAINT TEMP_H_HIERARCHISATION_VOIE_PK 
PRIMARY KEY("FID_VOIE_PRINCIPALE", "FID_VOIE_SECONDAIRE") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_H_HIERARCHISATION_VOIE
ADD CONSTRAINT TEMP_H_HIERARCHISATION_VOIE_FID_VOIE_PRINCIPALE_FK 
FOREIGN KEY (fid_voie_principale)
REFERENCES G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE(objectid);

ALTER TABLE G_BASE_VOIE.TEMP_H_HIERARCHISATION_VOIE
ADD CONSTRAINT TEMP_H_HIERARCHISATION_VOIE_FID_VOIE_SECONDAIRE_FK 
FOREIGN KEY (fid_voie_secondaire)
REFERENCES G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE(objectid);

-- 5. Création des index sur les clés étrangères et autres champs
CREATE INDEX TEMP_H_HIERARCHISATION_VOIE_FID_VOIE_PRINCIPALE_IDX ON G_BASE_VOIE.TEMP_H_HIERARCHISATION_VOIE(fid_voie_principale)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_HIERARCHISATION_VOIE_FID_VOIE_SECONDAIRE_IDX ON G_BASE_VOIE.TEMP_H_HIERARCHISATION_VOIE(fid_voie_secondaire)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_H_HIERARCHISATION_VOIE TO G_ADMIN_SIG;

/
