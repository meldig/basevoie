/*
Création de la vue V_TEMP_J_AUDIT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE permettant de connaître le nombre de voies administratives composées de plusieurs voies physiques et ce, dans le détail.
*/
/*
DROP VIEW G_BASE_VOIE.V_TEMP_J_AUDIT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_TEMP_J_AUDIT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE" ("OBJECTID", "NBR_VOIE_ADMINISTRATIVE", "NBR_VOIE_PHYSIQUE", 
    CONSTRAINT "V_TEMP_J_AUDIT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
WITH
    C_1 AS(
        SELECT
            fid_voie_administrative,
            COUNT(fid_voie_physique) AS nb_voie_physique
        FROM
            G_BASE_VOIE.TEMP_J_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
        GROUP BY
            fid_voie_administrative
    ),
    
    C_2 AS(
        SELECT
            COUNT(fid_voie_administrative) AS nb_voie_administrative,
            nb_voie_physique
        FROM
            C_1
        GROUP BY
            nb_voie_physique
    )
    
    SELECT
        rownum AS objectid,
        nb_voie_administrative,
        nb_voie_physique
    FROM
        C_2;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_J_AUDIT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE IS 'Vue permettant de connaître le nombre de voies administratives réparties par le nombre de voies physiques les composant.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_J_AUDIT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE.objectid IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_J_AUDIT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE.nbr_voie_administrative IS 'Nombre de voies administratives réparties par le nombre de voies physiques les composant.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_J_AUDIT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE.nbr_voie_physique IS 'Nombre de voies physiques.';

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_TEMP_J_AUDIT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE TO G_ADMIN_SIG;

/

