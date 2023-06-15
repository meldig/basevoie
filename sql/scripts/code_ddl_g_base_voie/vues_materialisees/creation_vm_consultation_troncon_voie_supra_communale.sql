/*
Création de la vue matérialisée VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE faisant le lien entre les tronçons et les voies supra-communales.
*/
/*
DROP INDEX VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE';
COMMIT;
*/
-- 1. Création de la vue matérialisée
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE(
    geom,
    objectid,
    id_troncon,
    id_voie_supra_communale,
    nom_voie_supra_communale
)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(
        SELECT
            a.fid_voie_supra_communale AS id_voie_supra_communale,
            b.nom
        FROM 
            G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE a
            INNER JOIN SIREO_LEC.EXRD_IDSUPVOIE b ON b.idsupvoi = a.fid_voie_supra_communale
    ),

    C_2 AS(
        SELECT DISTINCT
            a.id_troncon,
            b.fid_voie_supra_communale AS id_voie_supra_communale,
            CASE
                WHEN c.nom IS NOT NULL THEN 
                    c.nom
                WHEN c.nom IS NULL AND a.lateralite = 'droit' THEN
                    a.nom_voie
            END AS nom_voie_supra_communale
        FROM
            G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE a
            INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE b ON b.fid_voie_administrative = a.id_voie_administrative
            LEFT JOIN C_1 c ON c.id_voie_supra_communale = b.fid_voie_supra_communale
    )
    
    SELECT
        a.geom,
        rownum AS objectid,
        b.id_troncon,
        b.id_voie_supra_communale,
        b.nom_voie_supra_communale
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN C_2 b ON b.id_troncon = a.objectid;

-- 2. Création des commentaires sur la table et les champs
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE IS 'Vue matérialisée faisant le lien entre les tronçons et les voies supra-communales.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE.geom IS 'Géométrie du tronçon de type ligne simple.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE.objectid IS 'Clé primaire de la vue matérialisée.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE.id_troncon IS 'Identifiants du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE.id_voie_supra_communale IS 'Identifiants des voies supra-communales.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE.nom_voie_supra_communale IS 'Nom de la voie supra-communale - lorsqu''il s''agit d''une ex-route départementale le nom de cette ex-RD est conservé, sinon le nom de la voie administrative de droite est utilisé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE 
ADD CONSTRAINT VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE_SIDX
ON G_BASE_VOIE.VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des index sur les clés étrangères et autres
CREATE INDEX VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE_ID_TRONCON_IDX ON G_BASE_VOIE.VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE(id_troncon)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE_ID_VOIE_SUPRA_COMMUNALE_IDX ON G_BASE_VOIE.VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE(id_voie_supra_communale)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE_NOM_VOIE_SUPRA_COMMUNALE_IDX ON G_BASE_VOIE.VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE(nom_voie_supra_communale)
    TABLESPACE G_ADT_INDX;

-- 7. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE TO G_ADMIN_SIG;
GRANT SELECT ON G_BASE_VOIE.VM_CONSULTATION_TRONCON_VOIE_SUPRA_COMMUNALE TO G_BASE_VOIE_R;

/

