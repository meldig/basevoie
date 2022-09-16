/*
Création de la VM VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES - du projet C de correction de la latéralité des voies - identifiant les tronçons affectés à plusieurs voies dans la structure de correction de la Base du voie projet C. Cette VM est uniquement à utiliser dans le cadre de la correction des tronçons affectés à plusieurs voies physiques.
*/

CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES" ("OBJECTID", "ID_TRONCON", "ID_VOIE_PHYSIQUE", "ID_VOIE_ADMINISTRATIVE", "LIBELLE_VOIE", "LATERALITE", "CODE_INSEE", "GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(
        SELECT
                fid_troncon
            FROM
                G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE
            GROUP BY
                fid_troncon
            HAVING
                COUNT(fid_troncon) > 1
    )
    
    SELECT
        ROWNUM AS objectid,
        b.objectid AS id_troncon,
        d.objectid AS id_voie_physique,
        f.objectid AS id_voie_administrative,
        TRIM(TRIM(g.libelle) || ' ' || TRIM(f.libelle_voie) || ' ' || TRIM(f.complement_nom_voie)) AS libelle_voie,
        h.libelle_long AS lateralite,
        f.code_insee,
        b.geom
    FROM
        C_1 a
        INNER JOIN G_BASE_VOIE.TEMP_C_TRONCON b ON b.objectid = a.fid_troncon
        INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE c ON c.fid_troncon = b.objectid
        INNER JOIN G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE d ON d.objectid = c.fid_voie_physique
        INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE e ON e.fid_voie_physique = d.objectid
        INNER JOIN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE f ON f.objectid = e.fid_voie_administrative
        INNER JOIN G_BASE_VOIE.TEMP_C_TYPE_VOIE g ON g.objectid = f.fid_type_voie
        INNER JOIN G_BASE_VOIE.TEMP_C_LIBELLE h ON h.objectid = f.fid_lateralite;
    
-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES IS 'Vue identifiant les tronçons affectés à plusieurs voies dans la structure de correction de la Base du voie projet C. Cette VM est uniquement à utiliser dans le cadre de la correction des tronçons affectés à plusieurs voies physiques.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES"."OBJECTID" IS 'Clé primaire de la vue.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES"."ID_TRONCON" IS 'Identifiant des tronçons.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES"."ID_VOIE_PHYSIQUE" IS 'Identifiant des voies physiques.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES"."ID_VOIE_ADMINISTRATIVE" IS 'Identifiant des voies administratives.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES"."LIBELLE_VOIE" IS 'Nom de la voie administrative : type de voie + libelle voie + complément nom de voie.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES"."LATERALITE" IS 'Latéralité de la voie administrative par rapport à la voie physique.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES"."CODE_INSEE" IS 'Code INSEE de la voie administrative.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES"."GEOM" IS 'Géométrie de type ligne simple correspondant au tracé des tronçons.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES 
ADD CONSTRAINT VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES_PK 
PRIMARY KEY (OBJECTID);

-- 6. Création des index
CREATE INDEX VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES_SIDX
ON G_BASE_VOIE.VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);
/*
CREATE INDEX VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES_IDX ON G_BASE_VOIE.VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES(CODE_INSEE, TYPE_DE_VOIE, LIBELLE_VOIE, COMPLEMENT_NOM_VOIE)
    TABLESPACE G_ADT_INDX;
*/
-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES TO G_ADMIN_SIG;

/

