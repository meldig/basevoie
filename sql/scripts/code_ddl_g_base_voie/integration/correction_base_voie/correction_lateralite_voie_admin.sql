/*
Création de la table TEMP_C_IMPORT_MAIRIE_LILLE contenant la géométrie de la mairie de Lille, récupérée dans GEO.TA_SUR_TOPO_G.
*/

-- 1. Création de la table TEMP_C_IMPORT_MAIRIE_LILLE
CREATE TABLE G_BASE_VOIE.TEMP_C_IMPORT_MAIRIE_LILLE(
    objectid NUMBER(38,0),
    geom SDO_GEOMETRY NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_C_IMPORT_MAIRIE_LILLE IS 'Table contenant la géométrie de la mairie de Lille, récupérée dans GEO.TA_SUR_TOPO_G.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_IMPORT_MAIRIE_LILLE.objectid IS 'Clé primaire de la table correspondant également à la clé primaire de GEO.TA_SUR_TOPO_G.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_IMPORT_MAIRIE_LILLE.geom IS 'Géométrie de type multipolygone.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_C_IMPORT_MAIRIE_LILLE 
ADD CONSTRAINT TEMP_C_IMPORT_MAIRIE_LILLE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TEMP_C_IMPORT_MAIRIE_LILLE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_C_IMPORT_MAIRIE_LILLE_SIDX
ON G_BASE_VOIE.TEMP_C_IMPORT_MAIRIE_LILLE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTIPOLYGON, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_C_IMPORT_MAIRIE_LILLE TO G_ADMIN_SIG;

/

-- Import du polygone de la mairie de Lille via QGIS depuis la table GEO.TA_SUR_TOPO_G

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
Création de la table TEMP_C_CENTROIDE_MAIRIE_LILLE contenant le centroïde de la mairie de Lille, dont la géométrie, stockée dans TEMP_C_IMPORT_MAIRIE_LILLE, a été récupérée dans GEO.TA_SUR_TOPO_G.
*/

-- 1. Création de la table TEMP_C_CENTROIDE_MAIRIE_LILLE
CREATE TABLE G_BASE_VOIE.TEMP_C_CENTROIDE_MAIRIE_LILLE(
    objectid NUMBER(38,0),
    x NUMBER(38,3),
    y NUMBER(38,3),
    geom SDO_GEOMETRY NOT NULL
);


-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_C_CENTROIDE_MAIRIE_LILLE IS 'Table contenant le centroïde de la mairie de Lille, dont la géométrie, stockée dans TEMP_C_IMPORT_MAIRIE_LILLE, a été récupérée dans GEO.TA_SUR_TOPO_G.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_CENTROIDE_MAIRIE_LILLE.objectid IS 'Clé primaire de la table correspondant également à la clé primaire de GEO.TA_SUR_TOPO_G.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_CENTROIDE_MAIRIE_LILLE.x IS 'coordonnées x du point, EPSG2154.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_CENTROIDE_MAIRIE_LILLE.y IS 'coordonnées y du point, EPSG2154.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_CENTROIDE_MAIRIE_LILLE.geom IS 'Géométrie de type point.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_C_CENTROIDE_MAIRIE_LILLE 
ADD CONSTRAINT TEMP_C_CENTROIDE_MAIRIE_LILLE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TEMP_C_CENTROIDE_MAIRIE_LILLE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_C_CENTROIDE_MAIRIE_LILLE_SIDX
ON G_BASE_VOIE.TEMP_C_CENTROIDE_MAIRIE_LILLE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des index sur les autres champs
CREATE INDEX TEMP_C_CENTROIDE_MAIRIE_LILLE_X_IDX ON G_BASE_VOIE.TEMP_C_CENTROIDE_MAIRIE_LILLE(x)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX TEMP_C_CENTROIDE_MAIRIE_LILLE_Y_IDX ON G_BASE_VOIE.TEMP_C_CENTROIDE_MAIRIE_LILLE(y)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_C_CENTROIDE_MAIRIE_LILLE TO G_ADMIN_SIG;

/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
Remplissage de la table TEMP_C_CENTROIDE_MAIRIE_LILLE avec le centroïde de la mairie de Lille
*/
INSERT INTO G_BASE_VOIE.TEMP_C_CENTROIDE_MAIRIE_LILLE(objectid, geom)
SELECT
    objectid,
    SDO_GEOM.SDO_CENTROID(geom, 0.005) AS geom
FROM
    G_BASE_VOIE.TEMP_C_IMPORT_MAIRIE_LILLE;
COMMIT;
-- Résultat : 1 ligne insérée

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
Création de la vue VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE, rafraîchie toutes les 07h00, inversant les start/end points des voies administratives, quand nécessaire et quand le endpoint est plus près du point de référence (mairie de Lille) que le startpoint de la voie. Cela nous permet après d''identifier la latéralité des voies administratives.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE" ("OBJECTID", "ID_VOIE_ADMINISTRATIVE", "CODE_INSEE", "TYPE_POINT", "DISTANCE", "NEW_TYPE_POINT", "GEOM")        
REFRESH FORCE
START WITH sysdate+0 NEXT (SYSDATE+7/24)
DISABLE QUERY REWRITE AS 
    WITH
        C_1 AS(
            SELECT
                a.id_voie_administrative,
                a.code_insee,
                'startpoint' AS type_point,
                SDO_CS.MAKE_2D(SDO_LRS.GEOM_SEGMENT_START_PT(SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom, b.diminfo))) AS geom
            FROM
                G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE a,
                USER_SDO_GEOM_METADATA b
            WHERE
                b.table_name = 'VM_TEMP_C_VOIE_ADMINISTRATIVE'
            UNION ALL
            SELECT
                a.id_voie_administrative,
                a.code_insee,
                'endpoint' AS type_point,
                SDO_CS.MAKE_2D(SDO_LRS.GEOM_SEGMENT_END_PT(SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom, b.diminfo))) AS geom
            FROM
                G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE a,
                USER_SDO_GEOM_METADATA b
            WHERE
                b.table_name = 'VM_TEMP_C_VOIE_ADMINISTRATIVE'
        ),
    
        C_2 AS(
            SELECT
                a.id_voie_administrative,
                a.code_insee,
                a.type_point,
                SDO_GEOM.SDO_DISTANCE(a.geom, b.geom, 0.005) AS distance,
                a.geom
            FROM
                C_1 a,
                G_BASE_VOIE.TEMP_C_CENTROIDE_MAIRIE_LILLE b
        ),
        
        C_3 AS(
            SELECT
                id_voie_administrative,
                MIN(distance) AS distance,
                'startpoint' AS new_type_point
            FROM
                C_2
            GROUP BY
                id_voie_administrative,
                'startpoint'
            UNION ALL
            SELECT
                id_voie_administrative,
                MAX(distance) AS distance,
                'endpoint' AS new_type_point
            FROM
                C_2
            GROUP BY
                id_voie_administrative,
                'endpoint'
            )
            
            SELECT
                rownum AS objectid,
                a.id_voie_administrative,
                a.code_insee,
                a.type_point,
                a.distance,
                b.new_type_point,
                a.geom
            FROM
                C_2 a
                INNER JOIN C_3 b ON b.id_voie_administrative = a.id_voie_administrative AND b.distance = a.distance;

