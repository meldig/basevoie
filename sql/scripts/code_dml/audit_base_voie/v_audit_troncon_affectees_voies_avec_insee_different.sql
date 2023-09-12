-- V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_INSEE_DIFFERENT: tronçons affectées à des voies ayant un code insee différent de celui du troncon.

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_INSEE_DIFFERENT (identifiant, id_troncon, insee_troncon, id_voie, insee_voie, libelle_voie, geom,
CONSTRAINT "V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_INSEE_DIFFERENT_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS
WITH
    C_1 AS(-- Sélection des tronçons affectés à plusieurs voies
        SELECT
            a.cnumtrc,
            d.code_insee
        FROM
            G_BASE_VOIE.TEMP_ILTATRC a
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi,
            G_REFERENTIEL.MEL_COMMUNE_LLH d
        WHERE
            a.cdvaltro = 'V'
            AND b.cvalide = 'V'
            AND c.cdvalvoi = 'V'
            AND SDO_INSIDE(a.ora_geometry, d.geom) = 'TRUE'
        GROUP BY
            a.cnumtrc
            ,d.code_insee
        HAVING
            COUNT(a.cnumtrc) > 1
    )

SELECT
	rownum AS identifiant,
    a.cnumtrc AS id_troncon,
    a.code_insee AS insee_troncon,
    c.ccomvoi AS id_voie,
    CASE length(c.cnumcom)
        WHEN 1 THEN '59' || '00' || c.cnumcom
        WHEN 2 THEN '59' || '0' || c.cnumcom
        WHEN 3 THEN '59' || c.cnumcom
    END insee_voie,
    c.cnominus AS libelle_voie,
    d.ora_geometry AS geom
FROM
    C_1 a
    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi
    INNER JOIN G_BASE_VOIE.TEMP_ILTATRC d ON a.cnumtrc = d.cnumtrc
WHERE
    b.cvalide = 'V'
    AND c.cdvalvoi = 'V'
    AND a.code_insee <> CASE length(c.cnumcom)
        WHEN 1 THEN '59' || '00' || c.cnumcom
        WHEN 2 THEN '59' || '0' || c.cnumcom
        WHEN 3 THEN '59' || c.cnumcom
    END
;


-- 2. Commentaire de la vue
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_INSEE_DIFFERENT  IS 'Vue permettant d''identifier les tronçons tronçons affectées à des voies ayant un code insee différent de celui du troncon.';


-- 3. Commentaire des champs
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_INSEE_DIFFERENT.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_INSEE_DIFFERENT.ID_TRONCON IS 'Identifiant du troncon.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_INSEE_DIFFERENT.INSEE_TRONCON IS 'Code insee du troncon.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_INSEE_DIFFERENT.ID_VOIE IS 'Identifiant de la voie';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_INSEE_DIFFERENT.INSEE_VOIE IS 'Code insee de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_INSEE_DIFFERENT.LIBELLE_VOIE IS 'Libelle de la voie';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_INSEE_DIFFERENT.GEOM IS 'Géométrie du troncon de type linéaire.';