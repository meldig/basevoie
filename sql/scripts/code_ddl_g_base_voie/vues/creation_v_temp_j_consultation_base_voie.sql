/*
Création de la Vue matérialisée VM_TEMP_J_CONSULTATION_BASE_VOIE permettant de visualiser tous les éléments de la Base Voie.
*/
/*
DROP VIEW G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE table_name = 'VM_TEMP_J_CONSULTATION_BASE_VOIE';
COMMIT;
*/
-- 1. Création de la vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE(
    OBJECTID,
    ID_TRONCON,
    ID_VOIE_PHYSIQUE,
    ACTION_SENS,
    ID_VOIE_ADMINISTRATIVE,
    CODE_INSEE,
    TYPE_VOIE,
    LIBELLE_VOIE,
    COMPLEMENT_NOM_VOIE,
    LATERALITE,
    COMMENTAIRE,
    GEOM
)
REFRESH ON COMMIT
FORCE
DISABLE QUERY REWRITE AS
SELECT
    rownum AS objectid,
    a.objectid AS id_troncon,
    b.objectid AS id_voie_physique,
    d.libelle_court AS action_sens,
    e.objectid AS id_voie_administrative,
    e.code_insee,
    f.libelle AS type_voie,
    e.libelle_voie,
    e.complement_nom_voie,
    g.libelle_court AS lateralite,
    e.commentaire,
    a.geom
FROM
    G_BASE_VOIE.TEMP_J_TRONCON a
    INNER JOIN G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TEMP_J_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
    INNER JOIN G_BASE_VOIE.TEMP_J_LIBELLE d ON d.objectid = b.fid_action
    INNER JOIN G_BASE_VOIE.TEMP_J_VOIE_ADMINISTRATIVE e ON e.objectid = c.fid_voie_administrative
    INNER JOIN G_BASE_VOIE.TEMP_J_TYPE_VOIE f ON f.objectid = e.fid_type_voie
    INNER JOIN G_BASE_VOIE.TEMP_J_LIBELLE g ON g.objectid = c.fid_lateralite
);

-- 2. Création des commentaires
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE IS 'Vue matérialisée permettant de visualiser tous les éléments de la Base Voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE.OBJECTID IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE.ID_TRONCON IS 'Identifiant du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE.ID_VOIE_PHYSIQUE IS 'Identifiant de la voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE.ACTION_SENS IS 'Action sur le sens de la voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE.ID_VOIE_ADMINISTRATIVE IS 'Identifiant de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE.CODE_INSEE IS 'Code INSEE de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE.TYPE_VOIE IS 'Type de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE.LIBELLE_VOIE IS 'Libelle de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE.COMPLEMENT_NOM_VOIE IS 'Complément de nom de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE.LATERALITE IS 'Latéralité de la voie administrative par rapport à sa voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE.COMMENTAIRE IS 'Commentaire de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE.GEOM IS 'Géométrie du tronçon de type ligne simple.';

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_J_CONSULTATION_BASE_VOIE 
ADD CONSTRAINT VM_TEMP_J_CONSULTATION_BASE_VOIE_PK 
PRIMARY KEY (OBJECTID);

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_J_CONSULTATION_BASE_VOIE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 
    2154
);
COMMIT;

-- 5. Création des index
CREATE INDEX VM_TEMP_J_CONSULTATION_BASE_VOIE_SIDX
ON G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATEMP_J_TEMP');

CREATE INDEX VM_TEMP_J_CONSULTATION_BASE_VOIE_ID_TRONCON_IDX ON G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE(id_troncon)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_J_CONSULTATION_BASE_VOIE_ID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE(id_voie_physique)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_J_CONSULTATION_BASE_VOIE_ACTION_SENS_IDX ON G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE(action_sens)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_J_CONSULTATION_BASE_VOIE_ID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE(id_voie_administrative)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_J_CONSULTATION_BASE_VOIE_CODE_INSEE_IDX ON G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE(code_insee)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_J_CONSULTATION_BASE_VOIE_TYPE_VOIE_IDX ON G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE(type_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_J_CONSULTATION_BASE_VOIE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE(libelle_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_J_CONSULTATION_BASE_VOIE_COMPLEMENT_NOM_VOIE_IDX ON G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE(complement_nom_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_J_CONSULTATION_BASE_VOIE_LATERALITE_IDX ON G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE(lateralite)
    TABLESPACE G_ADT_INDX;

-- 6. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_J_CONSULTATION_BASE_VOIE TO G_ADMIN_SIG;

/

