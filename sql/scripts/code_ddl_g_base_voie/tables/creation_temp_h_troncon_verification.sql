/*
La table TEMP_H_INFOS_SEUIL_SAUVEGARDE - du projet H de correction des relations tronçons/seuils - regroupe le détail des seuils de la base voie.
*/
/*
DROP TABLE G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION CASCADE CONSTRAINTS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION';
COMMIT;
*/
CREATE TABLE G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION AS(
	SELECT
		objectid,
		geom,
		date_saisie,
		date_modification,
		fid_pnom_saisie,
		fid_pnom_modification,
		fid_etat,
		fid_voie_physique,
		old_objectid
	FROM
		G_BASE_VOIE.TEMP_H_TRONCON
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION IS 'Table - du projet H de correction des relations tronçons/seuils - contenant les tronçons de la base voie. C''est dans cette table qu''est effectuée la vérification des relations tronçons/seuils par les photo-interprètes.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION.objectid IS 'Clé primaire de la table identifiant chaque tronçon. Cette pk est auto-incrémentée et remplace l''ancien identifiant cnumtrc.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION.geom IS 'Géométrie de type ligne simple de chaque tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION.date_saisie IS 'date de saisie du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION.date_modification IS 'Dernière date de modification du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION.fid_pnom_saisie IS 'Clé étrangère vers la table TEMP_H_AGENT permettant de récupérer le pnom de l''agent ayant créé un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION.fid_pnom_modification IS 'Clé étrangère vers la table TEMP_H_AGENT permettant de récupérer le pnom de l''agent ayant modifié un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION.fid_etat IS 'Etat d''avancement des corrections : en erreur, corrigé, correct.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION.fid_voie_physique IS 'Clé étrangère permettant d''associer un ou plusieurs tronçons à une et une seule voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION.old_objectid IS 'Ancien identifiant correspondant au tronçon avant la correction topologique.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION 
ADD CONSTRAINT TEMP_H_TRONCON_VERIFICATION_PK 
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
    'TEMP_H_TRONCON_VERIFICATION',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_H_TRONCON_VERIFICATION_SIDX
ON G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION
ADD CONSTRAINT TEMP_H_TRONCON_VERIFICATION_FID_PNOM_SAISIE_FK 
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TEMP_H_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION
ADD CONSTRAINT TEMP_H_TRONCON_VERIFICATION_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TEMP_H_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION
ADD CONSTRAINT TEMP_H_TRONCON_VERIFICATION_FID_ETAT_FK
FOREIGN KEY (fid_etat)
REFERENCES G_BASE_VOIE.TEMP_H_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION
ADD CONSTRAINT TEMP_H_TRONCON_VERIFICATION_FID_VOIE_PHYSIQUE_FK
FOREIGN KEY (fid_voie_physique)
REFERENCES G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_H_TRONCON_VERIFICATION_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_TRONCON_VERIFICATION_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_TRONCON_VERIFICATION_FID_ETAT_IDX ON G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION(fid_etat)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_TRONCON_VERIFICATION_FID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION(fid_voie_physique)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_TRONCON_VERIFICATION_OLD_OBJECTID_IDX ON G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION(old_objectid)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION TO G_ADMIN_SIG;

/

