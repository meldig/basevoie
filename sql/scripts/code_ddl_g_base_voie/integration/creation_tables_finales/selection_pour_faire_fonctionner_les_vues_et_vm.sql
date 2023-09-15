/*
Sélection permettant de lancer la création des VM
*/

SELECT
	GET_CODE_INSEE_97_COMMUNES_CONTAIN_POINT('TA_SEUIL', a.geom)
FROM
	G_BASE_VOIE.TA_SEUIL a;

/

