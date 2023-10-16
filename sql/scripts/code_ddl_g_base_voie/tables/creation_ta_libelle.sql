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