-- 2. Création des commentaires
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE IS 'Vue inversant les start/end points des voies administratives, quand nécessaire et quand le endpoint est plus près du point de référence (mairie de Lille) que le startpoint de la voie. Cela nous permet après d''identifier la latéralité des voies administratives.' ;
COMMENT ON COLUMN G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE.objectid IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE.id_voie_administrative IS 'Identifiant de la voie administrative présente dans VM_TEMP_C_VOIE_ADMINISTRATIVE.';
COMMENT ON COLUMN G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE.code_insee IS 'Code insee de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE.type_point IS 'Type de point distinguant s''il s''agit du startpoint ou du endpoint de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE.distance IS 'Distance entre le point de la voie et le point de référence (correspondant au centroïde de la mairie de Lille) de la table G_BASE_VOIE.TEMP_C_CENTROIDE_MAIRIE_LILLE.';
COMMENT ON COLUMN G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE.new_type_point IS 'Nouveau type de point. Si le endpoint de la voie administrative présente dans VM_TEMP_C_VOIE_ADMINISTRATIVE est plus près du pont de référence que le startpoint, alors il prendra la valeur startpoint dans ce champ. Et son ancien startpoint deviendra son endpoint.';
COMMENT ON COLUMN G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE.geom IS 'Géométrie de type point correspondant à la géométrie des start/endpoints des voies administratives.';

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE 
ADD CONSTRAINT VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE_PK 
PRIMARY KEY (OBJECTID);

