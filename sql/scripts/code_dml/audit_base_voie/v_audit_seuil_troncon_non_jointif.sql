-- V_AUDIT_TRONCON_MEME_VOIE_NON_JOINTIF: Troncon f'une meme voie non jointif
-- 1. Creation vue
CREATE OR REPLACE FORCE VIEW V_AUDIT_SEUIL_TRONCON_NON_JOINTIF (identifiant, code_troncon_a, statut_connection,
CONSTRAINT "V_AUDIT_SEUIL_TRONCON_NON_JOINTIF_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS
SELECT
    rownum as identifiant,
    a.cnumtrc AS code_troncon_a,
    d.idseui AS code_seuil,
    SDO_LRS.CONNECTED_GEOM_SEGMENTS(
        SDO_LRS.CONVERT_TO_LRS_GEOM(a.ora_geometry),
        SDO_LRS.CONVERT_TO_LRS_GEOM(e.ora_geometry),
        0.005
    ) AS statut_connection
FROM
    G_BASE_VOIE.TEMP_ILTATRC a
    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
    INNER JOIN G_BASE_VOIE.TEMP_ILTASIT c ON c.cnumtrc = a.cnumtrc
    INNER JOIN G_BASE_VOIE.TEMP_ILTASEU d ON d.idseui = c.idesui,
    G_BASE_VOIE.TEMP_ILTATRC e
    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT f ON f.cnumtrc = e.cnumtrc
    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI g ON g.ccomvoi = f.ccomvoi
WHERE 
    a.cnumtrc <> e.cnumtrc
    AND a.cnumtrc < e.cnumtrc
    AND SDO_WITHIN_DISTANCE(
            e.ora_geometry, 
            a.ora_geometry, 
            'distance = 0.5'
        ) = 'TRUE'
    AND SDO_LRS.CONNECTED_GEOM_SEGMENTS(
            SDO_LRS.CONVERT_TO_LRS_GEOM(a.ora_geometry), 
            SDO_LRS.CONVERT_TO_LRS_GEOM(e.ora_geometry), 
            0.005
        ) = 'FALSE'
    AND b.ccomvoi = f.ccomvoi
    AND a.cdvaltro = 'V'
    AND e.cdvaltro = 'V'
    AND b.cvalide = 'V'
    AND f.cvalide = 'V'
    AND g.cdvalvoi = 'V'
;

-- 2. Commentaire vue
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_SEUIL_TRONCON_NON_JOINTIF IS 'Seuils affectés à des tronçons situés à quelques centaines de mètres de leur voie';

-- 3. Commentaires champs
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_SEUIL_TRONCON_NON_JOINTIF.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_SEUIL_TRONCON_NON_JOINTIF.code_troncon_a IS 'Identifiant du troncon considéré a.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_SEUIL_TRONCON_NON_JOINTIF.code_seuil IS 'Identifiant du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_SEUIL_TRONCON_NON_JOINTIF.statut_connection IS 'Statut de la connection.';