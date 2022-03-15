/*
Requ�tes de v�rification des donn�es � donner pour LITTERALIS
*/

-- 1. Les Tron�ons
---- 1.1. S�lection des tron�ons en doublons
---- 1.2. S�lection des tron�ons affect�s � plusieurs voies
---- 1.3. S�lection des doublons absolus
---- 1.4. V�rification que chaque tron�on dispose d'une domanialit�
---- 1.5. V�rification qu'aucune erreur ne se trouve dans les champs des codes INSEE
-- 2. Les Adresses
---- 2.1. S�lection des adresses en doublons
---- 2.2. S�lection des adresses affect�es � plusieurs voies
---- 2.3. S�lection des tron�ons pr�sents dans VM_ADRESSE_LITTERALIS_V2 et absents de VM_TRONCON_LITTERALIS
---- 2.4. S�lection des tron�ons virtuels pr�sents dans VM_ADRESSE_LITTERALIS_V2
---- 2.5. S�lection des doublons code_point, code_voie, libelle

-- 0. D�compte du nombre de tron�ons
SELECT
    COUNT(DISTINCT code_tronc)
FROM
    G_BASE_VOIE.VM_TRONCON_LITTERALIS_V2;
-- R�sultat : 49014

-- D�compte du nombre de tron�on de TA_TRONCON
SELECT
    COUNT(a.objectid)
FROM
    G_BASE_VOIE.TA_TRONCON a
    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
    INNER JOIN G_BASE_VOIE.TA_VOIE e ON e.objectid = b.fid_voie
    INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE c ON c.id_voie = b.fid_voie
    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE d ON d.objectid = c.type_de_voie
WHERE
    d.libelle NOT IN('TYPE DE VOIE PR�SENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION', 'RIVIERE');
-- R�sultat : 50319

SELECT *
FROM
    VM_TRONCON_LITTERALIS_V2
WHERE
    nom_rue_g LIKE '%ANNEXE%';
    
-- 1. Les Tron�ons
-- 1.1. S�lection des tron�ons en doublons
WITH
    C_1 AS(
        SELECT
            code_tronc
        FROM
            VM_TRONCON_LITTERALIS_V2
        GROUP BY
            code_tronc
        HAVING
            COUNT(code_tronc) > 1
    )
    
    SELECT
        a.CODE_TRONC, 
        a.CLASSEMENT, 
        a.CODE_RUE_G, 
        a.NOM_RUE_G, 
        a.INSEE_G, 
        a.CODE_RUE_D, 
        a.NOM_RUE_D, 
        a.INSEE_D, 
        a.LARGEUR, 
        a.GEOMETRY
    FROM
        VM_TRONCON_LITTERALIS_V2 a
        INNER JOIN C_1 b ON b.code_tronc = a.code_tronc;
-- R�sultat : 0

-- 1.2. S�lection des tron�ons affect�s � plusieurs voies
SELECT
    a.code_tronc,
    COUNT(a.code_rue_g) AS nombre_objets
FROM
    VM_TRONCON_LITTERALIS_V2 a
GROUP BY
    a.code_tronc
HAVING
    COUNT(a.code_rue_g) > 1;
-- R�sultat : 0

-- 1.3. S�lection des tron�ons ayant la m�me g�om�trie, mais un identifiant diff�rent et �tant affect�s � la m�me voie, dans la m�me commune
SELECT
    a.code_tronc,
    b.code_tronc
FROM
    G_BASE_VOIE.VM_TRONCON_LITTERALIS_V2 a,
    G_BASE_VOIE.VM_TRONCON_LITTERALIS_V2 b
WHERE
    a.code_tronc <> b.code_tronc
    AND a.code_rue_g = b.code_rue_g
    AND a.insee_g = b.insee_g
    AND SDO_EQUAL(a.geometry, b.geometry) = 'TRUE';
-- Le r�sultat est non null, ce qui est normal

-- 1.4. V�rification que chaque tron�on dispose d'une domanialit�
SELECT
    a.code_tronc,
    COUNT(a.classement) AS nombre_objets
