-- VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE: Troncon d'une meme voie non jointif

-- 0. Suppression de l'ancienne vue matérialisée
-- DROP MATERIALIZED VIEW VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE;

-- 1. Creation vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE (IDENTIFIANT, CODE_TRONCON_A, CODE_TRONCON_B)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
SELECT
    ROWNUM,
    a.cnumtrc,
    d.cnumtrc
FROM
    G_BASE_VOIE.TEMP_ILTATRC a
    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi,
    G_BASE_VOIE.TEMP_ILTATRC d
    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT e ON e.cnumtrc = d.cnumtrc
    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI f ON f.ccomvoi = e.ccomvoi
WHERE
    a.cnumtrc < d.cnumtrc
    AND b.ccomvoi = e.ccomvoi
    AND a.cdvaltro = 'V'
    AND b.cvalide = 'V'
    AND c.cdvalvoi = 'V'
    AND d.cdvaltro = 'V'
    AND e.cvalide = 'V'
    AND f.cdvalvoi = 'V'
    AND SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(a.ora_geometry, 0.005) = 'TRUE'
    AND SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(d.ora_geometry, 0.005) = 'TRUE'
    AND sdo_geom.sdo_distance(a.ora_geometry, d.ora_geometry, 0.005) > 100
    AND SDO_ANYINTERACT(a.ora_geometry, d.ora_geometry) <> 'TRUE'
    ;


-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE
ADD CONSTRAINT VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commentaire vue materialisée
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE IS 'Vue permettant de connaitre les tronçons d''une même voie qui ne s''intersectent pas et ne se connectent pas sur les points de départ/arrivée dans un rayon de 100 m autours de chaque tronçon.';

-- 4. Commentaires champs
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE.code_troncon_a IS 'Identifiant du troncon considéré a.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE.code_troncon_b IS 'Identifiant du troncon considéré b.';