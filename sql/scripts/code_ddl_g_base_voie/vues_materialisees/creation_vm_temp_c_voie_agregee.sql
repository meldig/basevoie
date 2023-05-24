/*
Création de la VM VM_TEMP_C_VOIE_AGREGEE- du projet C de correction de la latéralité des voies - matérialisant le tracé des voies administratives avec son id, libellé, type code insee et l''id de la voie physique de référence.
*/

CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TEMP_C_VOIE_AGREGEE" ("ID_VOIE_ADMINISTRATIVE", "ID_VOIE_PHYSIQUE","TYPE_DE_VOIE","LIBELLE_VOIE", "CODE_INSEE", "GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
    e.objectid AS id_voie_administrative,
    c.objectid AS id_voie_physique,
    f.libelle,
    TRIM(TRIM(f.libelle) || ' ' || TRIM(e.libelle_voie) || ' ' || TRIM(e.complement_nom_voie)) AS libelle_voie,
    e.code_insee AS code_insee,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS geom
FROM
    G_BASE_VOIE.TEMP_C_TRONCON a
    INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE b ON b.fid_troncon = a.objectid
    INNER JOIN G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE c ON c.objectid = b.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = c.objectid
    INNER JOIN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE e ON e.objectid = d.fid_voie_administrative
    INNER JOIN G_BASE_VOIE.TEMP_C_TYPE_VOIE f ON f.objectid = e.fid_type_voie
GROUP BY
    c.objectid,
    e.objectid,
    f.libelle,
    TRIM(TRIM(f.libelle) || ' ' || TRIM(e.libelle_voie) || TRIM(e.complement_nom_voie)),
    e.code_insee;
    
-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_C_VOIE_AGREGEE IS 'VM matérialisant le tracé des voies administratives avec son id, libellé, type code insee et l''id de la voie physique de référence.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_C_VOIE_AGREGEE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_C_VOIE_AGREGEE 
ADD CONSTRAINT VM_TEMP_C_VOIE_AGREGEE_PK 
PRIMARY KEY (ID_VOIE_ADMINISTRATIVE);

-- 6. Création des index
CREATE INDEX VM_TEMP_C_VOIE_AGREGEE_SIDX
ON G_BASE_VOIE.VM_TEMP_C_VOIE_AGREGEE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);
/*
CREATE INDEX VM_TEMP_C_VOIE_AGREGEE_IDX ON G_BASE_VOIE.VM_TEMP_C_VOIE_AGREGEE(CODE_INSEE, TYPE_DE_VOIE, LIBELLE_VOIE, COMPLEMENT_NOM_VOIE)
    TABLESPACE G_ADT_INDX;
*/
-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_C_VOIE_AGREGEE TO G_ADMIN_SIG;

/

