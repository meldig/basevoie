/*
Code permettant de remplir les tables de travail du projet LITTERALIS.
Les tables en question sont :
- TEMP_TRONCON_CORRECT_LITTERALIS ;
- TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS ;
- TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS ;
- TEMP_TRONCON_AUTRES_LITTERALIS ;
- TEMP_ADRESSE_CORRECTE_LITTERALIS ;
- TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS ;
- TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS ;
- TEMP_ADRESSE_AUTRES_LITTERALIS ;
Ces tables permettent de mettre les associations tronçon/seuil et tronçons/voies au format LITTERALIS, par type d'erreur (tronçon affecté à plusieurs voies, tronçons avec des domanialités différentes, etc), mais aussi pour les associations tronçon/seuil et tronçons/voies correctes.
*/

-- 1. LES TRONCONS

-- 1.1. Insertion des tronçons affectés à une et une seule voie et disposant d'une d'une seule domanialité dans TEMP_TRONCON_CORRECT_LITTERALIS

DELETE FROM G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS;

-- Insertion des tronçons des voies principales
MERGE INTO G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS a
    USING(
        WITH
            C_1 AS(-- Sélection des tronçons affectés à une et une seule voie PRINCIPALE et disposant d'une seule domanialité
                SELECT
                    a.objectid AS code_troncon
                FROM
                    G_BASE_VOIE.TA_TRONCON a
                    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
                    INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = b.fid_voie
                    INNER JOIN SIREO_LEC.OUT_DOMANIALITE d ON d.cnumtrc = a.objectid
                WHERE
                    c.objectid NOT IN(SELECT fid_voie_secondaire FROM G_BASE_VOIE.TA_HIERARCHISATION_VOIE)
                GROUP BY
                    a.objectid
                HAVING
                    COUNT(a.objectid) = 1
            )

            SELECT
                a.objectid AS CODE_TRONC,
                a.objectid AS id_troncon,
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
                c.id_voie AS CODE_RUE_G,
                TRIM(UPPER(c.type_de_voie) || ' ' || UPPER(c.libelle_voie) || ' ' || UPPER(COMPLEMENT_NOM_VOIE)) AS NOM_RUE_G,
                GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', c.GEOM) AS INSEE_G,
                c.id_voie AS CODE_RUE_D,
                TRIM(UPPER(c.type_de_voie) || ' ' || UPPER(c.libelle_voie) || ' ' || UPPER(COMPLEMENT_NOM_VOIE)) AS NOM_RUE_D,
                GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', c.GEOM) AS INSEE_D,
                CAST('' AS NUMBER(8,0)) AS LARGEUR,
                a.geom AS geometry
            FROM
                G_BASE_VOIE.TA_TRONCON a
                INNER JOIN C_1 d ON d.code_troncon = a.objectid
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
                INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE c ON c.id_voie = b.fid_voie
                INNER JOIN SIREO_LEC.OUT_DOMANIALITE e ON e.cnumtrc = a.objectid
            WHERE
                a.objectid NOT IN(90351, 4273, 90959, 90004, 90005, 91002, 90854, 90890, 90088, 90008, 90416, 90314, 14850, 90681, 90828, 90986, 91001, 90988, 90992, 9825, 90761, 90532, 90807, 90189, 27322, 10970, 4272, 90006, 9115, 90931, 90291, 90285, 90067, 90976, 90009, 55369, 90398, 90400, 90052, 90184, 90748, 21285, 90232, 90499, 90450, 90118, 11836, 90098, 90288, 90582, 90315, 90018, 90981, 6506, 90440, 90151, 50342, 90424, 11091, 90960, 90972, 58471, 90324, 90214, 90215, 90091, 11837, 90852, 90095, 90953, 90675, 90233, 90937, 90292, 5302, 90229, 90002, 90791, 2066, 6508, 16058, 90781, 90402, 90640, 16552, 90856, 9824, 90497, 90859, 10969, 90160, 90973, 9114, 90303, 18019, 10174, 90936, 5736, 90977, 90090, 90581, 90760, 90410, 9687, 9623, 9624, 90531, 90346, 90022, 90023, 90427, 90156, 90880, 12503, 12504, 90299, 10173, 10172, 91003, 90096, 79841, 90286, 90068, 90975, 90583, 90797, 90829, 90403, 10942, 90857, 90409, 90720, 90530, 90350, 90344, 90858, 90507, 90426, 90428, 9217, 15713, 90231, 10187, 90451, 90302, 10175, 90947, 90287, 90089, 90768, 90417, 90465, 14197, 4317, 9747, 90549, 90425, 90135, 90881, 90325, 9116, 90954, 90676, 90290, 5303, 90282, 91000, 91006, 90715, 14851, 90987, 90401, 90404, 9686)
    )t
    ON(a.code_tronc = t.code_tronc)
WHEN NOT MATCHED THEN
    INSERT(a.CODE_TRONC,a.ID_TRONCON,a.CLASSEMENT,a.CODE_RUE_G,a.NOM_RUE_G,a.INSEE_G,a.CODE_RUE_D,a.NOM_RUE_D,a.INSEE_D,a.LARGEUR,a.GEOMETRY)
    VALUES(t.CODE_TRONC,t.ID_TRONCON,t.CLASSEMENT,t.CODE_RUE_G,t.NOM_RUE_G,t.INSEE_G,t.CODE_RUE_D,t.NOM_RUE_D,t.INSEE_D,t.LARGEUR,t.GEOMETRY);
COMMIT;
-- Résultat : 42 367 tronçons affectés à une et une seule voie principale 

