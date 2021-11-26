/*
Vue matérialisée V_BAN_VERSION_1_3. Présentant les adresses présentes dans la base G_BASE_VOIE au format BAL version 1.3.
*/

-- 1. Création de la vue.
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_BAN_VERSION_1_3" (
                                                  "UID_ADRESSE",
                                                  "CLE_INTEROP",
                                                  "COMMUNE_INSEE",
                                                  "COMMUNE_NOM",
                                                  "COMMUNE_DELEGUEE_INSEE",
                                                  "COMMUNE_DELEGUEE_NOM",
                                                  "VOIE_NOM",
                                                  "LIEUDIT_COMPLEMENT_NOM",
                                                  "NUMERO",
                                                  "SUFFIXE",
                                                  "POSITION",
                                                  "X",
                                                  "Y",
                                                  "LONG",
                                                  "LAT",
                                                  "CAD_PARCELLES",
                                                  "SOURCE", 
                                                  "DATE_DER_MAJ",
                                                  "CERTIFICATION_COMMUNE",
CONSTRAINT "PK_V_BAN_VERSION_1_3" PRIMARY KEY ("CLE_INTEROP") DISABLE) AS 
SELECT
    a.OBJECTID AS "UID_ADRESSE",
-- GESTION DU CHAMP CLE INTEROP SI IL N'Y A PAS DE COMPLEMENT DE SEUIL
    CASE
      WHEN a.complement_numero_seuil IS NULL
        THEN
          CASE LENGTH(CAST (a.numero_seuil AS VARCHAR(5)))
            WHEN 0
              THEN j.code_insee||'_'|| h.code_rivoli ||'_'|| '00000'
            WHEN 1
              THEN j.code_insee||'_'|| h.code_rivoli ||'_'|| '0000' || a.numero_seuil
            WHEN 2
              THEN j.code_insee||'_'|| h.code_rivoli ||'_'|| '000' || a.numero_seuil
            WHEN 3
              THEN j.code_insee||'_'|| h.code_rivoli ||'_'|| '00' || a.numero_seuil
            WHEN 4
              THEN j.code_insee||'_'|| h.code_rivoli ||'_'|| '0' || a.numero_seuil
            WHEN 5
              THEN j.code_insee||'_'|| h.code_rivoli ||'_'|| a.numero_seuil
          END
    ELSE
-- GESTION DU CHAMP CLE INTEROP SI IL N'Y A UN COMPLEMENT DE SEUIL
            CASE LENGTH(CAST (a.numero_seuil AS VARCHAR(5)))
                WHEN 0
                  THEN j.code_insee||'_'|| h.code_rivoli ||'_'|| '00000' ||'_'|| LOWER(a.complement_numero_seuil)
                WHEN 1
                  THEN j.code_insee||'_'|| h.code_rivoli ||'_'|| '0000' || a.numero_seuil||'_'|| LOWER(a.complement_numero_seuil)
                WHEN 2
                  THEN j.code_insee||'_'|| h.code_rivoli ||'_'|| '000' || a.numero_seuil||'_'|| LOWER(a.complement_numero_seuil)
                WHEN 3
                  THEN j.code_insee||'_'|| h.code_rivoli ||'_'|| '00' || a.numero_seuil||'_'|| LOWER(a.complement_numero_seuil)
                WHEN 4
                  THEN j.code_insee||'_'|| h.code_rivoli ||'_'|| '0' || a.numero_seuil||'_'|| LOWER(a.complement_numero_seuil)
                ELSE
                        j.code_insee||'_'|| h.code_rivoli ||'_'|| a.numero_seuil||'_'|| LOWER(a.complement_numero_seuil)
            END
    END AS "CLE_INTEROP",
