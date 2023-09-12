-- VM_AUDIT_TRONCON_NON_JOINTIF: Vue permettant de connaitre les voies secondaire affectées à plusiseurs voie

-- 0. Suppression de l'ancienne vue matérialisée
-- DROP MATERIALIZED VIEW VM_AUDIT_TRONCON_NON_JOINTIF;

-- 1. Creation de la vue.
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TRONCON_NON_JOINTIF (IDENTIFIANT, TRONCON_A, TRONCON_B)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
SELECT
    ROWNUM,
    a.cnumtrc,
    b.cnumtrc
FROM
    G_BASE_VOIE.TEMP_ILTATRC a,
    G_BASE_VOIE.TEMP_ILTATRC b
WHERE
    a.cnumtrc < b.cnumtrc
    AND a.cdvaltro = 'V'
    AND b.cdvaltro = 'V'
    AND SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(a.ora_geometry, 0.005) = 'TRUE'
    AND SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(b.ora_geometry, 0.005) = 'TRUE'
    AND SDO_WITHIN_DISTANCE(a.ora_geometry, b.ora_geometry, 'distance = 0.5') = 'TRUE'
    AND SDO_ANYINTERACT(a.ora_geometry, b.ora_geometry) <> 'TRUE'
    ;

-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_TRONCON_NON_JOINTIF
ADD CONSTRAINT VM_AUDIT_TRONCON_NON_JOINTIF_PK 
PRIMARY KEY (IDENTIFIANT);


-- 3. Commentaire de la vue materialisée.
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_TRONCON_NON_JOINTIF  IS 'Vue permettant de connaitre les troncons qui ne sont pas jointifs.';


-- 4. Commentaire des colonnes.
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_NON_JOINTIF.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_NON_JOINTIF.TRONCON_A IS 'Troncon A considere.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_TRONCON_NON_JOINTIF.TRONCON_B IS 'Troncon B considere.';