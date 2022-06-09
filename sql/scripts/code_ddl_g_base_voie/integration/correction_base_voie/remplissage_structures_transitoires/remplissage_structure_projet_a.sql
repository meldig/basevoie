-- Insertion des pnoms des agents
INSERT INTO G_BASE_VOIE.TEMP_A_AGENT(numero_agent, pnom, validite)
    SELECT numero_agent, pnom, validite FROM TEMP_AGENT;
-- Résultat : 5 lignes insérées.

-- Insertion des types de voie
MERGE INTO G_BASE_VOIE.TEMP_A_TYPE_VOIE a
    USING(
        SELECT
            CCODTVO AS code_type_voie,
            LITYVOIE AS libelle
        FROM
            G_BASE_VOIE.TEMP_TYPEVOIE
        WHERE
            LITYVOIE IS NOT NULL
    )t
    ON(a.code_type_voie = t.code_type_voie AND a.libelle = t.libelle)
WHEN NOT MATCHED THEN
    INSERT(a.code_type_voie, a.libelle)
    VALUES(t.code_type_voie, t.libelle);
-- Résultat : 57 lignes fusionnées.

-- Insertion des valeurs de latéralité des voies dans TEMP_A_LIBELLE
INSERT INTO G_BASE_VOIE.TEMP_A_LIBELLE(libelle_court, libelle_long)
SELECT
    'droit' AS libelle_court,
    'côté droit de la voie physique' AS libelle_long
FROM
    DUAL
UNION ALL
SELECT
    'gauche' AS libelle_court,
    'côté gauche de la voie physique' AS libelle_long
FROM
    DUAL
UNION ALL
SELECT
    'les deux côtés' AS libelle_court,
    'les deux côtés de la voie physique' AS libelle_long
FROM
    DUAL;
-- Résultat : 3 lignes fusionnées

