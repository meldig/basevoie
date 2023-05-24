/*
La vue V_TEMP_H_AUDIT_DOUBLON_NUMERO_COMPLEMENT_SEUIL_VOIE_ADMIN - du projet H de correction des relations seuil/tronçon - identifie les seuils en doublons de numéro, complément de numéro, code INSEE et voie administrative
*/
/*
DROP VIEW V_TEMP_H_AUDIT_DOUBLON_NUMERO_COMPLEMENT_SEUIL_VOIE_ADMIN;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_TEMP_H_AUDIT_DOUBLON_NUMERO_COMPLEMENT_SEUIL_VOIE_ADMIN" ("ID_INFOS_SEUIL", "ID_SEUIL", "CODE_INSEE", "NUMERO_SEUIL", "COMPLEMENT_NUMERO_SEUIL", "ID_VOIE_ADMINISTRATIVE",
     CONSTRAINT "V_TEMP_H_AUDIT_DOUBLON_NUMERO_COMPLEMENT_SEUIL_VOIE_ADMIN_PK" PRIMARY KEY ("ID_INFOS_SEUIL") DISABLE) AS 
WITH
    C_1 AS(
        SELECT
            b.numero_seuil,
            b.complement_numero_seuil,
            a.code_insee,
            e.objectid AS id_voie_administrative
        FROM
            G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION a
            INNER JOIN G_BASE_VOIE.TEMP_H_INFOS_SEUIL b ON b.fid_seuil = a.objectid
            INNER JOIN G_BASE_VOIE.TEMP_H_TRONCON c ON c.objectid = a.fid_troncon
            INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE d ON d.objectid = c.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE e ON e.fid_voie_physique = d.objectid
            INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE f ON f.objectid = e.fid_voie_administrative AND f.code_insee = a.code_insee
    GROUP BY
        b.numero_seuil,
        b.complement_numero_seuil,
        e.objectid,
        a.code_insee
    HAVING
        COUNT(b.numero_seuil) > 1
        AND COUNT(b.complement_numero_seuil) > 1
        AND COUNT(e.objectid) > 1
        AND COUNT(a.code_insee) > 1
    )

    SELECT
        b.objectid AS id_infos_seuil,
        a.objectid AS id_seuil,
        a.code_insee,
        c.numero_seuil,
        c.complement_numero_seuil,
        c.id_voie_administrative
    FROM
        G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION a
        INNER JOIN G_BASE_VOIE.TEMP_H_INFOS_SEUIL b ON b.fid_seuil = a.objectid
        INNER JOIN C_1 c ON c.numero_seuil = b.numero_seuil AND c.complement_numero_seuil = b.complement_numero_seuil AND c.code_insee = a.code_insee;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_H_AUDIT_DOUBLON_NUMERO_COMPLEMENT_SEUIL_VOIE_ADMIN IS 'Vue - du projet H de correction des relations seuil/tronçon - identifiant tous les seuils en doublons de numéro, complément de numéro, code INSEE et voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_AUDIT_DOUBLON_NUMERO_COMPLEMENT_SEUIL_VOIE_ADMIN.id_infos_seuil IS 'Clé primaire de la vue correspondant aux identifiants des seuils de TEMP_H_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_AUDIT_DOUBLON_NUMERO_COMPLEMENT_SEUIL_VOIE_ADMIN.id_seuil IS 'Identifiants des géométries des seuils présentes dans la table TEMP_H_SEUIL_VERIFICATION.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_AUDIT_DOUBLON_NUMERO_COMPLEMENT_SEUIL_VOIE_ADMIN.code_insee IS 'Code INSEE des seuils.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_AUDIT_DOUBLON_NUMERO_COMPLEMENT_SEUIL_VOIE_ADMIN.numero_seuil IS 'Numéro des seuils.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_AUDIT_DOUBLON_NUMERO_COMPLEMENT_SEUIL_VOIE_ADMIN.complement_numero_seuil IS 'Complément des numéros de seuil.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_AUDIT_DOUBLON_NUMERO_COMPLEMENT_SEUIL_VOIE_ADMIN.id_voie_administrative IS 'Identifiant des voies administratives présentes dans la table TEMP_H_VOIE_ADMINISTRATIVE.';

-- 3. Création des droits de lecture
GRANT SELECT ON G_BASE_VOIE.V_TEMP_H_AUDIT_DOUBLON_NUMERO_COMPLEMENT_SEUIL_VOIE_ADMIN TO G_ADMIN_SIG;
GRANT SELECT ON G_BASE_VOIE.V_TEMP_H_AUDIT_DOUBLON_NUMERO_COMPLEMENT_SEUIL_VOIE_ADMIN TO G_BASE_VOIE_LEC;

/

