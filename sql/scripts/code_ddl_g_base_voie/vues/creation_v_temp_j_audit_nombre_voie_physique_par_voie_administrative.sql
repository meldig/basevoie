/*
Création de la vue V_TEMP_J_AUDIT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE permettant de connaître le nombre de voies physiques par voie administrative.
*/
/*
DROP VIEW G_BASE_VOIE.V_TEMP_J_AUDIT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_TEMP_J_AUDIT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE" ("ID_VOIE_ADMINISTRATIVE", "NBR_VOIE_PHYSIQUE", 
    CONSTRAINT "V_TEMP_J_AUDIT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE_PK" PRIMARY KEY ("ID_VOIE_ADMINISTRATIVE") DISABLE) AS 
        SELECT
            fid_voie_administrative,
            COUNT(fid_voie_physique) AS nb_voie_physique
        FROM
            G_BASE_VOIE.TEMP_J_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
        GROUP BY
            fid_voie_administrative;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_J_AUDIT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE IS 'Vue permettant de connaître le nombre de voies physiques par voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_J_AUDIT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE.id_voie_administrative IS 'Clé primaire de la vue composée des dentifiants des voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_J_AUDIT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE.nbr_voie_physique IS 'Nombre de voies physiques par voie administrative.';

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_TEMP_J_AUDIT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

