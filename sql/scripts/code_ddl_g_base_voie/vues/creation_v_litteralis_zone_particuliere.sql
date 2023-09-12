/*
Création de la vue V_LITTERALIS_ZONE_PARTICULIERE - du jeux d'export du projet LITTERALIS - contenant tous les tronçons au format LITTERALIS.
*/
/*
DROP VIEW G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'V_LITTERALIS_ZONE_PARTICULIERE';
COMMIT;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_LITTERALIS_ZONE_PARTICULIERE" (
    IDENTIFIANT, 
    TYPE_ZONE, 
    CODE_VOIE, 
    COTE_VOIE, 
    CODE_INSEE, 
    CATEGORIE, 
    GEOMETRY, 
   CONSTRAINT "V_LITTERALIS_ZONE_PARTICULIERE_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS 
    WITH C_1 AS(
        SELECT
            CAST(type_zone AS VARCHAR2(254 BYTE)) AS type_zone,
            CAST(code_voie AS VARCHAR2(254 BYTE)) AS code_voie,
            CAST(cote_voie AS VARCHAR2(254 BYTE)) AS cote_voie,
            CAST(code_insee AS VARCHAR2(254 BYTE)) AS code_insee,
            CAST(categorie  AS NUMBER(8,0)) AS categorie,
            geometry
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO
        UNION ALL
        SELECT
            CAST(type_zone AS VARCHAR2(254 BYTE)) AS type_zone,
            CAST(code_voie AS VARCHAR2(254 BYTE)) AS code_voie,
            CAST(cote_voie AS VARCHAR2(254 BYTE)) AS cote_voie,
            CAST(code_insee AS VARCHAR2(254 BYTE)) AS code_insee,
            CAST(categorie  AS NUMBER(8,0)) AS categorie,
            geometry
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO
        UNION ALL
        SELECT
            CAST(type_zone AS VARCHAR2(254 BYTE)) AS type_zone,
            CAST(code_voie AS VARCHAR2(254 BYTE)) AS code_voie,
            CAST(cote_voie AS VARCHAR2(254 BYTE)) AS cote_voie,
            CAST(code_insee AS VARCHAR2(254 BYTE)) AS code_insee,
            CAST(categorie  AS NUMBER(8,0)) AS categorie,
            geometry
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO
        UNION ALL
        SELECT
            CAST(type_zone AS VARCHAR2(254 BYTE)) AS type_zone,
            CAST(code_voie AS VARCHAR2(254 BYTE)) AS code_voie,
            CAST(cote_voie AS VARCHAR2(254 BYTE)) AS cote_voie,
            CAST(code_insee AS VARCHAR2(254 BYTE)) AS code_insee,
            CAST(categorie  AS NUMBER(8,0)) AS categorie,
            geometry
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO
    )

    SELECT
        rownum AS identifiant,
        type_zone,
        code_voie,
        cote_voie,
        code_insee,
        categorie,
        geometry
    FROM
        C_1;
        
-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE IS 'Vue - du jeux d''export du projet LITTERALIS - contenant toutes les zones particulières au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.TYPE_ZONE IS 'Type de zone : Commune, Agglomeration, RGC, Categorie, InteretCommunautaire.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.CODE_VOIE IS 'Liaison avec la classe TRONCON sur la colonne CODE_RUE_G ou CODE_RUE_D.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.COTE_VOIE IS 'Définit sur quel côté de la voie s’appuie la zone particulière : LesDeuxCotes, Gauche, Droit.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.CODE_INSEE IS 'Code INSEE de la commune. * Obligatoire pour les entrées « Commune » et « Agglomeration ».';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.CATEGORIE IS 'Valeur définissant la catégorie de la rue sur cette zone (1,2,3..). A définir à 0 lorsque le champ TYPE_ZONE <> « Categorie ».';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.GEOMETRY IS 'Géométries de type multiligne des zones particulières.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_LITTERALIS_ZONE_PARTICULIERE',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Affection des droits
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE TO G_ADMIN_SIG;

/