-- Insertion des identifiants des voies dans TEMP_A_VOIE_PHYSIQUE
-- Insertion des voies physiques en doublons (pour chaque couple de doublon on n'insère qu'une seule voie
MERGE INTO G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE a
    USING(
        SELECT -- Pour les voies en doublon de géométrie, on ne garde que la voie disposant de l'identifiant minimum
            CAST(a.id_voie AS NUMBER(38,0)) AS id_voie
        FROM
            G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a,
            G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE b 
        WHERE
            a.id_voie < b.id_voie
            AND SDO_EQUAL(a.geom, b.geom) = 'TRUE'
        -- Résultat : 53 voies
    )t
ON(a.objectid = t.id_voie)
WHEN NOT MATCHED THEN
    INSERT(a.objectid)
    VALUES(id_voie);
-- Résultat : 53 lignes fusionnées.

-- Insertion des voies physiques uniques
MERGE INTO G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE a
    USING(
        WITH
            C_1 AS(
                SELECT -- sélection de l'identifiant minimum pour chaque doublons de voies
                    a.id_voie AS id_voie
                FROM
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a,
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE b 
                WHERE
                    a.id_voie < b.id_voie
                    AND SDO_EQUAL(a.geom, b.geom) = 'TRUE'
                UNION ALL
                SELECT -- sélection de l'identifiant maximum pour chaque doublons de voies
                    b.id_voie AS id_voie
                FROM
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a,
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE b 
                WHERE
                    a.id_voie < b.id_voie
                    AND SDO_EQUAL(a.geom, b.geom) = 'TRUE'
                -- Résultat : 106 voies
            )
            
            SELECT
                CAST(id_voie AS NUMBER(38,0)) AS id_voie
            FROM
                G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE
            WHERE
                id_voie NOT IN(SELECT id_voie FROM C_1)
    )t
ON(a.objectid = t.id_voie)
WHEN NOT MATCHED THEN
    INSERT(a.objectid)
    VALUES(id_voie);
-- Résultat : 22 059 lignes fusionnées.

-- Insertion des libellés des voies en doublons de géométrie
MERGE INTO G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE a
    USING(
        WITH
            C_1 AS(
                SELECT -- Pour les voies en doublon de géométrie, on ne garde que la voie disposant de l'identifiant minimum
                    a.id_voie AS id_voie,
                    a.geom
                FROM
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a,
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE b 
                WHERE
                    a.id_voie < b.id_voie
                    AND SDO_EQUAL(a.geom, b.geom) = 'TRUE'
            )
            
            SELECT DISTINCT
                a.id_voie AS objectid,
                b.cnominus AS libelle_voie,
                b.cinfos AS complement_nom_voie,
                a.code_insee,
                c.objectid AS fid_type_voie,
                d.id_voie AS fid_voie_physique,
                e.numero_agent AS fid_pnom_saisie,
                e.numero_agent AS fid_pnom_modification,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification
            FROM
                G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a
                INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccomvoi = a.id_voie
                INNER JOIN G_BASE_VOIE.TEMP_A_TYPE_VOIE c ON c.code_type_voie = b.ccodtvo,
                C_1 d,
                G_BASE_VOIE.TEMP_A_AGENT e
            WHERE
                SDO_EQUAL(a.geom, d.geom) = 'TRUE'
                AND e.pnom = 'import_donnees'
                AND a.id_voie IN(99004, 3503380, 3560237, 3559121, 3503180, 3600840, 5990510, 6110390, 1939071, 6029100, 1430360, 2529007, 3320060, 3601220, 520080, 90299, 6461183, 6502690, 5995430, 1439083, 1739021, 2990086, 3469061, 3551330, 2860870, 3782070, 3681460, 3780330, 4870090, 5070070, 4210050, 6439004, 3789288, 6480011, 6480320, 5539009, 3209014, 449036, 1960053, 2509041, 3179061, 3569025, 3781455, 3889023, 4570236, 3670725, 4570360, 1631270, 1631305, 5850585, 1460120, 99294, 3503375, 4109016, 900510, 4779044, 3500495, 6460080, 6461195, 6480015, 5850040, 3039000, 1430214, 3289399, 3600370, 3320370, 3329010, 3679001, 4700153, 1529110, 4829031, 5124552, 6029002, 6461054, 1289003, 1969029, 2570276, 3170440, 3670767, 3681700, 2819017, 4210640, 3710057, 1631341, 3509252, 5980305, 1529422, 6489112, 5859036, 2509042, 880311, 2529011, 2509406, 2989086, 90202, 3039032, 95712, 3469046, 3501895, 3782043, 4100840, 3501483, 5279049, 139011, 6539092, 6589008)
                -- la condition ci-dessus n'est NORMALEMENT pas nécessaire, mais sans ça la requête tourne sans jamais aboutir
    )t
ON(a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique AND a.fid_type_voie = t.fid_type_voie)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.libelle_voie, a.complement_nom_voie, a.code_insee, a.fid_type_voie, a.fid_voie_physique, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification)
    VALUES(t.objectid, t.libelle_voie, t.complement_nom_voie, t.code_insee, t.fid_type_voie, t.fid_voie_physique, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification);
COMMIT;
-- Résultat : 106 lignes fusionnées.

-- Insertion des voies uniques
MERGE INTO G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE a
    USING (
        WITH
            C_1 AS (-- Sélection des tronçons affectés à une et une seule voie
                SELECT
                    a.cnumtrc
                FROM
                    G_BASE_VOIE.TEMP_VOIECVT a
                    INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.cnumtrc
                    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = a.ccomvoi
                WHERE
                    a.cvalide = 'V'
                    AND b.cdvaltro = 'V'
                    AND c.cdvalvoi = 'V'
                GROUP BY
                    a.cnumtrc
                HAVING
                    COUNT(a.cnumtrc) = 1
            )
            
            SELECT DISTINCT -- Sélection de toutes les libellés des voies auxquelles un tronçon est affecté une et une seule fois
                CAST(c.ccomvoi AS NUMBER(38,0)) AS objectid,
                c.cnominus AS libelle_voie,
                c.cinfos AS complement_nom_voie,
                CASE
                        WHEN LENGTH(b.cnumcom) = 1
                            THEN '5900' || b.cnumcom
                        WHEN LENGTH(b.cnumcom) = 2
                            THEN '590' || b.cnumcom
                        WHEN LENGTH(b.cnumcom) = 3
                            THEN '59' || b.cnumcom
                    END AS code_insee,
                f.objectid AS fid_lateralite,
                e.objectid AS fid_type_voie,
                CAST(d.objectid AS NUMBER(38,0)) AS fid_voie_physique,
                d.numero_agent AS fid_pnom_saisie,
                d.numero_agent AS fid_pnom_modification,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification
            FROM
                C_1 a
                INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
                INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi
                INNER JOIN G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE d ON d.objectid = CAST(c.ccomvoi AS NUMBER(38,0))
                INNER JOIN G_BASE_VOIE.TEMP_A_TYPE_VOIE e ON e.code_type_voie = c.ccodtvo,
                G_BASE_VOIE.TEMP_A_AGENT d,
                G_BASE_VOIE.TEMP_A_libelle f
            WHERE
                b.cvalide = 'V'
                AND c.cdvalvoi = 'V'
                AND d.pnom = 'import_donnees'
                AND f.libelle_court = 'les deux côtés'
    )t
