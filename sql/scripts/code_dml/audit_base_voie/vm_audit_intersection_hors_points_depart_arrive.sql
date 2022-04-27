-- VM_AUDIT_INTERSECTION_HORS_POINTS_DEPART_ARRIVE: Intersection des tronçons hors start/end point  Certains tronçons s'intersectent en dehors des startpoint/endpoint, ce qui est normalement impossible car un tronçon commence/fini à chaque croisement.

-- 0. Suppression de l'ancienne vue matérialisée
-- DROP MATERIALIZED VIEW VM_AUDIT_INTERSECTION_HORS_POINTS_DEPART_ARRIVE;

-- 1. Création de la vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_INTERSECTION_HORS_POINTS_DEPART_ARRIVE (identifiant, code_troncon_a, code_troncon_b)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
WITH CTE_1 AS
    (
    SELECT 
        a.cnumtrc troncon_a, 
        b.cnumtrc troncon_b
    FROM
        G_BASE_VOIE.TEMP_ILTATRC a,
        G_BASE_VOIE.TEMP_ILTATRC b
    WHERE
        a.cnumtrc < b.cnumtrc
        AND a.cdvaltro = 'V'
        AND b.cdvaltro = 'V'
        AND SDO_RELATE(SDO_UTIL.RECTIFY_GEOMETRY(a.ora_geometry, 0.005),SDO_UTIL.RECTIFY_GEOMETRY(b.ora_geometry, 0.005), 'mask=OVERLAPBDYDISJOINT') = 'TRUE'
    )
SELECT
    rownum,
    troncon_a,
    troncon_b
FROM
    CTE_1
;

-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_INTERSECTION_HORS_POINTS_DEPART_ARRIVE
ADD CONSTRAINT VM_AUDIT_INTERSECTION_HORS_POINTS_DEPART_ARRIVE_PK 
PRIMARY KEY (IDENTIFIANT);

-- 2. Commentaire de la vue matérialisée
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_INTERSECTION_HORS_POINTS_DEPART_ARRIVE  IS 'Vue permettant de connaitre les troncons qui ne s''intersectent pas sur les points de depart ni d''arrivé';


-- 3. Commentaire des champs
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_INTERSECTION_HORS_POINTS_DEPART_ARRIVE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_INTERSECTION_HORS_POINTS_DEPART_ARRIVE.code_troncon_a IS 'Identifiant du troncon considéré a.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_INTERSECTION_HORS_POINTS_DEPART_ARRIVE.code_troncon_b IS 'Identifiant du troncon considéré b.';