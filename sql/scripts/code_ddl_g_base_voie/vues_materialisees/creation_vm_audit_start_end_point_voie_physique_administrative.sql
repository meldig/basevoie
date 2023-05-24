/*
Création de la vue matérialisée VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE - du projet j de test de production - récupérant les start/end points des voies physiques composant les voies administratives dont le type de géométrie est multiligne (donc composées de plusieurs lignes non-jointives).
*/
-- Suppression de la VM et de ses métadonnées
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE (
    GEOM,
    OBJECTID,
    ID_VOIE_ADMINISTRATIVE,
    ID_VOIE_PHYSIQUE,
    TYPE_SOMMET    
)        
REFRESH FORCE
START WITH TO_DATE('16-05-2023 06:00:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 1
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(
        SELECT
            a.id_voie_administrative,
            a.NBR_VOIE_PHYSIQUE
        FROM
            G_BASE_VOIE.V_TA_AUDIT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE a
            INNER JOIN G_BASE_VOIE.VM_VOIE_ADMINISTRATIVE_MATERIALISEE b ON b.id_voie_administrative = a.id_voie_administrative  
        WHERE
            b.geom.sdo_gtype = '2006'
            AND a.NBR_VOIE_PHYSIQUE > 1
    ),

    C_2 AS(
        SELECT
            a.id_voie_administrative,
            c.id_voie_physique,
            SDO_CS.MAKE_2D(SDO_LRS.GEOM_SEGMENT_START_PT(SDO_LRS.CONVERT_TO_LRS_GEOM(c.geom, m.diminfo))) AS geom,
            'startpoint' AS type_sommet
        FROM
            C_1 a
            INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE b ON b.fid_voie_administrative = a.id_voie_administrative
            INNER JOIN G_BASE_VOIE.VM_VOIE_PHYSIQUE_MATERIALISEE_NON_REORIENTEE c ON c.id_voie_physique = b.fid_voie_physique,
            USER_SDO_GEOM_METADATA m 
        WHERE
            m.table_name = 'VM_VOIE_PHYSIQUE_MATERIALISEE_NON_REORIENTEE'
        UNION ALL
        SELECT
            a.id_voie_administrative,
            c.id_voie_physique,
            SDO_CS.MAKE_2D(SDO_LRS.GEOM_SEGMENT_END_PT(SDO_LRS.CONVERT_TO_LRS_GEOM(c.geom, m.diminfo))) AS geom,
            'endpoint' AS type_sommet
        FROM
            C_1 a
            INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE b ON b.fid_voie_administrative = a.id_voie_administrative
            INNER JOIN G_BASE_VOIE.VM_VOIE_PHYSIQUE_MATERIALISEE_NON_REORIENTEE c ON c.id_voie_physique = b.fid_voie_physique,
            USER_SDO_GEOM_METADATA m 
        WHERE
            m.table_name = 'VM_VOIE_PHYSIQUE_MATERIALISEE_NON_REORIENTEE'
    ),
    
    C_3 AS(
        SELECT DISTINCT
            id_voie_administrative,
            id_voie_physique 
        FROM
            C_2
    )
    
    SELECT
        b.geom,
        rownum AS objectid,
        a.id_voie_administrative,
        a.id_voie_physique,
        b.type_sommet
    FROM
        C_3 a
        INNER JOIN C_2 b ON b.id_voie_administrative = a.id_voie_administrative AND b.id_voie_physique = a.id_voie_physique;
    
-- 2. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE IS 'Vue matérialisée - du projet j de test de production - matérialisant les start/end points des voies physiques par voie administrative de type 2006 (donc composée de plusieurs lignes non-jointives).';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE.geom IS 'Géométrie de type point.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE.objectid IS 'Clé primaire de la VM.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE.id_voie_administrative IS 'Identifiants des voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE.id_voie_physique IS 'Identifiants des voies physiques.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE.type_sommet IS 'Start/end points des voies physiques.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE 
ADD CONSTRAINT VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE_PK 
PRIMARY KEY (OBJECTID);

-- 5. Création des index
CREATE INDEX VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE_SIDX
ON G_BASE_VOIE.VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=POINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE_ID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE(id_voie_administrative)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE_ID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE(id_voie_physique)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE_TYPE_SOMMET_IDX ON G_BASE_VOIE.VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE(type_sommet)
    TABLESPACE G_ADT_INDX;

-- 6. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_AUDIT_START_END_POINT_VOIE_PHYSIQUE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

