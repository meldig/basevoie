/*
Création de la vue V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE - du projet C d''homogénéisation des noms de voie  - permettant de suivre la correction des noms des voies administratives.
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE EDITIONABLE VIEW "G_BASE_VOIE"."V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE" ("OBJECTID", "TYPE_ERREUR", "DESCRIPTION_ERREUR", "NOMBRE",
	 CONSTRAINT "V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
WITH
    C_1 AS( -- Décompte des voies administratives dont le type de voie figure en début de libellé de voie
        SELECT
            'Répétition du type de voie en début de nom' AS TYPE_ERREUR,
            TRIM(UPPER(b.libelle)) AS description_erreur,
            COUNT(*) AS nombre
        FROM
            G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE a
            INNER JOIN G_BASE_VOIE.TEMP_C_TYPE_VOIE b ON b.objectid = a.fid_type_voie
        WHERE
            UPPER(a.libelle_voie) LIKE 'ALLEE%'
            OR UPPER(a.libelle_voie) LIKE 'AUTOPONT%'
            OR UPPER(a.libelle_voie) LIKE 'AUTOROUTE%'
            OR UPPER(a.libelle_voie) LIKE 'AVENUE%'
            OR UPPER(a.libelle_voie) LIKE 'BOULEVARD%'
            OR UPPER(a.libelle_voie) LIKE 'CARRIERE%'
            OR UPPER(a.libelle_voie) LIKE 'CHAUSSEE%'
            OR UPPER(a.libelle_voie) LIKE 'CHEMIN%'
            OR UPPER(a.libelle_voie) LIKE 'CHEMIN RURAL%'
            OR UPPER(a.libelle_voie) LIKE 'CITE%'
            OR UPPER(a.libelle_voie) LIKE 'CLOS%'
            OR UPPER(a.libelle_voie) LIKE 'COUR%'
            OR UPPER(a.libelle_voie) LIKE 'CONTOUR%'
            OR UPPER(a.libelle_voie) LIKE 'CHEMIN VICINAL ORD%'
            OR UPPER(a.libelle_voie) LIKE 'DREVE%'
            OR UPPER(a.libelle_voie) LIKE 'ECHANGEUR%'
            OR UPPER(a.libelle_voie) LIKE 'FACADE%'
            OR UPPER(a.libelle_voie) LIKE 'IMPASSE%'
            OR UPPER(a.libelle_voie) LIKE 'ISSUE%'
            OR UPPER(a.libelle_voie) LIKE 'PARVIS%'
            OR UPPER(a.libelle_voie) LIKE 'PASSAGE PIETON%'
            OR UPPER(a.libelle_voie) LIKE 'PAVE%'
            OR UPPER(a.libelle_voie) LIKE 'PLACE%'
            OR UPPER(a.libelle_voie) LIKE 'PONT%'
            OR UPPER(a.libelle_voie) LIKE 'PASSAGE SOUT. PIET%'
            OR UPPER(a.libelle_voie) LIKE 'PASSERELLE%'
            OR UPPER(a.libelle_voie) LIKE 'QUAI%'
            OR UPPER(a.libelle_voie) LIKE 'RANGEE%'
            OR UPPER(a.libelle_voie) LIKE 'ROUTE DEPARTEMENT%'
            OR UPPER(a.libelle_voie) LIKE 'RESIDENCE%'
            OR UPPER(a.libelle_voie) LIKE 'ROUTE NATIONALE%'
            OR UPPER(a.libelle_voie) LIKE 'ROND POINT%'
            OR UPPER(a.libelle_voie) LIKE 'ROUTE%'
            OR UPPER(a.libelle_voie) LIKE 'RUE%'
            OR UPPER(a.libelle_voie) LIKE 'RUELLE%'
            OR UPPER(a.libelle_voie) LIKE 'SQUARE%'
            OR UPPER(a.libelle_voie) LIKE 'SENTIER%'
            OR UPPER(a.libelle_voie) LIKE 'TERRAIN%'
            OR UPPER(a.libelle_voie) LIKE 'VOIE DITE%'
            OR UPPER(a.libelle_voie) LIKE 'VOIE%'
            OR UPPER(a.libelle_voie) LIKE 'CARREFOUR%'
            OR UPPER(a.libelle_voie) LIKE 'PASSAGE%'
            OR UPPER(a.libelle_voie) LIKE 'ESPLANADE%'
            OR UPPER(a.libelle_voie) LIKE 'TRAVERSE%'
            OR UPPER(a.libelle_voie) LIKE 'PAVILLON%'
            OR UPPER(a.libelle_voie) LIKE 'GROUPE%'
            OR UPPER(a.libelle_voie) LIKE 'PLACETTE%'
            OR UPPER(a.libelle_voie) LIKE 'RIVIERE%'
            OR UPPER(a.libelle_voie) LIKE 'PARC%'
            OR UPPER(a.libelle_voie) LIKE 'PORTE%'
            OR UPPER(a.libelle_voie) LIKE 'PROMENADE%'
            OR UPPER(a.libelle_voie) LIKE 'TERRASSE%'
            OR UPPER(a.libelle_voie) LIKE 'HAMEAU%'
            OR UPPER(a.libelle_voie) LIKE 'DOMAINE%'
            OR UPPER(a.libelle_voie) LIKE 'GIRATOIRE%'
            OR UPPER(a.libelle_voie) LIKE 'VOYETTE%'
            OR UPPER(a.libelle_voie) LIKE 'VILLA%'
        GROUP BY
            'Répétition du type de voie en début de nom',
            TRIM(UPPER(b.libelle))
        UNION ALL
        SELECT
            'Répétition du type de voie en début de nom' AS TYPE_ERREUR,
            CASE
                WHEN UPPER(a.libelle_voie) LIKE 'AVE%' THEN
                        'AVE'
                WHEN UPPER(a.libelle_voie) LIKE 'BD%' THEN
                    'BD'
            END AS description_erreur,
            COUNT(*) AS nombre
        FROM
            G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE a
        WHERE
            UPPER(a.libelle_voie) LIKE 'AVE%'
            OR UPPER(a.libelle_voie) LIKE 'BD%'
        GROUP BY
            'Répétition du type de voie en début de nom',
            CASE
                WHEN UPPER(a.libelle_voie) LIKE 'AVE%' THEN
                        'AVE'
                WHEN UPPER(a.libelle_voie) LIKE 'BD%' THEN
                    'BD'
            END
        UNION ALL
        SELECT
            'Absence de - derrière Saint pour les noms propres composés comme Saint-Hubert' AS TYPE_ERREUR,
            CASE
                WHEN TRIM(UPPER(a.libelle_voie)) LIKE '%SAINT %' THEN
                    'Saint '
            END AS description_erreur,
            COUNT(*) AS nombre
        FROM
            G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE a
        WHERE
            TRIM(UPPER(a.libelle_voie)) LIKE '%SAINT %'
        GROUP BY
            'Absence de - derrière Saint pour les noms propres composés comme Saint-Hubert',
            CASE
                WHEN TRIM(UPPER(a.libelle_voie)) LIKE '%SAINT %' THEN
                    'Saint '
            END
        UNION ALL
        SELECT
            'Caractère spécial présent dans le nom' AS TYPE_ERREUR,
            CASE
                WHEN a.libelle_voie LIKE '%"%' THEN
                    '%"%'
                WHEN a.libelle_voie LIKE '% ''%' THEN
                    '% ''%'
                WHEN a.libelle_voie LIKE '%'' %' THEN
                    '%'' %'
            END AS description_erreur,
            COUNT(*) AS nombre
        FROM
            G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE a
        WHERE
            a.libelle_voie LIKE '%"%'
            OR a.libelle_voie LIKE '% ''%'
            OR a.libelle_voie LIKE '%'' %'
        GROUP BY
            'Caractère spécial présent dans le nom',
            CASE
                WHEN a.libelle_voie LIKE '%"%' THEN
                    '%"%'
                WHEN a.libelle_voie LIKE '% ''%' THEN
                    '% ''%'
                WHEN a.libelle_voie LIKE '%'' %' THEN
                    '%'' %'
            END

    ),
    
    C_2 AS( -- Sélection des voies administratives reliées à des voies supra-communales
        SELECT DISTINCT
            'Noms de voie différents par voie supra-communale' AS type_erreur,
            TRIM(b.idsupvoi) AS description_erreur,
            a.libelle_voie
        FROM
            G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE a
            INNER JOIN SIREO_LEC.EXRD_ORDONNEE b ON b.ccomvoi = a.objectid
    ),
    
    C_3 AS(-- Décompte des voies administratives, reliées à une voie supra-communale, ayant des libellés de voies différents
        SELECT
            type_erreur,
            description_erreur,
            COUNT(libelle_voie) AS nombre
        FROM
            C_2
        GROUP BY
            type_erreur,
            description_erreur
        HAVING
            COUNT(libelle_voie) > 1
    ),
    
    C_4 AS(        
        SELECT
            type_erreur,
            description_erreur,
            nombre
        FROM
            C_1
        UNION ALL
        SELECT
            type_erreur,
            description_erreur,
            nombre
        FROM
            C_3
    )
    
    SELECT
        rownum AS objectid,
        type_erreur,
        description_erreur,
        nombre
    FROM
        C_4
    ORDER BY
        type_erreur;

-- 2. Création des commentaires    
COMMENT ON COLUMN "G_BASE_VOIE"."V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE"."OBJECTID" IS 'Clé primaire de la vue.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE"."TYPE_ERREUR" IS 'Type d''erreur identifié.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE"."DESCRIPTION_ERREUR" IS 'Catégories d''erreur par type d''erreur.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE"."NOMBRE" IS 'Nombre d''entités par catégorie et type d''erreur.';
COMMENT ON TABLE "G_BASE_VOIE"."V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE"  IS 'Vue - du projet C d''homogénéisation des noms de voie  - permettant de suivre la correction des noms des voies administratives.';

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_TEMP_C_SUIVI_CORRECTION_NOMENCLATURE_VOIE TO G_ADMIN_SIG;

/

