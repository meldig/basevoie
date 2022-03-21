/*
Création d'une vue matérialisée matérialisant la géométrie des voies.
*/
-- 1. Suppression de la VM et de ses métadonnées
/*DROP MATERIALIZED VIEW G_BASE_VOIE.VM_VOIE_AGGREGEE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_VOIE_AGGREGEE';
COMMIT;
*/
-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_VOIE_AGGREGEE" ("ID_VOIE","TYPE_DE_VOIE","LIBELLE_VOIE","COMPLEMENT_NOM_VOIE", "GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
    a.objectid AS id_voie,
    UPPER(TRIM(d.libelle)) AS type_de_voie,
    UPPER(TRIM(a.libelle_voie)) AS libelle_voie,
    UPPER(TRIM(a.complement_nom_voie)) AS complement_nom_voie,
    SDO_AGGR_UNION(
        SDOAGGRTYPE(c.geom, 0.005)
    ) AS geom
FROM
    G_BASE_VOIE.TA_VOIE a
    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_voie = a.objectid
    INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.objectid = b.fid_troncon
    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE d ON d.objectid = a.fid_typevoie
GROUP BY
    a.objectid,
    UPPER(TRIM(d.libelle)),
    UPPER(TRIM(a.libelle_voie)),
    UPPER(TRIM(a.complement_nom_voie))
;

-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_VOIE_AGGREGEE IS 'Vue matérialisée matérialisant la géométrie des voies.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_VOIE_AGGREGEE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_VOIE_AGGREGEE 
ADD CONSTRAINT VM_VOIE_AGGREGEE_PK 
PRIMARY KEY (ID_VOIE);

-- 6. Création des index
CREATE INDEX VM_VOIE_AGGREGEE_SIDX
ON G_BASE_VOIE.VM_VOIE_AGGREGEE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_VOIE_AGGREGEE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_VOIE_AGGREGEE(LIBELLE_VOIE)
    TABLESPACE G_ADT_INDX;

-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_VOIE_AGGREGEE TO G_ADMIN_SIG;

/*
Création d'une vue matérialisée regroupant toutes les voies avec leur nom, code INSEE et longueur
*/

-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR" ("ID_VOIE","TYPE_DE_VOIE","LIBELLE_VOIE","COMPLEMENT_NOM_VOIE","CODE_INSEE","LONGUEUR_VOIE", "GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
    b.id_voie,
    b.type_de_voie,
    b.libelle_voie,
    b.complement_nom_voie,
    CAST(GET_CODE_INSEE_97_COMMUNES_TRONCON('VM_VOIE_AGGREGEE', b.geom) AS VARCHAR2(5))AS code_insee,
    SDO_GEOM.SDO_LENGTH(b.geom) AS longueur_voie,
    b.geom
FROM
    G_BASE_VOIE.TA_VOIE a
    INNER JOIN G_BASE_VOIE.VM_VOIE_AGGREGEE b ON b.id_voie = a.objectid;

-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR IS 'Vue matérialisée récupérant le code INSEE, la longueur, le type , le nom, la géométrie et le complément de chaque voie.';

-- 2. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 
    2154
);
COMMIT;

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR 
ADD CONSTRAINT VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR_PK 
PRIMARY KEY (ID_VOIE);

