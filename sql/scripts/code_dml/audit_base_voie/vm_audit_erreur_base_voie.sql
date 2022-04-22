-- V_AUDIT_VOIEVOIE_GENRE_NULL: Genre des voies valides NULL Le genre de certaines voies valides n'est pas renseigné (hors c'était une demande des élus)
-- 0. Suppression de l'ancienne vue matérialisée
DROP MATERIALIZED VIEW VM_AUDIT_ERREUR_BASE_VOIE;

--1. Creation de la vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_ERREUR_BASE_VOIE (IDENTIFIANT, NOMBRE_D_ERREUR, TYPE_ERREUR)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
WITH CTE_1 AS
	(
	SELECT
	    COUNT(a.identifiant) AS nombre_d_erreur,
		'Nombre d''adresses en doublons de numéro, côté de la voie, complément de numéro de seuil, identifiant de voie et distance seuil/tronçon.' AS type_erreur
	FROM
	    G_BASE_VOIE.VM_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE a
	UNION ALL
/*	SELECT
	    COUNT(a.identifiant) AS nombre_d_erreur,
		'Nombre de seuils dont la distance par rapport à leur tronçon d''affectation est supérieure à 1000m.' AS type_erreur
	FROM
	    G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_SUPERIEURE_1KM a
	UNION ALL
*/
	SELECT
		COUNT(a.identifiant) AS nombre_d_erreur,
		'Adresses en doublons de numéro, côté de la voie, complément de numéro de seuil et identifiant de voie.' AS type_erreur
	FROM
		G_BASE_VOIE.VM_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE a
	UNION ALL
	SELECT
		COUNT(a.identifiant) AS nombre_d_erreur,
		'Troncons qui ne s''intersectent pas sur les points de depart ni d''arrivé' AS type_erreur
	FROM
		G_BASE_VOIE.VM_AUDIT_INTERSECTION_HORS_POINTS_DEPART_ARRIVE a
	UNION ALL
	SELECT
		COUNT(a.identifiant) AS nombre_d_erreur,
		'Nombre de seuils et les troncons qui s''intersectent.' AS type_erreur
	FROM
		G_BASE_VOIE.VM_AUDIT_INTERSECTION_SEUIL_TRONCON a
	UNION ALL
/*	SELECT
		COUNT(a.identifiant) AS nombre_d_erreur,
		'Seuils distant de moins de 50 cm.' AS type_erreur
	FROM
		G_BASE_VOIE.VM_AUDIT_SEUIL_DISTANCE_50_CM a
	UNION ALL
*/
	SELECT
		COUNT(a.identifiant) AS nombre_d_erreur,
		'Seuils situés hors MEL suite au changement de référentiel commune' AS type_erreur
	FROM
		G_BASE_VOIE.VM_AUDIT_SEUIL_HORS_MEL a
	UNION ALL
	SELECT
		COUNT(a.identifiant) AS nombre_d_erreur,
		'Troncons situés hors MEL suite au changement de référentiel commune' AS type_erreur
	FROM
		G_BASE_VOIE.VM_AUDIT_TRONCON_HORS_MEL a
	UNION ALL
	SELECT
		COUNT(a.identifiant) AS nombre_d_erreur,
		'Troncons d''une meme voie qui ne s''intersectent pas sur les points de depart ni d''arrivé' AS type_erreur
	FROM
		G_BASE_VOIE.VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF a
	UNION ALL
	SELECT
		COUNT(a.identifiant) AS nombre_d_erreur,
		'Nombre de troncon affectes à plusieurs voies' AS type_erreur
	FROM
		G_BASE_VOIE.VM_AUDIT_TRONCON_PLUSIEURS_VOIES a
	UNION ALL
	SELECT
		COUNT(a.identifiant) AS nombre_d_erreur,
		'Nombre de troncon qui ne n''ont pas de domanialite (absent de la table SIREO_LEC.OUT_DOMANIALITE)' AS type_erreur
	FROM
		G_BASE_VOIE.VM_AUDIT_TRONCON_SANS_DOMANIALITE a
	UNION ALL
	SELECT
		COUNT(a.identifiant) AS nombre_d_erreur,
		'Nombre de type de voies présent dans la table voievoi mais absent de la table typevoie.' AS type_erreur
	FROM
		G_BASE_VOIE.VM_AUDIT_TYPE_VOIE_DANS_VOIEVOI_MAIS_ABSENT_TYPE_VOIE a
	UNION ALL
	SELECT
		COUNT(a.identifiant) AS nombre_d_erreur,
		'Nombre de types de voies de la table typevoie sans libelle.' AS type_erreur
	FROM
		G_BASE_VOIE.VM_AUDIT_TYPE_VOIE_SANS_LITY_VOIE a
	UNION ALL
	SELECT
		COUNT(a.identifiant) AS nombre_d_erreur,
		'Nombre de voie secondaire affectées à plusiseurs voie' AS type_erreur
	FROM
		G_BASE_VOIE.VM_AUDIT_VOIE_SECONDAIRE_AVEC_PLUSIEURS_VOIE_PRINCIPALES a
	UNION ALL
	SELECT
		COUNT(a.identifiant) AS nombre_d_erreur,
		'Nombre de voie sans nom' AS type_erreur
	FROM
		G_BASE_VOIE.VM_AUDIT_VOIEVOIE_CNOMINUS_NULL a
	UNION ALL

	SELECT
		COUNT(a.identifiant) AS nombre_d_erreur,
		'Nombre de voie dont le genre est NULL' AS type_erreur
	FROM
		G_BASE_VOIE.VM_AUDIT_VOIEVOIE_GENRE_NULL a
	)
SELECT
	rownum AS identifiant,
	nombre_d_erreur,
	type_erreur
FROM
	CTE_1
;

-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_ERREUR_BASE_VOIE
ADD CONSTRAINT VM_AUDIT_ERREUR_BASE_VOIE_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commentaire de la vue matérialisée
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_ERREUR_BASE_VOIE  IS 'Vue présentant le nombre d''erreur par type d''erreur dans la base voie.';


-- 4. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_ERREUR_BASE_VOIE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_ERREUR_BASE_VOIE.NOMBRE_D_ERREUR IS 'Nombre d''erreur selon le type d''erreur considéré dans la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_ERREUR_BASE_VOIE.TYPE_ERREUR IS 'Type d''erreur considéré.';