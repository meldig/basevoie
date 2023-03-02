/*
Création de la table TA_TAMPON_LITTERALIS_ADRESSE - de la structure intermédiaire entre les tables sources et les vues matérialisées d''export du jeu de données - regroupant toutes les données des seuils au format LITTERALIS (cf. les spécifications LITTERALIS), sauf la clé primaire.
*/
/*
DROP TABLE G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE CASCADE CONSTRAINTS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'TA_TAMPON_LITTERALIS_ADRESSE';
*/
-- 1. Création de la table dans laquelle insérer les seuils affecter à un tronçon disposant d'une seule domanialité et affecté à une seule voie
CREATE TABLE G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE(
	OBJECTID NUMBER(38,0),
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
COMMENT ON TABLE G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE IS 'Table tampon du projet LITTERALIS - de la structure intermédiaire entre les tables sources et les vues matérialisées d''export du jeu de données - regroupant toutes les données des seuils au format LITTERALIS (cf. les spécifications LITTERALIS), sauf la clé primaire.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE.OBJECTID IS 'Clé primaire de la table correspondant aux identifiants de la table TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE.CODE_VOIE IS 'Identifiant de la voie associée au seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE.CODE_POINT IS 'Identifiant du seuil présent dans TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE.NATURE IS 'Nature du point. Toutes les valeurs sont ''ADR''.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE.LIBELLE IS 'Libelle de chaque seuil tel qu''il sera affiché dans les arrêtés : concaténation du numéro de seuil et du complément de numéro de seuil (quand il y en a un) présents dans TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE.NUMERO IS 'Numéro du seuil/adresse (différent de son identifiant) présent dans TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE.REPETITION IS 'Complément du numéro de seuil présent dans TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE.COTE IS 'Côté de la voie où se situe le seuil : Impair ou pair en limite de commune, LesDeuxCotes à l''intérieur d''une commune.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE.GEOMETRY IS 'Géométrie de chaque seuil de type point.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE
ADD CONSTRAINTS TA_TAMPON_LITTERALIS_ADRESSE_PK
PRIMARY KEY(OBJECTID)
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TA_TAMPON_LITTERALIS_ADRESSE',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TA_TAMPON_LITTERALIS_ADRESSE_SIDX
ON G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

CREATE INDEX TA_TAMPON_LITTERALIS_ADRESSE_CODE_VOIE_IDX
ON G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE(CODE_VOIE)
TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TAMPON_LITTERALIS_ADRESSE_LIBELLE_IDX
ON G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE(LIBELLE)
TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TAMPON_LITTERALIS_ADRESSE_NUMERO_IDX
ON G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE(NUMERO)
TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TAMPON_LITTERALIS_ADRESSE_REPETITION_IDX
ON G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE(REPETITION)
TABLESPACE G_ADT_INDX;

-- 6. Affection des droits
GRANT SELECT ON G_BASE_VOIE.TA_TAMPON_LITTERALIS_ADRESSE TO G_ADMIN_SIG;

/

