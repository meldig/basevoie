/*
SEQ_TEMP_H_TRONCON_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TEMP_H_TRONCON du projet H de correction des relations tronçons/seuils
*/

CREATE SEQUENCE SEQ_TEMP_H_TRONCON_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
La table TEMP_H_AGENT - du projet H de correction des relations tronçons/seuils - liste les pnoms de tous les agents ayant travaillés et qui travaillent encore pour la base voie.
*/

-- 1. Création de la table TEMP_H_AGENT
CREATE TABLE G_BASE_VOIE.TEMP_H_AGENT(
    numero_agent NUMBER(38,0) NOT NULL,
    pnom VARCHAR2(50) NOT NULL,
    validite NUMBER(1) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_H_AGENT IS 'Table temporaire - du projet H de correction des relations tronçons/seuils - listant les pnoms de tous les agents ayant travaillés et qui travaillent encore pour la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_AGENT.numero_agent IS 'Numéro d''agent présent sur la carte de chaque agent.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_AGENT.pnom IS 'Pnom de l''agent, c''est-à-dire la concaténation de l''initiale de son prénom et de son nom entier.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_AGENT.validite IS 'Validité de l''agent, c''est-à-dire que ce champ permet de savoir si l''agent continue de travailler dans/pour la base voie ou non : 1 = oui ; 0 = non.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_H_AGENT 
ADD CONSTRAINT TEMP_H_AGENT_PK 
PRIMARY KEY("NUMERO_AGENT") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_H_AGENT TO G_ADMIN_SIG;

/

/*
La table TEMP_H_LIBELLE - du projet H de correction des relations tronçons/seuils - liste les types et états permettant de catégoriser les objets de la base voie.
*/

-- 1. Création de la table TEMP_H_LIBELLE
CREATE TABLE G_BASE_VOIE.TEMP_H_LIBELLE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    libelle_court VARCHAR2(100 BYTE),
    libelle_long VARCHAR2(4000 BYTE)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_H_LIBELLE IS 'Table - du projet H de correction des relations tronçons/seuils - listant les types et états permettant de catégoriser les objets de la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_LIBELLE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_LIBELLE.libelle_court IS 'Valeur courte pouvant être prise par un libellé de la nomenclature de la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_LIBELLE.libelle_long IS 'Valeur longue pouvant être prise par un libellé de la nomenclature de la base voie.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_H_LIBELLE 
ADD CONSTRAINT TEMP_H_LIBELLE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_H_LIBELLE_LIBELLE_COURT_IDX ON G_BASE_VOIE.TEMP_H_LIBELLE(libelle_court)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_H_LIBELLE TO G_ADMIN_SIG;

/

/*
La table TEMP_H_TYPE_VOIE - du projet H de correction des relations tronçons/seuils - regroupe tous les types de voies de la base voie tels que les avenues, boulevards, rues, senteir, etc.
*/

-- 1. Création de la table TEMP_H_TYPE_VOIE
CREATE TABLE G_BASE_VOIE.TEMP_H_TYPE_VOIE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    code_type_voie CHAR(4) NULL,
    libelle VARCHAR2(100) NULL   
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_H_TYPE_VOIE IS 'Table - du projet H de correction des relations tronçons/seuils - rassemblant tous les types de voies présents dans la base voie. Ancienne table : TYPEVOIE.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TYPE_VOIE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TYPE_VOIE.code_type_voie IS 'Code des types de voie présents dans la base voie. Ce champ remplace le champ CCODTVO.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TYPE_VOIE.libelle IS 'Libellé des types de voie. Exemple : Boulevard, avenue, reu, sentier, etc.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_H_TYPE_VOIE 
ADD CONSTRAINT TEMP_H_TYPE_VOIE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 5. Création des index
CREATE INDEX TEMP_H_TYPE_VOIE_CODE_TYPE_VOIE_IDX ON G_BASE_VOIE.TEMP_H_TYPE_VOIE(code_type_voie)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_H_TYPE_VOIE TO G_ADMIN_SIG;

/

/*
La table TEMP_H_VOIE_PHYSIQUE - du projet H de correction des relations tronçons/seuils - rassemblant les identifiant de toutes les voies PHYSIQUES.
En opposition aux voies administratives : une voie physique peut correspondre à deux voies administratives si elle appartient à deux communes différentes.
*/

-- 1. Création de la table TEMP_H_VOIE_PHYSIQUE
CREATE TABLE G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE IS 'Table - du projet H de correction des relations tronçons/seuils - rassemblant les identifiant de toutes les voies PHYSIQUES (en opposition aux voies administratives : une voie physique peut correspondre à deux voies administratives si elle appartient à deux communes différentes).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE.objectid IS 'Clé primaire auto-incrémentée de la table (ses identifiants ne reprennent PAS ceux de VOIEVOI).';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE 
ADD CONSTRAINT TEMP_H_VOIE_PHYSIQUE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE TO G_ADMIN_SIG;

/

/*
La table TEMP_H_VOIE_ADMINISTRATIVE - du projet H de correction des relations tronçons/seuils - rassemblant les informations de chaque voie et notamment leurs libellés et leur latéralité : une voie physique peut avoir deux noms différents (à gauche et à droite) si elle traverse deux communes différentes.
*/

-- 1. Création de la table TEMP_H_VOIE_ADMINISTRATIVE
CREATE TABLE G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    genre_voie VARCHAR2(50 BYTE),
    libelle_voie VARCHAR2(1000 BYTE),
    complement_nom_voie VARCHAR2(200),
    fid_lateralite NUMBER(38,0),
    code_insee VARCHAR2(5),
    hierarchisation VARCHAR2(50),
    commentaire VARCHAR2(4000 BYTE),
    date_saisie DATE,
    date_modification DATE,
    fid_pnom_saisie NUMBER(38,0),
    fid_pnom_modification NUMBER(38,0),
    fid_type_voie NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE IS 'Table - du projet H de correction des relations tronçons/seuils - rassemblant les informations de chaque voie et notamment leurs libellés et leur latéralité : une voie physique peut avoir deux noms différents (à gauche et à droite) si elle traverse deux communes différentes.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE.objectid IS 'Clé primaire auto-incrémentée de la table. Elle remplace l''ancien identifiant ccomvoie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE.genre_voie IS 'Genre du nom de la voie (féminin, masculin, neutre, etc).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE.libelle_voie IS 'Nom de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE.complement_nom_voie IS 'Complément de nom de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE.code_insee IS 'Code insee de la voie "administrative".';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE.hierarchisation IS 'Champ permettant de distinguer les voies principales des voies secondaires.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE.commentaire IS 'Commentaire de chaque voie, à remplir si besoin, pour une précision ou pour les voies n''ayant pas encore de nom.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE.date_saisie IS 'Date de création du libellé de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE.date_modification IS 'Date de modification du libellé de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE.fid_pnom_saisie IS 'Clé étrangère vers la table TEMP_H_AGENT indiquant le pnom de l''agent créateur du libellé de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE.fid_pnom_modification IS 'Clé étrangère vers la table TEMP_H_AGENT indiquant le pnom de l''agent éditeur du libellé de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE.fid_type_voie IS 'Clé étrangère vers la table TEMP_H_TYPE_VOIE permettant d''associer une voie à un type de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE.fid_lateralite IS 'Clé étrangère vers la table TA_LIBELLE permettant de récupérer la latéralité de la voie. En limite de commune le côté gauche de la voie physique peut appartenir à la commune A et le côté droit à la comune B, tandis qu''au sein de la commune la voie physique appartient à une et une seule commune et est donc affectée à une et une seule voie administrative. Cette distinction se fait grâce à ce champ.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE 
ADD CONSTRAINT TEMP_H_VOIE_ADMINISTRATIVE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE
ADD CONSTRAINT TEMP_H_VOIE_ADMINISTRATIVE_FID_LATERALITE_FK
FOREIGN KEY (fid_lateralite)
REFERENCES G_BASE_VOIE.TEMP_B_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE
ADD CONSTRAINT TEMP_H_VOIE_ADMINISTRATIVE_FID_TYPE_VOIE_FK
FOREIGN KEY (fid_type_voie)
REFERENCES G_BASE_VOIE.TEMP_H_TYPE_VOIE(objectid);

ALTER TABLE G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE
ADD CONSTRAINT TEMP_H_VOIE_ADMINISTRATIVE_FID_PNOM_SAISIE_FK
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TEMP_H_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE
ADD CONSTRAINT TEMP_H_VOIE_ADMINISTRATIVE_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TEMP_H_AGENT(numero_agent);

-- 4. Création des index sur les clés étrangères et autres   
CREATE INDEX TEMP_H_VOIE_ADMINISTRATIVE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE(libelle_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_VOIE_ADMINISTRATIVE_COMPLEMENT_NOM_VOIE_IDX ON G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE(complement_nom_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_VOIE_ADMINISTRATIVE_CODE_INSEE_IDX ON G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE(code_insee)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_VOIE_ADMINISTRATIVE_FID_LATERALITE_IDX ON G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE(fid_lateralite)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_VOIE_ADMINISTRATIVE_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_VOIE_ADMINISTRATIVE_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_VOIE_ADMINISTRATIVE_FID_TYPE_VOIE_IDX ON G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE(fid_type_voie)
    TABLESPACE G_ADT_INDX;

-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

/*
La table TEMP_H_TRONCON - du projet H de correction des relations tronçons/seuils - regroupe tous les tronçons de la base voie.
*/

-- 1. Création de la table TEMP_H_TRONCON
CREATE TABLE G_BASE_VOIE.TEMP_H_TRONCON(
    objectid NUMBER(38,0),
    geom SDO_GEOMETRY NULL,
    date_saisie DATE DEFAULT sysdate NULL,
    date_modification DATE DEFAULT sysdate NULL,
    fid_pnom_saisie NUMBER(38,0) NULL,
    fid_pnom_modification NUMBER(38,0) NULL,
    fid_etat NUMBER(38,0) NULL,
    fid_voie_physique NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_H_TRONCON IS 'Table - du projet H de correction des relations tronçons/seuils - contenant les tronçons de la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TRONCON.objectid IS 'Clé primaire de la table identifiant chaque tronçon. Cette pk est auto-incrémentée et remplace l''ancien identifiant cnumtrc.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TRONCON.geom IS 'Géométrie de type ligne simple de chaque tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TRONCON.date_saisie IS 'date de saisie du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TRONCON.date_modification IS 'Dernière date de modification du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TRONCON.fid_pnom_saisie IS 'Clé étrangère vers la table TEMP_H_AGENT permettant de récupérer le pnom de l''agent ayant créé un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TRONCON.fid_pnom_modification IS 'Clé étrangère vers la table TEMP_H_AGENT permettant de récupérer le pnom de l''agent ayant modifié un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TRONCON.fid_etat IS 'Etat d''avancement des corrections : en erreur, corrigé, correct.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_TRONCON.fid_voie_physique IS 'Clé étrangère permettant d''associer un ou plusieurs tronçons à une et une seule voie physique.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_H_TRONCON 
ADD CONSTRAINT TEMP_H_TRONCON_PK 
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
    'TEMP_H_TRONCON',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_H_TRONCON_SIDX
ON G_BASE_VOIE.TEMP_H_TRONCON(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_H_TRONCON
ADD CONSTRAINT TEMP_H_TRONCON_FID_PNOM_SAISIE_FK 
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TEMP_H_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_H_TRONCON
ADD CONSTRAINT TEMP_H_TRONCON_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TEMP_H_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_H_TRONCON
ADD CONSTRAINT TEMP_H_TRONCON_FID_ETAT_FK
FOREIGN KEY (fid_etat)
REFERENCES G_BASE_VOIE.TEMP_H_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TEMP_H_TRONCON
ADD CONSTRAINT TEMP_H_TRONCON_FID_VOIE_PHYSIQUE_FK
FOREIGN KEY (fid_voie_physique)
REFERENCES G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_H_TRONCON_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TEMP_H_TRONCON(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_TRONCON_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TEMP_H_TRONCON(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_TRONCON_FID_ETAT_IDX ON G_BASE_VOIE.TEMP_H_TRONCON(fid_etat)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_TRONCON_FID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.TEMP_H_TRONCON(fid_voie_physique)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_H_TRONCON TO G_ADMIN_SIG;

/

/*
La table TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE - du projet H de correction des relations tronçons/seuils - permet d''associer une ou plusieurs voies physiques à une ou plusieurs voies administratives.
*/

-- 1. Création de la table TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
CREATE TABLE G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    fid_voie_physique NUMBER(38,0) NOT NULL,
    fid_voie_administrative NUMBER(38,0) NOT NULL,
    new_id_voie_physique NUMBER(38,0) NULL,
	old_id_voie_physique NUMBER(38,0) NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE IS 'Table pivot - du projet H de correction des relations tronçons/seuils - permettant d''associer une ou plusieurs voies physiques à une ou plusieurs voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE.fid_voie_physique IS 'Clé étrangère vers la table TEMP_H_VOIE_PHYSIQUE permettant d''associer une ou plusieurs voies physiques à une ou plusieurs administratives.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE.fid_voie_administrative IS 'Clé étrangère vers la table TEMP_H_VOIE_ADMINISTRATIVE permettant d''associer une ou plusieurs voies administratives à une ou plusieurs voies physiques.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE.new_id_voie_physique IS 'Champ de transition qui comportera le nouvel id voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE.old_id_voie_physique IS 'Champ de transition qui comportera l''ancien id voie physique.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE 
ADD CONSTRAINT TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
ADD CONSTRAINT TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_FID_VOIE_PHYSIQUE_FK
FOREIGN KEY (fid_voie_physique)
REFERENCES G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE(objectid);

ALTER TABLE G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
ADD CONSTRAINT TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_FID_VOIE_ADMINISTRATIVE_FK
FOREIGN KEY (fid_voie_administrative)
REFERENCES G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE(objectid);

-- 5. Création des index sur les clés étrangères
CREATE INDEX TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_FID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE(fid_voie_physique)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_FID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE(fid_voie_administrative)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

/*
La table TEMP_H_SEUIL - du projet H de correction des relations tronçons/seuils - regroupe tous les seuils de la base voie.
*/

-- 1. Création de la table TEMP_H_SEUIL
CREATE TABLE G_BASE_VOIE.TEMP_H_SEUIL(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    geom SDO_GEOMETRY,
    cote_troncon CHAR(1),
    code_insee AS (TRIM(GET_CODE_INSEE_97_COMMUNES_CONTAIN_POINT('TEMP_H_SEUIL', geom))),
    date_saisie DATE DEFAULT sysdate NOT NULL,
    date_modification DATE DEFAULT sysdate NOT NULL,
    fid_pnom_saisie NUMBER(38,0) NOT NULL,
    fid_pnom_modification NUMBER(38,0) NOT NULL,
    fid_troncon NUMBER(38,0),
    temp_idseui NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_H_SEUIL IS 'Table - du projet H de correction des relations tronçons/seuils - contenant les seuils de la Base Voie. Plusieurs seuils peuvent se situer sur le même point géographique. Ancienne table : ILTASEU';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL.objectid IS 'Clé primaire auto-incrémentée de la table identifiant chaque seuil. Cette pk remplace l''ancien identifiant idseui.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL.geom IS 'Géométrie de type point de chaque seuil présent dans la table.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL.cote_troncon IS 'Côté du tronçon auquel est rattaché le seuil. G = gauche ; D = droite. En agglomération le sens des tronçons est déterminé par ses numéros de seuils. En d''autres termes il commence au niveau du seuil dont le numéro est égal à 1. Hors agglomération, le sens du tronçon dépend du sens de circulation pour les rues à sens unique. Pour les rues à double-sens chaque tronçon est doublé donc leur sens dépend aussi du sens de circulation;';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL.code_insee IS 'Code INSEE de chaque seuil calculé à partir du référentiel des communes G_REFERENTIEL.MEL_COMMUNE_LLH.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL.date_saisie IS 'date de saisie du seuil (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL.date_modification IS 'Dernière date de modification du seuil(par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL.fid_pnom_saisie IS 'Clé étrangère vers la table TEMP_H_AGENT permettant de récupérer le pnom de l''agent ayant créé un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL.fid_pnom_modification IS 'Clé étrangère vers la table TEMP_H_AGENT permettant de récupérer le pnom de l''agent ayant modifié un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL.fid_troncon IS 'Clé étrangère vers la table TEMP_H_TRONCON permettant d''associer un troncon à un ou plusieurs seuils.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_SEUIL.temp_idseui IS 'Champ temporaire servant à l''import des données. Ce champ sera supprimé une fois l''import terminé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_H_SEUIL 
ADD CONSTRAINT TEMP_H_SEUIL_PK 
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
    'TEMP_H_SEUIL',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_H_SEUIL_SIDX
ON G_BASE_VOIE.TEMP_H_SEUIL(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATEMP_H_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_H_SEUIL
ADD CONSTRAINT TEMP_H_SEUIL_FID_PNOM_SAISIE_FK
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TEMP_H_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_H_SEUIL
ADD CONSTRAINT TEMP_H_SEUIL_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TEMP_H_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_H_SEUIL
ADD CONSTRAINT TEMP_H_SEUIL_FID_TRONCON_FK
FOREIGN KEY (fid_troncon)
REFERENCES G_BASE_VOIE.TEMP_H_TRONCON(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_H_SEUIL_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TEMP_H_SEUIL(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_SEUIL_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TEMP_H_SEUIL(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_SEUIL_FID_TRONCON_IDX ON G_BASE_VOIE.TEMP_H_SEUIL(fid_troncon)
    TABLESPACE G_ADT_INDX;
    
-- Cet index dispose d'une fonction permettant d'accélérer la récupération du code INSEE de la commune d'appartenance du seuil. 
-- Il créé également un champ virtuel dans lequel on peut aller chercher ce code INSEE.
CREATE INDEX TEMP_H_SEUIL_CODE_INSEE_IDX
ON G_BASE_VOIE.TEMP_H_SEUIL(GET_CODE_INSEE_CONTAIN_POINT('TEMP_H_SEUIL', geom))
TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_H_SEUIL TO G_ADMIN_SIG;

/

/*
La table TEMP_H_INFOS_SEUIL - du projet H de correction des relations tronçons/seuils - regroupe le détail des seuils de la base voie.
*/

-- 1. Création de la table TEMP_H_INFOS_SEUIL
CREATE TABLE G_BASE_VOIE.TEMP_H_INFOS_SEUIL(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    numero_seuil NUMBER(5,0) NOT NULL,
    numero_parcelle CHAR(9) NOT NULL,
    complement_numero_seuil VARCHAR2(10),
    date_saisie DATE DEFAULT sysdate NOT NULL,
    date_modification DATE DEFAULT sysdate NOT NULL,
    fid_seuil NUMBER(38,0) NOT NULL,
    fid_pnom_saisie NUMBER(38,0),
    fid_pnom_modification NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_H_INFOS_SEUIL IS 'Table - du projet H de correction des relations tronçons/seuils - contenant le détail des seuils, c''est-à-dire les numéros de seuil, de parcelles et les compléments de numéro de seuil. Cela permet d''associer un ou plusieurs seuils à un et un seul point géométrique au besoin.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL.numero_seuil IS 'Numéro de seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL.numero_parcelle IS 'Numéro de parcelle issu du cadastre.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL.complement_numero_seuil IS 'Complément du numéro de seuil. Exemple : 1 bis';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL.date_saisie IS 'Date de saisie des informations du seuil (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL.date_modification IS 'Date de modification des informations du seuil (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL.fid_seuil IS 'Clé étrangère vers la table TEMP_H_SEUIL, permettant d''affecter une géométrie à un ou plusieurs seuils, dans le cas où plusieurs se superposent sur le même point.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL.fid_pnom_saisie IS 'Clé étrangère vers la table TEMP_H_AGENT permettant de récupérer le pnom de l''agent ayant créé les informations d''un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_INFOS_SEUIL.fid_pnom_modification IS 'Clé étrangère vers la table TEMP_H_AGENT permettant de récupérer le pnom de l''agent ayant modifié les informations d''un seuil.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_H_INFOS_SEUIL 
ADD CONSTRAINT TEMP_H_INFOS_SEUIL_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_H_INFOS_SEUIL
ADD CONSTRAINT TEMP_H_INFOS_SEUIL_FID_SEUIL_FK 
FOREIGN KEY (fid_seuil)
REFERENCES G_BASE_VOIE.TEMP_H_SEUIL(objectid);

ALTER TABLE G_BASE_VOIE.TEMP_H_INFOS_SEUIL
ADD CONSTRAINT TEMP_H_INFOS_SEUIL_FID_PNOM_SAISIE_FK 
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TEMP_H_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_H_INFOS_SEUIL
ADD CONSTRAINT TEMP_H_INFOS_SEUIL_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TEMP_H_AGENT(numero_agent);

-- 5. Création des index sur les clés étrangères et autres champs
CREATE INDEX TEMP_H_INFOS_SEUIL_FID_SEUIL_IDX ON G_BASE_VOIE.TEMP_H_INFOS_SEUIL(fid_seuil)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_INFOS_SEUIL_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TEMP_H_INFOS_SEUIL(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_INFOS_SEUIL_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TEMP_H_INFOS_SEUIL(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_INFOS_SEUIL_NUMERO_SEUIL_IDX ON G_BASE_VOIE.TEMP_H_INFOS_SEUIL(numero_seuil)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_H_INFOS_SEUIL TO G_ADMIN_SIG;

/


/*
Déclencheur - du projet H de correction des relations tronçons/seuils - permettant de récupérer dans la table TEMP_H_LIBELLE, les dates de création/modification des entités ainsi que le pnom de l'agent les ayant effectués.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUX_TEMP_H_TRONCON_DATE_PNOM
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TEMP_H_TRONCON
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_etat NUMBER(38,0);
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TEMP_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TEMP_H_AGENT WHERE pnom = username;

    -- Sélection du libellé caractérisant une nouvelle entité
    SELECT objectid INTO v_id_etat FROM G_BASE_VOIE.TEMP_H_LIBELLE WHERE UPPER(libelle_court) = UPPER('nouvelle entité');

    -- En cas d'insertion on insère la FK du pnom de l'agent, ayant créé le tronçon, présent dans TEMP_AGENT. 
    IF INSERTING THEN 
        :new.objectid := SEQ_TEMP_H_TRONCON_OBJECTID.NEXTVAL;
        :new.fid_pnom_saisie := v_id_agent;
        :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
        :new.fid_pnom_modification := v_id_agent;
        :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');    
        :new.fid_etat := v_id_etat;
    ELSE
        -- En cas de mise à jour on édite le champ date_modification avec la date du jour et le champ fid_pnom_modification avec la FK du pnom de l'agent, ayant modifié le tronçon, présent dans TEMP_AGENT.
        IF UPDATING THEN 
             :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
             :new.fid_pnom_modification := v_id_agent;
        END IF;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUX_TEMP_H_TRONCON_DATE_PNOM','bjacq@lillemetropole.fr');
END;


/

-- Désactivation des contraintes et des index des tables de correction des tronçons disposant d'erreurs de topologie.
-- Désactivation des contraintes
ALTER TABLE G_BASE_VOIE.TEMP_H_TRONCON DISABLE CONSTRAINT TEMP_H_TRONCON_FID_PNOM_SAISIE_FK;
ALTER TABLE G_BASE_VOIE.TEMP_H_TRONCON DISABLE CONSTRAINT TEMP_H_TRONCON_FID_PNOM_MODIFICATION_FK;
ALTER TABLE G_BASE_VOIE.TEMP_H_TRONCON DISABLE CONSTRAINT TEMP_H_TRONCON_FID_VOIE_PHYSIQUE_FK;
ALTER TABLE G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE DISABLE CONSTRAINT TEMP_H_VOIE_ADMINISTRATIVE_FID_TYPE_VOIE_FK;
ALTER TABLE G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE DISABLE CONSTRAINT TEMP_H_VOIE_ADMINISTRATIVE_FID_PNOM_SAISIE_FK;
ALTER TABLE G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE DISABLE CONSTRAINT TEMP_H_VOIE_ADMINISTRATIVE_FID_PNOM_MODIFICATION_FK;
ALTER TABLE G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE DISABLE CONSTRAINT TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_FID_VOIE_PHYSIQUE_FK;
ALTER TABLE G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE DISABLE CONSTRAINT TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_FID_VOIE_ADMINISTRATIVE_FK;
ALTER TABLE G_BASE_VOIE.TEMP_H_TRONCON DISABLE CONSTRAINT TEMP_H_TRONCON_FID_PNOM_SAISIE_FK;
ALTER TABLE G_BASE_VOIE.TEMP_H_TRONCON DISABLE CONSTRAINT TEMP_H_TRONCON_FID_PNOM_MODIFICATION_FK;
ALTER TABLE G_BASE_VOIE.TEMP_H_TRONCON DISABLE CONSTRAINT TEMP_H_TRONCON_FID_ETAT_FK;
ALTER TABLE G_BASE_VOIE.TEMP_H_INFOS_SEUIL DISABLE CONSTRAINT TEMP_H_INFOS_SEUIL_FID_SEUIL_FK
ALTER TABLE G_BASE_VOIE.TEMP_H_INFOS_SEUIL DISABLE CONSTRAINT TEMP_H_INFOS_SEUIL_FID_PNOM_SAISIE_FK
ALTER TABLE G_BASE_VOIE.TEMP_H_INFOS_SEUIL DISABLE CONSTRAINT TEMP_H_INFOS_SEUIL_FID_PNOM_MODIFICATION_FK
ALTER TABLE G_BASE_VOIE.TEMP_H_SEUIL DISABLE CONSTRAINT TEMP_H_SEUIL_FID_PNOM_SAISIE_FK;
ALTER TABLE G_BASE_VOIE.TEMP_H_SEUIL DISABLE CONSTRAINT TEMP_H_SEUIL_FID_PNOM_MODIFICATION_FK;
ALTER TABLE G_BASE_VOIE.TEMP_H_SEUIL DISABLE CONSTRAINT TEMP_H_SEUIL_FID_TRONCON_FK;

-- Suppression des index
DROP INDEX TEMP_H_TRONCON_FID_PNOM_SAISIE_IDX;
DROP INDEX TEMP_H_TRONCON_FID_PNOM_MODIFICATION_IDX;
DROP INDEX TEMP_H_TRONCON_FID_VOIE_PHYSIQUE_IDX;
DROP INDEX TEMP_H_VOIE_ADMINISTRATIVE_LIBELLE_VOIE_IDX;
DROP INDEX TEMP_H_VOIE_ADMINISTRATIVE_COMPLEMENT_NOM_VOIE_IDX;
DROP INDEX TEMP_H_VOIE_ADMINISTRATIVE_CODE_INSEE_IDX;
DROP INDEX TEMP_H_VOIE_ADMINISTRATIVE_FID_LATERALITE_IDX;
DROP INDEX TEMP_H_VOIE_ADMINISTRATIVE_FID_PNOM_SAISIE_IDX;
DROP INDEX TEMP_H_VOIE_ADMINISTRATIVE_FID_PNOM_MODIFICATION_IDX;
DROP INDEX TEMP_H_VOIE_ADMINISTRATIVE_FID_TYPE_VOIE_IDX;
DROP INDEX TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_FID_VOIE_ADMINISTRATIVE_IDX;
DROP INDEX TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_FID_VOIE_PHYSIQUE_IDX;
DROP INDEX TEMP_H_TRONCON_SIDX;
DROP INDEX TEMP_H_INFOS_SEUIL_FID_SEUIL_IDX;
DROP INDEX TEMP_H_INFOS_SEUIL_FID_PNOM_SAISIE_IDX;
DROP INDEX TEMP_H_INFOS_SEUIL_FID_PNOM_MODIFICATION_IDX;
DROP INDEX TEMP_H_INFOS_SEUIL_NUMERO_SEUIL_IDX;
DROP INDEX TEMP_H_SEUIL_FID_PNOM_SAISIE_IDX;
DROP INDEX TEMP_H_SEUIL_FID_PNOM_MODIFICATION_IDX;
DROP INDEX TEMP_H_SEUIL_FID_TRONCON_IDX;
DROP INDEX TEMP_H_SEUIL_SIDX;

-- Désactivation des triggers
ALTER TRIGGER B_IUX_TEMP_H_TRONCON_DATE_PNOM DISABLE;

/

