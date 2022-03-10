/*
Création de la vue matérialisée VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE utilisé pour convertir les voies au format LITTERALIS. Plus spécifiquement cette VM permet de distinguer les voies principales des voies secondaires.
*/
  
-- 0. Suppression de l'objet
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE';
COMMIT;

-- 1. Création de la Vue Matérialisée
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE (OBJECTID, LIBELLE_VOIE, COMPLEMENT_NOM_VOIE, TYPE_VOIE, GEOM)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT 
    a.objectid, 
    a.libelle_voie,
    a.complement_nom_voie,
    d.libelle AS type_voie,
    SDO_AGGR_UNION (sdoaggrtype (c.geom, 0.05)) geom
FROM 
    G_BASE_VOIE.TA_VOIE a
    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_voie = a.objectid
    INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.objectid = b.fid_troncon
    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE d ON d.objectid = a.fid_typevoie
GROUP BY 
    a.objectid,
    a.libelle_voie,
    a.complement_nom_voie,
    d.libelle
ORDER BY
    a.libelle_voie,
    d.libelle;
    
-- 2. Création des commentaires de VM et de champs
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE IS 'VM DE TRAVAIL DU PROJET LITTERALIS: Création des voies géométrique en les regroupant par identifiant de voie, libelle de voie, complément de voie et type de voie. Cette VM a été créée pour distinguer les voies principales des voies secondaires. ELLE NE DOIT EN AUCUN CAS ETRE UTILISEE EN DEHORS DU PROJET LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE.objectid IS 'Identifiant des voies issus de TA_VOIE.';
COMMENT ON COLUMN G_BASE_VOIE.VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE.libelle_voie IS 'Libelle de la voie issu de la table TA_VOIE.';
COMMENT ON COLUMN G_BASE_VOIE.VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE.type_voie IS 'Type des voie (rue, avenue, boulevard, etc) issu de TA_TYPE_VOIE';
COMMENT ON COLUMN G_BASE_VOIE.VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE.geom IS 'Géométrie des voies issue de l''aggrégation des géométries des tronçons qui lui sont affectés.';

-- 3. Remplissage des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 
    2154
);

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE 
ADD CONSTRAINT VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE_PK 
PRIMARY KEY (OBJECTID);

-- 5. Création de l'index spatial
CREATE INDEX VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE_SIDX
ON G_BASE_VOIE.VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 6. Don du droit de lecture aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE TO G_ADMIN_SIG;