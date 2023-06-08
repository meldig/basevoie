/*
Création de la vue matérialisée VM_TAMPON_LITTERALIS_REGROUPEMENT - regroupant regroupements administratifs territoriaux pour le projet LITTERALIS du service voirie.
*/
-- Suppression de la VM
/*
DROP INDEX VM_TAMPON_LITTERALIS_REGROUPEMENT_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TAMPON_LITTERALIS_REGROUPEMENT';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT (
    CODE_REGR, 
    NOM, 
    CODE_INSEE, 
    TYPE, 
    GEOMETRY
)        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
    WITH
        C_1 AS(
            SELECT
                TRIM(UPPER(SUBSTR(a.nom, 0, 1)) || LOWER(SUBSTR(a.nom, 2, LENGTH(a.nom)))) AS nom,
                'Zone' AS TYPE,
                '' AS code_insee,
                a.geom AS geometry
            FROM
                G_BASE_VOIE.TA_SECTEUR_VOIRIE a
            UNION ALL
            SELECT
                TRIM(UPPER(SUBSTR(nom, 0, 1)) || LOWER(SUBSTR(nom, 2, LENGTH(nom)))) AS nom,
                'Zone' AS type,
                '' AS code_insee,
                geometry
            FROM
                G_BASE_VOIE.VM_TERRITOIRE_VOIRIE
            UNION ALL
            SELECT
                TRIM(UPPER(SUBSTR(nom, 0, 1)) || LOWER(SUBSTR(nom, 2, LENGTH(nom)))) AS nom,
                'Zone' AS type,
                '' AS code_insee,
                geometry
            FROM
                G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE
        )
    SELECT
        CAST(ROWNUM AS VARCHAR2(254 BYTE)) AS code_regr,
        CAST(a.nom AS VARCHAR2(254 BYTE)) AS nom,
        CAST(a.code_insee AS VARCHAR2(254 BYTE)) AS code_insee,
        CAST(a.type AS VARCHAR2(254 BYTE)) AS type,
        a.geometry
    FROM
        C_1 a;

-- 2. Création des commentaires de la vue matérialisée
COMMENT ON MATERIALIZED VIEW "G_BASE_VOIE"."VM_TAMPON_LITTERALIS_REGROUPEMENT"  IS 'Vue matérialisée des regroupements administratifs territoriaux pour le projet LITTERALIS du service voirie.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TAMPON_LITTERALIS_REGROUPEMENT"."CODE_REGR" IS 'Identificateur unique et immuable du regroupement partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TAMPON_LITTERALIS_REGROUPEMENT"."NOM" IS 'Nom du regroupement.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TAMPON_LITTERALIS_REGROUPEMENT"."CODE_INSEE" IS 'Code INSEE de la commune. Etant donné que les secteurs (regoupements à partir desquels tous les autres sont construits) peuvent recouvrir une partie de commune (Lille) il a été décidé avec le prestataire de ne mettre aucun code INSEE.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TAMPON_LITTERALIS_REGROUPEMENT"."TYPE" IS 'Type de regroupement. A la demande du prestataire, le type est "Zone" pour tous les types de regroupements (sous-territoires, territoires, unités territoriales) afin que les données s''insèrent correctement dans leur application... Bref.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TAMPON_LITTERALIS_REGROUPEMENT"."GEOMETRY" IS 'Géométries de type surfacique.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT 
ADD CONSTRAINT VM_TAMPON_LITTERALIS_REGROUPEMENT_PK 
PRIMARY KEY("CODE_REGR") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TAMPON_LITTERALIS_REGROUPEMENT',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création des index
CREATE INDEX VM_TAMPON_LITTERALIS_REGROUPEMENT_SIDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTIPOLYGON, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

CREATE INDEX VM_TAMPON_LITTERALIS_REGROUPEMENT_NOM_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT(NOM)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_REGROUPEMENT_CODE_INSEE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT(CODE_INSEE)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_REGROUPEMENT_TYPE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT(TYPE)
TABLESPACE G_ADT_INDX;

-- 6. Affection des droits de lecture
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT TO G_ADMIN_SIG;

/


