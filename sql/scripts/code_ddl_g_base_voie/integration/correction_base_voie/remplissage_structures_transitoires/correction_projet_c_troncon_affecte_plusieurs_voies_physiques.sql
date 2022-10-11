/*
Contexte :
 Un tronçon est, dans la structure du projet B, affecté à deux voies physiques car il se situe en limite de commune. Il appartient donc à la voie de la commune A et à celle de la commune B.
Il est donc impossible qu'un tronçon soit affecté à plus de deux voies physiques, sauf erreur de saisie.

Objectif :
Passer d'une structure où un tronçon est affectés à une ou plusieurs voies physiques, chacune d'elle affectée à une et une seule voie administrative
à une structure où un tronçon est affecté à une et une seule voie physique, pouvant être affectée à une ou plusieurs voies administratives 
*/
  
-- Insertion des voies physiques
MERGE INTO G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE a
    USING(
        WITH
            C_1 AS(
                SELECT
                    COUNT(*),
                    fid_troncon
                FROM
                    G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE
                GROUP BY
                    fid_troncon
                HAVING
                    COUNT(fid_troncon) > 1
            )
            
            SELECT DISTINCT
                a.fid_voie_physique AS objectid
            FROM
                G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE a
                INNER JOIN C_1 b ON b.fid_troncon = a.fid_troncon
        )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid)
    VALUES(t.objectid);
-- Résultat : 602  lignes fusionnées.

-- Insertion des relations tronçons / voies physiques pour lesquelles un tronçon est affecté à plusieurs voies physiques
MERGE INTO G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE a
    USING(
            WITH
            C_1 AS(
                SELECT
                    COUNT(*),
                    fid_troncon
                FROM
                    G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE
                GROUP BY
                    fid_troncon
                HAVING
                    COUNT(fid_troncon) > 1
            )
            
            SELECT
                a.fid_troncon,
                a.fid_voie_physique
            FROM
                G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE a
                INNER JOIN C_1 b ON b.fid_troncon = a.fid_troncon
    )t
ON(a.fid_voie_physique = t.fid_voie_physique AND a.fid_troncon = t.fid_troncon)
WHEN NOT MATCHED THEN
    INSERT(a.fid_voie_physique, a.fid_troncon, a.old_id_voie_physique)
    VALUES(t.fid_voie_physique, t.fid_troncon, t.fid_voie_physique);
-- Résultat : 1674 lignes fusionnées

-- Insertion des relations voies physiques / voies administratives
MERGE INTO G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
    USING(
        WITH
            C_1 AS(
                SELECT
                    fid_troncon
                FROM
                    G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE
                GROUP BY
                    fid_troncon
                HAVING
                    COUNT(fid_troncon) > 1
            )
                
            SELECT DISTINCT
                a.fid_voie_physique,
                c.objectid AS fid_voie_administrative
            FROM
                G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE a
                INNER JOIN G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE c ON c.fid_voie_physique = a.fid_voie_physique
                INNER JOIN C_1 b ON b.fid_troncon = a.fid_troncon
    )t
ON(a.fid_voie_physique = t.fid_voie_physique AND a.fid_voie_administrative = t.fid_voie_administrative)
WHEN NOT MATCHED THEN
    INSERT(a.fid_voie_physique, a.fid_voie_administrative)
    VALUES(t.fid_voie_physique, t.fid_voie_administrative);
-- Résultat : 602 lignes fusionnées.
    
-- Vidange de la table TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE
DELETE FROM G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE;

-- Remplissage de la table TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE
INSERT INTO G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE(OLD_ID_VOIE_PHYSIQUE, OLD_ID_VOIE_ADMINISTRATIVE, ID_TRONCON)
SELECT
    fid_voie_physique,
    fid_voie_physique,
    fid_troncon
FROM
    G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE;
    
