/*
Création de la vue matérialisée VM_AUDIT_TEMP_B_TRONCON_NON_JOINTIF listant tous les tronçons de la table TEMP_B_TRONCON ayant un problème d''accrochage dans un rayon d''1 mètre autours de chaque entité.
*/

CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TEMP_B_TRONCON_NON_JOINTIF(
    objectid,
    geom
)
REFRESH FORCE ON DEMAND START WITH sysdate+0 NEXT TRUNC(sysdate)+43/24
DISABLE QUERY REWRITE AS
    WITH
    C_1 AS(
        SELECT
            ROWNUM,
            a.objectid AS id_1,
            b.objectid AS id_2
        FROM
            G_BASE_VOIE.TEMP_B_TRONCON a,
            G_BASE_VOIE.TEMP_B_TRONCON b
        WHERE
            a.objectid < b.objectid
            AND SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(a.geom, 0.005) = 'TRUE'
            AND SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(b.geom, 0.005) = 'TRUE'
            AND SDO_WITHIN_DISTANCE(a.geom, b.geom, 'distance = 1') = 'TRUE'
            AND SDO_ANYINTERACT(a.geom, b.geom) <> 'TRUE'
    ),
    
    C_2 AS(
        SELECT DISTINCT
            id_1 AS objectid
        FROM
            C_1
        UNION ALL
        SELECT DISTINCT
            id_2 AS objectid
        FROM
            C_1
    )

    SELECT
        a.objectid,
        a.geom
    FROM
        G_BASE_VOIE.TEMP_B_TRONCON a
        INNER JOIN C_2 b ON b.objectid = a.objectid;

-- 2. Création des commentaires de la vue matérialisée
COMMENT ON COLUMN "G_BASE_VOIE"."VM_AUDIT_TEMP_B_TRONCON_NON_JOINTIF"."OBJECTID" IS 'Identificateur unique de chaque tronçon.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_AUDIT_TEMP_B_TRONCON_NON_JOINTIF"."GEOM" IS 'Géométries de type linéaire.';
COMMENT ON MATERIALIZED VIEW "G_BASE_VOIE"."VM_AUDIT_TEMP_B_TRONCON_NON_JOINTIF"  IS 'Vue matérialisée listant tous les tronçons de la table TEMP_B_TRONCON ayant un problème d''accrochage dans un rayon d''1 mètre autours de chaque entité.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_TEMP_B_TRONCON_NON_JOINTIF 
ADD CONSTRAINT VM_AUDIT_TEMP_B_TRONCON_NON_JOINTIF_PK 
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
    'VM_AUDIT_TEMP_B_TRONCON_NON_JOINTIF',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX VM_AUDIT_TEMP_B_TRONCON_NON_JOINTIF_SIDX
ON G_BASE_VOIE.VM_AUDIT_TEMP_B_TRONCON_NON_JOINTIF(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Affection des droits de lecture
GRANT SELECT ON G_BASE_VOIE.VM_AUDIT_TEMP_B_TRONCON_NON_JOINTIF TO G_ADMIN_SIG;

/

