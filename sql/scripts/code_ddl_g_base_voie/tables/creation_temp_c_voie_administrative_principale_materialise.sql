/*
création de la VM TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE - du projet C de correction de la latéralité des voies - matérialisant la géométrie des voies administratrives principale uniquement. Cette table est à utiliser uniquement dans le cadre de l''homogénéisation des noms de voie.
*/
/*
DROP TABLE G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE CASCADE CONSTRAINTS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE';
COMMIT;
*/
-- 2. Création de la VM
CREATE TABLE  "G_BASE_VOIE"."TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE" AS
    SELECT
        f.objectid AS id_voie_administrative,
        TRIM(g.libelle) AS type_voie,
        TRIM(f.libelle_voie) AS nom_voie,
        TRIM(f.complement_nom_voie) AS complement_nom_voie,
        h.libelle_long AS lateralite,
        f.code_insee,
        f.hierarchisation AS hierarchie,
        4 AS fid_etat,
        SDO_AGGR_UNION(
            SDOAGGRTYPE(b.geom, 0.005)
        ) AS geom
    FROM
        G_BASE_VOIE.TEMP_C_TRONCON b
        INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE c ON c.fid_troncon = b.objectid
        INNER JOIN G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE d ON d.objectid = c.fid_voie_physique
        INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE e ON e.fid_voie_physique = d.objectid
        INNER JOIN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE f ON f.objectid = e.fid_voie_administrative
        INNER JOIN G_BASE_VOIE.TEMP_C_TYPE_VOIE g ON g.objectid = f.fid_type_voie
        INNER JOIN G_BASE_VOIE.TEMP_C_LIBELLE h ON h.objectid = f.fid_lateralite
    WHERE
        f.hierarchisation = 'voie principale'
    GROUP BY
        f.objectid,
        TRIM(g.libelle),
        TRIM(f.libelle_voie),
        TRIM(f.complement_nom_voie),
        h.libelle_long,
        f.code_insee,
        f.hierarchisation,
        4;

-- 2. Création des commentaires de la VM
COMMENT ON TABLE G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE IS 'Table - du projet C de correction de la latéralité des voies - matérialisant la géométrie des voies administratrives principale uniquement. Cette table est à utiliser uniquement dans le cadre de l''homogénéisation des noms de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE.ID_VOIE_ADMINISTRATIVE IS 'Identifiant de la voie administrative présente dans TEMP_C_VOIE_ADMINISTRATIVE.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE.NOM_VOIE IS 'Libelle des voies administratives présentes dans la table TEMP_C_VOIE_ADMINISTRATIVE.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE.LATERALITE IS 'Latéralité des voies administratives par rapport à leur voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE.CODE_INSEE IS 'Code INSEE des voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE.HIERARCHIE IS 'Champ permettant de distinguer les voies principales des voies secondaires.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE.FID_ETAT IS 'Clé étrangère vers la table TEMP_C_LIBELLE permettant de connaître l''état d''avancement de l''homogénéisation des noms de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE.GEOM IS 'Géométrie de type multiligne des voies administratives.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE
ADD CONSTRAINT TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE_PK 
PRIMARY KEY("ID_VOIE_ADMINISTRATIVE") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE_SIDX
ON G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTILINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE
ADD CONSTRAINT TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE_FID_ETAT_FK
FOREIGN KEY (fid_etat)
REFERENCES G_BASE_VOIE.TEMP_C_LIBELLE(objectid);

-- 6. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE_NOM_VOIE_IDX ON G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE(nom_voie)
    TABLESPACE G_ADT_INDX;
CREATE INDEX TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE_COMPLEMENT_NOM_VOIE_IDX ON G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE(complement_nom_voie)
    TABLESPACE G_ADT_INDX;
CREATE INDEX TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE_CODE_INSEE_IDX ON G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE(code_insee)
    TABLESPACE G_ADT_INDX;
CREATE INDEX TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE_TYPE_VOIE_IDX ON G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE(type_voie)
    TABLESPACE G_ADT_INDX;
CREATE INDEX TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE_FID_ETAT_IDX ON G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE(fid_etat)
    TABLESPACE G_ADT_INDX;

    
-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE TO G_ADMIN_SIG;

/

