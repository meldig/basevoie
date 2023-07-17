/*
Création de la vue matérialisée VM_CONSULTATION_VOIE_SUPRA_COMMUNALE contenant la géométrie des voies administratives avec leur nom, code insee, latéralité et hiérarchie.  Mise à jour du lundi au vendredi à 22h00.
*/
-- 1. Suppression de la VM et de ses métadonnées
/*
DROP INDEX VM_CONSULTATION_VOIE_SUPRA_COMMUNALE_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_CONSULTATION_VOIE_SUPRA_COMMUNALE';
COMMIT;
*/
-- 2. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE (
    OBJECTID,
    NOM,
    GEOM
)        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
    SELECT
        rownum AS objectid,
        a.nom
        SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005)) AS geom
    FROM 
        G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE a 
        INNER JOIN G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE b ON b.id_voie_administrative = a.fid_voie_administrative
        INNER JOIN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE c ON c.objectid = a.fid_voie_supra_communale
    GROUP BY
        a.fid_voie_supra_communale;

-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE IS 'Vue matérialisée contenant la géométrie des voies administratives avec leur nom, code insee, latéralité et hiérarchie. Mise à jour du lundi au vendredi à 22h00.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE.objectid IS 'Clé primaire de la VM.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE.nom IS 'Nom de la voie supra-communale : s''il s''agit d''une ex RD, alors l''idsupvoi de la table SIREO_LEC.EXRD_IDSUPVOIE est utilisé, s''il s''agit d''une voie supra-communale absente de la table SIREO_LEC.EXRD_IDSUPVOIE au moment de l''import alors l''idvoi de SIREO_LEC.OUT_DOMANIALITE est utilisé. Pour toute nouvelle voie supra-communale, le nom correspond à l''identifiant de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE.geom IS 'Géométrie des voies supra-communales de type multiligne.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_CONSULTATION_VOIE_SUPRA_COMMUNALE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_CONSULTATION_VOIE_SUPRA_COMMUNALE 
ADD CONSTRAINT VM_CONSULTATION_VOIE_SUPRA_COMMUNALE_PK 
PRIMARY KEY (OBJECTID);

-- 6. Création des index
CREATE INDEX VM_CONSULTATION_VOIE_SUPRA_COMMUNALE_SIDX
ON G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_CONSULTATION_VOIE_SUPRA_COMMUNALE_NOM_IDX ON G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE(nom)
    TABLESPACE G_ADT_INDX;

-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE TO G_ADMIN_SIG;
GRANT SELECT ON G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE TO G_BASE_VOIE_R;

/

