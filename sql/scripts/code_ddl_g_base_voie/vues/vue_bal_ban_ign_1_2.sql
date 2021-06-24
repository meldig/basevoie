/*
Vue matérialisée V_BAL_BAN_IGN. Présentant les adresses présentes dans la base G_BASE_VOIE au format BAL version 1.2.
*/

-- 1. Création de la vue.
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_BAL_BAN_IGN" (
                                                  "UID_ADRESSE",
                                                  "CLE_INTEROP",
                                                  "COMMUNE_INSEE",
                                                  "COMMUNE_NOM",
                                                  "COMMUNE_DELEGUEE_INSEE",
                                                  "COMMUNE_DELEGUEE_NOM",
                                                  "VOIE_NOM",
                                                  "NUMERO",
                                                  "SUFFIXE",
                                                  "POSITION",
                                                  "X",
                                                  "Y",
                                                  "LONG",
                                                  "LAT",
                                                  "CAD_PARCELLES",
                                                  "SOURCE", 
                                                  "DATE_DER_MAJ"
                                                  )
CONSTRAINT "PK_V_BAL_BAN_IGN" PRIMARY KEY ("CLE_INTEROP") DISABLE) AS 
SELECT
    a.OBJECTID AS "UID_ADRESSE",
    CASE
      WHEN a.complement_numero_seuil IS NULL
      THEN b.code_insee||'_'|| '591' || h.code_rivoli || substr(b.code_insee,3,5) || h.cle_controle ||'_'||a.numero_seuil
      ELSE
            CASE LENGTH(CAST (a.numero_seuil AS VARCHAR(5)))
                WHEN 1
                  THEN b.code_insee||'_'|| '591' || h.code_rivoli || substr(b.code_insee,3,5) || h.cle_controle ||'_'|| '0000' || a.numero_seuil||'_'|| LOWER(a.complement_numero_seuil)
                WHEN 2
                  THEN b.code_insee||'_'|| '591' || h.code_rivoli || substr(b.code_insee,3,5) || h.cle_controle ||'_'|| '000' || a.numero_seuil||'_'|| LOWER(a.complement_numero_seuil)
                WHEN 3
                  THEN b.code_insee||'_'|| '591' || h.code_rivoli || substr(b.code_insee,3,5) || h.cle_controle ||'_'|| '00' || a.numero_seuil||'_'|| LOWER(a.complement_numero_seuil)
                WHEN 4
                  THEN b.code_insee||'_'|| '591' || h.code_rivoli || substr(b.code_insee,3,5) || h.cle_controle ||'_'|| '0' || a.numero_seuil||'_'|| LOWER(a.complement_numero_seuil)
                ELSE
                  b.code_insee||'_'|| '591' || h.code_rivoli || substr(b.code_insee,3,5) || h.cle_controle ||'_'|| a.numero_seuil||'_'|| LOWER(a.complement_numero_seuil)
            END
    END AS "CLE_INTEROP",
    -- COMMUNE_INSEE
    CASE b.code_insee
      WHEN '59298'
        THEN '59350'
      WHEN '59355'
        THEN '59350'
      ELSE b.code_insee
    END AS "COMMUNE_INSEE",
    -- COMMUNE_NOM
    CASE CAST(b.code_insee AS CHAR)
      WHEN '59298'
        THEN 'LILLE'
      WHEN '59355'
        THEN 'LILLE'
      ELSE i.NOM
    END AS "COMMUNE_NOM",
    -- COMMUNE_DELEGUEE_INSEE
    CASE b.code_insee
      WHEN '59298'
        THEN '59298'
      WHEN '59355'
        THEN '59355'
      ELSE
        NULL
    END AS "COMMUNE_DELEGUEE_INSEE",
    -- COMMUNE_DELEGUEE_NOM
    CASE CAST(b.code_insee AS CHAR)
      WHEN '59298'
        THEN 'HELLEMMES'
      WHEN '59355'
      THEN 'LOMME'
    ELSE
        NULL
    END AS "COMMUNE_DELEGUEE_NOM",
    -- VOIE_NOM
    UPPER(g.libelle) || ' ' || UPPER(f.libelle_voie) AS "VOIE_NOM",
    a.numero_seuil AS "NUMERO",
    a.complement_numero_seuil AS "SUFFIXE",
  'entrée' AS "POSITION",
  -- recuperation des coordonnées en X et Y
  b.geom.sdo_point.x AS "X",
  b.geom.sdo_point.y AS "Y",
  SDO_CS.TRANSFORM(b.geom,4326).sdo_point.x AS "LONG",
  SDO_CS.TRANSFORM(b.geom,4326).sdo_point.y AS "LAT",
  'MEL' SOURCE,
  a.numero_parcelle AS "CAD_PARCELLES",
  a.date_modification AS "DATE_DER_MAJ"
FROM
  g_base_voie.ta_infos_seuil a
INNER JOIN g_base_voie.ta_seuil b ON b.objectid = a.objectid
INNER JOIN g_base_voie.ta_relation_troncon_seuil c ON c.fid_seuil = b.objectid
INNER JOIN g_base_voie.ta_troncon d ON d.objectid = c.fid_troncon
INNER JOIN g_base_voie.ta_relation_troncon_voie e ON e.fid_troncon = d.objectid
INNER JOIN g_base_voie.ta_voie f ON f.objectid = e.fid_voie
INNER JOIN g_base_voie.ta_type_voie g ON g.objectid = f.fid_typevoie
INNER JOIN g_base_voie.ta_rivoli h ON h.objectid = f.fid_rivoli
INNER JOIN G_REFERENTIEL.A_COMMUNE i ON i.code_insee = b.code_insee
;

-- 2. Création des commentaires de table et de colonnes
COMMENT ON VIEW "G_BASE_VOIE"."V_BAL_BAN_IGN"  IS 'Vue des adresses au format BAL';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_BAN_IGN"."UID_ADRESSE" IS 'Identifiant unique d''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_BAN_IGN"."CLE_INTEROP" IS 'Clé d''interopérabilité: INSSE + _ + FANTOIR + _ + numéro d''adresse + _ + suffixe. Le tout en minuscule';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_BAN_IGN"."COMMUNE_INSEE" IS 'Code INSEE de la commune d''implantation de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_BAN_IGN"."COMMUNE_NOM" IS 'Nom de la commune d''implantation de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_BAN_IGN"."COMMUNE_DELEGUEE_INSEE" IS 'Code INSEE de la commune déléguée d''implantation de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_BAN_IGN"."COMMUNE_DELEGUEE_NOM" IS 'Nom de la commune déléguée d''implantation de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_BAN_IGN"."VOIE_NOM" IS 'Nom de la voie';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_BAN_IGN"."NUMERO" IS 'Numéro de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_BAN_IGN"."SUFFIXE" IS 'Suffixe de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_BAN_IGN"."POSITION" IS 'Position de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_BAN_IGN"."X" IS 'Coordonnée X';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_BAN_IGN"."Y" IS 'Coordonnée Y';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_BAN_IGN"."LONG" IS 'Longitude';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_BAN_IGN"."LAT" IS 'Latitude';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_BAN_IGN"."SOURCE" IS 'Source de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_BAN_IGN"."CAD_PARCELLES" IS 'Liste des parcelles représentées par l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAL_BAN_IGN"."DATE_DER_MAJ" IS 'Date de la dernière mise à jour';