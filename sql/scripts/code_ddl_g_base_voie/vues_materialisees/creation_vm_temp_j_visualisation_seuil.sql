/*
Création de la vue matérialisée VM_TEMP_J_VISUALISATION_SEUIL regroupant les seuils de la MEL et leur tronçon.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TEMP_J_VISUALISATION_SEUIL';
COMMIT;
*/
-- 1. Création de la vue matérialisée
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL(
    geom,
    objectid,
    numero,
    complement_numero,
    date_saisie,
    date_modification,
    code_insee,
    lateralite,
    id_troncon
)
REFRESH FORCE
START WITH TO_DATE('03-04-2023 11:51:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT TRUNC(sysdate + 1) + 240/24/1440
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
    b.fid_troncon AS id_troncon
FROM
    G_BASE_VOIE.TEMP_J_INFOS_SEUIL a
    INNER JOIN G_BASE_VOIE.TEMP_J_SEUIL b ON b.objectid = a.fid_seuil
    INNER JOIN G_BASE_VOIE.TEMP_J_TRONCON c ON c.objectid = b.fid_troncon
    INNER JOIN G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE d ON d.objectid = c.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TEMP_J_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE e ON e.fid_voie_physique = d.objectid
    INNER JOIN G_BASE_VOIE.TEMP_J_VOIE_ADMINISTRATIVE f ON f.objectid = e.fid_voie_administrative AND f.code_insee = b.code_insee
    LEFT JOIN G_BASE_VOIE.TEMP_J_LIBELLE g ON g.objectid = b.fid_lateralite;
        
-- 2. Création des commentaires de table et de colonnes
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL IS 'Vue matérialisée regroupant les seuils de la MEL et leur tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL.geom IS 'Géométrie de type point des seuils.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL.objectid IS 'Clé primaire de la VM correspondant aux identifiants de chaque seuil (TEMP_J_INFOS_SEUIL).';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL.numero IS 'Numéro du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL.complement_numero IS 'Complément du numéro de seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL.date_saisie IS 'Date de saisie du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL.date_modification IS 'Date de la dernière modification du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL.code_insee IS 'Code INSEE du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL.lateralite IS 'Latéralité du seuil par rapport au tronçon (droite/gauche).';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL.id_troncon IS 'Identifiant du tronçon auquel est rattaché le seuil.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_J_VISUALISATION_SEUIL',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_J_VISUALISATION_SEUIL 
ADD CONSTRAINT VM_TEMP_J_VISUALISATION_SEUIL_PK 
PRIMARY KEY (OBJECTID);

-- 5. Création des index
-- index spatial
CREATE INDEX VM_TEMP_J_VISUALISATION_SEUIL_SIDX
ON G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=POINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);
    
CREATE INDEX VM_TEMP_J_VISUALISATION_SEUIL_NUMERO_IDX ON G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL(NUMERO)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_J_VISUALISATION_SEUIL_COMPLEMENT_NUMERO_IDX ON G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL(COMPLEMENT_NUMERO)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_TEMP_J_VISUALISATION_SEUIL_DATE_SAISIE_IDX ON G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL(DATE_SAISIE)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_TEMP_J_VISUALISATION_SEUIL_DATE_MODIFICATION_IDX ON G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL(DATE_MODIFICATION)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_TEMP_J_VISUALISATION_SEUIL_CODE_INSEE_IDX ON G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL(CODE_INSEE)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_TEMP_J_VISUALISATION_SEUIL_ID_TRONCON_IDX ON G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL(ID_TRONCON)
    TABLESPACE G_ADT_INDX;
    
-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_J_VISUALISATION_SEUIL TO G_ADMIN_SIG;

/
   
