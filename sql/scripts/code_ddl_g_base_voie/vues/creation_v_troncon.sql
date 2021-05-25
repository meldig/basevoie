/*
Vue à destination des utilisateurs ayant besoin de faire des sélections sur la table TA_TRONCON (tel que le service voirie).
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_TRONCON(
	objectid,
	date_saisie,
	date_modification,
	debut_validite,
	fin_validite,
	longueur,
	startpoint,
	endpoint,
    CONSTRAINT "V_TRONCON_PK" PRIMARY KEY ("OBJECTID") DISABLE
) 
AS(
	SELECT
	    a.objectid,
	    a.date_saisie,
	    a.date_modification,
	    a.date_debut_validite,
	    a.date_fin_validite,
	    ROUND(SDO_LRS.MEASURE_RANGE(SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom, m.diminfo)), 2) AS longueur,
	    REPLACE(
	        TRIM(
	            BOTH')' FROM
	                TRIM(
	                    BOTH '(' FROM
	                    SUBSTR(
	                        SDO_UTIL.TO_WKTGEOMETRY(
	                            SDO_LRS.GEOM_SEGMENT_START_PT(a.geom)
	                        ),
	                        7
	                    )
	                )
	        ),
	        ' ',
	        ', '
	    )AS start_point,
	    
	    REPLACE(
	        TRIM(
	            BOTH')' FROM
	                TRIM(
	                    BOTH '(' FROM
	                    SUBSTR(
	                        SDO_UTIL.TO_WKTGEOMETRY(
	                            SDO_LRS.GEOM_SEGMENT_END_PT(a.geom)
	                        ),
	                        7
	                    )
	                )
	        ),
	        ' ',
	        ', '
	    )AS end_point
	FROM
	    G_BASE_VOIE.TA_TRONCON a,
	    USER_SDO_GEOM_METADATA m
	WHERE
	    m.TABLE_NAME = 'TA_TRONCON'
);

-- 2. Création des commentaires de la vue
COMMENT ON TABLE G_BASE_VOIE.V_TRONCON IS 'Vue regroupant tous les tronçons de la base voies valides avec leur longueur, coordonnés, date ed création/modification et début/fin de validité.' ;
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON.objectid IS 'Identifiant de chaque tronçon valide.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON.date_saisie IS 'Date de saisie du tronçon dans la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON.date_modification IS 'Date de la dernière modification du tronçon en base.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON.debut_validite IS 'Date de début de vie du tronçon, équivalent à sa date de fin de chantier. Cette date peut être différente de sa date de création en base.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON.fin_validite IS 'Date de fin de validité du tronçon. Cette date correspond à la date d''invalidation du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON.longueur IS 'Longueur du tronçon en mètre.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON.startpoint IS 'Coordonnées du startpoint du tronçon - EPSG 2154';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON.endpoint IS 'Coordonnées du endpoint du tronçon - EPSG 2154';