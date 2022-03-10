CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_TRONCON_VOIE(
    ID_TRONCON, 
    CODE_INSEE, 
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
    GEOM,
    CONSTRAINT "V_TRONCON_VOIE_PK" PRIMARY KEY ("ID_TRONCON") DISABLE
) 
AS(
        SELECT
        a.objectid AS ID_TRONCON,
        TRIM(a.SYS_NC00015$) AS CODE_INSEE,
        d.objectid AS ID_VOIE,
        '591' || SUBSTR(TRIM(a.SYS_NC00015$), 3) || e.code_rivoli AS CODE_FANTOIR,
        d.libelle_voie AS NOM_VOIE,
        c.sens AS SENS,
        c.ordre_troncon AS ORDRE_TRONCON,
        CAST(REPLACE(
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
            ) AS VARCHAR2(100))AS start_point,
            
            CAST(REPLACE(
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
            )AS VARCHAR2(100))AS end_point,
        ROUND(SDO_LRS.MEASURE_RANGE(SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom)), 2) AS longueur,
        a.date_saisie AS DATE_SAISIE,
        a.date_modification AS DATE_MODIFICATION,
        a.geom
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE c ON c.fid_troncon = a.objectid
        INNER JOIN G_BASE_VOIE.TA_VOIE d ON d.objectid = c.fid_voie
        INNER JOIN G_BASE_VOIE.TA_RIVOLI e ON e.objectid = d.fid_rivoli
);

COMMENT ON TABLE G_BASE_VOIE.V_TRONCON_VOIE IS 'Vue regroupant tous les tronçons valides par voie avec leur longueur, coordonnés, sens de saisie, ordre des tronçon dans la voie, code fantoir, nom de la voie, commune, date de création et de modification.' ;
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_VOIE.id_troncon IS 'Identifiant des tronçons valides en base.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_VOIE.code_insee IS 'Code INSEE de la commune dans laquelle se situe le tronçon.';
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
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_VOIE.geom IS 'Géométrie de chaque tronçon.';  

/
