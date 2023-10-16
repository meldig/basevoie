/*
SEQ_TA_TRONCON_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_TRONCON
*/

CREATE SEQUENCE SEQ_TA_TRONCON_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_TRONCON_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_VOIE_PHYSIQUE du projet j
*/

CREATE SEQUENCE SEQ_TA_VOIE_PHYSIQUE_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_VOIE_SUPRA_COMMUNALE_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_VOIE_SUPRA_COMMUNALE
*/

CREATE SEQUENCE SEQ_TA_VOIE_SUPRA_COMMUNALE_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_MISE_A_JOUR_A_FAIRE_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_MISE_A_JOUR_A_FAIRE
*/

CREATE SEQUENCE SEQ_TA_MISE_A_JOUR_A_FAIRE_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_VOIE_ADMINISTRATIVE_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_VOIE_ADMINISTRATIVE
*/

CREATE SEQUENCE SEQ_TA_VOIE_ADMINISTRATIVE_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_TRONCON_LOG_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_TRONCON_LOG
*/

CREATE SEQUENCE SEQ_TA_TRONCON_LOG_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_SEUIL_LOG_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_SEUIL_LOG
*/

CREATE SEQUENCE SEQ_TA_SEUIL_LOG_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_INFOS_SEUIL_LOG_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_INFOS_SEUIL_LOG
*/

CREATE SEQUENCE SEQ_TA_INFOS_SEUIL_LOG_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG
*/

CREATE SEQUENCE SEQ_TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
*/

CREATE SEQUENCE SEQ_TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_VOIE_ADMINISTRATIVE_LOG_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_VOIE_ADMINISTRATIVE_LOG
*/

CREATE SEQUENCE SEQ_TA_VOIE_ADMINISTRATIVE_LOG_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_VOIE_PHYSIQUE_LOG_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_VOIE_PHYSIQUE_LOG
*/

CREATE SEQUENCE SEQ_TA_VOIE_PHYSIQUE_LOG_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_INFOS_SEUIL_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_INFOS_SEUIL
*/

CREATE SEQUENCE SEQ_TA_INFOS_SEUIL_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_SEUIL_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_SEUIL
*/

CREATE SEQUENCE SEQ_TA_SEUIL_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_VOIE_SUPRA_COMMUNALE_LOG_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_VOIE_SUPRA_COMMUNALE_LOG
*/

CREATE SEQUENCE SEQ_TA_VOIE_SUPRA_COMMUNALE_LOG_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_RIVOLI_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_RIVOLI
*/

CREATE SEQUENCE SEQ_TA_RIVOLI_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_TYPE_VOIE_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_TYPE_VOIE
*/

CREATE SEQUENCE SEQ_TA_TYPE_VOIE_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_LIBELLE_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_LIBELLE
*/

CREATE SEQUENCE SEQ_TA_LIBELLE_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
SEQ_TA_SECTEUR_VOIRIE_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_SECTEUR_VOIRIE
*/

CREATE SEQUENCE SEQ_TA_SECTEUR_VOIRIE_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
Création de la table TA_AGENT listant les pnoms de tous les agents ayant travaillés et qui travaillent encore pour la base voie.
*/

