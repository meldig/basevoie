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
COMMIT;

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

