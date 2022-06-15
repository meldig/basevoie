/*
Création de la vue V_TEMP_B_TRONCON_SANS_VOIE listant tous les tronçons affectés à aucune voie physique ou ne disposant d'aucun sens de saisie par rapport au sens principal de la voie.
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_TEMP_B_TRONCON_SANS_VOIE(
    ID_TRONCON,
    SENS,
    ID_VOIE,
    DATE_SAISIE,
    PNOM_SAISIE,
    DATE_MODIFICATION,
    PNOM_MODIFICATION,
    GEOM,
    CONSTRAINT "V_TEMP_B_TRONCON_SANS_VOIE_PK" PRIMARY KEY ("ID_TRONCON") DISABLE
) 
AS(
    SELECT
        a.objectid,
        b.sens,
        b.fid_voie_physique,
        a.date_saisie,
        c.pnom AS pnom_saisie,
        a.date_modification,
        d.pnom AS pnom_modification,
        a.geom
    FROM
        G_BASE_VOIE.TEMP_B_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE b ON b.fid_troncon = a.objectid
        INNER JOIN G_BASE_VOIE.TEMP_B_AGENT c ON c.numero_agent = a.fid_pnom_saisie
        INNER JOIN G_BASE_VOIE.TEMP_B_AGENT d ON d.numero_agent = a.fid_pnom_modification
    WHERE
        b.fid_voie_physique IS NULL
        OR b.sens IS NULL
);

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_B_TRONCON_SANS_VOIE IS 'Vue regroupant tous les tronçons valides affectés à aucune voie ou n''ayant pas de sens. Cette vue est à utiliser dans le cadre de la correction topologique afin de contrôler la bonne saisie/correction des tronçons.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_B_TRONCON_SANS_VOIE.id_troncon IS 'Identifiant des tronçons de la structure b - correction topologique de la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_B_TRONCON_SANS_VOIE.id_voie IS 'Identifiant de la voie physique associée au tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_B_TRONCON_SANS_VOIE.sens IS 'Sens de saisie du tronçon par rapport au sens principal de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_B_TRONCON_SANS_VOIE.date_saisie IS 'Date de saisie du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_B_TRONCON_SANS_VOIE.date_modification IS 'Dernière date de modification du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_B_TRONCON_SANS_VOIE.PNOM_SAISIE IS 'Pnom de l''agent ayant créé le tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_B_TRONCON_SANS_VOIE.PNOM_MODIFICATION IS 'Pnom de l''agent ayant modifié en dernier le tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_B_TRONCON_SANS_VOIE.geom IS 'Géométrie de chaque tronçon.';  

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_TEMP_B_TRONCON_SANS_VOIE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Affectation du droit de sélection sur les objets de la vue aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_TEMP_B_TRONCON_SANS_VOIE TO G_ADMIN_SIG;

/

