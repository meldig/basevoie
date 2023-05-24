/*
La table TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE - du projet C de correction de la latéralité des voies - contenant les centroïdes des buffers des centroïdes des voies multilignes en limite de commune dont il faut déterminer la latéralité.
*/

DROP TABLE TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE CASCADE CONSTRAINTS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE';
COMMIT;

-- 1. Création de la table TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE
CREATE TABLE G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE(
    OBJECTID NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    ID_VOIE_ADMINISTRATIVE NUMBER(38,0),
    CODE_INSEE_VOIE VARCHAR2(5 BYTE),
    CODE_INSEE_BUFFER VARCHAR2(5 BYTE),
    GEOM SDO_GEOMETRY
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE IS 'Table - du projet C de correction de la latéralité des voies - contenant les centroïdes des buffers des centroïdes des voies multilignes en limite de commune dont il faut déterminer la latéralité.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE.id_voie_administrative IS 'Identifiant des voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE.code_insee_voie IS 'Code INSEE de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE.code_insee_buffer IS 'Code INSEE du buffer.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE.geom IS 'Géométrie de type point.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE 
ADD CONSTRAINT TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE_PK 
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
    'TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE_SIDX
ON G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE_ID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE(id_voie_administrative)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE_CODE_INSEE_BUFFER_IDX ON G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE(code_insee_buffer)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE_CODE_INSEE_VOIE_IDX ON G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE(code_insee_voie)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE TO G_ADMIN_SIG;

/

