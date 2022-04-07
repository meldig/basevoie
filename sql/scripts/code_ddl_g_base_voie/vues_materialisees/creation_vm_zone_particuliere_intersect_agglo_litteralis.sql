/*
Création de la VM VM_ZONE_PARTICULIERE_INTERSECT_AGGLO_LITTERALIS rassemblant les parties de voies contenues dans une zone d'agglomération
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_ZONE_PARTICULIERE_INTERSECT_AGGLO_LITTERALIS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_ZONE_PARTICULIERE_INTERSECT_AGGLO_LITTERALIS';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_ZONE_PARTICULIERE_INTERSECT_AGGLO_LITTERALIS(OBJECTID, TYPE_ZONE, CODE_VOIE, COTE_VOIE, CODE_INSEE, CATEGORIE, GEOMETRY)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
    SELECT
        rownum AS objectid,
        'Agglomération' AS type_zone,
        b.id_voie AS code_voie,
        'LesDeuxCotes' AS cote_voie,
        b.insee AS code_insee,
       0 AS categorie,
       SDO_GEOM.SDO_INTERSECTION(b.geom, c.geom, 0.005) AS geometry
    FROM
        G_BASE_VOIE.VM_VOIE_AGGREGEE_LITTERALIS b,
        G_BASE_VOIE.VM_ZONE_AGGLOMERATION c
    WHERE
        SDO_RELATE(b.geom, c.geom, 'mask=OVERLAPBDYDISJOINT+OVERLAPBDYINTERSECT') = 'TRUE';

-- 2. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_ZONE_PARTICULIERE_INTERSECT_AGGLO_LITTERALIS IS 'Vue matérialisée - pour le projet LITTERALIS - regroupant toutes les voies ou les parties de voies intersectant la zone d''agglomération.';

-- 3. Remplissage des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_ZONE_PARTICULIERE_INTERSECT_AGGLO_LITTERALIS',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_ZONE_PARTICULIERE_INTERSECT_AGGLO_LITTERALIS 
ADD CONSTRAINT VM_ZONE_PARTICULIERE_INTERSECT_AGGLO_LITTERALIS_PK 
PRIMARY KEY (OBJECTID);

-- 5. Création de l'index spatial
CREATE INDEX VM_ZONE_PARTICULIERE_INTERSECT_AGGLO_LITTERALIS_SIDX
ON G_BASE_VOIE.VM_ZONE_PARTICULIERE_INTERSECT_AGGLO_LITTERALIS(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 6. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_ZONE_PARTICULIERE_INTERSECT_AGGLO_LITTERALIS TO G_ADMIN_SIG;

/

