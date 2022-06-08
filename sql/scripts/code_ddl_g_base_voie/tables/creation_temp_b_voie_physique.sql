/*
La table TEMP_B_VOIE_PHYSIQUE regroupe tous les informations de chaque voie de la base voie.
*/

-- 1. Création de la table TEMP_B_VOIE_PHYSIQUE
CREATE TABLE G_BASE_VOIE.TEMP_B_VOIE_PHYSIQUE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_B_VOIE_PHYSIQUE IS 'Table - du projet B de correction des erreurs de topologie - rassemblant les identifiant de toutes les voies PHYSIQUES (en opposition aux voies administratives : une voie physique peut correspondre à deux voies administratives si elle appartient à deux communes différentes).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_VOIE_PHYSIQUE.objectid IS 'Clé primaire auto-incrémentée de la table (ses identifiants ne reprennent PAS ceux de VOIEVOI).';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_B_VOIE_PHYSIQUE 
ADD CONSTRAINT TEMP_B_VOIE_PHYSIQUE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_B_VOIE_PHYSIQUE TO G_ADMIN_SIG;

/

