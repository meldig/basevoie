-- V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE: Seuils en doublon de numéro, complément et voie.

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE (identifiant,nombre,numero_seuil,cdcote,complement,code_voie,
CONSTRAINT "V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS
WITH CTE_1 AS
    (
    SELECT
        COUNT(a.IDSEUI) AS NOMBRE,
        a.nuseui,
        a.cdcote,
        CASE
            WHEN a.nsseui IS NOT NULL
            THEN a.nsseui
        ELSE
            'pas de complément'
        END AS complement,
        d.ccomvoi
    FROM
        G_BASE_VOIE.TEMP_ILTASEU a
        INNER JOIN G_BASE_VOIE.TEMP_ILTASIT b ON b.idseui = a.idseui
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc
        INNER JOIN G_BASE_VOIE.TEMP_VOIECVT d ON d.cnumtrc = c.cnumtrc
        INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI e ON e.ccomvoi = d.ccomvoi
    WHERE
        c.cdvaltro = 'V'
    AND
        d.cvalide = 'V'
    AND
        e.cdvalvoi = 'V'
    GROUP BY
        a.nuseui,
        a.cdcote,
        a.nsseui,
        d.ccomvoi
    HAVING COUNT(a.IDSEUI) >1
    )
    SELECT 
        rownum,
        nombre,
        nuseui,
        cdcote,
        CASE
            WHEN a.nsseui IS NOT NULL
            THEN a.nsseui
        ELSE
            'pas de complément'
        END,
        ccomvoi
    FROM
        CTE_1
;

-- 2. Commentaire de la vue.
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE  IS 'Vue permettant d''identifier les adresses en doublons de numéro, côté de la voie, complément de numéro de seuil et identifiant de voie.';

-- 3. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE.NOMBRE IS 'Nombre de doublons.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE.NUMERO_SEUIL IS 'Numéro du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE.CDCOTE IS 'Cote de la voie ou est situé le seuil.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE.COMPLEMENT IS 'Complément du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE.CODE_VOIE IS 'Identifiant de la voie.';