/*
Création de la vue V_LITTERALIS_REGROUPEMENT - du jeux d'export du projet LITTERALIS - contenant tous les regroupements (secteurs, territoires, unités territoriales) au format LITTERALIS.
*/
/*
DROP VIEW G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'V_LITTERALIS_REGROUPEMENT';
COMMIT;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_LITTERALIS_REGROUPEMENT" ("IDENTIFIANT", "CODE_REGR", "TYPE", "NOM", "CODE_INSEE", "GEOMETRY", 
   CONSTRAINT "V_LITTERALIS_REGROUPEMENT_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS 
    WITH
        C_1 AS(
            SELECT
                'Zone' AS type,
                nom,
                '' AS code_insee,
                geometry
            FROM
                G_BASE_VOIE.TA_TAMPON_LITTERALIS_SECTEUR
            UNION ALL
            SELECT
                'Zone' AS type,
                nom,
                '' AS code_insee,
                geometry
            FROM
                G_BASE_VOIE.TA_TAMPON_LITTERALIS_TERRITOIRE
            UNION ALL
            SELECT
                'Zone' AS type,
                nom,
                '' AS code_insee,
                geometry
            FROM
                G_BASE_VOIE.TA_TAMPON_LITTERALIS_UNITE_TERRITORIALE
        )
        
        SELECT
            CAST(rownum AS NUMBER(38,0)) AS identifiant,
            a.nom,
            CAST(rownum AS VARCHAR2(254 BYTE)) AS code_regr,
            CAST(a.type AS VARCHAR2(254 BYTE)) AS type,
            CAST(a.code_insee AS VARCHAR2(254 BYTE)) AS code_insee,
            a.geometry
        FROM
            C_1 a;
        
-- Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT IS 'Vue - du jeux d''export du projet LITTERALIS - contenant tous les regroupements (secteurs, territoires, unités territoriales) au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT.NOM IS 'Nom du regroupement.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT.CODE_REGR IS 'Identificateur unique et immuable du regroupement partagé entre Littéralis Expert et le SIG';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT.TYPE IS 'Type de regroupement. En accord avec le prestataire tous les regroupements sont de type "Zone".';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT.CODE_INSEE IS 'Code INSEE de la commune. Les regroupements pouvant recouvrir plusieurs communes il a été convenu avec le prestataire de ne rien mettre dans ce champ.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT.GEOMETRY IS 'Géométries de type multipolygone des secteurs, territoires et unités territoriales du service voirie.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_LITTERALIS_REGROUPEMENT',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Affection des droits
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT TO G_ADMIN_SIG;

/