FROM
    VM_TRONCON_LITTERALIS_V2 a
GROUP BY
    a.code_tronc
HAVING
    COUNT(a.classement) > 1;

-- 1.5. V�rification qu'aucune erreur ne se trouve dans les champs des codes INSEE
SELECT
    code_tronc,
    INSEE_D,
    INSEE_G
FROM
    VM_TRONCON_LITTERALIS_V2
WHERE
    INSEE_D IS NULL
    AND INSEE_G IS NULL
    OR INSEE_D = 'error'
    AND INSEE_G = 'error';
-- R�sultat : 0
 
-- 1.7. V�rification qu'aucune voie ne dispose du m�me nom sur la m�me commune, mais avec des identifiants diff�rents
SELECT
    a.nom_rue_g,
    a.insee_g
FROM
    G_BASE_VOIE.VM_TRONCON_LITTERALIS_V2 a
GROUP BY
    a.nom_rue_g,
    a.insee_g
HAVING
    COUNT(a.nom_rue_g) > 1
    AND COUNT(a.insee_g) > 1
    AND COUNT(DISTINCT a.code_rue_g) > 1;
-- R�sultat : 138 tron�ons (ATTENTION aux voies principales/secondaires)
    
SELECT *
FROM
    G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS
WHERE
    id_troncon IN(
        6316,26174,5575,81736,
        11562,68873,4743,4822,
        14544,6202,6203,71211,
        71091,71221,11200,11202,
        11203,71087,71088,6181,
        6184,6190,6191,6187,
        6188,4821,35876,35706,
        71093,56486,56489,63580,
        70404,4860,35400,5115,
        5116,35395,35396,9209,
        35399,84904,32762
    );


------------------------------------------------------------------------------------------------------------------
-- S�lection des tron�ons absents de VM_TRONCON_LITTERALIS_V2
WITH
    C_1 AS(-- S�lection des tron�ons pr�sents des les tables temporaires litteralis
    SELECT
        id_troncon
    FROM
        G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS
    UNION ALL
    SELECT
        id_troncon
    FROM
        G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS
    UNION ALL
    SELECT
        id_troncon
    FROM
        G_BASE_VOIE.TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS
    )

SELECT
    a.objectid
FROM
    G_BASE_VOIE.TA_TRONCON a
    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
    INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE c ON c.id_voie = b.fid_voie
WHERE
    a.objectid NOT IN(SELECT id_troncon FROM C_1);
    
------------------------------------------------------------------------------------------------------------------
-- 2. Les Adresses  
--2.0. V�rification du nombre de seuils
SELECT
    COUNT(code_point)
FROM
    G_BASE_VOIE.VM_ADRESSE_LITTERALIS_V2;
-- R�sultat : 346177

SELECT
    COUNT(objectid)
FROM
    G_BASE_VOIE.TA_SEUIL;
-- R�sultat : 349807

-- 2.1. S�lection des adresses en doublons
SELECT
    code_point
FROM
    VM_ADRESSE_LITTERALIS_V2
GROUP BY
    code_point
HAVING
    COUNT(code_point)>1;

-- 2.2. S�lection des adresses affect�es � plusieurs voies
SELECT
    a.code_point,
    COUNT(a.code_voie)
FROM
    VM_ADRESSE_LITTERALIS_V2 a
GROUP BY
    a.code_point
HAVING
    COUNT(a.code_voie) >1;

-- 2.3. S�lection des tron�ons virtuels pr�sents dans VM_ADRESSE_LITTERALIS_V2 et absents de VM_TRONCON_LITTERALIS_3
SELECT
    a.code_voie
FROM
    VM_ADRESSE_LITTERALIS_V2 a
WHERE
    a.code_voie NOT IN(SELECT code_rue_g FROM VM_TRONCON_LITTERALIS_V2);

-- 2.4. S�lection des tron�ons virtuels pr�sents dans VM_ADRESSE_LITTERALIS_V2
SELECT DISTINCT
    a.code_voie,
    b.code_tronc
