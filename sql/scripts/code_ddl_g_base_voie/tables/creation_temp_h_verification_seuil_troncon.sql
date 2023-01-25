/*
La table TEMP_H_VERIFICATION_SEUIL_TRONCON regroupe tous les seuils de la base voie.
*/

-- 1. Création de la table TEMP_H_VERIFICATION_SEUIL_TRONCON
CREATE TABLE G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON(
    objectid NUMBER(38,0),
    geom SDO_GEOMETRY,
    code_insee AS (TRIM(GET_CODE_INSEE_97_COMMUNES_CONTAIN_POINT('TEMP_H_VERIFICATION_SEUIL_TRONCON', geom))),
    date_modification DATE DEFAULT sysdate NOT NULL,
    fid_pnom_modification NUMBER(38,0) NOT NULL,
    fid_troncon NUMBER(38,0),
    fid_voie_administrative NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON IS 'Table - du projet H de correction des relations tronçons/seuils - permettant de vérifier si les seuilsont affectés aux bons tronçons et aux bonnes voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON.objectid IS 'Clé primaire de la table identifiant chaque seuil et correspondant à la PK de la table TEMP_H_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON.geom IS 'Géométrie de type point de chaque seuil présent dans la table.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON.code_insee IS 'Code INSEE de chaque seuil calculé à partir du référentiel des communes G_REFERENTIEL.MEL_COMMUNE_LLH.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON.date_modification IS 'Dernière date de modification du seuil(par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON.fid_pnom_modification IS 'Clé étrangère vers la table TEMP_H_AGENT permettant de récupérer le pnom de l''agent ayant modifié un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON.fid_troncon IS 'Clé étrangère vers la table TEMP_H_TRONCON permettant d''associer un troncon à un ou plusieurs seuils.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON.fid_voie_administrative IS 'Clé étrangère vers la table TEMP_H_VOIE_ADMINISTRATIVE permettant d''associer un seuil à sa voie.';
-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON 
ADD CONSTRAINT TEMP_H_VERIFICATION_SEUIL_TRONCON_PK 
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
    'TEMP_H_VERIFICATION_SEUIL_TRONCON',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_H_VERIFICATION_SEUIL_TRONCON_SIDX
ON G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATEMP_H_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON
ADD CONSTRAINT TEMP_H_VERIFICATION_SEUIL_TRONCON_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TEMP_H_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON
ADD CONSTRAINT TEMP_H_VERIFICATION_SEUIL_TRONCON_FID_TRONCON_FK
FOREIGN KEY (fid_troncon)
REFERENCES G_BASE_VOIE.TEMP_H_TRONCON(objectid);

ALTER TABLE G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON
ADD CONSTRAINT TEMP_H_VERIFICATION_SEUIL_TRONCON_FID_VOIE_ADMINISTRATIVE_FK
FOREIGN KEY (fid_voie_administrative)
REFERENCES G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_H_VERIFICATION_SEUIL_TRONCON_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_H_VERIFICATION_SEUIL_TRONCON_FID_TRONCON_IDX ON G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON(fid_troncon)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX TEMP_H_VERIFICATION_SEUIL_TRONCON_FID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON(fid_voie_administrative)
    TABLESPACE G_ADT_INDX;

-- Cet index dispose d'une fonction permettant d'accélérer la récupération du code INSEE de la commune d'appartenance du seuil. 
-- Il créé également un champ virtuel dans lequel on peut aller chercher ce code INSEE.
CREATE INDEX TEMP_H_VERIFICATION_SEUIL_TRONCON_CODE_INSEE_IDX
ON G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON(GET_CODE_INSEE_CONTAIN_POINT('TEMP_H_VERIFICATION_SEUIL_TRONCON', geom))
TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_H_VERIFICATION_SEUIL_TRONCON TO G_ADMIN_SIG;

/

