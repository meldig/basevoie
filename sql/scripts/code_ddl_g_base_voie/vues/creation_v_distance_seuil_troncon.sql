/*
Vue permettant de connaître la distance entre le point de chaque seuil et le tronçon qui lui est affecté.
*/
CREATE OR REPLACE FORCE EDITIONABLE VIEW "G_BASE_VOIE"."V_DISTANCE_SEUIL_TRONCON" ("ID_INFOS_SEUIL", "ID_TRONCON", "CODE_INSEE", "DISTANCE", "GEOM", 
	 CONSTRAINT "V_DISTANCE_SEUIL_TRONCON_PK" PRIMARY KEY ("ID_INFOS_SEUIL") DISABLE) AS 
  SELECT
            b.objectid AS id_infos_seuil,
            d.objectid AS id_troncon,
            GET_CODE_INSEE_CONTAIN_POINT('TA_SEUIL', a.geom) AS code_insee,
            ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
                    SDO_LRS.CONVERT_TO_LRS_GEOM(d.geom, m.diminfo),
                    SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(d.geom, m.diminfo), a.geom),
                    0
                ),
                a.geom
            ), 2) AS distance,
            a.geom
        FROM
            G_BASE_VOIE.TA_SEUIL a
            INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL b ON b.fid_seuil = a.objectid
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = a.objectid
            INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = c.fid_troncon,
            USER_SDO_GEOM_METADATA m
        WHERE
            m.table_name = 'TA_TRONCON';

   COMMENT ON COLUMN "G_BASE_VOIE"."V_DISTANCE_SEUIL_TRONCON"."ID_INFOS_SEUIL" IS 'Identifiants des seuils utilisés en tant que clé primaire (objectid de TA_INFOS_SEUIL).';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_DISTANCE_SEUIL_TRONCON"."ID_TRONCON" IS 'Identifiant du tronçon affecté au seuil dans la table pivot (TA_RELATION_TRONCON_SEUIL).';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_DISTANCE_SEUIL_TRONCON"."CODE_INSEE" IS 'Code INSEE de la commune dans laquelle se situe le seuil.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_DISTANCE_SEUIL_TRONCON"."DISTANCE" IS 'Distance minimale entre un seuil et le tronçon qui lui est affecté.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_DISTANCE_SEUIL_TRONCON"."GEOM" IS 'Champ géométrique de type point contenant la géométrie des seuils.';
   COMMENT ON TABLE "G_BASE_VOIE"."V_DISTANCE_SEUIL_TRONCON"  IS 'Vue permettant de connaître la distance entre chaque seuil et le tronçon qui lui est affecté dans la table pivot, ainsi que sa commune de localisation.';
