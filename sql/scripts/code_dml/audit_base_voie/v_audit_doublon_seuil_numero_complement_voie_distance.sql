-- V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE: Seuils en doublon de numéro, complément, voie et de distance seuil/voie

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE (identifiant,nombre,numero_seuil,complement_seuil,code_voie,distance,
CONSTRAINT "V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS
WITH CTE_1 AS
    (
    SELECT
        COUNT(a.IDSEUI) AS NOMBRE,
        a.nuseui AS numero_seuil,
        CASE
            WHEN a.nsseui IS NOT NULL
            THEN a.nsseui
        ELSE
            'pas de complément'
        END AS complement_seuil,
        e.ccomvoi AS id_voie,
        ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                                SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
                                    SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo),
                                    SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo), a.ora_geometry),
                                    0
                                ),
                                a.ora_geometry
                                ), 2)AS distance
    FROM
        G_BASE_VOIE.TEMP_ILTASEU a
        INNER JOIN G_BASE_VOIE.TEMP_ILTASIT b ON b.idseui = a.idseui
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc
        INNER JOIN G_BASE_VOIE.TEMP_VOIECVT d ON d.cnumtrc = c.cnumtrc
        INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI e ON e.ccomvoi = d.ccomvoi,
        USER_SDO_GEOM_METADATA m
    WHERE
        c.cdvaltro = 'V'
        AND d.cvalide = 'V'
        AND e.cdvalvoi = 'V'
        AND a.idseui NOT IN(393545, 393540)
        AND m.table_name = 'TEMP_ILTATRC'
    GROUP BY
        a.nuseui,
            CASE
                WHEN a.nsseui IS NOT NULL
                THEN a.nsseui
            ELSE
                'pas de complément'
            END,
            e.ccomvoi,
        ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                                SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
                                    SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo),
                                    SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo), a.ora_geometry),
                                    0
                                ),
                                a.ora_geometry
                                ), 2)
    HAVING
        COUNT(a.nuseui) > 1
        AND COUNT(CASE
            WHEN a.nsseui IS NOT NULL
            THEN a.nsseui
        ELSE
            'pas de complément'
        END) > 1
        AND COUNT(e.ccomvoi) > 1
        AND COUNT(ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                            SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
                                SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo),
                                SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo), a.ora_geometry),
                                0
                            ),
                            a.ora_geometry
                            ), 2)) > 1
    )
    SELECT
        rownum,
        nombre,
        numero_seuil,
        complement_seuil,
        id_voie,
        distance
    FROM
        CTE_1
;

-- 2. Commentaire de la vue.
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE  IS 'Vue permettant d''identifier les adresses en doublons meme avec la distance entre le seuil et le troncon.';


-- 3. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE.NOMBRE IS 'Nombre de doublons.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE.NUMERO_SEUIL IS 'Numéro du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE.COMPLEMENT_SEUIL IS 'Complément du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE.CODE_VOIE IS 'Identifiant de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE.DISTANCE IS 'Distance entre la voie et le seuil.';