-- Insertion des tronçons des voies secondaires
MERGE INTO G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS a
    USING(
        WITH
            C_1 AS(-- Sélection des tronçons affectés à une et une seule voie PRINCIPALE et disposant d'une seule domanialité
                SELECT
                    a.objectid AS code_troncon
                FROM
                    G_BASE_VOIE.TA_TRONCON a
                    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
                    INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = b.fid_voie
                    INNER JOIN SIREO_LEC.OUT_DOMANIALITE d ON d.cnumtrc = a.objectid
                WHERE
                    c.objectid NOT IN(SELECT fid_voie_principale FROM G_BASE_VOIE.TA_HIERARCHISATION_VOIE)
                GROUP BY
                    a.objectid
                HAVING
                    COUNT(a.objectid) = 1
            )
            
            SELECT
                a.objectid AS CODE_TRONC,
                a.objectid AS id_troncon,
                CASE 
                    WHEN f.domania = 'AUTOROUTE OU VOIE A CARACTERE AUTOROUTIER'
                    THEN 'A'
                    WHEN f.domania = 'ROUTE NATIONALE'
                    THEN 'RN' -- Route Nationale
                    WHEN f.domania IN ('VOIE PRIVEE ENTRETENUE PAR LA CUDL','VOIE PRIVEE FERMEE','VOIE PRIVEE OUVERTE','AUTRE VOIE PRIVEE','DECLASSEMENT EN COURS')
                    THEN 'VP' -- Voie Privée
                    WHEN f.domania = 'CHEMIN RURAL'
                    THEN 'CR' -- Chemin Rural
                    WHEN f.domania IN ('VOIE METROPOLITAINE','GESTION COMMUNAUTAIRE','AUTRE VOIE PUBLIQUE')
                    THEN 'VC' -- Voie Communale
                END AS CLASSEMENT,
                e.id_voie AS CODE_RUE_G,
                TRIM(UPPER(e.type_de_voie) || ' ' || UPPER(e.libelle_voie) || ' ' || UPPER(e.COMPLEMENT_NOM_VOIE)) AS NOM_RUE_G,
                GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', e.GEOM) AS INSEE_G,
                e.id_voie AS CODE_RUE_D,
                TRIM(UPPER(e.type_de_voie) || ' ' || UPPER(e.libelle_voie) || ' ' || UPPER(e.COMPLEMENT_NOM_VOIE)) AS NOM_RUE_D,
                GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', e.GEOM) AS INSEE_D,
                CAST('' AS NUMBER(8,0)) AS LARGEUR,
                a.geom AS geometry
            FROM
                G_BASE_VOIE.TA_TRONCON a
                INNER JOIN C_1 d ON d.code_troncon = a.objectid
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
                INNER JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE c ON c.fid_voie_secondaire = b.fid_voie
                INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE e ON e.id_voie = c.fid_voie_principale
                INNER JOIN SIREO_LEC.OUT_DOMANIALITE f ON f.cnumtrc = a.objectid
            WHERE
                a.objectid NOT IN(SELECT id_troncon FROM G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS)
                AND a.objectid NOT IN(46738, 90877, 46599, 16627, 11383, 46606, 28361, 90351, 4273, 90959, 90004, 90005, 91002, 90854, 90890, 90088, 90008, 90416, 90314, 14850, 90681, 90828, 90986, 91001, 90988, 90992, 9825, 90761, 90532, 90807, 90189, 27322, 10970, 4272, 90006, 9115, 90931, 90291, 90285, 90067, 90976, 90009, 55369, 90398, 90400, 90052, 90184, 90748, 21285, 90232, 90499, 90450, 90118, 11836, 90098, 90288, 90582, 90315, 90018, 90981, 6506, 90440, 90151, 50342, 90424, 11091, 90960, 90972, 58471, 90324, 90214, 90215, 90091, 11837, 90852, 90095, 90953, 90675, 90233, 90937, 90292, 5302, 90229, 90002, 90791, 2066, 6508, 16058, 90781, 90402, 90640, 16552, 90856, 9824, 90497, 90859, 10969, 90160, 90973, 9114, 90303, 18019, 10174, 90936, 5736, 90977, 90090, 90581, 90760, 90410, 9687, 9623, 9624, 90531, 90346, 90022, 90023, 90427, 90156, 90880, 12503, 12504, 90299, 10173, 10172, 91003, 90096, 79841, 90286, 90068, 90975, 90583, 90797, 90829, 90403, 10942, 90857, 90409, 90720, 90530, 90350, 90344, 90858, 90507, 90426, 90428, 9217, 15713, 90231, 10187, 90451, 90302, 10175, 90947, 90287, 90089, 90768, 90417, 90465, 14197, 4317, 9747, 90549, 90425, 90135, 90881, 90325, 9116, 90954, 90676, 90290, 5303, 90282, 91000, 91006, 90715, 14851, 90987, 90401, 90404, 9686)
    )t
    ON(a.code_tronc = t.code_tronc)
WHEN NOT MATCHED THEN
    INSERT(a.CODE_TRONC,a.ID_TRONCON,a.CLASSEMENT,a.CODE_RUE_G,a.NOM_RUE_G,a.INSEE_G,a.CODE_RUE_D,a.NOM_RUE_D,a.INSEE_D,a.LARGEUR,a.GEOMETRY)
    VALUES(t.CODE_TRONC,t.ID_TRONCON,t.CLASSEMENT,t.CODE_RUE_G,t.NOM_RUE_G,t.INSEE_G,t.CODE_RUE_D,t.NOM_RUE_D,t.INSEE_D,t.LARGEUR,t.GEOMETRY);
COMMIT;
-- Résultat : 4 980 tronçons affectés à une et une seule voie secondaire

-- Mise à jour du code INSEE des tronçons situés à 15m maximum en-dehors du périmètre de la MEL et dont les champs insee_d et insee_g sont NULL
MERGE INTO G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS a
USING(
    SELECT
        a.id_troncon,
        b.code_insee
    FROM
        G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS a,
        G_REFERENTIEL.MEL_COMMUNE b, 
        USER_SDO_GEOM_METADATA m
    WHERE
        m.table_name = 'TEMP_TRONCON_CORRECT_LITTERALIS'
        AND a.insee_d IS NULL
        AND SDO_GEOM.WITHIN_DISTANCE(SDO_LRS.CONVERT_TO_STD_GEOM(
                SDO_LRS.LOCATE_PT(
                                SDO_LRS.CONVERT_TO_LRS_GEOM(a.geometry,m.diminfo),
                                SDO_GEOM.SDO_LENGTH(a.geometry,m.diminfo)/2
                )
            ), 15, b.geom, 0.005) = 'TRUE'
)t
ON(a.id_troncon = t.id_troncon)
WHEN MATCHED THEN
UPDATE SET a.insee_d = t.code_insee, a.insee_g = t.code_insee;
COMMIT;

-- Mise à jour du code INSEE des tronçons situés à 30m maximum en-dehors du périmètre de la MEL et dont les champs insee_d et insee_g sont NULL
MERGE INTO G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS a
USING(
    SELECT
        a.id_troncon,
        b.code_insee
    FROM
        G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS a,
        G_REFERENTIEL.MEL_COMMUNE b, 
        USER_SDO_GEOM_METADATA m
    WHERE
        m.table_name = 'TEMP_TRONCON_CORRECT_LITTERALIS'
        AND a.insee_d IS NULL
        AND SDO_GEOM.WITHIN_DISTANCE(SDO_LRS.CONVERT_TO_STD_GEOM(
                SDO_LRS.LOCATE_PT(
                                SDO_LRS.CONVERT_TO_LRS_GEOM(a.geometry,m.diminfo),
                                SDO_GEOM.SDO_LENGTH(a.geometry,m.diminfo)/2
                )
            ), 30, b.geom, 0.005) = 'TRUE'
)t
ON(a.id_troncon = t.id_troncon)
WHEN MATCHED THEN
UPDATE SET a.insee_d = t.code_insee, a.insee_g = t.code_insee;
COMMIT;

