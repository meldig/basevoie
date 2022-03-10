/*
VM_TRAVAIL_VOIE_SECONDAIRE_LONGUEUR : Vue matérialisée regroupant les voies dites secondaires, c-a-d les voies dont la longueur n''est PAS la plus grande 
au sein d''un ensensemble de voies ayant le même nom et code INSEE.
De plus, ces voies doivent intersecter directement ou indirectement une voie principale du même nom et code insee.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TRAVAIL_VOIE_SECONDAIRE_LONGUEUR;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TRAVAIL_VOIE_SECONDAIRE_LONGUEUR';
*/
-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TRAVAIL_VOIE_SECONDAIRE_LONGUEUR" ("OBJECTID", "ID_VOIE", "LIBELLE_VOIE", "CODE_INSEE", "LONGUEUR", "GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(-- Sélection des voies secondaires situées à 1m maximum de la voie principale
        SELECT
            a.id_voie AS id_voie_secondaire,
            TRIM(UPPER(a.libelle_voie)) AS libelle_voie_secondaire,
            a.code_insee AS code_insee_voie_secondaire,
            a.longueur_voie AS longueur_voie_secondaire,
            a.geom
        FROM
            G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR a
            INNER JOIN VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR b ON TRIM(UPPER(b.libelle_voie)) = TRIM(UPPER(a.libelle_voie))
                                                                AND b.code_insee = a.code_insee
        WHERE
            a.longueur_voie < b.longueur
            AND SDO_WITHIN_DISTANCE(a.geom, b.geom, 'distance=1') = 'TRUE'
    ),
    
    C_2 AS(-- Sélection des voies secondaires qui intersectent une voie secondaire elle-même intersectant une voie principale
        SELECT
            c.id_voie_secondaire AS id__intersect,
            TRIM(UPPER(c.libelle_voie_secondaire)) AS libelle_intersect,
            c.code_insee_voie_secondaire AS code_insee_intersect,
            c.longueur_voie_secondaire AS longueur_intersect,
            a.id_voie AS id_voie_secondaire,
            TRIM(UPPER(a.libelle_voie)) AS libelle_voie_secondaire,
            a.code_insee AS code_insee_voie_secondaire,
            a.longueur_voie AS longueur_voie_secondaire
        FROM
            G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR a
            INNER JOIN VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR b ON TRIM(UPPER(b.libelle_voie)) = TRIM(UPPER(a.libelle_voie))
                                                                AND b.code_insee = a.code_insee
            INNER JOIN C_1 c ON TRIM(UPPER(c.libelle_voie_secondaire)) = TRIM(UPPER(b.libelle_voie))
                                AND c.code_insee_voie_secondaire = b.code_insee
        WHERE
            a.longueur_voie < b.longueur
            AND a.id_voie <> c.id_voie_secondaire
            AND SDO_ANYINTERACT(a.geom, c.geom) = 'TRUE'
    ),
    
    C_3 AS(-- Regroupement de toutes les voies secondaires
        SELECT
            id_voie_secondaire,
            TRIM(UPPER(libelle_voie_secondaire)) AS libelle_voie_secondaire,
            code_insee_voie_secondaire,
            longueur_voie_secondaire
        FROM
            C_1
        UNION ALL
        SELECT
            id_voie_secondaire,
            TRIM(UPPER(libelle_voie_secondaire)) AS libelle_voie_secondaire,
            code_insee_voie_secondaire,
            longueur_voie_secondaire
        FROM
            C_2
    ),
    
    C_4 AS(
        SELECT DISTINCT
            rownum AS objectid,
            id_voie_secondaire,
            libelle_voie_secondaire,
            code_insee_voie_secondaire AS code_insee,
            longueur_voie_secondaire
        FROM
            C_3
    )
    
    SELECT
        a.objectid,
        a.id_voie_secondaire,
        a.libelle_voie_secondaire,
        a.code_insee,
        a.longueur_voie_secondaire,
        b.geom
    FROM
        C_4 a
        INNER JOIN G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR b ON b.id_voie = a.id_voie_secondaire;

-- 3. Création des commentaires
COMMENT ON MATERIALIZED VIEW VM_TRAVAIL_VOIE_SECONDAIRE_LONGUEUR IS 'Vue matérialisée regroupant les voies dites secondaires, c-a-d les voies dont la longueur n''est PAS la plus grande au sein d''un ensensemble de voies ayant le même nom et code INSEE. De plus, ces voies doivent intersecter directement ou indirectement une voie principale du même nom et code insee.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TRAVAIL_VOIE_SECONDAIRE_LONGUEUR',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création des index
CREATE INDEX VM_TRAVAIL_VOIE_SECONDAIRE_LONGUEUR_SIDX
ON G_BASE_VOIE.VM_TRAVAIL_VOIE_SECONDAIRE_LONGUEUR(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTILINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');
        
CREATE INDEX VM_TRAVAIL_VOIE_SECONDAIRE_LONGUEUR_COMPOSE_IDX ON G_BASE_VOIE.VM_TRAVAIL_VOIE_SECONDAIRE_LONGUEUR("CODE_INSEE", "LIBELLE_VOIE", "LONGUEUR")
    TABLESPACE G_ADT_INDX;

-- 6. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TRAVAIL_VOIE_SECONDAIRE_LONGUEUR TO G_ADMIN_SIG;

/

