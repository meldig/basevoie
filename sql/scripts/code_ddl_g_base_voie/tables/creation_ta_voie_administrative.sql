/*
Création de la table TA_VOIE_ADMINISTRATIVE rassemblant les informations de chaque voie et notamment leurs libellés et leur latéralité : une voie physique peut avoir deux noms différents (à gauche et à droite) si elle traverse deux communes différentes.
*/

-- 1. Création de la table TA_VOIE_ADMINISTRATIVE
CREATE TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_VOIE_ADMINISTRATIVE_OBJECTID.NEXTVAL,
    fid_genre_voie NUMBER(38,0),
    libelle_voie VARCHAR2(1000 BYTE),
    complement_nom_voie VARCHAR2(200),
    code_insee VARCHAR2(5),
    commentaire VARCHAR2(4000 BYTE),
    date_saisie DATE,
    date_modification DATE,
    fid_pnom_saisie NUMBER(38,0),
    fid_pnom_modification NUMBER(38,0),
    fid_type_voie NUMBER(38,0),
    fid_rivoli NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE IS 'Table rassemblant les informations de chaque voie et notamment leurs libellés et leur latéralité : une voie physique peut avoir deux noms différents (à gauche et à droite) si elle traverse deux communes différentes.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE.objectid IS 'Clé primaire auto-incrémentée de la table. Elle remplace l''ancien identifiant ccomvoie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE.fid_genre_voie IS 'Genre du nom de la voie (féminin, masculin, neutre, etc).';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE.libelle_voie IS 'Nom de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE.complement_nom_voie IS 'Complément de nom de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE.code_insee IS 'Code insee de la voie "administrative".';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE.commentaire IS 'Commentaire de chaque voie, à remplir si besoin, pour une précision ou pour les voies n''ayant pas encore de nom.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE.date_saisie IS 'Date de création du libellé de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE.date_modification IS 'Date de modification du libellé de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT indiquant le pnom de l''agent créateur du libellé de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT indiquant le pnom de l''agent éditeur du libellé de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE.fid_type_voie IS 'Clé étrangère vers la table TA_TYPE_VOIE permettant d''associer une voie à un type de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE.fid_rivoli IS 'Clé étrangère vers la table TA_RIVOLI permettant d''associer un code RIVOLI à chaque voie (cette fk est conservée uniquement dans le cadre de la production du jeu BAL).';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE 
ADD CONSTRAINT TA_VOIE_ADMINISTRATIVE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE
ADD CONSTRAINT TA_VOIE_ADMINISTRATIVE_FID_TYPE_VOIE_FK
FOREIGN KEY (fid_type_voie)
REFERENCES G_BASE_VOIE.TA_TYPE_VOIE(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE
ADD CONSTRAINT TA_VOIE_ADMINISTRATIVE_FID_PNOM_SAISIE_FK
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE
ADD CONSTRAINT TA_VOIE_ADMINISTRATIVE_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE
ADD CONSTRAINT TA_VOIE_ADMINISTRATIVE_FID_RIVOLI_FK 
FOREIGN KEY (fid_rivoli)
REFERENCES G_BASE_VOIE.TA_RIVOLI(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE
ADD CONSTRAINT TA_VOIE_ADMINISTRATIVE_FID_GENRE_VOIE_FK 
FOREIGN KEY (fid_genre_voie)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

-- 4. Création des index sur les clés étrangères et autres   
CREATE INDEX TA_VOIE_ADMINISTRATIVE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE(libelle_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_COMPLEMENT_NOM_VOIE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE(complement_nom_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_CODE_INSEE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE(code_insee)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_FID_TYPE_VOIE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE(fid_type_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_FID_RIVOLI_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE(fid_rivoli)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_FID_GENRE_VOIE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE(fid_genre_voie)
    TABLESPACE G_ADT_INDX;

-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

