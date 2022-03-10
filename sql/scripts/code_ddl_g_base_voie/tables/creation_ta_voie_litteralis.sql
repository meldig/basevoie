/*
La table TA_VOIE_LITTERALIS_4 regroupe tous les informations de chaque voie de la base voie.
*/
/*
DROP TABLE G_BASE_VOIE.TA_VOIE_LITTERALIS_4 CASCADE CONSTRAINTS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'G_BASE_VOIE.TA_VOIE_LITTERALIS_4';
*/
-- 1. Création de la table TA_VOIE_LITTERALIS_4
CREATE TABLE G_BASE_VOIE.TA_VOIE_LITTERALIS_4(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    libelle_voie VARCHAR2(200) NOT NULL,
    complement_nom_voie VARCHAR2(50),
    date_saisie DATE DEFAULT sysdate NOT NULL,
    date_modification DATE DEFAULT sysdate NOT NULL,
    fid_pnom_saisie NUMBER(38,0) NOT NULL,
    fid_pnom_modification NUMBER(38,0) NOT NULL,
    fid_typevoie NUMBER(38,0) NOT NULL,
    fid_genre_voie NUMBER(38,0) NOT NULL,
    fid_rivoli NUMBER(38,0) NULL,
    fid_metadonnee NUMBER(38,0) NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_VOIE_LITTERALIS_4 IS 'Table rassemblant toutes les informations pour chaque voie de la base. Ancienne table : VOIEVOI';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LITTERALIS_4.objectid IS 'Clé primaire auto-incrémentée de la table. Elle remplace l''ancien identifiant ccomvoie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LITTERALIS_4.libelle_voie IS 'Nom de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LITTERALIS_4.complement_nom_voie IS 'Complément du nom de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LITTERALIS_4.date_saisie IS 'Date de saisie de la voie (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LITTERALIS_4.date_modification IS 'Date de modification de la voie (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LITTERALIS_4.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé une voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LITTERALIS_4.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié une voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LITTERALIS_4.fid_typevoie IS 'Clé étangère vers la table TA_TYPE_VOIE permettant de catégoriser les voies de la base.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LITTERALIS_4.fid_genre_voie IS 'Clé étrangère vers la table TA_LIBELLE permettant de connaître le genre du nom de la voie : masculin, féminin, neutre et non-identifié.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LITTERALIS_4.fid_rivoli IS 'Clé étrangère vers la table TA_RIVOLI permettant d''associer un code RIVOLI à chaque voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LITTERALIS_4.fid_metadonnee IS 'Clé étrangère vers la table G_GEO.TA_METADONNEE permettant de connaître la source des voies (MEL ou IGN).';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_VOIE_LITTERALIS_4 
ADD CONSTRAINT TA_VOIE_LITTERALIS_4_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_VOIE_LITTERALIS_4
ADD CONSTRAINT TA_VOIE_LITTERALIS_4_FID_PNOM_SAISIE_FK
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_VOIE_LITTERALIS_4
ADD CONSTRAINT TA_VOIE_LITTERALIS_4_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_VOIE_LITTERALIS_4
ADD CONSTRAINT TA_VOIE_LITTERALIS_4_FID_TYPEVOIE_FK 
FOREIGN KEY (fid_typevoie)
REFERENCES G_BASE_VOIE.ta_type_voie(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE_LITTERALIS_4
ADD CONSTRAINT TA_VOIE_LITTERALIS_4_FID_GENRE_VOIE_FK
FOREIGN KEY (fid_genre_voie)
REFERENCES G_GEO.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE_LITTERALIS_4
ADD CONSTRAINT TA_VOIE_LITTERALIS_4_FID_RIVOLI_FK
FOREIGN KEY (fid_rivoli)
REFERENCES G_BASE_VOIE.ta_rivoli(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE_LITTERALIS_4
ADD CONSTRAINT TA_VOIE_LITTERALIS_4_FID_METADONNEE_FK
FOREIGN KEY (fid_metadonnee)
REFERENCES G_GEO.ta_metadonnee(objectid);

-- 5. Création des index sur les clés étrangères
CREATE INDEX TA_VOIE_LITTERALIS_4_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TA_VOIE_LITTERALIS_4(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_LITTERALIS_4_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TA_VOIE_LITTERALIS_4(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_LITTERALIS_4_FID_TYPEVOIE_IDX ON G_BASE_VOIE.TA_VOIE_LITTERALIS_4(fid_typevoie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_LITTERALIS_4_FID_GENRE_VOIE_IDX ON G_BASE_VOIE.TA_VOIE_LITTERALIS_4(fid_genre_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_LITTERALIS_4_FID_RIVOLI_IDX ON G_BASE_VOIE.TA_VOIE_LITTERALIS_4(fid_rivoli)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_LITTERALIS_4_FID_METADONNEE_IDX ON G_BASE_VOIE.TA_VOIE_LITTERALIS_4(fid_metadonnee)
    TABLESPACE G_ADT_INDX;
    
-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_LITTERALIS_4 TO G_ADMIN_SIG;

/

