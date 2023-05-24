/*
Création de la vue faisant le lien entre les tronçons et leur voie, tout en récupérant les coordonnées de leur start/end point, l'ordre des tronçons par voie, la longueur des tronçons et leur code insee.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_H_VOIE_PHYSIQUE_UN_TRONCON;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TEMP_H_VOIE_PHYSIQUE_UN_TRONCON';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_H_VOIE_PHYSIQUE_UN_TRONCON (ID_TRONCON, ID_VOIE_PHYSIQUE, GEOM)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
    WITH 
        C_1 AS(
            SELECT
                a.fid_voie_physique,
                COUNT(a.objectid) AS nbr_trc
            FROM
                G_BASE_VOIE.TEMP_H_TRONCON a
            GROUP BY
                a.fid_voie_physique
            HAVING
                COUNT(a.objectid) = 1
        ),

        C_2 AS(
            SELECT
                a.fid_voie_administrative
            FROM
                G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
            GROUP BY
                a.fid_voie_administrative
            HAVING
                COUNT(a.fid_voie_physique) = 1
        ),

        C_3 AS(
            SELECT
                a.fid_voie_physique,
                a.fid_voie_administrative
            FROM
                G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
                INNER JOIN C_1 b ON b.fid_voie_physique = a.fid_voie_physique
                INNER JOIN C_2 c ON c.fid_voie_administrative = a.fid_voie_administrative
        )

        SELECT
            a.objectid AS id_troncon,
            b.fid_voie_physique AS id_voie_physique,
            a.geom
        FROM
            G_BASE_VOIE.TEMP_H_TRONCON a 
            INNER JOIN C_3 b ON b.fid_voie_physique = a.fid_voie_physique;
        
-- 2. Création des commentaires de la VM
   COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_H_VOIE_PHYSIQUE_UN_TRONCON.ID_TRONCON IS 'Identifiant des tronçons de la table TEMP_H_TRONCON.';
   COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_H_VOIE_PHYSIQUE_UN_TRONCON.ID_VOIE_PHYSIQUE IS 'Identifiant des voies physiques de la table TEMP_H_VOIE_PHYSIQUE.';
   COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_H_VOIE_PHYSIQUE_UN_TRONCON.GEOM IS 'Géométrie des tronçons composant les voies physiques.';
   COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_H_VOIE_PHYSIQUE_UN_TRONCON  IS 'Vue matérialisée regroupant les voies physiques composées d''un seul tronçon. Chacune de ces voies physiques composent à elles seules la voie administrative qui leur est associée.';

-- 3. Remplissage des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_H_VOIE_PHYSIQUE_UN_TRONCON',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_H_VOIE_PHYSIQUE_UN_TRONCON 
ADD CONSTRAINT VM_TEMP_H_VOIE_PHYSIQUE_UN_TRONCON_PK 
PRIMARY KEY (ID_VOIE_PHYSIQUE);

-- 5. Création des index
CREATE INDEX VM_TEMP_H_VOIE_PHYSIQUE_UN_TRONCON_SIDX
ON G_BASE_VOIE.VM_TEMP_H_VOIE_PHYSIQUE_UN_TRONCON(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_TEMP_H_VOIE_PHYSIQUE_UN_TRONCON_ID_TRONCON_IDX ON G_BASE_VOIE.VM_TEMP_H_VOIE_PHYSIQUE_UN_TRONCON(id_troncon)
    TABLESPACE G_ADT_INDX;

-- 6. Don du droit de lecture de la vue matérialisée au schéma G_BASE_VOIE_LEC et aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_H_VOIE_PHYSIQUE_UN_TRONCON TO G_ADMIN_SIG;

/

