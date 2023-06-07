/*
Création de la vue matérialisée VM_CONSULTATION_BASE_VOIE contenant les tronçons, voies physiques et voies administratives de la base voie. Mise à jour quotidienne à 21h00
*/
/*
DROP INDEX VM_CONSULTATION_BASE_VOIE_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_CONSULTATION_BASE_VOIE';
COMMIT;
*/
-- 1. Création de la vue matérialisée
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(
    objectid,
    id_troncon,
    id_voie_physique,
    id_voie_administrative,
    code_insee,
    nom_commune,
    action_sens,
    type_voie,
    libelle_voie,
    complement_nom_voie,
    nom_voie,
    lateralite,
    hierarchie,
    commentaire,
    geom
)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
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

-- 2. Création des commentaires sur la table et les champs
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE IS 'Vue matérialisée contenant les tronçons, voies physiques et voies administratives de la base voie. Mise à jour du lundi au vendredi à 19h00.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.objectid IS 'Clé primaire de la VM.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.id_troncon IS 'Identifiant du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.id_voie_physique IS 'Identifiant de la voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.action_sens IS 'Action sur le sens de la voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.id_voie_administrative IS 'Identifiant de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.code_insee IS 'Code INSEE de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.nom_commune IS 'Nom de la commune d''appartenance de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.type_voie IS 'Type de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.libelle_voie IS 'Libelle de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.complement_nom_voie IS 'Complément de nom de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.nom_voie IS 'Nom de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.hierarchie IS 'Hiérarchie de la voie administrative : principale ou secondaire.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.lateralite IS 'Latéralité de la voie administrative par rapport à sa voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.commentaire IS 'Commentaire de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.geom IS 'Géométrie du tronçon de type ligne simple.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE 
ADD CONSTRAINT VM_CONSULTATION_BASE_VOIE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_CONSULTATION_BASE_VOIE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX VM_CONSULTATION_BASE_VOIE_SIDX
ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des index sur les clés étrangères et autres
CREATE INDEX VM_CONSULTATION_BASE_VOIE_ID_TRONCON_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(id_troncon)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_ID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(id_voie_physique)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_ACTION_SENS_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(action_sens)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_ID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(id_voie_administrative)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_CODE_INSEE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(code_insee)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_NOM_COMMUNE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(nom_commune)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_TYPE_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(type_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(libelle_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_COMPLEMENT_NOM_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(complement_nom_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_NOM_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(nom_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_HIERARCHIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(hierarchie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_LATERALITE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(lateralite)
    TABLESPACE G_ADT_INDX;

-- 7. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE TO G_ADMIN_SIG;

/

