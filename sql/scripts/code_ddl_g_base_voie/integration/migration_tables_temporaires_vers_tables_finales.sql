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
INSERT INTO G_BASE_VOIE.TA_FANTOIR(code_rivoli)
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
INSERT INTO G_BASE_VOIE.TA_VOIE(FID_TYPEVOIE, FID_RIVOLI, OBJECTID, COMPLEMENT_NOM_VOIE, LIBELLE_VOIE, FID_GENRE_VOIE, DATE_SAISIE, DATE_MODIFICATION)
        WITH C_1 AS(
            SELECT DISTINCT
                b.objectid AS FID_TYPE_VOIE,
                c.objectid AS FID_CODE_RIVOLI,
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
                INNER JOIN G_BASE_VOIE.TA_FANTOIR c ON c.code_rivoli = a.ccodrvo,
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

-- 11. Désactivation du trigger de log de la table TA_RELATION_TRONCON_VOIE
ALTER TRIGGER B_IUD_TA_RELATION_TRONCON_VOIE_LOG DISABLE;

INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE(FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON)
SELECT
    a.objectid AS fid_troncon,
    c.objectid AS fid_voie,
    b.CCODSTR AS sens,
    b.CNUMTRV AS ordre_troncon
FROM
    G_BASE_VOIE.TA_TRONCON a
    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.objectid
    INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = b.ccomvoi
WHERE
    b.CVALIDE = 'V';

/


-- 13. Insertion d'un seul point géométrique par groupe de seuils dans un rayon de 20cm max dans la table TA_SEUIL
INSERT INTO G_BASE_VOIE.TA_SEUIL(geom)
SELECT
    geom
FROM
    G_BASE_VOIE.TEMP_FUSION_SEUIL;

INSERT INTO G_BASE_VOIE.TA_SEUIL(geom)
SELECT
    a.geom
FROM
    G_BASE_VOIE.TEMP_SEUIL a,
    G_BASE_VOIE.TEMP_FUSION_SEUIL b
WHERE
    SDO_GEOM.WITHIN_DISTANCE(
        a.geom,
        0.50,
        b.geom,
        0.005
    ) <> 'TRUE';