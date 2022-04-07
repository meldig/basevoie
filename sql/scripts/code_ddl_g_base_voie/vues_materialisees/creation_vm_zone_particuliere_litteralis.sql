/*
Création de la VM des zones particulières pour le projet LITTERALIS.
Cette VM identifie les parties de voies dedans et en-dors des zones d'agglomération (du service DEPV(voirie)).
*/

-- 1. Suppression de la VM et de ses métadonnées
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_ZONE_PARTICULIERE_LITTERALIS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_ZONE_PARTICULIERE_LITTERALIS';
COMMIT;
*/
-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_ZONE_PARTICULIERE_LITTERALIS" ("OBJECTID", "TYPE_ZONE", "CODE_VOIE", "COTE_VOIE", "CODE_INSEE", "CATEGORIE", "GEOMETRY")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(-- Sélection des identifiants de tous les sous-éléments des géométries (multipartie et unipartie) de la table VM_ZONE_PARTICULIERE_INTERSECT_AGGLO_LITTERALIS
        SELECT
            level AS id
        FROM
            DUAL
        CONNECT BY LEVEL <=(SELECT MAX(SDO_UTIL.GETNUMELEM(geometry)) FROM G_BASE_VOIE.VM_ZONE_PARTICULIERE_INTERSECT_AGGLO_LITTERALIS)
    ),
    
    C_2 AS(
        SELECT
            a.type_zone,
            a.code_voie,
            a.cote_voie,
            a.code_insee,
            a.categorie,
            SDO_UTIL.EXTRACT(a.geometry, b.id) AS geom,
            SDO_UTIL.EXTRACT(a.geometry, b.id).sdo_gtype AS type_geom
        FROM
            G_BASE_VOIE.VM_ZONE_PARTICULIERE_INTERSECT_AGGLO_LITTERALIS a,
            C_1 b
        WHERE
            b.id<= SDO_UTIL.GETNUMELEM(a.geometry)
    ),
    
    C_3 AS(-- Sélection des identifiants de tous les sous-éléments des géométries (multipartie et unipartie) de la table VM_ZONE_PARTICULIERE_EN_AGGLO_LITTERALIS
        SELECT
            level AS id
        FROM
            DUAL
        CONNECT BY LEVEL <=(SELECT MAX(SDO_UTIL.GETNUMELEM(geometry)) FROM G_BASE_VOIE.VM_ZONE_PARTICULIERE_EN_AGGLO_LITTERALIS)
    ),
    
    C_4 AS(
        SELECT
            a.type_zone,
            a.code_voie,
            a.cote_voie,
            a.code_insee,
            a.categorie,
            SDO_UTIL.EXTRACT(a.geometry, b.id) AS geom,
            SDO_UTIL.EXTRACT(a.geometry, b.id).sdo_gtype AS type_geom
        FROM
            G_BASE_VOIE.VM_ZONE_PARTICULIERE_EN_AGGLO_LITTERALIS a,
            C_1 b
        WHERE
            b.id<= SDO_UTIL.GETNUMELEM(a.geometry)
    ),
    
    C_5 AS(-- Sélection des identifiants de tous les sous-éléments des géométries (multipartie et unipartie) de la table VM_ZONE_PARTICULIERE_HORS_AGGLO_LITTERALIS
        SELECT
            level AS id
        FROM
            DUAL
        CONNECT BY LEVEL <=(SELECT MAX(SDO_UTIL.GETNUMELEM(geometry)) FROM G_BASE_VOIE.VM_ZONE_PARTICULIERE_HORS_AGGLO_LITTERALIS)
    ),
    
    C_6 AS(
        SELECT
            a.type_zone,
            a.code_voie,
            a.cote_voie,
            a.code_insee,
            a.categorie,
            SDO_UTIL.EXTRACT(a.geometry, b.id) AS geom,
            SDO_UTIL.EXTRACT(a.geometry, b.id).sdo_gtype AS type_geom
        FROM
            G_BASE_VOIE.VM_ZONE_PARTICULIERE_HORS_AGGLO_LITTERALIS a,
            C_1 b
        WHERE
            b.id<= SDO_UTIL.GETNUMELEM(a.geometry)
    ),
    
    C_7 AS(
        SELECT
            type_zone,
            code_voie,
            cote_voie,
            code_insee,
            categorie,
            geom
        FROM
            C_2
        UNION ALL
        SELECT
            type_zone,
            code_voie,
            cote_voie,
            code_insee,
            categorie,
            geom
        FROM
            C_4
        UNION ALL
        SELECT
            type_zone,
            code_voie,
            cote_voie,
            code_insee,
            categorie,
            geom
        FROM
            C_6
    )
    
    SELECT
        rownum AS objectid,
        a.*
    FROM
        C_7 a;
      
-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_ZONE_PARTICULIERE_LITTERALIS IS 'Vue matérialisée rassemblant toutes les parties de voies en ou hors des zones d''aggolmération présentes dans SIREO_LEC. Cette VM est à utiliser UNIQUEMENT dans le cadre du projet LITTERALIS (prestataire SOGELINK).';

-- 2. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_ZONE_PARTICULIERE_LITTERALIS',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_ZONE_PARTICULIERE_LITTERALIS 
ADD CONSTRAINT VM_ZONE_PARTICULIERE_LITTERALIS_PK 
PRIMARY KEY (OBJECTID);

-- 4. Création de l'index spatial
CREATE INDEX VM_ZONE_PARTICULIERE_LITTERALIS_SIDX
ON G_BASE_VOIE.VM_ZONE_PARTICULIERE_LITTERALIS(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=LINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 5. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_ZONE_PARTICULIERE_LITTERALIS TO G_ADMIN_SIG;

/

