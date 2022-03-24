/*
Création de la table TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS permettant d'avoir au format LITTERALIS les associations tronçon/seuil où tout va bien.
*/

-- 1. Création de la table dans laquelle insérer les seuils affectés à un tronçon disposant de plusieurs domanialités différentes (une par sous-tronçon).
CREATE TABLE G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS(
	CODE_VOIE VARCHAR2(254), 
	CODE_POINT VARCHAR2(254), 
	NATURE VARCHAR2(254), 
	LIBELLE VARCHAR2(254), 
	NUMERO NUMBER(8,0), 
	REPETITION VARCHAR2(10), 
	COTE VARCHAR2(254), 
	GEOMETRY SDO_GEOMETRY
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS IS 'Table contenant tous les seuils affectés à un tronçon disposant de plusieurs domanialités différentes (une par sous-tronçon). En conséquence la table des tronçons utilisée pour faire les associations est TEMP_TRONCON_DOMANIA_DOUBLON_LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS.code_voie IS 'Identifiant de chaque voie au format LITTERALIS (VARCHAR).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS.code_point IS 'Identifiant de chaque seuil au format LITTERALIS (VARCHAR) présent dans la table TA_INFOS_SEUIL(objectid).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS.nature IS 'Nature du point. Toutes les valeurs sont ''ADR''.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS.libelle IS 'Libelle de chaque seuil qui est la concaténation du numéro de seuil et du complément de numéro de seuil (quand il y en a un) présents dans TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS.numero IS 'Numéro du seuil au format LITTERALIS NUMBER(8) présent dans TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS.repetition IS 'Complément du numéro de seuil au format LITTERALIS (VARCHAR(10)) présent dans TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS.cote IS 'Côté de la voie où se situe le seuil. Pour toutes les entités cette valeur est ''LesDeuxCotes''.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS.geometry IS 'Géométrie de chaque seuil de type point.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS
ADD CONSTRAINTS TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS_PK
PRIMARY KEY(CODE_POINT)
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS_SIDX
ON G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Affection des droits
GRANT SELECT ON G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS TO G_ADMIN_SIG;

/