FROM
    G_BASE_VOIE.VM_ADRESSE_LITTERALIS_V2 a
    INNER JOIN G_BASE_VOIE.VM_TRONCON_LITTERALIS_V2 b ON b.code_rue_g = a.code_voie
WHERE
    b.code_tronc NOT IN(SELECT CAST(objectid AS VARCHAR2(254 BYTE)) FROM G_BASE_VOIE.TA_TRONCON)
ORDER BY
    a.code_voie;

-- 2.6.  S�lection des doublons code_voie, nature, numero, pour un champ repetition NULL
WITH
    C_1 AS(
        SELECT
            code_voie, 
            nature, 
            numero,
            repetition
        FROM
            VM_ADRESSE_LITTERALIS_V2
        WHERE
            repetition IS NULL
        GROUP BY
            code_voie, 
            nature, 
            numero,
            repetition
        HAVING
            COUNT(code_voie) > 1
            AND COUNT(nature) > 1
            AND COUNT(numero) > 1
            AND COUNT(repetition) > 1
    )
    
    SELECT
        b.code_point,
        a.code_voie, 
        a.nature, 
        a.numero, 
        a.repetition
    FROM
        C_1 a,
        VM_ADRESSE_LITTERALIS_V2 b
    WHERE
        a.code_voie = b.code_voie
        AND a.nature = b.nature
        AND a.numero = b.numero
        AND a.repetition = b.repetition
    ORDER BY
        a.code_voie, 
        a.nature, 
        a.numero, 
        a.repetition;
        
-- 2.6.  S�lection des doublons code_voie, nature, numero, pour un champ repetition NON NULL
WITH
    C_1 AS(
        SELECT
            code_voie, 
            nature, 
            numero,
            repetition
        FROM
            VM_ADRESSE_LITTERALIS_V2
        WHERE
            repetition IS NOT NULL
        GROUP BY
            code_voie, 
            nature, 
            numero,
            repetition
        HAVING
            COUNT(code_voie) > 1
            AND COUNT(nature) > 1
            AND COUNT(numero) > 1
            AND COUNT(repetition) > 1
    )
    
    SELECT
        b.code_point,
        a.code_voie, 
        a.nature, 
        a.numero, 
        a.repetition
    FROM
        C_1 a,
        VM_ADRESSE_LITTERALIS_V2 b
    WHERE
        a.code_voie = b.code_voie
        AND a.nature = b.nature
        AND a.numero = b.numero
        AND a.repetition = b.repetition
    ORDER BY
        a.code_voie, 
        a.nature, 
        a.numero, 
        a.repetition;
-- R�sultat : 10 seuils

-- 2.7. Recherche de la source de l'erreur du point 2.6.
-- TEMP_ADRESSE_CORRECTE_LITTERALIS
WITH
    C_1 AS(
        SELECT
            code_voie, 
            nature, 
            numero, 
            repetition
        FROM
            TEMP_ADRESSE_CORRECTE_LITTERALIS
        GROUP BY
            code_voie, 
            nature, 
            numero, 
            repetition
        HAVING
            COUNT(code_voie) > 1
            AND COUNT(nature) > 1
            AND COUNT(numero) > 1
            AND COUNT(repetition) > 1
    )
    
    SELECT
        b.code_point,
        a.code_voie, 
        a.nature, 
        a.numero, 
        a.repetition
    FROM
        C_1 a,
        TEMP_ADRESSE_CORRECTE_LITTERALIS b
    WHERE
        a.code_voie = b.code_voie
        AND a.nature = b.nature
        AND a.numero = b.numero
        AND a.repetition = b.repetition
    ORDER BY
        a.code_voie, 
        a.nature, 
        a.numero, 
        a.repetition;
