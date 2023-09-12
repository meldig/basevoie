/*
Création de la vue matérialisée VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE - de la structure tampon du projet LITTERALIS - regroupant toutes les données des voies administratives (sauf leur latéralité) et matérialisant leur tracé. Mise à jour le dernier dimanche du mois à 08h00.
*/
-- Suppression de la VM
/*
DROP INDEX VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE';
COMMIT;
*/

-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE (
    geometry,
    objectid, 
    code_voie, 
    nom_voie, 
    code_insee
)        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(-- Sélection et matérialisation des voies secondaires
        SELECT
            a.id_voie_administrative,
            a.type_voie AS libelle,
            a.libelle_voie,
            a.complement_nom_voie,
            a.code_insee,
            SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS geom
        FROM
            G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE a
        WHERE
            LOWER(a.hierarchie) = 'voie secondaire'
        GROUP BY
            a.id_voie_administrative,
            a.type_voie,
            a.libelle_voie,
            a.complement_nom_voie,
            a.code_insee
    )

    SELECT -- mise en ordre des voies secondaires en fonction de leur taille (ajout du suffixe ANNEXE 1, 2, 3 en fonction de la taille pour un même libelle_voie et code_insee)
        a.geom,
        a.id_voie_administrative AS objectid,
        CAST(a.id_voie_administrative AS VARCHAR2(254 BYTE)) AS code_voie,
        CAST(SUBSTR(UPPER(TRIM(a.libelle)), 1, 1) || SUBSTR(LOWER(TRIM(a.libelle)), 2) || CASE WHEN a.libelle_voie IS NOT NULL THEN ' ' || TRIM(a.libelle_voie) ELSE '' END || CASE WHEN a.complement_nom_voie IS NOT NULL THEN ' ' || TRIM(a.complement_nom_voie) ELSE '' END || CASE WHEN a.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN a.code_insee = '59355' THEN ' (Lomme)' END || ' Annexe ' || ROW_NUMBER() OVER (PARTITION BY (UPPER(TRIM(a.libelle_voie)) || ' ' || a.code_insee) ORDER BY SDO_GEOM.SDO_LENGTH(a.geom, 0.001) DESC) AS VARCHAR2(254)) AS nom_voie,
        CAST(a.code_insee AS VARCHAR2(254 BYTE)) AS code_insee
    FROM
        C_1 a
    UNION ALL
    SELECT -- Sélection et matérialisation des voies principales
        SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS geom,
        a.id_voie_administrative AS objectid,
        CAST(a.id_voie_administrative AS VARCHAR2(254 BYTE)) AS code_voie,
        a.nom_voie,
        CAST(a.code_insee AS VARCHAR2(254 BYTE)) AS code_insee
    FROM
        G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE a
    WHERE
        LOWER(a.hierarchie) = 'voie principale'
    GROUP BY
        a.id_voie_administrative,
        CAST(a.id_voie_administrative AS VARCHAR2(254 BYTE)),
        a.nom_voie,
        CAST(a.code_insee AS VARCHAR2(254 BYTE));

-- 2. Création des commentaires sur la table et les champs
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE IS 'Vue matérialisée - de la structure tampon du projet LITTERALIS - regroupant toutes les données des voies administratives (sauf leur latéralité) et matérialisant leur tracé. Mise à jour le dernier dimanche du mois à 08h00.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE.geometry IS 'Géométrie de type multiligne des voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE.objectid IS 'Clé primaire de la VM correspondant aux identifiants des voies administratives de TA_VOIE_ADMINISTRATIVE.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE.code_voie IS 'Identifiant des voies administratives au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE.nom_voie IS 'Nom de la voie : type de voie + libelle_voie + complement_nom_voie + commune associée.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE.code_insee IS 'Code INSEE de la voie au format LITTERALIS (code INSEE des communes associées remplacé par celui de la commune nouvelle).';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE
ADD CONSTRAINTS VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE_PK
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
    'VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE_SIDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTILINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des index
CREATE INDEX VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE_CODE_VOIE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE(CODE_VOIE)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE_NOM_VOIE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE(NOM_VOIE)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE_CODE_INSEE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE(CODE_INSEE)
TABLESPACE G_ADT_INDX;

-- 7. Affection des droits
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

