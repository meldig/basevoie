/*
Vérification du nombre d'entités par table dans le schéma d'origine de la base voie
*/
-- Données du schéma G_SIDU
--Décompte du nombre de tronçons
SELECT
	'ILTATRC' AS NOM_TABLE,
	COUNT(*) AS NBR_LIGNES
FROM
	G_SIDU.ILTATRC
UNION ALL
--Décompte du nombre de seuils
SELECT
	'ILTASEU' AS NOM_TABLE,
	COUNT(*) AS NBR_LIGNES
FROM
	G_SIDU.ILTASEU
UNION ALL
--Décompte du nombre de relation tronçons/seuils
SELECT
	'ILTASIT' AS NOM_TABLE,
	COUNT(*) AS NBR_LIGNES
FROM
	G_SIDU.ILTASIT
UNION ALL
--Décompte du nombre de voies
SELECT
	'VOIEVOI' AS NOM_TABLE,
	COUNT(*) AS NBR_LIGNES
FROM
	G_SIDU.VOIEVOI
UNION ALL
--Décompte du nombre de relation tronçons/voies
SELECT
	'VOIECVT' AS NOM_TABLE,
	COUNT(*) AS NBR_LIGNES
FROM
	G_SIDU.VOIECVT
UNION ALL
--Décompte du nombre de types de voie
SELECT
	'TYPEVOIE' AS NOM_TABLE,
	COUNT(*) AS NBR_LIGNES
FROM
	G_SIDU.TYPEVOIE;
UNION ALL
--Décompte du nombre de points d'intérêts
SELECT
	'ILTALPU' AS NOM_TABLE,
	COUNT(*) AS NBR_LIGNES
FROM
	G_SIDU.ILTALPU;