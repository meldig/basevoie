/*
Requêtes sql permettant de supprimer les tables de la base voie, servant à tester la structure tenant compte de la latéralité des voies, avec leur MTD spatiale, index, contraintes, triggers et fonctions.
*/

-- 1. Suppression des tables
DROP TABLE G_BASE_VOIE.TEMP_A_TRONCON CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_A_VOIE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_A_LIBELLE_VOIE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_A_TYPE_VOIE CASCADE CONSTRAINTS;

-- 2. Suppression des métadonnées spatiales
DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'TEMP_A_TRONCON';

-- 6. Suppression des séquences
DROP SEQUENCE SEQ_TEMP_A_TRONCON_OBJECTID;
COMMIT;