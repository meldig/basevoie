/*
Création de la vue VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE dénombrant les doublons de numéros de seuil par voie administrative et par commune.
*/
/*
DROP VIEW G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE" ("OBJECTID", "NUMERO", "CODE_INSEE", "ID_VOIE_ADMINISTRATIVE", "NOM_VOIE", "NOMBRE", 
    CONSTRAINT "VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
    WITH 
        C_1 AS(-- Sélection des doublons de numéro de seuil
            SELECT
                TRIM(a.numero_seuil) AS numero_seuil,
                TRIM(a.complement_numero_seuil) AS complement_numero_seuil,
                b.code_insee,
                f.objectid AS id_voie_administrative,
                TRIM(SUBSTR(UPPER(g.libelle), 1, 1) || SUBSTR(LOWER(g.libelle), 2) || ' ' || TRIM(f.libelle_voie) || ' ' || TRIM(f.complement_nom_voie)) || CASE WHEN f.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN f.code_insee = '59355' THEN ' (Lomme)' END AS nom_voie,
                COUNT(a.objectid) AS nombre
            FROM
                G_BASE_VOIE.TA_INFOS_SEUIL a
                INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
                INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.objectid = b.fid_troncon
                INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE d ON d.objectid = c.fid_voie_physique
                INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE e ON e.fid_voie_physique = d.objectid
                INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE f ON f.objectid = e.fid_voie_administrative AND f.code_insee = b.code_insee
            GROUP BY
                TRIM(a.numero_seuil),
                TRIM(a.complement_numero_seuil),
                b.code_insee,
                f.objectid,
                TRIM(SUBSTR(UPPER(g.libelle), 1, 1) || SUBSTR(LOWER(g.libelle), 2) || ' ' || TRIM(f.libelle_voie) || ' ' || TRIM(f.complement_nom_voie)) || CASE WHEN f.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN f.code_insee = '59355' THEN ' (Lomme)' END
            HAVING
                COUNT(a.objectid) > 1
        ),

        C_2 AS(-- Fusion des géométrie des doublons (création de multi-points)
            SELECT
                a.numero_seuil || ' ' || a.complement_numero_seuil AS numero,
                a.code_insee,
                a.id_voie_administrative,
                a.nom_voie,
                a.nombre,
                SDO_CS.MAKE_2D(SDO_AGGR_UNION(SDOAGGRTYPE(b.geom, 0.001))) AS geom
            FROM
                C_1 a 
                INNER JOIN G_BASE_VOIE.VM_CONSULTATION_SEUIL b ON TRIM(b.numero_seuil) = a.numero_seuil AND TRIM(b.complement_numero_seuil) = a.complement_numero_seuil AND b.code_insee = a.code_insee AND b.id_voie_administrative = a.id_voie_administrative
            GROUP BY
                a.numero_seuil || ' ' || a.complement_numero_seuil,
                a.code_insee,
                a.id_voie_administrative,
                a.nom_voie,
                a.nombre
        )

    SELECT
        rownum AS objectid,
        a.numero,
        a.code_insee,
        a.id_voie_administrative,
        a.nom_voie,
        a.nombre,
        a.geom
    FROM
        C_2 a;

-- 2. Création des commentaires
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE IS 'Vue matérialisée dénombrant et géolocalisant les doublons de numéros de seuil par voie administrative et par commune.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE.objectid IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE.numero IS 'Numéro du seuil (numéro + concaténation).';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE.code_insee IS 'Code INSEE de la commune d''appartenance du seuil et de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE.id_voie_administrative IS 'Identifiant de la voie administrative associée au seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE.nom_voie IS 'Nom de voie (Type de voie + libelle de voie + complément nom de voie + commune associée).';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE.nombre IS 'Nombre de numéros de seuil en doublon par voie administrative et par commune.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE.geom IS 'Géométrie de type multipoint rassemblant les points des seuils par doublon.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
 
-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE 
ADD CONSTRAINT VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE_PK 
PRIMARY KEY (OBJECTID);

-- 5. Création des index
-- index spatial
CREATE INDEX VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE_SIDX
ON G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTIPOINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- Autres index  
CREATE INDEX VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE_NOM_VOIE_IDX ON G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE(NOM_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE_CODE_INSEE_IDX ON G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE(CODE_INSEE)
    TABLESPACE G_ADT_INDX;

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

