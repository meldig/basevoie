/*
Création de la vue matérialisée VM_CONSULTATION_SEUIL regroupant les seuils de la MEL et leur tronçon.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_SEUIL;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_CONSULTATION_SEUIL';
COMMIT;
*/
-- 1. Création de la vue matérialisée
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_SEUIL(
    id_seuil,
    id_troncon,
    id_voie_physique,
    id_voie_administrative,
    numero,
    complement_numero,
    code_insee,
    nom_commune,
    lateralite,
    position,
    type_voie,
    libelle_voie,
    complement_nom_voie,
    nom_voie,
    hierarchie_voie_admin,
    date_saisie,
    date_modification,
    id_geom,
    geom
)
REFRESH FORCE
START WITH TO_DATE('02-06-2023 18:00:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 240/24/1440
DISABLE QUERY REWRITE AS
SELECT
    a.objectid AS id_seuil,
    b.fid_troncon AS id_troncon,
    d.objectid AS id_voie_physique,
    f.objectid AS id_voie_administrative,
    a.numero_seuil,
    a.complement_numero_seuil,
    b.code_insee,
    j.nom AS nom_commune,
    g.libelle_court AS lateralite,
    k.libelle_court AS position,
    TRIM(SUBSTR(UPPER(h.libelle), 1, 1) || SUBSTR(LOWER(h.libelle), 2)) AS type_voie,
    TRIM(f.libelle_voie) AS libelle_voie,
    TRIM(f.complement_nom_voie) AS complement_nom_voie,
    TRIM(SUBSTR(UPPER(h.libelle), 1, 1) || SUBSTR(LOWER(h.libelle), 2) || ' ' || TRIM(f.libelle_voie) || ' ' || TRIM(f.complement_nom_voie)) || CASE WHEN f.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN f.code_insee = '59355' THEN ' (Lomme)' END AS nom_voie,
    CASE 
        WHEN i.fid_voie_secondaire IS NOT NULL
            THEN 'Voie secondaire'
        ELSE 
            'Voie principale'
    END AS hierarchie_voie_admin,
    a.date_saisie,
    a.date_modification,
    b.objectid AS id_geom,
    b.geom
FROM
    G_BASE_VOIE.TA_INFOS_SEUIL a
    INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
    INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.objectid = b.fid_troncon
    INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE d ON d.objectid = c.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE e ON e.fid_voie_physique = d.objectid
    INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE f ON f.objectid = e.fid_voie_administrative AND f.code_insee = b.code_insee
    LEFT JOIN G_BASE_VOIE.TA_LIBELLE g ON g.objectid = b.fid_lateralite
    LEFT JOIN G_BASE_VOIE.TA_LIBELLE k ON k.objectid = b.fid_position
    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE h ON h.objectid = f.fid_type_voie
    LEFT JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE i ON i.fid_voie_secondaire = f.objectid
    INNER JOIN G_REFERENTIEL.MEL_COMMUNE_LLH j ON j.code_insee = b.code_insee;

-- 2. Création des commentaires de table et de colonnes
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_SEUIL IS 'Vue matérialisée regroupant les seuils de la MEL, leur tronçon, voie physique et voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.id_seuil IS 'Clé primaire de la VM correspondant aux identifiants de chaque seuil (TA_INFOS_SEUIL).';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.id_troncon IS 'Identifiant du tronçon auquel est rattaché le seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.id_voie_physique IS 'Identifiant de la voie physique à laquelle est rattaché le seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.id_voie_administrative IS 'Identifiant de la voie administrative à laquelle est rattaché le seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.numero IS 'Numéro du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.complement_numero IS 'Complément du numéro de seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.code_insee IS 'Code INSEE du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.nom_commune IS 'Nom de la commune du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.lateralite IS 'Latéralité du seuil par rapport au tronçon (droite/gauche).';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.position IS 'Position de l''adresse : au seuil, à la boîte postale, au début de la rue, etc.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.type_voie IS 'Type de voie administrative';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.libelle_voie IS 'Libellé de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.complement_nom_voie IS 'Complément de nom de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.nom_voie IS 'Nom de la voie à laquelle le seuil est affecté.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.hierarchie_voie_admin IS 'Hiérarchie de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.date_saisie IS 'Date de saisie du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.date_modification IS 'Date de la dernière modification du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.id_geom IS 'Identifiants des géométries des seuils.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.geom IS 'Géométrie de type point des seuils.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_CONSULTATION_SEUIL',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_CONSULTATION_SEUIL 
ADD CONSTRAINT VM_CONSULTATION_SEUIL_PK 
PRIMARY KEY (ID_SEUIL);

-- 5. Création des index
-- index spatial
CREATE INDEX VM_CONSULTATION_SEUIL_SIDX
ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=POINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- Autres index  
CREATE INDEX VM_CONSULTATION_SEUIL_NUMERO_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(NUMERO)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_SEUIL_COMPLEMENT_NUMERO_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(COMPLEMENT_NUMERO)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_SEUIL_CODE_INSEE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(CODE_INSEE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_SEUIL_NOM_COMMUNE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(NOM_COMMUNE)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_CONSULTATION_SEUIL_LATERALITE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(lateralite)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_CONSULTATION_SEUIL_POSITION_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(position)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_SEUIL_ID_TRONCON_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(ID_TRONCON)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_SEUIL_ID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(ID_VOIE_PHYSIQUE)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_CONSULTATION_SEUIL_ID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(ID_VOIE_ADMINISTRATIVE)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_CONSULTATION_SEUIL_TYPE_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(TYPE_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_SEUIL_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(LIBELLE_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_SEUIL_COMPLEMENT_NOM_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(COMPLEMENT_NOM_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_SEUIL_NOM_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(NOM_VOIE)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_CONSULTATION_SEUIL_DATE_SAISIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(DATE_SAISIE)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_CONSULTATION_SEUIL_DATE_MODIFICATION_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(DATE_MODIFICATION)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_CONSULTATION_SEUIL_HIERARCHIE_VOIE_ADMIN_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(HIERARCHIE_VOIE_ADMIN)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_SEUIL_ID_GEOM_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(ID_GEOM)
    TABLESPACE G_ADT_INDX;
    
-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_CONSULTATION_SEUIL TO G_ADMIN_SIG;

/

