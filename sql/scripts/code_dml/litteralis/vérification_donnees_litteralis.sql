-- Vérification de la présence de doublons de voies secondaires dans la table TA_HIERARCHISATION_VOIE
SELECT
    fid_voie_secondaire
FROM
    TA_HIERARCHISATION_VOIE
GROUP BY
    fid_voie_secondaire
HAVING
    COUNT(fid_voie_secondaire) > 1;
-- Résultat : 0 voie

-- Vérification du bon remplissage des tables/VM sur lesquelles vont taper les tables de travail permettant de mettre les données au format LITTERALIS. Si tout est bon, les tables/VM de la requête ci-dessous doivent retourner le même nombre d'entités.
SELECT
    'TA_VOIE_LITTERALIS' AS nom_table,
    COUNT(distinct id_voie) AS nombre_voies
FROM
    G_BASE_VOIE.TA_VOIE_LITTERALIS
GROUP BY
    'TA_VOIE_LITTERALIS'
UNION ALL
SELECT
    'TA_VOIE' AS nom_table,
    COUNT(objectid) AS nombre_voies
FROM
    G_BASE_VOIE.TA_VOIE
GROUP BY
    'TA_VOIE'
UNION ALL
SELECT
    'VM_VOIE_AGGREGEE' AS nom_table,
    COUNT(distinct id_voie) AS nombre_voies
FROM
    G_BASE_VOIE.VM_VOIE_AGGREGEE
GROUP BY
    'VM_VOIE_AGGREGEE'
UNION ALL
SELECT
    'VM_TRONCON_LITTERALIS' AS nom_table,
    COUNT(distinct TO_NUMBER(code_rue_g)) AS nombre_voies
FROM
    G_BASE_VOIE.VM_TRONCON_LITTERALIS
GROUP BY
    'VM_TRONCON_LITTERALIS';