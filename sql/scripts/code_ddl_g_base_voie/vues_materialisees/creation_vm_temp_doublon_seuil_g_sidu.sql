
/*
VM_TEMP_DOUBLON_SEUIL_G_SIDU : cette VM sert lors de la migration des données de la base voie des tables temporaires vers les tables de production.
Elle permet d'identifier tous les seuils en doublons de numéros et de compléments de seuil ainsi que de voie, puis de les supprimer.
*/

-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_DOUBLON_SEUIL_G_SIDU(OBJECTID, ID_SEUIL, NUMERO_SEUIL, COMPLEMENT_SEUIL, ID_VOIE, DISTANCE)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(
        SELECT
            a.nuseui AS numero_seuil,
            CASE
                WHEN a.nsseui IS NOT NULL
                THEN a.nsseui
            ELSE
                'pas de complément'
            END AS complement_seuil,
            e.ccomvoi AS id_voie
        FROM
            G_BASE_VOIE.TEMP_ILTASEU a
            INNER JOIN G_BASE_VOIE.TEMP_ILTASIT b ON b.idseui = a.idseui
            INNER JOIN G_BASE_VOIE.TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT d ON d.cnumtrc = c.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI e ON e.ccomvoi = d.ccomvoi
        WHERE
            c.cdvaltro = 'V'
            AND d.cvalide = 'V'
            AND e.cdvalvoi = 'V'
            AND a.idseui NOT IN(393545, 393540) -- Ces seuils sont affectés à plusieurs voies
        GROUP BY
            a.nuseui,
                CASE
                    WHEN a.nsseui IS NOT NULL
                    THEN a.nsseui
                ELSE
                    'pas de complément'
                END,
                e.ccomvoi
        HAVING
            COUNT(a.nuseui) > 1
            AND COUNT(CASE
                WHEN a.nsseui IS NOT NULL
                THEN a.nsseui
            ELSE
                'pas de complément'
            END) > 1
            AND COUNT(e.ccomvoi) > 1
    )
    
        SELECT DISTINCT
            ROWNUM AS objectid,
            a.idseui,
            f.*,
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
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI e ON e.ccomvoi = d.ccomvoi
            INNER JOIN C_1 f ON f.numero_seuil = a.nuseui AND f.complement_seuil = CASE WHEN a.nsseui IS NULL THEN 'pas de complément' ELSE a.nsseui END AND f.id_voie = e.ccomvoi,
            USER_SDO_GEOM_METADATA m
        WHERE
            m.table_name = 'TEMP_ILTATRC'
            AND c.cdvaltro = 'V'
            AND d.cvalide = 'V'
            AND e.cdvalvoi = 'V'
        ORDER BY
            f.numero_seuil,
            f.complement_seuil,
            f.id_voie;

-- 2. Création des commentaires de VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_DOUBLON_SEUIL_G_SIDU IS 'VM temporaire servant à supprimer les seuils en doublons. Ces seuils disposent des mêmes numéros, compléments de seuil et voie, mais d''un identifiant et parfois d''un numéro de parcelle différent. Cependant, cela causant problème pour le "projet" LITTERALIS il fut décidé de ne garder que les seuils les plus proches de leur tronçon au sein des doublons.';

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_DOUBLON_SEUIL_G_SIDU 
ADD CONSTRAINT VM_TEMP_DOUBLON_SEUIL_G_SIDU_PK 
PRIMARY KEY (OBJECTID);

-- 4. Création des index
CREATE INDEX VM_TEMP_DOUBLON_SEUIL_G_SIDU_COMPOSE_IDX ON G_BASE_VOIE.VM_TEMP_DOUBLON_SEUIL_G_SIDU(ID_VOIE, NUMERO_SEUIL, COMPLEMENT_SEUIL)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_DOUBLON_SEUIL_G_SIDU_DISTANCE_IDX ON G_BASE_VOIE.VM_TEMP_DOUBLON_SEUIL_G_SIDU(DISTANCE)
    TABLESPACE G_ADT_INDX;

/

