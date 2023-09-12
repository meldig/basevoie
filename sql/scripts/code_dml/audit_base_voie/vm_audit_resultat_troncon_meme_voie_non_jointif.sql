-- VM_AUDIT_RESULTAT_TRONCON_MEME_VOIE_NON_JOINTIF: Troncon d'une meme voie non jointif

-- 0. Suppression de l'ancienne vue matérialisée
-- DROP MATERIALIZED VIEW VM_AUDIT_RESULTAT_TRONCON_MEME_VOIE_NON_JOINTIF;

-- 1. Creation vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_RESULTAT_TRONCON_MEME_VOIE_NON_JOINTIF (IDENTIFIANT, CODE_TRONCON_A, CODE_TRONCON_B, STATUT_CONNECTION)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
SELECT
    rownum as identifiant,
    a.cnumtrc AS code_troncon_a,
    d.cnumtrc AS code_troncon_b,
    SDO_LRS.CONNECTED_GEOM_SEGMENTS(
        SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom),
        SDO_LRS.CONVERT_TO_LRS_GEOM(d.geom),
        0.005
    ) AS statut_connection
FROM
    G_BASE_VOIE.TA_TRONCON a
    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
    INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = b.fid_voie,
    G_BASE_VOIE.TA_TRONCON d
    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE e ON e.fid_troncon = d.objectid
    INNER JOIN G_BASE_VOIE.TA_VOIE f ON f.objectid = e.fid_voie
WHERE 
    a.objectid <> d.objectid
    AND a.objectid < d.objectid
    AND SDO_WITHIN_DISTANCE(
            d.geom, 
            a.geom, 
            'distance = 0.5'
        ) = 'TRUE'
    AND SDO_LRS.CONNECTED_GEOM_SEGMENTS(
            SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom), 
            SDO_LRS.CONVERT_TO_LRS_GEOM(d.geom), 
            0.005
        ) = 'FALSE'
    AND c.ccomvoi = f.objectid
;


-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_RESULTAT_TRONCON_MEME_VOIE_NON_JOINTIF
ADD CONSTRAINT VM_AUDIT_RESULTAT_TRONCON_MEME_VOIE_NON_JOINTIF_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commentaire vue materialisée
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_RESULTAT_TRONCON_MEME_VOIE_NON_JOINTIF IS 'Vue permettant de connaitre les troncons d''une meme voie qui ne s''intersectent pas sur les points de depart ni d''arrivé';

-- 4. Commentaires champs
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_TRONCON_MEME_VOIE_NON_JOINTIF.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_TRONCON_MEME_VOIE_NON_JOINTIF.code_troncon_a IS 'Identifiant du troncon considéré a.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_TRONCON_MEME_VOIE_NON_JOINTIF.code_troncon_b IS 'Identifiant du troncon considéré b.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_TRONCON_MEME_VOIE_NON_JOINTIF.statut_connection IS 'Statut de la connection.';