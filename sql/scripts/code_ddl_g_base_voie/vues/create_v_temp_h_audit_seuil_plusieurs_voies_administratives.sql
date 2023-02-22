/*
La vue V_TEMP_H_AUDIT_SEUIL_PLUSIEURS_VOIES_ADMINISTRATIVES identifie les seuils affectés à plus d'une voie administrative
*/
/*
DROP VIEW V_TEMP_H_AUDIT_SEUIL_PLUSIEURS_VOIES_ADMINISTRATIVES;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_TEMP_H_AUDIT_SEUIL_PLUSIEURS_VOIES_ADMINISTRATIVES" ("ID_SEUIL", "NOMBRE_VOIE_ADMINISTRATIVE", 
    CONSTRAINT "V_TEMP_H_AUDIT_SEUIL_PLUSIEURS_VOIES_ADMINISTRATIVES_PK" PRIMARY KEY ("ID_SEUIL") DISABLE) AS 
    SELECT
        a.objectid AS id_seuil,
        COUNT(e.objectid) AS nbr
    FROM
        G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION a
        INNER JOIN G_BASE_VOIE.TEMP_H_TRONCON b ON b.objectid = a.fid_troncon
        INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE c ON c.objectid = b.fid_voie_physique
        INNER JOIN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = c.objectid
        INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE e ON e.objectid = d.fid_voie_administrative AND e.code_insee = a.code_insee
    GROUP BY
        a.objectid
    HAVING
        COUNT(e.objectid) > 1;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_H_AUDIT_SEUIL_PLUSIEURS_VOIES_ADMINISTRATIVES IS 'Vue identifiant les seuils affectés à plusieurs voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_AUDIT_SEUIL_PLUSIEURS_VOIES_ADMINISTRATIVES.id_seuil IS 'Identifiant des seuils présents dans la table TEMP_H_SEUIL_VERIFICATION (correspondant aux identifiants de TEMP_H_SEUIL).';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_AUDIT_SEUIL_PLUSIEURS_VOIES_ADMINISTRATIVES.nombre_voie_administrative IS 'Nombre de voies administratives par seuil.';

-- 3. Création des droits de lecture
GRANT SELECT ON G_BASE_VOIE.V_TEMP_H_AUDIT_SEUIL_PLUSIEURS_VOIES_ADMINISTRATIVES TO G_ADMIN_SIG;
GRANT SELECT ON G_BASE_VOIE.V_TEMP_H_AUDIT_SEUIL_PLUSIEURS_VOIES_ADMINISTRATIVES TO G_BASE_VOIE_LEC;

/

