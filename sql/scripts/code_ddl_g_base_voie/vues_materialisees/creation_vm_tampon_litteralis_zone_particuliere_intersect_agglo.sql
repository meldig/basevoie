/*
Création de la VM VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO- pour le projet LITTERALIS - regroupant toutes les parties de voie intersectant une agglomération.
*/
/*
DROP INDEX VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO';
COMMIT;
*/

CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO(
    OBJECTID, 
    TYPE_ZONE, 
    CODE_VOIE, 
    COTE_VOIE, 
    CODE_INSEE, 
    CATEGORIE, 
    GEOMETRY
)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH C_1 AS( -- Pour toutes les voies intersectant les zones d'agglomération, on sélectionne uniquement la partie située à l''intérieur des zones
        SELECT
            'Agglomeration' AS type_zone,
            a.id_voie_administrative AS code_voie,
            CASE
                WHEN a.lateralite = 'droit'
                    THEN 'Droit'
                WHEN a.lateralite = 'gauche'
                    THEN 'Gauche'
                WHEN a.lateralite = 'les deux côtés'
                    THEN 'LesDeuxCotes' 
                END AS cote_voie,
            a.code_insee,
            0 AS categorie,
           SDO_GEOM.SDO_INTERSECTION(a.geom, b.geom, 0.005) AS geometry
        FROM
            G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE a,
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION b
        WHERE
            SDO_GEOM.SDO_INTERSECTION(a.geom, b.geom, 0.005).sdo_gtype IN(2002, 2006)
            AND SDO_RELATE(a.geom, b.geom, 'mask=OVERLAPBDYDISJOINT+OVERLAPBDYINTERSECT') = 'TRUE'
    ),

    C_2 AS(
        SELECT
            rownum AS objectid,
            type_zone,
            code_voie,
            cote_voie,
            code_insee,
            categorie,
            geometry
        FROM
            C_1
    ),

    C_3 AS(
        SELECT
            MIN(objectid) AS objectid,
            type_zone,
            code_voie,
            cote_voie,
            code_insee,
            categorie
        FROM
            C_2
        GROUP BY
            type_zone,
            code_voie,
            cote_voie,
            code_insee,
            categorie
    )

    SELECT
        rownum AS objectid,
        CAST(a.type_zone AS VARCHAR2(254)) AS type_zone,
        CAST(a.code_voie AS VARCHAR2(254)) AS code_voie,
        CAST(a.cote_voie AS VARCHAR2(254)) AS cote_voie,
        CAST(a.code_insee AS VARCHAR2(254)) AS code_insee,
        CAST(a.categorie AS NUMBER(8)) AS categorie,
        a.geometry
    FROM
        C_2 a
        INNER JOIN C_3 b ON b.objectid = a.objectid;

-- 2. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO IS 'Vue matérialisée - pour le projet LITTERALIS - regroupant toutes les parties de voie intersectant une agglomération.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO.OBJECTID IS 'Clé primaire de la vue matérialisée.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO.TYPE_ZONE IS 'Type de zone : Agglomeration ; InteretCommunautaire';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO.CODE_VOIE IS 'Liaison avec la classe TRONCON sur la colonne CODE_RUE_G ou CODE_RUE_D';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO.COTE_VOIE IS 'Définit sur quel côté de la voie s’appuie la zone particulière : LesDeuxCotes, Gauche, Droit.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO.CODE_INSEE IS 'Code INSEE de la commune. Obligatoire pour les entrées Commune et Agglomeration.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO.CATEGORIE IS 'Valeur définissant la catégorie de la rue sur cette zone';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO.GEOMETRY IS 'Géométrie de type multiligne.';

-- 3. Remplissage des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO 
ADD CONSTRAINT VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO_PK 
PRIMARY KEY (OBJECTID);

-- 5. Création de l'index spatial
CREATE INDEX VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO_SIDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 6. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO TO G_ADMIN_SIG;

/