-- Objectif : créer de nouveaux identifiants de voie
MERGE INTO G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE a
    USING(
        WITH
            C_1 AS(
                SELECT DISTINCT
                    id_troncon
                FROM
                    G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE
            ),
            
            C_2 AS(
                SELECT
                    MAX(objectid) AS max_id_voie_physique
                FROM
                    G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE
            )
            
            SELECT
                a.id_troncon,
                b.max_id_voie_physique + rownum AS new_id_voie_physique
            FROM
                C_1 a,
                C_2 b
    )t
ON(a.id_troncon = t.id_troncon)
WHEN MATCHED THEN
    UPDATE SET a.new_id_voie_physique = t.new_id_voie_physique;
-- 1 674 lignes fusionnées

-- Insertion des nouvelles voies physiques
INSERT INTO G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE(objectid)
SELECT DISTINCT
    new_id_voie_physique
FROM
    G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE;
    
-- Suppression des relations tronçons/voies physiques
DELETE FROM G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE;

-- Correction des relations tronçon/voies physiques
INSERT INTO G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE(fid_troncon, fid_voie_physique)
    SELECT DISTINCT
        id_troncon,
        new_id_voie_physique
    FROM
        G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE;
        
-- Suppression des relations voies physiques / administratives
DELETE FROM G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE;

-- Insertion des nouvelles relations voies physiques / administratives
INSERT INTO G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE(fid_voie_physique, fid_voie_administrative)
    SELECT DISTINCT
        new_id_voie_physique,
        old_id_voie_administrative
    FROM
        G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE;
-- Résultat : 1 674 lignes insérées.

-- Insertion des voies physiques
MERGE INTO G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE a
    USING(
        WITH
            C_1 AS(
                SELECT
                    COUNT(*),
                    fid_troncon
                FROM
                    G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE
                GROUP BY
                    fid_troncon
                HAVING
                    COUNT(fid_troncon) = 1
            )
            
            SELECT DISTINCT
                a.fid_voie_physique AS objectid
            FROM
                G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE a
                INNER JOIN C_1 b ON b.fid_troncon = a.fid_troncon
        )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
    INSERT(a.objectid)
    VALUES(t.objectid);
-- Résultat : 21 495  lignes fusionnées.

-- Insertion des relations tronçons / voies physiques pour lesquelles un tronçon est affecté à plusieurs voies physiques
MERGE INTO G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE a
    USING(
            WITH
            C_1 AS(
                SELECT
                    COUNT(*),
                    fid_troncon
                FROM
                    G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE
                GROUP BY
                    fid_troncon
                HAVING
                    COUNT(fid_troncon) = 1
            )
            
            SELECT
                a.fid_troncon,
                a.fid_voie_physique
            FROM
                G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE a
                INNER JOIN C_1 b ON b.fid_troncon = a.fid_troncon
    )t
ON(a.fid_voie_physique = t.fid_voie_physique AND a.fid_troncon = t.fid_troncon)
WHEN NOT MATCHED THEN
    INSERT(a.fid_voie_physique, a.fid_troncon, a.old_id_voie_physique)
    VALUES(t.fid_voie_physique, t.fid_troncon, t.fid_voie_physique);
-- Résultat : 49 593 lignes fusionnées

-- Insertion des relations voies physiques / voies administratives
MERGE INTO G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
    USING(
        WITH
            C_1 AS(
                SELECT
                    fid_troncon
                FROM
                    G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE
                GROUP BY
                    fid_troncon
                HAVING
                    COUNT(fid_troncon) = 1
            )
                
            SELECT DISTINCT
                a.fid_voie_physique,
                c.objectid AS fid_voie_administrative
            FROM
                G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE a
                INNER JOIN G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE c ON c.fid_voie_physique = a.fid_voie_physique
                INNER JOIN C_1 b ON b.fid_troncon = a.fid_troncon
    )t
ON(a.fid_voie_physique = t.fid_voie_physique AND a.fid_voie_administrative = t.fid_voie_administrative)
WHEN NOT MATCHED THEN
    INSERT(a.fid_voie_physique, a.fid_voie_administrative)
    VALUES(t.fid_voie_physique, t.fid_voie_administrative);
-- Résultat : 21 978 lignes fusionnées

/
