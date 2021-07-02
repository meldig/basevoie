CREATE OR REPLACE FORCE VIEW V_REGROUPEMENT(
    CODE_RGR,
    TYPE,
    NOM,
    CODE_INSEE,
    GEOMETRY,
    CONSTRAINT " V_REGROUPEMENT _PK" PRIMARY KEY ("CODE_RGR") DISABLE
)AS
WITH
    C_1 AS(
        SELECT
           'Commune' AS TYPE,
            a.nom AS NOM,
            a.code_adm AS CODE_RGR,
            a.geom AS GEOMETRY
        FROM
            G_REFERENTIEL.MEL_COMMUNE a
        UNION ALL
        SELECT
            'Unité Territoriale' AS TYPE,
            a.nom AS NOM,
            a.code_adm AS CODE_RGR,
            a.geom AS GEOMETRY
        FROM
            G_REFERENTIEL.MEL_UT a
        UNION ALL
        SELECT
            'Territoire' AS TYPE,
            a.nom AS NOM,
            a.code_adm AS CODE_RGR,
            a.geom AS GEOMETRY
        FROM
            G_REFERENTIEL.MEL_PLANIF a
    )
    
    SELECT
        a.CODE_RGR,
        a.TYPE,
        a.NOM,
        b.CODE_INSEE,
        a.GEOMETRY
    FROM
        C_1 a
        LEFT JOIN G_REFERENTIEL.MEL_COMMUNE b ON b.code_adm = a.code_rgr;
        
-- 2. Création des commentaires de la vue
COMMENT ON TABLE G_BASE_VOIE.V_REGROUPEMENT IS 'Vue des regroupements administratifs territoriaux.';
COMMENT ON COLUMN G_BASE_VOIE.V_REGROUPEMENT.CODE_RGR IS 'Identificateur unique et immuable du regroupement partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.V_REGROUPEMENT.TYPE IS 'Type de regroupement.';
COMMENT ON COLUMN G_BASE_VOIE.V_REGROUPEMENT.NOM IS 'Nom du regroupement.';
COMMENT ON COLUMN G_BASE_VOIE.V_REGROUPEMENT.CODE_INSEE IS 'Code INSEE de la commune.';
COMMENT ON COLUMN G_BASE_VOIE.V_REGROUPEMENT.GEOMETRY IS 'Géométries de type surfacique.';
