/*
Création de la vue V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE dénombrant tous les objets de la base voie et de la base adresse.
*/
/*
DROP VIEW G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE" (
    OBJECTID, 
    NOMBRE, 
    GEOM, 
    CONSTRAINT "V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
    WITH
        C_1 AS(
            SELECT
                a.fid_seuil,
                COUNT(a.objectid) AS nombre
            FROM
                G_BASE_VOIE.TA_INFOS_SEUIL a
            GROUP BY 
                a.fid_seuil
            HAVING
                COUNT(a.objectid) > 1
        )
        
        SELECT
            a.objectid,
            b.nombre,
            a.geom
        FROM
            G_BASE_VOIE.TA_SEUIL a
            INNER JOIN C_1 b ON b.fid_seuil = a.objectid;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE IS 'Vue dénombrant les seuils partageant la même géométrie (seules les géométries associées à plusieurs seuils sont sélectionnées dans cette vue).';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE.objectid IS 'Clé primaire de la vue correspondant aux identifiants des géométries des seuils présents dans G_BASE_VOIE.TA_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE.nombre IS 'Nombre de seuils (de la table G_BASE_VOIE_INFOS_SEUIL) par géométrie. Seuls les géométries associées à plusieurs seuils sont présentes dans cette table.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE.geom IS 'Géométrie de type point.';

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
COMMIT;

-- 4. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE TO G_ADMIN_SIG;

/