--4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création des index
CREATE INDEX VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE_SIDX
ON G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=POINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 6. Création des index
CREATE INDEX VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE_ID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE(id_voie_administrative)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE_CODE_INSEE_IDX ON G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE(code_insee)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE_TYPE_POINT_IDX ON G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE(type_point)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE_DISTANCE_IDX ON G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE(distance)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE_NEW_TYPE_POINT_IDX ON G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE(new_type_point)
    TABLESPACE G_ADT_INDX;
    
-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
Création de la vue VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE, rafraîchie toutes les 07h00, inversant les start/end points des voies administratives, quand nécessaire et quand le endpoint est plus près du point de référence (mairie de Lille) que le startpoint de la voie. Cela nous permet de réorienter la géométrie des voies administratives au besoin.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE';
COMMIT;
*/

-- 1. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE" ("OBJECTID", "LIBELLE_VOIE", "CODE_INSEE", "GEOM")        
REFRESH FORCE
START WITH sysdate+0 NEXT (SYSDATE+8/24)
DISABLE QUERY REWRITE AS 
    WITH
        C_1 AS(-- Sélection des voies administratives ayant deux nouveaux types de sommet différents
            SELECT
                id_voie_administrative
            FROM
                G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE
            GROUP BY
                id_voie_administrative
            HAVING
                COUNT(DISTINCT new_type_point) > 1
        ),
        
        C_2 AS(
            SELECT DISTINCT
                a.id_voie_administrative,
                'reverse' AS statut
            FROM
                G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE a
                INNER JOIN C_1 b ON b.id_voie_administrative = a.id_voie_administrative
            WHERE
                a.type_point <> a.new_type_point
            UNION ALL
            SELECT DISTINCT
                a.id_voie_administrative,
                'keep' AS statut
            FROM
                G_BASE_VOIE.VM_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE a
                INNER JOIN C_1 b ON b.id_voie_administrative = a.id_voie_administrative
            WHERE
                a.type_point = a.new_type_point
        ),
        
        C_3 AS(
            SELECT
                rownum AS objectid,
                a.id_voie_administrative,
                a.libelle_voie,
                a.code_insee,
                CASE 
                    WHEN b.statut = 'reverse' THEN
                        SDO_CS.MAKE_2D(
                            SDO_LRS.REVERSE_GEOMETRY(SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom, m.diminfo)),
                            2154
                        )
                    WHEN b.statut = 'keep' THEN
                        a.geom
                END AS geom
            FROM
                G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE a
                INNER JOIN C_2 b ON b.id_voie_administrative = a.id_voie_administrative,
                USER_SDO_GEOM_METADATA m
            WHERE
                m.table_name = 'VM_TEMP_C_VOIE_ADMINISTRATIVE'
        ),
        
        C_4 AS(
            SELECT
                id_voie_administrative,
                MIN(objectid) AS objectid
            FROM
                C_3
            GROUP BY
                id_voie_administrative
        )
        
        SELECT
            a.id_voie_administrative,
            a.libelle_voie,
            a.code_insee,
            a.geom
        FROM
            C_3 a
            INNER JOIN C_4 b ON b.objectid = a.objectid;
            
