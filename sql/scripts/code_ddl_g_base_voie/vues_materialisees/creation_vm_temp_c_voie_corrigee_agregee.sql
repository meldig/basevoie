/*
création de la VM VM_TEMP_C_VOIE_CORRIGEE_AGREGEE - du projet C de correction de la latéralité des voies - matérialisant la géométrie des voies administratrives partageant la même voie physique.
*/
-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TEMP_C_VOIE_CORRIGEE_AGREGEE" ("ID_VOIE_ADMINISTRATIVE","ID_VOIE_PHYSIQUE","LIBELLE_VOIE","LATERALITE", "CODE_INSEE", "GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
    f.objectid AS id_voie_administrative,
    d.objectid AS id_voie_physique,
    TRIM(TRIM(g.libelle) || ' ' || TRIM(f.libelle_voie) || ' '  || TRIM(f.complement_nom_voie)) AS libelle_voie,
    h.libelle_long AS lateralite,
    f.code_insee,
    SDO_AGGR_UNION(
        SDOAGGRTYPE(b.geom, 0.005)
    ) AS geom
FROM
    G_BASE_VOIE.TEMP_C_TRONCON b
    INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE c ON c.fid_troncon = b.objectid
    INNER JOIN G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE d ON d.objectid = c.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE e ON e.fid_voie_physique = d.objectid
    INNER JOIN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE f ON f.objectid = e.fid_voie_administrative
    INNER JOIN G_BASE_VOIE.TEMP_C_TYPE_VOIE g ON g.objectid = f.fid_type_voie
    INNER JOIN G_BASE_VOIE.TEMP_C_LIBELLE h ON h.objectid = f.fid_lateralite
WHERE
    d.objectid > 6700320
GROUP BY
    d.objectid,
    f.objectid,
    TRIM(TRIM(g.libelle) || ' ' || TRIM(f.libelle_voie) || ' '  || TRIM(f.complement_nom_voie)),
    h.libelle_long,
    f.code_insee;

-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_C_VOIE_CORRIGEE_AGREGEE IS 'VM matérialisant la géométrie des voies administratrives partageant la même voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_C_VOIE_CORRIGEE_AGREGEE.ID_VOIE_ADMINISTRATIVE IS 'Identifiant de la voie administrative présente dans TEMP_C_VOIE_ADMINISTRATIVE.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_C_VOIE_CORRIGEE_AGREGEE.ID_VOIE_PHYSIQUE IS 'Identifiant de la voie physique présente dans TEMP_C_VOIE_PHYSIQUE.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_C_VOIE_CORRIGEE_AGREGEE.LIBELLE_VOIE IS 'Libelle des voies administratives présentes dans la table TEMP_C_VOIE_ADMINISTRATIVE.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_C_VOIE_CORRIGEE_AGREGEE.LATERALITE IS 'Latéralité des voies administratives par rapport à leur voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_C_VOIE_CORRIGEE_AGREGEE.CODE_INSEE IS 'Code INSEE des voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_C_VOIE_CORRIGEE_AGREGEE.GEOM IS 'Géométrie de type multiligne des voies administratives.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_C_VOIE_CORRIGEE_AGREGEE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_C_VOIE_CORRIGEE_AGREGEE 
ADD CONSTRAINT VM_TEMP_C_VOIE_CORRIGEE_AGREGEE_PK 
PRIMARY KEY (ID_VOIE_ADMINISTRATIVE);

-- 6. Création des index
CREATE INDEX VM_TEMP_C_VOIE_CORRIGEE_AGREGEE_SIDX
ON G_BASE_VOIE.VM_TEMP_C_VOIE_CORRIGEE_AGREGEE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_TEMP_C_VOIE_CORRIGEE_AGREGEE_ID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.VM_TEMP_C_VOIE_CORRIGEE_AGREGEE(ID_VOIE_PHYSIQUE)
    TABLESPACE G_ADT_INDX;

-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_C_VOIE_CORRIGEE_AGREGEE TO G_ADMIN_SIG;

/

