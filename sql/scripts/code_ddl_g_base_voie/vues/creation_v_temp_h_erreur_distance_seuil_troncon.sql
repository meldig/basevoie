/*
Création de la vue V_TEMP_H_ERREUR_DISTANCE_SEUIL_TRONCON - du projet H de correction des relations tronçons/seuils - sélectionnant les couples seuil/tronçon quand la distance entre les deux est supérieure à 1km, parmis les seuils concernés par le projet h (vérification relation seuil/tronçon). 
*/
/*
DROP VIEW G_BASE_VOIE.V_TEMP_H_ERREUR_DISTANCE_SEUIL_TRONCON;
DELETE FROM USER_SDO_GEOM_METDATA WHERE TABLE_NAME = 'V_TEMP_H_ERREUR_DISTANCE_SEUIL_TRONCON';
COMMIT;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_TEMP_H_ERREUR_DISTANCE_SEUIL_TRONCON(
    id_seuil,
    id_troncon,
    distance,
    geom,
    CONSTRAINT "V_TEMP_H_ERREUR_DISTANCE_SEUIL_TRONCON_PK" PRIMARY KEY ("ID_SEUIL") DISABLE
) 
AS(
    SELECT
        a.objectid AS id_seuil,
        b.objectid AS id_troncon,
        SDO_GEOM.SDO_DISTANCE(
            a.geom,
            SDO_LRS.PROJECT_PT(
                SDO_LRS.CONVERT_TO_LRS_GEOM(b.geom, m.diminfo),
                a.geom,
                0.005
            )
        ) AS distance,
        a.geom
    FROM
        G_BASE_VOIE.TEMP_H_SEUIL_VERIFICATION a
        INNER JOIN G_BASE_VOIE.TEMP_H_TRONCON_VERIFICATION b ON b.objectid = a.fid_troncon,
        USER_SDO_GEOM_METADATA m
    WHERE
        a.fid_agent_verification IS NOT NULL
        AND m.table_name = 'TEMP_H_TRONCON_VERIFICATION'
        AND SDO_GEOM.SDO_DISTANCE(
            a.geom,
            SDO_LRS.PROJECT_PT(
                SDO_LRS.CONVERT_TO_LRS_GEOM(b.geom, m.diminfo),
                a.geom,
                0.005
            )
        ) >= 1000
);
 
-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_H_ERREUR_DISTANCE_SEUIL_TRONCON IS 'Vue sélectionnant les couples seuil/tronçon quand la distance entre les deux est supérieure à 1km, parmis les seuils concernés par le projet h (vérification relation seuil/tronçon). ';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_ERREUR_DISTANCE_SEUIL_TRONCON.id_seuil IS 'Identifiant du seuil contenu dans la table TEMP_H_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_ERREUR_DISTANCE_SEUIL_TRONCON.id_troncon IS 'Identifiant du tronçon contenu dans la table TEMP_H_TRONCON_VERIFICATION affecté au seuil.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_ERREUR_DISTANCE_SEUIL_TRONCON.distance IS 'Distance entre le seuil et son tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_ERREUR_DISTANCE_SEUIL_TRONCON.geom IS 'Géométrie de type ponctuel des seuils.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_TEMP_H_ERREUR_DISTANCE_SEUIL_TRONCON',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_TEMP_H_ERREUR_DISTANCE_SEUIL_TRONCON TO G_ADMIN_SIG;

/

