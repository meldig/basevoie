/*
Création de la vue V_TAMPON_LITTERALIS_AUDIT_ZONE_PARTICULIERE - de la structure tampon du projet LITTERALIS - vérifiant la présence d''erreur dans la table TA_TAMPON_LITTERALIS_ZONE_PARTICULIERE. Les erreurs vérifiées sont celles qui ont été remontées dans les rapports d''erreurs.
*/
/*
DROP VIEW G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ZONE_PARTICULIERE;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE EDITIONABLE VIEW "G_BASE_VOIE"."V_TAMPON_LITTERALIS_AUDIT_ZONE_PARTICULIERE" ("THEMATIQUE", "OBJECTID", "CODE_VOIE", "CODE_INSEE", "COTE_VOIE", "GEOMETRY", 
    CONSTRAINT "V_TAMPON_LITTERALIS_AUDIT_ZONE_PARTICULIERE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
    WITH
        C_1 AS(
            SELECT DISTINCT
                 id_voie_droite as code_voie
            FROM
                G_BASE_VOIE.TA_TAMPON_LITTERALIS_TRONCON
           UNION
            SELECT DISTINCT
                 id_voie_gauche as code_voie
            FROM
                G_BASE_VOIE.TA_TAMPON_LITTERALIS_TRONCON
        )
        
        SELECT -- Sélection des voies présentes dans les zones particulières, mais absentes de la table des tronçons.
            'Voies présentes dans les zones particulières mais absentes de la table des tronçons' AS thematique,
            a.objectid,
            a.code_voie,
            a.code_insee,
            a.cote_voie,
            a.geometry
        FROM
            G_BASE_VOIE.TA_TAMPON_LITTERALIS_ZONE_PARTICULIERE a
        WHERE
            a.code_voie NOT IN (SELECT code_voie FROM C_1);
        
-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ZONE_PARTICULIERE IS 'Vue d''audit - de la structure tampon du projet LITTERALIS - vérifiant la présence d''erreur dans la table TA_TAMPON_LITTERALIS_ZONE_PARTICULIERE. Les erreurs vérifiées sont celles qui ont été remontées dans les rapports d''erreurs.';
COMMENT ON COLUMN G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ZONE_PARTICULIERE.OBJECTID IS 'Clé primaire de la vue correspondant à l''identifiant de chaque zone particulière.';
COMMENT ON COLUMN G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ZONE_PARTICULIERE.THEMATIQUE IS 'Thème de l''erreur identifiée.';
COMMENT ON COLUMN G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ZONE_PARTICULIERE.CODE_VOIE IS 'Identifiant de voie de la zone particulière.';
COMMENT ON COLUMN G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ZONE_PARTICULIERE.CODE_INSEE IS 'Code INSEE de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ZONE_PARTICULIERE.COTE_VOIE IS 'Latéralité de la zone particulière.';
COMMENT ON COLUMN G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ZONE_PARTICULIERE.GEOMETRY IS 'Géométrie de type multiligne.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_TAMPON_LITTERALIS_AUDIT_ZONE_PARTICULIERE',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 4. Création des droits de lecture
GRANT SELECT ON G_BASE_VOIE.V_TAMPON_LITTERALIS_AUDIT_ZONE_PARTICULIERE TO G_ADMIN_SIG;

/

