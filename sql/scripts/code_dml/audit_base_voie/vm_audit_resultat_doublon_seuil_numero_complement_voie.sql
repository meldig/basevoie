-- VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE: Seuils en doublon de numéro, complément et voie.

-- 0. Suppression de l'ancienne vue matérialisée
-- DROP MATERIALIZED VIEW VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE;

-- 1. Création de la vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE (IDENTIFIANT, NOMBRE, NUMERO_SEUIL, CDCOTE, COMPLEMENT, CODE_VOIE)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
WITH CTE_1 AS
    (
    SELECT
        COUNT(a.objectid) AS NOMBRE,
        b.numero_seuil,
        b.complement_numero_seuil,
        a.cote_troncon,
        f.objectid AS code_voie
    FROM
        G_BASE_VOIE.TA_SEUIL a
        INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL b ON b.fid_seuil = a.objectid
        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = a.objectid
        INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = c.fid_troncon
        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE e ON e.fid_troncon = d.objectid
        INNER JOIN G_BASE_VOIE.TA_VOIE f ON f.objectid = e.fid_voie 
    GROUP BY
        b.numero_seuil,
        a.cote_troncon,
        b.complement_numero_seuil,
        f.objectid
    HAVING COUNT(a.objectid) >1
    )
    SELECT 
        rownum,
        nombre,
        numero_seuil,
        cote_troncon,
        complement_numero_seuil,
        code_voie
    FROM
        CTE_1
;

-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE
ADD CONSTRAINT VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commentaire de la vue matérialisée.
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE  IS 'Vue permettant d''identifier les adresses en doublons de numéro, côté de la voie, complément de numéro de seuil et identifiant de voie.';

-- 4. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE.NOMBRE IS 'Nombre de doublons.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE.NUMERO_SEUIL IS 'Numéro du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE.CDCOTE IS 'Cote de la voie ou est situé le seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE.COMPLEMENT IS 'Complément du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE.CODE_VOIE IS 'Identifiant de la voie.';