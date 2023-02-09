/*
Table - du projet H de correction des relations tronçons/seuils - permettant aux photo-interprètes de vérifier/corriger les relations seuils/tronçons pour tous les tronçons ayant été modifié durant l'étape de correction topologique des tronçons.
*/
/*
DROP TABLE G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION CASCADE CONSTRAINTS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION';
COMMIT;
*/
-- 1. Création de la table
CREATE TABLE G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION AS(
	SELECT
		objectid,
	    geom,
	    code_insee,
	    fid_troncon
	FROM
		G_BASE_VOIE.TEMP_H_SEUIL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION IS 'Table - du projet H de correction des relations tronçons/seuils - contenant les seuils de la Base Voie. Cette table contient le code INSEE en dur et non dans un champ calculé, ce qui améliore les performances. C''est dans cette table qu''est effectuée la vérification des relations tronçons/seuils par les photo-interprètes.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION.objectid IS 'Clé primaire de la table identifiant chaque seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION.geom IS 'Géométrie de type point de chaque seuil présent dans la table.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION.code_insee IS 'Code INSEE de chaque seuil calculé à partir du référentiel des communes G_REFERENTIEL.MEL_COMMUNE_LLH.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION.fid_troncon IS 'Clé étrangère vers la table TEMP_H_TRONCON permettant d''associer un troncon à un ou plusieurs seuils.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION 
ADD CONSTRAINT TEMP_H_SEUIL_VERIFICATION_PK 
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
    'TEMP_H_SEUIL_VERIFICATION',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_H_SEUIL_VERIFICATION_SIDX
ON G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATEMP_H_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION
ADD CONSTRAINT TEMP_H_SEUIL_VERIFICATION_FID_TRONCON_FK
FOREIGN KEY (fid_troncon)
REFERENCES G_BASE_VOIE.TEMP_H_TRONCON(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_H_SEUIL_VERIFICATION_FID_TRONCON_IDX ON G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION(fid_troncon)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_SEUIL_VERIFICATION_CODE_INSEE_IDX ON G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION(code_insee)
    TABLESPACE G_ADT_INDX;

-- 8. Ajout des champs complémentaires
ALTER TABLE G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION
ADD fid_etat_verification NUMBER(38,0);

ALTER TABLE G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION
ADD fid_agent_verification NUMBER(38,0);

ALTER TABLE G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION
ADD doute NUMBER(1,0) DEFAULT 0;
    
ALTER TABLE G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION
ADD commentaire VARCHAR2(4000 BYTE);

ALTER TABLE G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION
ADD voie_sans_nom NUMBER(1,0) DEFAULT 0;

-- 9. Création des compentaires des champs complémentaires
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION.fid_etat_verification IS 'Clé étrangère vers la table TEMP_H_LIBELLE permettant de savoir si le seuil a été vérifié ou non (vérification seuil/tronçon).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION.fid_agent_verification IS 'Clé étrangère vers la table TEMP_H_AGENT permettant de diviser les seuils à vérifier entre photo-interprètes.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION.doute IS 'Champ permettant d''indiquer au photo-interprète s''il y a une question, une doute sur un seuil (valeur 0 : aucun doute ; valeur 0 : doute).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION.commentaire IS 'Champ permettant au photo-interprète d''indiquer son doute ou sa question sur le seuil, justifiant le changement de la valeur du champ doute.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION.voie_sans_nom IS 'Champ numérique booléen permettant d''indiquer si un seuil est affecté à une voie sans nom (seul le type de voie est présent dans son nom). 0 : voie avec nom ; 1 : voie sans nom';

-- 10 Création des contraintes sur les champs complémentaires
ALTER TABLE G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION
ADD CONSTRAINT TEMP_H_SEUIL_VERIFICATION_FID_ETAT_VERIFICATION_FK 
FOREIGN KEY (fid_etat_verification)
REFERENCES G_BASE_VOIE.TEMP_H_LIBELLE (objectid);

ALTER TABLE G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION
ADD CONSTRAINT TEMP_H_SEUIL_VERIFICATION_FID_AGENT_VERIFICATION_FK 
FOREIGN KEY (fid_agent_verification)
REFERENCES G_BASE_VOIE.TEMP_H_AGENT (numero_agent);

-- 11. Création des index relatifs aux champs complémentaires
CREATE INDEX TEMP_H_SEUIL_VERIFICATION_DOUTE_IDX ON G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION(doute)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_SEUIL_VERIFICATION_COMMENTAIRE_IDX ON G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION(commentaire)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX TEMP_H_SEUIL_VERIFICATION_AVANCEE_VERIFICATION_IDX ON G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION(fid_etat_verification, doute)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX TEMP_H_SEUIL_VERIFICATION_AVANCEE_VERIFICATION_AGENT_IDX ON G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION(fid_etat_verification, doute, fid_agent_verification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_SEUIL_VERIFICATION_VOIE_SANS_NOM_IDX ON G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION(voie_sans_nom)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION TO G_ADMIN_SIG;

/

