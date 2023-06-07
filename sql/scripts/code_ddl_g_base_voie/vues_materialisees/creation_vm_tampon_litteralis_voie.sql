/*
Création de la vue matérialisée VM_TAMPON_LITTERALIS_VOIE - de la structure tampon du projet LITTERALIS - regroupant toutes les données par voies administratives (dont leur géométrie) et latéralité nécessaires à l''export LITTERALIS.
*/
-- Suppression de la VM
/*
DROP INDEX VM_TAMPON_LITTERALIS_VOIE_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TAMPON_LITTERALIS_VOIE';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE (
    geometry,
    objectid, 
    code_voie, 
    nom_voie, 
    code_insee, 
    cote_voie
)        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(
        SELECT
            SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS geometry,
            CAST(a.id_voie_droite AS NUMBER(38,0)) AS code_voie,
            a.nom_voie_droite AS nom_voie,
            a.code_insee_voie_droite AS code_insee,
            'Droit' AS cote_voie
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON a
        WHERE
            a.id_voie_droite <> a.id_voie_gauche
        GROUP BY
            CAST(a.id_voie_droite AS NUMBER(38,0)),
            a.id_voie_droite,
            a.nom_voie_droite,
            a.code_insee_voie_droite,
            'Droit'
        UNION ALL
        SELECT
            SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS geometry,
            CAST(a.id_voie_gauche AS NUMBER(38,0)) AS code_voie,
            a.nom_voie_gauche AS nom_voie,
            a.code_insee_voie_gauche AS code_insee,
            'Gauche' AS cote_voie
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON a
        WHERE
            a.id_voie_droite <> a.id_voie_gauche
        GROUP BY
            CAST(a.id_voie_gauche AS NUMBER(38,0)),
            a.id_voie_gauche,
            a.nom_voie_gauche,
            a.code_insee_voie_gauche,
            'Gauche'
        UNION ALL
        SELECT
            SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS geometry,
            CAST(a.id_voie_gauche AS NUMBER(38,0)) AS code_voie,
            a.nom_voie_gauche AS nom_voie,
            a.code_insee_voie_gauche AS code_insee,
            'LesDeuxCotes' AS cote_voie
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON a
        WHERE
            a.id_voie_droite = id_voie_gauche
        GROUP BY
            CAST(a.id_voie_gauche AS NUMBER(38,0)),
            a.id_voie_gauche,
            a.nom_voie_gauche,
            a.code_insee_voie_gauche,
            'LesDeuxCotes'
    )
    
    SELECT
        a.geometry,
        rownum AS objectid,
        a.code_voie,
        a.nom_voie,
        a.code_insee,
        cote_voie
    FROM
        C_1 a;

-- 2. Création des commentaires sur la table et les champs
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE IS 'Vue matérialisée - de la structure tampon du projet LITTERALIS - regroupant toutes les données par voies administratives (dont leur géométrie) et latéralité nécessaires à l''export LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE.geometry IS 'Géométrie de type multiligne des voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE.objectid IS 'Clé primaire de la VM.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE.code_voie IS 'Identifiant des voies administratives au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE.nom_voie IS 'Nom de la voie : type de voie + libelle_voie + complement_nom_voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE.code_insee IS 'Code INSEE de la voie principale présente dans TA_VOIE_ADMINISTRATIVE, au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE.cote_voie IS 'Latéralité de la voie : droit, gauche, LesDeuxCotes';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE
ADD CONSTRAINTS VM_TAMPON_LITTERALIS_VOIE_PK
PRIMARY KEY(OBJECTID)
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TAMPON_LITTERALIS_VOIE',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX VM_TAMPON_LITTERALIS_VOIE_SIDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTILINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des index
CREATE INDEX VM_TAMPON_LITTERALIS_VOIE_CODE_VOIE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE(CODE_VOIE)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_VOIE_NOM_VOIE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE(NOM_VOIE)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_VOIE_CODE_INSEE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE(CODE_INSEE)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_VOIE_COTE_VOIE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE(COTE_VOIE)
TABLESPACE G_ADT_INDX;

-- 7. Affection des droits
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE TO G_ADMIN_SIG;

/

