CREATE OR REPLACE FORCE VIEW V_TRONCON (
    CODE_TRONC,
    CLASSEMENT,
    CODE_RUE_G,
    NOM_RUE_G,
    INSEE_G,
    CODE_RUE_D,
    NOM_RUE_D,
    INSEE_D,
    LARGEUR,
    CONSTRAINT "V_TRONCON_PK" PRIMARY KEY ("CODE_TRONC") DISABLE)
    AS (
            SELECT
                a.objectid AS CODE_TRONC,
                CASE 

                    WHEN d.objectid IN (2,3,16)
                    THEN A

                    WHEN d.objectid IN ()
                    THEN RN --(route nationale)

                    WHEN d.objectid IN ()
                    THEN RD (route departementale)

                    WHEN d.objectid IN (12)
                    THEN VP --voie privée

                    WHEN d.objectid IN (9)
                    THEN CR --(chemin rural)

                    WHEN d.objectid IN ()
                    THEN VF --voie forestiere

                    WHEN d.objectid IN (1,4,5,)
                    THEN VC --voie communale

                END AS CLASSEMENT,
                c.objectid AS CODE_RUE_G,
                UPPER(d.libelle) || ' ' || UPPER(c.libelle_voie) AS NOM_RUE_G,
                e.CODE_INSEE AS INSEE_G,
                c.objectid AS CODE_RUE_D,
                UPPER(d.libelle) || ' ' || UPPER(c.libelle_voie) AS NOM_RUE_D,
                e.CODE_INSEE AS INSEE_D,
                'NULL' AS LARGEUR
            FROM
                G_BASE_VOIE.TA_TRONCON a
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
                INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = b.fid_voie
                INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE d ON d.objectid = c.fid_typevoie,
                G_REFERENTIEL.MEL_COMMUNE e,
                USER_SDO_GEOM_METADATA m
            WHERE
            -- Pour rechercher l'INSEE du troncon nous analysons sur quelle commune se situe le point median du troncon.
                SDO_CONTAINS(
                            SDO_LRS.LOCATE_PT(
                                            SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom,m.diminfo),
                                            SDO_LRS.MEASURE_RANGE(SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom, m.diminfo)/2)
                                            ),
                            e.geom
                            )='TRUE'
            AND
                m.table_name = 'TA_TRONCON'
        );

-- 2. Création des commentaires de la vue
COMMENT ON TABLE G_BASE_VOIE.TRONCON IS 'Vue regroupant la liste des tronçons constituant une voie. Chaque objet de cette vue décrit un tronçon de voie.' ;
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON.CODE_TRONC IS 'Identificateur unique et immuable du tronçon de voie partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON.CLASSEMENT IS 'Classement de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON.CODE_RUE_G IS 'Code unique de la rue côté gauche du tronçon partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON.NOM_RUE_G IS 'Nom de la voie côté gauche du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON.INSEE_G IS 'Code INSEE de la commune côté gauche du tronçon..';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON.CODE_RUE_D IS 'Code unique de la rue côté droit du tronçon partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON.NOM_RUE_D IS 'Nom de la voie côté droit du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON.INSEE_D IS 'Code INSEE de la commune côté droit du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON.LARGEUR IS 'Valeur indiquant une largeur de la voie.';