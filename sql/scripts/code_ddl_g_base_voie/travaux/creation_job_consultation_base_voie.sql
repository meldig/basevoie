-- Description : Ce job permet de mettre à jour la table TEMP_J_CONSULTATION_BASE_VOIE toutes les minutes. Elle est vidée, puis remplie systématiquement. Ce process est utilisé car une vue ou une VM ne répondent pas au besoin.

DELETE FROM G_BASE_VOIE.TEMP_J_CONSULTATION_BASE_VOIE;

INSERT INTO G_BASE_VOIE.TEMP_J_CONSULTATION_BASE_VOIE(OBJECTID,ID_TRONCON,ID_VOIE_PHYSIQUE,ACTION_SENS,ID_VOIE_ADMINISTRATIVE,CODE_INSEE,TYPE_VOIE,LIBELLE_VOIE,COMPLEMENT_NOM_VOIE,LATERALITE,COMMENTAIRE, GEOM)
SELECT
    rownum AS objectid,
    a.objectid AS id_troncon,
    b.objectid AS id_voie_physique,
    d.libelle_court AS action_sens,
    e.objectid AS id_voie_administrative,
    e.code_insee,
    f.libelle AS type_voie,
    e.libelle_voie,
    e.complement_nom_voie,
    g.libelle_court AS lateralite,
    e.commentaire,
    a.geom
FROM
    G_BASE_VOIE.TEMP_J_TRONCON a
    LEFT JOIN G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
    LEFT JOIN G_BASE_VOIE.TEMP_J_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
    LEFT JOIN G_BASE_VOIE.TEMP_J_LIBELLE d ON d.objectid = b.fid_action
    LEFT JOIN G_BASE_VOIE.TEMP_J_VOIE_ADMINISTRATIVE e ON e.objectid = c.fid_voie_administrative
    LEFT JOIN G_BASE_VOIE.TEMP_J_TYPE_VOIE f ON f.objectid = e.fid_type_voie
    LEFT JOIN G_BASE_VOIE.TEMP_J_LIBELLE g ON g.objectid = c.fid_lateralite;

/

