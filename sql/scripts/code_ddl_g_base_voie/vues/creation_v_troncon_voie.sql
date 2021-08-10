/*
Création de la vue associant chaque tronçon à sa voie avec les identifiants des tronçons/voie, le nom et le code fantoir de la voie, 
le code INSEE, le nom de la commune, la longueur, les coordonnées des start/end points et les dates de saisie/modifications des tronçons en base.
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_TRONCON_VOIE(
    ID_TRONCON, 
    CODE_INSEE, 
    NOM_COMMUNE, 
    ID_VOIE, 
    CODE_FANTOIR, 
    NOM_VOIE, 
    SENS, 
    ORDRE_TRONCON, 
    STARTPOINT_TRONCON, 
    ENDPOINT_TRONCON, 
    LONGUEUR_TRONCON,
    DATE_SAISIE,
    DATE_MODIFICATION,
    CONSTRAINT "V_TRONCON_VOIE_PK" PRIMARY KEY ("ID_TRONCON") DISABLE
) 
AS(
    SELECT
        a.objectid AS ID_TRONCON,
        b.code_insee AS CODE_INSEE,
        b.nom AS NOM_COMMUNE,
        d.objectid AS ID_VOIE,
        '591' || SUBSTR(b.code_insee, 3) || e.code_rivoli AS CODE_FANTOIR,
        d.libelle_voie AS NOM_VOIE,
        c.sens AS SENS,
        c.ordre_troncon AS ORDRE_TRONCON,
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
            )AS end_point,
        ROUND(SDO_LRS.MEASURE_RANGE(SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom, m.diminfo)), 2) AS longueur,
        a.date_saisie AS DATE_SAISIE,
        a.date_modification AS DATE_MODIFICATION
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE c ON c.fid_troncon = a.objectid
        INNER JOIN G_BASE_VOIE.TA_VOIE d ON d.objectid = c.fid_voie
        INNER JOIN G_BASE_VOIE.TA_RIVOLI e ON e.objectid = d.fid_rivoli,
        G_REFERENTIEL.A_COMMUNE b,
        USER_SDO_GEOM_METADATA m
    WHERE
        m.table_name = 'TA_TRONCON'
        AND SDO_ANYINTERACT(a.geom, b.geom) = 'TRUE'
        AND SDO_CONTAINS(
                            b.geom,
                            SDO_LRS.CONVERT_TO_STD_GEOM(
                                SDO_LRS.LOCATE_PT(
                                    SDO_LRS.CONVERT_TO_LRS_GEOM(a.GEOM,m.diminfo),
                                    SDO_GEOM.SDO_LENGTH(a.GEOM,m.diminfo)/2
                                )
                            )
            )='TRUE'
);

-- 2. Création des commentaires de la vue
COMMENT ON TABLE G_BASE_VOIE.V_TRONCON_VOIE IS 'Vue regroupant tous les tronçons valides par voie avec leur longueur, coordonnés, sens de saisie, ordre des tronçon dans la voie, code fantoir, nom de la voie, commune, date de création et de modification.' ;
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_VOIE.id_troncon IS 'Identifiant des tronçons valides en base.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_VOIE.code_insee IS 'Code INSEE de la commune dans laquelle se situe le tronçon. ATTENTION : pour les tronçons en bordure de commune, le code INSEE peut être en fait le code INS d''un arrondissement belge si plus de 50% du tronçon se situe en belgique.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_VOIE.nom_commune IS 'Nom de la commune dans laquelle se situe le tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_VOIE.id_voie IS 'Identifiant interne des voies.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_VOIE.code_fantoir IS 'Code fantoir sur 10 caractères des voies (3 pour le code département + direction ; 3 pour le code commune ; 4 pour le rivoli(identifiant de la voie au sein de la commune).)';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_VOIE.nom_voie IS 'Nom de la voie en minuscule.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_VOIE.sens IS 'Sens de saisie du tronçon en base.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_VOIE.ordre_troncon IS 'Ordre des tronçons au sein de leur voie (1 = début de la voie).';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_VOIE.startpoint_troncon IS 'Coordonnées du point de départ du tronçon (EPSG : 2154).';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_VOIE.endpoint_troncon IS 'Coordonnées du point d''arrivée du tronçon (EPSG : 2154).';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_VOIE.longueur_troncon IS 'Longueur du tronçon calculée automatiquement.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_VOIE.date_saisie IS 'Date de saisie du tronçon en base.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_VOIE.date_modification IS 'Date de la dernière modification du tronçon en base.';

/
