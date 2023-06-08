/*
Création de la vue matérialisée VM_CONSULTATION_VOIE_ADMINISTRATIVE contenant la géométrie des voies administratives avec leur nom, code insee, latéralité et hiérarchie.  Mise à jour du lundi au vendredi à 22h00.
*/
-- 1. Suppression de la VM et de ses métadonnées
/*
DROP INDEX VM_CONSULTATION_VOIE_ADMINISTRATIVE_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_CONSULTATION_VOIE_ADMINISTRATIVE';
COMMIT;
*/
-- 2. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE (
    OBJECTID,
    ID_VOIE_ADMINISTRATIVE,
    CODE_INSEE,
    NOM_COMMUNE,
    TYPE_VOIE,
    LIBELLE_VOIE,
    COMPLEMENT_NOM_VOIE,
    NOM_VOIE,
    LATERALITE,
    HIERARCHIE,
    NBR_VOIE_PHYSIQUE,
    GEOM
)        
REFRESH FORCE
START WITH TO_DATE('08-06-2023 22:00:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 1
DISABLE QUERY REWRITE AS
    WITH 
        C_1 AS (
            SELECT
                d.objectid AS id_voie_administrative,
                d.code_insee,
                h.nom AS nom_commune,
                TRIM(SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 2)) AS type_voie,
                TRIM(d.libelle_voie) AS libelle_voie,
                TRIM(d.complement_nom_voie) AS complement_nom_voie,
                TRIM(SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 2) || ' ' || TRIM(d.libelle_voie) || ' ' || TRIM(d.complement_nom_voie)) || CASE WHEN d.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN d.code_insee = '59355' THEN ' (Lomme)' END AS nom_voie,
                f.libelle_court AS lateralite,
                CASE WHEN COALESCE(g.fid_voie_secondaire, 0) = 0 THEN 'Voie Principale' ELSE 'Voie secondaire' END AS hierarchie,
                COUNT(c.fid_voie_physique) AS nbr_voie_physique
            FROM
                G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c
                INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE d ON d.objectid = c.fid_voie_administrative
                LEFT JOIN G_BASE_VOIE.TA_TYPE_VOIE e ON e.objectid = d.fid_type_voie
                LEFT JOIN G_BASE_VOIE.TA_LIBELLE f ON f.objectid = c.fid_lateralite
                LEFT JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE g ON g.fid_voie_secondaire = d.objectid
                INNER JOIN G_REFERENTIEL.MEL_COMMUNE_LLH h ON h.code_insee = d.code_insee
            GROUP BY
                d.objectid,
                d.code_insee,
                h.nom,
                TRIM(SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 2)),
                TRIM(d.libelle_voie),
                TRIM(d.complement_nom_voie),
                TRIM(SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 2) || ' ' || TRIM(d.libelle_voie) || ' ' || TRIM(d.complement_nom_voie)) || CASE WHEN d.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN d.code_insee = '59355' THEN ' (Lomme)' END,
                f.libelle_court,
                CASE WHEN COALESCE(g.fid_voie_secondaire, 0) = 0 THEN 'Voie Principale' ELSE 'Voie secondaire' END
        ),

        C_2 AS(
            SELECT
                d.id_voie_administrative,
                d.code_insee,
                d.nom_commune,
                d.type_voie,
                d.libelle_voie,
                d.complement_nom_voie,
                d.nom_voie,
                d.lateralite,
                d.hierarchie,
                d.nbr_voie_physique,
                SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS geom
            FROM
                G_BASE_VOIE.TA_TRONCON a
                INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
                INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
                INNER JOIN C_1 d ON d.id_voie_administrative = c.fid_voie_administrative
            GROUP BY
                d.id_voie_administrative,
                d.code_insee,
                d.nom_commune,
                d.type_voie,
                d.libelle_voie,
                d.complement_nom_voie,
                d.nom_voie,
                d.lateralite,
                d.hierarchie,
                d.nbr_voie_physique
        )

        SELECT
            ROWNUM AS objectid,
            a.id_voie_administrative,
            a.code_insee,
            a.nom_commune,
            a.type_voie,
            a.libelle_voie,
            a.complement_nom_voie,
            a.nom_voie,
            a.lateralite,
            a.hierarchie,
            a.nbr_voie_physique,
            a.geom
        FROM
            C_2 a;

-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE IS 'Vue matérialisée contenant la géométrie des voies administratives avec leur nom, code insee, latéralité et hiérarchie. Mise à jour du lundi au vendredi à 22h00.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE.objectid IS 'Clé primaire de la VM. Il est nécessaire que cette clé primaire soit différente des identifiants de voie administrative, car la latéralité d''une voie peut-être droite ou gauche sur une partie de son tracé et lesdeuxcôtés sur le reste.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE.id_voie_administrative IS 'Identifiants des voies administratives de TA_VOIE_ADMINISTRATIVE.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE.code_insee IS 'Code INSEE de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE.nom_commune IS 'Nom commune.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE.type_voie IS 'Type de voie administrative';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE.libelle_voie IS 'Libellé de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE.complement_nom_voie IS 'Complément de nom de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE.nom_voie IS 'Nom des voies administratives : concaténation du type de voie, du libellé de voie et du complément de nom de voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE.lateralite IS 'Latéralité de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE.hierarchie IS 'Hiérarchie des voies (prinicpale/secondaire).';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE.nbr_voie_physique IS 'Nombre de voies physiques par voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE.geom IS 'Géométrie de type multiligne.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_CONSULTATION_VOIE_ADMINISTRATIVE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_CONSULTATION_VOIE_ADMINISTRATIVE 
ADD CONSTRAINT VM_CONSULTATION_VOIE_ADMINISTRATIVE_PK 
PRIMARY KEY (OBJECTID);

-- 6. Création des index
CREATE INDEX VM_CONSULTATION_VOIE_ADMINISTRATIVE_SIDX
ON G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_CONSULTATION_VOIE_ADMINISTRATIVE_ID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE(ID_VOIE_ADMINISTRATIVE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_VOIE_ADMINISTRATIVE_CODE_INSEE_IDX ON G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE(CODE_INSEE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_VOIE_ADMINISTRATIVE_NOM_COMMUNE_IDX ON G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE(NOM_COMMUNE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_VOIE_ADMINISTRATIVE_TYPE_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE(TYPE_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_VOIE_ADMINISTRATIVE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE(LIBELLE_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_VOIE_ADMINISTRATIVE_COMPLEMENT_NOM_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE(COMPLEMENT_NOM_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_VOIE_ADMINISTRATIVE_NOM_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE(NOM_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_VOIE_ADMINISTRATIVE_NBR_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE(NBR_VOIE_PHYSIQUE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_VOIE_ADMINISTRATIVE_LATERALITE_IDX ON G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE(LATERALITE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_VOIE_ADMINISTRATIVE_HIERARCHIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE(HIERARCHIE)
    TABLESPACE G_ADT_INDX;

-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

