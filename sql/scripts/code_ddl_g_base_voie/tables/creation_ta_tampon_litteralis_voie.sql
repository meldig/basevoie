/*
Création de la table TA_TAMPON_LITTERALIS_VOIE - de la structure intermédiaire entre les tables sources et les vues matérialisées d''export du jeu de données - regroupant toutes les données des tronçons au format LITTERALIS (cf. les spécifications LITTERALIS), sauf la clé primaire.
*/
/*
DROP TABLE G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE CASCADE CONSTRAINTS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'TA_TAMPON_LITTERALIS_VOIE';
*/
-- 1. Création de la table
CREATE TABLE G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE(
	geometry SDO_GEOMETRY NOT NULL,
    objectid NUMBER(38,0),
	code_voie VARCHAR2(254 BYTE) NOT NULL,
    nom_voie VARCHAR2(4000 BYTE) NOT NULL,
	code_insee VARCHAR2(5 BYTE) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE IS 'Table tampon - du projet LITTERALIS et de la structure intermédiaire entre les tables sources et les vues d''export du jeu de données - regroupant toutes les données des voies administratives (dont leur géométrie) nécessaires à l''export LITTERALIS';
COMMENT ON COLUMN G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE.geometry IS 'Géométrie de type multiligne des voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE.objectid IS 'Clé primaire de la table correspondant aux identifiants des voies administratives de la table TA_VOIE_ADMINISTRATIVE.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE.code_voie IS 'Identifiant des voies administratives au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE.nom_voie IS 'Nom de la voie : type de voie + libelle_voie + complement_nom_voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE.code_insee IS 'Code INSEE de la voie principale présente dans TA_VOIE_ADMINISTRATIVE, au format LITTERALIS.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE
ADD CONSTRAINTS TA_TAMPON_LITTERALIS_VOIE_PK
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
    'TA_TAMPON_LITTERALIS_VOIE',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TA_TAMPON_LITTERALIS_VOIE_SIDX
ON G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTILINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des index
CREATE INDEX TA_TAMPON_LITTERALIS_VOIE_CODE_VOIE_IDX
ON G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE(CODE_VOIE)
TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TAMPON_LITTERALIS_VOIE_NOM_VOIE_IDX
ON G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE(NOM_VOIE)
TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TAMPON_LITTERALIS_VOIE_CODE_INSEE_IDX
ON G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE(CODE_INSEE)
TABLESPACE G_ADT_INDX;

-- 7. Affection des droits
GRANT SELECT ON G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE TO G_ADMIN_SIG;

/