-- COMMUNE_INSEE
    CASE i.nature
      WHEN 'Commune associée'
        THEN j.code_insee
      ELSE j.code_insee
    END AS "COMMUNE_INSEE",
    -- COMMUNE_NOM
    CASE i.nature
      WHEN 'Commune associée'
        THEN j.nom
      ELSE j.NOM
    END AS "COMMUNE_NOM",
    -- COMMUNE_DELEGUEE_INSEE
    CASE i.nature
      WHEN 'Commune associée'
        THEN i.code_insee
      ELSE
        NULL
    END AS "COMMUNE_DELEGUEE_INSEE",
    -- COMMUNE_DELEGUEE_NOM
    CASE i.nature
      WHEN 'Commune associée'
        THEN i.nom
    ELSE
        NULL
    END AS "COMMUNE_DELEGUEE_NOM",
    -- VOIE_NOM
    UPPER(g.libelle) || ' ' || UPPER(f.libelle_voie) AS "VOIE_NOM",
    NULL AS "LIEUDIT_COMPLEMENT_NOM",
    a.numero_seuil AS "NUMERO",
    a.complement_numero_seuil AS "SUFFIXE",
  'entrée' AS "POSITION",
  -- recuperation des coordonnées en X et Y
  b.geom.sdo_point.x AS "X",
  b.geom.sdo_point.y AS "Y",
  SDO_CS.TRANSFORM(b.geom,4326).sdo_point.x AS "LONG",
  SDO_CS.TRANSFORM(b.geom,4326).sdo_point.y AS "LAT",
  'MEL' AS SOURCE,
  -- NUMERO PARCELLE
  CASE a.numero_parcelle
    WHEN 'NR'
      THEN NULL
    ELSE a.numero_parcelle
  END AS "CAD_PARCELLES",
  a.date_modification AS "DATE_DER_MAJ",
  0 AS "CERTIFICATION_COMMUNE"
FROM
  g_base_voie.ta_infos_seuil a
INNER JOIN g_base_voie.ta_seuil b ON b.objectid = a.fid_seuil
INNER JOIN g_base_voie.ta_relation_troncon_seuil c ON c.fid_seuil = b.objectid
INNER JOIN g_base_voie.ta_troncon d ON d.objectid = c.fid_troncon
INNER JOIN g_base_voie.ta_relation_troncon_voie e ON e.fid_troncon = d.objectid
INNER JOIN g_base_voie.ta_voie f ON f.objectid = e.fid_voie
INNER JOIN g_base_voie.ta_type_voie g ON g.objectid = f.fid_typevoie
INNER JOIN g_base_voie.ta_rivoli h ON h.objectid = f.fid_rivoli
INNER JOIN g_base_voie.ta_rivoli h ON h.objectid = f.fid_rivoli,
    g_referentiel.MEL_COMMUNE_LLH i,
    g_referentiel.MEL_COMMUNE j
WHERE
    SDO_CONTAINS(j.geom, b.geom) = 'TRUE'
AND
    SDO_CONTAINS(i.geom, b.geom) = 'TRUE'
;

-- 2. Création des commentaires de table et de colonnes
COMMENT ON TABLE "G_BASE_VOIE"."V_BAN_VERSION_1_3"  IS 'Vue des adresses au format BAL';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."UID_ADRESSE" IS 'Identifiant unique d''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."CLE_INTEROP" IS 'Clé d''interopérabilité: INSSE + _ + FANTOIR + _ + numéro d''adresse + _ + suffixe. Le tout en minuscule';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."COMMUNE_INSEE" IS 'Code INSEE de la commune d''implantation de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."COMMUNE_NOM" IS 'Nom de la commune d''implantation de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."COMMUNE_DELEGUEE_INSEE" IS 'Code INSEE de la commune déléguée d''implantation de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."COMMUNE_DELEGUEE_NOM" IS 'Nom de la commune déléguée d''implantation de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."VOIE_NOM" IS 'Nom de la voie';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."LIEUDIT_COMPLEMENT_NOM" IS  'nom du lieu-dit historique ou complémentaire';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."NUMERO" IS 'Numéro de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."SUFFIXE" IS 'Suffixe de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."POSITION" IS 'Position de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."X" IS 'Coordonnée X';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."Y" IS 'Coordonnée Y';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."LONG" IS 'Longitude';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."LAT" IS 'Latitude';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."SOURCE" IS 'Source de l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."CAD_PARCELLES" IS 'Liste des parcelles représentées par l''adresse';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."DATE_DER_MAJ" IS 'Date de la dernière mise à jour';
COMMENT ON COLUMN "G_BASE_VOIE"."V_BAN_VERSION_1_3"."CERTIFICATION_COMMUNE" IS 'Certification communale: 0, adresse non certifiée par la commune, 1, adresse certifiée par la commune';

-- 3. Metadonnee spatiale
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_BAN_VERSION_1_3',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 680041.099999997, 730745.000000005, 0.001),SDO_DIM_ELEMENT('Y', 7030203.99999884, 7082570.8999989, 0.001)),
    2154
);
COMMIT;