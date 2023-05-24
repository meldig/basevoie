/*
La vue V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE fait l''audit des relations entre les tronçons, les voies physiques et les voies administratives.
*/
/*
DROP VIEW V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE" ("OBJECTID", "CODE_INSEE", "NOM_COMMUNE", "NOMBRE", 
    CONSTRAINT "V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
	WITH
		C_1 AS(
			SELECT
				b.code_insee,
				b.nom AS nom_commune,
				COUNT(a.objectid) AS nombre
			FROM
				G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE a 
				INNER JOIN G_REFERENTIEL.MEL_COMMUNE_LLH b ON TRIM(b.code_insee) = TRIM(a.code_insee)
			GROUP BY
			    b.code_insee,
			    b.nom
		)

		SELECT
			rownum AS objectid,
			code_insee,
			nom_commune,
			nombre
		FROM
			C_1;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE IS 'Vue dénombrant les voies administratives par commune.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE.objectid IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE.code_insee IS 'Code INSEE de la commune (avec Lomme et Hellemmes-Lille).';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE.nom_commune IS 'Nom de la commune (avec Lomme et Hellemmes-Lille).';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE.nombre IS 'Nombre de voies administratives par commune.';

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE TO G_ADMIN_SIG;

/

