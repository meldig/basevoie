
  CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_TRONCON_LITTERALIS" ("IDENTIFIANT", "CODE_TRONC", "CLASSEMENT", "CODE_RUE_G", "NOM_RUE_G", "INSEE_G", "CODE_RUE_D", "NOM_RUE_D", "INSEE_D", "LARGEUR", "GEOMETRY", 
	 CONSTRAINT "V_TRONCON_LITTERALIS_PK" PRIMARY KEY ("CODE_TRONC") DISABLE) AS 
  WITH C_1 AS(
                    SELECT DISTINCT
                        CAST(a.objectid AS VARCHAR2(50)) AS CODE_TRONC,
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
                        CAST(c.objectid AS VARCHAR2(50)) AS CODE_RUE_G,
                        UPPER(d.libelle) || ' ' || UPPER(c.libelle_voie) AS NOM_RUE_G,
                        CAST(c.objectid AS VARCHAR2(50)) AS CODE_RUE_D,
                        UPPER(d.libelle) || ' ' || UPPER(c.libelle_voie) AS NOM_RUE_D
                    FROM
                        G_BASE_VOIE.TA_TRONCON a
                        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
                        INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = b.fid_voie
                        INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE d ON d.objectid = c.fid_typevoie
                        INNER JOIN SIREO_LEC.OUT_DOMANIALITE e ON e.cnumtrc = a.objectid
                )
                SELECT
                    CAST(ROWNUM AS NUMBER(38,0)) AS IDENTIFIANT,
                    C_1.CODE_TRONC,
                    C_1.CLASSEMENT,
                    C_1.CODE_RUE_G,
                    C_1.NOM_RUE_G,
                    f.CODE_INSEE AS INSEE_G,
                    C_1.CODE_RUE_D,
                    C_1.NOM_RUE_D,
                    f.CODE_INSEE AS INSEE_D,
                    CAST('NULL' AS NUMBER(8,0)) AS LARGEUR,
                    b.geom AS GEOMETRY
                FROM
                    C_1
                    INNER JOIN G_BASE_VOIE.TA_TRONCON b ON b.objectid = C_1.code_tronc,
                    G_REFERENTIEL.MEL_COMMUNE f,
                    USER_SDO_GEOM_METADATA m
                WHERE
                -- Pour rechercher l'INSEE du troncon nous analysons sur quelle commune se situe le point median du troncon.
                SDO_CONTAINS(
                            f.geom,
                             SDO_LRS.CONVERT_TO_STD_GEOM(
                                                        SDO_LRS.LOCATE_PT(
                                                                        SDO_LRS.CONVERT_TO_LRS_GEOM(b.GEOM,m.diminfo),
                                                                        SDO_GEOM.SDO_LENGTH(b.GEOM,m.diminfo)/2
                                                                        )
                                                         )
                            )='TRUE'
                AND
                    m.table_name = 'TA_TRONCON';

   COMMENT ON COLUMN "G_BASE_VOIE"."V_TRONCON_LITTERALIS"."IDENTIFIANT" IS 'Cle primaire de la vue';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_TRONCON_LITTERALIS"."CODE_TRONC" IS 'Identificateur unique et immuable du tronçon de voie partagé entre Littéralis Expert et le SIG.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_TRONCON_LITTERALIS"."CLASSEMENT" IS 'Classement de la voie.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_TRONCON_LITTERALIS"."CODE_RUE_G" IS 'Code unique de la rue côté gauche du tronçon partagé entre Littéralis Expert et le SIG.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_TRONCON_LITTERALIS"."NOM_RUE_G" IS 'Nom de la voie côté gauche du tronçon.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_TRONCON_LITTERALIS"."INSEE_G" IS 'Code INSEE de la commune côté gauche du tronçon..';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_TRONCON_LITTERALIS"."CODE_RUE_D" IS 'Code unique de la rue côté droit du tronçon partagé entre Littéralis Expert et le SIG.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_TRONCON_LITTERALIS"."NOM_RUE_D" IS 'Nom de la voie côté droit du tronçon.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_TRONCON_LITTERALIS"."INSEE_D" IS 'Code INSEE de la commune côté droit du tronçon.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_TRONCON_LITTERALIS"."LARGEUR" IS 'Valeur indiquant une largeur de la voie.';
   COMMENT ON TABLE "G_BASE_VOIE"."V_TRONCON_LITTERALIS"  IS 'Vue regroupant la liste des tronçons constituant une voie, dont les catégorisations répondent aux exigences du prestataire Sogelink afin de remplir la base de données Litteralis.';
