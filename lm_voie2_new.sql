DROP MATERIALIZED VIEW GEO.LM_VOIE2;
CREATE MATERIALIZED VIEW GEO.LM_VOIE2 (OBJECTID,TRONCON,INSEE,CODE_INSEE,COMMUNE,ID_VOIE,RIVOLI,NOM_RUE,CODE_TRAF,TRAFIC,CODE_DOME,DOMANIALITE,CODE_SENS,SENS, CODE_INFO, INFO_RESEAU, CODE_USAG, USAG, CODE_AGPL, AGR_PL, CODE_EXCP, CONVOI_EXCP, CODE_2ROU, DEUX_ROUES, CODE_TONA, TONNAGE, CODE_CBUS, COULOIR_BUS, GEOM)   
       
TABLESPACE DATA_GEO
PCTUSED    0
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
USING INDEX
            TABLESPACE DATA_GEO
            PCTFREE    10
            INITRANS   2
            MAXTRANS   255
            STORAGE    (
                        INITIAL          64K
                        NEXT             1M
                        MINEXTENTS       1
                        MAXEXTENTS       UNLIMITED
                        PCTINCREASE      0
                        BUFFER_POOL      DEFAULT
                        FLASH_CACHE      DEFAULT
                        CELL_FLASH_CACHE DEFAULT
                       )
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
 USING TRUSTED CONSTRAINTS
AS 
/* Formatted on 05/05/2015 13:42:37 (QP5 v5.185.11230.41888) */
SELECT CAST (geo.cnumtrc + voi.cnumcom * 100000 AS NUMBER (38)) as Objectid,
       cvt.cnumtrc as troncon,
       voi.cnumcom as insee,
       voi.cnumcom+59000 as code_insee, 
       com.cnomcom as commune,
       voi.ccomvoi as id_voie,
       voi.ccodrvo as rivoli,
       lityvoie || ' ' || voi.cnomvoi as nom_rue,
       ges.codtraf as code_traf,
       traf.libelle as trafic,
       ges.coddoma as code_dome,
       doma.libelle as domanialite,
       ges.codsens as code_sens,
       sens.libelle as sens,
       ges.codinfo as code_info,
       info.libelle as info_reseau,
       ges.codusag as code_usag,
       usag.libelle as usag,
       ges.codagpl as code_agpl,
       agpl.libelle as agr_pl,
       ges.codexcp as code_excp,
       excp.libelle as convoi_excp,
       ges.cod2rou as code_2rou,
       drou.libelle as deux_roues,
       ges.codtona as cod_tona,
       tona.libelle as tonnage,
       ges.codcbus as cod_cbus,
       cbus.libelle as couloir_bus,       
       geo.geom
  FROM g_sidu.voievoi voi,
       g_sidu.voiecvt cvt,
       sidu.iltacom com,
       g_sidu.typevoie typ,
       g_sidu.iltatrc geo,
       ges_caratron ges,
       typovoie.cod_trafic traf,
       typovoie.cod_domanialite doma,
       Typovoie.Cod_Sens_Uniques Sens,
       typovoie.COD_AGRESSIVITE_POIDS_LOURDS agpl,
       typovoie.COD_CONVOIS_EXCEPTIONNELS excp,
       typovoie.COD_RESEAU_ROUTIER info,
       typovoie.COD_USAGES usag,
       typovoie.COD_DEUX_ROUES drou,
       typovoie.cod_limites_tonnage tona,
       TYPOVOIE.COD_couloirs_bus cbus
 WHERE     geo.cdvaltro = 'V'
       AND cvt.cvalide = 'V'
       AND voi.cdvalvoi = 'V'
       AND Voi.Ccomvoi = Cvt.Ccomvoi
       AND voi.ccodtvo = typ.ccodtvo
       AND Voi.Cnumcom = Com.Cnumcom
       AND Cvt.Cnumtrc = Geo.cnumtrc
       AND Cvt.Cnumtrc = Ges.Cnumtrc(+)
       AND Ges.Codtraf = Traf.Codtraf(+)
       AND Ges.Coddoma = Doma.Coddoma(+)
       AND ges.codsens = sens.codsens(+)
       AND ges.codagpl = agpl.codagpl(+)
       AND ges.codexcp = excp.codexcp(+)
       AND ges.codinfo = info.codinfo(+)
       AND ges.codusag = usag.codusag(+)
       AND ges.cod2ROU = drou.cod2rou(+)
       AND ges.codtona = tona.codtona(+)
       AND ges.codcbus = cbus.codCBUS(+);
       
COMMENT ON MATERIALIZED VIEW GEO.LM_VOIE2 IS 'snapshot table for snapshot GEO.LM_VOIE2';

CREATE UNIQUE INDEX GEO.LM_VOIE2_PK ON GEO.LM_VOIE2
(OBJECTID)
LOGGING
TABLESPACE DATA_GEO
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL;

CREATE INDEX GEO.LM_VOIE2_SIDX ON GEO.LM_VOIE2
(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(' LAYER_GTYPE = MULTILINE WORK_TABLESPACE=DATA_TEMP TABLESPACE=ISPA_GEO')
NOPARALLEL;

GRANT INSERT, SELECT, UPDATE ON GEO.LM_VOIE2 TO DYN_ADT WITH GRANT OPTION;

GRANT INSERT, SELECT, UPDATE ON GEO.LM_VOIE2 TO DYN_ECO WITH GRANT OPTION;

GRANT INSERT, SELECT, UPDATE ON GEO.LM_VOIE2 TO DYN_GEO WITH GRANT OPTION;

GRANT INSERT, SELECT, UPDATE ON GEO.LM_VOIE2 TO DYN_HAB WITH GRANT OPTION;

GRANT INSERT, SELECT, UPDATE ON GEO.LM_VOIE2 TO DYNMAP WITH GRANT OPTION;

GRANT INSERT, SELECT, UPDATE ON GEO.LM_VOIE2 TO DYN_SIT WITH GRANT OPTION;

GRANT SELECT ON GEO.LM_VOIE2 TO PUBLIC WITH GRANT OPTION;

