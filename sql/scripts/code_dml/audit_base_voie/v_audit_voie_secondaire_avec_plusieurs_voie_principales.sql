-- V_AUDIT_VOIE_SECONDAIRE_AVEC_PLUSIEURS_VOIE_PRINCIPALES: Vue materialisée permettant de connaitre les voies secondaires affectées à plusiseurs voie.

-- 1. Creation de la vue.
CREATE OR REPLACE FORCE VIEW V_AUDIT_VOIE_SECONDAIRE_AVEC_PLUSIEURS_VOIE_PRINCIPALES (identifiant, nombre, code_voie,
CONSTRAINT "V_AUDIT_VOIE_SECONDAIRE_AVEC_PLUSIEURS_VOIE_PRINCIPALES_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS
WITH CTE AS
    ( 
    SELECT
        COUNT(fid_voie_secondaire) as nombre,
        fid_voie_secondaire
    FROM
        G_BASE_VOIE.TA_HIERARCHISATION_VOIE
    GROUP BY
        fid_voie_secondaire
    HAVING COUNT(fid_voie_secondaire) >1
    )
SELECT
    ROWNUM AS identifiant,
    nombre,
    fid_voie_secondaire AS code_voie
FROM
    CTE
    ;


-- 2. Commentaires de la table.
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_VOIE_SECONDAIRE_AVEC_PLUSIEURS_VOIE_PRINCIPALES  IS 'Vue permettant de connaitre les voies secondaire affectées à plusiseurs voie';


-- 3. Commentaires des champs.
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_VOIE_SECONDAIRE_AVEC_PLUSIEURS_VOIE_PRINCIPALES.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_VOIE_SECONDAIRE_AVEC_PLUSIEURS_VOIE_PRINCIPALES.NOMBRE IS 'Nombre d''occurence de la voie secondaire.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_VOIE_SECONDAIRE_AVEC_PLUSIEURS_VOIE_PRINCIPALES.CODE_VOIE IS 'Identifiant de la voie secondaire.';