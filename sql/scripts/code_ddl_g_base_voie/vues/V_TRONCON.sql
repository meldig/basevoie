CREATE OR REPLACE FORCE VIEW V_TRONCON_LITTERALIS (
    IDENTIFIANT,
    CODE_TRONC,
    CLASSEMENT,
    CODE_RUE_G,
    NOM_RUE_G,
    INSEE_G,
    CODE_RUE_D,
    NOM_RUE_D,
    INSEE_D,
    LARGEUR,
    GEOMETRY,
    CONSTRAINT "V_TRONCON_LITTERALIS_PK" PRIMARY KEY ("CODE_TRONC") DISABLE)
    AS 
  WITH
    -- Repérer les tronçons affectés à plusieurs voies
    C_1 AS(
        SELECT
            a.objectid AS code_troncon,
            COUNT(c.objectid) AS nbr_voies
        FROM
            G_BASE_VOIE.TA_TRONCON a
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
            INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = b.fid_voie
        GROUP BY
            a.objectid
        HAVING
            COUNT(c.objectid) > 1
    ),
    
    C_2 AS( -- Sélection du code voie maximum par doublon dont nous allons modifier le code tronçon
        SELECT
            a.code_troncon,
            MAX(c.objectid) AS code_voie
        FROM
            C_1 a
            INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = a.code_troncon
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.code_troncon
            INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = b.fid_voie
        GROUP BY
            a.code_troncon
    ),
            
    C_3 AS(-- Sélection de l'objectid max de TA_TRONCON afin de ne pas créer de doublons d'id
        SELECT
            MAX(objectid) AS code_troncon_max
        FROM
            G_BASE_VOIE.TA_TRONCON
    ),
    
    C_4 AS(-- Création des nouveaux id pour les doublons et sélection des autres données
        SELECT 
            (d.code_troncon_max + rownum) AS code_troncon_max,
            a.code_troncon,
            CASE 
                WHEN b.domania = 'AUTOROUTE OU VOIE A CARACTERE AUTOROUTIER'
                THEN 'A'
                WHEN b.domania = 'ROUTE NATIONALE'
                THEN 'RN' -- Route Nationale
                WHEN b.domania IN ('VOIE PRIVEE ENTRETENUE PAR LA CUDL','VOIE PRIVEE FERMEE','VOIE PRIVEE OUVERTE','AUTRE VOIE PRIVEE','DECLASSEMENT EN COURS')
                THEN 'VP' -- Voie Privée
                WHEN b.domania = 'CHEMIN RURAL'
                THEN 'CR' -- Chemin Rural
                WHEN b.domania IN ('VOIE METROPOLITAINE','GESTION COMMUNAUTAIRE','AUTRE VOIE PUBLIQUE')
                THEN 'VC' -- Voie Communale
            END AS CLASSEMENT,
            a.code_voie AS CODE_RUE_G,
            UPPER(f.libelle) || ' ' || UPPER(e.libelle_voie) AS NOM_RUE_G,
            a.code_voie AS CODE_RUE_D,
            UPPER(f.libelle) || ' ' || UPPER(e.libelle_voie) AS NOM_RUE_D,
            c.geom,
            GET_CODE_INSEE_CONTAIN_LINE('TA_TRONCON', c.geom) AS code_insee
        FROM
            C_2 a
            INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.objectid = a.code_troncon
            INNER JOIN SIREO_LEC.OUT_DOMANIALITE b ON b.cnumtrc = a.code_troncon
            INNER JOIN G_BASE_VOIE.TA_VOIE e ON e.objectid = a.code_voie
            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE f ON f.objectid = e.fid_typevoie,
            C_3 d
    ),
    
    C_5 AS( -- Sélection rassemblant les tronçons uniques et les tronçons doublonnés en base
        SELECT DISTINCT
            a.objectid AS CODE_TRONC,
            a.objectid AS doublon,
            CASE 
                WHEN e.domania = 'AUTOROUTE OU VOIE A CARACTERE AUTOROUTIER'
                THEN 'A'
                WHEN e.domania = 'ROUTE NATIONALE'
                THEN 'RN' -- Route Nationale
                WHEN e.domania IN ('VOIE PRIVEE ENTRETENUE PAR LA CUDL','VOIE PRIVEE FERMEE','VOIE PRIVEE OUVERTE','AUTRE VOIE PRIVEE','DECLASSEMENT EN COURS')
                THEN 'VP' -- Voie Privée
                WHEN e.domania = 'CHEMIN RURAL'
                THEN 'CR' -- Chemin Rural
                WHEN e.domania IN ('VOIE METROPOLITAINE','GESTION COMMUNAUTAIRE','AUTRE VOIE PUBLIQUE')
                THEN 'VC' -- Voie Communale
            END AS CLASSEMENT,
            c.objectid AS CODE_RUE_G,
            UPPER(d.libelle) || ' ' || UPPER(c.libelle_voie) AS NOM_RUE_G,
            c.objectid AS CODE_RUE_D,
            UPPER(d.libelle) || ' ' || UPPER(c.libelle_voie) AS NOM_RUE_D,
            GET_CODE_INSEE_CONTAIN_LINE('TA_TRONCON', a.geom) AS code_insee
        FROM
            G_BASE_VOIE.TA_TRONCON a
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
            INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = b.fid_voie
            INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE d ON d.objectid = c.fid_typevoie
            INNER JOIN SIREO_LEC.OUT_DOMANIALITE e ON e.cnumtrc = a.objectid
        WHERE
            a.objectid NOT IN(SELECT code_troncon FROM C_4)
        UNION ALL
        SELECT
            a.code_troncon_max AS CODE_TRONC,
            a.code_troncon AS doublon,
            a.CLASSEMENT,
            a.CODE_RUE_G,
            a.NOM_RUE_G,
            a.CODE_RUE_D,
            a.NOM_RUE_D,
            a.code_insee
        FROM
            C_4 a            
    )
    
    SELECT
        CAST(ROWNUM AS NUMBER(38,0)) AS IDENTIFIANT,
        CAST(b.CODE_TRONC AS VARCHAR2(254)) AS CODE_TRONC,
        CAST(b.CLASSEMENT AS VARCHAR2(254)) AS CLASSEMENT,
        CAST(b.CODE_RUE_G AS VARCHAR2(254)) AS CODE_RUE_G,
        CAST(b.NOM_RUE_G AS VARCHAR2(254)) AS NOM_RUE_G,
        CAST(b.CODE_INSEE AS VARCHAR2(254)) AS INSEE_G,
        CAST(b.CODE_RUE_D AS VARCHAR2(254)) AS CODE_RUE_D,
        CAST(b.NOM_RUE_D AS VARCHAR2(254)) AS NOM_RUE_D,
        CAST(b.CODE_INSEE AS VARCHAR2(254)) AS INSEE_D,
        CAST('' AS NUMBER(8,0)) AS LARGEUR,
        a.geom AS GEOMETRY
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN C_5 b ON b.doublon = a.objectid;

-- 2. Création des commentaires de la vue
COMMENT ON TABLE G_BASE_VOIE.V_TRONCON_LITTERALIS IS 'Vue regroupant la liste des tronçons constituant une voie, dont les catégorisations répondent aux exigences du prestataire Sogelink afin de remplir la base de données Litteralis.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_LITTERALIS.IDENTIFIANT IS 'Cle primaire de la vue';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_LITTERALIS.CODE_TRONC IS 'Identificateur unique et immuable du tronçon de voie partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_LITTERALIS.CLASSEMENT IS 'Classement de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_LITTERALIS.CODE_RUE_G IS 'Code unique de la rue côté gauche du tronçon partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_LITTERALIS.NOM_RUE_G IS 'Nom de la voie côté gauche du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_LITTERALIS.INSEE_G IS 'Code INSEE de la commune côté gauche du tronçon..';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_LITTERALIS.CODE_RUE_D IS 'Code unique de la rue côté droit du tronçon partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_LITTERALIS.NOM_RUE_D IS 'Nom de la voie côté droit du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_LITTERALIS.INSEE_D IS 'Code INSEE de la commune côté droit du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.V_TRONCON_LITTERALIS.LARGEUR IS 'Valeur indiquant une largeur de la voie.';