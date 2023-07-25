/*
Création de la vue matérialisée VM_CONSULTATION_VOIE_SUPRA_COMMUNALE contenant la géométrie des voies supra-communales avec leur identifiant, leur nom et leur géométrie. Mise à jour tous les jours à 23h00.
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
    ID_VOIE_SUPRA_COMMUNALE,
    NOM,
    GEOM
)        
REFRESH FORCE
START WITH TO_DATE('25-07-2023 23:00:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 1
DISABLE QUERY REWRITE AS
    WITH 
        C_1 AS(
            SELECT
                coalesce(c.id_sireo, TO_CHAR(c.objectid)) AS id_voie_supra_communale,
                c.nom,
                SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005)) AS geom
            FROM 
                G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE a 
                INNER JOIN G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE b ON b.id_voie_administrative = a.fid_voie_administrative
                INNER JOIN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE c ON c.objectid = a.fid_voie_supra_communale
            GROUP BY
                coalesce(c.id_sireo, TO_CHAR(c.objectid)),
                c.objectid,
                c.nom
        )

        SELECT
            rownum AS objectid,
            a.id_voie_supra_communale,
            a.nom,
            a.geom
        FROM
            C_1 a;

-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE IS 'Vue matérialisée contenant la géométrie des voies supra-communales avec leur identifiant, leur nom et leur géométrie. Mise à jour quotidienne à 23h00.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE.objectid IS 'Clé primaire auto-incrémentée de la VM.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE.id_voie_supra_communale IS 'Identifiants des voies supra-communales correspondant aux dentifiants des ex-rd et des voies supra-communales antérieures à la migration (TA_VOIE_SUPRA_COMMUNALE.id_sireo) et aux identifiants des voies supra-communales postérieures à la migration (TA_VOIE_SUPRA_COMMUNALE.objectid).';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE.nom IS 'Nom de la voie supra-communale : s''il s''agit d''une ex RD au moement de l''import, alors l''idsupvoi de la table SIREO_LEC.EXRD_IDSUPVOIE est utilisé, s''il s''agit d''une voie supra-communale absente de la table SIREO_LEC.EXRD_IDSUPVOIE au moment de l''import alors l''idvoi de SIREO_LEC.OUT_DOMANIALITE est utilisé. Pour toute nouvelle voie supra-communale post-import, le nom correspond à l''identifiant auto-incrémenté de la voie.';
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

CREATE INDEX VM_CONSULTATION_VOIE_SUPRA_COMMUNALE_ID_VOIE_SUPRA_COMMUNALE_IDX ON G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE(id_voie_supra_communale)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_VOIE_SUPRA_COMMUNALE_NOM_IDX ON G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE(nom)
    TABLESPACE G_ADT_INDX;

-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE TO G_ADMIN_SIG;
GRANT SELECT ON G_BASE_VOIE.VM_CONSULTATION_VOIE_SUPRA_COMMUNALE TO G_BASE_VOIE_R;

/

