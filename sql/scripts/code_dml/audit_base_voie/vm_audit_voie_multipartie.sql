-- GEO.VM_AUDIT_VOIE_MULTIPARTIE: Présente les voies multiparties

-- 1. creation de la vue:

-- 0. Suppression de l'ancienne vue matérialisée
/*
DROP INDEX VM_AUDIT_VOIE_MULTIPARTIE_SIDX;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_AUDIT_VOIE_MULTIPARTIE';
DROP MATERIALIZED VIEW VM_AUDIT_VOIE_MULTIPARTIE;
*/

CREATE MATERIALIZED VIEW GEO.VM_AUDIT_VOIE_MULTIPARTIE (ccomvoi, geom)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
WITH cte_1 AS
          (
          SELECT
              a.ccomvoi,
              SDO_AGGR_UNION(sdoaggrtype (c.ora_geometry, 0.005)) AS geom
          FROM
              temp_voievoi a
              INNER JOIN temp_voiecvt b on b.ccomvoi = a.ccomvoi
              INNER JOIN temp_iltatrc c on c.cnumtrc = b.cnumtrc
          WHERE
              a.cdvalvoi = 'V'
              AND b.cvalide = 'V'
              AND c.cdvaltro = 'V'
          GROUP BY a.ccomvoi
          )
SELECT
  *
FROM
  CTE_1
WHERE
  SDO_UTIL.GETNUMELEM(CTE_1.geom) >1;


-- 2.Commentaire de la vue materialisee
COMMENT ON MATERIALIZED VIEW IS "G_BASE_VOIE"."VM_AUDIT_VOIE_MULTIPARTIE"  IS 'snapshot table for snapshot G_BASE_VOIE.VM_AUDIT_VOIE_MULTIPARTIE';


-- 3. Clé primaire
ALTER MATERIALIZED VIEW GEO.VM_AUDIT_VOIE_MULTIPARTIE
ADD CONSTRAINT VM_LIG_TOPO_SOMMET_GPS_PK 
PRIMARY KEY (ccomvoi);


-- 4. Métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_AUDIT_VOIE_MULTIPARTIE',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);


-- 5. Création de l'index spatial
CREATE INDEX VM_AUDIT_VOIE_MULTIPARTIE_SIDX
ON VM_AUDIT_VOIE_MULTIPARTIE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=POINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);