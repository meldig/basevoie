-- VM_AUDIT_PROJET_B_TRONCON_MEME_VOIE_NON_JOINTIF: Troncon d'une meme voie non jointif

-- 0. Suppression de l'ancienne vue matérialisée
-- DROP MATERIALIZED VIEW VM_AUDIT_PROJET_B_TRONCON_MEME_VOIE_NON_JOINTIF;

-- 1. Creation vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_PROJET_B_TRONCON_MEME_VOIE_NON_JOINTIF (IDENTIFIANT, CODE_TRONCON_A, CODE_TRONCON_B)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
SELECT
    ROWNUM,
    a.objectid,
    d.objectid
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
    AND SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(a.geom, 0.005) = 'TRUE'
    AND SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(d.geom, 0.005) = 'TRUE'
    AND SDO_WITHIN_DISTANCE(a.geom, d.geom, 'distance = 0.5') = 'TRUE'
    AND SDO_ANYINTERACT(a.geom, d.geom) <> 'TRUE'
    ;


-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_PROJET_B_TRONCON_MEME_VOIE_NON_JOINTIF
ADD CONSTRAINT VM_AUDIT_PROJET_B_TRONCON_MEME_VOIE_NON_JOINTIF_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commentaire vue materialisée
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_PROJET_B_TRONCON_MEME_VOIE_NON_JOINTIF IS 'Vue permettant de connaitre les tronçons d''une même voie qui ne s''intersectent pas et ne se connectent pas sur les points de départ/arrivée dans un rayon de 50 cm autours de chaque tronçon.';

-- 4. Commentaires champs
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_PROJET_B_TRONCON_MEME_VOIE_NON_JOINTIF.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_PROJET_B_TRONCON_MEME_VOIE_NON_JOINTIF.code_troncon_a IS 'Identifiant du troncon considéré a.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_PROJET_B_TRONCON_MEME_VOIE_NON_JOINTIF.code_troncon_b IS 'Identifiant du troncon considéré b.';