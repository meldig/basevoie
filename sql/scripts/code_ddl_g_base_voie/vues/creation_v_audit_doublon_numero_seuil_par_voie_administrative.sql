/*
Création de la vue V_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE dénombrant les doublons de numéros de seuil par voie administrative et par commune.
*/
/*
DROP VIEW G_BASE_VOIE.V_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE" ("OBJECTID", "NUMERO", "CODE_INSEE", "ID_VOIE_ADMINISTRATIVE", "NOM_VOIE", "NOMBRE", 
    CONSTRAINT "V_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
    WITH C_1 AS(
        SELECT
            TRIM(a.numero_seuil) || ' ' || TRIM(a.complement_numero_seuil) AS numero,
            b.code_insee,
            f.objectid AS id_voie_administrative,
            TRIM(SUBSTR(UPPER(g.libelle), 1, 1) || SUBSTR(LOWER(g.libelle), 2) || ' ' || TRIM(f.libelle_voie) || ' ' || TRIM(f.complement_nom_voie)) || CASE WHEN f.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN f.code_insee = '59355' THEN ' (Lomme)' END AS nom_voie,
            COUNT(a.objectid) AS nombre
        FROM
            G_BASE_VOIE.TA_INFOS_SEUIL a
            INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
            INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.objectid = b.fid_troncon
            INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE d ON d.objectid = c.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE e ON e.fid_voie_physique = d.objectid
            INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE f ON f.objectid = e.fid_voie_administrative AND f.code_insee = b.code_insee
            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE g ON g.objectid = f.fid_type_voie
        GROUP BY
            TRIM(a.numero_seuil) || ' ' || TRIM(a.complement_numero_seuil),
            b.code_insee,
            f.objectid,
            TRIM(SUBSTR(UPPER(g.libelle), 1, 1) || SUBSTR(LOWER(g.libelle), 2) || ' ' || TRIM(f.libelle_voie) || ' ' || TRIM(f.complement_nom_voie)) || CASE WHEN f.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN f.code_insee = '59355' THEN ' (Lomme)' END
        HAVING
            COUNT(a.objectid) > 1
    )

    SELECT
        rownum AS objectid,
        numero,
        code_insee,
        id_voie_administrative,
        nom_voie,
        nombre
    FROM
        C_1;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE IS 'Vue dénombrant les doublons de numéros de seuil par voie administrative et par commune.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE.objectid IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE.numero IS 'Numéro du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE.code_insee IS 'Code INSEE de la commune d''appartenance du seuil et de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE.nom_voie IS 'Nom de voie (Type de voie + libelle de voie + complément nom de voie + commune associée).';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE.nombre IS 'Nombre de numéros de seuil en doublon par voie administrative et par commune.';

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