-- Résultat Total : 47 347 tronçons affectés à une et une seule voie    

--------------------------------------------------------------------------------------------------------------------------------
-- 1.2. Insertion des tronçons affectés à plusieurs voies et disposant d'une seule domanialité
-- 
DELETE FROM G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS;
MERGE INTO G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS a
    USING(
        WITH
            C_1 AS(-- Sélection des tronçons affectés à plusieurs voies  au sein d'une même commune mais disposant d'une seule domanialité
                SELECT
                    a.objectid AS code_tronc
                FROM
                    G_BASE_VOIE.TA_TRONCON a
                    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
                    INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE c ON c.id_voie = b.fid_voie
                    INNER JOIN SIREO_LEC.OUT_DOMANIALITE d ON d.cnumtrc = a.objectid
                WHERE
                    GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', c.geom) <> 'error'
                GROUP BY
                    a.objectid
                HAVING
                    COUNT(a.objectid) > 1
                    AND COUNT(DISTINCT d.objectid) = 1
                    AND COUNT(GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', c.geom)) > 1
                    AND COUNT(DISTINCT c.id_voie) > 1
            ),
            
            C_2 AS(-- Sélection de l'objectid max de TA_TRONCON afin de ne pas créer de doublons d'id
                SELECT
                    MAX(objectid) AS code_troncon_max
                FROM
                    G_BASE_VOIE.TA_TRONCON
            ),
            
            C_3 AS(
            SELECT
                a.code_tronc,
                d.id_voie,
                TRIM(UPPER(d.type_de_voie) || ' ' || UPPER(d.libelle_voie) || ' ' || UPPER(d.COMPLEMENT_NOM_VOIE)) AS libelle_voie
            FROM
                C_1 a
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.code_tronc
                INNER JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE c ON c.fid_voie_principale  = b.fid_voie
                INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE d ON d.id_voie = c.fid_voie_principale
            UNION ALL
            SELECT
                a.code_tronc,
                d.id_voie,
                TRIM(UPPER(d.type_de_voie) || ' ' || UPPER(d.libelle_voie) || ' ' || UPPER(d.COMPLEMENT_NOM_VOIE)) AS libelle_voie
            FROM
                C_1 a
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.code_tronc
                INNER JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE c ON c.fid_voie_secondaire = b.fid_voie
                INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE d ON d.id_voie = c.fid_voie_principale
            )
            
            -- Sélection des autes infos + création des id de tronçon virtuels : on part du code_tronçon max+1 et on incrémente de 1 par tronçon repéré dans C_1
            SELECT
                a.code_troncon_max + 1 + rownum AS code_tronc,
                d.objectid AS id_troncon,
                CASE 
                    WHEN c.domania = 'AUTOROUTE OU VOIE A CARACTERE AUTOROUTIER'
                    THEN 'A'
                    WHEN c.domania = 'ROUTE NATIONALE'
                    THEN 'RN' -- Route Nationale
                    WHEN c.domania IN ('VOIE PRIVEE ENTRETENUE PAR LA CUDL','VOIE PRIVEE FERMEE','VOIE PRIVEE OUVERTE','AUTRE VOIE PRIVEE','DECLASSEMENT EN COURS')
                    THEN 'VP' -- Voie Privée
                    WHEN c.domania = 'CHEMIN RURAL'
                    THEN 'CR' -- Chemin Rural
                    WHEN c.domania IN ('VOIE METROPOLITAINE','GESTION COMMUNAUTAIRE','AUTRE VOIE PUBLIQUE')
                    THEN 'VC' -- Voie Communale
                END AS CLASSEMENT,
                b.id_voie AS CODE_RUE_G,
                b.libelle_voie AS NOM_RUE_G,
                GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', e.geom) AS INSEE_G,
                b.id_voie AS CODE_RUE_D,
                b.libelle_voie AS NOM_RUE_D,
                GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', e.geom) AS INSEE_D,
                CAST('' AS NUMBER(8,0)) AS LARGEUR,
                d.geom AS geometry
            FROM
                C_2 a,
                C_3 b
                INNER JOIN SIREO_LEC.OUT_DOMANIALITE c ON c.cnumtrc = b.code_tronc
                INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = b.code_tronc
                INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE e ON e.id_voie = b.id_voie
    )t
    ON(a.code_tronc = t.code_tronc)
WHEN NOT MATCHED THEN
    INSERT(a.CODE_TRONC,a.ID_TRONCON,a.CLASSEMENT,a.CODE_RUE_G,a.NOM_RUE_G,a.INSEE_G,a.CODE_RUE_D,a.NOM_RUE_D,a.INSEE_D,a.LARGEUR,a.GEOMETRY)
    VALUES(t.CODE_TRONC,t.ID_TRONCON,t.CLASSEMENT,t.CODE_RUE_G,t.NOM_RUE_G,t.INSEE_G,t.CODE_RUE_D,t.NOM_RUE_D,t.INSEE_D,t.LARGEUR,t.GEOMETRY);
COMMIT;
-- Résultat : 866 lignes fusionnées en créant des codes tronçons différents (uniques) 

-- Voies principales uniquement
MERGE INTO G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS a
    USING(
        WITH
            C_1 AS(-- Sélection des tronçons affectés à plusieurs voies  au sein d'une même commune mais disposant d'une seule domanialité
                SELECT
                    a.objectid AS code_tronc
                FROM
                    G_BASE_VOIE.TA_TRONCON a
                    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
                    INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE c ON c.id_voie = b.fid_voie
                    INNER JOIN SIREO_LEC.OUT_DOMANIALITE d ON d.cnumtrc = a.objectid
                WHERE
                    GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', c.geom) <> 'error'
                    AND c.id_voie NOT IN(SELECT fid_voie_principale AS id_voie FROM G_BASE_VOIE.TA_HIERARCHISATION_VOIE
                                        UNION ALL SELECT fid_voie_secondaire AS id_voie FROM G_BASE_VOIE.TA_HIERARCHISATION_VOIE
                                        )
                GROUP BY
                    a.objectid
                HAVING
                    COUNT(a.objectid) > 1
                    AND COUNT(DISTINCT d.objectid) = 1
                    AND COUNT(GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', c.geom)) > 1
                    AND COUNT(DISTINCT c.id_voie) > 1
            ),
            
            C_2 AS(-- Sélection de l'objectid max de TA_TRONCON afin de ne pas créer de doublons d'id
                SELECT
                    MAX(objectid) AS code_troncon_max
                FROM
                    G_BASE_VOIE.TA_TRONCON
            )
            
            -- Sélection des autes infos + création des id de tronçon virtuels : on part du code_tronçon max+1 et on incrémente de 1 par tronçon repéré dans C_1
            SELECT
                a.code_troncon_max + 1 + 1000 + rownum AS code_tronc,
                d.objectid AS id_troncon,
                CASE 
                    WHEN c.domania = 'AUTOROUTE OU VOIE A CARACTERE AUTOROUTIER'
                    THEN 'A'
                    WHEN c.domania = 'ROUTE NATIONALE'
                    THEN 'RN' -- Route Nationale
                    WHEN c.domania IN ('VOIE PRIVEE ENTRETENUE PAR LA CUDL','VOIE PRIVEE FERMEE','VOIE PRIVEE OUVERTE','AUTRE VOIE PRIVEE','DECLASSEMENT EN COURS')
                    THEN 'VP' -- Voie Privée
                    WHEN c.domania = 'CHEMIN RURAL'
                    THEN 'CR' -- Chemin Rural
                    WHEN c.domania IN ('VOIE METROPOLITAINE','GESTION COMMUNAUTAIRE','AUTRE VOIE PUBLIQUE')
                    THEN 'VC' -- Voie Communale
                END AS CLASSEMENT,
                e.id_voie AS CODE_RUE_G,
                TRIM(UPPER(e.type_de_voie) || ' ' || UPPER(e.libelle_voie) || ' ' || UPPER(e.COMPLEMENT_NOM_VOIE)) AS NOM_RUE_G,
                GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', e.geom) AS INSEE_G,
                e.id_voie AS CODE_RUE_D,
                TRIM(UPPER(e.type_de_voie) || ' ' || UPPER(e.libelle_voie) || ' ' || UPPER(e.COMPLEMENT_NOM_VOIE)) AS NOM_RUE_D,
                GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', e.geom) AS INSEE_D,
                CAST('' AS NUMBER(8,0)) AS LARGEUR,
                d.geom AS geometry
            FROM
                C_2 a,
                C_1 b
                INNER JOIN SIREO_LEC.OUT_DOMANIALITE c ON c.cnumtrc = b.code_tronc
                INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = b.code_tronc
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE f ON f.fid_troncon = d.objectid
                INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE e ON e.id_voie = f.fid_voie
    )t
    ON(a.code_tronc = t.code_tronc)
WHEN NOT MATCHED THEN
    INSERT(a.CODE_TRONC,a.ID_TRONCON,a.CLASSEMENT,a.CODE_RUE_G,a.NOM_RUE_G,a.INSEE_G,a.CODE_RUE_D,a.NOM_RUE_D,a.INSEE_D,a.LARGEUR,a.GEOMETRY)
    VALUES(t.CODE_TRONC,t.ID_TRONCON,t.CLASSEMENT,t.CODE_RUE_G,t.NOM_RUE_G,t.INSEE_G,t.CODE_RUE_D,t.NOM_RUE_D,t.INSEE_D,t.LARGEUR,t.GEOMETRY);
COMMIT;
-- Résultat : 886 lignes fusionnées en créant des codes tronçons différents (uniques)

--------------------------------------------------------------------------------------------------------------------------------
-- 1.3. Insertion des tronçons affectés à une seule voie, mais disposant de sous-tronçons de domanialités différentes

DELETE FROM G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS;
ALTER TABLE G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS ADD CODE_SOUS_TRONCON NUMBER(38,0);

-- Voies principales/secondaires
MERGE INTO G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS a
    USING(
        -- Insertion des tronçons disposant de plusieurs domanialités
        WITH
            C_1 AS(-- Sélection des tronçons disposant de plusieurs domanialités, mais affectés à une seule voie
                SELECT
                    a.objectid AS code_tronc
                FROM
                    G_BASE_VOIE.TA_TRONCON a
                    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
                    INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE c ON c.id_voie = b.fid_voie
                    INNER JOIN SIREO_LEC.OUT_DOMANIALITE d ON d.cnumtrc = a.objectid
                WHERE
                    GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', c.geom) <> 'error'
                GROUP BY
                    a.objectid
                HAVING
                    COUNT(a.objectid) > 1
                    AND COUNT(DISTINCT b.fid_voie) = 1
                    AND COUNT(DISTINCT d.domania) > 1
            ),
            
            C_2 AS(
                SELECT -- Sélection des tronçon des voies principales
                    a.code_tronc,
                    d.id_voie,
                    TRIM(UPPER(d.type_de_voie) || ' ' || UPPER(d.libelle_voie) || ' ' || UPPER(d.COMPLEMENT_NOM_VOIE)) AS libelle_voie
                FROM
                    C_1 a
                    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.code_tronc
                    INNER JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE c ON c.FID_VOIE_PRINCIPALE = b.FID_VOIE
                    INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE d ON d.ID_VOIE = c.FID_VOIE_PRINCIPALE
                UNION ALL
                SELECT -- Sélection des tronçon des voies secondaires
                    a.code_tronc,
                    d.id_voie,
                    TRIM(UPPER(d.type_de_voie) || ' ' || UPPER(d.libelle_voie) || ' ' || UPPER(d.COMPLEMENT_NOM_VOIE)) AS libelle_voie
                FROM
                    C_1 a
                    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.code_tronc
                    INNER JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE c ON c.FID_VOIE_SECONDAIRE = b.FID_VOIE
                    INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE d ON d.ID_VOIE = c.FID_VOIE_PRINCIPALE
            )
            
            SELECT
                a.code_tronc,
                a.code_tronc AS id_troncon,
                CASE 
                    WHEN c.domania = 'AUTOROUTE OU VOIE A CARACTERE AUTOROUTIER'
                    THEN 'A'
                    WHEN c.domania = 'ROUTE NATIONALE'
                    THEN 'RN' -- Route Nationale
                    WHEN c.domania = 'CHEMIN RURAL'
                    THEN 'CR' -- Chemin Rural
                    WHEN c.domania IN ('VOIE METROPOLITAINE','GESTION COMMUNAUTAIRE','AUTRE VOIE PUBLIQUE')
                    THEN 'VC' -- Voie Communale
                END AS CLASSEMENT,
                a.id_voie AS CODE_RUE_G,
                a.libelle_voie AS NOM_RUE_G,
                GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', b.geom) AS INSEE_G,
                a.id_voie AS CODE_RUE_D,
                a.libelle_voie AS NOM_RUE_D,
                GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', b.geom) AS INSEE_D,
                CAST('' AS NUMBER(8,0)) AS LARGEUR,
                d.geom AS geometry,
                c.objectid AS CODE_SOUS_TRONCON
            FROM
                C_2 a
                INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE b ON b.id_voie = a.id_voie
                INNER JOIN SIREO_LEC.OUT_DOMANIALITE c ON c.cnumtrc = a.code_tronc
                INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = a.code_tronc
            WHERE
                c.domania NOT IN ('VOIE PRIVEE ENTRETENUE PAR LA CUDL','VOIE PRIVEE FERMEE','VOIE PRIVEE OUVERTE','AUTRE VOIE PRIVEE','DECLASSEMENT EN COURS')
                AND c.objectid <> 889 -- Cette condition est nécessaire pour éviter d'avoir un doublon du troncon 54215 avec la même domanialité, ce qu ne devrait normalement pas être, mais bon...
    )t
    ON(a.code_tronc = t.code_tronc)
WHEN NOT MATCHED THEN
    INSERT(a.CODE_TRONC,a.ID_TRONCON,a.CLASSEMENT,a.CODE_RUE_G,a.NOM_RUE_G,a.INSEE_G,a.CODE_RUE_D,a.NOM_RUE_D,a.INSEE_D,a.LARGEUR,a.GEOMETRY, a.CODE_SOUS_TRONCON)
    VALUES(t.CODE_TRONC,t.ID_TRONCON,t.CLASSEMENT,t.CODE_RUE_G,t.NOM_RUE_G,t.INSEE_G,t.CODE_RUE_D,t.NOM_RUE_D,t.INSEE_D,t.LARGEUR,t.GEOMETRY, t.CODE_SOUS_TRONCON);
COMMIT;
-- Résultat : 3 lignes fusionnées

-- Voies principales uniquement
MERGE INTO G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS a
    USING(
        -- Insertion des tronçons disposant de plusieurs domanialités
        WITH
            C_1 AS(-- Sélection des tronçons disposant de plusieurs domanialités, mais affectés à une seule voie
                SELECT
                    a.objectid AS code_tronc
                FROM
                    G_BASE_VOIE.TA_TRONCON a
                    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
                    INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE c ON c.id_voie = b.fid_voie
                    INNER JOIN SIREO_LEC.OUT_DOMANIALITE d ON d.cnumtrc = a.objectid
                WHERE
                    GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', c.geom) <> 'error'
                    AND c.id_voie NOT IN(SELECT fid_voie_principale AS id_voie FROM G_BASE_VOIE.TA_HIERARCHISATION_VOIE
                                        UNION ALL SELECT fid_voie_secondaire AS id_voie FROM G_BASE_VOIE.TA_HIERARCHISATION_VOIE
                                        )
                GROUP BY
                    a.objectid
                HAVING
                    COUNT(a.objectid) > 1
                    AND COUNT(DISTINCT b.fid_voie) = 1
                    AND COUNT(DISTINCT d.domania) > 1
            )
            
            SELECT
                a.code_tronc,
                a.code_tronc AS id_troncon,
                CASE 
                    WHEN c.domania = 'AUTOROUTE OU VOIE A CARACTERE AUTOROUTIER'
                    THEN 'A'
                    WHEN c.domania = 'ROUTE NATIONALE'
                    THEN 'RN' -- Route Nationale
                    WHEN c.domania = 'CHEMIN RURAL'
                    THEN 'CR' -- Chemin Rural
                    WHEN c.domania IN ('VOIE METROPOLITAINE','GESTION COMMUNAUTAIRE','AUTRE VOIE PUBLIQUE')
                    THEN 'VC' -- Voie Communale
                END AS CLASSEMENT,
                b.id_voie AS CODE_RUE_G,
                TRIM(UPPER(b.type_de_voie) || ' ' || UPPER(b.libelle_voie) || ' ' || UPPER(b.COMPLEMENT_NOM_VOIE)) AS NOM_RUE_G,
                GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', b.geom) AS INSEE_G,
                b.id_voie AS CODE_RUE_D,
                TRIM(UPPER(b.type_de_voie) || ' ' || UPPER(b.libelle_voie) || ' ' || UPPER(b.COMPLEMENT_NOM_VOIE)) AS NOM_RUE_D,
                GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', b.geom) AS INSEE_D,
                CAST('' AS NUMBER(8,0)) AS LARGEUR,
                d.geom AS geometry,
                c.objectid AS CODE_SOUS_TRONCON
            FROM
                C_1 a
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE e ON e.fid_troncon = a.code_tronc
                INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE b ON b.id_voie = e.fid_voie
                INNER JOIN SIREO_LEC.OUT_DOMANIALITE c ON c.cnumtrc = a.code_tronc
                INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = a.code_tronc
            WHERE
                c.domania NOT IN ('VOIE PRIVEE ENTRETENUE PAR LA CUDL','VOIE PRIVEE FERMEE','VOIE PRIVEE OUVERTE','AUTRE VOIE PRIVEE','DECLASSEMENT EN COURS')
                AND c.objectid <> 889 -- Cette condition est nécessaire pour éviter d'avoir un doublon du troncon 54215 avec la même domanialité, ce qu ne devrait normalement pas être, mais bon...
    )t
    ON(a.code_tronc = t.code_tronc)
WHEN NOT MATCHED THEN
    INSERT(a.CODE_TRONC,a.ID_TRONCON,a.CLASSEMENT,a.CODE_RUE_G,a.NOM_RUE_G,a.INSEE_G,a.CODE_RUE_D,a.NOM_RUE_D,a.INSEE_D,a.LARGEUR,a.GEOMETRY, a.CODE_SOUS_TRONCON)
    VALUES(t.CODE_TRONC,t.ID_TRONCON,t.CLASSEMENT,t.CODE_RUE_G,t.NOM_RUE_G,t.INSEE_G,t.CODE_RUE_D,t.NOM_RUE_D,t.INSEE_D,t.LARGEUR,t.GEOMETRY, t.CODE_SOUS_TRONCON);
COMMIT;
-- Résultat : 8 lignes fusionnées

--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

-- 2. LES ADRESSES

-- 2.1. Insertion des associations tronçon/seuil où un seuil est affecté à un tronçon disposant d'une domanialité et affecté à une seule voie

-- La table des tronçons utilisée pour faire ces associations est TEMP_TRONCON_CORRECT_LITTERALIS.

DELETE FROM G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS;
MERGE INTO G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS a
    USING(
        -- Sélection des infos des seuils + leur géométrie pour ceux qui sont affectés à un tronçon sans problème
        WITH
            C_1 AS(
                SELECT DISTINCT
                    d.code_rue_g AS CODE_VOIE,
                    a.objectid AS CODE_POINT,
                    'ADR' AS NATURE,
                    CASE
                        WHEN a.complement_numero_seuil IS NULL
                            THEN CAST(a.numero_seuil AS VARCHAR2(254))
                        WHEN a.complement_numero_seuil IS NOT NULL
                            THEN CAST(a.numero_seuil || ' ' || a.complement_numero_seuil AS VARCHAR2(254))
                        END AS libelle,
                    a.numero_seuil AS NUMERO,
                    a.complement_numero_seuil AS REPETITION,
                    'LesDeuxCotes' AS COTE
                FROM
                    G_BASE_VOIE.TA_INFOS_SEUIL a
                    INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
                    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = b.objectid
                    INNER JOIN G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS d ON d.id_troncon = c.fid_troncon
                WHERE
                    a.objectid NOT IN(SELECT CAST(code_point AS NUMBER(38,0)) FROM G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS)
                
            )
            
            SELECT
                CAST(a.CODE_VOIE AS VARCHAR2(254)) AS CODE_VOIE,
                CAST(a.CODE_POINT AS VARCHAR2(254)) AS CODE_POINT,
                CAST(a.NATURE AS VARCHAR2(254)) AS NATURE,
                CAST(a.LIBELLE AS VARCHAR2(254)) AS LIBELLE,
                CAST(a.NUMERO AS NUMBER(8,0)) AS NUMERO,
                CAST(a.REPETITION AS VARCHAR2(10)) AS REPETITION,
                CAST(a.COTE AS VARCHAR2(254)) AS COTE,
                b.geom AS geometry
            FROM
                C_1 a
                INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.CODE_POINT
            WHERE
                code_point NOT IN(332914,299591)
    )t
    ON(a.code_point = t.code_point AND a.code_voie = t.code_voie)
WHEN NOT MATCHED THEN
    INSERT(a.code_voie, a.code_point, a.nature, a.libelle, a.numero, a.repetition, a.cote, a.geometry)
    VALUES(t.code_voie, t.code_point, t.nature, t.libelle, t.numero, t.repetition, t.cote, t.geometry);
COMMIT;
-- Résultat : 290 191 seuils fusionnés
-- Nouv Résultat : 286 507 seuils fusionnés
------------------------------------------------------------------------------------------------------------------------

-- 2.2. Insertion des seuils affectés à des tronçons affectés à plusieurs voies
/*
Pour éviter la création de doublons, la table des tronçons utilisée est TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS.
L'objectif est ici que les tronçons utilisés soient les tronçons virtuels crés à l'étape 1.2.
*/
DELETE FROM G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS;
INSERT INTO G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS(CODE_VOIE,CODE_POINT,NATURE,LIBELLE,NUMERO,REPETITION,COTE,GEOMETRY)
WITH
    C_1 AS(
        SELECT DISTINCT
            d.code_rue_g AS CODE_VOIE,
            a.objectid AS CODE_POINT,
            'ADR' AS NATURE,
            CASE
                WHEN a.complement_numero_seuil IS NULL
                    THEN CAST(a.numero_seuil AS VARCHAR2(254))
                WHEN a.complement_numero_seuil IS NOT NULL
                    THEN CAST(a.numero_seuil || ' ' || a.complement_numero_seuil AS VARCHAR2(254))
                END AS libelle,
            a.numero_seuil AS NUMERO,
            a.complement_numero_seuil AS REPETITION,
            'LesDeuxCotes' AS COTE,
            a.fid_seuil,
            d.insee_g
        FROM
            G_BASE_VOIE.TA_INFOS_SEUIL a
            INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = b.objectid
            INNER JOIN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS d ON CAST(d.ID_TRONCON AS NUMBER(38,0)) = c.fid_troncon,
            USER_SDO_GEOM_METADATA m            
    ),
    
    C_2 AS(
        SELECT DISTINCT
            MIN(CAST(a.CODE_VOIE AS NUMBER(38,0))) AS CODE_VOIE,
            CAST(a.CODE_POINT AS VARCHAR2(254)) AS CODE_POINT,
            a.fid_seuil,
            CAST(a.NATURE AS VARCHAR2(254)) AS NATURE,
            CAST(a.LIBELLE AS VARCHAR2(254)) LIBELLE,
            CAST(a.NUMERO AS NUMBER(8,0)) AS NUMERO,
            CAST(a.REPETITION AS VARCHAR2(10)) AS REPETITION,
            CAST(a.COTE AS VARCHAR2(254)) AS COTE
        FROM
            C_1 a
            INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
        WHERE
            GET_CODE_INSEE_CONTAIN_POINT('TA_SEUIL', b.geom) = a.insee_g
        GROUP BY
            CAST(a.CODE_POINT AS VARCHAR2(254)),
            a.fid_seuil,
            CAST(a.NATURE AS VARCHAR2(254)),
            CAST(a.LIBELLE AS VARCHAR2(254)),
            CAST(a.NUMERO AS NUMBER(8,0)),
            CAST(a.REPETITION AS VARCHAR2(10)),
            CAST(a.COTE AS VARCHAR2(254))
    )        
    SELECT 
        CAST(a.CODE_VOIE AS VARCHAR(254)),
        a.CODE_POINT,
        a.NATURE,
        a.LIBELLE,
        a.NUMERO,
        a.REPETITION,
        a.COTE,       
        b.geom AS GEOMETRY
    FROM
        C_2 a
        INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil;
COMMIT;
-- Résultat : 3 718 seuils fusionnés
-- Nouv Résultat : 3 189 seuils fusionnés
--------------------------------------------------------------------------------------------------------------------------

-- 2.3. Insertion des seuils affectés à des tronçons disposant de sous-tronçons de domanialités différentes.
-- La table des tronçons utilisée pour ces associations est : TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS.

DELETE FROM G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS;
MERGE INTO G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS a
USING(
        WITH
            C_1 AS(
                SELECT DISTINCT
                    TRIM(d.code_rue_g) AS CODE_VOIE,
                    TRIM(d.id_troncon),
                    TRIM(b.objectid) AS id_point_geom,
                    TRIM(a.objectid) AS CODE_POINT,
                    'ADR' AS NATURE,
                    CASE
                        WHEN a.complement_numero_seuil IS NULL
                            THEN TRIM(CAST(a.numero_seuil AS VARCHAR2(254)))
                        WHEN a.complement_numero_seuil IS NOT NULL
                            THEN TRIM(CAST(a.numero_seuil || ' ' || a.complement_numero_seuil AS VARCHAR2(254)))
                        END AS libelle,
                    TRIM(a.numero_seuil) AS NUMERO,
                    TRIM(a.complement_numero_seuil) AS REPETITION,
                    'LesDeuxCotes' AS COTE,
                    TRIM(a.fid_seuil) AS fid_seuil,
                    TRIM(MAX(d.code_sous_troncon)),
                    TRIM(d.insee_g)
                FROM
                    G_BASE_VOIE.TA_INFOS_SEUIL a
                    INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
                    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = b.objectid
                    INNER JOIN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS d ON CAST(d.ID_TRONCON AS NUMBER(38,0)) = c.fid_troncon AND d.insee_g = GET_CODE_INSEE_CONTAIN_POINT('TA_SEUIL', b.geom)
                    INNER JOIN SIREO_LEC.OUT_DOMANIALITE e ON e.cnumtrc = d.id_troncon AND e.objectid = d.code_sous_troncon
                GROUP BY
                    TRIM(d.code_rue_g),
                    TRIM(d.id_troncon),
                    TRIM(b.objectid),
                    TRIM(a.objectid),
                    'ADR',
                    CASE
                        WHEN a.complement_numero_seuil IS NULL
                            THEN TRIM(CAST(a.numero_seuil AS VARCHAR2(254)))
                        WHEN a.complement_numero_seuil IS NOT NULL
                            THEN TRIM(CAST(a.numero_seuil || ' ' || a.complement_numero_seuil AS VARCHAR2(254)))
                        END,
                    TRIM(a.numero_seuil),
                    TRIM(a.complement_numero_seuil),
                    'LesDeuxCotes',
                    TRIM(a.fid_seuil),
                    TRIM(d.insee_g)
            )
            
            SELECT
                CAST(a.CODE_VOIE AS VARCHAR(254)) AS CODE_VOIE,
                a.CODE_POINT,
                a.NATURE,
                a.LIBELLE,
                a.NUMERO,
                a.REPETITION,
                a.COTE,       
                b.geom AS GEOMETRY
            FROM
                C_1 a
                INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
    )t
    ON(a.code_point = t.code_point AND a.code_voie = t.code_voie)
WHEN NOT MATCHED THEN
INSERT(a.CODE_VOIE,a.CODE_POINT,a.NATURE,a.LIBELLE,a.NUMERO,a.REPETITION,a.COTE,a.GEOMETRY)
VALUES(t.CODE_VOIE,t.CODE_POINT,t.NATURE,t.LIBELLE,t.NUMERO,t.REPETITION,t.COTE,t.GEOMETRY);
COMMIT;
-- Résultat : 89 seuils fusionnés

--------------------------------------------------------------------------------------------------------------------------------

-- 2.4. Insertion des seuils restants

-- Pour éviter les erreurs et/ou incongruités, la table des tronçons utilisée pour faire ces associations est TEMP_TRONCON_AUTRES_LITTERALIS.

DELETE FROM G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS;
MERGE INTO G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS a
USING(
        WITH
            C_1 AS(
                SELECT
                    CAST(code_point AS NUMBER(38,0)) AS code_point
                FROM
                    G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS
                UNION ALL
                SELECT
                    CAST(code_point AS NUMBER(38,0)) AS code_point
                FROM
                    G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS
                UNION ALL
                SELECT
                    CAST(code_point AS NUMBER(38,0)) AS code_point
                FROM
                    G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS
            ),
            
            C_2 AS(
                SELECT DISTINCT
                    a.objectid
                FROM
                    G_BASE_VOIE.TA_INFOS_SEUIL a
                    INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
                    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = b.objectid
                    INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = c.fid_troncon
                    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE e ON e.fid_troncon = d.objectid
                    INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE f ON f.id_voie = e.fid_voie
               WHERE
                    a.objectid NOT IN(SELECT code_point FROM C_1) 
                GROUP BY
                    a.objectid
                HAVING
                    COUNT(f.id_voie) = 1
            ),
            
            C_3 AS(
                SELECT DISTINCT
                    d.code_rue_g AS CODE_VOIE,
                    a.objectid AS CODE_POINT,
                    'ADR' AS NATURE,
                    CASE
                        WHEN a.complement_numero_seuil IS NULL
                            THEN CAST(a.numero_seuil AS VARCHAR2(254))
                        WHEN a.complement_numero_seuil IS NOT NULL
                            THEN CAST(a.numero_seuil || ' ' || a.complement_numero_seuil AS VARCHAR2(254))
                        END AS libelle,
                    a.numero_seuil AS NUMERO,
                    a.complement_numero_seuil AS REPETITION,
                    'LesDeuxCotes' AS COTE,
                    a.fid_seuil
                    FROM
                        G_BASE_VOIE.TA_INFOS_SEUIL a
                        INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
                        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = b.objectid
                        INNER JOIN G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS d ON d.id_troncon = c.fid_troncon
                        INNER JOIN C_2 e ON e.objectid = a.objectid
            )
            
            SELECT
                a.*,
                b.geom AS geometry
            FROM
                C_3 a
                INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
    )t
    ON(a.code_point = t.code_point AND a.code_voie = t.code_voie)
WHEN NOT MATCHED THEN
INSERT(a.CODE_VOIE,a.CODE_POINT,a.NATURE,a.LIBELLE,a.NUMERO,a.REPETITION,a.COTE,a.GEOMETRY)
VALUES(t.CODE_VOIE,t.CODE_POINT,t.NATURE,t.LIBELLE,t.NUMERO,t.REPETITION,t.COTE,t.GEOMETRY);
COMMIT;    
-- Résultat : 51 586 seuils fusionnés
-- Nouv Résultat : 52 450 seuils fusionnés
---------------------------------------------------------------------------------------------------------------

-- 2.5. Insertion des adresses restantes liées aux tronçons affectés à plusieurs voies
-- Je ne comprends pas pourquoi il faut lancer ce code en plus de celui du point 2.2, mais cela fonctionne sans produire d'erreur et permet de ne pas oublier de seuils...
MERGE INTO G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS a
    USING(
        WITH
            C_0 AS(
                SELECT
                    code_point
                FROM
                    G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS
                UNION ALL
                SELECT
                    code_point
                FROM
                    G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS
                UNION ALL
                SELECT
                    code_point
                FROM
                    G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS
                UNION ALL
                SELECT
                    code_point
                FROM
                    G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS      
            ),
            
            C_1 AS(
                SELECT DISTINCT
                    d.code_rue_g AS CODE_VOIE,
                    a.objectid AS CODE_POINT,
                    'ADR' AS NATURE,
                    CASE
                        WHEN a.complement_numero_seuil IS NULL
                            THEN CAST(a.numero_seuil AS VARCHAR2(254))
                        WHEN a.complement_numero_seuil IS NOT NULL
                            THEN CAST(a.numero_seuil || ' ' || a.complement_numero_seuil AS VARCHAR2(254))
                        END AS libelle,
                    a.numero_seuil AS NUMERO,
                    a.complement_numero_seuil AS REPETITION,
                    'LesDeuxCotes' AS COTE,
                    a.fid_seuil,
                    d.insee_g
                FROM
                    G_BASE_VOIE.TA_INFOS_SEUIL a
                    INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
                    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = b.objectid
                    INNER JOIN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS d ON CAST(d.ID_TRONCON AS NUMBER(38,0)) = c.fid_troncon,
                    USER_SDO_GEOM_METADATA m 
                WHERE
                    a.objectid NOT IN(SELECT CAST(code_point AS NUMBER(38,0)) FROM C_0)
            ),
            
            C_2 AS(
                SELECT DISTINCT
                    MIN(CAST(a.CODE_VOIE AS NUMBER(38,0))) AS CODE_VOIE,
                    CAST(a.CODE_POINT AS VARCHAR2(254)) AS CODE_POINT,
                    a.fid_seuil,
                    CAST(a.NATURE AS VARCHAR2(254)) AS NATURE,
                    CAST(a.LIBELLE AS VARCHAR2(254)) LIBELLE,
                    CAST(a.NUMERO AS NUMBER(8,0)) AS NUMERO,
                    CAST(a.REPETITION AS VARCHAR2(10)) AS REPETITION,
                    CAST(a.COTE AS VARCHAR2(254)) AS COTE
                FROM
                    C_1 a
                    INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
                GROUP BY
                    CAST(a.CODE_POINT AS VARCHAR2(254)),
                    a.fid_seuil,
                    CAST(a.NATURE AS VARCHAR2(254)),
                    CAST(a.LIBELLE AS VARCHAR2(254)),
                    CAST(a.NUMERO AS NUMBER(8,0)),
                    CAST(a.REPETITION AS VARCHAR2(10)),
                    CAST(a.COTE AS VARCHAR2(254))
            )        
            SELECT 
                CAST(a.CODE_VOIE AS VARCHAR(254)) AS CODE_VOIE,
                a.CODE_POINT,
                a.NATURE,
                a.LIBELLE,
                a.NUMERO,
                a.REPETITION,
                a.COTE,       
                b.geom AS GEOMETRY
            FROM
                C_2 a
                INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
    )t
ON(a.code_point = t.code_point AND a.code_voie = t.code_voie)
WHEN NOT MATCHED THEN
    INSERT(a.code_voie, a.code_point, a.nature, a.libelle, a.numero, a.repetition, a.cote, a.geometry)
    VALUES(t.code_voie, t.code_point, t.nature, t.libelle, t.numero, t.repetition, t.cote, t.geometry);
COMMIT;
-- Résultat : 934 seuils fusionnés
-- Nouv Résultat : 1 684 seuils fusionnés
------------------------------------------------------------------------------------------------------------------------------

-- 2.6. Insertion des seuils restants dans TEMP_ADRESSE_AUTRES_LITTERALIS
-- Même remarque qu'au point 2.5, normalement ce code ne devrait pas être nécessaire, mais sans lui il manque des seuils (et le résultat qu'il renvoie est correct)

MERGE INTO G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS a
USING(
    WITH
        C_0 AS(
                SELECT
                    code_point
                FROM
                    G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS
                UNION ALL
                SELECT
                    code_point
                FROM
                    G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS
                UNION ALL
                SELECT
                    code_point
                FROM
                    G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS
                UNION ALL
                SELECT
                    code_point
                FROM
                    G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS      
        ),
            
        C_1 AS( -- Sélection des seuils restants
            SELECT
                a.objectid
            FROM
                G_BASE_VOIE.TA_INFOS_SEUIL a
                INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = b.objectid
                INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = c.fid_troncon
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE e ON e.fid_troncon = d.objectid
                INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE f ON f.id_voie = e.fid_voie                       
            WHERE
                a.objectid NOT IN(331519,299591,332914,181776)
                AND a.objectid NOT IN(SELECT CAST(code_point AS NUMBER(38,0)) FROM C_0)
            GROUP BY
                a.objectid
            HAVING
                COUNT(a.objectid) = 1
        ),
    
        C_2 AS(
            SELECT DISTINCT
                f.code_rue_g AS CODE_VOIE,
                a.objectid AS CODE_POINT,
                'ADR' AS NATURE,
                CASE
                    WHEN g.complement_numero_seuil IS NULL
                        THEN CAST(g.numero_seuil AS VARCHAR2(254))
                    WHEN g.complement_numero_seuil IS NOT NULL
                        THEN CAST(g.numero_seuil || ' ' || g.complement_numero_seuil AS VARCHAR2(254))
                    END AS libelle,
                g.numero_seuil AS NUMERO,
                g.complement_numero_seuil AS REPETITION,
                'LesDeuxCotes' AS COTE,
                g.fid_seuil
            FROM
                C_1 a
                INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL g ON g.objectid = a.objectid
                INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = g.fid_seuil
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = b.objectid
                INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = c.fid_troncon
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE e ON e.fid_troncon = d.objectid
                INNER JOIN G_BASE_VOIE.VM_TRONCON_LITTERALIS f ON CAST(f.code_rue_g AS NUMBER(38,0))= e.fid_voie
            WHERE
                g.objectid NOT IN(331519,299591,332914,181776)
        )
            SELECT
                a.*,
                b.geom AS GEOMETRY
            FROM
                C_2 a
                INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil       
    )t
    ON(a.code_point = t.code_point AND a.code_voie = t.code_voie)
WHEN NOT MATCHED THEN
INSERT(a.CODE_VOIE,a.CODE_POINT,a.NATURE,a.LIBELLE,a.NUMERO,a.REPETITION,a.COTE,a.GEOMETRY)
VALUES(t.CODE_VOIE,t.CODE_POINT,t.NATURE,t.LIBELLE,t.NUMERO,t.REPETITION,t.COTE,t.GEOMETRY);
COMMIT; 
-- Résultat : 1133 seuils fusionnés
-- Nouv Résultat : 1679 seuils fusionnés