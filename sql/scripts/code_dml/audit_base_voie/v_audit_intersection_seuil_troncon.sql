-- V_AUDIT_INTERSECTION_SEUIL_TRONCON: Intersection seuil / tronçon Certains seuils intersectent le tronçon auquel ils appartiennent. Cela est dû aux anciennes migrations.
-- 1. Création de la vue.
CREATE OR REPLACE FORCE VIEW V_AUDIT_INTERSECTION_SEUIL_TRONCON (identifiant, code_seuil, code_troncon,
CONSTRAINT "V_AUDIT_INTERSECTION_SEUIL_TRONCON_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS
WITH CTE_1 AS
    (
    SELECT
        a.IDSEUI,
        c.cnumtrc
    FROM
        TEMP_ILTASEU a
        INNER JOIN TEMP_ILTASIT b ON b.idseui = a.idseui
        INNER JOIN TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc
    WHERE
        c.cdvaltro = 'V'
        AND SDO_RELATE(a.ora_geometry,c.ora_geometry,'mask = OVERLAPBDYINTERSECT') = 'TRUE'
    )
SELECT
    rownum,
    idseui,
    cnumtrc
FROM
    CTE_1
;


-- 2. Commentaire de la vue
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_INTERSECTION_SEUIL_TRONCON  IS 'Vue permettant de connaitre les seuils et les troncons qui s''intersectent.';


-- 3. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_INTERSECTION_SEUIL_TRONCON.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_INTERSECTION_SEUIL_TRONCON.code_seuil IS 'Identifiant du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_INTERSECTION_SEUIL_TRONCON.code_troncon IS 'Identifiant du troncon.';