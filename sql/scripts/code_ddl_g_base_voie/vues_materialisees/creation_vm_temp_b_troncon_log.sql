/*
Création de la Vue matérialisée VM_TEMP_B_TRONCON_LOG - du projet B de correction de la topologie des tronçons - contenant les tronçons de la base voie. Cette VM est rafraîchie tous les jours à 07h00, ce qui permet de toujours revenir un jour en arrière au besoin.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_B_TRONCON_LOG;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TEMP_B_TRONCON_LOG';
*/

CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_B_TRONCON_LOG(OBJECTID, GEOM, DATE_SAISIE, DATE_MODIFICATION, FID_PNOM_SAISIE, FID_PNOM_MODIFICATION, FID_ETAT, OUVRAGE_ART)
REFRESH FORCE ON DEMAND START WITH TO_DATE('2022/09/29 07:00:00', 'YYYY/MM/DD HH:MI:SS') NEXT(SYSDATE+31/24)
DISABLE QUERY REWRITE AS
  SELECT
        OBJECTID,
        GEOM,
        DATE_SAISIE,
        DATE_MODIFICATION,
        FID_PNOM_SAISIE,
        FID_PNOM_MODIFICATION,
        FID_ETAT,
        OUVRAGE_ART
    FROM
        G_BASE_VOIE.TEMP_B_TRONCON;

-- 2. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_B_TRONCON_LOG',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_B_TRONCON_LOG 
ADD CONSTRAINT VM_TEMP_B_TRONCON_LOG_PK 
PRIMARY KEY (OBJECTID);

-- 4. Création de l'index spatial
CREATE INDEX VM_TEMP_B_TRONCON_LOG_SIDX
ON G_BASE_VOIE.VM_TEMP_B_TRONCON_LOG(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=LINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_B_TRONCON_LOG IS 'Vue matérialisée - du projet B de correction de la topologie des tronçons - contenant les tronçons de la base voie. Cette VM est rafraîchie tous les jours à 07h00, ce qui permet de toujours revenir un jour en arrière au besoin.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_B_TRONCON_LOG.objectid IS 'Clé primaire de la VM identifiant chaque tronçon. Cette pk est auto-incrémentée et remplace l''ancien identifiant cnumtrc.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_B_TRONCON_LOG.geom IS 'Géométrie de type ligne simple de chaque tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_B_TRONCON_LOG.date_saisie IS 'date de saisie du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_B_TRONCON_LOG.date_modification IS 'Dernière date de modification du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_B_TRONCON_LOG.fid_pnom_saisie IS 'Clé étrangère vers la table TEMP_C_AGENT permettant de récupérer le pnom de l''agent ayant créé un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_B_TRONCON_LOG.fid_pnom_modification IS 'Clé étrangère vers la table TEMP_C_AGENT permettant de récupérer le pnom de l''agent ayant modifié un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_B_TRONCON_LOG.fid_etat IS 'Etat d''avancement des corrections : en erreur, corrigé, correct.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_B_TRONCON_LOG.ouvrage_art IS 'Champ permettant de distinguer attributairement les tronçons situés sur un ouvrage d''art ou l''intersectant, des autres.';

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_B_TRONCON_LOG TO G_ADMIN_SIG;

/

