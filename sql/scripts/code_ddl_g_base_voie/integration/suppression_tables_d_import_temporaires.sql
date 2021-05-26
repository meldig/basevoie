/*
Suppression des tables temporaires ayant servies à importer les tables de l'ancien schéma de la base voie, G_SIDU.
*/

-- 1. Suppression des tables temporaires
DROP TABLE G_BASE_VOIE.TEMP_ILTATRC CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_ILTAPTZ CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_ILTADTN CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_VOIEVOI CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_VOIECVT CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_TYPEVOIE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_ILTASEU CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_ILTASIT CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_ILTAFILIA CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_TA_RUE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_TA_RUEVOIE CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_ILTALPU CASCADE CONSTRAINTS;
DROP TABLE G_BASE_VOIE.TEMP_TA_GG_SOURCE CASCADE CONSTRAINTS;

-- 2. Suppression des métadonnées spatiales des tables temporaires
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'TEMP_ILTATRC';
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'TEMP_ILTAPTZ';
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'TEMP_ILTASEU';