/*
Création de la vue matérialisée VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE dénombrant les voies en doublon de nom par commune.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE table_name = 'VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE';
COMMIT;
*/

-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE(
    objectid, 
    nom_voie, 
    code_insee, 
    nombre, 
    geom
)
REFRESH FORCE
START WITH TO_DATE('25-05-2023 12:05:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 240/24/1440
DISABLE QUERY REWRITE AS
    WITH 
        C_1 AS( -- Sélection du centroïde des voies admin disposant d'un nom de voie 
            SELECT
                a.nom_voie,
                a.code_insee,
                SDO_LRS.LOCATE_PT(
                        SDO_LRS.CONVERT_TO_LRS_GEOM(a.geom, m.diminfo),
                        SDO_GEOM.SDO_LENGTH(a.geom, 0.005)/2
                ) AS geom
            FROM
                G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE a,
                USER_SDO_GEOM_METADATA m
            WHERE
                a.libelle_voie IS NOT NULL
                AND m.table_name = 'VM_CONSULTATION_VOIE_ADMINISTRATIVE'
        ),

        C_2 AS(-- Décompte des doubons de noms de voie par commune
            SELECT
                a.nom_voie,
                a.code_insee,
                COUNT(a.objectid) AS nombre
            FROM
                G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE a
                INNER JOIN C_1 b ON b.nom_voie = a.nom_voie AND b.code_insee = a.code_insee
            GROUP BY
                a.nom_voie,
                a.code_insee
            HAVING
                COUNT(a.objectid) > 1
        ),

        C_3 AS(-- Regroupement des géométries par nom de voie et commune
            SELECT
                a.nom_voie,
                a.code_insee,
                b.nombre,
                SDO_CS.MAKE_2D(SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.001))) AS geom
            FROM
                C_1 a 
                INNER JOIN C_2 b ON b.nom_voie = a.nom_voie AND a.code_insee = b.code_insee
            GROUP BY
                a.nom_voie,
                a.code_insee,
                b.nombre
        )
        SELECT
            rownum AS objectid,
            a.nom_voie,
            a.code_insee,
            a.nombre,
            a.geom
        FROM
            C_3 a;

-- 2. Création des commentaires
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE IS 'Vue matérialisée dénombrant les voies en doublon de nom par commune.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE.objectid IS 'Clé primaire de la VM.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE.nom_voie IS 'Nom de voie (Type de voie + libelle de voie + complément nom de voie + commune associée).';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE.code_insee IS 'Code INSEE de la commune d''appartenance de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE.nombre IS 'Nombre de voies ayant le même nom au sein d''une même commune.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE.geom IS 'Géométrie de type multipoint rassemblant les centroïdes de toutes les voies par doublon.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
 
-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE 
ADD CONSTRAINT VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE_PK 
PRIMARY KEY (OBJECTID);

-- 5. Création des index
-- index spatial
CREATE INDEX VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE_SIDX
ON G_BASE_VOIE.VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTIPOINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- Autres index  
CREATE INDEX VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE_NOM_VOIE_IDX ON G_BASE_VOIE.VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE(NOM_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE_CODE_INSEE_IDX ON G_BASE_VOIE.VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE(CODE_INSEE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE_NOMBRE_IDX ON G_BASE_VOIE.VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE(NOMBRE)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE TO G_ADMIN_SIG;

/

