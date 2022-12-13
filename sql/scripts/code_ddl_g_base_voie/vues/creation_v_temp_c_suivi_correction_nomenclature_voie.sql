/*
Vue V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE - du projet C d''homogénéisation des noms de voie  - permettant d''identifier les voies qu''il reste à corriger.
*/
/*
DROP VIEW G_BASE_VOIE.V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE;
*/
-- 1. Création de la vue

CREATE OR REPLACE FORCE EDITIONABLE VIEW "G_BASE_VOIE"."V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE" ("ID_VOIE_ADMINISTRATIVE", "TYPE_ERREUR", "TYPE_VOIE", "NOM_VOIE", "COMPLEMENT_NOM_VOIE", 
 CONSTRAINT "V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE_PK" PRIMARY KEY ("ID_VOIE_ADMINISTRATIVE") DISABLE) AS 
WITH
    C_1 AS(
        SELECT
            a.ID_VOIE_ADMINISTRATIVE,
            'Répétition du type de voie en début de nom' AS TYPE_ERREUR,
            TRIM(UPPER(b.libelle)) AS type_de_voie,
            a.NOM_VOIE,
            a.COMPLEMENT_NOM_VOIE
        FROM
            G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE a
            INNER JOIN G_BASE_VOIE.TEMP_C_TYPE_VOIE b ON b.objectid = a.fid_type_voie
        WHERE
            UPPER(a.nom_voie) LIKE 'ALLEE %'
            OR UPPER(a.nom_voie) LIKE 'AUTOPONT %'
            OR UPPER(a.nom_voie) LIKE 'AUTOROUTE %'
            OR UPPER(a.nom_voie) LIKE 'AVENUE %'
            OR UPPER(a.nom_voie) LIKE 'BOULEVARD%'
            OR UPPER(a.nom_voie) LIKE 'CARRIERE%'
            OR UPPER(a.nom_voie) LIKE 'CHAUSSEE%'
            OR UPPER(a.nom_voie) LIKE 'CHEMIN%'
            OR UPPER(a.nom_voie) LIKE 'CHEMIN RURAL%'
            OR UPPER(a.nom_voie) LIKE 'CITE %'
            OR UPPER(a.nom_voie) LIKE 'CLOS %'
            OR UPPER(a.nom_voie) LIKE 'COUR %'
            OR UPPER(a.nom_voie) LIKE 'CONTOUR %'
            OR UPPER(a.nom_voie) LIKE 'CHEMIN VICINAL ORD %'
            OR UPPER(a.nom_voie) LIKE 'DREVE %'
            OR UPPER(a.nom_voie) LIKE 'ECHANGEUR%'
            OR UPPER(a.nom_voie) LIKE 'FACADE%'
            OR UPPER(a.nom_voie) LIKE 'IMPASSE%'
            OR UPPER(a.nom_voie) LIKE 'ISSUE%'
            OR UPPER(a.nom_voie) LIKE 'PARVIS%'
            OR UPPER(a.nom_voie) LIKE 'PASSAGE PIETON%'
            OR UPPER(a.nom_voie) LIKE 'PAVE %'
            OR UPPER(a.nom_voie) LIKE 'PLACE %'
            OR UPPER(a.nom_voie) LIKE 'PONT %'
            OR UPPER(a.nom_voie) LIKE 'PASSAGE SOUT. PIET%'
            OR UPPER(a.nom_voie) LIKE 'PASSERELLE%'
            OR UPPER(a.nom_voie) LIKE 'QUAI %'
            OR UPPER(a.nom_voie) LIKE 'RANGEE%'
            OR UPPER(a.nom_voie) LIKE 'ROUTE DEPARTEMENT%'
            OR UPPER(a.nom_voie) LIKE 'RESIDENCE%'
            OR UPPER(a.nom_voie) LIKE 'ROUTE NATIONALE%'
            OR UPPER(a.nom_voie) LIKE 'ROND POINT%'
            OR UPPER(a.nom_voie) LIKE 'ROUTE %'
            OR UPPER(a.nom_voie) LIKE 'RUE %'
            OR UPPER(a.nom_voie) LIKE 'RUELLE %'
            OR UPPER(a.nom_voie) LIKE 'SQUARE %'
            OR UPPER(a.nom_voie) LIKE 'SENTIER %'
            OR UPPER(a.nom_voie) LIKE 'TERRAIN %'
            OR UPPER(a.nom_voie) LIKE 'VOIE DITE %'
            OR UPPER(a.nom_voie) LIKE 'VOIE %'
            OR UPPER(a.nom_voie) LIKE 'CARREFOUR %'
            OR UPPER(a.nom_voie) LIKE 'PASSAGE %'
            OR UPPER(a.nom_voie) LIKE 'ESPLANADE %'
            OR UPPER(a.nom_voie) LIKE 'TRAVERSE %'
            OR UPPER(a.nom_voie) LIKE 'PAVILLON %'
            OR UPPER(a.nom_voie) LIKE 'GROUPE %'
            OR UPPER(a.nom_voie) LIKE 'PLACETTE %'
            OR UPPER(a.nom_voie) LIKE 'RIVIERE %'
            OR UPPER(a.nom_voie) LIKE 'PARC %'
            OR UPPER(a.nom_voie) LIKE 'PORTE %'
            OR UPPER(a.nom_voie) LIKE 'PROMENADE %'
            OR UPPER(a.nom_voie) LIKE 'TERRASSE %'
            OR UPPER(a.nom_voie) LIKE 'HAMEAU %'
            OR UPPER(a.nom_voie) LIKE 'DOMAINE %'
            OR UPPER(a.nom_voie) LIKE 'GIRATOIRE %'
            OR UPPER(a.nom_voie) LIKE 'VOYETTE %'
            OR UPPER(a.nom_voie) LIKE 'VILLA %'
        UNION ALL
        SELECT
                a.ID_VOIE_ADMINISTRATIVE,
                'Répétition du type de voie en début de nom' AS TYPE_ERREUR,
                TRIM(UPPER(b.libelle)) AS type_de_voie,
                a.NOM_VOIE,
                a.COMPLEMENT_NOM_VOIE        
            FROM
                G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE a
                INNER JOIN G_BASE_VOIE.TEMP_C_TYPE_VOIE b ON b.objectid = a.fid_type_voie
            WHERE
                UPPER(a.nom_voie) LIKE 'AVE%'
                OR UPPER(a.nom_voie) LIKE 'BD%'
            UNION ALL
            SELECT
                a.ID_VOIE_ADMINISTRATIVE,
                'Absence de - derrière Saint pour les noms propres composés comme Saint-Hubert' AS TYPE_ERREUR,
                TRIM(UPPER(b.libelle)) AS type_de_voie,
                a.NOM_VOIE,
                a.COMPLEMENT_NOM_VOIE
            FROM
                G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE a
                INNER JOIN G_BASE_VOIE.TEMP_C_TYPE_VOIE b ON b.objectid = a.fid_type_voie
            WHERE
                TRIM(UPPER(a.nom_voie)) LIKE '%SAINT %'
            UNION ALL
            SELECT
                a.ID_VOIE_ADMINISTRATIVE,
                'Caractère spécial présent dans le nom' AS TYPE_ERREUR,
                TRIM(UPPER(b.libelle)) AS type_de_voie,
                a.NOM_VOIE,
                a.COMPLEMENT_NOM_VOIE
            FROM
                G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE a
                INNER JOIN G_BASE_VOIE.TEMP_C_TYPE_VOIE b ON b.objectid = a.fid_type_voie
            WHERE
                a.nom_voie LIKE '%"%'
                OR a.nom_voie LIKE '% ''%'
                OR a.nom_voie LIKE '%'' %'
    )
    
    SELECT DISTINCT
        a.*
    FROM
        C_1 a;

-- 2. Création des commentaires
COMMENT ON COLUMN "G_BASE_VOIE"."V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE"."ID_VOIE_ADMINISTRATIVE" IS 'Clé primaire de la vue correspondant aux identifiants des voies administratives.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE"."TYPE_ERREUR" IS 'Type d''erreur identifié.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE"."TYPE_VOIE" IS 'Type de voie.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE"."NOM_VOIE" IS 'Nom de la voie.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE"."COMPLEMENT_NOM_VOIE" IS 'Complément du nom de voie.';
COMMENT ON TABLE "G_BASE_VOIE"."V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE"  IS 'Vue - du projet C d''homogénéisation des noms de voie  - permettant d''identifier les voies qu''il reste à corriger.';

/

