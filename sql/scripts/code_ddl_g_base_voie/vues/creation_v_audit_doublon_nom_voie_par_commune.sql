/*
Création de la vue V_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE dénombrant les voies en doublon de nom par commune.
*/
/*
DROP VIEW G_BASE_VOIE.V_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE" ("OBJECTID", "NOM_VOIE", "CODE_INSEE", "NOMBRE", 
    CONSTRAINT "V_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
    WITH 
        C_1 AS(
            SELECT
                TRIM(SUBSTR(UPPER(b.libelle), 1, 1) || SUBSTR(LOWER(b.libelle), 2) || ' ' || TRIM(a.libelle_voie) || ' ' || TRIM(a.complement_nom_voie)) || CASE WHEN a.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN a.code_insee = '59355' THEN ' (Lomme)' END AS nom_voie,
                a.code_insee,
                COUNT(a.objectid) AS nombre
            FROM
                G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE a
                RIGHT JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_type_voie
            WHERE
                a.libelle_voie IS NOT NULL
            GROUP BY
                TRIM(SUBSTR(UPPER(b.libelle), 1, 1) || SUBSTR(LOWER(b.libelle), 2) || ' ' || TRIM(a.libelle_voie) || ' ' || TRIM(a.complement_nom_voie)) || CASE WHEN a.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN a.code_insee = '59355' THEN ' (Lomme)' END,
                a.code_insee
            HAVING
                COUNT(a.objectid) > 1
        )

        SELECT
            rownum AS objectid,
            nom_voie,
            code_insee,
            nombre
        FROM
            C_1;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE IS 'Vue dénombrant les voies en doublon de nom par commune.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE.objectid IS 'Clé primaire de la vue composée des dentifiants des géométries des seuils.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE.nom_voie IS 'Nom de voie (Type de voie + libelle de voie + complément nom de voie + commune associée).';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE.code_insee IS 'Code INSEE de la commune d''appartenance de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE.nombre IS 'Nombre de voies ayant le même nom au sein d''une même commune.';

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE TO G_ADMIN_SIG;

/

