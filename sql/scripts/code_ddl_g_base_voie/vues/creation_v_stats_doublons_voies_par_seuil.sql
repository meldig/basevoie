/*
Vue permettant de connaître le nombre de seuils affectés à une ou plusieurs voies (ainsi que leur part par nombre de voies auxquelles ils sont affectés).
*/
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_STATS_DOUBLONS_VOIES_PAR_SEUIL" ("IDENTIFIANT", "NBR_SEUILS", "PART_DE_SEUILS", "NBR_VOIES", 
    CONSTRAINT "V_STATS_DOUBLONS_VOIES_PAR_SEUIL_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS 
    -- Objectif : Compter le nombre de seuils affectés à plusieurs voies et répartir ce décompte par nombre de voies
    WITH
        C_1 AS(-- Décompte du nombre total de seuils de la base
            SELECT
                COUNT(a.objectid) AS nbr_total_seuil
            FROM
                G_BASE_VOIE.TA_INFOS_SEUIL a
        ),
        
        C_2 AS(-- Sélection des seuils affectés à plusieurs voies
            SELECT
                b.objectid AS id_seuil,
                COUNT(e.objectid) AS nbr_voies
            FROM
                G_BASE_VOIE.TA_SEUIL a
                INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL b ON b.fid_seuil = a.objectid
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = a.objectid
                INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = c.fid_troncon
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE e ON e.fid_troncon = d.objectid
                INNER JOIN G_BASE_VOIE.TA_VOIE f ON f.objectid = e.fid_voie
            GROUP BY
                b.objectid
        ),
        
        C_3 AS( -- Regroupement des seuils par nombre de voies
            SELECT
                COUNT(a.id_seuil) AS nbr_seuils,
                a.nbr_voies
            FROM
                C_2 a
            GROUP BY
                a.nbr_voies
        )
        
        SELECT -- Création d'un identifiant pour la PK
            rownum AS identifiant,
            a.nbr_seuils,
            ROUND(((a.nbr_seuils/b.nbr_total_seuil)*100), 3) AS part_de_seuils,
            a.nbr_voies
        FROM
            C_3 a,
            C_1 b;
            
COMMENT ON COLUMN "G_BASE_VOIE"."V_STATS_DOUBLONS_VOIES_PAR_SEUIL"."IDENTIFIANT" IS 'Clé primaire de la vue.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_STATS_DOUBLONS_VOIES_PAR_SEUIL"."NBR_SEUILS" IS 'Nombre de seuils affectés à plusieurs voies.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_STATS_DOUBLONS_VOIES_PAR_SEUIL"."PART_DE_SEUILS" IS 'Part des seuils par nombre de voies auxquelles ils sont affectés.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_STATS_DOUBLONS_VOIES_PAR_SEUIL"."NBR_VOIES" IS 'Nombre de voies auxquelles sont affectés les seuils.';
COMMENT ON TABLE "G_BASE_VOIE"."V_STATS_DOUBLONS_VOIES_PAR_SEUIL"  IS 'Vue comptant le nombre de seuils affectés à plusieurs voies et répartissant ce décompte par nombre de voies';