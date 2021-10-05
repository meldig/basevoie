CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_ADRESSE_LITTERALIS" ("IDENTIFIANT", "CODE_VOIE", "CODE_POINT", "NATURE", "LIBELLE", "NUMERO", "REPETITION", "COTE", "GEOMETRY", 
    CONSTRAINT "V_ADRESSE_LITTERALIS_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS 
  WITH
    C_1 AS(
    SELECT
        MAX(fid_troncon) AS max_troncon
    FROM
        ta_relation_troncon_seuil
    ),

    C_2 AS(
    SELECT
        a.code_tronc AS id_trc_virtuel,
        c.objectid AS id_trc_reel,
        a.code_rue_g AS code_voie
    FROM
        vm_troncon_litteralis a,
        C_1 b,
        TA_TRONCON c
    WHERE
        CAST(a.code_tronc AS NUMBER(38,0)) > b.max_troncon
        AND c.objectid = (CAST(a.code_tronc AS NUMBER(38,0)) - b.max_troncon)
    ),
    
    C_3 AS(
    SELECT DISTINCT
        d.code_voie AS CODE_VOIE,
        b.objectid AS CODE_POINT,
        'ADR' AS NATURE,
        CASE
            WHEN a.complement_numero_seuil IS NULL
                THEN CAST(a.numero_seuil AS VARCHAR2(254))
            WHEN a.complement_numero_seuil IS NOT NULL
                THEN CAST(a.numero_seuil || ' ' || a.complement_numero_seuil AS VARCHAR2(254))
            END AS libelle,
        a.numero_seuil AS NUMERO,
        a.complement_numero_seuil AS REPETITION,
        'LesDeuxCotes' AS COTE
    FROM
        G_BASE_VOIE.TA_INFOS_SEUIL a
        INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = b.objectid
        INNER JOIN C_2 d ON d.id_trc_reel = c.fid_troncon
    ),
    
    C_4 AS(
    SELECT
        C_3.CODE_VOIE,
        CAST(C_3.CODE_POINT AS VARCHAR2(254)) AS CODE_POINT,
        CAST(C_3.NATURE AS VARCHAR2(254)) AS NATURE,
        C_3.LIBELLE AS LIBELLE,
        CAST(C_3.NUMERO AS NUMBER(8,0)) AS NUMERO,
        CAST(C_3.REPETITION AS VARCHAR2(10)) AS REPETITION,
        CAST(C_3.COTE AS VARCHAR2(254)) AS COTE,
        b.geom AS GEOMETRY
    FROM
        C_3 
        INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.OBJECTID = C_3.CODE_POINT
    ),
    
    C_5 AS(
    SELECT DISTINCT
        f.objectid AS CODE_VOIE,
        b.objectid AS CODE_POINT,
        'ADR' AS NATURE,
        CASE
            WHEN a.complement_numero_seuil IS NULL
                THEN CAST(a.numero_seuil AS VARCHAR2(254))
            WHEN a.complement_numero_seuil IS NOT NULL
                THEN CAST(a.numero_seuil || ' ' || a.complement_numero_seuil AS VARCHAR2(254))
            END AS libelle,
        a.numero_seuil AS NUMERO,
        a.complement_numero_seuil AS REPETITION,
        'LesDeuxCotes' AS COTE
    FROM
        G_BASE_VOIE.TA_INFOS_SEUIL a
        INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = b.objectid
        INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = c.fid_troncon
        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE e ON e.fid_troncon = d.objectid
        INNER JOIN G_BASE_VOIE.TA_VOIE f ON f.objectid = e.fid_voie
    WHERE
        a.objectid NOT IN(SELECT code_point FROM C_3)
    ),
    
    C_6 AS(
    SELECT
        CAST(C_5.CODE_VOIE AS VARCHAR2(254)) AS CODE_VOIE,
        CAST(C_5.CODE_POINT AS VARCHAR2(254)) AS CODE_POINT,
        CAST(C_5.NATURE AS VARCHAR2(254)) AS NATURE,
        C_5.LIBELLE AS LIBELLE,
        CAST(C_5.NUMERO AS NUMBER(8,0)) AS NUMERO,
        CAST(C_5.REPETITION AS VARCHAR2(10)) AS REPETITION,
        CAST(C_5.COTE AS VARCHAR2(254)) AS COTE,
        b.geom AS GEOMETRY
    FROM
        C_5
        INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.OBJECTID = C_5.CODE_POINT
    ),
    
    C_7 AS(
    SELECT
        CODE_VOIE,
        CODE_POINT,
        NATURE,
        LIBELLE,
        NUMERO,
        REPETITION,
        COTE,
        GEOMETRY
    FROM
        C_4
    UNION ALL
    SELECT
        CODE_VOIE,
        CODE_POINT,
        NATURE,
        LIBELLE,
        NUMERO,
        REPETITION,
        COTE,
        GEOMETRY
    FROM
        C_6
    )
   
    SELECT
        ROWNUM AS IDENTIFIANT,
        CODE_VOIE,
        CODE_POINT,
        NATURE,
        LIBELLE,
        NUMERO,
        REPETITION,
        COTE,
        GEOMETRY
    FROM
        C_7;

   COMMENT ON COLUMN "G_BASE_VOIE"."V_ADRESSE_LITTERALIS"."IDENTIFIANT" IS 'Cle primaire de la vue';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_ADRESSE_LITTERALIS"."CODE_VOIE" IS 'Liaison avec la classe TRONCON sur la colonne CODE_RUE_G ou CODE_RUE_D.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_ADRESSE_LITTERALIS"."CODE_POINT" IS 'Identificateur unique et immuable du point partagé entre Littéralis Expert et le SIG.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_ADRESSE_LITTERALIS"."NATURE" IS 'Indique la nature du point: ADR = Adresse.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_ADRESSE_LITTERALIS"."LIBELLE" IS 'Libellé du point affiché dans les textes (dans les actes…).';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_ADRESSE_LITTERALIS"."NUMERO" IS 'Code INSEE de la commune côté gauche du tronçon..';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_ADRESSE_LITTERALIS"."REPETITION" IS 'Indique la valeur de répétition d’un numéro sur une rue. La saisie de la répétition est libre.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_ADRESSE_LITTERALIS"."COTE" IS 'Définit sur quel côté de la voie s’appuie l’adresse: LesDeuxCotes, Impair, Pair.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_ADRESSE_LITTERALIS"."GEOMETRY" IS 'Géométrie de type point.';
   COMMENT ON TABLE "G_BASE_VOIE"."V_ADRESSE_LITTERALIS"  IS 'Vue regroupant la liste des adresses postales par rue pour LITTERALIS';