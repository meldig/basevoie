/*
Création de la vue matérialisée VM_ADRESSE_LITTERALIS_2023 testant le regroupement des seuils par voie administrative au format LITTERALIS à partir de la structure TEMP_H
*/
/*
-- 1. Suppression de la VM et de ses métadonnées
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_ADRESSE_LITTERALIS_2023;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_ADRESSE_LITTERALIS_2023';
COMMIT;
*/

-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_ADRESSE_LITTERALIS_2023" ("IDENTIFIANT", "CODE_VOIE", "CODE_POINT", "NATURE", "LIBELLE", "NUMERO", "REPETITION", "COTE", "GEOMETRY")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(
        SELECT DISTINCT
            a.objectid AS id_seuil,
            b.objectid AS objectid,
            CAST(f.objectid AS VARCHAR2(254)) AS CODE_VOIE,
            CAST(b.objectid AS VARCHAR2(254)) AS CODE_POINT,
            CAST('ADR' AS VARCHAR2(254)) AS NATURE,
            CAST(b.numero_seuil || ' ' || TRIM(b.complement_numero_seuil) AS VARCHAR2(254)) AS LIBELLE,
            CAST(b.numero_seuil  AS VARCHAR2(254)) AS NUMERO,
            CAST(TRIM(b.complement_numero_seuil) AS VARCHAR2(254)) AS REPETITION,
            CASE
                WHEN LOWER(g.libelle_court) = 'droit'
                    THEN 'Pair'
                WHEN LOWER(g.libelle_court) = 'gauche'
                    THEN 'Impair'
                ELSE
                    'LesDeuxCotes' 
            END AS COTE
        FROM
            G_BASE_VOIE.TEMP_H_SEUIL a
            INNER JOIN G_BASE_VOIE.TEMP_H_INFOS_SEUIL b ON b.fid_seuil = a.objectid
            INNER JOIN G_BASE_VOIE.TEMP_H_TRONCON c ON c.objectid = a.fid_troncon
            INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE d ON d.objectid = c.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE e ON e.fid_voie_physique = d.objectid    
            INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE f ON f.objectid = e.fid_voie_administrative AND f.objectid = b.fid_voie_administrative
            INNER JOIN G_BASE_VOIE.TEMP_H_LIBELLE g ON g.objectid = e.fid_lateralite
            INNER JOIN G_BASE_VOIE.TEMP_H_TYPE_VOIE h ON h.objectid = f.fid_type_voie        
    )
    
    SELECT
        a.OBJECTID,
        a.CODE_VOIE,
        a.CODE_POINT,
        a.NATURE,
        a.LIBELLE,
        a.NUMERO,
        a.REPETITION,
        a.COTE,
        b.geom
    FROM
        C_1 a
        INNER JOIN G_BASE_VOIE.TEMP_H_SEUIL b ON b.objectid = a.id_seuil;

-- 3. Création des commentaires de la VM
COMMENT ON COLUMN "G_BASE_VOIE"."VM_ADRESSE_LITTERALIS_2023"."IDENTIFIANT" IS 'Clé primaire de la vue';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_ADRESSE_LITTERALIS_2023"."CODE_VOIE" IS 'Liaison avec la classe TRONCON sur la colonne CODE_RUE_G ou CODE_RUE_D.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_ADRESSE_LITTERALIS_2023"."CODE_POINT" IS 'Identificateur unique et immuable du point partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_ADRESSE_LITTERALIS_2023"."NATURE" IS 'Indique la nature du point: ADR = Adresse.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_ADRESSE_LITTERALIS_2023"."LIBELLE" IS 'Libellé du point affiché dans les textes (dans les actes…) correspondant à la concaténation numéro + complément de numéro de seuil.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_ADRESSE_LITTERALIS_2023"."NUMERO" IS 'Numéro du seuil.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_ADRESSE_LITTERALIS_2023"."REPETITION" IS 'Indique la valeur de répétition d’un numéro sur une rue. La saisie de la répétition est libre.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_ADRESSE_LITTERALIS_2023"."COTE" IS 'Définit sur quel côté de la voie administrative s’appuie le seuil: LesDeuxCotes, Impair, Pair.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_ADRESSE_LITTERALIS_2023"."GEOMETRY" IS 'Géométrie de type point.';
COMMENT ON MATERIALIZED VIEW "G_BASE_VOIE"."VM_ADRESSE_LITTERALIS_2023"  IS 'Vue matérialisée testant le regroupement des seuils par voie administrative au format LITTERALIS à partir de la structure TEMP_H.';

-- 2. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_ADRESSE_LITTERALIS_2023',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 
    2154
);
COMMIT;

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_ADRESSE_LITTERALIS_2023 
ADD CONSTRAINT VM_ADRESSE_LITTERALIS_2023_PK 
PRIMARY KEY (IDENTIFIANT);

-- 4. Création de l'index spatial
CREATE INDEX VM_ADRESSE_LITTERALIS_2023_SIDX
ON G_BASE_VOIE.VM_ADRESSE_LITTERALIS_2023(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=POINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 5. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_ADRESSE_LITTERALIS_2023 TO G_ADMIN_SIG;

/

