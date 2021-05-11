/*
Vue matérialisée qui présente les voies présente dans le périmètre de la MEL.
*/

-- 1. Creation de la vue matérialisée
CREATE MATERIALIZED VIEW "GEO"."LM_VOIE" (
                                          "OBJECTID",
                                          "TRONCON",
                                          "INSEE",
                                          "CODE_INSEE",
                                          "COMMUNE",
                                          "ID_VOIE",
                                          "RIVOLI",
                                          "NOM_RUE",
                                          "CODE_TRAF",
                                          "TRAFIC",
                                          "CODE_DOME",
                                          "DOMANIALITE",
                                          "CODE_SENS",
                                          "SENS",
                                          "CODE_INFO",
                                          "INFO_RESEAU",
                                          "CODE_USAG",
                                          "USAG",
                                          "CODE_AGPL",
                                          "AGR_PL",
                                          "CODE_EXCP",
                                          "CONVOI_EXCP",
                                          "CODE_2ROU",
                                          "DEUX_ROUES",
                                          "CODE_TONA",
                                          "TONNAGE",
                                          "CODE_CBUS",
                                          "COULOIR_BUS",
                                          "CODE_DGLN",
                                          "BAR_DEGEL_N",
                                          "CODE_DGLR",
                                          "BAR_DEGEL_R",
                                          "GEOM")
CONSTRAINT "PK_LM_VOIE" PRIMARY KEY ("OBJECTID") DISABLE) AS 


AS SELECT 
        a.objectid + c.objectid * 10000 AS OBJECTID,
        a.objectid AS TRONCON,
        SUBSTR(e.code_insee, 1, 3) AS INSEE,
        e.code_insee AS CODE_INSEE,
        h.nom AS COMMUNE,
        c.objectid AS ID_VOIE,
        f.code_fantoir AS RIVOLI,
        g.libelle || ' ' || e.nom AS NOM_RUE,
        ges.codtraf as CODE_TRAF,
        traf.libelle as TRAFIC,
        ges.coddoma as CODE_DOME,
        doma.libelle as DOMANIALITE,
        ges.codsens as CODE_SENS,
        sens.libelle as SENS,
        ges.codinfo as CODE_INFO,
        info.libelle as INFO_RESEAU,
        ges.codusag as CODE_USAG,
        usag.libelle as USAG,
        ges.codagpl as CODE_AGPL,
        agpl.libelle as AGR_PL,
        ges.codexcp as CODE_EXCP,
        excp.libelle as CONVOI_EXCP,
        ges.cod2rou as CODE_2ROU,
        drou.libelle as DEUX_ROUES,
        ges.codtona as COD_TONA,
        tona.libelle as TONNAGE,
        ges.codcbus as COD_CBUS,
        cbus.libelle as COULOIR_BUS,
        ges.CODDGLN  AS CODE_DGLN,
        dgln.LIBELLE AS BAR_DEGEL_N,
        ges.CODDGLR  AS CODE_DGLR,
        dglr.LIBELLE AS BAR_DEGEL_R,                 
        a.geom
