/*
Création de la vue matérialisée VM_VOIE_ADMINISTRATIVE_MATERIALISEE - du projet j de test de production - matérialisant la géométrie des voies administratives avec leur nom, code insee, latéralité et hiérarchie.
*/
-- 1. Suppression de la VM et de ses métadonnées
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_VOIE_ADMINISTRATIVE_MATERIALISEE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_VOIE_ADMINISTRATIVE_MATERIALISEE';
COMMIT;
*/
-- 2. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_VOIE_ADMINISTRATIVE_MATERIALISEE (
    OBJECTID,
    ID_VOIE_ADMINISTRATIVE,
    NOM_VOIE,
    HIERARCHIE,
    CODE_INSEE,
    LATERALITE,
    GEOM
)        
REFRESH FORCE
START WITH TO_DATE('16-05-2023 15:00:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 120/24/1440
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(
        SELECT
            d.objectid AS id_voie_administrative,
            TRIM(SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 2) || ' ' || TRIM(d.libelle_voie) || ' ' || TRIM(d.complement_nom_voie)) || CASE WHEN d.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN d.code_insee = '59355' THEN ' (Lomme)' END AS nom_voie,
            CASE WHEN COALESCE(g.fid_voie_secondaire, 0) = 0 THEN 'Voie Principale' ELSE 'Voie secondaire' END AS hierarchie,
            d.code_insee,
            f.libelle_court AS lateralite,
            SDO_AGGR_UNION(
                SDOAGGRTYPE(a.geom, 0.005)
            ) AS geom
        FROM
            G_BASE_VOIE.TA_TRONCON a
            INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
            INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE d ON d.objectid = c.fid_voie_administrative
            LEFT JOIN G_BASE_VOIE.TA_TYPE_VOIE e ON e.objectid = d.fid_type_voie
            LEFT JOIN G_BASE_VOIE.TA_LIBELLE f ON f.objectid = c.fid_lateralite
            LEFT JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE g ON g.fid_voie_secondaire = d.objectid
        GROUP BY
            d.code_insee,
            f.libelle_court,
            CASE WHEN COALESCE(g.fid_voie_secondaire, 0) = 0 THEN 'Voie Principale' ELSE 'Voie secondaire' END,
            TRIM(SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 2) || ' ' || TRIM(d.libelle_voie) || ' ' || TRIM(d.complement_nom_voie)) || CASE WHEN d.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN d.code_insee = '59355' THEN ' (Lomme)' END,
            d.objectid
    )
    
    SELECT
        rownum AS objectid,
        id_voie_administrative,
        nom_voie,
        hierarchie,
        code_insee,
        lateralite,
        geom
    FROM
        C_1;

-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_VOIE_ADMINISTRATIVE_MATERIALISEE IS 'Vue matérialisée - du projet j de test de production - matérialisant la géométrie des voies administratives avec leur nom, code insee, latéralité et hiérarchie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_VOIE_ADMINISTRATIVE_MATERIALISEE.objectid IS 'Clé primaire de la VM.';
COMMENT ON COLUMN G_BASE_VOIE.VM_VOIE_ADMINISTRATIVE_MATERIALISEE.id_voie_administrative IS 'Identifiants des voies administratives de TA_VOIE_ADMINISTRATIVE.';
COMMENT ON COLUMN G_BASE_VOIE.VM_VOIE_ADMINISTRATIVE_MATERIALISEE.nom_voie IS 'Nom des voies administratives : concaténation du type de voie, du libellé de voie et du complément de nom de voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_VOIE_ADMINISTRATIVE_MATERIALISEE.hierarchie IS 'Hiérarchie des voies (prinicpale/secondaire).';
COMMENT ON COLUMN G_BASE_VOIE.VM_VOIE_ADMINISTRATIVE_MATERIALISEE.code_insee IS 'Code INSEE de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_VOIE_ADMINISTRATIVE_MATERIALISEE.lateralite IS 'Latéralité de la voie administrative (droit, gauche les deux côtés)';
COMMENT ON COLUMN G_BASE_VOIE.VM_VOIE_ADMINISTRATIVE_MATERIALISEE.geom IS 'Géométrie de type multiligne.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_VOIE_ADMINISTRATIVE_MATERIALISEE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_VOIE_ADMINISTRATIVE_MATERIALISEE 
ADD CONSTRAINT VM_VOIE_ADMINISTRATIVE_MATERIALISEE_PK 
PRIMARY KEY (OBJECTID);

-- 6. Création des index
CREATE INDEX VM_VOIE_ADMINISTRATIVE_MATERIALISEE_SIDX
ON G_BASE_VOIE.VM_VOIE_ADMINISTRATIVE_MATERIALISEE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_VOIE_ADMINISTRATIVE_MATERIALISEE_NOM_VOIE_IDX ON G_BASE_VOIE.VM_VOIE_ADMINISTRATIVE_MATERIALISEE(NOM_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_VOIE_ADMINISTRATIVE_MATERIALISEE_CODE_INSEE_IDX ON G_BASE_VOIE.VM_VOIE_ADMINISTRATIVE_MATERIALISEE(CODE_INSEE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_VOIE_ADMINISTRATIVE_MATERIALISEE_HIERARCHIE_IDX ON G_BASE_VOIE.VM_VOIE_ADMINISTRATIVE_MATERIALISEE(HIERARCHIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_VOIE_ADMINISTRATIVE_MATERIALISEE_LATERALITE_IDX ON G_BASE_VOIE.VM_VOIE_ADMINISTRATIVE_MATERIALISEE(LATERALITE)
    TABLESPACE G_ADT_INDX;

-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_VOIE_ADMINISTRATIVE_MATERIALISEE TO G_ADMIN_SIG;

/