ON(a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique AND a.fid_type_voie = t.fid_type_voie)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.libelle_voie, a.complement_nom_voie, a.code_insee, a.fid_lateralite, a.fid_type_voie, a.fid_voie_physique, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification)
    VALUES(t.objectid, t.libelle_voie, t.complement_nom_voie, t.code_insee, t.fid_lateralite, t.fid_type_voie, t.fid_voie_physique, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification);
COMMIT;        
-- Résultat : 21 866 lignes fusionnées.

DELETE FROM G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE;

-- Insertion des voies restantes, c'est-à-dire des voies disposant de tronçons affectés à plusieurs voie dont la géométrie n'est pas identique
MERGE INTO G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE a
    USING (
        SELECT
            CAST(a.id_voie AS NUMBER(38,0)) AS objectid,
            b.cnominus AS libelle_voie,
            b.cinfos AS complement_nom_voie,
            a.code_insee,
            c.objectid AS fid_type_voie,
            CAST(a.id_voie AS NUMBER(38,0)) AS fid_voie_physique,
            d.numero_agent AS fid_pnom_saisie,
            d.numero_agent AS fid_pnom_modification,
            TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
            TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification
        FROM
            G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccomvoi = CAST(a.id_voie AS NUMBER(38,0))
            INNER JOIN G_BASE_VOIE.TEMP_A_TYPE_VOIE c ON c.code_type_voie = b.ccodtvo,
            G_BASE_VOIE.TEMP_A_AGENT d
        WHERE
            a.id_voie NOT IN(SELECT objectid FROM TEMP_A_VOIE_ADMINISTRATIVE)
            AND d.pnom = 'import_donnees'
    )t
ON(a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique AND a.fid_type_voie = t.fid_type_voie)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.libelle_voie, a.complement_nom_voie, a.code_insee, a.fid_type_voie, a.fid_voie_physique, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification)
    VALUES(t.objectid, t.libelle_voie, t.complement_nom_voie, t.code_insee, t.fid_type_voie, t.fid_voie_physique, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification);
COMMIT;
-- Résultat : 193 lignes fusionnées.

-- Insertion des tronçons affectés à une et une seule voie
/*MERGE INTO G_BASE_VOIE.TEMP_A_TRONCON a
    USING (
        WITH
            C_1 AS(
                SELECT -- Sélection des tronçons affectés à une et une seule voie
                    a.cnumtrc AS objectid            
                FROM
                    G_BASE_VOIE.TEMP_ILTATRC a
                    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
                WHERE
                    a.cdvaltro = 'V'
                    AND b.cvalide = 'V'
                GROUP BY
                    a.cnumtrc
                HAVING
                    COUNT(a.cnumtrc) = 1
            )

        SELECT
            CAST(a.objectid AS NUMBER(38,0)) AS objectid,
            b.ora_geometry AS geom,
            TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
            e.numero_agent AS fid_pnom_saisie,
            TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification,
            e.numero_agent AS fid_pnom_modification,
            CAST(d.objectid AS NUMBER(38,0)) AS fid_voie_physique
        FROM
            C_1 a
            INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT c ON c.cnumtrc = b.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE d ON d.objectid = CAST(c.ccomvoi AS NUMBER(38,0)),
            G_BASE_VOIE.TEMP_A_AGENT e
        WHERE
            e.pnom = 'import_donnees'
    )t
ON(a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique)
WHEN NOT MATCHED THEN
INSERT(a.objectid, a.geom, a.date_saisie, a.fid_pnom_saisie, a.date_modification, a.fid_pnom_modification, a.fid_voie_physique)
VALUES(t.objectid, t.geom, t.date_saisie, t.fid_pnom_saisie, t.date_modification, t.fid_pnom_modification, t.fid_voie_physique);*/
-- Résultat : 49 451 lignes fusionnées.

