/*
Table de sauvegarde des infos des seuils - du projet H de correction des relations tronçons/seuils - contenant le détail des seuils, c''est-à-dire les numéros de seuil, de parcelles et les compléments de numéro de seuil. Cela permet d''associer un ou plusieurs seuils à un et un seul point géométrique au besoin. Cette table est une sauvegarde de la table TEMP_H_INFOS_SEUIL avant la vérification des relations tronçons/seuils par les photo-interprètes.
*/
/*
DROP TABLE G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION CASCADE CONSTRAINTS;
*/
-- 1. Création de la table
CREATE TABLE G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION AS(
	SELECT
		objectid,
		numero_seuil,
		numero_parcelle,
		complement_numero_seuil,
		date_saisie,
		date_modification,
		fid_seuil,
		fid_voie_administrative,
		fid_pnom_saisie,
		fid_pnom_modification
	FROM
		G_BASE_VOIE.TEMP_H_INFOS_SEUIL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION IS 'Table - du projet H de correction des relations tronçons/seuils - contenant le détail des seuils, c''est-à-dire les numéros de seuil, de parcelles et les compléments de numéro de seuil. Cela permet d''associer un ou plusieurs seuils à un et un seul point géométrique au besoin. C''est dans cette table qu''est effectuée la vérification des relations tronçons/seuils par les photo-interprètes.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION.objectid IS 'Clé primaire de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION.numero_seuil IS 'Numéro de seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION.numero_parcelle IS 'Numéro de parcelle issu du cadastre.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION.complement_numero_seuil IS 'Complément du numéro de seuil. Exemple : 1 bis';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION.date_saisie IS 'Date de saisie des informations du seuil (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION.date_modification IS 'Date de modification des informations du seuil (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION.fid_seuil IS 'Clé étrangère vers la table TEMP_H_SEUIL, permettant d''affecter une géométrie à un ou plusieurs seuils, dans le cas où plusieurs se superposent sur le même point.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION.fid_voie_administrative IS 'Clé étrangère vers la table TEMP_H_VOIE_ADMINISTRATIVE permettant d''associer un seuil à une voie administrative qui, elle-même, détient l''information de sa latéralité par rapport à la voie physique, nous permettant de dire si le seuil se trouve à gauche ou à droite de la voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION.fid_pnom_saisie IS 'Clé étrangère vers la table TEMP_H_AGENT permettant de récupérer le pnom de l''agent ayant créé les informations d''un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION.fid_pnom_modification IS 'Clé étrangère vers la table TEMP_H_AGENT permettant de récupérer le pnom de l''agent ayant modifié les informations d''un seuil.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION 
ADD CONSTRAINT TEMP_H_INFOS_SEUIL_VERIFICATION_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION
ADD CONSTRAINT TEMP_H_INFOS_SEUIL_VERIFICATION_FID_SEUIL_FK 
FOREIGN KEY (fid_seuil)
REFERENCES G_BASE_VOIE.TEMP_H_SEUIL(objectid);

ALTER TABLE G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION
ADD CONSTRAINT TEMP_H_INFOS_SEUIL_VERIFICATION_FID_VOIE_ADMINISTRATIVE_FK
FOREIGN KEY (fid_voie_administrative)
REFERENCES G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE(objectid);

ALTER TABLE G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION
ADD CONSTRAINT TEMP_H_INFOS_SEUIL_VERIFICATION_FID_PNOM_SAISIE_FK 
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TEMP_H_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION
ADD CONSTRAINT TEMP_H_INFOS_SEUIL_VERIFICATION_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TEMP_H_AGENT(numero_agent);

-- 5. Création des index sur les clés étrangères et autres champs
CREATE INDEX TEMP_H_INFOS_SEUIL_VERIFICATION_FID_SEUIL_IDX ON G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION(fid_seuil)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_INFOS_SEUIL_VERIFICATION_FID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION(fid_voie_administrative)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_INFOS_SEUIL_VERIFICATION_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_INFOS_SEUIL_VERIFICATION_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_INFOS_SEUIL_VERIFICATION_NUMERO_SEUIL_IDX ON G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION(numero_seuil)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_H_INFOS_SEUIL_VERIFICATION TO G_ADMIN_SIG;

/

