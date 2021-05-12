/*
La table TA_RELATION_TRONCON_VOIE regroupant tous les types et états permettant de catégoriser les objets de la base voie.
*/

-- 1. Création de la table TA_RELATION_TRONCON_VOIE
CREATE TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    fid_voie NUMBER(38,0) NOT NULL,
    fid_troncon NUMBER(38,0) NOT NULL,
    sens CHAR(1) NOT NULL,
    ordre_troncon NUMBER(2,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE IS 'Table pivot permettant d''associer les tronçons de la table TA_TRONCON à leur voie présente dans TA_VOIE.

Ancienne table : VOIECVT.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE.fid_voie IS 'Clé étrangère vers la table TA_VOIE permettant d''associer une voie à un ou plusieurs tronçons.
Ancien champ : CCOMVOI.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE.fid_troncon IS 'Clé étrangère vers la table TA_TRONCON permettant d''associer un ou plusieurs tronçons à une voie.
Ancien champ : CNUMTRC.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE.sens IS 'Code permettant de connaître le sens du tronçon. 
Ancien champ : CCODSTR
A préciser avec Marie-Hélène, car les valeurs ne sont pas compréhensibles sans documentation.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE.ordre_troncon IS 'Ordre dans lequel les tronçons se positionnent afin de contituer la voie.
1 est égal au début de la voie et 1 + n est égal au tronçon suivant.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE 
ADD CONSTRAINT TA_RELATION_TRONCON_VOIE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE
ADD CONSTRAINT TA_RELATION_TRONCON_VOIE_FID_VOIE_FK
FOREIGN KEY (fid_voie)
REFERENCES G_BASE_VOIE.ta_voie(objectid);

ALTER TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE
ADD CONSTRAINT TA_RELATION_TRONCON_VOIE_FID_TRONCON_FK
FOREIGN KEY (fid_troncon)
REFERENCES G_BASE_VOIE.ta_troncon(objectid);

-- 5. Création des index sur les clés étrangères
CREATE INDEX TA_RELATION_TRONCON_VOIE_FID_VOIE_IDX ON G_BASE_VOIE.TA_RELATION_TRONCON_VOIE(fid_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_RELATION_TRONCON_VOIE_FID_TRONCON_IDX ON G_BASE_VOIE.TA_RELATION_TRONCON_VOIE(fid_troncon)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_RELATION_TRONCON_VOIE TO G_ADMIN_SIG;