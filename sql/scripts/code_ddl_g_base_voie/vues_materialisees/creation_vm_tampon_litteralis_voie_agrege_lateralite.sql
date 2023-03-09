/*
Création de la vue matérialisée VM_TAMPON_LITTERALIS_VOIE_AGREGE_LATERALITE - du projet LITTERALIS et de la structure intermédiaire entre les tables sources et les vues d''export du jeu de données - matérialisant les voies administratives par latéralité pour pouvoir générer les zones particulières.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_AGREGE_LATERALITE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TAMPON_LITTERALIS_VOIE_AGREGE_LATERALITE';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TAMPON_LITTERALIS_VOIE_AGREGE_LATERALITE" ("OBJECTID", "CODE_VOIE", "CODE_INSEE", "NOM_VOIE", "COTE_VOIE", "GEOMETRY")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
    WITH
        C_1 AS(
            SELECT -- Sélection et matérialisation des voies situées à l'intérieur des communes
                CAST(a.code_rue_g AS VARCHAR(254)) AS code_voie,
                CAST(a.insee_g AS VARCHAR(254)) AS code_insee,
                CAST(a.nom_rue_g AS VARCHAR(254)) AS nom_voie,
                CAST('LesDeuxCotes' AS VARCHAR(254)) AS cote_voie,
                SDO_AGGR_UNION(
                    SDOAGGRTYPE(a.geometry, 0.005)
                ) AS geom
            FROM
                G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023 a
            WHERE
                a.code_rue_g = a.code_rue_d
            GROUP BY
                CAST(a.code_rue_g AS VARCHAR(254)),
                CAST(a.insee_g AS VARCHAR(254)),
                CAST(a.nom_rue_g AS VARCHAR(254)),
                CAST('LesDeuxCotes' AS VARCHAR(254))
            UNION ALL
            SELECT -- Sélection et matérialisation des voies situées en limite de commune partie gauche
                CAST(a.code_rue_g AS VARCHAR(254)) AS code_voie,
                CAST(a.insee_g AS VARCHAR(254)) AS code_insee,
                CAST(a.nom_rue_g AS VARCHAR(254)) AS nom_voie,
                CAST('Gauche' AS VARCHAR(254)) AS cote_voie,
                SDO_AGGR_UNION(
                    SDOAGGRTYPE(a.geometry, 0.005)
                ) AS geom
            FROM
                G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023 a
            WHERE
                a.code_rue_g <> a.code_rue_d
            GROUP BY
                CAST(a.code_rue_g AS VARCHAR(254)),
                CAST(a.insee_g AS VARCHAR(254)),
                CAST(a.nom_rue_g AS VARCHAR(254)),
                CAST('Gauche' AS VARCHAR(254))
            UNION ALL
            SELECT -- Sélection et matérialisation des voies situées en limite de commune partie droite
                CAST(a.code_rue_d AS VARCHAR(254)),
                CAST(a.insee_d AS VARCHAR(254)),
                CAST(a.nom_rue_d AS VARCHAR(254)) AS nom_voie,
                CAST('Droit' AS VARCHAR(254)) AS cote_voie,
                SDO_AGGR_UNION(
                    SDOAGGRTYPE(a.geometry, 0.005)
                ) AS geom
            FROM
                G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023 a
            WHERE
                a.code_rue_g <> a.code_rue_d
            GROUP BY
                CAST(a.code_rue_d AS VARCHAR(254)),
                CAST(a.insee_d AS VARCHAR(254)),
                CAST(a.nom_rue_d AS VARCHAR(254)),
                CAST('Droit' AS VARCHAR(254))
        )
        
        SELECT
            rownum AS objectid,
            code_voie,
            code_insee,
            nom_voie,
            cote_voie,
            geom
        FROM
            C_1;
            
-- 2. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_AGREGE_LATERALITE IS 'Vue matérialisée - du projet LITTERALIS et de la structure intermédiaire entre les tables sources et les vues d''export du jeu de données - matérialisant les voies administratives par latéralité pour pouvoir générer les zones particulières.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_AGREGE_LATERALITE.OBJECTID IS 'Clé primaire de la VM.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_AGREGE_LATERALITE.CODE_VOIE IS 'Identifiant de la voie au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_AGREGE_LATERALITE.CODE_INSEE IS 'Code INSEE de la voie au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_AGREGE_LATERALITE.NOM_VOIE IS 'Nom voie au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_AGREGE_LATERALITE.COTE_VOIE IS 'Cote de la voie au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_AGREGE_LATERALITE.GEOMETRY IS 'Géométrie de type multiligne.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TAMPON_LITTERALIS_VOIE_AGREGE_LATERALITE',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TAMPON_LITTERALIS_VOIE_AGREGE_LATERALITE 
ADD CONSTRAINT VM_TAMPON_LITTERALIS_VOIE_AGREGE_LATERALITE_PK 
PRIMARY KEY (OBJECTID);

-- 5. Création de l'index spatial
CREATE INDEX VM_TAMPON_LITTERALIS_VOIE_AGREGE_LATERALITE_SIDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_AGREGE_LATERALITE(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 6. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_AGREGE_LATERALITE TO G_ADMIN_SIG;

/

