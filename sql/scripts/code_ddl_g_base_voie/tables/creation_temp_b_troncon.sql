/*
La table TEMP_B_TRONCON regroupe tous les tronçons de la base voie.
*/

-- 1. Création de la table TEMP_B_TRONCON
CREATE TABLE G_BASE_VOIE.TEMP_B_TRONCON(
    objectid NUMBER(38,0),
    geom SDO_GEOMETRY NULL,
    sens CHAR(1 BYTE),
    date_saisie DATE DEFAULT sysdate NULL,
    date_modification DATE DEFAULT sysdate NULL,
    fid_pnom_saisie NUMBER(38,0) NULL,
    fid_pnom_modification NUMBER(38,0) NULL,
    fid_voie_physique NUMBER(38,0),
    fid_metadonnee NUMBER(38,0) NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_B_TRONCON IS 'Table - du projet B de correction des erreurs de topologie - contenant les tronçons de la base voie. Il s''agit d''une table temporaire servant à tester la structure de la base en teant compte des latéralités de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_TRONCON.objectid IS 'Clé primaire de la table identifiant chaque tronçon. Cette pk est auto-incrémentée et remplace l''ancien identifiant cnumtrc.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_TRONCON.geom IS 'Géométrie de type ligne simple de chaque tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_TRONCON.sens IS 'Sense de circulation du tronçon par rapport au sens de saisie : "+" = saisie de saisie égal au sens de circulation ; "-" = sens de saisie opposé au sens de circulation.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_TRONCON.date_saisie IS 'date de saisie du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_TRONCON.date_modification IS 'Dernière date de modification du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_TRONCON.fid_pnom_saisie IS 'Clé étrangère vers la table TEMP_B_AGENT permettant de récupérer le pnom de l''agent ayant créé un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_TRONCON.fid_pnom_modification IS 'Clé étrangère vers la table TEMP_B_AGENT permettant de récupérer le pnom de l''agent ayant modifié un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_TRONCON.fid_voie_physique IS 'Clé étrangère vers la table TEMP_B_VOIE_PHYSIQUE, permettant d''associer un tronçon à une et une seule voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_B_TRONCON.fid_metadonnee IS 'Clé étrangère vers la table G_GEO.TA_METADONNEE permettant de connaître la source des tronçons (MEL ou IGN).';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_B_TRONCON 
ADD CONSTRAINT TEMP_B_TRONCON_PK 
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
    'TEMP_B_TRONCON',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_B_TRONCON_SIDX
ON G_BASE_VOIE.TEMP_B_TRONCON(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_B_TRONCON
ADD CONSTRAINT TEMP_B_TRONCON_FID_PNOM_SAISIE_FK 
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TEMP_B_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_B_TRONCON
ADD CONSTRAINT TEMP_B_TRONCON_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TEMP_B_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_B_TRONCON
ADD CONSTRAINT TEMP_B_TRONCON_FID_VOIE_PHYSIQUE_FK
FOREIGN KEY (fid_voie_physique)
REFERENCES G_BASE_VOIE.TEMP_B_VOIE_PHYSIQUE(objectid);

ALTER TABLE G_BASE_VOIE.TEMP_B_TRONCON
ADD CONSTRAINT TEMP_B_TRONCON_FID_METADONNEE_FK
FOREIGN KEY (fid_metadonnee)
REFERENCES G_GEO.TA_METADONNEE(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_B_TRONCON_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TEMP_B_TRONCON(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_B_TRONCON_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TEMP_B_TRONCON(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_B_TRONCON_fid_voie_physique_IDX ON G_BASE_VOIE.TEMP_B_TRONCON(fid_voie_physique)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_B_TRONCON_FID_METADONNEE_IDX ON G_BASE_VOIE.TEMP_B_TRONCON(fid_metadonnee)
    TABLESPACE G_ADT_INDX;

-- Cet index dispose d'une fonction permettant d'accélérer la récupération du code INSEE de la commune d'appartenance du tronçon. 
-- Il créé également un champ virtuel dans lequel on peut aller chercher ce code INSEE.
CREATE INDEX TEMP_B_TRONCON_CODE_INSEE_IDX
ON G_BASE_VOIE.TEMP_B_TRONCON(GET_CODE_INSEE_TRONCON('TEMP_B_TRONCON', geom))
TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_B_TRONCON TO G_ADMIN_SIG;

/

