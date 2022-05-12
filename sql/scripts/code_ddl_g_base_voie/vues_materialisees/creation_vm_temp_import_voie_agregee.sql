/*
Création d'une vue matérialisée transitoire matérialisant la géométrie des voies pour corriger les tronçons affectés à plusieurs voies.
*/
-- 1. Suppression de la VM et de ses métadonnées
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TEMP_IMPORT_VOIE_AGREGEE';
COMMIT;
*/

-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TEMP_IMPORT_VOIE_AGREGEE" ("OBJECTID", "ID_VOIE","LIBELLE_VOIE","CODE_INSEE","GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
    WITH
        C_1 AS(
            SELECT
                c.ccomvoi AS id_voie,
                TRIM(UPPER(d.lityvoie)) ||' '|| TRIM(UPPER(c.cnominus)) ||' '|| TRIM(UPPER(c.cinfos)) AS libelle_voie,
                CASE
                    WHEN LENGTH(c.cnumcom) = 3
                        THEN '59' || c.cnumcom
                    WHEN
                        LENGTH(c.cnumcom) = 2
                        THEN '590' || c.cnumcom
                    WHEN
                        LENGTH(c.cnumcom) = 1
                        THEN '5900' || c.cnumcom
                END AS code_insee,
                SDO_AGGR_UNION(SDOAGGRTYPE(a.ora_geometry, 0.005)) AS geom
            FROM
                G_BASE_VOIE.TEMP_ILTATRC a
                INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
                INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi
                INNER JOIN G_BASE_VOIE.TEMP_TYPEVOIE d ON d.ccodtvo = c.ccodtvo
            WHERE
                c.cdvalvoi = 'V'
                AND b.cvalide = 'V'
                AND a.cdvaltro ='V'
                AND d.lityvoie IS NOT NULL
            GROUP BY
                c.ccomvoi,
                TRIM(UPPER(d.lityvoie)) ||' '|| TRIM(UPPER(c.cnominus)) ||' '|| TRIM(UPPER(c.cinfos)),
                CASE
                    WHEN LENGTH(c.cnumcom) = 3
                        THEN '59' || c.cnumcom
                    WHEN
                        LENGTH(c.cnumcom) = 2
                        THEN '590' || c.cnumcom
                    WHEN
                        LENGTH(c.cnumcom) = 1
                        THEN '5900' || c.cnumcom
                END
        )
        
        SELECT
            rownum AS objectid,
            id_voie,
            libelle_voie,
            code_insee,
            geom
    FROM
        C_1;
    
-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE IS 'Vue matérialisée matérialisant la géométrie des voies depuis les tables d''import.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_IMPORT_VOIE_AGREGEE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_IMPORT_VOIE_AGREGEE 
ADD CONSTRAINT VM_TEMP_IMPORT_VOIE_AGREGEE_PK 
PRIMARY KEY (OBJECTID);

-- 6. Création des index
CREATE INDEX VM_TEMP_IMPORT_VOIE_AGREGEE_SIDX
ON G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);
    
CREATE INDEX VM_TEMP_IMPORT_VOIE_AGREGEE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE(LIBELLE_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_IMPORT_VOIE_AGREGEE_LONGUEUR_IDX ON G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE(CODE_INSEE)
    TABLESPACE G_ADT_INDX;
    
-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE TO G_ADMIN_SIG;

/

