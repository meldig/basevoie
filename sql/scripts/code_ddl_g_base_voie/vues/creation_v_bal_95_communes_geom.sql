/*
Création de la vue V_BAL_95_COMMUNES_GEOM proposant la base adresse locale de la MEL sur 95 communes avec la géométrie des seuils.
*/
/*
DROP VIEW G_BASE_VOIE.V_BAL_95_COMMUNES_GEOM;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'V_BAL_95_COMMUNES_GEOM';
COMMIT;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM" ("UID_ADRESSE", "CLE_INTEROP", "COMMUNE_INSEE", "COMMUNE_NOM", "COMMUNE_DELEGUEE_INSEE", "COMMUNE_DELEGUEE_NOM", "VOIE_NOM", "LIEUDIT_COMPLEMENT_NOM", "NUMERO", "SUFFIXE", "POSITION", "X", "Y", "LONG", "LAT", "CAD_PARCELLES", "SOURCE", "DATE_DER_MAJ", "CERTIFICATION_COMMUNE", "GEOM", 
CONSTRAINT "V_BAL_95_COMMUNES_GEOM_PK" PRIMARY KEY ("UID_ADRESSE") DISABLE) AS 
    SELECT
        a.UID_ADRESSE,
        a.CLE_INTEROP,
        a.COMMUNE_INSEE,
        a.COMMUNE_NOM,
        a.COMMUNE_DELEGUEE_INSEE,
        a.COMMUNE_DELEGUEE_NOM,
        TRIM(UPPER(a.VOIE_NOM)) AS VOIE_NOM,
        a.LIEUDIT_COMPLEMENT_NOM,
        a.NUMERO,
        a.SUFFIXE,
        a."POSITION",
        a.X,
        a.Y,
        a."LONG",
        a.LAT,
        TRIM(a.CAD_PARCELLES),
        a."SOURCE",
        a.DATE_DER_MAJ,
        a.CERTIFICATION_COMMUNE,
        c.geom
    FROM
        G_BASE_VOIE.VM_BAN_VERSION_1_3 a
        INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL b ON b.objectid = a.uid_adresse
        INNER JOIN G_BASE_VOIE.TA_SEUIL c ON c.objectid = b.fid_seuil;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_BAL_95_COMMUNES_GEOM  IS 'Vue proposant la base adresse locale de la MEL sur 95 communes avec la géométrie des seuils.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."UID_ADRESSE" IS 'Identifiant unique d''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."CLE_INTEROP" IS 'Clé d''interopérabilité: INSSE + _ + FANTOIR + _ + numéro d''adresse + _ + suffixe. Le tout en minuscule';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."COMMUNE_INSEE" IS 'Code INSEE de la commune d''implantation de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."COMMUNE_NOM" IS 'Nom de la commune d''implantation de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."COMMUNE_DELEGUEE_INSEE" IS 'Code INSEE de la commune déléguée d''implantation de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."COMMUNE_DELEGUEE_NOM" IS 'Nom de la commune déléguée d''implantation de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."VOIE_NOM" IS 'Nom de la voie';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."LIEUDIT_COMPLEMENT_NOM" IS 'nom du lieu-dit historique ou complémentaire';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."NUMERO" IS 'Numéro de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."SUFFIXE" IS 'Suffixe de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."POSITION" IS 'Position de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."X" IS 'Coordonnée X';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."Y" IS 'Coordonnée Y';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."LONG" IS 'Longitude';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."LAT" IS 'Latitude';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."CAD_PARCELLES" IS 'Liste des parcelles représentées par l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."SOURCE" IS 'Source de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."DATE_DER_MAJ" IS 'Date de la dernière mise à jour';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."CERTIFICATION_COMMUNE" IS 'Certification communale: 0, adresse non certifiée par la commune, 1, adresse certifiée par la commune';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_95_COMMUNES_GEOM"."GEOM" IS 'Champ géométrique de type point contenant la géométrie de chaque seuil.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_BAL_95_COMMUNES_GEOM',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 3. Création du droit de lecture
GRANT SELECT ON G_BASE_VOIE.V_BAL_95_COMMUNES_GEOM TO G_ADMIN_SIG;
GRANT SELECT ON G_BASE_VOIE.V_BAL_95_COMMUNES_GEOM TO G_BASE_VOIE_R;

/

