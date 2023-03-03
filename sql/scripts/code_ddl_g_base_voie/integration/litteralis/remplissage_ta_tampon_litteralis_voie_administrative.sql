-- Insertion des voies administratives principales/secondaires au format LITTERALIS
INSERT INTO G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE(OBJECTID, NOM_VOIE, CODE_INSEE, GEOM)
-- Sélection des voies administratives principales au format LITTERALIS (sans la latéralité)
WITH
    C_1 AS(
        SELECT
            d.objectid,
            CAST(SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 2) || ' ' || d.libelle_voie || ' ' || d.complement_nom_voie AS VARCHAR2(254)) AS nom_voie,
            d.libelle_voie,
            d.code_insee,
            SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS geom
        FROM
            G_BASE_VOIE.TEMP_H_TRONCON a
            INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
            INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE d ON d.objectid = c.fid_voie_administrative
            INNER JOIN G_BASE_VOIE.TEMP_H_TYPE_VOIE e ON e.objectid = d.fid_type_voie
        WHERE
            d.objectid IN(SELECT fid_voie_secondaire FROM G_BASE_VOIE.TEMP_H_HIERARCHISATION_VOIE)
        GROUP BY
            d.objectid,
            CAST(SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 2) || ' ' || d.libelle_voie || ' ' || d.complement_nom_voie AS VARCHAR2(254)),
            d.libelle_voie,
            d.code_insee
    )

SELECT
    a.objectid,
    a.nom_voie || ' ANNEXE ' || ROW_NUMBER() OVER (PARTITION BY (UPPER(TRIM(a.libelle_voie)) || ' ' || a.code_insee) ORDER BY SDO_GEOM.SDO_LENGTH(a.geom, 0.001) DESC) AS nom_voie,
    a.code_insee,
    a.geom AS geom
FROM
    C_1 a
UNION ALL
-- Sélection des voies administratives secondaires au format LITTERALIS (sans la latéralité)
SELECT
    d.objectid,
    CAST(SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 2) || ' ' || d.libelle_voie || ' ' || d.complement_nom_voie AS VARCHAR2(254)) AS nom_voie,
    d.code_insee,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS geom
FROM
    G_BASE_VOIE.TEMP_H_TRONCON a
    INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
    INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE d ON d.objectid = c.fid_voie_administrative
    INNER JOIN G_BASE_VOIE.TEMP_H_TYPE_VOIE e ON e.objectid = d.fid_type_voie
WHERE
    d.objectid NOT IN(SELECT fid_voie_secondaire FROM G_BASE_VOIE.TEMP_H_HIERARCHISATION_VOIE)
GROUP BY
    d.objectid,
    CAST(SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 2) || ' ' || d.libelle_voie || ' ' || d.complement_nom_voie AS VARCHAR2(254)),
    d.code_insee;
-- Résultat : 22 164 lignes insérées.

-- Insertion des tronçons au format LITTERALIS
