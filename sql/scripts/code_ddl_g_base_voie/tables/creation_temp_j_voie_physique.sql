/*
La table TEMP_J_VOIE_PHYSIQUE - du projet j de test de production - rassemblant les identifiant de toutes les voies PHYSIQUES.
En opposition aux voies administratives : une voie physique peut correspondre à deux voies administratives si elle appartient à deux communes différentes.
*/

-- 1. Création de la table TEMP_J_VOIE_PHYSIQUE
CREATE TABLE G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE(
    objectid NUMBER(38,0) DEFAULT SEQ_TEMP_J_VOIE_PHYSIQUE_OBJECTID.NEXTVAL,
    fid_action NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE IS 'Table - du projet j de test de production - rassemblant les identifiant de toutes les voies PHYSIQUES (en opposition aux voies administratives : une voie physique peut correspondre à deux voies administratives si elle appartient à deux communes différentes).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE.objectid IS 'Clé primaire auto-incrémentée de la table (ses identifiants ne reprennent PAS ceux de VOIEVOI).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE.FID_ACTION IS 'Champ permettant de savoir s''il faut inverser le sens géométrique de la voie physique ou non.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE 
ADD CONSTRAINT TEMP_J_VOIE_PHYSIQUE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des index
CREATE INDEX TEMP_J_VOIE_PHYSIQUE_FID_ACTION_IDX ON G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE(fid_action)
    TABLESPACE G_ADT_INDX;

-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE TO G_ADMIN_SIG;

/



