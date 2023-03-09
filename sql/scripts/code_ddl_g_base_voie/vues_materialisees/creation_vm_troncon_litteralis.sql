/*
Création de la vue matérialisée VM_TRONCON_LITTERALIS_2023 mettant les tronçons au format d'export LITTERALIS
Cette VM est utilisée pour exporter les données pour le prestataire Sogelink.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TRONCON_LITTERALIS_2023';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TRONCON_LITTERALIS_2023" ("CODE_TRONC","CLASSEMENT","CODE_RUE_G","NOM_RUE_G","INSEE_G","CODE_RUE_D","NOM_RUE_D","INSEE_D","LARGEUR","GEOMETRY")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
    SELECT
        a.code_tronc,
        a.classement,
        e.code_voie AS CODE_RUE_G,
        e.nom_voie AS NOM_RUE_G,
        e.code_insee AS INSEE_G,    
        c.code_voie AS CODE_RUE_D,
        c.nom_voie AS NOM_RUE_D,
        c.code_insee AS INSEE_D,
        CAST('' AS NUMBER(8,0)) AS LARGEUR,
        z.geom AS GEOMETRY
    FROM
        G_BASE_VOIE.TA_TAMPON_LITTERALIS_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_H_TRONCON z ON z.objectid = a.objectid
        INNER JOIN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE b ON b.fid_voie_physique = z.fid_voie_physique
        INNER JOIN G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE c ON c.objectid = b.fid_voie_administrative
        INNER JOIN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = z.fid_voie_physique
        INNER JOIN G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE e ON e.objectid = d.fid_voie_administrative
    WHERE
        b.fid_lateralite IN(1,3)
        AND d.fid_lateralite IN(2,3);
        
-- 2. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023 IS 'Vue matérialisée regroupant les tronçons au format d''export LITTERALIS. Cette VM est faite à partir des tables préfixées par ''TA_TAMPON_LITTERALIS'' et de quelques tables de la base voie MEL.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023.CODE_TRONC IS 'Identificateur unique et immuable du tronçon de voie partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023.CLASSEMENT IS 'Classement de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023.CODE_RUE_G IS 'Code unique de la rue côté gauche du tronçon partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023.NOM_RUE_G IS 'Nom de la voie côté gauche du tronçon (telle qu’affichée dans les arrêtés et autorisations).';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023.INSEE_G IS 'Code INSEE de la commune côté gauche du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023.CODE_RUE_D IS 'Code unique de la rue côté droit du tronçon partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023.NOM_RUE_D IS 'Nom de la voie côté droit du tronçon (telle qu’affichée dans les arrêtés et autorisations).';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023.INSEE_D IS 'Code INSEE de la commune côté droit du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023.LARGEUR IS 'Valeur indiquant une largeur de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023.GEOMETRY IS 'Géométrie de type ligne simple des tronçons.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TRONCON_LITTERALIS_2023',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TRONCON_LITTERALIS_2023 
ADD CONSTRAINT VM_TRONCON_LITTERALIS_2023_PK 
PRIMARY KEY (CODE_TRONC);

-- 5. Création de l'index spatial
CREATE INDEX VM_TRONCON_LITTERALIS_2023_SIDX
ON G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=LINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 6. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TRONCON_LITTERALIS_2023 TO G_ADMIN_SIG;

/

