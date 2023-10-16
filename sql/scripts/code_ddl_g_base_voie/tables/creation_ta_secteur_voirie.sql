/*
Cr�ation de la table des secteurs de voiries. Ces secteurs permettent au service voirie de r�partir la gestion de la voirie de la M�tropole entre ses �quipes sur le terrain.
Ils sont cr��s � partir du r�f�rentiel des communes situ�s dans le sch�ma G_REFERENTIEL et de l'ancienne table des secteur G_VOIRIE.SECTEUR_UT_TERRITOIRE.
*/

-- 1. Cr�ation de la table
CREATE TABLE G_BASE_VOIE.TA_SECTEUR_VOIRIE(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_SECTEUR_VOIRIE_OBJECTID.NEXTVAL,
    nom VARCHAR2(100),
    geom SDO_GEOMETRY
);

-- 2. Cr�ation des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_SECTEUR_VOIRIE IS 'Table contenant les secteurs de la voirie adapt�s aux limites communales pr�sentes dans G_REFERENTIEL (les g�om�tries sont topologiques). Ces secteurs servent � produire des arr�t�s pour l''am�nagement de la de voirie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SECTEUR_VOIRIE.objectid IS 'Cl� primaire auto-incr�ment�e de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SECTEUR_VOIRIE.nom IS 'Nom de chaque secteur.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SECTEUR_VOIRIE.geom IS 'Champ g�om�trique de type multipolygone.';

-- 3. Cr�ation de la cl� primaire
ALTER TABLE G_BASE_VOIE.TA_SECTEUR_VOIRIE 
ADD CONSTRAINT TA_SECTEUR_VOIRIE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Cr�ation des m�tadonn�es spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TA_SECTEUR_VOIRIE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Cr�ation de l'index spatial sur le champ geom
CREATE INDEX TA_SECTEUR_VOIRIE_SIDX
ON G_BASE_VOIE.TA_SECTEUR_VOIRIE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTIPOLYGON, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Affection des droits de lecture
GRANT SELECT ON G_BASE_VOIE.TA_SECTEUR_VOIRIE TO G_ADMIN_SIG;
GRANT SELECT ON G_BASE_VOIE.TA_SECTEUR_VOIRIE TO G_BASE_VOIE_LEC;
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_SECTEUR_VOIRIE TO G_BASE_VOIE_MAJ;

/

