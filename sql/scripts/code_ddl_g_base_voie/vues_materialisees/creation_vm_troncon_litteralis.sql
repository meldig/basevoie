/*
Création de la vue matérialisée VM_TRONCON_LITTERALIS regroupant, au format LITTERALIS, toutes les TRONCONs de la base présentes
dans les tables TEMP_TRONCON_CORRECTE_LITTERALIS, TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS, TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS, TEMP_TRONCON_AUTRES_LITTERALIS.
Cette VM est utilisée pour exporter les données pour le prestataire Sogelink.
*/

-- 1. Suppression de la VM et de ses métadonnées
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TRONCON_LITTERALIS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TRONCON_LITTERALIS';
COMMIT;

-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TRONCON_LITTERALIS" ("CODE_TRONC","CLASSEMENT","CODE_RUE_G","NOM_RUE_G","INSEE_G","CODE_RUE_D","NOM_RUE_D","INSEE_D","LARGEUR","GEOMETRY")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
        CODE_TRONC,
        CLASSEMENT,
        CODE_RUE_G,
        NOM_RUE_G,
        INSEE_G,
        CODE_RUE_D,
        NOM_RUE_D,
        INSEE_D,
        LARGEUR,
        GEOMETRY
    FROM
        G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS
    UNION ALL
    SELECT
        CODE_TRONC,
        CLASSEMENT,
        CODE_RUE_G,
        NOM_RUE_G,
        INSEE_G,
        CODE_RUE_D,
        NOM_RUE_D,
        INSEE_D,
        LARGEUR,
        GEOMETRY
    FROM
        G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS
    UNION ALL
    SELECT
        CODE_TRONC,
        CLASSEMENT,
        CODE_RUE_G,
        NOM_RUE_G,
        INSEE_G,
        CODE_RUE_D,
        NOM_RUE_D,
        INSEE_D,
        LARGEUR,
        GEOMETRY
    FROM
        G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS;

-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TRONCON_LITTERALIS IS 'Vue matérialisée rassemblant toutes les associations tronçons/voies au format LITTERALIS. Cette VM est utilisée pour exporter les données pour le projet LITTERALIS mené par le service voirie et le prestataire SOGELINK.';

-- 2. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TRONCON_LITTERALIS',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TRONCON_LITTERALIS 
ADD CONSTRAINT VM_TRONCON_LITTERALIS_PK 
PRIMARY KEY (CODE_TRONC);

-- 4. Création de l'index spatial
CREATE INDEX VM_TRONCON_LITTERALIS_SIDX
ON G_BASE_VOIE.VM_TRONCON_LITTERALIS(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 5. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TRONCON_LITTERALIS TO G_ADMIN_SIG;

/

