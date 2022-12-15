/*
Projet G - Correction de la latéralité des voies administratives - étape 2
1. faire en sorte que les couples voie physique / voie administrative aient la même latéralité 
quand les voies physiques sont jointives et pour les voies administratives composées de 3 voies physiques maximum.
*/

MERGE INTO G_BASE_VOIE.TEMP_G_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
    USING(
        WITH
            C_1 AS(-- Aggrégation de toutes les voies physiques en une seule géométrie (de type 2006)
                SELECT
                    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS geom
                FROM
                    G_BASE_VOIE.TEMP_G_VOIE_LATERALITE a
            ),
            
            C_2 AS(-- Extraction de tous les sous-éléments de la géométie de l'étape 1
                SELECT 
                   rownum AS id_voies_jointives,
                   b.object_value AS geom
                FROM
                    C_1 a,
                    TABLE(sdo_util.extract_all(a.geom)) b
            ),
            
            C_3 AS(-- Sélection des voies physiques, des voies administratives et des latéralités par voies jointives fusionnées
                SELECT
                    a.id_voies_jointives,
                    b.id_voie_physique,
                    b.id_voie_administrative,
                    c.libelle_court AS lateralite
                FROM
                    C_2 a,
                    G_BASE_VOIE.TEMP_G_VOIE_LATERALITE b
                    INNER JOIN G_BASE_VOIE.TEMP_G_LIBELLE c ON c.objectid = b.fid_lateralite
                WHERE
                    SDO_ANYINTERACT(a.geom, b.geom) = 'TRUE'
                    --AND b.id_voie_administrative = 3781240
            ),
            
            C_4 AS(-- Décompte du nombre de latéralités différentes par voie jointive et voie administrative
                SELECT
                    id_voies_jointives,
                    id_voie_administrative,
                    lateralite,
                    COUNT(lateralite) AS nbr_lateralite
                FROM
                    C_3
                GROUP BY
                    id_voies_jointives,
                    id_voie_administrative,
                    lateralite
            ),

            C_5 AS(-- Sélection du nbr_lateralite maximum  pour chaque voie administrative par voie jointive
                SELECT
                    id_voies_jointives,
                    id_voie_administrative,
                    MAX(nbr_lateralite) AS lateralite_maj
                FROM
                    C_4
                GROUP BY
                    id_voies_jointives,
                    id_voie_administrative
            ),
            
            C_6 AS(-- Sélection de la latéralité majoritaire par voie administrative et voie jointive en faisant attentation à ce que cette majorité soit supérieure à 2 afin de sélectionner les voies administratives composées de plus de 2 voies physiques
                SELECT
                    a.id_voies_jointives,
                    a.id_voie_administrative,
                    a.lateralite
                FROM
                    C_4 a
                    INNER JOIN C_5 b ON b.id_voies_jointives = a.id_voies_jointives AND b.id_voie_administrative = a.id_voie_administrative AND b.lateralite_maj = a.nbr_lateralite
                WHERE
                    b.lateralite_maj > 2
            )
            
            SELECT -- On affecte à tous les couples voie physique / voie administrative la latéralité majoritaire de la voie administrative dont les voies physiques sont jointives
                a.id_voies_jointives,
                b.id_voie_physique,
                a.id_voie_administrative,
                a.lateralite,
                c.objectid AS fid_lateralite
            FROM
                C_6 a
                INNER JOIN C_3 b ON b.id_voies_jointives = a.id_voies_jointives AND b.id_voie_administrative = a.id_voie_administrative
                INNER JOIN G_BASE_VOIE.TEMP_G_LIBELLE c ON c.libelle_court = a.lateralite
            ORDER BY
                a.id_voies_jointives,
                a.id_voie_administrative
    )t
ON(a.fid_foie_physique = t.id_voie_physique AND a.fid_voie_administrative = t.id_voie_administrative)
WHEN MATCHED THEN
    UPDATE SET a.fid_lateralite = t.fid_lateralite;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
Projet G - Correction de la latéralité des voies administratives - étape 2
2. affecter une latéralité aux couples voie physique / voie administrative au sein desquels une voie admin est composée d'une et d'une seule voie physique n'étant pas jointive à d'autres voies physiques.
*/

MERGE INTO G_BASE_VOIE.TEMP_G_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
    USING(
        WITH
                C_1 AS(-- Aggrégation de toutes les voies physiques en une seule géométrie (de type 2006)
                    SELECT
                        SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS geom
                    FROM
                        G_BASE_VOIE.TEMP_G_VOIE_LATERALITE a
                ),
                
                C_2 AS(-- Extraction de tous les sous-éléments de la géométie de l'étape 1
                    SELECT 
                       rownum AS id_voies_jointives,
                       b.object_value AS geom
                    FROM
                        C_1 a,
                        TABLE(sdo_util.extract_all(a.geom)) b
                ),
                
                C_3 AS(-- Sélection des voies physiques, des voies administratives et des latéralités par voies jointives fusionnées
                    SELECT
                        a.id_voies_jointives,
                        b.id_voie_physique,
                        b.id_voie_administrative,
                        c.libelle_court AS lateralite,
                        b.fid_lateralite
                    FROM
                        C_2 a,
                        G_BASE_VOIE.TEMP_G_VOIE_LATERALITE b
                        INNER JOIN G_BASE_VOIE.TEMP_G_LIBELLE c ON c.objectid = b.fid_lateralite
                    WHERE
                        SDO_ANYINTERACT(a.geom, b.geom) = 'TRUE'
                ),
                
                C_4 AS(
                    SELECT
                        --id_voie_administrative
                        id_voie_physique
                    FROM
                        C_3
                    GROUP BY
                        --id_voie_administrative
                        id_voie_physique
                    HAVING
                        --COUNT(id_voie_administrative) = 1
                        COUNT(id_voie_physique) = 1
                )
                
                SELECT
                    a.id_voie_physique,
                    a.id_voie_administrative,
                    a.fid_lateralite
                FROM
                    C_3 a
                    --INNER JOIN C_4 b ON b.id_voie_administrative = a.id_voie_administrative
                    INNER JOIN C_4 b ON b.id_voie_physique = a.id_voie_physique
    )t
ON(a.fid_foie_physique = t.id_voie_physique AND a.fid_voie_administrative = t.id_voie_administrative)
WHEN MATCHED THEN
    UPDATE SET a.fid_lateralite = t.fid_lateralite;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
Projet G - Correction de la latéralité des voies administratives - étape 2
3. 
*/