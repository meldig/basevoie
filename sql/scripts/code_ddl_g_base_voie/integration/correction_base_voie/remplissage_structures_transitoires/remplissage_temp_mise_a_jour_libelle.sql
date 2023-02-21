/*
Remplissage de la table TEMP_MISE_A_JOUR_LIBELLE
*/

INSERT INTO G_BASE_VOIE.TEMP_MISE_A_JOUR_LIBELLE(libelle_court, libelle_long)
	SELECT
		'à faire' AS libelle_court,
		'Il reste une action à faire sur cette entité (correction, vérification, validation, etc).' AS libelle_long
	FROM
		DUAL
	UNION ALL
	SELECT
		'en cours' AS libelle_court,
		'Une action est en cours sur cette entité (correction, vérification, validation, etc).' AS libelle_long
	FROM
		DUAL
	UNION ALL
	SELECT
		'terminé' AS libelle_court,
		'L''action qui était à faire sur cette entité (correction, vérification, validation, etc) a été terminée.' AS libelle_long
	FROM
		DUAL;

/

