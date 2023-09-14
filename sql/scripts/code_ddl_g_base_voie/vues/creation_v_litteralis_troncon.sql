/*
Création de la vue V_LITTERALIS_TRONCON - du jeux d'export du projet LITTERALIS - contenant tous les tronçons au format LITTERALIS.
*/
/*
DROP VIEW G_BASE_VOIE.V_LITTERALIS_TRONCON;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'V_LITTERALIS_TRONCON';
COMMIT;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_LITTERALIS_TRONCON" ("IDENTIFIANT", "CODE_TRONC", "CLASSEMENT", "CODE_RUE_G", "NOM_RUE_G", "INSEE_G", "CODE_RUE_D", "NOM_RUE_D", "INSEE_D", "LARGEUR", "GEOMETRY", 
   CONSTRAINT "V_LITTERALIS_TRONCON_PK" PRIMARY KEY ("CODE_TRONC") DISABLE) AS 
    SELECT
        a.objectid AS identifiant,
        a.code_tronc,
        a.classement,
        CAST(a.id_voie_gauche AS VARCHAR2(254)) AS code_rue_g,
        CAST(a.nom_voie_gauche AS VARCHAR2(254)) AS nom_rue_g,
        a.code_insee_voie_gauche AS insee_g,
        CAST(a.id_voie_droite AS VARCHAR2(254)) AS code_rue_d,
        CAST(a.nom_voie_droite AS VARCHAR2(254)) AS nom_rue_d,
        a.code_insee_voie_droite AS insee_d,
        CAST('' AS NUMBER(8,0)) AS largeur,
        a.geometry
    FROM
        G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON a;
        
-- Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_LITTERALIS_TRONCON IS 'Vue - du jeux d''export du projet LITTERALIS - contenant tous les tronçons au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.CODE_TRONC IS 'Identificateur unique et immuable du tronçon de voie partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.CLASSEMENT IS 'Classement de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.CODE_RUE_G IS 'Code unique de la rue côté gauche du tronçon partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.NOM_RUE_G IS 'Nom de la voie côté gauche du tronçon (telle qu’affichée dans les arrêtés et autorisations).';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.INSEE_G IS 'Code INSEE de la commune côté gauche du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.CODE_RUE_D IS 'Code unique de la rue côté droit du tronçon partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.NOM_RUE_D IS 'Nom de la voie côté droit du tronçon (telle qu’affichée dans les arrêtés et autorisations).';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.INSEE_D IS 'Code INSEE de la commune côté droit du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.LARGEUR IS 'Valeur indiquant une largeur de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.GEOMETRY IS 'Géométrie de l''adresse de type ligne simple.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_LITTERALIS_TRONCON',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Affection des droits
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_TRONCON TO G_ADMIN_SIG;

/

