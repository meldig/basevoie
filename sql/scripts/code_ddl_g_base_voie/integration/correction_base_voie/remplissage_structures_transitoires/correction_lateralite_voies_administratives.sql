/*
Gestion des voies dont la géométrie est de type ligne simple
*/
-- 1. Création des centroïdes des voies administratives simples
INSERT INTO G_BASE_VOIE.TEMP_C_CENTROIDE_VOIE_ADMINISTRATIVE_SIMPLE(id_voie_administrative, code_insee, geom)
SELECT
    a.id_voie_administrative,
    --SDO_GEOM.SDO_LENGTH(a.geom, 0.005)/2 AS mesure_mediane_voie,
    a.code_insee,
    SDO_CS.MAKE_2D(
        SDO_LRS.LOCATE_PT(
            SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom, m.diminfo),
            SDO_GEOM.SDO_LENGTH(a.geom, 0.005)/2
        ),
        2154
    ) AS geom_centroide
FROM
    G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE a
    INNER JOIN (SELECT DISTINCT id_voie_administrative FROM G_BASE_VOIE.TEMP_C_BUFFER_VOIE_LIMITE_DE_COMMUNE) b ON b.id_voie_administrative = a.id_voie_administrative,
    USER_SDO_GEOM_METADATA m
WHERE
    a.geom.sdo_gtype = 2002
    AND m.table_name = 'VM_TEMP_C_VOIE_ADMINISTRATIVE';
-- Résultat : 586 lignes insérées.

-- 2. Création des buffers autours des centroïdes des voies administratives
INSERT INTO G_BASE_VOIE.TEMP_C_BUFFER_CENTROIDE_VOIE(ID_VOIE_ADMINISTRATIVE, CODE_INSEE_VOIE, GEOM)
SELECT
    a.ID_VOIE_ADMINISTRATIVE, 
    a.code_insee AS CODE_INSEE_VOIE, 
    SDO_GEOM.SDO_BUFFER(a.GEOM, 5, 0.005) AS geom
FROM
    G_BASE_VOIE.TEMP_C_CENTROIDE_VOIE_ADMINISTRATIVE_SIMPLE a
    INNER JOIN (SELECT DISTINCT code_voie FROM VM_AUDIT_TRONCON_PLUSIEURS_VOIES) b ON b.code_voie = a.id_voie_administrative;

-- 3. Création des centroïdes des buffers, créés à l'étape 2, découpés par rapport aux communes qu'ils intersectent
INSERT INTO G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_VOIE(ID_VOIE_ADMINISTRATIVE, CODE_INSEE_VOIE, CODE_INSEE_BUFFER, GEOM)
WITH
    C_1 AS(
        SELECT
            a.ID_VOIE_ADMINISTRATIVE,
            a.code_insee_voie,
            b.code_insee AS code_insee_buffer,
            SDO_GEOM.SDO_INTERSECTION(
                b.geom,
                a.geom,
                0.005
            ) AS geom
        FROM
            G_BASE_VOIE.TEMP_C_BUFFER_CENTROIDE_VOIE a,
            G_REFERENTIEL.MEL_COMMUNE_LLH b
    )
    
    SELECT
        a.ID_VOIE_ADMINISTRATIVE,
        a.code_insee_voie,
        a.code_insee_buffer,
        SDO_GEOM.SDO_CENTROID(a.geom, 0.005) AS gem
    FROM
        C_1 a
    WHERE
        a.geom IS NOT NULL;
-- 929 lignes insérées.

-- Identification des latéralitées des voies simples
WITH
    C_1 AS(
        SELECT
            b.objectid,
            a.id_voie_administrative,
            a.code_insee,
            b.X  AS x_voie,
            b.Y AS y_voie,
            c.x AS x_buffer,
            c.y AS y_buffer
        FROM
            G_BASE_VOIE.TEMP_C_CENTROIDE_VOIE_ADMINISTRATIVE_SIMPLE a
            INNER JOIN G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_VOIE b ON b.id_voie_administrative = a.id_voie_administrative AND b.code_insee_buffer = a.code_insee,
            TABLE(SDO_UTIL.GETVERTICES(a.geom)) b,
            TABLE(SDO_UTIL.GETVERTICES(b.geom)) c
        /*WHERE
            a.id_voie_administrative = 2520380*/
    )
    
    SELECT
        a.objectid,
        a.id_voie_administrative,
        a.code_insee,
        CASE
            WHEN x_buffer > x_voie AND y_buffer > y_voie THEN
                'droite'
            WHEN x_buffer > x_voie AND y_buffer = y_voie THEN
                'droite'
            WHEN x_buffer > x_voie AND y_buffer < y_voie THEN
                'droite'
            WHEN x_buffer < x_voie AND y_buffer < y_voie THEN
                'gauche'
            WHEN x_buffer < x_voie AND y_buffer = y_voie THEN
                'gauche'
            WHEN x_buffer < x_voie AND y_buffer > y_voie THEN
                'gauche'
        END AS lateralite
    FROM
        C_1 a;
-- 343 gauche/droite et 228 null sur un total de 708 voies (polyligne / multiligne comprises)

