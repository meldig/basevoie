/*
Création de la vue matérialisée VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE identifiant les tronçons affectés à plusieurs voies contenues dans une seule commune.
*/
/*
DROP MATERIALIZED VIEW VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE';
COMMIT;
*/
-- 1. Création de la vue matérialisée
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE" ("OBJECTID", "ID_TRONCON", "ID_VOIE", "NOM_VOIE", "VALIDITE", "GEOM") 
REFRESH COMPLETE
START WITH trunc(sysdate) + 16/24
NEXT trunc(sysdate) + 40/24
DISABLE QUERY REWRITE AS
    WITH
        C_1 AS(
            SELECT DISTINCT
                a.id_troncon
            FROM
                G_BASE_VOIE.V_TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE_DOUBLON a
                INNER JOIN G_BASE_VOIE.VM_TEMP_CORRECTION_PROJET_A_VOIE_AGGREGEE b ON b.id_voie = a.id_voie,
                G_REFERENTIEL.MEL_COMMUNE_LLH c
            WHERE
                SDO_OVERLAPBDYDISJOINT(b.geom, c.geom) = 'TRUE'
            GROUP BY
                a.id_troncon
            HAVING
                COUNT(a.id_troncon)>1
        )
        
    SELECT
        rownum AS objectid,
        a.id_troncon,
        c.id_voie,
        d.libelle_voie,
        c.validite,
        b.geom
    FROM
        C_1 a
        INNER JOIN G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON b ON b.objectid = a.id_troncon
        INNER JOIN G_BASE_VOIE.V_TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE_DOUBLON c ON c.id_troncon = a.id_troncon
        INNER JOIN G_BASE_VOIE.VM_TEMP_CORRECTION_PROJET_A_VOIE_AGGREGEE d ON d.id_voie = c.id_voie
    WHERE
        b.cdvaltro = 'V';

-- 2. Création des commentaires
COMMENT ON MATERIALIZED VIEW "G_BASE_VOIE"."VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE"  IS 'Vue matérialisée regroupant les relations tronçon/voies dans lesquelles un tronçon est affecté à plusieurs voie intersectant une limite communale.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE"."OBJECTID" IS 'Clé primaire de la VM.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE"."ID_TRONCON" IS 'Identifiant du tronçon.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE"."ID_VOIE" IS 'Identifiant de la voie.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE"."NOM_VOIE" IS 'Nom de la voie : type de voie + nom de voie + complément nom de voie.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE"."VALIDITE" IS 'Validité de la relation tronçon/voie : ''V'' = valide ; ''F'' = invalide.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE"."GEOM" IS 'Géométrie de type ligne simple de chaque tronçon.';

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE 
ADD CONSTRAINT VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE_PK 
PRIMARY KEY (OBJECTID);

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de l'index spatial
CREATE INDEX VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE_SIDX
ON G_BASE_VOIE.VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 5. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE TO G_ADMIN_SIG;
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE TO G_BASE_VOIE_R;
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_CORRECTION_PROJET_A_TRONCON_DOUBLON_VOIE_OVERLAPBDYDISJOINT_COMMUNE TO G_BASE_VOIE_RW;

/

