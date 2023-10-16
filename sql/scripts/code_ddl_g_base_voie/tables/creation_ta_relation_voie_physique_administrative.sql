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

