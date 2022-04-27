-- VM_AUDIT_RESULTAT_SEUIL_DISTANCE_50_CM: Seuils situés à moins de 50cm les uns des autres  Certains seuils uniques se situent à moins de 50cm les uns des autres

-- 0. Suppression de l'ancienne vue matérialisée
-- DROP MATERIALIZED VIEW VM_AUDIT_RESULTAT_SEUIL_DISTANCE_50_CM;

-- 1. Creation de la vue.
CREATE MATERIALIZED VIEW VM_AUDIT_RESULTAT_SEUIL_DISTANCE_50_CM (identifiant, seuil_a, distance, seuil_b)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
WITH CTE_1 AS 
    (
    SELECT
        a.objectid AS SEUIL_A,
        ROUND(
            SDO_GEOM.SDO_DISTANCE
                (-- Sélection de la distance entre les seuils.
                 a.geom,
                 b.geom,
                 0.005
                ), 
            2
            ) AS DISTANCE,
        b.objectid AS SEUIL_B
    FROM
        G_BASE_VOIE.TA_SEUIL a,
        G_BASE_VOIE.TA_SEUIL b
    WHERE
        a.objectid < b.objectid
        AND
        ROUND(
            SDO_GEOM.SDO_DISTANCE
                (-- condition pour ne selectionner que les seuils qui sont espacés de moins de 50 cm.
                 a.geom,
                 b.geom,
                 0.005
                ), 
            2
            )<=0.5
    )
SELECT
    rownum,
    seuil_a,
    distance,
    seuil_b
FROM
    CTE_1
;

-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_RESULTAT_SEUIL_DISTANCE_50_CM
ADD CONSTRAINT VM_AUDIT_RESULTAT_SEUIL_DISTANCE_50_CM_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commentaire de la vue matérialisée.
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_RESULTAT_SEUIL_DISTANCE_50_CM  IS 'Vue permettant les seuils distant de moins de 50 cm.';

-- 4. Commentaire des champs de la vue
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_SEUIL_DISTANCE_50_CM.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_SEUIL_DISTANCE_50_CM.seuil_a IS 'Identifiant du seuil considéré.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_SEUIL_DISTANCE_50_CM.distance IS 'Distance en les deux seuils considérés.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_SEUIL_DISTANCE_50_CM.seuil_b IS 'Identifiant du second seuil considéré.';
