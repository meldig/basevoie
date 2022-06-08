/*
Vérification du nombre d'entités par table dans le schéma d'origine de la base voie pour des données valides uniquement
*/
--Décompte du nombre de tronçons valides
SELECT
	'ILTATRC' AS NOM_TABLE,
	COUNT(*) AS NBR_LIGNES
FROM
	G_SIDU.ILTATRC
WHERE
    cdvaltro = 'V'
UNION ALL
--Décompte du nombre de voies valides
SELECT
	'VOIEVOI' AS NOM_TABLE,
	COUNT(*) AS NBR_LIGNES
FROM
	G_SIDU.VOIEVOI
WHERE
    cdvalvoi = 'V'
UNION ALL
--Décompte du nombre de relation tronçons/voies  valides
SELECT
	'VOIECVT' AS NOM_TABLE,
	COUNT(*) AS NBR_LIGNES
FROM
	G_SIDU.VOIECVT
WHERE
    cvalide = 'V'
UNION ALL
--Décompte du nombre de points d'intérêts de type mairie valides 
SELECT
	'ILTALPU' AS NOM_TABLE,
	COUNT(*) AS NBR_LIGNES
FROM
	G_SIDU.ILTALPU
WHERE
    UPPER(libelle_court) IN(UPPER('mairie'), UPPER('mairie annexe'), UPPER('mairie quartier'))
    AND cdvallpu = 'V'
    ;