-- Insertion des tronçons affectés à plusieurs voies ayant la même géométrie
MERGE INTO G_BASE_VOIE.TEMP_A_TRONCON a
    USING(
        WITH
            C_1 AS(
                SELECT -- Pour les voies en doublon de géométrie, on ne garde que la voie disposant de l'identifiant minimum
                    a.id_voie AS id_voie,
                    a.geom
                FROM
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a,
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE b 
                WHERE
                    a.id_voie < b.id_voie
                    AND SDO_EQUAL(a.geom, b.geom) = 'TRUE'
            ),
            
            C_2 AS(
                SELECT DISTINCT
                    CAST(c.cnumtrc AS NUMBER(38,0)) AS objectid,
                    CAST(d.id_voie AS NUMBER(38,0)) AS fid_voie_physique,
                    e.numero_agent AS fid_pnom_saisie,
                    e.numero_agent AS fid_pnom_modification,
                    TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
                    TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification
                FROM
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a
                    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON CAST(b.ccomvoi AS NUMBER(38,0)) = a.id_voie
                    INNER JOIN G_BASE_VOIE.TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc,
                    C_1 d,
                    G_BASE_VOIE.TEMP_A_AGENT e
                WHERE
                    c.cdvaltro = 'V'
                    AND b.cvalide = 'V'
                    AND e.pnom = 'import_donnees'
                    AND SDO_EQUAL(a.geom, d.geom) = 'TRUE'
            )
            
            SELECT
                a.*,
                b.ora_geometry AS geom
            FROM
                C_2 a
                INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid
            WHERE
                b.cdvaltro = 'V'
    )t
ON(a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.geom, a.date_saisie, a.fid_pnom_saisie, a.date_modification, a.fid_pnom_modification, a.fid_voie_physique)
    VALUES(t.objectid, t.geom, t.date_saisie, t.fid_pnom_saisie, t.date_modification, t.fid_pnom_modification, t.fid_voie_physique);
COMMIT;
-- Résultat : 166 lignes fusionnées.

DELETE FROM TEMP_A_TRONCON;

-- Insertion des tronçons affectés à plusieurs voies ayant des géométries différentes
/*MERGE INTO G_BASE_VOIE.TEMP_A_TRONCON a
    USING(
        WITH
            C_1 AS(
                SELECT -- Pour les voies en doublon de géométrie, on ne garde que la voie disposant de l'identifiant minimum
                    a.id_voie AS id_voie,
                    a.geom
                FROM
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a,
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE b 
                WHERE
                    a.id_voie < b.id_voie
                    AND SDO_EQUAL(a.geom, b.geom) <> 'TRUE'
            ),
            
            C_2 AS(
                SELECT DISTINCT
                    CAST(c.cnumtrc AS NUMBER(38,0)) AS objectid,
                    CAST(d.id_voie AS NUMBER(38,0)) AS fid_voie_physique,
                    e.numero_agent AS fid_pnom_saisie,
                    e.numero_agent AS fid_pnom_modification,
                    TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
                    TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification
                FROM
                    G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a
                    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON CAST(b.ccomvoi AS NUMBER(38,0)) = a.id_voie
                    INNER JOIN G_BASE_VOIE.TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc,
                    C_1 d,
                    G_BASE_VOIE.TEMP_A_AGENT e
                WHERE
                    c.cdvaltro = 'V'
                    AND b.cvalide = 'V'
                    AND e.pnom = 'import_donnees'
                    AND SDO_EQUAL(a.geom, d.geom) <> 'TRUE'
            )
            
            SELECT
                a.*,
                b.ora_geometry AS geom
            FROM
                C_2 a
                INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid
            WHERE
                b.cdvaltro = 'V'
    )t
ON(a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique)
WHEN NOT MATCHED THEN
    INSERT(a.objectid, a.geom, a.date_saisie, a.fid_pnom_saisie, a.date_modification, a.fid_pnom_modification, a.fid_voie_physique)
    VALUES(t.objectid, t.geom, t.date_saisie, t.fid_pnom_saisie, t.date_modification, t.fid_pnom_modification, t.fid_voie_physique);
COMMIT;*/
-- Résultat :  lignes fusionnées.

