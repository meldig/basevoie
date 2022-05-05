/*
Correction des erreurs de la base voie via des requête SQL (le reste sera traité manuellement via un projet QGIS par les agents charger de produire la donnée).
*/

-- Suppression des doublons de voie absolus
DELETE FROM
    G_BASE_VOIE.TEMP_PROJET_A_VOIE
WHERE
    objectid IN(
        WITH
            C_1 AS(-- Sélection des voies en doublon de nom, commune, longueur
                SELECT
                    libelle_voie,
                    longueur,
                    GET_TEMP_CODE_INSEE_97_COMMUNES_TRONCON('VM_TEMP_PROJET_A_VOIE_AGGREGEE', geom) AS code_insee_voie
                FROM
                    G_BASE_VOIE.VM_TEMP_PROJET_A_VOIE_AGGREGEE
                GROUP BY
                    libelle_voie,
                    longueur,
                    GET_TEMP_CODE_INSEE_97_COMMUNES_TRONCON('VM_TEMP_PROJET_A_VOIE_AGGREGEE', geom)
                HAVING
                    COUNT(libelle_voie)>1
                    AND COUNT(longueur)>1
                    AND COUNT(GET_TEMP_CODE_INSEE_97_COMMUNES_TRONCON('VM_TEMP_PROJET_A_VOIE_AGGREGEE', geom))>1
            ),
            
            C_2 AS(-- Sélection des identifiants des voies en doublons
                SELECT
                    a.*,
                    GET_TEMP_CODE_INSEE_97_COMMUNES_TRONCON('VM_TEMP_PROJET_A_VOIE_AGGREGEE', a.geom) AS code_insee
                FROM
                    G_BASE_VOIE.VM_TEMP_PROJET_A_VOIE_AGGREGEE a,
                    C_1 b
                WHERE
                    a.libelle_voie = b.libelle_voie
                    AND a.longueur = b.longueur
                    AND b.code_insee_voie = GET_TEMP_CODE_INSEE_97_COMMUNES_TRONCON('VM_TEMP_PROJET_A_VOIE_AGGREGEE', a.geom)
                ORDER BY
                    a.libelle_voie,
                    a.longueur,
                    GET_TEMP_CODE_INSEE_97_COMMUNES_TRONCON('VM_TEMP_PROJET_A_VOIE_AGGREGEE', a.geom)
            ),
            
            C_3 AS( -- Vérification que les voies en doublons ont exactement la même géométrie
                SELECT
                    a.id_voie AS voie_a,
                    b.id_voie AS voie_b
                FROM
                    G_BASE_VOIE.VM_TEMP_PROJET_A_VOIE_AGGREGEE a,
                    C_2 b
                WHERE
                    a.id_voie < b.id_voie
                    AND a.longueur = b.longueur
                    AND GET_TEMP_CODE_INSEE_97_COMMUNES_TRONCON('VM_TEMP_PROJET_A_VOIE_AGGREGEE', a.geom) = b.code_insee
                    AND SDO_EQUAL(a.geom, b.geom) = 'TRUE'
            )
            
        SELECT
            voie_b
        FROM
            C_3
    );
    -- 34 voies supprimées
    
    -- Suppression des relations tronçons/voies dont le code INSEE du tronçon diffère de celui de la voie
    DELETE FROM TEMP_PROJET_A_RELATION_TRONCON_VOIE
    WHERE 
        cvalide = 'V'
        AND objectid IN(
            WITH
                C_1 AS(-- Sélection des tronçons affectés à plusieurs voies
                    SELECT
                        fid_troncon
                    FROM
                        G_BASE_VOIE.TEMP_PROJET_A_RELATION_TRONCON_VOIE
                    WHERE
                        cvalide = 'V'
                    GROUP BY
                        fid_troncon
                    HAVING
                        COUNT(fid_troncon) > 1
                ),
                
                C_2 AS(-- Sélection du code insee des tronçons et des voies auxquelles ils sont affectés
                    SELECT
                        a.fid_troncon AS id_troncon,
                        GET_TEMP_CODE_INSEE_97_COMMUNES_TRONCON('TEMP_PROJET_A_TRONCON', c.geom) AS code_insee_troncon,
                        d.id_voie,
                        GET_TEMP_CODE_INSEE_97_COMMUNES_TRONCON('TEMP_PROJET_A_TRONCON', d.geom) AS code_insee_voie,
                        d.longueur AS longueur_voie
                    FROM
                        G_BASE_VOIE.TEMP_PROJET_A_RELATION_TRONCON_VOIE a
                        INNER JOIN C_1 b ON b.fid_troncon = a.fid_troncon
                        INNER JOIN G_BASE_VOIE.TEMP_PROJET_A_TRONCON c ON c.objectid = b.fid_troncon
                        INNER JOIN G_BASE_VOIE.VM_TEMP_PROJET_A_VOIE_AGGREGEE d ON d.id_voie = a.fid_voie
                        INNER JOIN G_BASE_VOIE.TEMP_PROJET_A_VOIE e ON e.objectid = a.fid_voie
                    WHERE
                        a.cvalide = 'V'
                        AND c.cdvaltro = 'V'
                        AND e.cdvalvoi = 'V'
                )
                
                -- Sélection des tronçons ne disposant pas du même code INSEE que leur voie
                SELECT
                    b.objectid
                FROM
                    C_2 a
                    INNER JOIN G_BASE_VOIE.TEMP_PROJET_A_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.id_troncon  AND b.fid_voie = a.id_voie
                WHERE
                    a.code_insee_troncon <> a.code_insee_voie
                    AND b.cvalide = 'V'
            );
-- 735 relations tronçon/voie supprimées