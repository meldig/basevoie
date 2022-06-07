-- V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_LATERALITE: tronçons complètement contenus dans une commune et affectés à deux voies utilisent la latéralité du schéma G_SIDU.

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_LATERALITE (identifiant, id_troncon, id_voie, sens, cote_droit, cote_gauche, libelle_voie, numero_commune, geom,
CONSTRAINT "V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_LATERALITE_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS
WITH
    C_1 AS(
        SELECT
            a.cnumtrc
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
        HAVING
            COUNT(a.cnumtrc) > 1
    )

SELECT
	rownum AS identifiant,
    a.cnumtrc AS id_troncon,
    c.ccomvoi AS id_voie,
    b.ccodstr AS sens,
    c.cdparite AS cote_droit,
    c.cgparite AS cote_gauche,
    c.cnominus AS libelle_voie,
    c.cnumcom AS numero_commune,
    d.ora_geometry AS GEOM
FROM
    C_1 a
    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi
    INNER JOIN G_BASE_VOIE.TEMP_ILTATRC d ON a.cnumtrc = d.cnumtrc
WHERE
    b.cvalide = 'V'
    AND c.cdvalvoi = 'V'
    AND(c.cdparite IS NOT NULL
            OR c.cgparite IS NOT NULL)
ORDER BY
    a.cnumtrc,
    b.ccodstr;


-- 2. Commentaire de la vue
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_LATERALITE  IS 'Vue permettant d''identifier les tronçons complètement contenus dans une commune et affectés à deux voies utilisent la latéralité du schéma G_SIDU.';


-- 3. Commentaire des champs
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_LATERALITE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_LATERALITE.ID_TRONCON IS 'Identifiant du troncon.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_LATERALITE.ID_VOIE IS 'Identifiant de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_LATERALITE.SENS IS 'Sens de saisie du troncon. Si + alors le sens de saisie du tronçon est le même que le sens de circulation principal, si - alors le sens de saisie du tronçon est opposé au sens de circulation principal';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_LATERALITE.COTE_DROIT IS 'Localisation à droite de la voie suivant le sens de codage du troncon.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_LATERALITE.COTE_GAUCHE IS 'Localisation à droite de la voie suivant le sens de codage du troncon.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_LATERALITE.LIBELLE_VOIE IS 'Libelle de la voie';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_LATERALITE.NUMERO_COMMUNE IS 'Numero de commune d''appartenance de la voie';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_TRONCON_AFFECTEES_VOIES_AVEC_LATERALITE.GEOM IS 'Géométrie du troncon de type linéaire.';