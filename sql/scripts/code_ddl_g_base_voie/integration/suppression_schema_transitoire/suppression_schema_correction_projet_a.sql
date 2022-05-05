/*
Requêtes sql permettant de supprimer les tables de la base voie avec leur MTD spatiale, index, contraintes, triggers et fonctions.
*/

-- 1. Suppression des tables
DROP TABLE G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_VOIE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_TYPE_VOIE CASCADE CONSTRAINTS;

-- 2. Suppression des métadonnées spatiales
DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'TEMP_CORRECTION_PROJET_A_TRONCON';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'VM_TEMP_CORRECTION_PROJET_A_VOIE_AGGREGEE';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_INSIDE_COMMUNE';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE';

-- 3. Suppression des fonctions personnalisées
DROP FUNCTION G_BASE_VOIE.GET_TEMP_CODE_INSEE_97_COMMUNES_CONTAIN_LINE;
DROP FUNCTION G_BASE_VOIE.GET_TEMP_CODE_INSEE_97_COMMUNES_POURCENTAGE;
DROP FUNCTION G_BASE_VOIE.GET_TEMP_CODE_INSEE_97_COMMUNES_TRONCON;
DROP FUNCTION G_BASE_VOIE.GET_TEMP_CODE_INSEE_97_COMMUNES_WITHIN_DISTANCE;

-- 4. Suppression des vues matérialisées
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_CORRECTION_PROJET_A_VOIE_AGGREGEE;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_INSIDE_COMMUNE;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE;

-- 5. Suppression des vues
DROP VIEW G_BASE_VOIE.V_TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE_DOUBLON;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'V_TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE_DOUBLON';

DROP VIEW G_BASE_VOIE.V_TEMP_CORRECTION_PROJET_A_VOIE_DOUBLON;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'V_TEMP_CORRECTION_PROJET_A_VOIE_DOUBLON';

-- 6. Suppression des séquences
DROP SEQUENCE SEQ_TEMP_CORRECTION_PROJET_A_TRONCON_OBJECTID;
COMMIT;