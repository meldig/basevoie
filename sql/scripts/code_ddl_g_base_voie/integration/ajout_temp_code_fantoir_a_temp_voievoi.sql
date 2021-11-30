/*
Création d'un champ temporaire nécessaire à l'import des données dans les tables finales de la Base Voie
*/

ALTER TABLE G_BASE_VOIE.TEMP_VOIEVOI ADD temp_code_fantoir CHAR(11);
COMMENT ON COLUMN G_BASE_VOIE.TEMP_VOIEVOI.temp_code_fantoir IS 'Champ temporaire contenant le VRAI code fantoir des voies.';