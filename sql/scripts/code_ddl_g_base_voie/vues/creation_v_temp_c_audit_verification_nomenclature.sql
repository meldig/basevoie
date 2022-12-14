/*
Vue V_TEMP_C_AUDIT_VERIFICATION_NOMENCLATURE - du projet C de correction de la nomenclature des voies - permettant de suivre l''évolution de la vérification des noms de voie.
*/ 
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_TEMP_C_AUDIT_VERIFICATION_NOMENCLATURE(
    objectid,
    agent,
    etat,
    nombre_voie,
    CONSTRAINT "V_TEMP_C_AUDIT_VERIFICATION_NOMENCLATURE_PK" PRIMARY KEY ("OBJECTID") DISABLE
)
AS
WITH
    C_1 AS(
        SELECT
            d.id_voie_administrative,
            e.libelle_court AS etat,
            b.pnom AS agent
        FROM
            G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE d
            INNER JOIN G_BASE_VOIE.TEMP_C_LIBELLE e ON e.objectid = d.fid_etat_verification
            INNER JOIN G_BASE_VOIE.TEMP_C_AGENT b ON b.numero_agent = d.fid_agent_verification
    ),

    C_2 AS(
        SELECT-- Décompte des voies par état et par agent
            agent,
            etat,
            COUNT(id_voie_administrative) AS nombre_voie
        FROM
            C_1
        GROUP BY
            agent,
            etat
        UNION ALL-- Décompte des voies par état et pour tous les agents
        SELECT
            'tous les agents' AS agent,
            etat,
            COUNT(id_voie_administrative) AS nombre_voie
        FROM
            C_1
        GROUP BY
            'tous les agents',
            etat
    )
    
    SELECT
        ROWNUM AS objectid,
        a.*
    FROM
        C_2 a
    ORDER BY
        a.agent,
        a.etat;
    
-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_C_AUDIT_VERIFICATION_NOMENCLATURE IS 'Vue - du projet C de correction de la nomenclature des voies - permettant de suivre l''évolution de la vérification des noms de voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_VERIFICATION_NOMENCLATURE.objectid IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_VERIFICATION_NOMENCLATURE.agent IS 'Pnom de l''agent chargé de vérifier la nomenclature.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_VERIFICATION_NOMENCLATURE.etat IS 'Etat de la vérification de la nomenclature.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_VERIFICATION_NOMENCLATURE.nombre_voie IS 'Nombre de voies par agent et par état de vérification.';

/

