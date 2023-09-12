/*
Création de la vue matérialisée VM_VISUALISATION_SEUIL regroupant les seuils de la MEL et leur tronçon.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_VISUALISATION_SEUIL;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_VISUALISATION_SEUIL';
COMMIT;
*/
-- 1. Création de la vue matérialisée
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_VISUALISATION_SEUIL(
    geom,
    objectid,
    numero,
    complement_numero,
    date_saisie,
    date_modification,
    code_insee,
    lateralite,
    id_troncon,
    id_voie_physique,
    id_voie_administrative,
    nom_voie,
    hierarchie_voie_admin
)
REFRESH FORCE
START WITH TO_DATE('15-05-2023 09:20:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 240/24/1440
DISABLE QUERY REWRITE AS
SELECT
    b.geom,
    a.objectid,
    a.numero_seuil,
    a.complement_numero_seuil,
    a.date_saisie,
    a.date_modification,
    b.code_insee,
    g.libelle_court AS lateralite,
    b.fid_troncon AS id_troncon,
    d.objectid AS id_voie_physique,
    f.objectid AS id_voie_administrative,
    TRIM(SUBSTR(UPPER(h.libelle), 1, 1) || SUBSTR(LOWER(h.libelle), 2) || ' ' || TRIM(f.libelle_voie) || ' ' || TRIM(f.complement_nom_voie)) AS nom_voie,
    CASE 
        WHEN i.fid_voie_secondaire IS NOT NULL
            THEN 'Voie secondaire'
        ELSE 
            'Voie principale'
    END AS hierarchie_voie_admin
FROM
    G_BASE_VOIE.TA_INFOS_SEUIL a
    INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
    INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.objectid = b.fid_troncon
    INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE d ON d.objectid = c.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE e ON e.fid_voie_physique = d.objectid
    INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE f ON f.objectid = e.fid_voie_administrative AND f.code_insee = b.code_insee
    LEFT JOIN G_BASE_VOIE.TA_LIBELLE g ON g.objectid = b.fid_lateralite
    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE h ON h.objectid = f.fid_type_voie
    LEFT JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE i ON i.fid_voie_secondaire = f.objectid;

-- 2. Création des commentaires de table et de colonnes
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_VISUALISATION_SEUIL IS 'Vue matérialisée regroupant les seuils de la MEL, leur tronçon, voie physique et voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_VISUALISATION_SEUIL.geom IS 'Géométrie de type point des seuils.';
COMMENT ON COLUMN G_BASE_VOIE.VM_VISUALISATION_SEUIL.objectid IS 'Clé primaire de la VM correspondant aux identifiants de chaque seuil (TA_INFOS_SEUIL).';
COMMENT ON COLUMN G_BASE_VOIE.VM_VISUALISATION_SEUIL.numero IS 'Numéro du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_VISUALISATION_SEUIL.complement_numero IS 'Complément du numéro de seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_VISUALISATION_SEUIL.date_saisie IS 'Date de saisie du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_VISUALISATION_SEUIL.date_modification IS 'Date de la dernière modification du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_VISUALISATION_SEUIL.code_insee IS 'Code INSEE du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_VISUALISATION_SEUIL.lateralite IS 'Latéralité du seuil par rapport au tronçon (droite/gauche).';
COMMENT ON COLUMN G_BASE_VOIE.VM_VISUALISATION_SEUIL.id_troncon IS 'Identifiant du tronçon auquel est rattaché le seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_VISUALISATION_SEUIL.id_voie_physique IS 'Identifiant de la voie physique à laquelle est rattaché le seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_VISUALISATION_SEUIL.id_voie_administrative IS 'Identifiant de la voie administrative à laquelle est rattaché le seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_VISUALISATION_SEUIL.nom_voie IS 'Nom de la voie à laquelle le seuil est affecté.';
COMMENT ON COLUMN G_BASE_VOIE.VM_VISUALISATION_SEUIL.hierarchie_voie_admin IS 'Hiérarchie de la voie administrative.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_VISUALISATION_SEUIL',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_VISUALISATION_SEUIL 
ADD CONSTRAINT VM_VISUALISATION_SEUIL_PK 
PRIMARY KEY (OBJECTID);

-- 5. Création des index
-- index spatial
CREATE INDEX VM_VISUALISATION_SEUIL_SIDX
ON G_BASE_VOIE.VM_VISUALISATION_SEUIL(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=POINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- Autres index  
CREATE INDEX VM_VISUALISATION_SEUIL_NUMERO_IDX ON G_BASE_VOIE.VM_VISUALISATION_SEUIL(NUMERO)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_VISUALISATION_SEUIL_COMPLEMENT_NUMERO_IDX ON G_BASE_VOIE.VM_VISUALISATION_SEUIL(COMPLEMENT_NUMERO)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_VISUALISATION_SEUIL_DATE_SAISIE_IDX ON G_BASE_VOIE.VM_VISUALISATION_SEUIL(DATE_SAISIE)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_VISUALISATION_SEUIL_DATE_MODIFICATION_IDX ON G_BASE_VOIE.VM_VISUALISATION_SEUIL(DATE_MODIFICATION)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_VISUALISATION_SEUIL_CODE_INSEE_IDX ON G_BASE_VOIE.VM_VISUALISATION_SEUIL(CODE_INSEE)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_VISUALISATION_SEUIL_ID_TRONCON_IDX ON G_BASE_VOIE.VM_VISUALISATION_SEUIL(ID_TRONCON)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_VISUALISATION_SEUIL_ID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.VM_VISUALISATION_SEUIL(id_voie_physique)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_VISUALISATION_SEUIL_ID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.VM_VISUALISATION_SEUIL(ID_VOIE_ADMINISTRATIVE)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_VISUALISATION_SEUIL_NOM_VOIE_IDX ON G_BASE_VOIE.VM_VISUALISATION_SEUIL(NOM_VOIE)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_VISUALISATION_SEUIL_HIERARCHIE_VOIE_ADMIN_IDX ON G_BASE_VOIE.VM_VISUALISATION_SEUIL(hierarchie_voie_admin)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_VISUALISATION_SEUIL TO G_ADMIN_SIG;

/

