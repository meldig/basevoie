/*
Création de la vue V_TEMP_C_AUDIT_CORRECTION_NOMENCLATURE permettant de suivre l''avancée des corrections des noms des voies administratives présentes dans TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE, suivant la nouvelle nomenclature mise en place.
*/
/*
DROP VIEW G_BASE_VOIE.V_TEMP_C_AUDIT_CORRECTION_NOMENCLATURE;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_TEMP_C_AUDIT_CORRECTION_NOMENCLATURE(
    --OBJECTID,
    ETAT,
    NOMBRE,
    CONSTRAINT "V_TEMP_C_AUDIT_CORRECTION_NOMENCLATURE_PK" PRIMARY KEY ("ETAT") DISABLE) AS(
    /*WITH
        C_1 AS(*/
            SELECT
                TRIM(UPPER(b.libelle_court)) AS etat,
                COUNT(a.id_voie_administrative) AS nombre   
            FROM
                G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE a
                INNER JOIN G_BASE_VOIE.TEMP_C_LIBELLE b ON b.objectid = a.fid_etat
            GROUP BY
                TRIM(UPPER(b.libelle_court))
        /*)

        SELECT
            rownum AS objectid,
            a.etat,
            a.nombre
        FROM
            C_1 a*/
);

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_C_AUDIT_CORRECTION_NOMENCLATURE IS 'Vue permettant de suivre l''avancée des corrections des noms des voies administratives présentes dans TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE, suivant la nouvelle nomenclature mise en place.' ;
--COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_CORRECTION_NOMENCLATURE.objectid IS 'Identifiant/clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_CORRECTION_NOMENCLATURE.etat IS 'Etats d''avancement de la correction des noms de voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_CORRECTION_NOMENCLATURE.nombre IS 'Nombre de voies par état.';

-- 3. Affectation du droit de sélection sur la vue aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_TEMP_C_AUDIT_CORRECTION_NOMENCLATURE TO G_ADMIN_SIG;

/

