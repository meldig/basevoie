/*
Correction des tronçons affectés à plusieurs voies physiques :
migration pour passer à un tronçon relié à une et une seule voie physique.
*/

-- Insertion dans une table transitoire des tronçons (affectés à deux voies) et de l'identifiant minimum des voies auxquelles ils sont affectés
INSERT INTO G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE(id_troncon, old_id_voie_physique)
        SELECT
            a.id_troncon,
            MIN(a.id_voie_physique) AS id_voie_physique
        FROM
            G_BASE_VOIE.VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES a
        GROUP BY
            a.id_troncon;
-- Résultat : 837 lignes fusionnées.

-- Création d'un nouvel identifiant de voie physique pour chaque ancienne voie physique présente dans TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE et mise à jour du  champ old_id_voie_physique en conséquence.
-- Objectif : créer de nouveaux identifiants de voie
MERGE INTO G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE a
    USING(
        WITH
            C_1 AS(
                SELECT DISTINCT
                    old_id_voie_physique
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
                a.old_id_voie_physique,
                b.max_id_voie_physique + rownum AS new_id_voie_physique
            FROM
                C_1 a,
                C_2 b
    )t
ON(a.old_id_voie_physique = t.old_id_voie_physique)
WHEN MATCHED THEN
    UPDATE SET a.new_id_voie_physique = t.new_id_voie_physique;
-- Résultat : 837 lignes fusionnées.

-- Insertion des nouveaux identifiants de voie physique dans la table des voies physiques
MERGE INTO G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE a
    USING(
        SELECT DISTINCT
            new_id_voie_physique
        FROM
            G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE
    )t
ON(a.objectid = t.new_id_voie_physique)
WHEN NOT MATCHED THEN
INSERT(a.objectid)
VALUES(t.new_id_voie_physique);
-- Résultat : 306 lignes fusionnées.
    
-- Mise à jour du champ new_id_voie_physique de la table TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE pour raccorder les voies administratives aux nouvelles voies physiques
MERGE INTO G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
    USING(
        WITH
            C_1 AS(
                SELECT DISTINCT
                    d.fid_voie_physique AS old_id_voie_physique,
                    a.new_id_voie_physique,
                    e.objectid AS id_voie_administrative
                FROM
                    G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE a
                    INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE b ON b.fid_troncon = a.id_troncon
                    INNER JOIN G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE c ON c.objectid = b.fid_voie_physique
                    INNER JOIN  G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = c.objectid
                    INNER JOIN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE e ON e.objectid = d.fid_voie_administrative
        ),
        
        C_2 AS(
            SELECT
                old_id_voie_physique
            FROM
                C_1
            GROUP BY
                old_id_voie_physique
            HAVING
                COUNT(old_id_voie_physique) > 1
        )
        
        SELECT
            a.*
        FROM
            C_1 a
        WHERE
            a.old_id_voie_physique NOT IN(SELECT old_id_voie_physique FROM C_2)
    )t
ON(a.fid_voie_physique = t.old_id_voie_physique AND a.fid_voie_administrative = t.id_voie_administrative)
WHEN MATCHED THEN
    UPDATE SET a.new_id_voie_physique = t.new_id_voie_physique;
-- Résultat : 559 lignes fusionnées.

-- Mise à jour du champ fid_voie_physique de la table TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE pour les voies administratives composées de plusieurs voies physiques
MERGE INTO G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
    USING(
        WITH
            C_1 AS(
                SELECT
                    new_id_voie_physique
                FROM
                    G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
                GROUP BY
                    new_id_voie_physique
                HAVING
                    COUNT(new_id_voie_physique) > 1
            )
            
            SELECT
                a.old_id_voie_physique,
                a.new_id_voie_physique
            FROM
                G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
            WHERE
                a.new_id_voie_physique IN(SELECT new_id_voie_physique FROM C_1)
    )t
ON (a.old_id_voie_physique = t.old_id_voie_physique AND a.new_id_voie_physique = t.new_id_voie_physique)
WHEN MATCHED THEN
    UPDATE SET a.fid_voie_physique = t.new_id_voie_physique;
-- Résultat : 483 lignes fusionnées
    
-- Mise à jour de la table TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE
MERGE INTO G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE a
    USING(
        SELECT DISTINCT
            a.id_troncon,
            c.old_id_voie_physique,
            a.new_id_voie_physique
        FROM
            G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE a
            INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE b ON b.fid_voie_physique = a.old_id_voie_physique
            INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = a.new_id_voie_physique
    )t
ON (a.fid_troncon = t.id_troncon AND a.old_id_voie_physique = t.old_id_voie_physique)
WHEN MATCHED THEN
    UPDATE SET a.fid_voie_physique = t.new_id_voie_physique;
-- Résultat : 1 244 lignes fusionnées

-- Suppression des anciennes relations tronçons/voies physiques qui ont été corrigées 
DELETE FROM G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE
WHERE
    objectid IN(
        WITH
            C_1 AS(-- Sélection des tronçons présents en doublons dans la table
                SELECT
                    fid_troncon
                FROM
                    G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE
                GROUP BY
                    fid_troncon
                HAVING
                    COUNT(fid_troncon) > 1
            ),
            
            C_2 AS(-- Sélection de la relation quand pour un fid_voie_physique minimum au sein des doublons 
                SELECT
                    a.fid_troncon,
                    MIN(a.fid_voie_physique) AS fid_voie_physique
                FROM
                    G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE a
                    INNER JOIN C_1 b ON b.fid_troncon = a.fid_troncon
                GROUP BY
                    a.fid_troncon
            )
            
            SELECT
                a.objectid
            FROM
                G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE a
                INNER JOIN C_2 b ON b.fid_troncon = a.fid_troncon AND b.fid_voie_physique = a.fid_voie_physique
    )
;
-- Résultat : 227 lignes supprimées

COMMIT;

-- Ajout d'anciennes relations voie physique / voie administrative correctes
INSERT INTO G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE(fid_voie_physique, fid_voie_administrative)
SELECT DISTINCT
    a.objectid,
    c.objectid
FROM
    G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE a
    INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE b ON b.fid_voie_physique = a.objectid
    INNER JOIN G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE c ON c.fid_voie_physique = a.objectid
    --INNER JOIN G_BASE_VOIE.TEMP_b_RELATION_TRONCON_VOIE_PHYSIQUE c ON c.fid_voie_physique = b.fid_voie_physique
WHERE
    a.objectid NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE);
-- Résultat : 397 lignes insérées