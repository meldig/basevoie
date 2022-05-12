/*
Création de la vue matérialisée VM_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE permettant de matérialiser les voies et de faire en sorte que leur sens géométrique soit équivalent au sens de circulation.
*/
/*
-- 0. Suppression de l'objet
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE';
COMMIT;
*/
-- 1. Création de la Vue Matérialisée
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE (ID_VOIE, LIBELLE_VOIE, GEOM)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(-- interversion du endpoint avec le startpoint pour les tronçons saisis dans le sens opposé au sens de circulation
        SELECT
            a.cnumtrc,
            CASE
                WHEN TRIM(b.ccodstr) = '-'
                    THEN SDO_LRS.REVERSE_GEOMETRY(a.ora_geometry, m.diminfo)
                ELSE
                    a.ora_geometry
            END AS geom
        FROM
            G_BASE_VOIE.TEMP_ILTATRC a
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi,
            USER_SDO_GEOM_METADATA m
        WHERE
            a.cdvaltro = 'V'
            AND b.cvalide = 'V'
            AND c.cdvalvoi = 'V'
            AND m.table_name = 'TEMP_ILTATRC'
    )
    
    SELECT
        c.ccomvoi AS id_voie,
        TRIM(UPPER(TRIM(d.lityvoie) || ' ' || TRIM(c.cnominus) || ' ' || TRIM(c.cinfos))) AS libelle_voie,
        SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS geom
    FROM
        C_1 a
        INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
        INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi
        INNER JOIN G_BASE_VOIE.TEMP_TYPEVOIE d ON d.ccodtvo = c.ccodtvo
    WHERE
        b.cvalide = 'V'
        AND c.cdvalvoi = 'V'
        AND d.lityvoie IS NOT NULL
    GROUP BY
        c.ccomvoi,
        TRIM(UPPER(TRIM(d.lityvoie) || ' ' || TRIM(c.cnominus) || ' ' || TRIM(c.cinfos)));

-- 2. Création des commentaires de VM et de champs
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE IS 'Cette VM matérialise la géométrie des voies valides (disposant d''un type valide) de sorte que le sens géométrique soit égal au sens de circulation : si le sens de saisie d''un tronçon est opposé au sens de circulation de la voie, les startpoint et endpoint sont intervertis, puis les tronçons sont fusionnés par voie d''appartenance. ';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE.id_voie IS 'Identifiant de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE.libelle_voie IS 'nom de la voie : type de voie + nom de voie + complément de nom.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE.geom IS 'Géométri des voies de type multiligne.';

-- 3. Remplissage des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE 
ADD CONSTRAINT VM_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE_PK 
PRIMARY KEY (ID_VOIE);

-- 5. Création des index
CREATE INDEX VM_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE_SIDX
ON G_BASE_VOIE.VM_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE(libelle_voie)
    TABLESPACE G_ADT_INDX;

-- 6. Don du droit de lecture aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE TO G_ADMIN_SIG;

/

