/*
Création de la vue faisant le lien entre les tronçons et leur voie, tout en récupérant les coordonnées de leur start/end point, l'ordre des tronçons par voie, la longueur des tronçons et leur code insee.
*/
-- 0. Suppression de l'objet
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TRONCON_VOIE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TRONCON_VOIE';
COMMIT;

-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TRONCON_VOIE (OBJECTID, ID_TRONCON, CODE_INSEE, ID_VOIE, CODE_FANTOIR, NOM_VOIE, SENS, ORDRE_TRONCON, STARTPOINT_TRONCON, ENDPOINT_TRONCON, LONGUEUR_TRONCON, DATE_SAISIE, DATE_MODIFICATION, GEOM)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
    SELECT
        rownum AS OBJECTID,
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
        ROUND(SDO_LRS.MEASURE_RANGE(SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom, m.diminfo)), 2) AS longueur,
        a.date_saisie AS DATE_SAISIE,
        a.date_modification AS DATE_MODIFICATION,
        a.geom
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE c ON c.fid_troncon = a.objectid
        INNER JOIN G_BASE_VOIE.TA_VOIE d ON d.objectid = c.fid_voie
        INNER JOIN G_BASE_VOIE.TA_RIVOLI e ON e.objectid = d.fid_rivoli,
        USER_SDO_GEOM_METADATA m
    WHERE
        m.table_name = 'TA_TRONCON';
        
-- 2. Création des commentaires de la VM
   COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_VOIE.OBJECTID IS 'Clé primaire de la VM. Cette clé est différente des identifiants de tronçons car plusieurs tronçons sont affectés à différentes voies, ce qui les empêche de servir de clé primaire.';
   COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_VOIE.ID_TRONCON IS 'Identifiant des tronçons valides en base.';
   COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_VOIE.CODE_INSEE IS 'Code INSEE de la commune dans laquelle se situe le tronçon.';
   COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_VOIE.ID_VOIE IS 'Identifiant interne des voies.';
   COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_VOIE.CODE_FANTOIR IS 'Code fantoir sur 10 caractères des voies (3 pour le code département + direction ; 3 pour le code commune ; 4 pour le rivoli(identifiant de la voie au sein de la commune).)';
   COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_VOIE.NOM_VOIE IS 'Nom de la voie en minuscule.';
   COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_VOIE.SENS IS 'Sens de saisie du tronçon en base.';
   COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_VOIE.ORDRE_TRONCON IS 'Ordre des tronçons au sein de leur voie (1 = début de la voie).';
   COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_VOIE.STARTPOINT_TRONCON IS 'Coordonnées du point de départ du tronçon (EPSG : 2154).';
   COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_VOIE.ENDPOINT_TRONCON IS 'Coordonnées du point d''arrivée du tronçon (EPSG : 2154).';
   COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_VOIE.LONGUEUR_TRONCON IS 'Longueur du tronçon calculée automatiquement.';
   COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_VOIE.DATE_SAISIE IS 'Date de saisie du tronçon en base.';
   COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_VOIE.DATE_MODIFICATION IS 'Date de la dernière modification du tronçon en base.';
   COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_VOIE.GEOM IS 'Géométrie de chaque tronçon.';
   COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TRONCON_VOIE  IS 'Vue matérialisée regroupant tous les tronçons valides par voie avec leur longueur, coordonnés, sens de saisie, ordre des tronçon dans la voie, code fantoir, nom de la voie, commune, date de création et de modification.';

-- 3. Remplissage des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TRONCON_VOIE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TRONCON_VOIE 
ADD CONSTRAINT VM_TRONCON_VOIE_PK 
PRIMARY KEY (OBJECTID);

-- 5. Création de l'index spatial
CREATE INDEX VM_TRONCON_VOIE_SIDX
ON G_BASE_VOIE.VM_TRONCON_VOIE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 6. Don du droit de lecture de la vue matérialisée au schéma G_BASE_VOIE_LEC et aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_TRONCON_VOIE TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.VM_TRONCON_VOIE TO G_ADMIN_SIG;

/

