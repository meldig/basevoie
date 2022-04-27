-- VM_AUDIT_RESULTAT_SEUIL_TRONCON_NON_JOINTIF: Troncon d'une meme voie non jointif

-- 0. Suppression de l'ancienne vue matérialisée
/*
DROP INDEX VM_AUDIT_RESULTAT_SEUIL_TRONCON_NON_JOINTIF_SIDX;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_AUDIT_RESULTAT_SEUIL_TRONCON_NON_JOINTIF';
DROP MATERIALIZED VIEW VM_AUDIT_RESULTAT_SEUIL_TRONCON_NON_JOINTIF;
*/

-- 1. Creation vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_RESULTAT_SEUIL_TRONCON_NON_JOINTIF (identifiant, code_troncon, code_seuil, statut_connection, geom)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
SELECT
    rownum as identifiant,
    a.objectid AS code_troncon_a,
    e.objectid AS code_seuil,
    SDO_LRS.CONNECTED_GEOM_SEGMENTS(
        SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom),
        SDO_LRS.CONVERT_TO_LRS_GEOM(e.geom),
        0.005
    ) AS statut_connection,
    f.objectid
FROM
    G_BASE_VOIE.TA_TRONCON a
    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
    INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = b.fid_voie
    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL d ON d.fid_troncon = a.objectid
    INNER JOIN G_BASE_VOIE.TA_SEUIL e ON e.objectid = d.fid_seuil,
    G_BASE_VOIE.TA_TRONCON f
    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE g ON g.fid_troncon = f.objectid
    INNER JOIN G_BASE_VOIE.TA_VOIE h ON h.objectid = g.fid_voie
WHERE 
    a.objectid <> f.objectid
    AND a.objectid < f.objectid
    AND SDO_WITHIN_DISTANCE(
            f.geom, 
            a.geom, 
            'distance = 0.5'
        ) = 'TRUE'
    AND SDO_LRS.CONNECTED_GEOM_SEGMENTS(
            SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom), 
            SDO_LRS.CONVERT_TO_LRS_GEOM(f.geom), 
            0.005
        ) = 'FALSE'
    AND c.objectid = h.objectid
;

-- 2. Clé primaire
ALTER MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_RESULTAT_SEUIL_TRONCON_NON_JOINTIF
ADD CONSTRAINT VM_AUDIT_RESULTAT_SEUIL_TRONCON_NON_JOINTIF_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commentaire vue materialisée
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_RESULTAT_SEUIL_TRONCON_NON_JOINTIF IS 'Seuils affectés à des tronçons situés à quelques centaines de mètres de leur voie';

-- 4. Commentaires champs
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_SEUIL_TRONCON_NON_JOINTIF.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_SEUIL_TRONCON_NON_JOINTIF.code_troncon IS 'Identifiant du troncon considéré a.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_SEUIL_TRONCON_NON_JOINTIF.code_seuil IS 'Identifiant du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_SEUIL_TRONCON_NON_JOINTIF.statut_connection IS 'Statut de la connection.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_SEUIL_TRONCON_NON_JOINTIF.geom IS 'Géométrie de l''élément type point';

-- 5. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_AUDIT_RESULTAT_SEUIL_TRONCON_NON_JOINTIF',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.001), MDSYS.SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.001)), 
    2154
);


-- 6. Création de l'index spatial
CREATE INDEX VM_AUDIT_RESULTAT_SEUIL_TRONCON_NON_JOINTIF_SIDX
ON VM_AUDIT_RESULTAT_SEUIL_TRONCON_NON_JOINTIF(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=POINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);