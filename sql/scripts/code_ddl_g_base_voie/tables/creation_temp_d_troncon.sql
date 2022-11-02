/*
La table TEMP_D_TRONCON regroupe tous les tronçons de la base voie.
*/

/*
DROP TABLE G_BASE_VOIE.TEMP_D_TRONCON CASCADE CONSTRAINTS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'TEMP_D_TRONCON';
COMMIT;
*/

-- 1. Création de la table TEMP_D_TRONCON
CREATE TABLE G_BASE_VOIE.TEMP_D_TRONCON(
    new_id_troncon NUMBER(38,0),
    old_id_troncon NUMBER(38,0),
    geom SDO_GEOMETRY NOT NULL,
    sens CHAR(1 BYTE),
    date_saisie DATE DEFAULT sysdate NOT NULL,
    date_modification DATE DEFAULT sysdate NOT NULL,
    fid_voie_physique NUMBER(38,0),
    fid_pnom_saisie NUMBER(38,0) NOT NULL,
    fid_pnom_modification NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_D_TRONCON IS 'Table contenant les tronçons de la base voie. Dans cette table, on fait la relation entre les anciens tronçons et les nouveaux suite à la correction topologique, ce qui nous permet de récupérer leur sens et nous permettra plus tard de faire le lien seuil/nouveau tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_D_TRONCON.old_id_troncon IS 'Identifiant des tronçons de la table TEMP_ILTATRC.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_D_TRONCON.new_id_troncon IS 'Identifiant des tronçons de la table TEMP_C_TRONCON, contenant les nouveaux tronçons suite aux corrections topologiques.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_D_TRONCON.geom IS 'Géométrie de type ligne simple de chaque tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_D_TRONCON.sens IS 'Code permettant de connaître le sens de saisie du tronçon par rapport au sens de la voie : + = dans le sens de la voie ; - = dans le sens inverse de la voie.';
--COMMENT ON COLUMN G_BASE_VOIE.TEMP_D_TRONCON.ordre_troncon IS 'Ordre dans lequel les tronçons se positionnent afin de constituer la voie. 1 est égal au début de la voie et 1 + n est égal au tronçon suivant.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_D_TRONCON.date_saisie IS 'date de saisie du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_D_TRONCON.date_modification IS 'Dernière date de modification du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_D_TRONCON.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_D_TRONCON.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_D_TRONCON.fid_voie_physique IS 'Clé étrangère vers la table TA_VOIE_PHYSIQUE permettant d''associer une voie à un ou plusieurs tronçons. Ancien champ : CCOMVOI.';
--COMMENT ON COLUMN G_BASE_VOIE.TEMP_D_TRONCON.fid_metadonnee IS 'Clé étrangère vers la table G_GEO.TA_METADONNEE permettant de connaître la source des tronçons (MEL ou IGN).';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_D_TRONCON 
ADD CONSTRAINT TEMP_D_TRONCON_PK 
PRIMARY KEY("NEW_ID_TRONCON") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TEMP_D_TRONCON',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_D_TRONCON_SIDX
ON G_BASE_VOIE.TEMP_D_TRONCON(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_D_TRONCON
ADD CONSTRAINT TEMP_D_TRONCON_FID_PNOM_SAISIE_FK 
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_D_TRONCON
ADD CONSTRAINT TEMP_D_TRONCON_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_D_TRONCON
ADD CONSTRAINT TEMP_D_TRONCON_FID_VOIE_FK
FOREIGN KEY (fid_voie_physique)
REFERENCES G_BASE_VOIE.TA_VOIE(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_D_TRONCON_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TEMP_D_TRONCON(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_D_TRONCON_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TEMP_D_TRONCON(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_D_TRONCON_FID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.TEMP_D_TRONCON(fid_voie_physique)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_D_TRONCON TO G_ADMIN_SIG;

/

