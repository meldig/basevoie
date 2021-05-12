/*
La table TA_VOIE regroupe tous les informations de chaque voie de la base voie.
*/

-- 1. Création de la table TA_VOIE
CREATE TABLE G_BASE_VOIE.TA_VOIE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    fid_typevoie NUMBER(38,0) NOT NULL,
    fid_fantoir NUMBER(38,0) NOT NULL,
    numero_voie NUMBER(7,0),
    cote_commune CHAR(6),
    complement_nom_voie VARCHAR2(50),
    libelle_voie VARCHAR2(50) NOT NULL,
    fid_genre_voie NUMBER(38,0) NOT NULL,
    date_saisie DATE NOT NULL,
    fid_pnom_saisie NUMBER(38,0) NOT NULL,
    date_modification DATE,
    fid_pnom_modification NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_VOIE IS 'Table rassemblant toutes les informations pour chaque voie de la base. Ancienne table : VOIEVOI';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.objectid IS 'Clé primaire auto-incrémentée de la table. Elle remplace l''ancien identifiant ccomvoie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.fid_typevoie IS 'Clé étangère vers la table TA_TYPE_VOIE permettant de catégoriser les voies de la base.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.fid_fantoir IS 'Clé étrangère vers la table TA_FANTOIR permettant d''associer un code fantoir à chaque voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.numero_voie IS 'numéro de voie (commence par code insee)';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.cote_commune IS 'Côté de la voie appartenant à la commune (gauche/droite) Remplace les champs ';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.complement_nom_voie IS 'Complément du nom de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.libelle_voie IS 'Nom de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.fid_genre_voie IS 'Clé étrangère vers la table TA_LIBELLE permettant de connaître le genre du nom de la voie : masculin, féminin, neutre et non-identifié.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.date_saisie IS 'Date de saisie de la voie (via un trigger).';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé une voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.date_modification IS 'Date de modification de la voie (via un trigger).';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié une voie.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_VOIE 
ADD CONSTRAINT TA_VOIE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_VOIE
ADD CONSTRAINT TA_VOIE_FID_TYPEVOIE_FK 
FOREIGN KEY (fid_typevoie)
REFERENCES G_BASE_VOIE.ta_type_voie(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE
ADD CONSTRAINT TA_VOIE_FID_FANTOIR_FK
FOREIGN KEY (fid_fantoir)
REFERENCES G_BASE_VOIE.ta_fantoir(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE
ADD CONSTRAINT TA_VOIE_FID_GENRE_VOIE_FK
FOREIGN KEY (fid_genre_voie)
REFERENCES G_BASE_VOIE.ta_libelle(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE
ADD CONSTRAINT TA_VOIE_FID_PNOM_SAISIE_FK
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.ta_agent(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE
ADD CONSTRAINT TA_VOIE_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.ta_agent(objectid);

-- 5. Création des index sur les clés étrangères
CREATE INDEX TA_VOIE_FID_TYPEVOIE_IDX ON G_BASE_VOIE.TA_VOIE(fid_typevoie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_FID_FANTOIR_IDX ON G_BASE_VOIE.TA_VOIE(fid_fantoir)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_FID_GENRE_VOIE_IDX ON G_BASE_VOIE.TA_VOIE(fid_genre_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TA_VOIE(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TA_VOIE(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_VOIE TO G_ADMIN_SIG;