/*
Gestion des voies dont la géométrie est de type multiligne
*/
-- 1. Création des centroïdes des voies administratives simples
INSERT INTO G_BASE_VOIE.TEMP_C_CENTROIDE_VOIE_ADMINISTRATIVE_MULTILIGNE(id_voie_administrative, code_insee, geom)
SELECT
    a.id_voie_administrative,
    --SDO_GEOM.SDO_LENGTH(a.geom, 0.005)/2 AS mesure_mediane_voie,
    a.code_insee,
    SDO_CS.MAKE_2D(
        SDO_LRS.LOCATE_PT(
            SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom, m.diminfo),
            SDO_GEOM.SDO_LENGTH(a.geom, 0.005)/2
        ),
        2154
    ) AS geom_centroide
FROM
    G_BASE_VOIE.VM_TEMP_C_VOIE_ADMINISTRATIVE a
    INNER JOIN (SELECT DISTINCT code_voie FROM G_BASE_VOIE.vm_audit_troncon_plusieurs_voies) b ON b.code_voie = a.id_voie_administrative,
    USER_SDO_GEOM_METADATA m
WHERE
    a.geom.sdo_gtype = 2006
    AND m.table_name = 'VM_TEMP_C_VOIE_ADMINISTRATIVE';
-- Résultat : 121 lignes insérées.

-- 2. Création des buffers autours des centroïdes des voies administratives
INSERT INTO G_BASE_VOIE.TEMP_C_BUFFER_CENTROIDE_VOIE_MULTILIGNE(ID_VOIE_ADMINISTRATIVE, CODE_INSEE_VOIE, GEOM)
SELECT
    a.ID_VOIE_ADMINISTRATIVE, 
    a.code_insee AS CODE_INSEE_VOIE, 
    SDO_GEOM.SDO_BUFFER(a.GEOM, 5, 0.005) AS geom
FROM
    G_BASE_VOIE.TEMP_C_CENTROIDE_VOIE_ADMINISTRATIVE_MULTILIGNE a
    INNER JOIN (SELECT DISTINCT code_voie FROM VM_AUDIT_TRONCON_PLUSIEURS_VOIES) b ON b.code_voie = a.id_voie_administrative;
-- Résultat : 121 lignes insérées.

-- 3. Création des centroïdes des buffers, créés à l'étape 2, découpés par rapport aux communes qu'ils intersectent
INSERT INTO G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE(ID_VOIE_ADMINISTRATIVE, CODE_INSEE_VOIE, CODE_INSEE_BUFFER, GEOM)
WITH
    C_1 AS(
        SELECT
            a.ID_VOIE_ADMINISTRATIVE,
            a.code_insee_voie,
            b.code_insee AS code_insee_buffer,
            SDO_GEOM.SDO_INTERSECTION(
                b.geom,
                a.geom,
                0.005
            ) AS geom
        FROM
            G_BASE_VOIE.TEMP_C_BUFFER_CENTROIDE_VOIE_MULTILIGNE a,
            G_REFERENTIEL.MEL_COMMUNE_LLH b
    )
    
    SELECT
        a.ID_VOIE_ADMINISTRATIVE,
        a.code_insee_voie,
        a.code_insee_buffer,
        SDO_GEOM.SDO_CENTROID(a.geom, 0.005) AS gem
    FROM
        C_1 a
    WHERE
        a.geom IS NOT NULL;
-- Résultat : 170 lignes insérées.

-- Identification des latéralitées des voies multilignes
WITH
    C_1 AS(
        SELECT
            b.objectid,
            a.id_voie_administrative,
            a.code_insee,
            b.X  AS x_voie,
            b.Y AS y_voie,
            c.x AS x_buffer,
            c.y AS y_buffer
        FROM
            G_BASE_VOIE.TEMP_C_CENTROIDE_VOIE_ADMINISTRATIVE_MULTILIGNE a
            INNER JOIN G_BASE_VOIE.TEMP_C_CENTROIDE_BUFFER_VOIE_MULTILIGNE b ON b.id_voie_administrative = a.id_voie_administrative AND b.code_insee_buffer = a.code_insee,
            TABLE(SDO_UTIL.GETVERTICES(a.geom)) b,
            TABLE(SDO_UTIL.GETVERTICES(b.geom)) c
        /*WHERE
            a.id_voie_administrative = 2520380*/
    )
    
    SELECT
        a.objectid,
        a.id_voie_administrative,
        a.code_insee,
        CASE
            WHEN x_buffer > x_voie AND y_buffer > y_voie THEN
                'droite'
            WHEN x_buffer > x_voie AND y_buffer = y_voie THEN
                'droite'
            WHEN x_buffer > x_voie AND y_buffer < y_voie THEN
                'droite'
            WHEN x_buffer < x_voie AND y_buffer < y_voie THEN
                'gauche'
            WHEN x_buffer < x_voie AND y_buffer = y_voie THEN
                'gauche'
            WHEN x_buffer < x_voie AND y_buffer > y_voie THEN
                'gauche'
        END AS lateralite
    FROM
        C_1 a;