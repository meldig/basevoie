-- VM_AUDIT_TRONCON_PLUSIEURS_VOIES: Tronçon affecté à plusieurs voies: Des tronçons au sein comme en limite de communes peuvent être affectés à plusieurs voies.
-- 1. Création de la vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TRONCON_PLUSIEURS_VOIES (IDENTIFIANT, CODE_TRONCON, CODE_VOIE, GEOM)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
    WITH cte_1 AS 
                (
                SELECT
                    distinct
                    a.cnumtrc,
                    c.ccomvoi
                FROM
                    G_BASE_VOIE.TEMP_ILTATRC a
                    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
                    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi
                WHERE
                    a.cdvaltro = 'V'
                    AND b.cvalide = 'V'
                    AND c.cdvalvoi = 'V'
                ),
    cte_2 AS
        (
        SELECT
            COUNT(CNUMTRC),
            cnumtrc
        FROM
            cte_1
        GROUP BY cnumtrc
        HAVING COUNT(cnumtrc)>1
        ) 
SELECT
    rownum,
    cte_1.cnumtrc,
    cte_1.ccomvoi,
    a.ora_geometry
FROM
    cte_1
INNER JOIN cte_2 ON cte_1.cnumtrc = cte_2.cnumtrc
INNER JOIN G_BASE_VOIE.TEMP_ILTATRC a ON cte_1.cnumtrc = a.cnumtrc
;

-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_TRONCON_PLUSIEURS_VOIES
ADD CONSTRAINT VM_AUDIT_TRONCON_PLUSIEURS_VOIES_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commentaire de la vue materialisée
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TRONCON_PLUSIEURS_VOIES  IS 'Vue permettant de connaitre les troncons affectes à plusieurs voies';


-- 4. Commentaire des champs
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_PLUSIEURS_VOIES.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_PLUSIEURS_VOIES.CODE_TRONCON IS 'Identifiant du troncon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_PLUSIEURS_VOIES.CODE_VOIE IS 'Identifiant de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_PLUSIEURS_VOIES.GEOM IS 'Géométrie du troncon de type linéaire.';

-- 5. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_AUDIT_TRONCON_PLUSIEURS_VOIES',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.001), MDSYS.SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.001)), 
    2154
);

-- 6. Création de l'index spatial
CREATE INDEX VM_AUDIT_TRONCON_PLUSIEURS_VOIES_SIDX
ON VM_AUDIT_TRONCON_PLUSIEURS_VOIES(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=LINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);