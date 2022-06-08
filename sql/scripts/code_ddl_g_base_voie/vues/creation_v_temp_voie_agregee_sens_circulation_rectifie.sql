CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE" (ID_VOIE, LIBELLE_VOIE, FID_LATERALITE, GEOM, 
    CONSTRAINT "V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE_PK" PRIMARY KEY (ID_VOIE) DISABLE) AS 
WITH
    C_1 AS(-- interversion du endpoint avec le startpoint pour les tronçons saisis dans le sens opposé au sens de circulation
        SELECT
            a.objectid,
            a.fid_voie_physique,
            CASE
                WHEN a.sens = '-'
                    THEN SDO_LRS.REVERSE_GEOMETRY(a.geom, m.diminfo)
                ELSE
                    a.geom
            END AS geom
        FROM
            G_BASE_VOIE.TEMP_A_TRONCON a,
            USER_SDO_GEOM_METADATA m
        WHERE
            m.table_name = 'TEMP_A_TRONCON'
    ),

    C_2 AS(
        SELECT
            fid_voie_physique AS id_voie,
            SDO_AGGR_CONCAT_LINES(geom) AS geom
        FROM
            C_1
        GROUP BY
            fid_voie_physique
    )
    
    SELECT
        b.objectid AS id_voie,
        TRIM(UPPER(TRIM(c.libelle)) || ' ' || UPPER(TRIM(b.libelle_voie)) || ' ' || UPPER(TRIM(b.complement_nom_voie))) AS libelle_voie,
        b.fid_lateralite,
        a.geom
    FROM
        C_2 a
        INNER JOIN G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE b ON b.fid_voie_physique = a.id_voie
        INNER JOIN G_BASE_VOIE.TEMP_A_TYPE_VOIE c ON c.objectid = b.fid_type_voie;
        
-- 2. Création des commentaires de VM et de champs
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE IS 'Cette vue matérialise la géométrie des voies valides (disposant d''un type valide) de sorte que le sens géométrique soit égal au sens de circulation : si le sens de saisie d''un tronçon est opposé au sens de circulation de la voie, les startpoint et endpoint sont intervertis, puis les tronçons sont fusionnés par voie d''appartenance. ';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE.id_voie IS 'Identifiant de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE.libelle_voie IS 'nom de la voie : type de voie + nom de voie + complément de nom.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE.fid_lateralite IS 'Identifiant des différentes latéralités possible de la voie administrative (par rapport à la voie physique).';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE.geom IS 'Géométrie des voies de type multiligne.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE TO G_ADMIN_SIG;

/