-- 4. Création des index
CREATE INDEX VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR_SIDX
ON G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR_CODE_INSEE_IDX ON G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR(CODE_INSEE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR_LONGUEUR_VOIE_IDX ON G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR(LONGUEUR_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR(LIBELLE_VOIE)
    TABLESPACE G_ADT_INDX;

-- 5. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR TO G_ADMIN_SIG;

/*
VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR : Vue matérialisée regroupant toutes les voies dites principales de la base, c-a-d les voies ayant la plus grande longueur au sein d''un ensemble de voie ayant le même libellé et code insee.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR';
*/

-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR" ("OBJECTID", "ID_VOIE", "LIBELLE_VOIE", "CODE_INSEE", "LONGUEUR", "GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(-- Sélection des noms, code insee et longueur des voies principales
        SELECT
            TRIM(UPPER(libelle_voie)) AS libelle_voie_principale,
            code_insee AS code_insee_voie_principale,
            MAX(longueur_voie) AS longueur_voie_principale
        FROM
            G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR
        GROUP BY
            libelle_voie,
            code_insee
        HAVING
            COUNT(TRIM(UPPER(libelle_voie)))>1
            AND COUNT(code_insee)>1
    )
    
    SELECT
        rownum AS objectid,
        a.id_voie AS id_voie_principale,
        b.libelle_voie_principale,
        b.code_insee_voie_principale,
        b.longueur_voie_principale,
        a.geom
    FROM
        G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR a
        INNER JOIN C_1 b ON TRIM(UPPER(b.libelle_voie_principale)) = TRIM(UPPER(a.libelle_voie))
                        AND b.code_insee_voie_principale = a.code_insee
                        AND b.longueur_voie_principale = a.longueur_voie
;

-- 3. Création des commentaires
COMMENT ON MATERIALIZED VIEW VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR IS 'Vue matérialisée regroupant toutes les voies dites principales de la base, c-a-d les voies ayant la plus grande longueur au sein d''un ensemble de voie ayant le même libellé et code insee.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR 
ADD CONSTRAINT VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR_PK 
PRIMARY KEY (OBJECTID);

-- 6. Création des index
CREATE INDEX VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR_SIDX
ON G_BASE_VOIE.VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTILINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

CREATE INDEX VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR_COMPOSE_IDX ON G_BASE_VOIE.VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR("CODE_INSEE", "LIBELLE_VOIE")
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR_LONGUEUR_IDX ON G_BASE_VOIE.VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR("LONGUEUR")
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR_ID_VOIE_IDX ON G_BASE_VOIE.VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR("ID_VOIE")
    TABLESPACE G_ADT_INDX;

-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR TO G_ADMIN_SIG;

/

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
    )/*,
    
    C_2 AS(-- Sélection des voies secondaires qui intersectent une voie secondaire elle-même intersectant une voie principale*/
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

/*
VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR : Vue matérialisée regroupant chaque voie secondaire avec sa voie principale. Une voie principale la voie la plus grande au sein d''un ensemble de voies ayant le même nom et le même code INSEE, les autres sont les voies secondaires. De plus, ces dernières doivent obligatoirement intersecter directement ou non leur voie principale.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR';
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR" ("ID_VOIE_PRINCIPALE","TYPE_VOIE_PRINCIPALE","LIBELLE_VOIE_PRINCIPALE","CODE_INSEE_VOIE_PRINCIPALE","LONGUEUR_VOIE_PRINCIPALE","ID_VOIE_SECONDAIRE","TYPE_VOIE_SECONDAIRE","LIBELLE_VOIE_SECONDAIRE","CODE_INSEE_VOIE_SECONDAIRE","LONGUEUR_VOIE_SECONDAIRE")
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT DISTINCT
    a.id_voie AS id_voie_principale,
    d.libelle AS type_voie_principale,
    a.libelle_voie AS libelle_voie_principale,
    a.code_insee AS code_insee_voie_principale,
    a.longueur AS longueur_voie_principale,
    b.id_voie AS id_voie_secondaire,
    f.libelle AS type_voie_secondaire,
    b.libelle_voie AS libelle_voie_secondaire,
    b.code_insee AS code_insee_voie_secondaire,
    b.longueur AS longueur_voie_secondaire
FROM
    G_BASE_VOIE.VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR a
    INNER JOIN G_BASE_VOIE.VM_TRAVAIL_VOIE_SECONDAIRE_LONGUEUR b ON TRIM(UPPER(b.libelle_voie)) = TRIM(UPPER(a.libelle_voie)) AND b.code_insee = a.code_insee
    INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = a.id_voie
    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE d ON d.objectid = c.fid_typevoie
    INNER JOIN G_BASE_VOIE.TA_VOIE e ON e.objectid = b.id_voie
    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE f ON f.objectid = e.fid_typevoie
WHERE
    a.longueur > b.longueur;
    
-- 2. Création des commentaires de la vue matérialisée et des champs
COMMENT ON MATERIALIZED VIEW "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR"  IS 'Vue matérialisée regroupant chaque voie secondaire avec sa voie principale. Une voie principale la voie la plus grande au sein d''un ensemble de voies ayant le même nom et le même code INSEE, les autres sont les voies secondaires. De plus, ces dernières doivent obligatoirement intersecter directement ou non leur voie principale.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR"."ID_VOIE_PRINCIPALE" IS 'Identifiant de chaque voie principale se trouvant dans VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR. Partie de la clé primaire.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR"."LIBELLE_VOIE_PRINCIPALE" IS 'Libelle de chaque voie principale (sans son type) se trouvant dans VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR"."LIBELLE_VOIE_PRINCIPALE" IS 'Libelle de chaque voie principale se trouvant dans VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR"."CODE_INSEE_VOIE_PRINCIPALE" IS 'Code INSEE de la voie principale.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR"."LONGUEUR_VOIE_PRINCIPALE" IS 'Longueur de la voie principale.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR"."ID_VOIE_SECONDAIRE" IS 'Identifiant de chaque voie secondaire se trouvant dans VM_TRAVAIL_VOIE_SECONDAIRE_LONGUEUR. Partie de la clé primaire.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR"."LIBELLE_VOIE_SECONDAIRE" IS 'Libelle de chaque voie secondaire (sans son type) se trouvant dans VM_TRAVAIL_VOIE_SECONDAIRE_LONGUEUR.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR"."LIBELLE_VOIE_SECONDAIRE" IS 'Libelle de chaque voie secondaire se trouvant dans VM_TRAVAIL_VOIE_SECONDAIRE_LONGUEUR.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR"."CODE_INSEE_VOIE_SECONDAIRE" IS 'Code INSEE de la voie secondaire.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR"."LONGUEUR_VOIE_SECONDAIRE" IS 'Longueur de la voie secondaire.';

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR 
ADD CONSTRAINT VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR_PK 
PRIMARY KEY ("ID_VOIE_PRINCIPALE", "ID_VOIE_SECONDAIRE");

-- 4. Création des index
CREATE INDEX VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR_VOIE_PRINCIPALE_IDX ON G_BASE_VOIE.VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR("CODE_INSEE_VOIE_PRINCIPALE", "TYPE_VOIE_PRINCIPALE", "LIBELLE_VOIE_PRINCIPALE", "LONGUEUR_VOIE_PRINCIPALE")
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR_VOIE_SECONDAIRE_IDX ON G_BASE_VOIE.VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR("CODE_INSEE_VOIE_SECONDAIRE", "TYPE_VOIE_SECONDAIRE", "LIBELLE_VOIE_SECONDAIRE", "LONGUEUR_VOIE_SECONDAIRE")
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR_ID_VOIE_PRINCIPALE_IDX ON G_BASE_VOIE.VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR("ID_VOIE_PRINCIPALE")
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR_ID_VOIE_SECONDAIRE_IDX ON G_BASE_VOIE.VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR("ID_VOIE_SECONDAIRE")
    TABLESPACE G_ADT_INDX;
    
-- 5. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR TO G_ADMIN_SIG;

/


-- Import des relations voies principales / secondaires de la VM VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR dans la table TA_HIERARCHISATION_VOIE
MERGE INTO G_BASE_VOIE.TA_HIERARCHISATION_VOIE a
    USING(
        SELECT
            id_voie_principale,
            id_voie_secondaire
        FROM
            G_BASE_VOIE.VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR
    )t
    ON(a.fid_voie_principale = t.id_voie_principale AND a.fid_voie_secondaire = t.id_voie_secondaire)
WHEN NOT MATCHED THEN
    INSERT(a.fid_voie_principale, a.fid_voie_secondaire)
    VALUES(t.id_voie_principale, t.id_voie_secondaire);
COMMIT;