CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_REGROUPEMENT_LITTERALIS(
    TYPE,
    NOM,
    CODE_RGR,
    CODE_INSEE,
    GEOMETRY,
    CONSTRAINT "V_REGROUPEMENT_PK" PRIMARY KEY("CODE_RGR") DISABLE
)
AS(
    SELECT
       'Commune' AS TYPE,
        a.nom AS NOM,
        a.code_adm AS CODE_RGR,
        a.code_insee AS code_insee,
        a.geom AS GEOMETRY
    FROM
        G_REFERENTIEL.MEL_COMMUNE a
    UNION ALL
    SELECT
        'Unité Territoriale' AS TYPE,
        a.nom AS NOM,
        a.code_adm AS CODE_RGR,
        null AS code_insee,
        a.geom AS GEOMETRY
    FROM
        G_REFERENTIEL.MEL_UT a
    UNION ALL
    SELECT
        'Territoire' AS TYPE,
        a.nom AS NOM,
        a.code_adm AS CODE_RGR,
        null AS code_insee,
        a.geom AS GEOMETRY
    FROM
        G_REFERENTIEL.MEL_PLANIF a
    UNION ALL
    SELECT
        'sous-territoire' AS TYPE,
        a.sous_territoire AS NOM,
        CAST(a.codesouster AS VARCHAR2(24)) AS CODE_RGR,
        null AS code_insee,
        CASE
            WHEN a.sous_territoire = 'TERRITOIRE 1 COURONNE SUD EST - UTLS 1'
                THEN SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005))
            WHEN a.sous_territoire = 'TERRITOIRE 1 LA LYS - UTTA 1'
                THEN SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005))
            WHEN a.sous_territoire = 'TERRITOIRE 1 ROUBAISIEN - UTRV 1'
                THEN SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005))
            WHEN a.sous_territoire = 'TERRITOIRE 1 WEPPES SUD - UTML 1'
                THEN SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005))
            WHEN a.sous_territoire = 'TERRITOIRE 2  COURONNE ROUBAISIENNE - UTRV 2'
                THEN SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005))
            WHEN a.sous_territoire = 'TERRITOIRE 2 COMINOIS - UTTA 2'
                THEN SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005))
            WHEN a.sous_territoire = 'TERRITOIRE 2 COURONNE SUD OUEST - UTLS 2'
                THEN SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005))
            WHEN a.sous_territoire = 'TERRITOIRE 2 WEPPES NORD - MARCQ EN BAROEUL - UTML 2'
                THEN SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005))
            WHEN a.sous_territoire = 'TERRITOIRE 3  EST - UTRV 3'
                THEN SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005))
            WHEN a.sous_territoire = 'TERRITOIRE 3 COURONNE NORD - UTML 3'
                THEN SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005))
            WHEN a.sous_territoire = 'TERRITOIRE 3 LILLOIS EST - UTLS 3'
                THEN SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005))
            WHEN a.sous_territoire = 'TERRITOIRE 3 TOURQUENNOIS - UTTA 3'
                THEN SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005))
            WHEN a.sous_territoire = 'TERRITOIRE 4 LILLOIS OUEST - UTLS 4'
                THEN SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005))
            WHEN a.clibut = 'UTLS'
                THEN SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005))
            WHEN a.clibut = 'UTLM'
                THEN SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005))
            WHEN a.clibut = 'UTRV'
                THEN SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005))
            WHEN a.clibut = 'UTTA'
                THEN SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.005))
        END AS geom_sous_territoire
    FROM
        G_DALC.TEMP_EPCM_COM_TERRITOIRES a
        INNER JOIN G_REFERENTIEL.MEL_COMMUNE_LLH b ON SUBSTR(b.code_insee, 3, 3) = a.cnumcom
    WHERE
        a.sous_territoire IN(
            'TERRITOIRE 1 COURONNE SUD EST - UTLS 1',
            'TERRITOIRE 1 LA LYS - UTTA 1',
            'TERRITOIRE 1 ROUBAISIEN - UTRV 1',
            'TERRITOIRE 1 WEPPES SUD - UTML 1',
            'TERRITOIRE 2  COURONNE ROUBAISIENNE - UTRV 2',
            'TERRITOIRE 2 COMINOIS - UTTA 2',
            'TERRITOIRE 2 COURONNE SUD OUEST - UTLS 2',
            'TERRITOIRE 2 WEPPES NORD - MARCQ EN BAROEUL - UTML 2',
            'TERRITOIRE 3  EST - UTRV 3',
            'TERRITOIRE 3 COURONNE NORD - UTML 3',
            'TERRITOIRE 3 LILLOIS EST - UTLS 3',
            'TERRITOIRE 3 TOURQUENNOIS - UTTA 3',
            'TERRITOIRE 4 LILLOIS OUEST - UTLS 4',
            'MULTI SOUS TERRITOIRES'
        )
    GROUP BY
        a.sous_territoire,
        a.clibut,
        CAST(a.codesouster AS VARCHAR2(24))
);
    
-- 2. Création des commentaires de la vue
COMMENT ON TABLE G_BASE_VOIE.V_REGROUPEMENT_LITTERALIS IS 'Vue des regroupements administratifs territoriaux pour LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.V_REGROUPEMENT_LITTERALIS.CODE_RGR IS 'Identificateur unique et immuable du regroupement partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.V_REGROUPEMENT_LITTERALIS.TYPE IS 'Type de regroupement.';
COMMENT ON COLUMN G_BASE_VOIE.V_REGROUPEMENT_LITTERALIS.NOM IS 'Nom du regroupement.';
COMMENT ON COLUMN G_BASE_VOIE.V_REGROUPEMENT_LITTERALIS.CODE_INSEE IS 'Code INSEE de la commune.';
COMMENT ON COLUMN G_BASE_VOIE.V_REGROUPEMENT_LITTERALIS.GEOMETRY IS 'Géométries de type surfacique.';
