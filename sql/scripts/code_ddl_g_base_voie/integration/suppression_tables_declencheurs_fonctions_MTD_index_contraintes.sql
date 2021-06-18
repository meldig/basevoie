/*
Requêtes sql permettant de supprimer les tables de la base voie avec leur MTD spatiale, index, contraintes, triggers et fonctions.
*/

-- 1. Suppression des tables pivot
DROP TABLE G_BASE_VOIE.TA_RELATION_FAMILLE_LIBELLE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL CASCADE CONSTRAINTS;

-- 2. Suppression des tables filles (tables de log avec FK)
DROP TABLE G_BASE_VOIE.TA_LIBELLE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_TRONCON_LOG CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_VOIE_LOG CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_SEUIL_LOG CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_INFOS_SEUIL_LOG CASCADE CONSTRAINTS;

-- 3. Suppression des tables parentes
DROP TABLE G_BASE_VOIE.TA_FAMILLE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_AGENT CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_TRONCON CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_VOIE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_SEUIL CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_INFOS_SEUIL CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_TYPE_VOIE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TA_RIVOLI CASCADE CONSTRAINTS;

-- 4. Suppression des vues
DROP VIEW G_BASE_VOIE.V_TRONCON;

-- 5. Suppression des métadonnées spatiales
DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'TA_TRONCON';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'TA_TRONCON_LOG';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'TA_SEUIL';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'TA_SEUIL_LOG';

COMMIT;

-- 6. Suppression des fonctions personnalisées du schéma
DROP FUNCTION GET_CODE_INSEE;