-- Insertion du sens pour les tronçons sauf pour 10 tronçons problématiques
MERGE INTO G_BASE_VOIE.TEMP_A_TRONCON a
    USING(
        SELECT DISTINCT
            a.objectid,
            a.fid_voie_physique,
            b.ccodstr AS sens
        FROM
            G_BASE_VOIE.TEMP_A_TRONCON a
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON CAST(b.ccomvoi AS NUMBER(38,0)) = a.fid_voie_physique --AND b.cnumtrc = a.objectid
        WHERE
            b.cvalide = 'V'
            AND a.objectid NOT IN(20,54,58,61,71,72,73,74,78,79,186,220,224,227,237,238,239,240,244,245)
    )t
ON (a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique)
WHEN MATCHED THEN
    UPDATE SET a.sens = t.sens;
COMMIT;
-- Résultat : 156 lignes fusionnées.

-- Insertion du sens pour les 10 tronçons problématiques
MERGE INTO G_BASE_VOIE.TEMP_A_TRONCON a
    USING(
        SELECT DISTINCT
            a.objectid,
            a.fid_voie_physique,
            b.ccomvoi,
            '-' AS sens
        FROM
            G_BASE_VOIE.TEMP_A_TRONCON a
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON CAST(b.ccomvoi AS NUMBER(38,0)) = a.fid_voie_physique
        WHERE
            b.cvalide = 'V'
            AND a.objectid IN(20,54,58,61,71,72,73,74,78,79,186,220,224,227,237,238,239,240,244,245)
    )t
ON (a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique)
WHEN MATCHED THEN
    UPDATE SET a.sens = t.sens;
COMMIT;
-- Résultat : 10 lignes fusionnées

-- Correction du sens de la géométrie des tronçons : si le sens est "-" alors ses startpoint et endpoint seront inversés, sinon ils resterons tels quels.
/*MERGE INTO G_BASE_VOIE.TEMP_A_TRONCON a
    USING(
        SELECT
            a.objectid,
            a.fid_voie_physique,
            CASE
                WHEN a.sens = '-'
                    THEN '+'
                ELSE
                    a.sens
            END AS sens,
            CASE
                WHEN a.sens = '-'
                    THEN SDO_LRS.REVERSE_GEOMETRY(a.geom, m.diminfo)
                ELSE
                    a.geom
            END AS geom
        FROM
            G_BASE_VOIE.TEMP_A_TRONCON a,
            USER_SDO_GEOM_METADATA m
        WHERE
            m.table_name = 'TEMP_A_TRONCON'
    )t
ON (a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique)
WHEN MATCHED THEN
    UPDATE SET a.sens = t.sens, a.geom = t.geom;
COMMIT;*/
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--------------------------------------------- Vérification import des données ------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- Décompte du nombre de voies présentes dans la structure d'import
SELECT
    COUNT(DISTINCT a.ccomvoi)
FROM
    TEMP_VOIEVOI a
    INNER JOIN TEMP_TYPEVOIE b ON b.ccodtvo = a.ccodtvo
    INNER JOIN TEMP_VOIECVT c ON c.ccomvoi = a.ccomvoi
WHERE
    b.lityvoie IS NOT NULL
    AND a.cdvalvoi = 'V'
    AND c.cvalide = 'V';
-- Résultat : 22165 voies

-- Décompte du nombre de libellés de voies
SELECT
    COUNT(objectid)
FROM
    TEMP_A_VOIE_ADMINISTRATIVE;
-- Résultat : 22158 libellés de voies

-- Décompte du nombre de voies présentes dans TEMP_A_TRONCON.FID_VOIE. Ces voies correspondent à celles pour lesquelles un tronçon affecté à une et une seule voie
SELECT
    COUNT(DISTINCT fid_voie_physique)
FROM
    G_BASE_VOIE.TEMP_A_TRONCON;
-- Résultat : 21860 voies distinctes (1 de plus ?)

