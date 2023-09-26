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
GRANT SELECT ON G_BASE_VOIE.SEQ_TA_MISE_A_JOUR_A_FAIRE_OBJECTID TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.SEQ_TA_MISE_A_JOUR_A_FAIRE_OBJECTID TO G_BASE_VOIE_MAJ;

/

-- 4. Creation droits de modification sur les tables TA_SEUIL et TA_TRONCON
GRANT UPDATE(GEOM) ON TA_TRONCON TO G_BASE_VOIE_MAJ;
GRANT UPDATE(GEOM) ON TA_SEUIL TO G_BASE_VOIE_MAJ;

/
