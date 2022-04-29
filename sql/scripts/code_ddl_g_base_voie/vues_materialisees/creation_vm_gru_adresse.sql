/*
Création de la vue matérialisée G_BASE_VOIE.VM_GRU_ADRESSE proposant les adresses de la MEL pour la Gestion des Relations des Usagers.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_GRU_ADRESSE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_GRU_ADRESSE';
COMMIT;
*/
-- 1. Création de la vue matérialisée
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_GRU_ADRESSE(
    id_seuil,
    numero,
    nom_voie,
    code_insee,
    geom
)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
    SELECT -- Sélection des seuils affectés aux voies secondaires pour lesquelles on conserve les noms des voies principales
        b.objectid AS id_seuil,
        TRIM(b.numero_seuil || ' ' || COALESCE(b.complement_numero_seuil, '')) AS numero,
        UPPER(f.libelle) || ' ' || UPPER(e.libelle_voie) || ' ' || UPPER(e.complement_nom_voie) AS nom_voie,
        CAST(TRIM(GET_CODE_INSEE_LLH_CONTAIN_POINT('TA_SEUIL', a.geom)) AS VARCHAR2(8 BYTE)) AS code_insee,
        a.geom
    FROM
        G_BASE_VOIE.TA_SEUIL a
        INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL b ON b.fid_seuil = a.objectid
        INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.objectid = a.fid_troncon  
        INNER JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE d ON d.fid_voie_secondaire = c.fid_voie
        INNER JOIN G_BASE_VOIE.TA_VOIE e ON e.objectid = d.fid_voie_principale
        INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE f on f.objectid = e.fid_typevoie
    UNION ALL
    SELECT -- Sélection des seuils affectés aux voies principales dont on conserve les noms
        b.objectid AS id_seuil,
        TRIM(b.numero_seuil || ' ' || COALESCE(b.complement_numero_seuil, '')) AS numero,
        UPPER(f.libelle) || ' ' || UPPER(e.libelle_voie) || ' ' || UPPER(e.complement_nom_voie) AS nom_voie,
        CAST(TRIM(GET_CODE_INSEE_LLH_CONTAIN_POINT('TA_SEUIL', a.geom)) AS VARCHAR2(8 BYTE)) AS code_insee,
        a.geom
    FROM
        G_BASE_VOIE.TA_SEUIL a
        INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL b ON b.fid_seuil = a.objectid
        INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.objectid = a.fid_troncon  
        INNER JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE d ON d.fid_voie_secondaire = c.fid_voie
        INNER JOIN G_BASE_VOIE.TA_VOIE e ON e.objectid = d.fid_voie_principale
        INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE f on f.objectid = e.fid_typevoie
    WHERE
        e.objectid NOT IN(SELECT fid_voie_secondaire FROM G_BASE_VOIE.TA_HIERARCHISATION_VOIE);
    
-- 2. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_GRU_ADRESSE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_GRU_ADRESSE 
ADD CONSTRAINT VM_GRU_ADRESSE_PK 
PRIMARY KEY (ID_SEUIL);

-- 4. Création des index
-- index spatial
CREATE INDEX VM_GRU_ADRESSE_SIDX
ON G_BASE_VOIE.VM_GRU_ADRESSE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=POINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- autres index
CREATE INDEX VM_GRU_ADRESSE_COMMUNE_NOM_VOIE_NUMERO_IDX ON G_BASE_VOIE.VM_GRU_ADRESSE(CODE_INSEE, NOM_VOIE, NUMERO)
    TABLESPACE G_ADT_INDX;

-- 5. Création des commentaires de table et de colonnes
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_GRU_ADRESSE IS 'Vue matérialisée proposant les adresses de la MEL pour la Gestion des Relations des Usagers.';
COMMENT ON COLUMN G_BASE_VOIE.VM_GRU_ADRESSE.id_seuil IS 'Clé primaire de la VM correspondant aux identifiants de chaque seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_GRU_ADRESSE.numero IS 'Numéro de chaque seuil avec son suffixe b, bis, ter, etc quand il existe.';
COMMENT ON COLUMN G_BASE_VOIE.VM_GRU_ADRESSE.nom_voie IS 'Nom de chaque voie : type de voie + nom de la voie + complément du nom.';
COMMENT ON COLUMN G_BASE_VOIE.VM_GRU_ADRESSE.code_insee IS 'Code INSEE de la commune d''appartenance du seuil (calculé à partir de MEL LLH (97 communes)).';
COMMENT ON COLUMN G_BASE_VOIE.VM_GRU_ADRESSE.geom IS 'géométries de type point de chaque seuil.';

-- 6. Création des droits de lecture pour les admins
GRANT SELECT ON G_BASE_VOIE.VM_GRU_ADRESSE TO G_ADMIN_SIG;

/

