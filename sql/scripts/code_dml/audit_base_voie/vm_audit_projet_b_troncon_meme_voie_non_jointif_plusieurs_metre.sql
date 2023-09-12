-- VM_AUDIT_PROJET_B_TRONCON_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE: Troncon d'une meme voie non jointif

-- 0. Suppression de l'ancienne vue matérialisée
-- DROP MATERIALIZED VIEW VM_AUDIT_PROJET_B_TRONCON_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE;

-- 1. Creation vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_PROJET_B_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE (IDENTIFIANT, CODE_TRONCON_A, CODE_TRONCON_B)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
SELECT
    ROWNUM,
    a.cnumtrc,
    d.cnumtrc
FROM
    G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON a
    INNER JOIN G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
    INNER JOIN G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_VOIE c ON c.objectid = b.fid_voie,
    G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON d
    INNER JOIN G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE e ON e.fid_troncon = d.objectid
    INNER JOIN G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_VOIE f ON f.objectid = e.fid_voie
WHERE
    a.objectid < d.objectid
    AND b.objectid = b.objectid
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
ALTER TABLE G_BASE_VOIE.VM_AUDIT_PROJET_B_TRONCON_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE
ADD CONSTRAINT VM_AUDIT_PROJET_B_TRONCON_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commentaire vue materialisée
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_PROJET_B_TRONCON_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE IS 'Vue permettant de connaitre les tronçons d''une même voie qui ne s''intersectent pas et ne se connectent pas sur les points de départ/arrivée dans un rayon de 100 m autours de chaque tronçon.';

-- 4. Commentaires champs
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_PROJET_B_TRONCON_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_PROJET_B_TRONCON_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE.code_troncon_a IS 'Identifiant du troncon considéré a.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_PROJET_B_TRONCON_MEME_VOIE_NON_JOINTIF_PLUSIEURS_METRE.code_troncon_b IS 'Identifiant du troncon considéré b.';