-- 2. Création des commentaires sur la table et les champs
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE IS 'Table rafraîchie toutes les 07h00, inversant les start/end points des voies administratives, quand nécessaire et quand le endpoint est plus près du point de référence (mairie de Lille) que le startpoint de la voie. Cela nous permet de réorienter la géométrie des voies administratives au besoin.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE.objectid IS 'Clé primaire de la table et identifiant de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE.geom IS 'Géométrie de type multiligne de chaque voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE.code_insee IS 'Code INSEE de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE.libelle_voie IS 'Libellés des voies administratives (concaténation du type, du libellé et du complément de nom) présents dans la vue matérialisée VM_TEMP_C_VOIE_ADMINISTRATIVE.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE 
ADD CONSTRAINT VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 7. Création des index
CREATE INDEX VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE_ID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE(id_voie_administrative)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE(libelle_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE_CODE_INSEE_IDX ON G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE(code_insee)
    TABLESPACE G_ADT_INDX;

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE_SIDX
ON G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTILINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');
    
-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE TO G_ADMIN_SIG;

/

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
Supression des tables / VM temporaires permettant de donner une latéralité à une voie administrative
*/
DROP TABLE G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE CASCADE CONSTRAINTS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE';

DROP TABLE G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE CASCADE CONSTRAINTS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE';

DROP TABLE G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE CASCADE CONSTRAINTS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE';

DROP TABLE G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE CASCADE CONSTRAINTS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE';

DROP TABLE G_BASE_VOIE.TEMP_C_BUFFER_VOIE_ADMINISTRATIVE CASCADE CONSTRAINTS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'TEMP_C_BUFFER_VOIE_ADMINISTRATIVE';
COMMIT;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
La table TEMP_C_BUFFER_VOIE_ADMINISTRATIVE contient un buffer de 5m autours de la géométrie de chaque voie administrative.
*/

-- 1. Création de la table TEMP_C_BUFFER_VOIE_ADMINISTRATIVE
CREATE TABLE G_BASE_VOIE.TEMP_C_BUFFER_VOIE_ADMINISTRATIVE(
    objectid NUMBER(38,0),
    geom SDO_GEOMETRY NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_C_BUFFER_VOIE_ADMINISTRATIVE IS 'Table contenant un buffer de 5m autours de la géométrie de chaque voie administrative réorientée dans VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_BUFFER_VOIE_ADMINISTRATIVE.objectid IS 'Clé primaire de la table correspondant à l''identifiant de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_BUFFER_VOIE_ADMINISTRATIVE.geom IS 'Géométrie de type multipolygone de chaque buffer.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_C_BUFFER_VOIE_ADMINISTRATIVE 
ADD CONSTRAINT TEMP_C_BUFFER_VOIE_ADMINISTRATIVE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TEMP_C_BUFFER_VOIE_ADMINISTRATIVE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_C_BUFFER_VOIE_ADMINISTRATIVE_SIDX
ON G_BASE_VOIE.TEMP_C_BUFFER_VOIE_ADMINISTRATIVE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTIPOLYGON, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_C_BUFFER_VOIE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
Remplissage de la table G_BASE_VOIE.TEMP_C_BUFFER_VOIE_ADMINISTRATIVE.
*/

INSERT INTO G_BASE_VOIE.TEMP_C_BUFFER_VOIE_ADMINISTRATIVE(objectid, geom)
SELECT
    a.objectid,
    SDO_GEOM.SDO_BUFFER(a.geom, 5, 0.005) AS geom
FROM
    G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE a
    INNER JOIN G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE b ON b.id_voie_administrative = a.objectid
WHERE
    b.lateralite = 'les deux côtés de la voie physique';
COMMIT;
-- Résultat : 22 058 lignes insérées

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
La table TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE contient un découpage du buffer de 5m autours de la géométrie de chaque voie administrative, par les communes qu''il intersecte.
*/

-- 1. Création de la table TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE
CREATE TABLE G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    fid_voie_administrative NUMBER(38,0),
    geom SDO_GEOMETRY NOT NULL,
    code_insee VARCHAR2(5 BYTE)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE IS 'Table contenant un découpage du buffer de 5m autours de la géométrie de chaque voie administrative, par les communes qu''il intersecte.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE.objectid IS 'Clé primaire de la table auto-incrémenté.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE.fid_voie_administrative IS 'Identifiant de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE.geom IS 'Géométrie de type multipolygone de chaque buffer.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE.code_insee IS 'Code INSEE du buffer.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE 
ADD CONSTRAINT TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE
ADD CONSTRAINT TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE_FID_VOIE_ADMINISTRATIVE_FK
FOREIGN KEY (fid_voie_administrative)
REFERENCES G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE_FID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE(fid_voie_administrative)
    TABLESPACE G_ADT_INDX;

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE_SIDX
ON G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTIPOLYGON, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
Remplissage de la table G_BASE_VOIE.TEMP_C_BUFFER_VOIE_ADMINISTRATIVE.
*/

INSERT INTO G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE(fid_voie_administrative, geom, code_insee)
WITH
    C_1 AS(
        SELECT
            a.objectid,
            SDO_GEOM.SDO_INTERSECTION(a.geom, b.geom, 0.005) AS geom,
            b.code_insee
        FROM
            G_BASE_VOIE.TEMP_C_BUFFER_VOIE_ADMINISTRATIVE a,
            G_REFERENTIEL.MEL_COMMUNE_LLH b
    )
    
    SELECT
        objectid,
        geom,
        code_insee
    FROM
        C_1
    WHERE
        geom IS NOT NULL;
COMMIT;
-- 25 393 lignes insérées.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
Création de la table TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE dans laquelle on affecte une latéralité à chaque voie administrative
*/

-- 1. Création de la table TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE
CREATE TABLE G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    geom SDO_GEOMETRY NOT NULL,
    code_insee VARCHAR2(5),
    fid_lateralite NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE IS 'Table permettant d''affecter une latéralité à chaque voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE.objectid IS 'Clé primaire de la table et identifiant de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE.geom IS 'Géométrie de type multiligne de chaque voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE.code_insee IS 'Code INSEE de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE.fid_lateralite IS 'Clé étrangère vers la table TEMP_C_LIBELLE permettant d''indiquer la latéralité d''une voie administrative.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE 
ADD CONSTRAINT TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE
ADD CONSTRAINT TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE_FID_LATERALITE_FK
FOREIGN KEY (fid_lateralite)
REFERENCES G_BASE_VOIE.TEMP_C_LIBELLE(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE_FID_LATERALITE_IDX ON G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE(fid_lateralite)
    TABLESPACE G_ADT_INDX;

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE_SIDX
ON G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTILINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE TO G_ADMIN_SIG;

/

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
Affectation d'une latéralité pour les voies administratives situées au sein des communes (donc ne disposant que d'un seul buffer dans la table TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE)
*/
INSERT INTO G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE(objectid, geom, code_insee, fid_lateralite)
SELECT
    a.id_voie_administrative,
    a.geom,
    a.code_insee,
    3
FROM
    G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE a
WHERE
        id_voie_administrative IN(
            SELECT
                fid_voie_administrative
            FROM
                G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE 
            GROUP BY
                fid_voie_administrative
            HAVING
                COUNT(objectid) = 1
        );
COMMIT;
-- Résultat : 19 147 lignes insérées.

SELECT *
FROM
    USER_SDO_GEOM_METADATA
WHERE
    table_name = 'TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE';
    
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
Création de la table TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE contenant le centroïde du buffer de 5m autours de la géométrie de chaque voie administrative, découpé par les communes qu''il intersecte.
*/

-- 1. Création de la table TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE
CREATE TABLE G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    geom SDO_GEOMETRY NOT NULL,
    code_insee VARCHAR2(5),
    X NUMBER(38,3),
    Y NUMBER(38,3),
    fid_voie_administrative NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE IS 'Table contenant le centroïde du buffer de 5m autours de la géométrie de chaque voie administrative, découpé par les communes qu''il intersecte.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE.objectid IS 'Clé primaire de la table auto-incrémentée.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE.geom IS 'Géométrie de type point des centroïdes des buffers des voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE.code_insee IS 'Code INSEE de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE.x IS 'coordonnées x du point, EPSG2154.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE.x IS 'coordonnées y du point, EPSG2154.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE.fid_voie_administrative IS 'Clé étrangère vers la table TEMP_C_VOIE_ADMINISTRATIVE identifiant les voies administratives.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE 
ADD CONSTRAINT TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE
ADD CONSTRAINT TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE_FID_VOIE_ADMINISTRATIVE_FK
FOREIGN KEY (fid_voie_administrative)
REFERENCES G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE_FID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE(fid_voie_administrative)
    TABLESPACE G_ADT_INDX;

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE_SIDX
ON G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des autres index
CREATE INDEX TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE_X_IDX ON G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE(x)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE_Y_IDX ON G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE(y)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
Remplissage de la table TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE
*/
INSERT INTO TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE(fid_voie_administrative, code_insee, geom)
WITH
    C_1 AS(
        SELECT
                fid_voie_administrative
            FROM
                G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE 
            GROUP BY
                fid_voie_administrative
            HAVING
                COUNT(objectid) > 1
    ),
    
    C_2 AS(
        SELECT 
            a.objectid
        FROM
            G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE a
            INNER JOIN G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE b ON b.objectid = a.fid_voie_administrative
        WHERE
            a.code_insee = b.code_insee
            AND b.objectid IN(SELECT fid_voie_administrative FROM C_1)
    )

    SELECT
        a.fid_voie_administrative,
        a.code_insee,
        SDO_GEOM.SDO_CENTROID(a.geom, 0.005) AS geom
    FROM
        G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE a
        INNER JOIN C_2 b ON b.objectid = a.objectid;
COMMIT;
-- Résultat : 2 908 lignes insérées.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
Mise à jour des champs X/Y de la table TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE
*/
MERGE INTO G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE a
    USING(
        SELECT
            a.objectid,
            ROUND(a.geom.sdo_point.x, 3) AS x,
            ROUND(a.geom.sdo_point.y, 3) AS y
        FROM
            G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE a
    )t
ON(a.objectid = t.objectid)
WHEN MATCHED THEN
    UPDATE SET a.x = t.x, a.y = t.y;
COMMIT;
-- Résultat : 2 908 lignes fusionnées.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
Création de la table TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE contenant la projection sur la voie administrative du centroïde du buffer de 5m autours de la géométrie de chaque voie administrative, découpé par les communes qu''il intersecte.
*/

-- 1. Création de la table TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE
CREATE TABLE G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    geom SDO_GEOMETRY NOT NULL,
    x NUMBER(38,3),
    y NUMBER(38,3),
    code_insee VARCHAR2(5),
    fid_voie_administrative NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE IS 'Table contenant la projection sur la voie administrative du centroïde du buffer de 5m autours de la géométrie de chaque voie administrative, découpé par les communes qu''il intersecte.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE.objectid IS 'Clé primaire de la table auto-incrémentée.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE.geom IS 'Géométrie de type point de la projection des centroïdes des buffers des voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE.x IS 'coordonnées x du point, EPSG2154.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE.y IS 'coordonnées y du point, EPSG2154.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE.code_insee IS 'Code INSEE de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE.fid_voie_administrative IS 'Clé étrangère vers la table TEMP_C_VOIE_ADMINISTRATIVE identifiant les voies administratives.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE 
ADD CONSTRAINT TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE
ADD CONSTRAINT TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE_FID_VOIE_ADMINISTRATIVE_FK
FOREIGN KEY (fid_voie_administrative)
REFERENCES G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE_FID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE(fid_voie_administrative)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE_X_IDX ON G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE(x)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE_Y_IDX ON G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE(y)
    TABLESPACE G_ADT_INDX;

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE_SIDX
ON G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE(fid_voie_administrative, code_insee, geom)
SELECT
    a.objectid,
    a.code_insee,
    SDO_CS.MAKE_2D(
        SDO_LRS.PROJECT_PT(SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom, c.diminfo), b.geom),
        2154
    ) AS geom
FROM
    G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE a
    INNER JOIN G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE b ON b.fid_voie_administrative = a.objectid,
    USER_SDO_GEOM_METADATA c
WHERE
    c.table_name = 'VM_TEMP_C_VOIE_ADMINISTRATIVE';
COMMIT;
-- Résultat : 2 908 lignes insérées.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
Mise à jour des champs X/Y de la table TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE
*/
MERGE INTO G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE a
    USING(
        SELECT
            a.objectid,
            ROUND(t.x, 3) AS x,
            ROUND(t.y, 3) AS y
        FROM
            G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE a,
            TABLE(SDO_UTIL.GETVERTICES(a.geom)) t
    )t
ON(a.objectid = t.objectid)
WHEN MATCHED THEN
    UPDATE SET a.x = t.x, a.y = t.y;
COMMIT;
-- Résultat : 2 908 lignes fusionnées.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
Supression des buffers dont le code insee est différents de celui de la voie à laquelle il est associé
*/

DELETE 
FROM
    G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE
WHERE
    objectid IN(
        WITH
            C_1 AS(
                SELECT
                fid_voie_administrative
            FROM
                G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE 
            GROUP BY
                fid_voie_administrative
            HAVING
                COUNT(objectid) <> 1
            )
        
        SELECT 
            a.objectid
        FROM
            G_BASE_VOIE.TEMP_C_BUFFER_INSEE_VOIE_ADMINISTRATIVE a
            INNER JOIN G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE b ON b.objectid = a.fid_voie_administrative
        WHERE
            a.code_insee <> b.code_insee
            AND b.objectid IN(SELECT fid_voie_administrative FROM C_1)
    );    
COMMIT;
-- 3 338 lignes supprimées.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
Mise à jour du champ fid_lateralite en fonction du décalage du centroïde du buffer par rapport à sa projection sur la voie
*/
MERGE INTO G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_LATERALITE a
    USING(
        SELECT
            b.fid_voie_administrative,
            c.geom,
            b.code_insee,
            CASE
                WHEN a.x < b.x THEN
                    2
                WHEN a.x > b.x THEN
                    1
            END AS fid_lateralite
        FROM
            G_BASE_VOIE.TEMP_C_PROJECTION_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE a
            INNER JOIN G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_INSEE_VOIE_ADMINISTRATIVE b ON b.fid_voie_administrative = a.fid_voie_administrative
            INNER JOIN G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE_REORIENTEE c ON c.objectid = a.fid_voie_administrative
    )t
ON(a.objectid = t.fid_voie_administrative)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.geom, a.code_insee, a.fid_lateralite)
    VALUES(t.fid_voie_administrative, t.geom, t.code_insee, t.fid_lateralite);
COMMIT;
-- Résultat : 2 908 lignes fusionnées.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------