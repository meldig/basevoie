/*
Code permettant de remplir les tables de travail du projet LITTERALIS.
Les tables en question sont :
- TA_VOIE_LITTERALIS ;
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

-- TA_VOIE_LITTERALIS
-- Insertion des voies principales dans TA_VOIE_LITTERALIS
INSERT INTO G_BASE_VOIE.TA_VOIE_LITTERALIS(id_voie,libelle_voie,insee,mesure_voie,complement_nom_voie,geom,date_saisie,date_modification,fid_pnom_saisie,fid_pnom_modification,fid_typevoie,fid_genre_voie,fid_rivoli,fid_metadonnee)
WITH
    C_1 AS(
        SELECT
            a.id_voie,
            a.libelle_voie,
            GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', a.GEOM) AS INSEE,
            SDO_GEOM.SDO_LENGTH(a.geom, 0.001) AS mesure_voie,
            a.complement_nom_voie,
            b.date_saisie,
            b.date_modification,
            b.fid_pnom_saisie,
            b.fid_pnom_modification,
            b.fid_typevoie,
            b.fid_genre_voie,
            b.fid_rivoli,
            b.fid_metadonnee
        FROM
            G_BASE_VOIE.VM_VOIE_AGGREGEE a
            INNER JOIN G_BASE_VOIE.TA_VOIE b ON b.objectid = a.id_voie
            INNER JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE b ON b.fid_voie_principale = a.id_voie
        UNION ALL
        SELECT
            a.id_voie,
            a.libelle_voie,
            GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', a.GEOM) AS INSEE,
            SDO_GEOM.SDO_LENGTH(a.geom, 0.001) AS mesure_voie,
            a.complement_nom_voie,
            b.date_saisie,
            b.date_modification,
            b.fid_pnom_saisie,
            b.fid_pnom_modification,
            b.fid_typevoie,
            b.fid_genre_voie,
            b.fid_rivoli,
            b.fid_metadonnee
        FROM
            G_BASE_VOIE.VM_VOIE_AGGREGEE a
            INNER JOIN G_BASE_VOIE.TA_VOIE b ON b.objectid = a.id_voie
        WHERE
            a.id_voie NOT IN(SELECT fid_voie_secondaire FROM G_BASE_VOIE.TA_HIERARCHISATION_VOIE)
            AND a.id_voie NOT IN(SELECT fid_voie_principale FROM G_BASE_VOIE.TA_HIERARCHISATION_VOIE)
    ),
    
    C_2 AS(
        SELECT DISTINCT *
        FROM
            C_1
    )
    
    SELECT
        a.id_voie,
        a.libelle_voie,
        a.insee,
        a.mesure_voie,
        a.complement_nom_voie,
        b.geom,
        a.date_saisie,
        a.date_modification,
        a.fid_pnom_saisie,
        a.fid_pnom_modification,
        a.fid_typevoie,
        a.fid_genre_voie,
        a.fid_rivoli,
        a.fid_metadonnee
    FROM
        C_2 a
        INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE b ON b.id_voie = a.id_voie;
-- Résultat : 17611 lignes insérées

-- Insertion des voies secondaires dans TA_VOIE_LITTERALIS
MERGE INTO G_BASE_VOIE.TA_VOIE_LITTERALIS a
USING(
    SELECT
        a.id_voie,
        b.fid_voie_principale,
        a.libelle_voie || ' ANNEXE ' || ROW_NUMBER() OVER (PARTITION BY (UPPER(TRIM(a.libelle_voie)) || ' ' || GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', a.GEOM)) ORDER BY SDO_GEOM.SDO_LENGTH(a.geom, 0.001) DESC) AS libelle_voie,
        GET_CODE_INSEE_TRONCON('VM_VOIE_AGGREGEE', a.GEOM) AS INSEE,
        SDO_GEOM.SDO_LENGTH(a.geom, 0.001) AS mesure_voie,
        c.complement_nom_voie,
        c.date_saisie,
        c.date_modification,
        c.fid_pnom_saisie,
        c.fid_pnom_modification,
        c.fid_typevoie,
        c.fid_genre_voie,
        c.fid_rivoli,
        c.fid_metadonnee,
        a.geom
    FROM
        G_BASE_VOIE.VM_VOIE_AGGREGEE a
        INNER JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE b ON b.FID_VOIE_SECONDAIRE = a.id_voie
        INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = b.fid_voie_secondaire
)t
ON(a.id_voie = t.id_voie)
WHEN NOT MATCHED THEN
INSERT(a.id_voie, a.libelle_voie, a.insee, a.mesure_voie, a.complement_nom_voie, a.geom, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.fid_typevoie, a.fid_genre_voie, a.fid_rivoli, a.fid_metadonnee)
VALUES(t.id_voie, t.libelle_voie, t.insee, t.mesure_voie, t.complement_nom_voie, t.geom, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification, t.fid_typevoie, t.fid_genre_voie, t.fid_rivoli, t.fid_metadonnee);
-- Résultat : 4531 lignes fusionnées

-- 1. LES TRONCONS
-- 1.1. Insertion des tronçons affectés à une et une seule voie et disposant d'une d'une seule domanialité dans TEMP_TRONCON_CORRECT_LITTERALIS

DELETE FROM G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS;
MERGE INTO G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS a
    USING(
        WITH
            C_1 AS(-- Sélection des tronçons affectés à une et une seule voie et disposant d'une seule domanialité
                SELECT
                    a.objectid AS code_troncon
                FROM
                    G_BASE_VOIE.TA_TRONCON a
                    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
                    INNER JOIN G_BASE_VOIE.TA_VOIE_LITTERALIS c ON c.id_voie = b.fid_voie
                    INNER JOIN SIREO_LEC.OUT_DOMANIALITE d ON d.cnumtrc = a.objectid
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
                c.libelle_voie AS NOM_RUE_G,
                c.insee AS INSEE_G,
                c.id_voie AS CODE_RUE_D,
                c.libelle_voie AS NOM_RUE_D,
                c.insee AS INSEE_D,
                CAST('' AS NUMBER(8,0)) AS LARGEUR,
                a.geom AS geometry
            FROM
                G_BASE_VOIE.TA_TRONCON a
                INNER JOIN C_1 d ON d.code_troncon = a.objectid
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
                INNER JOIN G_BASE_VOIE.TA_VOIE_LITTERALIS c ON c.id_voie = b.fid_voie
                INNER JOIN SIREO_LEC.OUT_DOMANIALITE e ON e.cnumtrc = a.objectid
            WHERE
                c.insee IS NOT NULL
                --c.id_voie NOT IN(3670725,5980305,3780330,4109016,3789288,6461183,2509041,3039032,3289399,3560237,3039000,2509042,3209014,6589008,3681700,3782043,1739021,2529011,139011,6029002,2990086,3320060,4210050,5990510,1631305,6461195,3503180,3600840,5850585,6480320,3710057,4870090,4570236,4700153,3503375,3781455,171620,3170480,900510,4210640,5995430,6502690,3500495,5070070,2989086,90202,3469046,95712,880311,1430360,3320370,3670767,3681460,3782070,2860870,3601220,1430214,3170440,3329010,3679001,3509252,5279049,2529007,3179061)
                -- la condition ci-dessus est due au fait que ces voies étaient sur les limites communales. C'est pour ça qu'elles ont été doublonnées. Problème : en changeant de référentiel communal ces voies ne sont plus sur les limites
        )t
    ON(a.code_tronc = t.code_tronc)
WHEN NOT MATCHED THEN
    INSERT(a.CODE_TRONC,a.ID_TRONCON,a.CLASSEMENT,a.CODE_RUE_G,a.NOM_RUE_G,a.INSEE_G,a.CODE_RUE_D,a.NOM_RUE_D,a.INSEE_D,a.LARGEUR,a.GEOMETRY)
    VALUES(t.CODE_TRONC,t.ID_TRONCON,t.CLASSEMENT,t.CODE_RUE_G,t.NOM_RUE_G,t.INSEE_G,t.CODE_RUE_D,t.NOM_RUE_D,t.INSEE_D,t.LARGEUR,t.GEOMETRY);
COMMIT;
-- Résultat : 47 427 tronçons affectés à une et une seule voie    

--------------------------------------------------------------------------------------------------------------------------------
-- 1.2. Insertion des tronçons affectés à plusieurs voies et disposant d'une seule domanialité

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
                    INNER JOIN G_BASE_VOIE.TA_VOIE_LITTERALIS c ON c.id_voie = b.fid_voie
                    INNER JOIN SIREO_LEC.OUT_DOMANIALITE d ON d.cnumtrc = a.objectid
                WHERE
                    c.insee IS NOT NULL
                GROUP BY
                    a.objectid
                HAVING
                    COUNT(a.objectid) > 1
                    AND COUNT(DISTINCT d.objectid) = 1
                    AND COUNT(c.insee) > 1
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
                a.code_troncon_max + 1 + rownum AS code_tronc,
                f.objectid AS id_troncon,
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
                d.id_voie AS CODE_RUE_G,
                d.libelle_voie AS NOM_RUE_G,
                d.insee AS INSEE_G,
                d.id_voie AS CODE_RUE_D,
                d.libelle_voie AS NOM_RUE_D,
                d.insee AS INSEE_D,
                CAST('' AS NUMBER(8,0)) AS LARGEUR,
                f.geom AS geometry
            FROM
                C_2 a,
                C_1 b
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE c ON c.fid_troncon = b.code_tronc
                INNER JOIN G_BASE_VOIE.TA_VOIE_LITTERALIS d ON d.id_voie = c.fid_voie
                INNER JOIN SIREO_LEC.OUT_DOMANIALITE e ON e.cnumtrc = b.code_tronc
                INNER JOIN G_BASE_VOIE.TA_TRONCON f ON f.objectid = b.code_tronc
    )t
    ON(a.code_tronc = t.code_tronc)
WHEN NOT MATCHED THEN
    INSERT(a.CODE_TRONC,a.ID_TRONCON,a.CLASSEMENT,a.CODE_RUE_G,a.NOM_RUE_G,a.INSEE_G,a.CODE_RUE_D,a.NOM_RUE_D,a.INSEE_D,a.LARGEUR,a.GEOMETRY)
    VALUES(t.CODE_TRONC,t.ID_TRONCON,t.CLASSEMENT,t.CODE_RUE_G,t.NOM_RUE_G,t.INSEE_G,t.CODE_RUE_D,t.NOM_RUE_D,t.INSEE_D,t.LARGEUR,t.GEOMETRY);
COMMIT;
-- Résultat : 1 518 lignes fusionnées en créant des codes tronçons différents (uniques) 

--------------------------------------------------------------------------------------------------------------------------------
-- 1.3. Insertion des tronçons affectés à une seule voie, mais disposant de sous-tronçons de domanialités différentes

DELETE FROM G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS;
ALTER TABLE G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS ADD CODE_SOUS_TRONCON NUMBER(38,0);

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
                    INNER JOIN G_BASE_VOIE.TA_VOIE_LITTERALIS c ON c.id_voie = b.fid_voie
                    INNER JOIN SIREO_LEC.OUT_DOMANIALITE d ON d.cnumtrc = a.objectid
                WHERE
                    c.insee IS NOT NULL
                GROUP BY
                    a.objectid
                HAVING
                    COUNT(a.objectid) > 1
                    AND COUNT(DISTINCT b.fid_voie) = 1
                    AND COUNT(DISTINCT d.domania) > 1
            )
            
            SELECT
                b.code_tronc,
                b.code_tronc AS id_troncon,
                CASE 
                    WHEN e.domania = 'AUTOROUTE OU VOIE A CARACTERE AUTOROUTIER'
                    THEN 'A'
                    WHEN e.domania = 'ROUTE NATIONALE'
                    THEN 'RN' -- Route Nationale
                    WHEN e.domania = 'CHEMIN RURAL'
                    THEN 'CR' -- Chemin Rural
                    WHEN e.domania IN ('VOIE METROPOLITAINE','GESTION COMMUNAUTAIRE','AUTRE VOIE PUBLIQUE')
                    THEN 'VC' -- Voie Communale
                END AS CLASSEMENT,
                d.id_voie AS CODE_RUE_G,
                d.libelle_voie AS NOM_RUE_G,
                d.insee AS INSEE_G,
                d.id_voie AS CODE_RUE_D,
                d.libelle_voie AS NOM_RUE_D,
                d.insee AS INSEE_D,
                CAST('' AS NUMBER(8,0)) AS LARGEUR,
                f.geom AS geometry,
                e.objectid AS CODE_SOUS_TRONCON
            FROM
                C_1 b
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE c ON c.fid_troncon = b.code_tronc
                INNER JOIN G_BASE_VOIE.TA_VOIE_LITTERALIS d ON d.id_voie = c.fid_voie
                INNER JOIN SIREO_LEC.OUT_DOMANIALITE e ON e.cnumtrc = b.code_tronc
                INNER JOIN G_BASE_VOIE.TA_TRONCON f ON f.objectid = b.code_tronc
            WHERE
                e.domania NOT IN ('VOIE PRIVEE ENTRETENUE PAR LA CUDL','VOIE PRIVEE FERMEE','VOIE PRIVEE OUVERTE','AUTRE VOIE PRIVEE','DECLASSEMENT EN COURS')
                AND e.objectid <> 889 -- Cette condition est nécessaire pour éviter d'avoir un doublon du troncon 54215 avec la même domanialité, ce qu ne devrait normalement pas être, mais bon...
    )t
    ON(a.code_tronc = t.code_tronc)
WHEN NOT MATCHED THEN
    INSERT(a.CODE_TRONC,a.ID_TRONCON,a.CLASSEMENT,a.CODE_RUE_G,a.NOM_RUE_G,a.INSEE_G,a.CODE_RUE_D,a.NOM_RUE_D,a.INSEE_D,a.LARGEUR,a.GEOMETRY, a.CODE_SOUS_TRONCON)
    VALUES(t.CODE_TRONC,t.ID_TRONCON,t.CLASSEMENT,t.CODE_RUE_G,t.NOM_RUE_G,t.INSEE_G,t.CODE_RUE_D,t.NOM_RUE_D,t.INSEE_D,t.LARGEUR,t.GEOMETRY, t.CODE_SOUS_TRONCON);
COMMIT;
-- Résultat : 187 lignes fusionnées

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
                    INNER JOIN G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS_2 d ON d.id_troncon = c.fid_troncon
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
    )t
    ON(a.code_point = t.code_point AND a.code_voie = t.code_voie)
WHEN NOT MATCHED THEN
    INSERT(a.code_voie, a.code_point, a.nature, a.libelle, a.numero, a.repetition, a.cote, a.geometry)
    VALUES(t.code_voie, t.code_point, t.nature, t.libelle, t.numero, t.repetition, t.cote, t.geometry);
COMMIT;
-- Résultat : 290 191 seuils fusionnés
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
            INNER JOIN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS_2 d ON CAST(d.ID_TRONCON AS NUMBER(38,0)) = c.fid_troncon,
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
                    INNER JOIN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS_2 d ON CAST(d.ID_TRONCON AS NUMBER(38,0)) = c.fid_troncon AND d.insee_g = GET_CODE_INSEE_CONTAIN_POINT('TA_SEUIL', b.geom)
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
                    G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS_2
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
                    INNER JOIN G_BASE_VOIE.TA_VOIE_LITTERALIS f ON f.id_voie = e.fid_voie
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
                        INNER JOIN G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS_2 d ON d.id_troncon = c.fid_troncon
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
                    G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS_2      
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
                    INNER JOIN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS_2 d ON CAST(d.ID_TRONCON AS NUMBER(38,0)) = c.fid_troncon,
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
------------------------------------------------------------------------------------------------------------------------------

-- 2.6. Insertion des seuils restants dans TEMP_ADRESSE_AUTRES_LITTERALIS
-- Même remarque qu'au point 2.5, normalement ce code ne devrait pas être nécessaire, mais sans lui il manque des seuils (et le résultat qu'il renvoie est correct)

MERGE INTO G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS_2 a
USING(
    WITH
        C_0 AS(
                SELECT
                    code_point
                FROM
                    G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS_2
                UNION ALL
                SELECT
                    code_point
                FROM
                    G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS_2
                UNION ALL
                SELECT
                    code_point
                FROM
                    G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS_2
                UNION ALL
                SELECT
                    code_point
                FROM
                    G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS_2      
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
                INNER JOIN G_BASE_VOIE.TA_VOIE_LITTERALIS f ON f.id_voie = e.fid_voie                       
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
                INNER JOIN G_BASE_VOIE.VM_TRONCON_LITTERALIS_2 f ON CAST(f.code_rue_g AS NUMBER(38,0))= e.fid_voie
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