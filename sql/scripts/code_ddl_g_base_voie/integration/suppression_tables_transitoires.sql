/*
Requêtes sql permettant de supprimer les tables transitoires de la base voie avec leur MTD spatiale, index, contraintes, triggers et fonctions.
Pour rappel cette structure transitoire est une étape intermédiaire permettant de corriger les données avant de les insérer dans les tables de production.
*/

-- 1. Suppression des tables pivot
DROP TABLE G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_TRONCON CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_VOIE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_TYPE_VOIE CASCADE CONSTRAINTS;

-- 5. Suppression des métadonnées spatiales
DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'TEMP_TRONCON';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'VM_TEMP_VOIE_AGGREGEE';

-- 6. Suppression des fonctions personnalisées
DROP FUNCTION G_BASE_VOIE.GET_TEMP_CODE_INSEE_97_COMMUNES_CONTAIN_LINE;
DROP FUNCTION G_BASE_VOIE.GET_TEMP_CODE_INSEE_97_COMMUNES_POURCENTAGE;
DROP FUNCTION G_BASE_VOIE.GET_TEMP_CODE_INSEE_97_COMMUNES_TRONCON;
DROP FUNCTION G_BASE_VOIE.GET_TEMP_CODE_INSEE_97_COMMUNES_WITHIN_DISTANCE;

-- 7. Suppression des vues matérialisées
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_VOIE_AGGREGEE;

-- 8. Suppression des séquences
DROP SEQUENCE SEQ_TEMP_TRONCON_OBJECTID;
COMMIT;
