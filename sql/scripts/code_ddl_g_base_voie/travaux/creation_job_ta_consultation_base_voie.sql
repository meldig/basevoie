-- Description : Le job JOB_TA_CONSULTATION_BASE_VOIE, fonctionnant quotidiennement à 21h00, permet de mettre à jour la table TA_CONSULTATION_BASE_VOIE. Elle est vidée, puis remplie systématiquement. Ce process est utilisé car une vue ou une VM ne répondent pas au besoin.

DELETE FROM G_BASE_VOIE.TA_CONSULTATION_BASE_VOIE;

INSERT INTO G_BASE_VOIE.TA_CONSULTATION_BASE_VOIE(OBJECTID,ID_TRONCON,ID_VOIE_PHYSIQUE,ID_VOIE_ADMINISTRATIVE,CODE_INSEE,NOM_COMMUNE,ACTION_SENS,TYPE_VOIE,LIBELLE_VOIE,COMPLEMENT_NOM_VOIE,NOM_VOIE,LATERALITE,HIERARCHIE,COMMENTAIRE, GEOM)
SELECT
    rownum AS objectid,
    a.objectid AS id_troncon,
    b.objectid AS id_voie_physique,
    d.objectid AS id_voie_administrative,
    d.code_insee,
    h.nom AS nom_commune,
    i.libelle_court AS action_sens,
    TRIM(SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 2)) AS type_voie,
    TRIM(d.libelle_voie) AS libelle_voie,
    TRIM(d.complement_nom_voie) AS complement_nom_voie,
    TRIM(SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 2) || ' ' || TRIM(d.libelle_voie) || ' ' || TRIM(d.complement_nom_voie)) || CASE WHEN d.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN d.code_insee = '59355' THEN ' (Lomme)' END AS nom_voie,
    f.libelle_court AS lateralite,
    CASE WHEN COALESCE(g.fid_voie_secondaire, 0) = 0 THEN 'Voie Principale' ELSE 'Voie secondaire' END AS hierarchie,
    d.commentaire,
    a.geom
FROM
    G_BASE_VOIE.TA_TRONCON a
    INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
    INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE d ON d.objectid = c.fid_voie_administrative
    LEFT JOIN G_BASE_VOIE.TA_TYPE_VOIE e ON e.objectid = d.fid_type_voie
    LEFT JOIN G_BASE_VOIE.TA_LIBELLE f ON f.objectid = c.fid_lateralite
    LEFT JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE g ON g.fid_voie_secondaire = d.objectid
    INNER JOIN G_REFERENTIEL.MEL_COMMUNE_LLH h ON h.code_insee = d.code_insee
    LEFT JOIN G_BASE_VOIE.TA_LIBELLE i ON i.objectid = b.fid_action;

