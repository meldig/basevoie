-- VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE: Seuils en doublon de numéro, complément, voie ainsi que de distance.

-- 0. Suppression de l'ancienne vue matérialisée
-- DROP MATERIALIZED VIEW VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE;

-- 1. Création de la vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE (IDENTIFIANT, NOMBRE, NUMERO_SEUIL, CDCOTE, COMPLEMENT, CODE_VOIE, DISTANCE)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
WITH CTE_1 AS
    (
    SELECT
        COUNT(a.objectid) AS nombre,
        b.numero_seuil AS numero_seuil,
        a.cote_troncon AS cdcote,
        CASE
            WHEN b.complement_numero_seuil IS NOT NULL
            THEN b.complement_numero_seuil
        ELSE
            'pas de complément'
        END AS complement,
        e.objectid AS code_voie,
        ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                                SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
                                    SDO_LRS.CONVERT_TO_LRS_GEOM(d.geom, m.diminfo),
                                    SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(d.geom, m.diminfo), a.geom),
                                    0
                                ),
                                a.geom
                                ), 2) AS distance
    FROM
        G_BASE_VOIE.TA_SEUIL a
        INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL b ON b.fid_seuil = a.objectid
        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = a.objectid
        INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = c.fid_troncon
        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE e ON e.fid_troncon = d.objectid
        INNER JOIN G_BASE_VOIE.TA_VOIE f ON f.objectid = e.fid_voie,
        USER_SDO_GEOM_METADATA m
    WHERE
        m.table_name = 'TA_TRONCON'
    GROUP BY
        b.numero_seuil,
        a.cote_troncon,
            CASE
                WHEN b.complement_numero_seuil IS NOT NULL
                THEN b.complement_numero_seuil
            ELSE
                'pas de complément'
            END,
            e.objectid,
            ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                                SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
                                    SDO_LRS.CONVERT_TO_LRS_GEOM(d.geom, m.diminfo),
                                    SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(d.geom, m.diminfo), a.geom),
                                    0
                                ),
                                a.geom
                                ), 2)
    HAVING
        COUNT(a.objectid) > 1
        AND COUNT(CASE
            WHEN b.complement_numero_seuil IS NOT NULL
            THEN b.complement_numero_seuil
        ELSE
            'pas de complément'
        END) > 1
        AND COUNT(e.objectid) > 1
        AND COUNT(ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                                SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
                                    SDO_LRS.CONVERT_TO_LRS_GEOM(d.geom, m.diminfo),
                                    SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(d.geom, m.diminfo), a.geom),
                                    0
                                ),
                                a.geom
                                ), 2)) > 1  
    )
    SELECT 
        rownum,
        nombre,
        numero_seuil,
        cdcote,
        complement,
        code_voie,
        distance
    FROM
        CTE_1
;

-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE
ADD CONSTRAINT VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE_PK 
PRIMARY KEY (IDENTIFIANT);

-- 3. Commentaire de la vue matérialisée.
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE  IS 'Vue permettant d''identifier les adresses en doublons de numéro, côté de la voie, complément de numéro de seuil et identifiant de voie.';

-- 4. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE.NOMBRE IS 'Nombre de doublons.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE.NUMERO_SEUIL IS 'Numéro du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE.CDCOTE IS 'Cote de la voie ou est situé le seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE.COMPLEMENT IS 'Complément du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_RESULTAT_DOUBLON_SEUIL_NUMERO_COMPLEMENT_VOIE_DISTANCE.CODE_VOIE IS 'Identifiant de la voie.';