-- R�sultat : 6 lignes
-------------------------------------------           
-- TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS
WITH
    C_1 AS(
        SELECT
            code_voie, 
            nature, 
            numero, 
            repetition
        FROM
            TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS
        GROUP BY
            code_voie, 
            nature, 
            numero, 
            repetition
        HAVING
            COUNT(code_voie) > 1
            AND COUNT(nature) > 1
            AND COUNT(numero) > 1
            AND COUNT(repetition) > 1
    )
    
    SELECT
        b.code_point,
        a.code_voie, 
        a.nature, 
        a.numero, 
        a.repetition
    FROM
        C_1 a,
        TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS b
    WHERE
        a.code_voie = b.code_voie
        AND a.nature = b.nature
        AND a.numero = b.numero
        AND a.repetition = b.repetition
    ORDER BY
        a.code_voie, 
        a.nature, 
        a.numero, 
        a.repetition;
-- R�sultat : 0 lignes
-------------------------------------------        
-- TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS
WITH
    C_1 AS(
        SELECT
            code_voie, 
            nature, 
            numero, 
            repetition
        FROM
            TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS
        GROUP BY
            code_voie, 
            nature, 
            numero, 
            repetition
        HAVING
            COUNT(code_voie) > 1
            AND COUNT(nature) > 1
            AND COUNT(numero) > 1
            AND COUNT(repetition) > 1
    )
    
    SELECT
        b.code_point,
        a.code_voie, 
        a.nature, 
        a.numero, 
        a.repetition
    FROM
        C_1 a,
        TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS b
    WHERE
        a.code_voie = b.code_voie
        AND a.nature = b.nature
        AND a.numero = b.numero
        AND a.repetition = b.repetition
    ORDER BY
        a.code_voie, 
        a.nature, 
        a.numero, 
        a.repetition;
-- R�sultat : 0 lignes
-----------------------------------
-- TEMP_ADRESSE_AUTRES_LITTERALIS
WITH
    C_1 AS(
        SELECT
            code_voie, 
            nature, 
            numero, 
            repetition
        FROM
            TEMP_ADRESSE_AUTRES_LITTERALIS
        GROUP BY
            code_voie, 
            nature, 
            numero, 
            repetition
        HAVING
            COUNT(code_voie) > 1
            AND COUNT(nature) > 1
            AND COUNT(numero) > 1
            AND COUNT(repetition) > 1
    )
    
    SELECT
        b.code_point,
        a.code_voie, 
        a.nature, 
        a.numero, 
        a.repetition
    FROM
        C_1 a,
        TEMP_ADRESSE_AUTRES_LITTERALIS b
    WHERE
        a.code_voie = b.code_voie
        AND a.nature = b.nature
        AND a.numero = b.numero
        AND a.repetition = b.repetition
    ORDER BY
        a.code_voie, 
        a.nature, 
        a.numero, 
        a.repetition;
-- R�sultat : 4 lignes

-- V�rification que les doublons de TEMP_ADRESSE_AUTRES_LITTERALIS sont bien parmis les erreurs relev�es par Sogelink
WITH
    C_1 AS(
        SELECT
            code_voie, 
            nature, 
            numero, 
            repetition
        FROM
            TEMP_ADRESSE_AUTRES_LITTERALIS
        GROUP BY
            code_voie, 
            nature, 
            numero, 
            repetition
        HAVING
            COUNT(code_voie) > 1
            AND COUNT(nature) > 1
            AND COUNT(numero) > 1
            AND COUNT(repetition) > 1
    )
    
    SELECT
        c.id_point AS id_point_litteralis,
        b.code_point AS id_point_adresse_autre,
        a.code_voie, 
        a.nature, 
        a.numero, 
        a.repetition,
        d.numero_parcelle,
        d.date_saisie,
        d.date_modification
        /*d.nparcelle,
        d.cdtsseuil AS date_saisie,
        d.cdtmseuil AS date_modification*/
    FROM
        C_1 a,
        TEMP_ADRESSE_AUTRES_LITTERALIS b
        LEFT JOIN TEMP_ERREUR_ADR_LITTERALIS c ON c.id_point = CAST(b.code_point AS NUMBER(38,0))
        --INNER JOIN TEMP_ILTASEU d ON d.idseui = c.id_point
        INNER JOIN TA_INFOS_SEUIL d ON d.objectid = c.id_point
    WHERE
        a.code_voie = b.code_voie
        AND a.nature = b.nature
        AND a.numero = b.numero
        AND a.repetition = b.repetition
    ORDER BY
        a.code_voie, 
        a.nature, 
        a.numero, 
        a.repetition;
