
  CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE" ("OBJECTID", "ID_VOIE_ADMINISTRATIVE", "CODE_INSEE", "TYPE_POINT", "DISTANCE", "NEW_TYPE_POINT", "GEOM", 
	 CONSTRAINT "V_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
  WITH
        C_1 AS(
            SELECT
                a.id_voie_administrative,
                a.code_insee,
                'startpoint' AS type_point,
                SDO_CS.MAKE_2D(SDO_LRS.GEOM_SEGMENT_START_PT(SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom, b.diminfo))) AS geom
            FROM
                G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE a,
                USER_SDO_GEOM_METADATA b
            WHERE
                b.table_name = 'VM_TEMP_C_VOIE_ADMINISTRATIVE'
            UNION ALL
            SELECT
                a.id_voie_administrative,
                a.code_insee,
                'endpoint' AS type_point,
                SDO_CS.MAKE_2D(SDO_LRS.GEOM_SEGMENT_END_PT(SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom, b.diminfo))) AS geom
            FROM
                G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE a,
                USER_SDO_GEOM_METADATA b
            WHERE
                b.table_name = 'VM_TEMP_C_VOIE_ADMINISTRATIVE'
        ),
    
        C_2 AS(
            SELECT
                rownum AS objectid,
                a.id_voie_administrative,
                a.code_insee,
                a.type_point,
                SDO_GEOM.SDO_DISTANCE(a.geom, b.geom, 0.005) AS distance,
                a.geom
            FROM
                C_1 a,
                G_BASE_VOIE.TEMP_C_CENTROIDE_MAIRIE_LILLE b
        ),
        
        C_3 AS(
            SELECT
                id_voie_administrative,
                MIN(distance) AS distance,
                'startpoint' AS new_type_point
            FROM
                C_2
            GROUP BY
                id_voie_administrative,
                'startpoint'
            UNION ALL
            SELECT
                id_voie_administrative,
                MAX(distance) AS distance,
                'endpoint' AS new_type_point
            FROM
                C_2
            GROUP BY
                id_voie_administrative,
                'endpoint'
            )
            
            SELECT
                a.objectid,
                a.id_voie_administrative,
                a.code_insee,
                a.type_point,
                a.distance,
                b.new_type_point,
                a.geom
            FROM
                C_2 a
                INNER JOIN C_3 b ON b.id_voie_administrative = a.id_voie_administrative AND b.distance = a.distance;

   COMMENT ON COLUMN "G_BASE_VOIE"."V_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE"."OBJECTID" IS 'Clé primaire de la vue.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE"."ID_VOIE_ADMINISTRATIVE" IS 'Identifiant de la voie administrative présente dans VM_TEMP_C_VOIE_ADMINISTRATIVE.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE"."CODE_INSEE" IS 'Code insee de la voie administrative.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE"."TYPE_POINT" IS 'Type de point distinguant s''il s''agit du startpoint ou du endpoint de la voie administrative.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE"."DISTANCE" IS 'Distance entre le point de la voie et le point de référence (correspondant au centroïde de la mairie de Lille) de la table G_BASE_VOIE.TEMP_C_CENTROIDE_MAIRIE_LILLE.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE"."NEW_TYPE_POINT" IS 'Nouveau type de point. Si le endpoint de la voie administrative présente dans VM_TEMP_C_VOIE_ADMINISTRATIVE est plus près du pont de référence que le startpoint, alors il prendra la valeur startpoint dans ce champ. Et son ancien startpoint deviendra son endpoint.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE"."GEOM" IS 'Géométrie de type point correspondant à la géométrie des start/endpoints des voies administratives.';
   COMMENT ON TABLE "G_BASE_VOIE"."V_REPROJECTION_START_END_POINTS_VOIE_ADMINISTRATIVE"  IS 'Vue test que l''on va surement supprimer - inversant les start/end points des voies administratives, quand nécessaire et quand le endpoint est plus près du point de référence (mairie de Lille) que le startpoint de la voie. Cela nous permet après d''identifier la latéralité des voies administratives.';

/

