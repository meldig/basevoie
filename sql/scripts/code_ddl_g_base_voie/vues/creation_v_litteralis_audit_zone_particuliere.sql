/*
Création de la vue V_LITTERALIS_AUDIT_ZONE_PARTICULIERE - de la structure tampon du projet LITTERALIS - vérifiant la présence d''erreur dans la table VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE. Les erreurs vérifiées sont celles qui ont été remontées dans les rapports d''erreurs.
*/
/*
DROP VIEW G_BASE_VOIE.V_LITTERALIS_AUDIT_ZONE_PARTICULIERE;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE EDITIONABLE VIEW "G_BASE_VOIE"."V_LITTERALIS_AUDIT_ZONE_PARTICULIERE" (
    OBJECTID,
    THEMATIQUE,
    IDENTIFIANT,
    TYPE_ZONE,
    CODE_VOIE,
    COTE_VOIE,
    CODE_INSEE,
    CATEGORIE,
    GEOMETRY,
    CONSTRAINT "V_LITTERALIS_AUDIT_ZONE_PARTICULIERE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
    WITH
        C_1 AS(
            SELECT DISTINCT
                 id_voie_droite as code_voie
            FROM
                G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON
           UNION
            SELECT DISTINCT
                 id_voie_gauche as code_voie
            FROM
                G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON
        ),
        
        C_2 AS(
            SELECT -- Sélection des voies présentes dans les zones particulières, mais absentes de la table des tronçons.
                'Voies présentes dans les zones particulières mais absentes de la table des tronçons' AS thematique,
                a.identifiant,
                a.type_zone,
                a.code_voie,
                a.cote_voie,
                a.code_insee,
                a.categorie,
                a.geometry
            FROM
                G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE a
            WHERE
                a.code_voie NOT IN (SELECT DISTINCT code_voie FROM C_1)
            UNION ALL
            SELECT -- Sélection des zones particulières dont le type de zone est non-conforme au cahier des charges
                'Zones particulières dont le type de zone est non-conforme au cahier des charges' AS thematique,
                a.identifiant,
                a.type_zone,
                a.code_voie,
                a.cote_voie,
                a.code_insee,
                a.categorie,
                a.geometry
            FROM
                G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE a
            WHERE
                a.type_zone NOT IN('Commune', 'Agglomeration', 'RGC', 'Categorie', 'InteretCommunautaire')
            UNION ALL
            SELECT -- Sélection des zones particulières dont le type de zone est Commune ou Agglomeration, mais ne disposant pas de code INSEE
                'Zones particulières dont le type de zone est Commune ou Agglomeration, mais ne disposant pas de code INSEE' AS thematique,
                a.identifiant,
                a.type_zone,
                a.code_voie,
                a.cote_voie,
                a.code_insee,
                a.categorie,
                a.geometry
            FROM
                G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE a
            WHERE
                a.type_zone IN('Commune', 'Agglomeration')
                AND (
                        a.code_insee IS NULL
                        OR a.code_INSEE IN('59355', '59298')
                    )
        )

        SELECT
            rownum AS objectid,
            thematique,
            identifiant,
            type_zone,
            code_voie,
            cote_voie,
            code_insee,
            categorie,
            geometry
        FROM
            C_2;
        
-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_LITTERALIS_AUDIT_ZONE_PARTICULIERE IS 'Vue d''audit - de la structure tampon du projet LITTERALIS - vérifiant la présence d''erreur dans la table V_LITTERALIS_ZONE_PARTICULIERE. Les erreurs vérifiées sont celles qui ont été remontées dans les rapports d''erreurs.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_ZONE_PARTICULIERE.OBJECTID IS 'Clé primaire de la vue correspondant à l''identifiant de chaque zone particulière.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_ZONE_PARTICULIERE.THEMATIQUE IS 'Thème de l''erreur identifiée.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.IDENTIFIANT IS 'Identifiant des zones particulières.';
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
    'V_LITTERALIS_AUDIT_ZONE_PARTICULIERE',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 4. Création des droits de lecture
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_AUDIT_ZONE_PARTICULIERE TO G_ADMIN_SIG;

/

