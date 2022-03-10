/*
Création de la vue matérialisée G_BASE_VOIE.VM_GRU_ADRESSE proposant les adresses de la MEL pour la Gestion des Relations des Usagers.
*/

DROP MATERIALIZED VIEW G_BASE_VOIE.VM_GRU_ADRESSE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_GRU_ADRESSE';
COMMIT;

-- 1. Création de la vue matérialisée
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_GRU_ADRESSE(
    objectid,
    id_seuil,
    numero,
    nom_voie,
    commune,
    geom
)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(
        SELECT -- Sélection des seuils affectés aux voies secondaires pour lesquelles on conserve les noms des voies principales
            b.objectid AS id_seuil,
            TRIM(c.numero_seuil || ' ' || COALESCE(c.complement_numero_seuil, '')) AS numero,
            UPPER(i.libelle) || ' ' || UPPER(h.libelle_voie) || ' ' || UPPER(h.complement_nom_voie) AS nom_voie,
            CASE
                WHEN UPPER(a.nom) = UPPER('Lomme')
                    THEN UPPER('lille (lomme)')
                WHEN UPPER(a.nom) = UPPER('Hellemmes-Lille')
                    THEN UPPER('lille (hellemmes)')
                WHEN UPPER(a.nom) NOT IN(UPPER('Lomme'), UPPER('Hellemmes-Lille'))
                    THEN UPPER(a.nom)
            END AS commune,
            b.geom
        FROM
            G_REFERENTIEL.MEL_COMMUNE_LLH a
            INNER JOIN G_BASE_VOIE.TA_SEUIL b ON TRIM(GET_CODE_INSEE_LLH_CONTAIN_POINT('TA_SEUIL', b.geom)) = TRIM(a.code_insee)
            INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL c ON c.fid_seuil = b.objectid
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL d ON d.fid_seuil = b.objectid
            INNER JOIN G_BASE_VOIE.TA_TRONCON e ON e.objectid = d.fid_troncon
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE f ON f.fid_troncon = e.objectid   
            INNER JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE g ON g.fid_voie_secondaire = f.fid_voie
            INNER JOIN G_BASE_VOIE.TA_VOIE h ON h.objectid = g.fid_voie_principale
            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE i on i.objectid = h.fid_typevoie
        WHERE
            UPPER(i.libelle) NOT IN('Libellé non-renseigné avant la migration', 'type de voie présent dans VOIEVOI mais pas dans TYPEVOIE lors de la migration')
        UNION ALL
        SELECT -- Sélection des seuils affectés aux voies principales dont on conserve les noms
            b.objectid AS id_seuil,
            c.numero_seuil || COALESCE(c.complement_numero_seuil, '') AS numero,
            UPPER(h.libelle) || ' ' || UPPER(g.libelle_voie) || ' ' || UPPER(g.complement_nom_voie) AS nom_voie,
            CASE
                WHEN UPPER(a.nom) = UPPER('Lomme')
                    THEN UPPER('lille (lomme)')
                WHEN UPPER(a.nom) = UPPER('Hellemmes-Lille')
                    THEN UPPER('lille (hellemmes)')
                WHEN UPPER(a.nom) NOT IN(UPPER('Lomme'), UPPER('Hellemmes-Lille'))
                    THEN UPPER(a.nom)
            END AS commune,
            b.geom
        FROM
            G_REFERENTIEL.MEL_COMMUNE_LLH a
            INNER JOIN G_BASE_VOIE.TA_SEUIL b ON TRIM(GET_CODE_INSEE_LLH_CONTAIN_POINT('TA_SEUIL', b.geom)) = TRIM(a.code_insee)
            INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL c ON c.fid_seuil = b.objectid
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL d ON d.fid_seuil = b.objectid
            INNER JOIN G_BASE_VOIE.TA_TRONCON e ON e.objectid = d.fid_troncon
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE f ON f.fid_troncon = e.objectid   
            INNER JOIN G_BASE_VOIE.TA_VOIE g ON g.objectid = f.fid_voie
            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE h on h.objectid = g.fid_typevoie
        WHERE
            UPPER(h.libelle) NOT IN('Libellé non-renseigné avant la migration', 'type de voie présent dans VOIEVOI mais pas dans TYPEVOIE lors de la migration')
            AND g.objectid NOT IN(SELECT fid_voie_secondaire FROM G_BASE_VOIE.TA_HIERARCHISATION_VOIE)
    )
    
    SELECT
        rownum,
        id_seuil,
        numero,
        nom_voie,
        commune,
        geom
    FROM
        C_1;
    
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
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 
    2154
);
COMMIT;

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_GRU_ADRESSE 
ADD CONSTRAINT VM_GRU_ADRESSE_PK 
PRIMARY KEY (OBJECTID);

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
CREATE INDEX VM_GRU_ADRESSE_COMMUNE_NOM_VOIE_NUMERO_IDX ON G_BASE_VOIE.VM_GRU_ADRESSE(COMMUNE, NOM_VOIE, NUMERO)
    TABLESPACE G_ADT_INDX;

-- 5. Création des commentaires de table et de colonnes
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_GRU_ADRESSE IS 'Vue matérialisée proposant les adresses de la MEL pour la Gestion des Relations des Usagers.';
COMMENT ON COLUMN G_BASE_VOIE.VM_GRU_ADRESSE.id_seuil IS 'Clé primaire de la VM correspondant aux identifiants de chaque seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_GRU_ADRESSE.numero IS 'Numéro de chaque seuil avec son suffixe b, bis, ter, etc quand il existe.';
COMMENT ON COLUMN G_BASE_VOIE.VM_GRU_ADRESSE.nom_voie IS 'Nom de chaque voie : type de voie + nom de la voie + complément du nom';
COMMENT ON COLUMN G_BASE_VOIE.VM_GRU_ADRESSE.commune IS 'Nom de la commune d''appartenance du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_GRU_ADRESSE.geom IS 'géométries de type point de chaque seuil.';

-- 6. Création des droits de lecture pour les admins
GRANT SELECT ON G_BASE_VOIE.VM_GRU_ADRESSE TO G_ADMIN_SIG;

/

