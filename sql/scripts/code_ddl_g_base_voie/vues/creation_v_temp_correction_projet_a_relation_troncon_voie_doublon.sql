/*
Création de la vue V_TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE_DOUBLON permettant d'identifier et de corriger les tronçons affectés à plusieurs voies dans les tables transitoires.
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE_DOUBLON" ("ID_TRONCON", "ID_VOIE", "VALIDITE", "GEOM", 
    CONSTRAINT "V_TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE_DOUBLON_PK" PRIMARY KEY ("ID_TRONCON") DISABLE) AS 
WITH
    C_1 AS(-- Sélection des tronçons affectés à plusieurs voies
        SELECT
            fid_troncon
        FROM
            G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE
        WHERE
            cvalide = 'V'
        GROUP BY
            fid_troncon
        HAVING
            COUNT(fid_troncon) > 1
    )
    
    SELECT
        a.objectid AS id_troncon,
        d.objectid AS id_voie,
        c.cvalide AS validite,
        a.geom
    FROM
        G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_TRONCON a
        INNER JOIN C_1 b ON b.fid_troncon = a.objectid
        INNER JOIN G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE c ON c.fid_troncon = a.objectid
        INNER JOIN G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_VOIE d ON d.objectid = c.fid_voie
    WHERE
        a.cdvaltro = 'V'
        AND c.cvalide = 'V'
        AND d.cdvalvoi = 'V';
    
-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE_DOUBLON IS 'Vue identifiant les tronçons affectés à plusieurs voies avec la géométrie des tronçons. Cette vue sert à corriger les tronçons affectés à plusieurs voies ET DOIT UNIQUEMENT ETRE UTILISEE DANS CE CAS.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE_DOUBLON.id_troncon IS 'Identifiant de chaque tronçon affecté à plusieurs voies.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE_DOUBLON.id_voie IS 'Identifiant de chaque voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE_DOUBLON.validite IS 'Champ indiquant si la relation tronçon/voie est valide. La modification de ce champ dans QGIS modifie les données dans les tables transitoires.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE_DOUBLON.geom IS 'Géométrie de type poyligne des tronçons.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE_DOUBLON',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

/

