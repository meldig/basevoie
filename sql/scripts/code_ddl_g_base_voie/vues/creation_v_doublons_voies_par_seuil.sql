/*
Création de la vue permettant d'identifier les seuils affectés à plusieurs voies.
Ce cas est entièrement dépendant des tronçons affectés à plusieurs voies.
*/

CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_DOUBLONS_VOIES_PAR_SEUIL" ("ID_INFOS_SEUIL", "ID_SEUIL", "ID_TRONCON", "NBR_VOIE", "GEOM", 
    CONSTRAINT "V_DOUBLONS_VOIES_PAR_SEUIL_PK" PRIMARY KEY ("ID_INFOS_SEUIL") DISABLE) AS 
    -- Objectif : Sélectionner des seuils affectés à plusieurs voies (dans le cadre de tronçon affectés à plusieurs voies)
    WITH
        C_1 AS(-- Sélection des seuils affectés à plusieurs voies
            SELECT
                b.objectid AS id_infos_seuil,
                b.fid_seuil AS id_seuil,
                d.objectid AS id_troncon,
                COUNT(e.objectid) AS nbr_voie
            FROM
                G_BASE_VOIE.TA_SEUIL a
                INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL b ON b.fid_seuil = a.objectid
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = a.objectid
                INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = c.fid_troncon
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE e ON e.fid_troncon = d.objectid
                INNER JOIN G_BASE_VOIE.TA_VOIE f ON f.objectid = e.fid_voie
            GROUP BY
                b.objectid,
                d.objectid,
                b.fid_seuil
            HAVING
                COUNT(e.objectid) > 1
        )
        
        SELECT -- Association des géométries aux seuils affectés à plusieurs voies
            a.id_infos_seuil,
            a.id_seuil,
            a.id_troncon,
            a.nbr_voie,
            b.geom
        FROM
            C_1 a
            INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.id_seuil;
        
COMMENT ON COLUMN "G_BASE_VOIE"."V_DOUBLONS_VOIES_PAR_SEUIL"."ID_INFOS_SEUIL" IS 'Identifiant des seuils (partie attributaire car plusieurs seuils peuvent avoir la même géométrie) affectés à plusieurs voies.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_DOUBLONS_VOIES_PAR_SEUIL"."ID_SEUIL" IS 'Identifiant des seuils (partie géométrique).';
COMMENT ON COLUMN "G_BASE_VOIE"."V_DOUBLONS_VOIES_PAR_SEUIL"."ID_TRONCON" IS 'Identifiant de chaque tronçon affecté à plusieurs voies.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_DOUBLONS_VOIES_PAR_SEUIL"."NBR_VOIE" IS 'Nombre de voies auxquelles les seuils sont affectés.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_DOUBLONS_VOIES_PAR_SEUIL"."GEOM" IS 'Géométrie de type point des seuils.';
COMMENT ON TABLE "G_BASE_VOIE"."V_DOUBLONS_VOIES_PAR_SEUIL"  IS 'Vue regroupant les seuils et tronçons affectés à plusieurs voies.';