/*
Création de la table TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE - du projet C de correction de la latéralité des voies - rassemblant tous les tronçons affectés à plusieurs voies physiques et permettant de modifier ces relations en affectant un tronçon qu'à une et une seule voie physique.
*/

-- 1. Création de la table TEMP_C_TRONCON
CREATE TABLE G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE (
  id_troncon NUMBER(38,0), 
	old_id_voie_physique NUMBER(38,0), 
	new_id_voie_physique NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE.id_troncon IS 'Identifiant des tronçons.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE.old_id_voie_physique IS 'Ancien identifiant de voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE.new_id_voie_physique IS 'Nouvel identifiant de voie physique.';
COMMENT ON TABLE G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE  IS 'Table - du projet C de correction de la latéralité des voies - rassemblant tous les tronçons affectés à plusieurs voies physiques et permettant de modifier ces relations en affectant un tronçon qu''à une et une seule voie physique.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE 
ADD CONSTRAINT TEMP_C_TRONCON_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des index
CREATE INDEX G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE_NEW_ID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE (new_id_voie_physique)
TABLESPACE G_ADT_INDX;

CREATE INDEX G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE_OLD_ID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE (old_id_voie_physique)
TABLESPACE G_ADT_INDX;
  
/

