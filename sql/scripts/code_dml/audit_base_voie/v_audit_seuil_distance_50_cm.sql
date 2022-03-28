-- V_AUDIT_SEUIL_DISTANCE_50_CM: Seuils situés à moins de 50cm les uns des autres  Certains seuils uniques se situent à moins de 50cm les uns des autres
-- 1. Creation de la vue.
CREATE OR REPLACE FORCE VIEW V_AUDIT_SEUIL_DISTANCE_50_CM (identifiant, seuil_a, distance, seuil_b,
CONSTRAINT "V_AUDIT_SEUIL_DISTANCE_50_CM_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS
WITH CTE_1 AS 
    (
    SELECT
        a.IDSEUI AS SEUIL_A,
        ROUND(
            SDO_GEOM.SDO_DISTANCE
                (-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                 a.ora_geometry,
                 b.ora_geometry,
                 0.005
                ), 
            2
            ) AS DISTANCE,
        b.IDSEUI AS SEUIL_B
    FROM
        TEMP_ILTASEU a,
        TEMP_ILTASEU b
    WHERE
        a.idseui < b.idseui
        AND
        ROUND(
            SDO_GEOM.SDO_DISTANCE
                (-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                 a.ora_geometry,
                 b.ora_geometry,
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


-- 2. Creation de la vue.
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_SEUIL_DISTANCE_50_CM  IS 'Vue permettant les seuils distant de moins de 50 cm.';

COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_SEUIL_DISTANCE_50_CM.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_SEUIL_DISTANCE_50_CM.seuil_a IS 'Identifiant du seuil considéré.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_SEUIL_DISTANCE_50_CM.distance IS 'Distance en les deux seuils considérés.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_SEUIL_DISTANCE_50_CM.seuil_b IS 'Identifiant du second seuil considéré.';
