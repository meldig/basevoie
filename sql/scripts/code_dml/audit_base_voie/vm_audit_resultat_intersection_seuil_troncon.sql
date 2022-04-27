-- VM_AUDIT_RESULTAT_INTERSECTION_SEUIL_TRONCON: Intersection seuil / tronçon Certains seuils intersectent le tronçon auquel ils appartiennent. Cela est dû aux anciennes migrations.

-- 0. Suppression de l'ancienne vue matérialisée
-- DROP MATERIALIZED VIEW VM_AUDIT_RESULTAT_INTERSECTION_SEUIL_TRONCON;

-- 1. Création de la vue.
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_RESULTAT_INTERSECTION_SEUIL_TRONCON (identifiant, code_seuil, code_troncon, geom)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
WITH CTE_1 AS
    (
    SELECT
        a.objectid AS code_seuil,
        c.objectid AS code_troncon,
        a.geom
    FROM
        G_BASE_VOIE.TA_SEUIL a
        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL b ON b.fid_seuil = a.objectid
        INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.objectid = b.fid_troncon
    WHERE
        SDO_RELATE(a.geom,c.geom,'mask = OVERLAPBDYINTERSECT') = 'TRUE'
    )
SELECT
    rownum,
    code_seuil,
    code_troncon,
    geom
FROM
    CTE_1
;

-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_RESULTAT_INTERSECTION_SEUIL_TRONCON
ADD CONSTRAINT VM_AUDIT_RESULTAT_INTERSECTION_SEUIL_TRONCON_PK 
PRIMARY KEY (IDENTIFIANT);


-- 3. Commentaire de la vue materialisée
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_RESULTAT_INTERSECTION_SEUIL_TRONCON  IS 'Vue permettant de connaitre les seuils et les troncons qui s''intersectent.';


-- 4. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_INTERSECTION_SEUIL_TRONCON.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_INTERSECTION_SEUIL_TRONCON.CODE_SEUIL IS 'Identifiant du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_INTERSECTION_SEUIL_TRONCON.CODE_TRONCON IS 'Identifiant du troncon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_INTERSECTION_SEUIL_TRONCON.GEOM IS 'Géométrie du seuil de type point.';