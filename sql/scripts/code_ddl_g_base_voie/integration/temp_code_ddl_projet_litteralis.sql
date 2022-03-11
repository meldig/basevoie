/*
Création de la table TEMP_ADRESSE_AUTRES_LITTERALIS permettant d'avoir au format LITTERALIS les associations tronçon/seuil disposant de plusieurs erreurs, et/ou absentes de TEMP_ADRESSE_CORRECT_LITTERALIS, TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS et TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS. 
Pour remplir cette table, le code utilise la table TEMP_TRONCON_AUTRE_LITTERALIS.
*/

-- 1. Création de la table dans laquelle insérer les seuils affecter à un tronçon disposant d'une seule domanialité et affecté à une seule voie
CREATE TABLE G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS(
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
COMMENT ON TABLE G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS IS 'Table contenant toutes les associations tronçon/seuil disposant de plusieurs erreurs, et/ou absentes de TEMP_ADRESSE_CORRECT_LITTERALIS, TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS et TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS. Pour remplir cette table, le code utilise la table TEMP_TRONCON_AUTRE_LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS.code_voie IS 'Identifiant de chaque voie au format LITTERALIS (VARCHAR).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS.code_point IS 'Identifiant de chaque seuil au format LITTERALIS (VARCHAR) présent dans la table TA_INFOS_SEUIL(objectid).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS.nature IS 'Nature du point. Toutes les valeurs sont ''ADR'''.;
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS.libelle IS 'Libelle de chaque seuil qui est la concaténation du numéro de seuil et du complément de numéro de seuil (quand il y en a un) présents dans TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS.numero IS 'Numéro du seuil au format LITTERALIS NUMBER(8) présent dans TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS.repetition IS 'Complément du numéro de seuil au format LITTERALIS (VARCHAR(10)) présent dans TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS.cote IS 'Côté de la voie où se situe le seuil. Pour toutes les entités cette valeur est ''LesDeuxCotes''.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS.geometry IS 'Géométrie de chaque seuil de type point.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS
ADD CONSTRAINTS TEMP_ADRESSE_AUTRES_LITTERALIS_PK
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
    'TEMP_ADRESSE_AUTRES_LITTERALIS',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_ADRESSE_AUTRES_LITTERALIS_SIDX
ON G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Affection des droits
GRANT SELECT ON G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS TO G_ADMIN_SIG;

/

/*
Création de la table TEMP_ADRESSE_CORRECTE_LITTERALIS permettant d'avoir au format LITTERALIS les associations tronçon/seuil où tout va bien.
*/

-- 1. Création de la table dans laquelle insérer les seuils affecter à un tronçon disposant d'une seule domanialité et affecté à une seule voie
CREATE TABLE G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS(
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
COMMENT ON TABLE G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS IS 'Table contenant tous les seuils affectés à un tronçon disposant d''une seule domanialité et affecté à une seule voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS.code_voie IS 'Identifiant de chaque voie au format LITTERALIS (VARCHAR).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS.code_point IS 'Identifiant de chaque seuil au format LITTERALIS (VARCHAR) présent dans la table TA_INFOS_SEUIL(objectid).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS.nature IS 'Nature du point. Toutes les valeurs sont ''ADR'''.;
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS.libelle IS 'Libelle de chaque seuil qui est la concaténation du numéro de seuil et du complément de numéro de seuil (quand il y en a un) présents dans TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS.numero IS 'Numéro du seuil au format LITTERALIS NUMBER(8) présent dans TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS.repetition IS 'Complément du numéro de seuil au format LITTERALIS (VARCHAR(10)) présent dans TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS.cote IS 'Côté de la voie où se situe le seuil. Pour toutes les entités cette valeur est ''LesDeuxCotes''.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS.geometry IS 'Géométrie de chaque seuil de type point.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS
ADD CONSTRAINTS TEMP_ADRESSE_CORRECTE_LITTERALIS_PK
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
    'TEMP_ADRESSE_CORRECTE_LITTERALIS',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_ADRESSE_CORRECTE_LITTERALIS_SIDX
ON G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Affection des droits
GRANT SELECT ON G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS TO G_ADMIN_SIG;

/

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
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS.nature IS 'Nature du point. Toutes les valeurs sont ''ADR'''.;
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
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Affection des droits
GRANT SELECT ON G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS TO G_ADMIN_SIG;

/

/*
Création de la table TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS permettant d'avoir au format LITTERALIS les associations tronçon/seuil où les tronçons sont affectés à plusieurs voies. En conséquence, la table des tronçons utilisée pour faire les associations est TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS, pour éviter les doublons.
*/

-- 1. Création de la table dans laquelle insérer les seuils affecter à un tronçon disposant d'une seule domanialité et affecté à une seule voie
CREATE TABLE G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS(
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
COMMENT ON TABLE G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS IS 'Table contenant tous les seuils affectés à un tronçon affectés à plusieurs voies. Cependant, afin d''éviter ces doublons la table des tronçons utilisée pour les associations est TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS.code_voie IS 'Identifiant de chaque voie au format LITTERALIS (VARCHAR).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS.code_point IS 'Identifiant de chaque seuil au format LITTERALIS (VARCHAR) présent dans la table TA_INFOS_SEUIL(objectid).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS.nature IS 'Nature du point. Toutes les valeurs sont ''ADR'''.;
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS.libelle IS 'Libelle de chaque seuil qui est la concaténation du numéro de seuil et du complément de numéro de seuil (quand il y en a un) présents dans TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS.numero IS 'Numéro du seuil au format LITTERALIS NUMBER(8) présent dans TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS.repetition IS 'Complément du numéro de seuil au format LITTERALIS (VARCHAR(10)) présent dans TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS.cote IS 'Côté de la voie où se situe le seuil. Pour toutes les entités cette valeur est ''LesDeuxCotes''.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS.geometry IS 'Géométrie de chaque seuil de type point.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS
ADD CONSTRAINTS TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS_PK
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
    'TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS_SIDX
ON G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Affection des droits
GRANT SELECT ON G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS TO G_ADMIN_SIG;

/

/*
Création de la table TEMP_TRONCON_CORRECT_LITTERALIS permettant d'avoir au format LITTERALIS les associations tronçon/voie où tout va bien.
*/

-- 1. Création de la table
CREATE TABLE G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS(
	CODE_TRONC VARCHAR2(254 BYTE),
    ID_TRONCON NUMBER(38,0),
	CLASSEMENT VARCHAR2(254 BYTE),
	CODE_RUE_G VARCHAR2(254 BYTE),
	NOM_RUE_G VARCHAR2(254 BYTE),
	INSEE_G VARCHAR2(254 BYTE),
	CODE_RUE_D VARCHAR2(254 BYTE),
	NOM_RUE_D VARCHAR2(254 BYTE),
	INSEE_D VARCHAR2(254 BYTE),
	LARGEUR NUMBER(8,0),
	GEOMETRY SDO_GEOMETRY
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS IS 'Table contenant tous les tronçons disposant d''une seule domanialité et affecté à une seule voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS.CODE_TRONC IS 'Identifiant du tronçon au format LITTERALIS (VARCHAR).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS.ID_TRONCON IS 'Identifiant du tronçon au format base voie (NUMBER).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS.CLASSEMENT IS 'Domanialité de chaque voie au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS.CODE_RUE_G IS 'Identifiant de chaque voie de gauche du tronçon au format LITTERALIS (VARCHAR).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS.NOM_RUE_G IS 'Libelle voie + complément nom voie issus de TA_VOIE pour la voie de gauche du tronçon .';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS.INSEE_G IS 'Code INSEE de la commune d''appartenance de la voie de gauche du tronçon au format LITTERALIS (VARCHAR).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS.CODE_RUE_D IS 'Identifiant de chaque voie de droite du tronçon au format LITTERALIS (VARCHAR).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS.NOM_RUE_D IS 'Libelle voie + complément nom voie issus de TA_VOIE pour la voie de droite du tronçon .';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS.INSEE_D IS 'Code INSEE de la commune d''appartenance de la voie de droite du tronçon au format LITTERALIS (VARCHAR).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS.LARGEUR IS 'Largeur de la voie de type NUMBER, c-à-d NULL pour nous.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS.GEOMETRY IS 'Géométrie de chaque tronçon de type multiligne.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS
ADD CONSTRAINTS TEMP_TRONCON_CORRECT_LITTERALIS_PK
PRIMARY KEY(CODE_TRONC)
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TEMP_TRONCON_CORRECT_LITTERALIS',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création des index
CREATE INDEX TEMP_TRONCON_CORRECT_LITTERALIS_SIDX
ON G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTILINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

CREATE INDEX TEMP_TRONCON_CORRECT_LITTERALIS_ID_TRONCON_IDX
ON G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS(ID_TRONCON)
TABLESPACE G_ADT_INDX;

-- 6. Affection des droits
GRANT SELECT ON G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS TO G_ADMIN_SIG;

/

/*
Création de la table TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS permettant d'avoir au format LITTERALIS les associations tronçon/voie dans lesquelles un tronçon dispose de plusieurs domanialités différentes (une par sous-tronçon).
*/

-- 1. Création de la table
CREATE TABLE G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS(
	CODE_TRONC VARCHAR2(254 BYTE),
    ID_TRONCON NUMBER(38,0),
	CLASSEMENT VARCHAR2(254 BYTE),
	CODE_RUE_G VARCHAR2(254 BYTE),
	NOM_RUE_G VARCHAR2(254 BYTE),
	INSEE_G VARCHAR2(254 BYTE),
	CODE_RUE_D VARCHAR2(254 BYTE),
	NOM_RUE_D VARCHAR2(254 BYTE),
	INSEE_D VARCHAR2(254 BYTE),
	LARGEUR NUMBER(8,0),
	GEOMETRY SDO_GEOMETRY
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS IS 'Table contenant tous les tronçons disposant de plusieurs domanialités différentes (une par sous-tronçon).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS.CODE_TRONC IS 'Identifiant du tronçon au format LITTERALIS (VARCHAR). Cet identifiant diffère de celui de TA_VOIE pour afin de "supprimer" les doublons.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS.ID_TRONCON IS 'Identifiant du tronçon au format base voie (NUMBER).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS.CLASSEMENT IS 'Domanialité de chaque voie au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS.CODE_RUE_G IS 'Identifiant de chaque voie de gauche du tronçon au format LITTERALIS (VARCHAR).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS.NOM_RUE_G IS 'Libelle voie + complément nom voie issus de TA_VOIE pour la voie de gauche du tronçon .';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS.INSEE_G IS 'Code INSEE de la commune d''appartenance de la voie de gauche du tronçon au format LITTERALIS (VARCHAR).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS.CODE_RUE_D IS 'Identifiant de chaque voie de droite du tronçon au format LITTERALIS (VARCHAR).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS.NOM_RUE_D IS 'Libelle voie + complément nom voie issus de TA_VOIE pour la voie de droite du tronçon .';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS.INSEE_D IS 'Code INSEE de la commune d''appartenance de la voie de droite du tronçon au format LITTERALIS (VARCHAR).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS.LARGEUR IS 'Largeur de la voie de type NUMBER, c-à-d NULL pour nous.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS.GEOMETRY IS 'Géométrie de chaque tronçon de type multiligne.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS
ADD CONSTRAINTS TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS_PK
PRIMARY KEY(CODE_TRONC)
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création des index
CREATE INDEX TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS_SIDX
ON G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTILINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

CREATE INDEX TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS_ID_TRONCON_IDX
ON G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS(ID_TRONCON)
TABLESPACE G_ADT_INDX;

-- 6. Affection des droits
GRANT SELECT ON G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS TO G_ADMIN_SIG;

/

/*
Création de la table TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS permettant d'avoir au format LITTERALIS les associations tronçon/voie dans lesquelles un tronçon est affecté à plusieurs voies.
*/

-- 1. Création de la table
CREATE TABLE G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS(
	CODE_TRONC VARCHAR2(254 BYTE),
    ID_TRONCON NUMBER(38,0),
	CLASSEMENT VARCHAR2(254 BYTE),
	CODE_RUE_G VARCHAR2(254 BYTE),
	NOM_RUE_G VARCHAR2(254 BYTE),
	INSEE_G VARCHAR2(254 BYTE),
	CODE_RUE_D VARCHAR2(254 BYTE),
	NOM_RUE_D VARCHAR2(254 BYTE),
	INSEE_D VARCHAR2(254 BYTE),
	LARGEUR NUMBER(8,0),
	GEOMETRY SDO_GEOMETRY
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS IS 'Table contenant tous les tronçons disposant de plusieurs voies.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS.CODE_TRONC IS 'Identifiant du tronçon au format LITTERALIS (VARCHAR). Cet identifiant diffère de celui de TA_VOIE pour afin de "supprimer" les doublons.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS.ID_TRONCON IS 'Identifiant du tronçon au format base voie (NUMBER).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS.CLASSEMENT IS 'Domanialité de chaque voie au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS.CODE_RUE_G IS 'Identifiant de chaque voie de gauche du tronçon au format LITTERALIS (VARCHAR).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS.NOM_RUE_G IS 'Libelle voie + complément nom voie issus de TA_VOIE pour la voie de gauche du tronçon .';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS.INSEE_G IS 'Code INSEE de la commune d''appartenance de la voie de gauche du tronçon au format LITTERALIS (VARCHAR).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS.CODE_RUE_D IS 'Identifiant de chaque voie de droite du tronçon au format LITTERALIS (VARCHAR).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS.NOM_RUE_D IS 'Libelle voie + complément nom voie issus de TA_VOIE pour la voie de droite du tronçon .';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS.INSEE_D IS 'Code INSEE de la commune d''appartenance de la voie de droite du tronçon au format LITTERALIS (VARCHAR).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS.LARGEUR IS 'Largeur de la voie de type NUMBER, c-à-d NULL pour nous.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS.GEOMETRY IS 'Géométrie de chaque tronçon de type multiligne.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS
ADD CONSTRAINTS TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS_PK
PRIMARY KEY(CODE_TRONC)
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création des index
CREATE INDEX TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS_SIDX
ON G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTILINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

CREATE INDEX TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS_ID_TRONCON_IDX
ON G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS(ID_TRONCON)
TABLESPACE G_ADT_INDX;

-- 6. Affection des droits
GRANT SELECT ON G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS TO G_ADMIN_SIG;

/

