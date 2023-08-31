/*
Création de la Vue matérialisée VM_INFORMATION_VOIE_LITTERALIS rassemblant les informations nécessaires aux agents de la DEPV pour gérer les travaux de voirie via l'application LITTERALIS.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS;
*/
-- 1. Création de la vue matérialisée
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS (
    OBJECTID, 
    ID_VOIE,
    DOMANIALITE,
    TRAFIC,
    AGE_DES_TRAVAUX,
    ANCIENNETE_DES_TRAVAUX
)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
    WITH C_1 AS(
        SELECT
            a.idvoie AS id_voie,
            a.domania AS domanialite,
            b.clastrf AS trafic,
            c.age_travaux AS age_des_travaux,
            CASE
                WHEN c.age_travaux< 5
                    THEN 'Voirie de moins de 5 ans'
                ELSE
                    'Voirie de plus de 5 ans'
            END AS anciennete_des_travaux
        FROM
            SIREO_LEC.OUT_DOMANIALITE a
            INNER JOIN SIREO_LEC.OUT_CLAS_TRAF b ON a.idvoie = b.idvoie 
            INNER JOIN SIREO_LEC.OUT_TRAVAUX_VOIE c ON c.idvoie = b.idvoie
        GROUP BY
            a.idvoie,
            a.domania,
            b.clastrf,
            c.age_travaux,
            CASE
                WHEN c.age_travaux< 5
                    THEN 'Voirie de moins de 5 ans'
                ELSE
                    'Voirie de plus de 5 ans'
            END
    )

    SELECT
        rownum AS objectid,
        a.id_voie,
        a.domanialite,
        a.trafic,
        a.age_des_travaux,
        a.anciennete_des_travaux
    FROM
        C_1 a;

-- 2. Création des commentaires
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS IS 'Vue matérialisée rassemblant les informations nécessaires aux agents de la DEPV pour gérer les travaux de voirie via l''application LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS.OBJECTID IS 'Clé primaire de la VM.';
COMMENT ON COLUMN G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS.ID_VOIE IS 'Identifiant de la voie récupéré dans le schéma SIREO_LEC.';
COMMENT ON COLUMN G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS.DOMANIALITE IS 'Domanialité de la voie, c''est-à-dire le propriétaire de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS.TRAFIC IS 'Type de trafic des voies.';
COMMENT ON COLUMN G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS.AGE_DES_TRAVAUX IS 'Age des travaux de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS.ANCIENNETE_DES_TRAVAUX IS 'Ancienneté des travaux permettant de savoir s''ils ont plus ou moins de 5 ans d''ancienneté.';

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_INFORMATION_VOIE_LITTERALIS 
ADD CONSTRAINT VM_INFORMATION_VOIE_LITTERALIS_PK 
PRIMARY KEY (OBJECTID);

-- 4. Création des index
CREATE INDEX VM_INFORMATION_VOIE_LITTERALIS_ID_VOIE_IDX ON G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS(ID_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_INFORMATION_VOIE_LITTERALIS_DOMANIALITE_IDX ON G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS(DOMANIALITE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_INFORMATION_VOIE_LITTERALIS_TRAFIC_IDX ON G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS(TRAFIC)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_INFORMATION_VOIE_LITTERALIS_AGE_DES_TRAVAUX_IDX ON G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS(AGE_DES_TRAVAUX)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_INFORMATION_VOIE_LITTERALIS_ANCIENNETE_DES_TRAVAUX_IDX ON G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS(ANCIENNETE_DES_TRAVAUX)
    TABLESPACE G_ADT_INDX;

-- 5. Création des droits de lecture
GRANT SELECT ON G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS TO G_ADMIN_SIG;

/

