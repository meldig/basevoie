/*
Requêtes sql permettant de supprimer les tables de la base voie, servant à tester la structure tenant compte de la latéralité des voies, avec leur MTD spatiale, index, contraintes, triggers et fonctions.
*/

-- 1. Suppression des tables
DROP TABLE G_BASE_VOIE.TEMP_A_TRONCON CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_A_LIBELLE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_A_TYPE_VOIE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_A_AGENT CASCADE CONSTRAINTS;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE;

-- 2. Suppression des métadonnées spatiales
DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'TEMP_A_TRONCON';

DELETE FROM USER_SDO_GEOM_METADATA
WHERE TABLE_NAME = 'VM_TEMP_IMPORT_VOIE_AGREGEE';

-- 3. Suppression des séquences
DROP SEQUENCE SEQ_TEMP_A_TRONCON_OBJECTID;

-- 4. Suppression des fonctions
DROP FUNCTION get_temp_code_insee_97_communes_contain_line;
DROP FUNCTION get_temp_code_insee_97_communes_pourcentage;
DROP FUNCTION get_temp_code_insee_97_communes_within_distance;
DROP FUNCTION get_temp_code_insee_97_communes_troncon;
COMMIT;