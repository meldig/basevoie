/*
La table TEMP_A_LIBELLE_VOIE regroupe tous les informations de chaque voie de la base voie. Cette séparation de l'identifiant de voie permet d''affecter deux noms à une voie physique.
*/

-- 1. Création de la table TEMP_A_LIBELLE_VOIE
CREATE TABLE G_BASE_VOIE.TEMP_A_LIBELLE_VOIE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    libelle_voie VARCHAR2(1000 BYTE),
    complement_nom_voie VARCHAR2(100),
    lateralite CHAR(2 BYTE),
    fid_voie NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_A_LIBELLE_VOIE IS 'Table rassemblant les informations de chaque voie et notamment leurs libellés : une voie physique peut avoir deux noms différents si elle traverse deux communes différentes.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_LIBELLE_VOIE.objectid IS 'Clé primaire auto-incrémentée de la table. Elle remplace l''ancien identifiant ccomvoie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_LIBELLE_VOIE.libelle_voie IS 'Nom de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_LIBELLE_VOIE.complement_nom_voie IS 'Complément de nom de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_LIBELLE_VOIE.lateralite IS 'Latéralité de la voie : les deux côtés d''une voie physique peuvent appartenir à deux communes différentes.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_LIBELLE_VOIE.fid_voie IS 'Clé étrangère vers la table TEMP_A_VOIE permettant d''associer une voie physique à un nom de voie.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_A_LIBELLE_VOIE 
ADD CONSTRAINT TEMP_A_LIBELLE_VOIE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_A_LIBELLE_VOIE
ADD CONSTRAINT TEMP_A_LIBELLE_VOIE_FID_METADONNEE_FK
FOREIGN KEY (fid_voie)
REFERENCES G_BASE_VOIE.TEMP_A_VOIE(objectid);

-- 4. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_A_LIBELLE_VOIE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.TEMP_A_LIBELLE_VOIE(libelle_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_A_LIBELLE_VOIE_COMPLEMENT_NOM_VOIE_IDX ON G_BASE_VOIE.TEMP_A_LIBELLE_VOIE(complement_nom_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_A_LIBELLE_VOIE_LATERALITE_IDX ON G_BASE_VOIE.TEMP_A_LIBELLE_VOIE(lateralite)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_A_LIBELLE_VOIE_FID_VOIE_IDX ON G_BASE_VOIE.TEMP_A_LIBELLE_VOIE(fid_voie)
    TABLESPACE G_ADT_INDX;

-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_A_LIBELLE_VOIE TO G_ADMIN_SIG;

/

