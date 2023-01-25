-- Remplissage des tables de vérifications qui seront utilisées pour corriger les relations seuil/tronçon

-- Création de nouveaux libellés
INSERT INTO G_BASE_VOIE.TEMP_H_LIBELLE(libelle_court, libelle_long)
VALUES('non-vérifié', 'Relation seuil/tronçon non vérifiée');

INSERT INTO G_BASE_VOIE.TEMP_H_LIBELLE(libelle_court, libelle_long)
VALUES('vérifié', 'Relation seuil/tronçon vérifiée et corrigée au besoin');

-- Mise à jour des tronçons concernés par la vérification des relations seuils/tronçons
MERGE INTO G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION a
    USING(
        SELECT-- Sélection des tronçons modifiés dans les raquettes (passage d'une raquette/rond-point uni-tronçon à une raquette/rond-point multi-tronçon)
            objectid,
            1 AS verif_relation_seuil_troncon
        FROM
            G_BASE_VOIE.TEMP_F_TRONCON
        WHERE
            fid_etat IN(4, 5)
        UNION ALL
        SELECT-- Sélection des tronçons modifiés durant les corrections topologiques
            objectid,
            1 AS verif_relation_seuil_troncon
        FROM
            G_BASE_VOIE.TEMP_B_TRONCON
        WHERE
            objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_F_TRONCON WHERE fid_etat IN(4, 5))
            AND fid_etat IN(6,7)
    )t
ON(a.objectid = t.objectid)
WHEN MATCHED THEN
    UPDATE SET a.verif_relation_seuil_troncon = t.verif_relation_seuil_troncon;
    
-- Mise à jour des seuils à vérifier
MERGE INTO G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION a
    USING(
        WITH
            C_1 AS(-- Sélection de tous les tronçons modifiés
                SELECT-- Sélection des tronçons modifiés dans les raquettes (passage d'une raquette/rond-point uni-tronçon à une raquette/rond-point multi-tronçon)
                    objectid
                FROM
                    G_BASE_VOIE.TEMP_F_TRONCON
                WHERE
                    fid_etat IN(4, 5)
                UNION ALL
                SELECT-- Sélection des tronçons modifiés durant les corrections topologiques
                    objectid
                FROM
                    G_BASE_VOIE.TEMP_B_TRONCON
                WHERE
                    objectid NOT IN(SELECT objectid FROM G_BASE_VOIE.TEMP_F_TRONCON WHERE fid_etat IN(4, 5))
                    AND fid_etat IN(6,7)
            )
            
            SELECT
                a.objectid,
                4 AS fid_etat_verification
            FROM
                 G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION a
                 INNER JOIN C_1 b ON b.objectid = a.fid_troncon
    )t
ON(a.objectid = t.objectid)
WHEN MATCHED THEN
    UPDATE SET a.fid_etat_verification = t.fid_etat_verification;
-- Résultat : 155 862 lignes fusionnées.

-- Affectation des seuils à vérifier aux agents    
MERGE INTO G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION a
    USING(
        SELECT
            a.objectid,
            b.numero_agent
        FROM
             G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION a,
             G_BASE_VOIE.TEMP_H_AGENT b
        WHERE
            LOWER(b.pnom) = 'ydelebarre'
            AND a.fid_etat_verification = 4
            --AND a.fid_agent_verification IS NULL
            AND a.code_insee IN('59025','59052','59056','59088','59128','59670','59193','59195','59196','59201','59208','59250','59257','59278','59281','59286','59303','59316','59320','59051','59371','59360','59388','59437','59477','59487','59524','59550','59553','59566','59648','59653','59658')
    )t
ON(a.objectid = t.objectid)
WHEN MATCHED THEN
    UPDATE SET a.fid_agent_verification = t.numero_agent;
-- Résultat : 20 519 lignes fusionnées.

MERGE INTO G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION a
    USING(
        SELECT
            a.objectid,
            b.numero_agent
        FROM
             G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION a,
             G_BASE_VOIE.TEMP_H_AGENT b
        WHERE
            LOWER(b.pnom) = 'obecquaert'
            AND a.fid_etat_verification = 4
            --AND a.fid_agent_verification IS NULL
            AND a.code_insee IN('59005','59011','59133','59220','59256','59368','59328','59343','59346','59350','59386','59507','59527','59560','59585','59609')
    )t
ON(a.objectid = t.objectid)
WHEN MATCHED THEN
    UPDATE SET a.fid_agent_verification = t.numero_agent;
-- Résultat : 32 371 lignes fusionnées.

MERGE INTO G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION a
    USING(
        SELECT
            a.objectid,
            b.numero_agent
        FROM
             G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION a,
             G_BASE_VOIE.TEMP_H_AGENT b
        WHERE
            LOWER(b.pnom) = 'smarrazzo'
            AND a.fid_etat_verification = 4
            --AND a.fid_agent_verification IS NULL
            AND a.code_insee IN('59013','59044','59106','59146','59163','59247','59275','59299','59332','59339','59367','59378','59410','59458','59512','59522','59523','59598','59599','59602','59009','59646','59650','59660')
    )t
ON(a.objectid = t.objectid)
WHEN MATCHED THEN
    UPDATE SET a.fid_agent_verification = t.numero_agent;
-- Résultat : 67 593 lignes fusionnées.

MERGE INTO G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION a
    USING(
        SELECT
            a.objectid,
            b.numero_agent
        FROM
             G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION a,
             G_BASE_VOIE.TEMP_H_AGENT b
        WHERE
            LOWER(b.pnom) = 'gdartois'
            AND a.fid_etat_verification = 4
            --AND a.fid_agent_verification IS NULL 
            AND a.code_insee IN('59017','59090','59098','59152','59173','59202','59252','59279','59317','59143','59352','59356','59421','59426','59457','59470','59482','59508','59611','59636','59643','59656')
    )t
ON(a.objectid = t.objectid)
WHEN MATCHED THEN
    UPDATE SET a.fid_agent_verification = t.numero_agent;
-- Résultat : 29 714 lignes fusionnées.