-- 1. Création de la table TA_AGENT
CREATE TABLE G_BASE_VOIE.TA_AGENT(
    numero_agent NUMBER(38,0) NOT NULL,
    pnom VARCHAR2(50) NOT NULL,
    validite NUMBER(1) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_AGENT IS 'Table listant les pnoms de tous les agents ayant travaillés et qui travaillent encore pour la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_AGENT.numero_agent IS 'Numéro d''agent présent sur la carte de chaque agent.';
COMMENT ON COLUMN G_BASE_VOIE.TA_AGENT.pnom IS 'Pnom de l''agent, c''est-à-dire la concaténation de l''initiale de son prénom et de son nom entier.';
COMMENT ON COLUMN G_BASE_VOIE.TA_AGENT.validite IS 'Validité de l''agent, c''est-à-dire que ce champ permet de savoir si l''agent continue de travailler dans/pour la base voie ou non : 1 = oui ; 0 = non.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_AGENT 
ADD CONSTRAINT TA_AGENT_PK 
PRIMARY KEY("NUMERO_AGENT") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_AGENT TO G_ADMIN_SIG;

/

/*
Création de la table TA_LIBELLE listant les types et états permettant de catégoriser les objets de la base voie.
*/

-- 1. Création de la table TA_LIBELLE
CREATE TABLE G_BASE_VOIE.TA_LIBELLE(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_LIBELLE_OBJECTID.NEXTVAL,
    libelle_court VARCHAR2(100 BYTE),
    libelle_long VARCHAR2(4000 BYTE)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_LIBELLE IS 'Table listant les types et états permettant de catégoriser les objets de la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_LIBELLE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_LIBELLE.libelle_court IS 'Valeur courte pouvant être prise par un libellé de la nomenclature de la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_LIBELLE.libelle_long IS 'Valeur longue pouvant être prise par un libellé de la nomenclature de la base voie.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_LIBELLE 
ADD CONSTRAINT TA_LIBELLE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TA_LIBELLE_LIBELLE_COURT_IDX ON G_BASE_VOIE.TA_LIBELLE(libelle_court)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_LIBELLE TO G_ADMIN_SIG;

/

/*
Création de la table TA_TYPE_VOIE regroupant tous les types de voies de la base voie tels que les avenues, boulevards, rues, senteir, etc.
*/

-- 1. Création de la table TA_TYPE_VOIE
CREATE TABLE G_BASE_VOIE.TA_TYPE_VOIE(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_TYPE_VOIE_OBJECTID.NEXTVAL,
    code_type_voie VARCHAR2(4) NULL,
    libelle VARCHAR2(100) NULL   
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_TYPE_VOIE IS 'Table rassemblant tous les types de voies présents dans la base voie. Ancienne table : TYPEVOIE.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TYPE_VOIE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TYPE_VOIE.code_type_voie IS 'Code des types de voie présents dans la base voie (les types de voie de la BdTopo y sont présents).';
COMMENT ON COLUMN G_BASE_VOIE.TA_TYPE_VOIE.libelle IS 'Libellé des types de voie. Exemple : Boulevard, avenue, reu, sentier, etc.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_TYPE_VOIE 
ADD CONSTRAINT TA_TYPE_VOIE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des contraintes
ALTER TABLE G_BASE_VOIE.TA_TYPE_VOIE
ADD CONSTRAINT TA_TYPE_VOIE_LIBELLE_UNIQ UNIQUE("LIBELLE")
USING INDEX TABLESPACE "G_ADT_INDX";

-- 5. Création des index
CREATE INDEX TA_TYPE_VOIE_CODE_TYPE_VOIE_IDX ON G_BASE_VOIE.TA_TYPE_VOIE(code_type_voie)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_TYPE_VOIE TO G_ADMIN_SIG;

/

/*
Création de la table TA_RIVOLI regroupant tous les codes RIVOLI des voies de la base voie.
*/

-- 1. Création de la table TA_RIVOLI
CREATE TABLE G_BASE_VOIE.TA_RIVOLI(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_RIVOLI_OBJECTID.NEXTVAL,
    code_rivoli CHAR(4) NOT NULL,
    cle_controle CHAR(1)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_RIVOLI IS 'Table rassemblant tous les codes fantoirs issus du fichier fantoir et correspondants aux voies présentes sur le territoire de la MEL.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RIVOLI.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RIVOLI.code_rivoli IS 'Code RIVOLI du code fantoir. Ce code est l''identifiant sur 4 caractères de la voie au sein de la commune. Attention : il ne faut pas confondre ce code avec le code de l''ancien fichier RIVOLI, devenu depuis fichier fantoir. Le code RIVOLI fait partie du code fantoir. Attention cet identifiant est recyclé dans le fichier fantoir, ce champ ne doit donc jamais être utilisé en tant que clé primaire ou étrangère.' ;
COMMENT ON COLUMN G_BASE_VOIE.TA_RIVOLI.cle_controle IS 'Clé de contrôle du code fantoir issue du fichier fantoir.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_RIVOLI 
ADD CONSTRAINT TA_RIVOLI_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des index
CREATE INDEX TA_RIVOLI_CODE_RIVOLI_IDX ON G_BASE_VOIE.TA_RIVOLI(code_rivoli)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_RIVOLI_CLE_CONTROLE_IDX ON G_BASE_VOIE.TA_RIVOLI(cle_controle)
    TABLESPACE G_ADT_INDX;

-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_RIVOLI TO G_ADMIN_SIG;

/

/*
Création de la table TA_VOIE_PHYSIQUE rassemblant les identifiant de toutes les voies PHYSIQUES.
En opposition aux voies administratives : une voie physique peut correspondre à deux voies administratives si elle appartient à deux communes différentes.
*/

-- 1. Création de la table TA_VOIE_PHYSIQUE
CREATE TABLE G_BASE_VOIE.TA_VOIE_PHYSIQUE(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_VOIE_PHYSIQUE_OBJECTID.NEXTVAL,
    fid_action NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_VOIE_PHYSIQUE IS 'Table rassemblant les identifiant de toutes les voies PHYSIQUES (en opposition aux voies administratives : une voie physique peut correspondre à deux voies administratives si elle appartient à deux communes différentes).';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_PHYSIQUE.objectid IS 'Clé primaire auto-incrémentée de la table (ses identifiants ne reprennent PAS ceux de VOIEVOI).';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_PHYSIQUE.fid_action IS 'Champ permettant de savoir s''il faut inverser le sens géométrique de la voie physique ou non.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_VOIE_PHYSIQUE 
ADD CONSTRAINT TA_VOIE_PHYSIQUE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des index
CREATE INDEX TA_VOIE_PHYSIQUE_FID_ACTION_IDX ON G_BASE_VOIE.TA_VOIE_PHYSIQUE(fid_action)
    TABLESPACE G_ADT_INDX;

-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_PHYSIQUE TO G_ADMIN_SIG;

/



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

/*
La table TA_TRONCON regroupe tous les tronçons de la base voie.
*/

-- 1. Création de la table TA_TRONCON
CREATE TABLE G_BASE_VOIE.TA_TRONCON(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_TRONCON_OBJECTID.NEXTVAL,
    geom SDO_GEOMETRY NULL,
    old_objectid NUMBER(38,0),
    date_saisie DATE NULL,
    date_modification DATE DEFAULT sysdate NULL,
    fid_pnom_saisie NUMBER(38,0) NULL,
    fid_pnom_modification NUMBER(38,0) NULL,
    fid_voie_physique NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_TRONCON IS 'Table contenant les tronçons de la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.objectid IS 'Clé primaire de la table identifiant chaque tronçon. Cette pk est auto-incrémentée et remplace l''ancien identifiant cnumtrc.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.geom IS 'Géométrie de type ligne simple de chaque tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.old_objectid IS 'Ancien identifiant correspondant au tronçon avant la correction topologique.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.date_saisie IS 'date de saisie du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.date_modification IS 'Dernière date de modification du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.fid_voie_physique IS 'Clé étrangère permettant d''associer un ou plusieurs tronçons à une et une seule voie physique.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_TRONCON 
ADD CONSTRAINT TA_TRONCON_PK 
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
    'TA_TRONCON',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TA_TRONCON_SIDX
ON G_BASE_VOIE.TA_TRONCON(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_TRONCON
ADD CONSTRAINT TA_TRONCON_FID_PNOM_SAISIE_FK 
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_TRONCON
ADD CONSTRAINT TA_TRONCON_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_TRONCON
ADD CONSTRAINT TA_TRONCON_FID_VOIE_PHYSIQUE_FK
FOREIGN KEY (fid_voie_physique)
REFERENCES G_BASE_VOIE.TA_VOIE_PHYSIQUE(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TA_TRONCON_OLD_OBJECTID_IDX ON G_BASE_VOIE.TA_TRONCON(old_objectid)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TA_TRONCON(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TA_TRONCON(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_FID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.TA_TRONCON(fid_voie_physique)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_TRONCON TO G_ADMIN_SIG;

/

/*
Création de la table TA_SEUIL regroupant toutes les géométries des seuils de la base voie.
*/
/*
DROP TABLE G_BASE_VOIE.TA_SEUIL CASCADE CONSTRAINTS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'TA_SEUIL';
*/
-- 1. Création de la table TA_SEUIL
CREATE TABLE G_BASE_VOIE.TA_SEUIL(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_SEUIL_OBJECTID.NEXTVAL,
    geom SDO_GEOMETRY,
    code_insee VARCHAR2(5 BYTE),
    date_saisie DATE NULL,
    date_modification DATE DEFAULT sysdate NOT NULL,
    fid_pnom_saisie NUMBER(38,0) NOT NULL,
    fid_pnom_modification NUMBER(38,0) NOT NULL,
    fid_troncon NUMBER(38,0),
    fid_position NUMBER(38,0),
    fid_lateralite NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_SEUIL IS 'Table contenant les géométries des seuils de la Base Voie. Plusieurs seuils peuvent se situer sur le même point géographique. Ancienne table : ILTASEU';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.objectid IS 'Clé primaire auto-incrémentée de la table identifiant chaque seuil. Cette pk remplace l''ancien identifiant idseui.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.geom IS 'Géométrie de type point de chaque seuil présent dans la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.code_insee IS 'Code INSEE de chaque seuil inséré en dur à la saisie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.date_saisie IS 'date de saisie du seuil (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.date_modification IS 'Dernière date de modification du seuil(par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.fid_troncon IS 'Identifiant du tronçon de la table TA_TRONCON associé au seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.fid_position IS 'Clé étrangère vers la table TA_LIBELLE permettant d''indiquer la position de l''adresse (seuil, boîte postale, portail, etc).';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.fid_lateralite IS 'Clé étrangère vers la table G_BASE_VOIE.TA_LIBELLE permettant d''affecter une latéralité à un seuil. Cette latéralité est déterminée par rapport au sens géométrique du tronçon.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_SEUIL 
ADD CONSTRAINT TA_SEUIL_PK 
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
    'TA_SEUIL',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TA_SEUIL_SIDX
ON G_BASE_VOIE.TA_SEUIL(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_SEUIL
ADD CONSTRAINT TA_SEUIL_FID_PNOM_SAISIE_FK
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_SEUIL
ADD CONSTRAINT TA_SEUIL_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_SEUIL
ADD CONSTRAINT TA_SEUIL_FID_TRONCON_FK
FOREIGN KEY (fid_troncon)
REFERENCES G_BASE_VOIE.TA_TRONCON(objectid);

ALTER TABLE G_BASE_VOIE.TA_SEUIL
ADD CONSTRAINT TA_SEUIL_FID_POSITION_FK
FOREIGN KEY (fid_position)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_SEUIL
ADD CONSTRAINT TA_SEUIL_FID_LATERALITE_FK 
FOREIGN KEY(fid_lateralite)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TA_SEUIL_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TA_SEUIL(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TA_SEUIL(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_FID_TRONCON_IDX ON G_BASE_VOIE.TA_SEUIL(fid_troncon)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX TA_SEUIL_CODE_INSEE_IDX ON G_BASE_VOIE.TA_SEUIL(code_insee)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX TA_SEUIL_FID_POSITION_IDX ON G_BASE_VOIE.TA_SEUIL(fid_position)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_FID_LATERALITE_IDX ON G_BASE_VOIE.TA_SEUIL(fid_lateralite)
    TABLESPACE G_ADT_INDX;
    
-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_SEUIL TO G_ADMIN_SIG;

/

/*
La table TA_SEUIL_LOG  permet d''avoir l''historique de toutes les évolutions des seuils de la base voie.
*/

-- 1. Création de la table TA_SEUIL_LOG
CREATE TABLE G_BASE_VOIE.TA_SEUIL_LOG(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_SEUIL_LOG_OBJECTID.NEXTVAL,
    geom SDO_GEOMETRY NOT NULL,
    id_seuil NUMBER(38,0),
    code_insee VARCHAR2(5),
    id_troncon NUMBER(38,0),
    id_position NUMBER(38,0),
    id_lateralite NUMBER(38,0),
    date_action DATE DEFAULT sysdate,
    fid_type_action NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_SEUIL_LOG IS 'Table d''historisation des actions effectuées sur les seuils.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.geom IS 'Géométrie de type point de chaque seuil présent dans la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.id_seuil IS 'Identifiant du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.code_insee IS 'Code INSEE du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.id_troncon IS 'Identifiant du tronçon affecté au seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.id_position IS 'Identifiant de la table G_BASE_VOIE.TA_LIBELLE permettant d''affecter une position à un seuil. Cette position désigne le lieu physique de l''adresse (seuil, boîte postale, portail, entrée de rue, etc).';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.id_lateralite IS 'Identifiant de la table G_BASE_VOIE.TA_LIBELLE permettant d''affecter une latéralité à un seuil. Cette latéralité est déterminée par rapport au sens géométrique du tronçon au sein d''une commune et par rapport à la latéralité de sa voie en limites de commune.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.date_action IS 'Date de création, modification ou suppression d''un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de savoir quelle action a été effectuée sur le seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant d''associer le pnom d''un agent au seuil qu''il a créé, modifié ou supprimé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_SEUIL_LOG 
ADD CONSTRAINT TA_SEUIL_LOG_PK 
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
    'TA_SEUIL_LOG',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_SEUIL_LOG
ADD CONSTRAINT TA_SEUIL_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_SEUIL_LOG
ADD CONSTRAINT TA_SEUIL_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

-- 6. Création des index
CREATE INDEX TA_SEUIL_LOG_SIDX
ON G_BASE_VOIE.TA_SEUIL_LOG(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

CREATE INDEX TA_SEUIL_LOG_ID_SEUIL_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(id_seuil)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_LOG_CODE_INSEE_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(code_insee)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_LOG_ID_TRONCON_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(id_troncon)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_LOG_ID_POSITION_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(id_position)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_LOG_ID_LATERALITE_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(id_lateralite)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX TA_SEUIL_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

-- 7. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_SEUIL_LOG TO G_ADMIN_SIG;

/

/*
Création de la table TA_INFOS_SEUIL regroupant le détail des seuils de la base voie.
*/

-- 1. Création de la table TA_INFOS_SEUIL
CREATE TABLE G_BASE_VOIE.TA_INFOS_SEUIL(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_INFOS_SEUIL_OBJECTID.NEXTVAL,
    numero_seuil NUMBER(5,0) DEFAULT 9999 NOT NULL,
    complement_numero_seuil VARCHAR2(10),
    date_saisie DATE NOT NULL,
    date_modification DATE DEFAULT sysdate NOT NULL,
    fid_pnom_saisie NUMBER(38,0),
    fid_pnom_modification NUMBER(38,0),
    fid_seuil NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_INFOS_SEUIL IS 'Table contenant le détail des seuils, c''est-à-dire les numéros de seuil, de parcelles et les compléments de numéro de seuil. Cela permet d''associer un ou plusieurs seuils à un et un seul point géométrique au besoin.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL.numero_seuil IS 'Numéro de seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL.complement_numero_seuil IS 'Complément du numéro de seuil. Exemple : 1 bis';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL.date_saisie IS 'Date de saisie des informations du seuil (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL.date_modification IS 'Date de modification des informations du seuil (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé les informations d''un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié les informations d''un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL.fid_seuil IS 'Clé étrangère vers la table TA_SEUIL, permettant d''affecter une géométrie à un ou plusieurs seuils, dans le cas où plusieurs se superposent sur le même point.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_INFOS_SEUIL 
ADD CONSTRAINT TA_INFOS_SEUIL_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_INFOS_SEUIL
ADD CONSTRAINT TA_INFOS_SEUIL_FID_SEUIL_FK 
FOREIGN KEY (fid_seuil)
REFERENCES G_BASE_VOIE.TA_SEUIL(objectid)
ON DELETE CASCADE;

ALTER TABLE G_BASE_VOIE.TA_INFOS_SEUIL
ADD CONSTRAINT TA_INFOS_SEUIL_FID_PNOM_SAISIE_FK 
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_INFOS_SEUIL
ADD CONSTRAINT TA_INFOS_SEUIL_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

-- 5. Création des index sur les clés étrangères et autres champs
CREATE INDEX TA_INFOS_SEUIL_FID_SEUIL_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL(fid_seuil)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_SEUIL_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_SEUIL_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_SEUIL_NUMERO_SEUIL_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL(numero_seuil)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_INFOS_SEUIL TO G_ADMIN_SIG;

/

/*
La table TA_INFOS_SEUIL_LOG regroupe toutes les évlutions des objets présents dans la table TA_INFOS_SEUIL de la base voie.
*/

-- 1. Création de la table TA_INFOS_SEUIL_LOG
CREATE TABLE G_BASE_VOIE.TA_INFOS_SEUIL_LOG(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_INFOS_SEUIL_LOG_OBJECTID.NEXTVAL,
    id_infos_seuil NUMBER(38,0) NOT NULL,
    id_seuil NUMBER(38,0) NOT NULL,
    numero_seuil NUMBER(5,0) NOT NULL,
    complement_numero_seuil VARCHAR2(10),
    date_action DATE NOT NULL,
    fid_type_action NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_INFOS_SEUIL_LOG IS 'Table de log permettant d''enregistrer toutes les évlutions des objets présents dans la table TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.id_infos_seuil IS 'Identifiant du seuil dans la table TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.id_seuil IS 'Identifiant de la table TA_SEUIL, permettant d''affecter une géométrie à un ou plusieurs seuils, dans le cas où plusieurs se superposent sur le même point.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.numero_seuil IS 'Numéro de seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.complement_numero_seuil IS 'Complément du numéro de seuil. Exemple : 1 bis';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.date_action IS 'Date de chaque action effectuée sur les objets de la table TA_INFOS_SEUILS.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de catégoriser les actions effectuées sur la table TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé, modifié ou supprimé des données dans TA_INFOS_SEUIL.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_INFOS_SEUIL_LOG 
ADD CONSTRAINT TA_INFOS_SEUIL_LOG_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_INFOS_SEUIL_LOG
ADD CONSTRAINT TA_INFOS_SEUIL_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_INFOS_SEUIL_LOG
ADD CONSTRAINT TA_INFOS_SEUIL_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

-- 5. Création des index sur les clés étrangères et les autres champs
CREATE INDEX TA_INFOS_SEUIL_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_SEUIL_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_SEUIL_LOG_ID_INFOS_SEUIL_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL_LOG(id_infos_seuil)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_SEUIL_LOG_ID_SEUIL_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL_LOG(id_seuil)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_INFOS_SEUIL_LOG TO G_ADMIN_SIG;

/

/*
Création de la table TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE permettant d''associer une ou plusieurs voies physiques à une ou plusieurs voies administratives.
*/

-- 1. Création de la table TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
CREATE TABLE G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_OBJECTID.NEXTVAL,
    fid_voie_physique NUMBER(38,0) NOT NULL,
    fid_voie_administrative NUMBER(38,0) NOT NULL,
    fid_lateralite NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE IS 'Table pivot permettant d''associer une ou plusieurs voies physiques à une ou plusieurs voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE.fid_voie_physique IS 'Clé étrangère vers la table TA_VOIE_PHYSIQUE permettant d''associer une ou plusieurs voies physiques à une ou plusieurs administratives.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE.fid_voie_administrative IS 'Clé étrangère vers la table TA_VOIE_ADMINISTRATIVE permettant d''associer une ou plusieurs voies administratives à une ou plusieurs voies physiques.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE.fid_lateralite IS 'Clé étrangère vers la table TA_LIBELLE permettant de récupérer la latéralité de la voie. En limite de commune le côté gauche de la voie physique peut appartenir à la commune A et à la voie administrative 5 tandis que le côté droit peut appartenir à la comune B et à la voie administrative 26. Au sein de la commune en revanche, la voie physique appartient à une et une seule commune et est donc affectée à une et une seule voie administrative. Cette distinction se fait grâce à ce champ.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE 
ADD CONSTRAINT TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
ADD CONSTRAINT TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_FID_VOIE_PHYSIQUE_FK
FOREIGN KEY (fid_voie_physique)
REFERENCES G_BASE_VOIE.TA_VOIE_PHYSIQUE(objectid)
ON DELETE CASCADE;

ALTER TABLE G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
ADD CONSTRAINT TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_FID_VOIE_ADMINISTRATIVE_FK
FOREIGN KEY (fid_voie_administrative)
REFERENCES G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE(objectid)
ON DELETE CASCADE;

ALTER TABLE G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
ADD CONSTRAINT TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_FID_LATERALITE_FK
FOREIGN KEY (fid_lateralite)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

-- 5. Création des index sur les clés étrangères
CREATE INDEX TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_FID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE(fid_voie_physique)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_FID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE(fid_voie_administrative)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_FID_LATERALITE_IDX ON G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE(fid_lateralite)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

/*
Création de la table TA_HIERARCHISATION_VOIE permettant de hiérarchiser les voies en associant les voies secondaires à leur voie principale.
*/

-- 1. Création de la table TA_HIERARCHISATION_VOIE
CREATE TABLE G_BASE_VOIE.TA_HIERARCHISATION_VOIE(
    fid_voie_principale NUMBER(38,0) NOT NULL,
    fid_voie_secondaire NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_HIERARCHISATION_VOIE IS 'Table permettant de hiérarchiser les voies en associant les voies secondaires à leur voie principale.';
COMMENT ON COLUMN G_BASE_VOIE.TA_HIERARCHISATION_VOIE.fid_voie_principale IS 'Clé primaire (partie 1) de la table et clé étrangère vers TA_VOIE_ADMINISTRATIVE permettant d''associer une voie principale à une voie secondaire';
COMMENT ON COLUMN G_BASE_VOIE.TA_HIERARCHISATION_VOIE.fid_voie_secondaire IS 'Clé primaire (partie 2) et clé étrangère vers TA_VOIE_ADMINISTRATIVE permettant d''associer une voie secondaire à une voie principale.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_HIERARCHISATION_VOIE 
ADD CONSTRAINT TA_HIERARCHISATION_VOIE_PK 
PRIMARY KEY("FID_VOIE_PRINCIPALE", "FID_VOIE_SECONDAIRE") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_HIERARCHISATION_VOIE
ADD CONSTRAINT TA_HIERARCHISATION_VOIE_FID_VOIE_PRINCIPALE_FK 
FOREIGN KEY (fid_voie_principale)
REFERENCES G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE(objectid)
ON DELETE CASCADE;

ALTER TABLE G_BASE_VOIE.TA_HIERARCHISATION_VOIE
ADD CONSTRAINT TA_HIERARCHISATION_VOIE_FID_VOIE_SECONDAIRE_FK 
FOREIGN KEY (fid_voie_secondaire)
REFERENCES G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE(objectid)
ON DELETE CASCADE;

-- 5. Création des index sur les clés étrangères et autres champs
CREATE INDEX TA_HIERARCHISATION_VOIE_FID_VOIE_PRINCIPALE_IDX ON G_BASE_VOIE.TA_HIERARCHISATION_VOIE(fid_voie_principale)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_HIERARCHISATION_VOIE_FID_VOIE_SECONDAIRE_IDX ON G_BASE_VOIE.TA_HIERARCHISATION_VOIE(fid_voie_secondaire)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_HIERARCHISATION_VOIE TO G_ADMIN_SIG;

/
/*
Création de la table TA_TRONCON_LOG regroupant toutes les évolutions des tronçons de la base voie situés dans TA_TRONCON.
*/

-- 1. Création de la table TA_TRONCON_LOG
CREATE TABLE G_BASE_VOIE.TA_TRONCON_LOG(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_TRONCON_LOG_OBJECTID.NEXTVAL,
    geom SDO_GEOMETRY NOT NULL,
    id_troncon NUMBER(38,0),
    old_id_troncon NUMBER(38,0),
    id_voie_physique NUMBER(38,0),
    date_action DATE DEFAULT sysdate,
    fid_type_action NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_TRONCON_LOG IS 'Table Table d''historisation des actions effectuées sur les entités de la table TA_TRONCON.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.geom IS 'Géométrie de type ligne simple de chaque tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.id_troncon IS 'Identifiant du tronçon de la table TA_TRONCON.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.old_id_troncon IS 'Ancien identifiant du troncon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.id_voie_physique IS 'Identifiant de la voie physique associée au tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.date_action IS 'date de saisie, modification et suppression du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de catégoriser le type d''action effectuée sur les tronçons.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant d''associer le pnom d''un agent au tronçon qu''il a créé, modifié ou supprimé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_TRONCON_LOG 
ADD CONSTRAINT TA_TRONCON_LOG_PK 
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
    'TA_TRONCON_LOG',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_TRONCON_LOG
ADD CONSTRAINT TA_TRONCON_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_TRONCON_LOG
ADD CONSTRAINT TA_TRONCON_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

-- 6. Création des index
CREATE INDEX TA_TRONCON_LOG_SIDX
ON G_BASE_VOIE.TA_TRONCON_LOG(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

CREATE INDEX TA_TRONCON_LOG_ID_TRONCON_IDX ON G_BASE_VOIE.TA_TRONCON_LOG(id_troncon)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_LOG_OLD_ID_TRONCON_IDX ON G_BASE_VOIE.TA_TRONCON_LOG(old_id_troncon)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_LOG_ID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.TA_TRONCON_LOG(id_voie_physique)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_TRONCON_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_TRONCON_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

-- 7. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_TRONCON_LOG TO G_ADMIN_SIG;

/

/*
Création de la table TA_TRONCON_LOG regroupant toutes les évolutions des voies physiques de la base voie situées dans TA_VOIE_PHYSIQUE.
*/
/*
DROP TABLE TA_VOIE_PHYSIQUE_LOG CASCADE CONSTRAINTS;
*/
-- 1. Création de la table TA_VOIE_PHYSIQUE_LOG
CREATE TABLE G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_VOIE_PHYSIQUE_LOG_OBJECTID.NEXTVAL,
    id_voie_physique NUMBER(38,0),
    id_action NUMBER(38,0),
    date_action DATE DEFAULT sysdate,
    fid_type_action NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG IS 'Table d''historisation des actions effectuées sur les voies physiques de la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG.id_voie_physique IS 'Identifiant des voies physiques de la table TA_VOIE_PHYSIQUE.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG.id_action IS 'Champ permettant de savoir s''il faut inverser le sens géométrique de la voie physique ou non.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG.date_action IS 'date de saisie, modification et suppression du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de catégoriser le type d''action effectuée sur les tronçons.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant d''associer le pnom d''un agent au tronçon qu''il a créé, modifié ou supprimé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG 
ADD CONSTRAINT TA_VOIE_PHYSIQUE_LOG_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG
ADD CONSTRAINT TA_VOIE_PHYSIQUE_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG
ADD CONSTRAINT TA_VOIE_PHYSIQUE_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

-- 5. Création des index
CREATE INDEX TA_VOIE_PHYSIQUE_LOG_ID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG(id_voie_physique)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_PHYSIQUE_LOG_ID_ACTION_IDX ON G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG(id_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_PHYSIQUE_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_PHYSIQUE_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG TO G_ADMIN_SIG;

/

/*
Création de la table TA_VOIE_ADMINISTRATIVE_LOG regroupant toutes les évolutions des voies administratives de la base voie situés dans TA_VOIE_ADMINISTRATIVE.
*/
/*
DROP TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG CASCADE CONSTRAINTS;
*/
-- 1. Création de la table TA_VOIE_ADMINISTRATIVE_LOG
CREATE TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_VOIE_ADMINISTRATIVE_LOG_OBJECTID.NEXTVAL,
    id_voie_administrative NUMBER(38,0),
    id_genre_voie NUMBER(38,0),
    libelle_voie VARCHAR2(1000 BYTE),
    complement_nom_voie VARCHAR2(200),
    code_insee VARCHAR2(5),
    commentaire VARCHAR2(4000 BYTE),
    id_type_voie NUMBER(38,0),
    id_rivoli NUMBER(38,0),
    date_action DATE DEFAULT sysdate,
    fid_type_action NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG IS 'Table d''historisation des actions effectuées sur les voies administratives de la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.id_voie_administrative IS 'Identifiants des voies administratives de la table TA_VOIE_ADMINISTRATIVE.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.id_genre_voie IS 'Identifiant du genre du nom de la voie (féminin, masculin, neutre, etc).';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.libelle_voie IS 'Nom de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.complement_nom_voie IS 'Complément de nom de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.code_insee IS 'Code insee de la voie "administrative".';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.commentaire IS 'Commentaire de chaque voie, à remplir si besoin, pour une précision ou pour les voies n''ayant pas encore de nom.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.id_type_voie IS 'Identifiant de la table TA_TYPE_VOIE permettant d''associer une voie à un type de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.id_rivoli IS 'Identifiant de la table TA_RIVOLI permettant d''associer un code RIVOLI à chaque voie (cette fk est conservée uniquement dans le cadre de la production du jeu BAL).';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.date_action IS 'date de saisie, modification et suppression de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de catégoriser le type d''action effectuée sur les tronçons.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant d''associer le pnom d''un agent à la voie administrative qu''il a créé, modifié ou supprimé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG 
ADD CONSTRAINT TA_VOIE_ADMINISTRATIVE_LOG_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG
ADD CONSTRAINT TA_VOIE_ADMINISTRATIVE_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG
ADD CONSTRAINT TA_VOIE_ADMINISTRATIVE_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

-- 4. Création des index sur les clés étrangères et autres   
CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_ID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(id_voie_administrative)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_LIBELLE_VOIE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(libelle_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_COMPLEMENT_NOM_VOIE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(complement_nom_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_CODE_INSEE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(code_insee)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_ID_TYPE_VOIE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(id_type_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_ID_RIVOLI_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(id_rivoli)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_ID_GENRE_VOIE_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(id_genre_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_ADMINISTRATIVE_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG TO G_ADMIN_SIG;

/

/*
Création de la table TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG regroupant toutes les évolutions des relations voies physiques/administratives de la base voie situés dans TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE.
*/

-- 1. Création de la table TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG
CREATE TABLE G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG_OBJECTID.NEXTVAL,
    id_voie_physique NUMBER(38,0) NOT NULL,
    id_voie_administrative NUMBER(38,0) NOT NULL,
    id_lateralite NUMBER(38,0),
    date_action DATE DEFAULT sysdate,
    fid_type_action NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG IS 'Table d''historisation des actions effectuées sur les entités de la table TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG.id_voie_physique IS 'Identifiant de la table TA_VOIE_PHYSIQUE permettant d''associer une ou plusieurs voies physiques à une ou plusieurs administratives.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG.id_voie_administrative IS 'Identifiant de la table TA_VOIE_ADMINISTRATIVE permettant d''associer une ou plusieurs voies administratives à une ou plusieurs voies physiques.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG.id_lateralite IS 'Identifiant de la table TA_LIBELLE permettant de récupérer la latéralité de la voie. En limite de commune le côté gauche de la voie physique peut appartenir à la commune A et à la voie administrative 5 tandis que le côté droit peut appartenir à la comune B et à la voie administrative 26. Au sein de la commune en revanche, la voie physique appartient à une et une seule commune et est donc affectée à une et une seule voie administrative. Cette distinction se fait grâce à ce champ.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG.date_action IS 'date de saisie, modification et suppression du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de catégoriser le type d''action effectuée sur les tronçons.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant d''associer le pnom d''un agent au tronçon qu''il a créé, modifié ou supprimé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG 
ADD CONSTRAINT TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG
ADD CONSTRAINT TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG
ADD CONSTRAINT TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

-- 5. Création des index
CREATE INDEX TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG_ID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG(id_voie_physique)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG_ID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG(id_voie_administrative)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG_ID_LATERALITE_IDX ON G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG(id_lateralite)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG TO G_ADMIN_SIG;

/

/*
La table TA_VOIE_SUPRA_COMMUNALE faisant le lien entre la table des voies administratives (TA_VOIE_ADMINISTRATIVE) et celle des voies supra-communales de la DEPV (OUT_DOMANIALITE).
*/
/*
DROP TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE CASCADE CONSTRAINTS;
*/
-- 1. Création de la table TA_VOIE_SUPRA_COMMUNALE
CREATE TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_VOIE_SUPRA_COMMUNALE_OBJECTID.NEXTVAL,
    id_sireo VARCHAR2(50 BYTE),
    nom VARCHAR2(50 BYTE) NULL,
    date_saisie DATE,
    date_modification DATE DEFAULT sysdate,
    fid_pnom_saisie NUMBER(38,0),
    fid_pnom_modification NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE IS 'Table contenant toutes les voies supra-communales (EX-RD ou non).';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE.id_sireo IS 'Identifiants des anciennes voies départementales et voies supra-communales antérieures à la migration et mis en place par SIREO.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE.nom IS 'Nom de la voie supra-communale - nom de l''Ex-RD ou laissez ce champ vide - Exemple : MD0750, MD0006D DGIR3.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE.date_saisie IS 'Date de saisie de la voie supra-communale en base.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE.date_modification IS 'Date de modification de la voie supra-communale en base.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant inséré en base une voie supra-communale.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié en base une voie supra-communale.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE 
ADD CONSTRAINT TA_VOIE_SUPRA_COMMUNALE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE
ADD CONSTRAINT TA_VOIE_SUPRA_COMMUNALE_FID_PNOM_SAISIE_FK 
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE
ADD CONSTRAINT TA_VOIE_SUPRA_COMMUNALE_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

-- 5. Création des index sur les clés étrangères et autres
CREATE INDEX TA_VOIE_SUPRA_COMMUNALE_ID_SIREO_IDX ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE(id_sireo)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX TA_VOIE_SUPRA_COMMUNALE_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_SUPRA_COMMUNALE_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE TO G_ADMIN_SIG;

/

/*
La table TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE faisant le lien entre la table des voies administratives (TA_VOIE_ADMINISTRATIVE) et celle des voies supra-communales de la DEPV (OUT_DOMANIALITE).
*/
/*
DROP TABLE G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE CASCADE CONSTRAINTS;
*/
-- 1. Création de la table TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE
CREATE TABLE G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE(
    fid_voie_administrative NUMBER(38,0),
    fid_voie_supra_communale NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE IS 'Table de relation entre la table des voies administratives (TA_VOIE_ADMINISTRATIVE) et celle des voies supra-communales de la DEPV (EXRD_IDSUPVOIE).';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE.fid_voie_administrative IS 'Clé primaire et étrangère de la table permettant d''associer une voie administrative à une voie supra-communale.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE.fid_voie_supra_communale IS 'Clé primaire et étrangère de la table permettant d''associer une voie supra-communale à une voie administrative.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE 
ADD CONSTRAINT TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE_PK 
PRIMARY KEY("FID_VOIE_ADMINISTRATIVE", "FID_VOIE_SUPRA_COMMUNALE") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE
ADD CONSTRAINT TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE_FID_VOIE_ADMINISTRATIVE_FK 
FOREIGN KEY (fid_voie_administrative)
REFERENCES G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE(objectid);

ALTER TABLE G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE
ADD CONSTRAINT TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE_FID_VOIE_SUPRA_COMMUNALE_FK
FOREIGN KEY (fid_voie_supra_communale)
REFERENCES G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE_FID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE(fid_voie_administrative)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE_FID_VOIE_SUPRA_COMMUNALE_IDX ON G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE(fid_voie_supra_communale)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE TO G_ADMIN_SIG;

/

/*
La table TA_VOIE_SUPRA_COMMUNALE_LOG  permet d''avoir l''historique de toutes les évolutions des voies supra-communales de la base voie.
*/
/*
DROP TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG CASCADE CONSTRAINTS;
*/

-- 1. Création de la table TA_VOIE_SUPRA_COMMUNALE_LOG
CREATE TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_VOIE_SUPRA_COMMUNALE_LOG_OBJECTID.NEXTVAL,
    id_voie_supra_communale NUMBER(38,0),
    id_sireo VARCHAR2(50 BYTE),
    nom VARCHAR2(50 BYTE) NULL,
    date_action DATE DEFAULT sysdate,
    fid_type_action NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG IS 'Table d''historisation des actions effectuées sur les voies supra-communales.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG.id_voie_supra_communale IS 'Identifiant de la voie supra-communale.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG.id_sireo IS 'Identifiants des anciennes voies départementales et voies supra-communales antérieures à la migration et mis en place par SIREO.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG.date_action IS 'Date de création, modification ou suppression d''une voie supra-communale.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de savoir quelle action a été effectuée sur la voie supra-communale.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant d''associer le pnom d''un agent à la voie supra-communale qu''il a créé, modifié ou supprimé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG 
ADD CONSTRAINT TA_VOIE_SUPRA_COMMUNALE_LOG_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG
ADD CONSTRAINT TA_VOIE_SUPRA_COMMUNALE_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG
ADD CONSTRAINT TA_VOIE_SUPRA_COMMUNALE_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

-- 5. Création des index
CREATE INDEX TA_VOIE_SUPRA_COMMUNALE_LOG_ID_VOIE_SUPRA_COMMUNALE_IDX ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(id_voie_supra_communale)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_SUPRA_COMMUNALE_LOG_ID_SIREO_IDX ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(id_sireo)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX TA_VOIE_SUPRA_COMMUNALE_LOG_NOM_IDX ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(nom)
    TABLESPACE G_ADT_INDX;
  
CREATE INDEX TA_VOIE_SUPRA_COMMUNALE_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_SUPRA_COMMUNALE_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

-- 7. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG TO G_ADMIN_SIG;
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG TO G_BASE_VOIE_R;

/

/*
Création de la table TA_MISE_A_JOUR_A_FAIRE dans laquelle les agents participant à la correction de la Base Voie peuvent renseigner les mises à jour qu''il faudra faire une fois la base passée en production.
*/
-- Supression de la table
/*
DROP TABLE G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE CASCADE CONSTRAINTS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'TA_MISE_A_JOUR_A_FAIRE';
*/
-- 1. Création de la table TA_INFOS_SEUIL
CREATE TABLE G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE(
    OBJECTID NUMBER(38,0) DEFAULT SEQ_TA_MISE_A_JOUR_A_FAIRE_OBJECTID.NEXTVAL, 
	ID_SEUIL NUMBER(38,0), 
	ID_TRONCON NUMBER(38,0), 
	ID_VOIE_ADMINISTRATIVE NUMBER(38,0),
    CODE_INSEE VARCHAR2(5), 
	EXPLICATION VARCHAR2(4000),  
	DATE_SAISIE DATE, 
    DATE_MODIFICATION DATE, 
    FID_PNOM_SAISIE NUMBER(38,0),
	FID_PNOM_MODIFICATION NUMBER(38,0), 
	FID_ETAT_AVANCEMENT NUMBER(38,0) DEFAULT 110 NOT NULL ENABLE,
    GEOM SDO_GEOMETRY
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE IS 'Table dans laquelle les agents participant à la correction de la Base Voie peuvent renseigner les mises à jour qu''il faudra faire une fois la base passée en production.';
COMMENT ON COLUMN G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE.id_seuil IS 'Identifiant du seuil si l''entité concerne un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE.id_troncon IS 'Identifiant du tronçon si l''entité concerne un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE.id_voie_administrative IS 'Identifiant de la voie administrative si l''entité concerne une voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE.code_insee IS 'Code insee de la mise à jour à faire.';
COMMENT ON COLUMN G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE.explication IS 'Explication de la mise à jour qu''il faudra effectuer.';
COMMENT ON COLUMN G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE.date_saisie IS 'Date de saisie de la mise à jour à faire.';
COMMENT ON COLUMN G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE.date_modification IS 'Dernière date de modification de la mise à jour à faire.';
COMMENT ON COLUMN G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de savoir qui a créé chaque point de mise à jour.';
COMMENT ON COLUMN G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de savoir qui a modifié le point en dernier.';
COMMENT ON COLUMN G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE.fid_etat_avancement IS 'Champ permettant de connaître l''état d''avancement de la mise à jour.';
COMMENT ON COLUMN G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE.geom IS 'Géométrie de type point.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE 
ADD CONSTRAINT TA_MISE_A_JOUR_A_FAIRE_PK 
PRIMARY KEY ("OBJECTID")
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TA_MISE_A_JOUR_A_FAIRE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE
ADD CONSTRAINT TA_MISE_A_JOUR_A_FAIRE_FID_PNOM_SAISIE_FK 
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE
ADD CONSTRAINT TA_MISE_A_JOUR_A_FAIRE_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE
ADD CONSTRAINT TA_MISE_A_JOUR_A_FAIRE_FID_LATERALITE_FK
FOREIGN KEY (fid_etat_avancement)
REFERENCES G_BASE_VOIE.TA_LIBELLE(objectid);

-- 6. Création des index
CREATE INDEX G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE_SIDX ON G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE (geom) 
   INDEXTYPE IS "MDSYS"."SPATIAL_INDEX_V2"  PARAMETERS ('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATEMP_I_TEMP');

CREATE INDEX G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE_ID_SEUIL_IDX ON G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE (id_seuil) 
    TABLESPACE G_ADT_INDX;

CREATE INDEX G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE_ID_TRONCON_IDX ON G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE (id_troncon) 
    TABLESPACE G_ADT_INDX;

CREATE INDEX G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE_ID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE (id_voie_administrative) 
    TABLESPACE G_ADT_INDX;

CREATE INDEX G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE_CODE_INSEE_IDX ON G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE (code_insee) 
    TABLESPACE G_ADT_INDX;

CREATE INDEX G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE_DATE_SAISIE_IDX ON G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE (date_saisie) 
    TABLESPACE G_ADT_INDX;

CREATE INDEX G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE_DATE_MODIFICATION_IDX ON G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE (date_modification) 
    TABLESPACE G_ADT_INDX;

CREATE INDEX G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE_fid_pnom_modification_IDX ON G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE (fid_pnom_modification) 
    TABLESPACE G_ADT_INDX;

CREATE INDEX G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE (fid_pnom_saisie) 
    TABLESPACE G_ADT_INDX;

CREATE INDEX G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE_FID_ETAT_AVANCEMENT_IDX ON G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE (fid_etat_avancement) 
    TABLESPACE G_ADT_INDX;

-- 7. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE TO G_ADMIN_SIG;

/


create or replace FUNCTION GET_CODE_INSEE_97_COMMUNES_CONTAIN_POINT(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
/*
Cette fonction a pour objectif de récupérer le code INSEE de la commune dans laquelle se situe le point médian d'un objet ponctuel (de type point). ATTENTION : cette fonction récupère le code INSEE en faisant la disticntion entre Lille / Lomme / Hellemmes-Lille
La variable v_table_name doit contenir le nom de la table dont on veut connaître le code INSEE des objets.
La variable v_geometry doit contenir le nom du champ géométrique de la table interrogée.
*/
    DETERMINISTIC
    As
    v_code_insee CHAR(8);
    BEGIN
        SELECT
            TRIM(b.code_insee)
            INTO v_code_insee
        FROM
            G_REFERENTIEL.MEL_COMMUNE_LLH b,
            USER_SDO_GEOM_METADATA m
        WHERE
            m.table_name = v_table_name
            AND SDO_CONTAINS(
                    b.geom,
                    v_geometry
                )='TRUE';
        RETURN v_code_insee;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'error';
END GET_CODE_INSEE_97_COMMUNES_CONTAIN_POINT;

/

/*
Affectation des droits de lecture et de mise à jour aux tables de production du schéma
*/
-- 1. Création des droits de lecture et d'édition aux rôles de lecture et d'édition sur les tables de production
GRANT SELECT ON G_BASE_VOIE.TA_AGENT TO G_BASE_VOIE_LEC;	
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_AGENT TO G_BASE_VOIE_MAJ;
GRANT SELECT ON G_BASE_VOIE.TA_HIERARCHISATION_VOIE TO G_BASE_VOIE_LEC;	
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_HIERARCHISATION_VOIE TO G_BASE_VOIE_MAJ;
GRANT SELECT ON G_BASE_VOIE.TA_INFOS_SEUIL TO G_BASE_VOIE_LEC;	
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_INFOS_SEUIL TO G_BASE_VOIE_MAJ;	
GRANT SELECT ON G_BASE_VOIE.TA_LIBELLE TO G_BASE_VOIE_LEC;	
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_LIBELLE TO G_BASE_VOIE_MAJ;
GRANT SELECT ON G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE TO G_BASE_VOIE_LEC;	
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE TO G_BASE_VOIE_MAJ;
GRANT SELECT ON G_BASE_VOIE.TA_RIVOLI TO G_BASE_VOIE_LEC;	
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_RIVOLI TO G_BASE_VOIE_MAJ;
GRANT SELECT ON G_BASE_VOIE.TA_SEUIL TO G_BASE_VOIE_LEC;	
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_SEUIL TO G_BASE_VOIE_MAJ;	
GRANT SELECT ON G_BASE_VOIE.TA_TRONCON TO G_BASE_VOIE_LEC;	
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_TRONCON TO G_BASE_VOIE_MAJ;	
GRANT SELECT ON G_BASE_VOIE.TA_TYPE_VOIE TO G_BASE_VOIE_LEC;	
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_TYPE_VOIE TO G_BASE_VOIE_MAJ;
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE TO G_BASE_VOIE_LEC;	
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE TO G_BASE_VOIE_MAJ;	
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_PHYSIQUE TO G_BASE_VOIE_LEC;	
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_VOIE_PHYSIQUE TO G_BASE_VOIE_MAJ;
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE TO G_BASE_VOIE_LEC;	
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE TO G_BASE_VOIE_MAJ;
GRANT SELECT ON G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE TO G_BASE_VOIE_LEC;	
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE TO G_BASE_VOIE_MAJ;
GRANT SELECT ON G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE TO G_BASE_VOIE_LEC;	
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_MISE_A_JOUR_A_FAIRE TO G_BASE_VOIE_MAJ;

-- 2. Création du droit de lecture à l'utilisateur de lecture sur les tables de logs
GRANT SELECT ON G_BASE_VOIE.TA_TRONCON_LOG TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG TO G_BASE_VOIE_LEC;	
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG TO G_BASE_VOIE_LEC;	
GRANT SELECT ON G_BASE_VOIE.TA_INFOS_SEUIL_LOG TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.TA_SEUIL_LOG TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG TO G_BASE_VOIE_LEC;	
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_TRONCON_LOG TO G_BASE_VOIE_MAJ;
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG TO G_BASE_VOIE_MAJ;	
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG TO G_BASE_VOIE_MAJ;
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG TO G_BASE_VOIE_MAJ;	
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_INFOS_SEUIL_LOG TO G_BASE_VOIE_MAJ;
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_SEUIL_LOG TO G_BASE_VOIE_MAJ;
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG TO G_BASE_VOIE_MAJ;

/

-- 3. Création des droits de lecture des séquences
GRANT SELECT ON G_BASE_VOIE.SEQ_TA_TRONCON_OBJECTID TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.SEQ_TA_TRONCON_OBJECTID TO G_BASE_VOIE_MAJ;
GRANT SELECT ON G_BASE_VOIE.SEQ_TA_VOIE_PHYSIQUE_OBJECTID TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.SEQ_TA_VOIE_PHYSIQUE_OBJECTID TO G_BASE_VOIE_MAJ;
GRANT SELECT ON G_BASE_VOIE.SEQ_TA_VOIE_SUPRA_COMMUNALE_OBJECTID TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.SEQ_TA_VOIE_SUPRA_COMMUNALE_OBJECTID TO G_BASE_VOIE_MAJ;
GRANT SELECT ON G_BASE_VOIE.SEQ_TA_SEUIL_OBJECTID TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.SEQ_TA_SEUIL_OBJECTID TO G_BASE_VOIE_MAJ;
GRANT SELECT ON G_BASE_VOIE.SEQ_TA_VOIE_ADMINISTRATIVE_OBJECTID TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.SEQ_TA_VOIE_ADMINISTRATIVE_OBJECTID TO G_BASE_VOIE_MAJ;

/

-- 4. Creation droits de modification sur les tables TA_SEUIL et TA_TRONCON
GRANT UPDATE(GEOM) ON TA_TRONCON TO G_BASE_VOIE_MAJ;
GRANT UPDATE(GEOM) ON TA_SEUIL TO G_BASE_VOIE_MAJ;

/
