-- V_AUDIT_TRONCON_PLUSIEURS_VOIES: Tronçon affecté à plusieurs voies: Des tronçons au sein comme en limite de communes peuvent être affectés à plusieurs voies.
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW V_AUDIT_TRONCON_PLUSIEURS_VOIES (identifiant, code_troncon, code_voie,geom,
CONSTRAINT "V_AUDIT_TRONCON_PLUSIEURS_VOIES_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS
    WITH cte_1 AS 
                (
                SELECT
                    distinct
                    a.cnumtrc,
                    c.ccomvoi
                FROM
                    G_BASE_VOIE.TEMP_ILTATRC a
                    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
                    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi
                WHERE
                    a.cdvaltro = 'V'
                    AND b.cvalide = 'V'
                    AND c.cdvalvoi = 'V'
                ),
    cte_2 AS
        (
        SELECT
            COUNT(CNUMTRC),
            cnumtrc
        FROM
            cte_1
        GROUP BY cnumtrc
        HAVING COUNT(cnumtrc)>1
        ) 
SELECT
    rownum,
    cte_1.cnumtrc,
    cte_1.ccomvoi,
    a.ora_geometry
FROM
    cte_1
INNER JOIN cte_2 ON cte_1.cnumtrc = cte_2.cnumtrc
INNER JOIN G_BASE_VOIE.TEMP_ILTATRC a ON cte_1.cnumtrc = a.cnumtrc
;


-- 2. Commentaire de la vue
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_TRONCON_PLUSIEURS_VOIES  IS 'Vue permettant de connaitre les troncons affectes à plusieurs voies';


-- 3. Commentaire des champs
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_PLUSIEURS_VOIES.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_PLUSIEURS_VOIES.CODE_TRONCON IS 'Identifiant du troncon.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_PLUSIEURS_VOIES.CODE_VOIE IS 'Identifiant de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_PLUSIEURS_VOIES.GEOM IS 'Géométrie du troncon de type linéaire.';