/*
Correction des données de la table TEMP_VOIEVOI
*/

/*
Fusion des points des seuils
*/

CREATE TABLE GEO.TEST_SEUIL(
	objectid NUMBER(38,0),
	geom sdo_geometry
);

COMMENT ON TABLE GEO.TEST_SEUIL IS 'TABLE TEST A NE PAS UTILISER !!! Cette table est utilisée dans la migration des seuils de la base voie et permet de stocker les centroïdes de la fusion des seuils à 50cm les uns des autres.';
COMMENT ON COLUMN GEO.TEST_SEUIL.objectid IS 'Clé primaire de la table. Il s''agit des identifiants de la table TA_POINT_TOPO_F utilisés pour sélectionner les seuils de la base voie dans un rayon de 50cm.';
COMMENT ON COLUMN GEO.TEST_SEUIL.geom IS 'Champ géométrique de la table conteant les centroïdes des fusion de seuils.';

-- Sélection des centroïds des seuils après fusion des seuils dans un rayon de 50cm
SELECT
    a.objectid,
    SDO_GEOM.SDO_CENTROID(
        SDO_AGGR_UNION(
            SDOAGGRTYPE(b.geom, 0.50)
        ),
        0.005
    )AS v_centroid
FROM
    GEO.TA_POINT_TOPO_F a,
    G_SIDU.ILTASEU b
WHERE
    a.cla_inu = 42
    AND SDO_WITHIN_DISTANCE(b.geom, a.geom, 'DISTANCE=0.50') = 'TRUE'
GROUP BY
    a.objectid
HAVING
    COUNT(b.idseui)>1;
-- Fait en 413, 308 secondes le 16/05/2021