-- Décompte du nombre de tronçons associés à plusieurs voies ayant la même géométrie
WITH
    C_1 AS(
        SELECT -- Pour les voies en doublon de géométrie, on ne garde que la voie disposant de l'identifiant minimum
            a.id_voie AS id_voie,
            a.geom
        FROM
            G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a,
            G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE b 
        WHERE
            a.id_voie < b.id_voie
            AND SDO_EQUAL(a.geom, b.geom) = 'TRUE'
    )
    
    SELECT
        COUNT(DISTINCT c.cnumtrc)
    FROM
        G_BASE_VOIE.VM_TEMP_IMPORT_VOIE_AGREGEE a
        INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.ccomvoi = a.id_voie
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc,
        C_1 d
    WHERE
        b.cvalide = 'V'
        AND c.cdvaltro = 'V'
        AND SDO_EQUAL(a.geom, d.geom) = 'TRUE';
-- Résultat : 166 tronçons

-- Décompte du nombre de tronçons valides affectés à des voies valides dans l'ancienne structure
SELECT
    COUNT(DISTINCT a.cnumtrc)
FROM
    G_BASE_VOIE.TEMP_ILTATRC a
    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi
    INNER JOIN G_BASE_VOIE.TEMP_TYPEVOIE d ON d.ccodtvo = c.ccodtvo
WHERE
    a.cdvaltro = 'V'
    AND b.cvalide = 'V'
    AND c.cdvalvoi = 'V'
    AND d.lityvoie IS NOT NULL;
-- Résultat : 49 692 tronçons

-- Décompte du nombre de tronçons dans la nouvelle structure
SELECT
    COUNT(objectid)
FROM
    TEMP_A_TRONCON;
-- Résultat : 51283 tronçons

SELECT
    a.*
FROM
    G_BASE_VOIE.TEMP_ILTATRC a
    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi
    INNER JOIN G_BASE_VOIE.TEMP_TYPEVOIE d ON d.ccodtvo = c.ccodtvo
WHERE
    a.cdvaltro = 'V'
    AND b.cvalide = 'V'
    AND c.cdvalvoi = 'V'
    AND d.lityvoie IS NOT NULL
    AND a.cnumtrc NOT IN(SELECT objectid FROM TEMP_A_TRONCON)
ORDER BY
    a.cnumtrc;
    
SELECT objectid
FROM
    TEMP_A_TRONCON
GROUP BY
    objectid
HAVING
    COUNT(objectid) > 1;
    
MERGE INTO G_BASE_VOIE.TEMP_A_TRONCON a
    USING(
        WITH
            C_1 AS(-- Sélection des tronçons pas encore insérés dans les tables de transition
                SELECT
                    a.*,
                    b.ccodstr,
                    c.ccomvoi
                FROM
                    G_BASE_VOIE.TEMP_ILTATRC a
                    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
                    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi
                    INNER JOIN G_BASE_VOIE.TEMP_TYPEVOIE d ON d.ccodtvo = c.ccodtvo
                WHERE
                    a.cdvaltro = 'V'
                    AND b.cvalide = 'V'
                    AND c.cdvalvoi = 'V'
                    AND d.lityvoie IS NOT NULL
                    AND a.cnumtrc NOT IN(SELECT objectid FROM TEMP_A_TRONCON)
            )
            
            SELECT
                a.cnumtrc AS objectid,
                a.ccodstr AS sens,
                c.objectid AS fid_voie_physique,
                b.objectid AS id_voie_administrative,
                d.numero_agent AS fid_pnom_saisie,
                d.numero_agent AS fid_pnom_modification,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
                TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification,
                a.ora_geometry AS geom
            FROM
                C_1 a
                INNER JOIN G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE b ON b.objectid = a.ccomvoi
                INNER JOIN G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE c ON c.objectid = b.fid_voie_physique,
                G_BASE_VOIE.TEMP_A_AGENT d
    )t
ON(a.objectid = t.objectid AND a.fid_voie_physique = t.fid_voie_physique)
WHEN NOT MATCHED THEN
INSERT(a.objectid, a.geom, a.date_saisie, a.fid_pnom_saisie, a.date_modification, a.fid_pnom_modification, a.fid_voie_physique)
VALUES(t.objectid, t.geom, t.date_saisie, t.fid_pnom_saisie, t.date_modification, t.fid_pnom_modification, t.fid_voie_physique);
        