/*
Création de la VM VM_CONSULTATION_VOIE_PHYSIQUE matérialisant les voies physiques, permettant de distinguer les voies dont le sens géométrique est réorienté ou non.
*/
-- 1. Suppression de la VM et de ses métadonnées
/*DROP MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_CONSULTATION_VOIE_PHYSIQUE';
COMMIT;
*/
-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_CONSULTATION_VOIE_PHYSIQUE" (
    ID_VOIE_PHYSIQUE, 
    TYPE_SENS, 
    GEOM
)        
REFRESH FORCE
START WITH TO_DATE('06-04-2023 16:00:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 1440/24/1440
DISABLE QUERY REWRITE AS
SELECT
    b.objectid AS id_voie_physique,
    CASE 
        WHEN c.libelle_court = 'à conserver'
            THEN 'sens géométrique originel'
        WHEN c.libelle_court = 'à inverser'
            THEN 'sens géométrique inversé'
    END AS type_sens,
    CASE 
        WHEN c.libelle_court = 'à conserver' 
            THEN SDO_AGGR_UNION(SDOAGGRTYPE(a.geom , 0.005)) 
        WHEN c.libelle_court = 'à inverser' 
            THEN SDO_UTIL.REVERSE_LINESTRING(SDO_AGGR_UNION(SDOAGGRTYPE(a.geom , 0.005)))
    END AS geom
FROM
    G_BASE_VOIE.TA_TRONCON a
    INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TA_LIBELLE c ON c.objectid = b.fid_action
GROUP BY
    b.objectid,
    CASE 
        WHEN c.libelle_court = 'à conserver'
            THEN 'sens géométrique originel'
        WHEN c.libelle_court = 'à inverser'
            THEN 'sens géométrique inversé'
    END;

-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE IS 'Vue matérialisée matérialisant les voies physiques, permettant de distinguer les voies dont le sens géométrique est réorienté ou non.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE.id_voie_physique IS 'Identifiant des voies physique.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE.type_sens IS 'Types de sens géométrique des voies. Si elles ont été taguées en "à inverser" dans TA_VOIE_PHYSIQUE, alors le sens géométrique de la voie a été inversé, sinon il a été conservé.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE.geom IS 'Géométries de type multiligne.';

-- 4. Création des métadonnées spatiales
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

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_CONSULTATION_VOIE_PHYSIQUE 
ADD CONSTRAINT VM_CONSULTATION_VOIE_PHYSIQUE_PK 
PRIMARY KEY (ID_VOIE_PHYSIQUE);

-- 6. Création des index
CREATE INDEX VM_CONSULTATION_VOIE_PHYSIQUE_TYPE_SENS_IDX ON G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE(type_sens)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_VOIE_PHYSIQUE_SIDX
ON G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE TO G_ADMIN_SIG;

/

