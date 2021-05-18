/*
La table TA_RELATION_TRONCON_SEUIL fait la relation entre les tronçons de la table TA_TRONCON et les seuils de la table TA_SEUIl qui s''y rattachent dans la base voie.
*/

-- 1. Création de la table TA_RELATION_TRONCON_SEUIL
CREATE TABLE G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL(
    fid_troncon NUMBER(38,0) NOT NULL,
    fid_seuil NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL IS 'Table pivot faisant la relation entre les tronçons de la table TA_TRONCON et les seuils de la table TA_SEUIl qui s''y rattachent. Ancienne table : ILTASIT.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL.fid_troncon IS 'Clé primaire et étrangère vers la table TA_TRONCON permettant d''asocier un tronçons aux seuils.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL.fid_seuil IS 'Clé primaire et clé étrangère vers la table TA_SEUIL permettant d''associer un ou plusieurs seuils à un tronçon.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL 
ADD CONSTRAINT TA_RELATION_TRONCON_SEUIL_PK 
PRIMARY KEY("FID_TRONCON", "FID_SEUIL") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL
ADD CONSTRAINT TA_RELATION_TRONCON_SEUIL_FID_TRONCON_FK 
FOREIGN KEY (fid_troncon)
REFERENCES G_BASE_VOIE.TA_TRONCON(objectid);

ALTER TABLE G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL
ADD CONSTRAINT TA_RELATION_TRONCON_SEUIL_FID_SEUIL_FK
FOREIGN KEY (fid_seuil)
REFERENCES G_BASE_VOIE.TA_SEUIL(objectid);

-- 5. Création des index sur les clés étrangères
CREATE INDEX TA_RELATION_TRONCON_SEUIL_FID_TRONCON_IDX ON G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL(fid_troncon)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_RELATION_TRONCON_SEUIL_FID_SEUIL_IDX ON G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL(fid_seuil)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL TO G_ADMIN_SIG;