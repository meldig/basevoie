/*
Création de la vue matérialisée G_BASE_VOIE.VM_TERRITOIRE_VOIRIE qui regroupe les secteurs de voirie par territoire de voirie.
ATTENTION : ces territoires sont différents des territoires du référentiel administratif du schéma G_REFERENTIEL.
*/
-- Suppression de la VM
/*
DROP INDEX VM_TERRITOIRE_VOIRIE_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TERRITOIRE_VOIRIE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TERRITOIRE_VOIRIE';
COMMIT;
*/
-- 1. Création de la vue matérialisée
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TERRITOIRE_VOIRIE(
    identifiant,
    nom,
    type,
    geometry
)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
    1,
    'UTLS 1' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'LILLE OUEST',
        'LILLE SUD'
    )
UNION ALL
SELECT
    2,
    'UTLS 2' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'LILLE NORD',
        'LILLE CENTRE'
    )
UNION ALL
SELECT
    3,
    'UTLS 3' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'RONCHIN',
        'COURONNE SUD'
    )
UNION ALL
SELECT
    4,
    'UTLS 4' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'CCHD-SECLIN',
        'COURONNE OUEST'
    )
UNION ALL
SELECT
    5,
    'UTML 1' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'HAUBOURDIN',
        'WAVRIN',
        'BASSEEN'
    )
UNION ALL
SELECT
    6,
    'UTML 2' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'WEPPES',
        'MARCQUOIS'
    )
UNION ALL
SELECT
    7,
    'UTML 3' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'LAMBERSART',
        'WAMBRECHIES'
    )
UNION ALL
SELECT
    8,
    'UTRV 1' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'WATTRELOS',
        'ROUBAIX OUEST',
        'ROUBAIX EST'
    )
UNION ALL
SELECT
    9,
    'UTRV 2' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'CROIX',
        'LANNOY',
        'LEERS'
    )
UNION ALL
SELECT
    10,
    'UTRV 3' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'VA OUEST',
        'VA EST',
        'MELANTOIS'
    )
UNION ALL
SELECT
    11,
    'UTTA 1' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'ARMENTIERES',
        'HOUPLINES'
    )
UNION ALL
SELECT
    12,
    'UTTA 2' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'COMINES HALLUIN',
        'BONDUES'
    )
UNION ALL
SELECT
    13,
    'UTTA 3' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'TOURCOING NORD',
        'TOURCOING SUD',
        'MOUVAUX-NEUVILLE'
    );

-- 2. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TERRITOIRE_VOIRIE',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TERRITOIRE_VOIRIE 
ADD CONSTRAINT VM_TERRITOIRE_VOIRIE_PK 
PRIMARY KEY (IDENTIFIANT);

-- 4. Création de l'index spatial
CREATE INDEX VM_TERRITOIRE_VOIRIE_SIDX
ON G_BASE_VOIE.VM_TERRITOIRE_VOIRIE(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTIPOLYGON, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 5. Création des commentaires de table et de colonnes
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TERRITOIRE_VOIRIE IS 'Vue matérialisée proposant les Territoires de la voirie. ATTENTION : ces territoires sont différents des territoires du référentiel administratif du schéma G_REFERENTIEL.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TERRITOIRE_VOIRIE.identifiant IS 'Clé primaire de chaque enregistrement.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TERRITOIRE_VOIRIE.nom IS 'Nom de chaque territoire.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TERRITOIRE_VOIRIE.geometry IS 'géométries des Territoires.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TERRITOIRE_VOIRIE.type IS 'Type de regroupement.';

/

