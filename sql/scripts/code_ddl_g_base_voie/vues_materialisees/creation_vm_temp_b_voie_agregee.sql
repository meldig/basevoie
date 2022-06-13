/*
Création d'une vue matérialisée matérialisant la géométrie des voies depuis les tables de la structure B de correction de la base voie.
*/
-- 1. Suppression de la VM et de ses métadonnées
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_B_VOIE_AGREGEE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TEMP_B_VOIE_AGREGEE';
COMMIT;
*/

-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TEMP_B_VOIE_AGREGEE" ("ID_VOIE_PHYSIQUE", "ID_VOIE_ADMINISTRATIVE", "CODE_INSEE", "LATERALITE", "LIBELLE_VOIE", "GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
    SELECT
        c.objectid AS id_voie_physique,
        d.objectid AS id_voie_administrative,
        d.code_insee,
        f.libelle_court AS lateralite,
        TRIM(UPPER(e.libelle)) ||' '|| TRIM(UPPER(d.libelle_voie)) ||' '|| TRIM(UPPER(d.complement_nom_voie)) AS libelle_voie,               
        SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS geom
    FROM
        G_BASE_VOIE.TEMP_B_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE b ON b.fid_troncon = a.objectid
        INNER JOIN G_BASE_VOIE.TEMP_B_VOIE_PHYSIQUE c ON c.objectid = b.fid_voie_physique
        INNER JOIN G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE d ON d.fid_voie_physique = c.objectid
        INNER JOIN G_BASE_VOIE.TEMP_B_TYPE_VOIE e ON e.objectid = d.fid_type_voie
        INNER JOIN G_BASE_VOIE.TEMP_B_LIBELLE f ON f.objectid = d.fid_lateralite
    GROUP BY
        c.objectid,
        d.objectid,
        d.code_insee,
        f.libelle_court,
        TRIM(UPPER(e.libelle)) ||' '|| TRIM(UPPER(d.libelle_voie)) ||' '|| TRIM(UPPER(d.complement_nom_voie));
    
-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_B_VOIE_AGREGEE IS 'Vue matérialisée matérialisant la géométrie des voies depuis les tables de la structure B de correction de la base voie.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_B_VOIE_AGREGEE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_B_VOIE_AGREGEE 
ADD CONSTRAINT VM_TEMP_B_VOIE_AGREGEE_PK 
PRIMARY KEY (ID_VOIE_ADMINISTRATIVE);

-- 6. Création des index
CREATE INDEX VM_TEMP_B_VOIE_AGREGEE_SIDX
ON G_BASE_VOIE.VM_TEMP_B_VOIE_AGREGEE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);
    
CREATE INDEX VM_TEMP_B_VOIE_AGREGEE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_TEMP_B_VOIE_AGREGEE(LIBELLE_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_B_VOIE_AGREGEE_CODE_INSEE_IDX ON G_BASE_VOIE.VM_TEMP_B_VOIE_AGREGEE(CODE_INSEE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_B_VOIE_AGREGEE_ID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.VM_TEMP_B_VOIE_AGREGEE(ID_VOIE_PHYSIQUE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_B_VOIE_AGREGEE_LATERALITE_IDX ON G_BASE_VOIE.VM_TEMP_B_VOIE_AGREGEE(LATERALITE)
    TABLESPACE G_ADT_INDX;
    
-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_B_VOIE_AGREGEE TO G_ADMIN_SIG;

/

