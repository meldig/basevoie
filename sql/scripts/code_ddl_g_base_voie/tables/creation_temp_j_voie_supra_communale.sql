/*
Création de la table de relation - du projet j de test de production - permettant d''associer une ou plusieurs les voies administratives une ou plusieurs voies supra-communales.
*/
/*
DROP TABLE G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE CASCADE CONSTRAINTS;
*/
-- 1. Création de la table TEMP_J_VOIE_SUPRA_COMMUNALE
CREATE TABLE G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE(
    geom SDO_GEOMETRY,
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    id_voie_supra_communale VARCHAR2(50 BYTE),
    domanialite_supra_communale VARCHAR2(100 BYTE),
    fid_voie_administrative NUMBER(38,0),
    nom_voie_administrative VARCHAR2(4000 BYTE),
    code_insee VARCHAR2(5 BYTE)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE IS 'Table - du projet j de test de production - permettant d''associer une ou plusieurs les voies administratives à une ou plusieurs voies supra-communales. Cette table permet aussi de corriger les voies administratives affectées en erreur à des voies supra-communales.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE.geom IS 'Géométrie des voies supra-communales.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE.id_voie_supra_communale IS 'Identifiants des voies supra-communales.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE.domanialite_supra_communale IS 'Domanialité des voies supra-communales.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE.fid_voie_administrative IS 'Identifiants des voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE.nom_voie_administrative IS 'Nom des voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE.code_insee IS 'Code INSEE des voies administratives.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE 
ADD CONSTRAINT TEMP_J_VOIE_SUPRA_COMMUNALE_PK 
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
    'TEMP_J_VOIE_SUPRA_COMMUNALE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE
ADD CONSTRAINT TEMP_J_VOIE_SUPRA_COMMUNALE_FID_VOIE_ADMINISTRATIVE_FK
FOREIGN KEY (fid_voie_administrative)
REFERENCES G_BASE_VOIE.TEMP_J_VOIE_ADMINISTRATIVE(objectid);

-- 6. Création des index sur les clés étrangères
CREATE INDEX TEMP_J_VOIE_SUPRA_COMMUNALE_ID_VOIE_SUPRA_COMMUNALE_IDX ON G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE(id_voie_supra_communale)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_J_VOIE_SUPRA_COMMUNALE_FID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE(fid_voie_administrative)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_J_VOIE_SUPRA_COMMUNALE_DOMANIALITE_SUPRA_COMMUNALE_IDX ON G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE(domanialite_supra_communale)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_J_VOIE_SUPRA_COMMUNALE_CODE_INSEE_IDX ON G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE(code_insee)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_J_VOIE_SUPRA_COMMUNALE_NOM_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE(nom_voie_administrative)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_J_VOIE_SUPRA_COMMUNALE_SIDX
ON G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTILINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 7. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_J_VOIE_SUPRA_COMMUNALE TO G_ADMIN_SIG;

/

