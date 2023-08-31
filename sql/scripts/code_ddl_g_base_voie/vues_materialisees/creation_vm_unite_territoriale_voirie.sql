/*
Création de la vue matérialisée VM_UNITE_TERRITORIALE_VOIRIE proposant les Unités Territoriales de la voirie.
*/
-- Suppression de la VM
/*
DROP INDEX VM_UNITE_TERRITORIALE_VOIRIE_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_UNITE_TERRITORIALE_VOIRIE';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE (
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
    C_1 AS(-- Création de l'UT LS
    SELECT
        SUBSTR(a.nom, 0, 4) AS NOM,
        'Unité Territoriale' AS TYPE,
        SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS GEOMETRY
    FROM
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE a
    WHERE
        a.identifiant IN(1, 2, 3)
    GROUP BY
        SUBSTR(a.nom, 0, 4),
        'Unité Territoriale'
    ),

    C_2 AS(
    SELECT
        SUBSTR(a.nom, 0, 4) AS NOM, 
        'Unité Territoriale' AS TYPE,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        C_1 a,
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE b
    WHERE
        b.identifiant = 4
    ),
    
    C_3 AS(-- Création de l'UT ML
    SELECT
        SUBSTR(a.nom, 0, 4) AS NOM, 
        'Unité Territoriale' AS TYPE,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE a,
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE b
    WHERE
        a.identifiant = 5
        AND b.identifiant = 6
    ),
    
    C_4 AS(
    SELECT
        SUBSTR(a.nom, 0, 4) AS NOM, 
        'Unité Territoriale' AS TYPE,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        C_3 a,
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE b
    WHERE
        b.identifiant = 7
    ),
    
    C_5 AS(-- Création de l'UT RV
    SELECT
        SUBSTR(a.nom, 0, 4) AS NOM, 
        'Unité Territoriale' AS TYPE,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE a,
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE b
    WHERE
        a.identifiant = 8
        AND b.identifiant = 9
    ),
    
    C_6 AS(
    SELECT
        SUBSTR(a.nom, 0, 4) AS NOM, 
        'Unité Territoriale' AS TYPE,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        C_5 a,
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE b
    WHERE
        b.identifiant = 10
    ),
    
    C_7 AS(-- Création de l'UT TA
    SELECT
        SUBSTR(a.nom, 0, 4) AS NOM, 
        'Unité Territoriale' AS TYPE,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE a,
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE b
    WHERE
        a.identifiant = 11
        AND b.identifiant = 12
    ),
    
    C_8 AS(
    SELECT
        SUBSTR(a.nom, 0, 4) AS NOM, 
        'Unité Territoriale' AS TYPE,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        C_7 a,
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE b
    WHERE
        b.identifiant = 13
    )
    
    SELECT
        1 AS identifiant,
        nom,
        type,
        geometry
    FROM
        C_2
    UNION ALL
    SELECT
        2 AS identifiant,
        nom,
        type,
        geometry
    FROM
        C_4
    UNION ALL
    SELECT
        3 AS identifiant,
        nom,
        type,
        geometry
    FROM
        C_6
    UNION ALL
    SELECT
        4 AS identifiant,
        nom,
        type,
        geometry
    FROM
        C_8;

-- 2. Création des commentaires de la vue matérialisée
COMMENT ON MATERIALIZED VIEW "G_BASE_VOIE"."VM_UNITE_TERRITORIALE_VOIRIE"  IS 'Vue matérialisée proposant les Unités Territoriales de la voirie.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_UNITE_TERRITORIALE_VOIRIE"."IDENTIFIANT" IS 'Clé primaire de chaque enregistrement.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_UNITE_TERRITORIALE_VOIRIE"."NOM" IS 'Nom de chaque Unité Territoriale.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_UNITE_TERRITORIALE_VOIRIE"."TYPE" IS 'Type de regroupement.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_UNITE_TERRITORIALE_VOIRIE"."GEOMETRY" IS 'géométries des Unités Territoriales.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE 
ADD CONSTRAINT VM_UNITE_TERRITORIALE_VOIRIE_PK 
PRIMARY KEY("IDENTIFIANT") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_UNITE_TERRITORIALE_VOIRIE',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création des index
CREATE INDEX VM_UNITE_TERRITORIALE_VOIRIE_SIDX
ON G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE (GEOMETRY) 
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS ('sdo_indx_dims=2, layer_gtype=MULTIPOLYGON, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

CREATE INDEX VM_UNITE_TERRITORIALE_VOIRIE_NOM_IDX
ON G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE(NOM)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_UNITE_TERRITORIALE_VOIRIE_TYPE_IDX
ON G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE(TYPE)
TABLESPACE G_ADT_INDX;

-- 6. Affection des droits de lecture
GRANT SELECT ON G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE TO G_ADMIN_SIG;

/   

