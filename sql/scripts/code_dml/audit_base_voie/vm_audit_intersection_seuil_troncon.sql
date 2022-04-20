-- VM_AUDIT_INTERSECTION_SEUIL_TRONCON: Intersection seuil / tronçon Certains seuils intersectent le tronçon auquel ils appartiennent. Cela est dû aux anciennes migrations.
-- 1. Création de la vue.
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_INTERSECTION_SEUIL_TRONCON (identifiant, code_seuil, code_troncon, geom)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
WITH CTE_1 AS
    (
    SELECT
        a.idseui,
        c.cnumtrc,
        a.ora_geometry
    FROM
        G_BASE_VOIE.TEMP_ILTASEU a
        INNER JOIN G_BASE_VOIE.TEMP_ILTASIT b ON b.idseui = a.idseui
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc
    WHERE
        c.cdvaltro = 'V'
        AND SDO_RELATE(a.ora_geometry,c.ora_geometry,'mask = OVERLAPBDYINTERSECT') = 'TRUE'
    )
SELECT
    rownum,
    idseui,
    cnumtrc,
    ora_geometry
FROM
    CTE_1
;

-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_INTERSECTION_SEUIL_TRONCON
ADD CONSTRAINT VM_AUDIT_INTERSECTION_SEUIL_TRONCON_PK 
PRIMARY KEY (IDENTIFIANT);


-- 3. Commentaire de la vue materialisée
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_INTERSECTION_SEUIL_TRONCON  IS 'Vue permettant de connaitre les seuils et les troncons qui s''intersectent.';


-- 4. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_INTERSECTION_SEUIL_TRONCON.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_INTERSECTION_SEUIL_TRONCON.CODE_SEUIL IS 'Identifiant du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_INTERSECTION_SEUIL_TRONCON.CODE_TRONCON IS 'Identifiant du troncon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_INTERSECTION_SEUIL_TRONCON.GEOM IS 'Géométrie du seuil de type point.';