-- R�sultat : 0

-- 3. Cr�ation de vues statistiques
---- 3.1. Cr�ation de la vue regroupant le nombre d'erreurs et le nombre de tron�ons virtuels pr�sents dans VM_TRONCON_LITTERALIS 
CREATE OR REPLACE FORCE EDITIONABLE VIEW "G_BASE_VOIE"."V_ERREURS_STATS_TRONCON_LITTERALIS" ("IDENTIFIANT", "TYPE_ERREURS", "NOMBRE_OBJETS", 
 CONSTRAINT "V_ERREURS_STATS_TRONCON_LITTERALIS_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS 
WITH
    C_1 AS(-- S�lection des tron�ons en doublons
        SELECT
            code_tronc
        FROM
            VM_TRONCON_LITTERALIS_V2
        GROUP BY
            code_tronc
        HAVING
            COUNT(code_tronc) > 1
    ),
    
    C_2 AS(
        SELECT
            'Tron�ons en doublons' AS type_erreurs,
            COUNT(CODE_TRONC) AS nombre_objets
        FROM
            C_1
    ),

    C_3 AS(-- S�lection des tron�ons affect�s � plusieurs voies
        SELECT
            a.code_tronc,
            COUNT(a.code_rue_g) AS nombre_objets
        FROM
            VM_TRONCON_LITTERALIS_V2 a
        GROUP BY
            a.code_tronc
        HAVING
            COUNT(a.code_rue_g) > 1
    ),

    C_4 AS(
        SELECT
            'Tron�ons affect�s � plusieurs voies' AS type_erreurs,
            COUNT(CODE_TRONC) AS nombre_objets
        FROM
            C_3
    ),

    C_5 AS(--S�lection des doublons absolus
        SELECT
            a.CODE_TRONC, 
            a.CLASSEMENT, 
            a.CODE_RUE_G,
            a.INSEE_G,
            a.CODE_RUE_D,
            a.INSEE_D
        FROM
            VM_TRONCON_LITTERALIS_V2 a
        GROUP BY
            a.CODE_TRONC, 
            a.CLASSEMENT, 
            a.CODE_RUE_G,
            a.INSEE_G,
            a.CODE_RUE_D,
            a.INSEE_D
        HAVING
            COUNT(a.CODE_TRONC)>1
            AND COUNT(a.CLASSEMENT)>1
            AND COUNT(a.CODE_RUE_G)>1
            AND COUNT(a.INSEE_G)>1
            AND COUNT(a.CODE_RUE_D)>1
            AND COUNT(a.INSEE_D)>1
    ),
    
    C_6 AS(
        SELECT
            'Doublons absolus' AS type_erreurs,
            COUNT(a.CODE_TRONC) AS nombre_objets
        FROM
            C_5 a
    ),

    C_7 AS(-- V�rification que chaque tron�on dispose d'une domanialit�
        SELECT
            a.code_tronc,
            COUNT(a.classement) AS nombre_objets
        FROM
            VM_TRONCON_LITTERALIS_V2 a
        GROUP BY
            a.code_tronc
        HAVING
            COUNT(a.classement) > 1
    ),

    C_8 AS(
        SELECT
            'Tron�ons disposant de plusieurs domanialit�s' AS type_erreurs,
            COUNT(code_tronc) AS nombre_objets
        FROM
            C_7
    ),

    C_9 AS(-- V�rification qu'aucune erreur ne se trouve dans les champs des codes INSEE
        SELECT
            code_tronc
        FROM
            VM_TRONCON_LITTERALIS_V2
        WHERE
            INSEE_D IS NULL
            AND INSEE_G IS NULL
            OR INSEE_D = 'error'
            AND INSEE_G = 'error'
    ),

    C_10 AS(
        SELECT
            'Tron�ons disposant d''un code INSEE NULL ou en erreur' AS type_erreurs,
            COUNT(code_tronc) AS nombre_objets
        FROM
            C_9
    ),
    
    C_11 AS(-- S�lection de l'identifiant maximum des tron�ons
        SELECT
            MAX(a.objectid) AS max_code_troncon
        FROM
            G_BASE_VOIE.TA_TRONCON a
    ),
        
    C_12 AS(-- S�lection des tron�ons virtuels
        SELECT
            'Tron�ons virtuels (pour le cas o� un tron�on est affect� � plusieurs voies) ' AS type_erreurs,
            COUNT(a.code_tronc) as nombre_objets
        FROM
            G_BASE_VOIE.VM_TRONCON_LITTERALIS_V2 a,
            C_11 b
        WHERE
            TO_NUMBER(a.code_tronc) > b.max_code_troncon
        GROUP BY
            'Tron�ons virtuels (pour le cas o� un tron�on est affect� � plusieurs voies) '
    ),

    C_13 AS(-- S�lection du delta entre le nombre de tron�ons dans TA_TRONCON et dans VM_TRONCON_LITTERALIS_V2
        SELECT
            'Delta entre le nombre de tron�ons dans TA_TRONCON et dans VM_TRONCON_LITTERALIS_V2 ' AS type_erreurs,
            COUNT(a.objectid) as nombre_objets
        FROM
            G_BASE_VOIE.TA_TRONCON a
        WHERE
           a.objectid NOT IN(SELECT TO_NUMBER(code_tronc) FROM G_BASE_VOIE.VM_TRONCON_LITTERALIS_V2)
        GROUP BY
            'Delta entre le nombre de tron�ons dans TA_TRONCON et dans VM_TRONCON_LITTERALIS_V2 '
    ),
    
    
    C_18 AS(    
        SELECT
            type_erreurs,
            nombre_objets
        FROM
            C_2
        UNION ALL
        SELECT
            type_erreurs,
            nombre_objets
        FROM
            C_4
        UNION ALL
        SELECT
            type_erreurs,
            nombre_objets
        FROM
            C_6
        UNION ALL
        SELECT
            type_erreurs,
            nombre_objets
        FROM
            C_8
        UNION ALL
        SELECT
            type_erreurs,
            nombre_objets
        FROM
            C_10
        UNION ALL
        SELECT
            type_erreurs,
            nombre_objets
        FROM
            C_12
        UNION ALL
        SELECT
            type_erreurs,
            nombre_objets
        FROM
            C_13
    )

    SELECT
        rownum AS IDENTIFIANT,
        type_erreurs AS TYPE_ERREURS,
        nombre_objets AS NOMBRE_OBJETS
    FROM
        C_18;

COMMENT ON COLUMN "G_BASE_VOIE"."V_ERREURS_STATS_TRONCON_LITTERALIS"."IDENTIFIANT" IS 'Cl� primaire de la vue (sans aucune autre signification particuli�re).';
COMMENT ON COLUMN "G_BASE_VOIE"."V_ERREURS_STATS_TRONCON_LITTERALIS"."TYPE_ERREURS" IS 'Types d''erreurs relev�s dans VM_TRONCON_LITTERALIS_V2.';
COMMENT ON COLUMN "G_BASE_VOIE"."V_ERREURS_STATS_TRONCON_LITTERALIS"."NOMBRE_OBJETS" IS 'Nombre d''objets par types d''erreurs.';

--------------------------------------------------------------------------------------------------------------------------------
---- 3.2. Cr�ation de la vue regroupant le nombre d'erreurs et le nombre de voies virtuelles pr�sents dans VM_ADRESSES_LITTERALIS 
CREATE OR REPLACE FORCE EDITIONABLE VIEW "G_BASE_VOIE"."V_ERREURS_STATS_ADRESSE_LITTERALIS" ("IDENTIFIANT", "TYPE_ERREURS", "NOMBRE_OBJETS", 
     CONSTRAINT "V_ERREURS_STATS_ADRESSE_LITTERALIS_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS 
    WITH
        C_1 AS(--S�lection des adresses en doublons
            SELECT
                code_point
            FROM
                VM_ADRESSE_LITTERALIS_V2
            GROUP BY
                code_point
            HAVING
                COUNT(code_point)>1
        ),
    
        C_2 AS(
            SELECT
                'Adresses en doublons' AS type_erreurs,
                COUNT(code_point) AS nombre_objets
            FROM
                C_1
        ),
    
        C_3 AS(-- S�lection des adresses affect�es � plusieurs voies
            SELECT
                a.code_point
            FROM
                VM_ADRESSE_LITTERALIS_V2 a
            GROUP BY
                a.code_point
            HAVING
                COUNT(a.code_voie) >1
        ),
        
        C_4 AS(
            SELECT
                'Adresses affect�es � plusieurs voies' AS type_erreurs,
                COUNT(code_point) AS nombre_objets
            FROM
                C_3
        ),
        
        C_5 AS(-- S�lection des doublons code_point, code_voie, libelle
            SELECT
                code_point,
                code_voie,
                libelle
            FROM
                VM_ADRESSE_LITTERALIS_V2
            GROUP BY
                code_point,
                code_voie,
                libelle
            HAVING
                COUNT(code_point) > 1
                AND COUNT(code_voie) > 1
                AND COUNT(libelle) > 1
        ),
        
        C_6 AS(
            SELECT
                'Doublons de code_point, code_voie, libelle' AS type_erreurs,
                COUNT(code_point) AS nombre_objets
            FROM
                C_5
        ), 
        
        C_7 AS(-- S�lection des voies pr�sentes dans VM_ADRESSE_LITTERALIS_V2 et absentes de VM_TRONCON_LITTERALIS_V2
            SELECT
                a.code_voie
            FROM
                VM_ADRESSE_LITTERALIS_V2 a
            WHERE
                a.code_voie NOT IN(SELECT code_rue_g FROM VM_TRONCON_LITTERALIS_V2)    
        ),
        
        C_8 AS(
            SELECT
                'Voies pr�sentes dans VM_ADRESSE_LITTERALIS_V2 et absentes de VM_TRONCON_LITTERALIS_V2' AS type_erreurs,
                COUNT(code_voie) AS nombre_objets
            FROM
                C_7
        ),
        
        C_9 AS(
            SELECT
                type_erreurs,
                nombre_objets
            FROM
                C_2
            UNION ALL
            SELECT
                type_erreurs,
                nombre_objets
            FROM
                C_4
            UNION ALL
            SELECT
                type_erreurs,
                nombre_objets
            FROM
                C_6
            UNION ALL
            SELECT
                type_erreurs,
                nombre_objets
            FROM
                C_8
        )
        
        SELECT
            rownum AS identifiant,
            a.type_erreurs,
            a.nombre_objets
        FROM
            C_9 a;
        
   COMMENT ON COLUMN "G_BASE_VOIE"."V_ERREURS_STATS_ADRESSE_LITTERALIS"."IDENTIFIANT" IS 'Cl� primaire de la vue (sans aucune autre signification particuli�re).';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_ERREURS_STATS_ADRESSE_LITTERALIS"."TYPE_ERREURS" IS 'Types d''erreurs relev�s dans VM_ADRESSE_LITTERALIS_V2.';
   COMMENT ON COLUMN "G_BASE_VOIE"."V_ERREURS_STATS_ADRESSE_LITTERALIS"."NOMBRE_OBJETS" IS 'Nombre d''objets par types d''erreurs.';
   
SELECT *
FROM
    VM_ADRESSE_LITTERALIS_V2
WHERE
    CODE_POINT IN('151835','151869');