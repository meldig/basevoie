/*
Création de la vue V_TRONCON_VOIE_GRU rassemblant les voies , leur code insee, leur identifiant et leur nom. pour la Gestion des Relations des Usagers (GRU).
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE EDITIONABLE VIEW "G_BASE_VOIE"."V_TRONCON_VOIE_GRU" ("ID_VOIE", "NOM_VOIE", "CODE_INSEE", "GEOM", 
CONSTRAINT "V_TRONCON_VOIE_GRU_PK" PRIMARY KEY ("ID_VOIE") DISABLE) AS 
  SELECT
    a.id_voie,
    TRIM(UPPER(a.type_de_voie) || ' ' || UPPER(a.libelle_voie) || ' ' || UPPER(a.complement_nom_voie)) AS nom_voie,
    CAST(TRIM(GET_CODE_INSEE_97_COMMUNES_TRONCON('VM_VOIE_AGGREGEE', a.geom)) AS VARCHAR2(8 BYTE)) AS code_insee,
    a.geom
  FROM
    G_BASE_VOIE.VM_VOIE_AGGREGEE a;

-- 2. Création des commentaires
COMMENT ON TABLE "G_BASE_VOIE"."V_TRONCON_VOIE_GRU"  IS 'Vue regroupant les voies , leur code insee, leur identifiant et leur nom pour la Gestion des Relations des Usagers (GRU).';
COMMENT ON COLUMN "G_BASE_VOIE"."V_TRONCON_VOIE_GRU"."ID_VOIE" IS 'Identifiant unique et immuable de la voie servant de clé primaire à la vue.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_TRONCON_VOIE_GRU"."NOM_VOIE" IS 'Nom de la voie comportant le type, le nom et le complément de nom de la voie.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_TRONCON_VOIE_GRU"."CODE_INSEE" IS 'Code INSEE de la voie à laquelle appartient le tronçon, calculé sur les 97 communes (dont Hellemmes-lille et Lomme).';
COMMENT ON COLUMN "G_BASE_VOIE"."V_TRONCON_VOIE_GRU"."GEOM" IS 'Géométrie de chaque voie de type multi-ligne.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_TRONCON_VOIE_GRU',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création des droits de lecture
GRANT SELECT ON G_BASE_VOIE.V_TRONCON_VOIE_GRU TO G_ADMIN_SIG;
GRANT SELECT ON G_BASE_VOIE.V_TRONCON_VOIE_GRU TO G_BASE_VOIE_LEC;

/

