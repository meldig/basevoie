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

