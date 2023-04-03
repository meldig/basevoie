/*
Création de la vue V_TEMP_I_AUDIT_VOIE_ADMINISTRATIVE_PLUSIEURS_SENS identifiant toutes les voies administratives disposant de plusieurs sens différents au sein des relations voies physiques/voie administrative.
*/
/*
DROP VIEW G_BASE_VOIE.V_TEMP_I_AUDIT_VOIE_ADMINISTRATIVE_PLUSIEURS_SENS;
*/
-- 1. Création de la vue
 CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_TEMP_I_AUDIT_VOIE_ADMINISTRATIVE_PLUSIEURS_SENS" ("ID_VOIE_ADMINISTRATIVE", "NOMBRE_SENS_DISTINCTS",
    CONSTRAINT "V_TEMP_I_AUDIT_VOIE_ADMINISTRATIVE_PLUSIEURS_SENS_PK" PRIMARY KEY ("ID_VOIE_ADMINISTRATIVE") DISABLE) AS 
SELECT
    fid_voie_administrative,
    COUNT(DISTINCT fid_lateralite)
FROM
    G_BASE_VOIE.TEMP_I_VOIE_LATERALITE
WHERE
    fid_lateralite IN(1,2)
GROUP BY
    fid_voie_administrative
HAVING
    COUNT(DISTINCT fid_lateralite) > 1;
    
-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_I_AUDIT_VOIE_ADMINISTRATIVE_PLUSIEURS_SENS IS 'Vue identifiant toutes les voies administratives disposant de plusieurs sens différents au sein des relations voies physiques/voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_I_AUDIT_VOIE_ADMINISTRATIVE_PLUSIEURS_SENS.id_voie_administrative IS 'Identifiant de la vue et des voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_I_AUDIT_VOIE_ADMINISTRATIVE_PLUSIEURS_SENS.nombre_sens_distincts IS 'Nombre de voies physiques ayant un sens différent pour une même voie administrative.';

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_TEMP_I_AUDIT_VOIE_ADMINISTRATIVE_PLUSIEURS_SENS TO G_ADMIN_SIG;

/

