/*
Création de la vue V_TEMP_CORRECTION_PROJET_A_VOIE_DOUBLON permettant d'identifier les voies auxquelles un tronçon est affecté plusieurs fois.
Un tronçon pouvant être affecté à plusieurs voies, cette regroupe les voies en question.
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_TEMP_CORRECTION_PROJET_A_VOIE_DOUBLON" ("ID_VOIE", "NOM_VOIE", "GEOM", 
    CONSTRAINT "V_TEMP_CORRECTION_PROJET_A_VOIE_DOUBLON_PK" PRIMARY KEY ("ID_VOIE") DISABLE) AS 
WITH
    C_1 AS(-- Sélection des tronçons affectés à plusieurs voies
        SELECT
            fid_troncon
        FROM
            G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE
        WHERE
            cvalide = 'V'
        GROUP BY
            fid_troncon
        HAVING
            COUNT(fid_troncon) > 1
    ),

    C_2 AS(-- Sélection des voies reliées aux tronçons affectés à plusieurs voies
        SELECT DISTINCT
            a.id_voie,
            TRIM(UPPER(e.libelle)) ||' '|| TRIM(UPPER(d.libelle_voie)) ||' '|| TRIM(UPPER(d.complement_nom_voie)) AS nom_voie        
        FROM
            G_BASE_VOIE.VM_TEMP_CORRECTION_PROJET_A_VOIE_AGGREGEE a
            INNER JOIN G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_RELATION_TRONCON_VOIE b ON b.fid_voie = a.id_voie
            INNER JOIN C_1 c ON c.fid_troncon = b.fid_troncon
            INNER JOIN G_BASE_VOIE.TEMP_CORRECTION_PROJET_A_VOIE d ON d.objectid = b.fid_voie
            INNER JOIN G_BASE_VOIE.TEMP_TYPE_VOIE e ON e.objectid = d.fid_typevoie
        WHERE
            b.cvalide = 'V'
    )
    
    SELECT
        a.id_voie,
        a.nom_voie,
        b.geom
    FROM
        C_2 a
        INNER JOIN G_BASE_VOIE.VM_TEMP_CORRECTION_PROJET_A_VOIE_AGGREGEE b ON b.id_voie = a.id_voie;
    
-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_CORRECTION_PROJET_A_VOIE_DOUBLON IS 'Vue identifiant les voies disposant d''un tronçon affecté à plusieurs voies. Cette vue sert à corriger les tronçons affectés à plusieurs voies ET DOIT UNIQUEMENT ETRE UTILISEE DANS CE CAS.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_CORRECTION_PROJET_A_VOIE_DOUBLON.id_voie IS 'Identifiant de chaque voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_CORRECTION_PROJET_A_VOIE_DOUBLON.nom_voie IS 'Nom de la voie (Type de voie + nom de la voie + complément du nom de la voie).';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_CORRECTION_PROJET_A_VOIE_DOUBLON.geom IS 'Géométrie de type multiligne des voies.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_TEMP_CORRECTION_PROJET_A_VOIE_DOUBLON',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

/

