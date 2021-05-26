/*
Import des données corrigées des tables temporaires vers les tables finales de la base voie.
*/

-- 1. Import des données des agents de la base voie + gestionnaires de données
INSERT INTO G_BASE_VOIE.TA_AGENT(numero_agent, pnom, validite)
SELECT numero_agent, pnom, validite FROM TEMP_AGENT;

-- 2. Import des libellés dans TA_FAMILLE
INSERT INTO G_BASE_VOIE.TA_FAMILLE(valeur)
SELECT valeur FROM TEMP_FAMILLE;

-- 3. Import des libellés dans TA_LIBELLE
INSERT INTO G_BASE_VOIE.TA_LIBELLE(valeur)
SELECT valeur FROM TEMP_LIBELLE;

-- 4. Import des relations dans TA_RELATION_FAMILLE_LIBELLE
INSERT INTO G_BASE_VOIE.TA_RELATION_FAMILLE_LIBELLE(fid_famille, fid_libelle)
SELECT
	a.objectid,
	b.objectid
FROM
	G_BASE_VOIE.TA_FAMILLE a,
	G_BASE_VOIE.TA_LIBELLE b
WHERE
	a.valeur = 'action';

-- 5. Import des tronçons dans TA_TRONCON
INSERT INTO G_BASE_VOIE.TA_TRONCON(geom, date_saisie, date_modification, date_debut_validite, date_fin_validite)
SELECT
	a.geom,
	a.CDTSTRC,
	a.CDTMTRC,
	a.CDTDTRC,
	a.CDTFTRC
FROM
	G_BASE_VOIE.TEMP_TRONCON a;