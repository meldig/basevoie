/*
Création de la vue matérialisée VM_TEMP_H_VOIE_AGREGE matérialisant les voies administratives de la structure de correction H de la Base Voie.
*/
-- 1. Suppression de la VM et de ses métadonnées
/*DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_H_VOIE_AGREGE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TEMP_H_VOIE_AGREGE';
COMMIT;
*/
-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TEMP_H_VOIE_AGREGE" ("ID_VOIE", "CODE_INSEE", "NOM_VOIE","GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
    d.objectid AS id_voie_administrative,
    d.code_insee,
    TRIM(UPPER(SUBSTR(e.libelle, 1,1)) || LOWER(SUBSTR(e.libelle, 2)) || ' ' || d.libelle_voie || ' ' || d.complement_nom_voie) AS nom_voie,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS geom
FROM
    G_BASE_VOIE.TEMP_H_TRONCON a
    INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
    INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE d ON d.objectid = c.fid_voie_administrative
    INNER JOIN G_BASE_VOIE.TEMP_H_TYPE_VOIE e ON e.objectid = d.fid_type_voie
GROUP BY
    d.objectid,
    d.code_insee,
    TRIM(UPPER(SUBSTR(e.libelle, 1,1)) || LOWER(SUBSTR(e.libelle, 2)) || ' ' || d.libelle_voie || ' ' || d.complement_nom_voie)
;
    
-- 3. Création des commentaires de la VM
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_H_VOIE_AGREGE"."ID_VOIE" IS 'Clé primaire de la VM correspondant aux identifiants de chaque voie administrative.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_H_VOIE_AGREGE"."CODE_INSEE" IS 'Code INSEE de la voie administrative.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_H_VOIE_AGREGE"."NOM_VOIE" IS 'Nom de chaque voie : type de voie + nom de la voie + complément du nom.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_H_VOIE_AGREGE"."GEOM" IS 'Géométrie de type multiligne.';
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_H_VOIE_AGREGE IS 'VM matérialisant les voies administratives de la structure de correction H de la Base Voie.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_H_VOIE_AGREGE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_H_VOIE_AGREGE 
ADD CONSTRAINT VM_TEMP_H_VOIE_AGREGE_PK 
PRIMARY KEY (ID_VOIE);

-- 6. Création des index
CREATE INDEX VM_TEMP_H_VOIE_AGREGE_SIDX
ON G_BASE_VOIE.VM_TEMP_H_VOIE_AGREGE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_TEMP_H_VOIE_AGREGE_CODE_INSEE_IDX ON G_BASE_VOIE.VM_TEMP_H_VOIE_AGREGE(CODE_INSEE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_H_VOIE_AGREGE_NOM_VOIE_IDX ON G_BASE_VOIE.VM_TEMP_H_VOIE_AGREGE(NOM_VOIE)
    TABLESPACE G_ADT_INDX;
    
-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_H_VOIE_AGREGE TO G_ADMIN_SIG;

/

