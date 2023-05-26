/*
Création de la VM VM_CONSULTATION_VOIE_PHYSIQUE matérialisant les voies physiques, permettant de distinguer les voies dont le sens géométrique est inversé ou non.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_CONSULTATION_VOIE_PHYSIQUE';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_CONSULTATION_VOIE_PHYSIQUE" (
    ID_VOIE_PHYSIQUE, 
    TYPE_SENS, 
    GEOM
)        
REFRESH FORCE
START WITH TO_DATE('26-05-2023 10:30:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 1440/24/1440
DISABLE QUERY REWRITE AS
SELECT
    b.objectid AS id_voie_physique,
    'sens conservé' AS type_sens,
    SDO_AGGR_UNION(
        SDOAGGRTYPE(a.geom , 0.005)
    ) AS geom
FROM
    G_BASE_VOIE.TA_TRONCON a
    INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TA_LIBELLE c ON c.objectid = b.fid_action
WHERE
    c.libelle_court = 'à conserver'
GROUP BY
    b.objectid,
    'sens conservé'
UNION ALL
SELECT
    b.objectid AS id_voie_physique,
    'sens inversé' AS type_sens,
    SDO_UTIL.REVERSE_LINESTRING(SDO_AGGR_UNION(SDOAGGRTYPE(a.geom , 0.005))) AS geom
FROM
    G_BASE_VOIE.TA_TRONCON a
    INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TA_LIBELLE c ON c.objectid = b.fid_action
WHERE
    c.libelle_court = 'à inverser'
GROUP BY
    b.objectid,
    'sens inversé';

-- 2. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE IS 'Vue matérialisée matérialisant les voies physiques, permettant de distinguer les voies dont le sens géométrique est inversé ou non.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE.id_voie_physique IS 'Clé primaire de la VM et identifiant des voies physiques.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE.type_sens IS 'Types de sens géométrique des voies. Si elles ont été taguées en "à inverser" dans TA_VOIE_PHYSIQUE, alors le sens géométrique de la voie a été inversé, sinon il a été conservé.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE.geom IS 'Géométries de type multiligne.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_CONSULTATION_VOIE_PHYSIQUE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_CONSULTATION_VOIE_PHYSIQUE 
ADD CONSTRAINT VM_CONSULTATION_VOIE_PHYSIQUE_PK 
PRIMARY KEY (ID_VOIE_PHYSIQUE);

-- 5. Création des index
CREATE INDEX VM_CONSULTATION_VOIE_PHYSIQUE_SIDX
ON G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_CONSULTATION_VOIE_PHYSIQUE_TYPE_SENS_IDX ON G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE(type_sens)
    TABLESPACE G_ADT_INDX;

-- 6. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE TO G_ADMIN_SIG;

/