FROM
        g_base_voie.ta_troncon a
        INNER JOIN g_base_voie.ta_relation_troncon_voie b ON b.fid_troncon = a.objectid
        INNER JOIN g_base_voie.ta_voie c ON c.objectid = b.fid_voie
        INNER JOIN g_base_voie.ta_relation_rue_voie d ON d.fid_voie = c.objectid
        INNER JOIN g_base_voie.ta_rue e ON e.objectid = d.fid_rue
        INNER JOIN g_base_voie.ta_fantoir f ON f.objectid = e.fid_fantoir
        INNER JOIN g_base_voie.ta_type_voie g ON g.objectid = e.fid_typevoie
        INNER JOIN g_referentiel_lec.a_commune h ON h.code_insee = e.code_insee
        INNER JOIN typevoie.V_GES_CARATRON i ON i.cnumtrc(+) = a.objectid
        INNER JOIN typevoie.cod_trafic j ON j.Codtraf(+) = i.Codtraf
        INNER JOIN typovoie.cod_domanialite k ON k.Coddoma(+) = i.Coddoma,
        INNER JOIN Typovoie.Cod_Sens_Uniques l ON l.codsens(+) = i.codsens,
        INNER JOIN typovoie.COD_AGRESSIVITE_POIDS_LOURDS m ON m.codagpl(+) = i.codagpl,
        INNER JOIN typovoie.COD_CONVOIS_EXCEPTIONNELS n ON n.codexcp(+) = i.codexcp,
        INNER JOIN typovoie.COD_RESEAU_ROUTIER o ON o.codinfo(+) = i.codinfo,
        INNER JOIN typovoie.COD_USAGES p ON p.codusag(+) = es.codusag,
        INNER JOIN typovoie.COD_DEUX_ROUES q ON q.cod2rou(+) = i.cod2ROU,
        INNER JOIN typovoie.cod_limites_tonnage r ON r.codtona(+) = i.codtona,
        INNER JOIN TYPOVOIE.COD_couloirs_bus s ON s.codCBUS(+) = i.codcbus,
        INNER JOIN TYPOVOIE.COD_BARRIERES_DEGEL_NORMAL t ON t.CODDGLN(+) = i.CODDGLN,
        INNER JOIN TYPOVOIE.COD_BARRIERES_DEGEL_RIGOUREUX u ON u.CODDGLR(+) = i.CODDGLR;

-- 2. Creation de la clé primaire.
ALTER MATERIALIZED VIEW G_BASE_VOIE.LM_VOIE 
ADD CONSTRAINT LM_VOIE _PK 
PRIMARY KEY (OBJECTID);

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'LM_VOIE',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 
    2154
);

-- 4. Creation de l'index sur la clé primaire

CREATE UNIQUE INDEX LM_VOIE_INDX ON LM_VOIE("OBJECTID") TABLESPACE "DATA_GEO";

-- 5. Creation de l'index spatiale

CREATE INDEX LM_VOIE_SIDX
ON G_BASE_VOIE.LM_VOIE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=POLYGON, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 6. Commentaire de la vue materialisee et des colonnes.

COMMENT ON MATERIALIZED VIEW "GEO"."LM_VOIE"  IS 'snapshot table for snapshot GEO.LM_VOIE';

COMMENT ON COLUMN "GEO"."LM_VOIE".OBJECTID IS 'Cle primaire de la vue materialisee.';
COMMENT ON COLUMN "GEO"."LM_VOIE"."TRONCON" IS "Identifiant du troncon.";
COMMENT ON COLUMN "GEO"."LM_VOIE"."INSEE" IS "code commune de la commune d'implantation du troncon.";
COMMENT ON COLUMN "GEO"."LM_VOIE"."CODE_INSEE" IS "code INSEE de la commune d'implantation du troncon.";
COMMENT ON COLUMN "GEO"."LM_VOIE"."COMMUNE" IS "Nom de la commune d'implantation du troncon.";
COMMENT ON COLUMN "GEO"."LM_VOIE"."ID_VOIE" IS "Identifiant de la voie composé des troncons.";
COMMENT ON COLUMN "GEO"."LM_VOIE"."RIVOLI" IS "Code FANTOIR de la voie.";
COMMENT ON COLUMN "GEO"."LM_VOIE"."NOM_RUE" IS "Nom de la rue composée des voies.";
COMMENT ON COLUMN "GEO"."LM_VOIE"."CODE_TRAF" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."TRAFIC" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."CODE_DOME" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."DOMANIALITE" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."CODE_SENS" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."SENS" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."CODE_INFO" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."INFO_RESEAU" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."CODE_USAG" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."USAG" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."CODE_AGPL" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."AGR_PL" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."CODE_EXCP" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."CONVOI_EXCP" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."CODE_2ROU" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."DEUX_ROUES" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."CODE_TONA" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."TONNAGE" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."CODE_CBUS" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."COULOIR_BUS" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."CODE_DGLN" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."BAR_DEGEL_N" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."CODE_DGLR" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."BAR_DEGEL_R" IS "";
COMMENT ON COLUMN "GEO"."LM_VOIE"."GEOM" IS "Geometrie de chaque troncon.";