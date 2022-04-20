-- V_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF: Troncon d'une meme voie non jointif
-- 1. Creation vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF (IDENTIFIANT, CODE_TRONCON_A, CODE_TRONCON_B, STATUT_CONNECTION)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
SELECT
    rownum as identifiant,
    a.cnumtrc AS code_troncon_a,
    d.cnumtrc AS code_troncon_b,
    SDO_LRS.CONNECTED_GEOM_SEGMENTS(
        SDO_LRS.CONVERT_TO_LRS_GEOM(a.ora_geometry),
        SDO_LRS.CONVERT_TO_LRS_GEOM(d.ora_geometry),
        0.005
    ) AS statut_connection
FROM
    G_BASE_VOIE.TEMP_ILTATRC a
    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi,
    G_BASE_VOIE.TEMP_ILTATRC d
    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT e ON e.cnumtrc = d.cnumtrc
    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI f ON f.ccomvoi = e.ccomvoi
WHERE 
    a.cnumtrc <> d.cnumtrc
    AND a.cnumtrc < d.cnumtrc
    AND SDO_WITHIN_DISTANCE(
            d.ora_geometry, 
            a.ora_geometry, 
            'distance = 0.5'
        ) = 'TRUE'
    AND SDO_LRS.CONNECTED_GEOM_SEGMENTS(
            SDO_LRS.CONVERT_TO_LRS_GEOM(a.ora_geometry), 
            SDO_LRS.CONVERT_TO_LRS_GEOM(d.ora_geometry), 
            0.005
        ) = 'FALSE'
    AND b.ccomvoi = e.ccomvoi
    AND a.cdvaltro = 'V'
    AND b.cvalide = 'V'
    AND c.cdvalvoi = 'V'
    AND d.cdvaltro = 'V'
    AND e.cvalide = 'V'
    AND f.cdvalvoi = 'V'
;


-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF
ADD CONSTRAINT VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commentaire vue materialisée
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF IS 'Vue permettant de connaitre les troncons d''une meme voie qui ne s''intersectent pas sur les points de depart ni d''arrivé';

-- 4. Commentaires champs
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF.code_troncon_a IS 'Identifiant du troncon considéré a.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF.code_troncon_b IS 'Identifiant du troncon considéré b.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF.statut_connection IS 'Statut de la connection.';