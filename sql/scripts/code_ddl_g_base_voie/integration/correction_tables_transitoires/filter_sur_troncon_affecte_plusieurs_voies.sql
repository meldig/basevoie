/*
Suppression des données non-concernées par les tronçons affectés à plusieurs voies
*/

-- Suppression des tronçons non affectés à plusieurs voies
DELETE FROM TEMP_CORRECTION_PROJET_A_TRONCON
WHERE
    objectid NOT IN(
        WITH
            C_1 AS(
                SELECT
                    id_troncon
                FROM
                    G_BASE_VOIE.V_TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE_DOUBLON
                UNION ALL
                SELECT
                    id_troncon
                FROM
                    G_BASE_VOIE.V_TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE_DOUBLON
            )
        
        SELECT DISTINCT
            id_troncon
        FROM
            C_1
    );
    
-- Suppression des voies auxquelles un tronçon est affecté plusieurs fois 
DELETE FROM TEMP_CORRECTION_PROJET_A_VOIE
WHERE
    objectid NOT IN(
        WITH
            C_1 AS(
                SELECT
                    id_voie
                FROM
                    G_BASE_VOIE.V_TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE_DOUBLON
                UNION ALL
                SELECT
                    id_voie
                FROM
                    G_BASE_VOIE.V_TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE_DOUBLON
            )
        
        SELECT DISTINCT
            id_voie
        FROM
            C_1
    );
    
-- Suppression des relations tronçons/voies dans lesquelles un tronçon est affecté à plusieurs voies 
DELETE FROM TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE
WHERE
    fid_troncon NOT IN(
        SELECT
            objectid
        FROM
            TEMP_CORRECTION_PROJET_A_TRONCON
    )
    AND fid_voie NOT IN(
        SELECT
            objectid
        FROM
            TEMP_CORRECTION_PROJET_A_VOIE
    );