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

-- 5. Insertion des codes fantoir dans TA_FANTOIR
INSERT INTO G_BASE_VOIE.TA_FANTOIR(code_fantoir)
SELECT DISTINCT
    CCODRVO
FROM
    G_BASE_VOIE.TEMP_VOIEVOI;

-- 6. Désactivation du trigger de log de la table TA_TRONCON
ALTER TRIGGER B_IUD_TA_TRONCON_LOG DISABLE;

-- 7. Import des tronçons dans TA_TRONCON
INSERT INTO G_BASE_VOIE.TA_TRONCON(geom, date_saisie, date_modification, date_debut_validite, date_fin_validite)
SELECT
	a.geom,
	a.CDTSTRC,
	a.CDTMTRC,
	a.CDTDTRC,
	a.CDTFTRC
FROM
	G_BASE_VOIE.TEMP_TRONCON a
WHERE
    a.cdvaltro = 'V';

-- 8. Désactivation de la contrainte de non-nullité du champ TA_TYPE_VOIE.LIBELLE
ALTER TABLE G_BASE_VOIE.TA_TYPE_VOIE DISABLE CONSTRAINT SYS_C00414903;

-- 9. Import des données dans TA_TYPE_VOIE
INSERT INTO G_BASE_VOIE.TA_TYPE_VOIE(code_type_voie, libelle)
SELECT
	CCODTVO,
	LITYVOIE
FROM
	G_BASE_VOIE.TEMP_TYPEVOIE;

-- 10. Import des voies dans TA_VOIE
INSERT INTO G_BASE_VOIE.TA_VOIE(FID_TYPEVOIE, FID_FANTOIR, OBJECTID, COMPLEMENT_NOM_VOIE, LIBELLE_VOIE, FID_GENRE_VOIE, DATE_SAISIE, DATE_MODIFICATION)
        WITH C_1 AS(
            SELECT DISTINCT
                b.objectid AS FID_TYPE_VOIE,
                c.objectid AS FID_CODE_FANTOIR,
                a.CCOMVOI AS NUMERO_VOIE,
                a.CINFOS AS COMPLEMENT_NOM_VOIE,
                a.CNOMINUS AS LIBELLE,
                CASE
                    WHEN a.genre = 'M' AND f.valeur = 'masculin' THEN f.objectid
                    WHEN a.genre = 'F' AND f.valeur = 'féminin' THEN f.objectid
                    WHEN a.genre = 'N' AND f.valeur = 'neutre' THEN f.objectid
                    WHEN a.genre = 'C' AND f.valeur = 'couple' THEN f.objectid
                    WHEN a.genre = 'NI' AND f.valeur = 'non-identifié' THEN f.objectid
                END AS GENRE,
                CDTSVOI AS DATE_SAISIE,
                CDTMVOI AS DATE_MODIFICATION
            FROM
                G_BASE_VOIE.TEMP_VOIEVOI a
                INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.code_type_voie = a.ccodtvo
                INNER JOIN G_BASE_VOIE.TA_FANTOIR c ON c.code_fantoir = a.ccodrvo,
                G_BASE_VOIE.TA_FAMILLE d
                INNER JOIN G_BASE_VOIE.TA_RELATION_FAMILLE_LIBELLE e ON e.fid_famille = d.objectid
                INNER JOIN G_BASE_VOIE.TA_LIBELLE f ON f.objectid = e.fid_libelle
            WHERE
                a.ccomvoi IS NOT NULL 
                AND a.CDVALVOI = 'V'
            )
        SELECT *
        FROM
            C_1
        WHERE
            GENRE IS NOT NULL;