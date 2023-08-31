delete from user_sdo_geom_metadata where table_name !='VM_LITERALIS_VOIE_AGREGATION_THEMATIQUES';
commit;

/*
Requêtes sql permettant de supprimer les tables de la base voie avec leur MTD spatiale, index, contraintes, triggers et fonctions, les vues et vues matérialisées.
*/

-- 1. Suppression des tables pivot
DROP TABLE G_BASE_VOIE.TA_HIERARCHISATION_VOIE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE CASCADE CONSTRAINTS;

-- 2. Suppression des tables de logs
DROP TABLE G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE_LOG CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_TRONCON_LOG CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_VOIE_PHYSIQUE_LOG CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE_LOG CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_SEUIL_LOG CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_INFOS_SEUIL_LOG CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE_LOG CASCADE CONSTRAINTS;

-- 3. Suppression des autres tables
DROP TABLE G_BASE_VOIE.TA_TYPE_VOIE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_LIBELLE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_AGENT CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_RIVOLI CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_VOIE_PHYSIQUE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_TRONCON CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_INFOS_SEUIL CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_SEUIL CASCADE CONSTRAINTS;

-- 4. Suppression des vues matérialisées de consultation et d'audit
-- 4.1. Suppression des index spatiaux des VM de consultation
DROP INDEX VM_CONSULTATION_BASE_VOIE;
DROP INDEX VM_CONSULTATION_SEUIL;
DROP INDEX VM_CONSULTATION_VOIE_ADMINISTRATIVE;
DROP INDEX VM_CONSULTATION_VOIE_PHYSIQUE;
DROP INDEX VM_CONSULTATION_VOIE_SUPRA_COMMUNALE;

-- 4.2. Suppression des VM de consultation
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_SEUIL;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE;

-- 4.3. Supression des index spatiaux des VM d'audit
DROP INDEX VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM_SIDX;
DROP INDEX VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE_SIDX;
DROP INDEX VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR_SIDX;
DROP INDEX VM_AUDIT_TRONCON_NON_JOINTIFS_SIDX;

-- 4.4. Suppression des VM d'audit
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TRONCON_NON_JOINTIFS;

-- 5. Suppression des vues statistiques
DROP VIEW G_BASE_VOIE.V_STAT_NOMBRE_OBJET;
DROP VIEW G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE;
DROP VIEW G_BASE_VOIE.V_STAT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE;
DROP VIEW G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE;
DROP VIEW G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE;
DROP VIEW G_BASE_VOIE.V_STAT_CREATION_OBJET_PAR_ANNEE_MOIS;

-- 6. Suppression des métadonnées spatiales
DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'TA_TRONCON';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'TA_TRONCON_LOG';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'TA_SEUIL';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'TA_SEUIL_LOG';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'VM_CONSULTATION_VOIE_ADMINISTRATIVE';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'VM_CONSULTATION_BASE_VOIE';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'VM_CONSULTATION_SEUIL';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'VM_CONSULTATION_VOIE_PHYSIQUE';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'VM_CONSULTATION_VOIE_SUPRA_COMMUNALE';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'VM_AUDIT_TRONCON_NON_JOINTIFS';

COMMIT;

-- 7. Suppression des séquences
DROP SEQUENCE SEQ_TA_TRONCON_OBJECTID;
DROP SEQUENCE SEQ_TA_VOIE_PHYSIQUE_OBJECTID;
DROP SEQUENCE SEQ_TA_VOIE_SUPRA_COMMUNALE_OBJECTID;

-- 8. Suppression des fonctions personnalisées
DROP FUNCTION G_BASE_VOIE.GET_CODE_INSEE_97_COMMUNES_CONTAIN_POINT;

/

