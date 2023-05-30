/*
Création de la vue V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE dénombrant tous les objets de la base voie et de la base adresse.
*/
/*
DROP VIEW G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE table_name = 'V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE';
COMMIT;
*/

-- 1. Création de la vue
##########A REFAIRE#################################
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE" (
    id_seuil,
    nombre,
    geom, 
    CONSTRAINT "V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE_PK" PRIMARY KEY ("ID_SEUIL") DISABLE) AS 
    WITH 
        C_1 AS(
            SELECT
                a.objectid AS id_seuil,
                a.fid_seuil,
                COUNT(a.objectid) AS nombre
            FROM
                G_BASE_VOIE.TA_INFOS_SEUIL a
            GROUP BY 
                a.objectid,
                a.fid_seuil
            HAVING
                COUNT(a.objectid) > 1
        )

        SELECT
            a.id_seuil
            a.nombre,
            b.geom
        FROM
            C_1 a
            INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
     ;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE IS 'Vue dénombrant les seuils par géométrie, pour chaque géométrie disposant de plus d''un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE.id_seuil IS 'Clé primaire de la vue correspondant aux identifiants des seuils.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE.nombre IS 'Nombre de seuils par localisation (géométrie).';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE.geom IS 'Géométrie de type point des seuils.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 4. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE TO G_ADMIN_SIG;

/

