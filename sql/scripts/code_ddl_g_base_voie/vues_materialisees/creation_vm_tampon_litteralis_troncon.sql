/*
Création de la vue matérialisée VM_TAMPON_LITTERALIS_TRONCON - de la structure tampon du projet LITTERALIS - regroupant les tronçons de la table TA_TRONCON les informations nécessaires à l''export LITTERALIS.
*/
-- Suppression de la VM
/*
DROP INDEX VM_TAMPON_LITTERALIS_TRONCON_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TAMPON_LITTERALIS_TRONCON';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON (
    geometry, 
    objectid, 
    code_tronc, 
    classement, 
    id_voie_droite, 
    id_voie_gauche, 
    code_insee_voie_droite, 
    code_insee_voie_gauche, 
    nom_voie_droite, 
    nom_voie_gauche
)        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(-- Sélection des tronçons composés de plusieurs sous-tronçons de domanialités différentes
        SELECT
            cnumtrc
        FROM
            SIREO_LEC.OUT_DOMANIALITE
        GROUP BY
            cnumtrc
        HAVING
            COUNT(DISTINCT domania) > 1
    ),
    
    C_2 AS(-- Mise en concordance des domanialités de la DEPV et des classements de LITTERALIS
        SELECT
            a.cnumtrc,
            c.classement
        FROM
            C_1 a
            INNER JOIN SIREO_LEC.OUT_DOMANIALITE b ON b.cnumtrc = a.cnumtrc
            INNER JOIN G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT c ON c.domanialite = b.domania
    ),
    
    C_3 AS(-- Si un tronçon se compose de plusieurs sous-tronçons de domanialités différentes, alors on utilise le système de priorité de la DEPV (présent dans G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT) pour déterminer une domanialité pour le tronçon
        SELECT
            a.cnumtrc,
            CASE
                WHEN a.classement IN('VC', 'VP')
                    THEN 'VC'
                WHEN a.classement IN('VC', 'CR')
                    THEN 'VC'
                WHEN a.classement IN('A', 'RN')
                    THEN 'A'
            END AS classement
        FROM
            C_2 a
        GROUP BY
            a.cnumtrc,
            CASE
                WHEN a.classement IN('VC', 'VP')
                    THEN 'VC'
                WHEN a.classement IN('VC', 'CR')
                    THEN 'VC'
                WHEN a.classement IN('A', 'RN')
                    THEN 'A'
            END
    ),
    
    C_4 AS(-- Sélection des tronçons n'ayant qu'une seule domanialité
        SELECT
            cnumtrc
        FROM
            SIREO_LEC.OUT_DOMANIALITE
        GROUP BY
            cnumtrc
        HAVING
            COUNT(DISTINCT domania) = 1  
    ),
    
    C_5 AS(-- Mise en forme des tronçons ayant une seule domanialité et compilation avec ceux disposant de deux domanialités dans les tables source 
        SELECT DISTINCT --Le DISTINCT est indispensable car certains tronçons peuvent être composés de plusieurs sous-tronçons de même domanialité
            d.id_troncon,
            CAST(d.id_troncon AS VARCHAR2(254 BYTE)) AS code_tronc,
            c.classement,
            d.id_voie_physique,
            d.id_voie_administrative,
            d.lateralite
        FROM
            C_4 a
            INNER JOIN SIREO_LEC.OUT_DOMANIALITE b ON b.cnumtrc = a.cnumtrc
            INNER JOIN G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT c ON c.domanialite = b.domania
            INNER JOIN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE d ON d.id_troncon = b.cnumtrc
        UNION ALL
        SELECT
            b.id_troncon,
            CAST(b.id_troncon AS VARCHAR2(254 BYTE)) AS code_tronc,
            a.classement,
            b.id_voie_physique,
            b.id_voie_administrative,
            b.lateralite
        FROM
            C_3 a
            INNER JOIN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE b ON b.id_troncon = a.cnumtrc
        UNION ALL
        SELECT -- Sélection des tronçons n'ayant pas de domanialité - dans ce cas le classement est 'VC'
            a.objectid,
            CAST(a.objectid AS VARCHAR2(254 BYTE)) AS code_tronc,
            'VC' AS classement,
            a.id_voie_physique,
            a.id_voie_administrative,
            a.lateralite
        FROM
            G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE a
            INNER JOIN G_BASE_VOIE.TA_TRONCON b ON b.objectid = a.id_troncon
        WHERE
            b.old_objectid NOT IN(SELECT cnumtrc FROM SIREO_LEC.OUT_DOMANIALITE)
    ),
    
    C_6 AS(-- Récupération des informations complémentaires (hors géométrie)
        SELECT
            a.id_troncon,
            a.code_tronc,
            a.classement,
            CASE
                WHEN a.lateralite = 'droit'
                    THEN 'Droit'
                WHEN a.lateralite = 'gauche'
                    THEN 'Gauche'
                WHEN a.lateralite = 'les deux côtés'
                    THEN 'LesDeuxCotes'
            END AS lateralite,
            b.objectid AS id_voie,
            b.code_insee AS code_insee_voie,
            b.nom_voie AS nom_voie
        FROM
            C_5 a
            INNER JOIN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE b ON b.objectid = a.id_voie_administrative
    )

    SELECT
        b.geom,
        a.id_troncon,
        a.code_tronc,
        a.classement,
        a.id_voie AS id_voie_droite,
        c.id_voie AS id_voie_gauche,
        a.code_insee_voie AS code_insee_voie_droite,
        c.code_insee_voie AS code_insee_voie_gauche,
        a.nom_voie AS nom_voie_droite,
        c.nom_voie AS nom_voie_gauche
    FROM
        C_6 a
        INNER JOIN G_BASE_VOIE.TA_TRONCON b ON b.objectid = a.id_troncon
        INNER JOIN C_6 c ON c.id_troncon = b.objectid
    WHERE
        a.lateralite IN('Droit', 'LesDeuxCotes')
        AND c.lateralite IN('Gauche', 'LesDeuxCotes')
        AND a.id_troncon NOT IN(1851, 51654);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON IS 'Vue matérialisée - de la structure tampon du projet LITTERALIS - regroupant les tronçons de la table TA_TRONCON les informations nécessaires à l''export LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.GEOMETRY IS 'Géométrie des tronçons de ligne simple.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.OBJECTID IS 'Clé primaire de la VM correspondant aux identifiants des tronçons de la table TA_TRONCON.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.CODE_TRONC IS 'Identifiant du tronçon au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.CLASSEMENT IS 'Domanialité de chaque voie respectant les règles de priorité de la DEPV (TYPOVOIE.COD_DOMANIALITE).';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.ID_VOIE_DROITE IS 'Identifiant de la voie administrative associée au tronçon et située à droite de la voie physique à laquelle il est associé.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.ID_VOIE_GAUCHE IS 'Identifiant de la voie administrative associée au tronçon et située à gauche de la voie physique à laquelle il est associé.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.CODE_INSEE_VOIE_DROITE IS 'Code INSEE de la voie administrative associée au tronçon et située à droite de la voie physique à laquelle il est associé.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.CODE_INSEE_VOIE_GAUCHE IS 'Code INSEE de la voie administrative associée au tronçon et située à gauche de la voie physique à laquelle il est associé.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.NOM_VOIE_DROITE IS 'Nom de la voie administrative (type + nom + complément de nom + Annexe 1,2,3,etc pour les voies secondaires) associée au tronçon et située à droite de la voie physique à laquelle il est associé.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.NOM_VOIE_GAUCHE IS 'Nom de la voie administrative (type + nom + complément de nom + Annexe 1,2,3,etc pour les voies secondaires) associée au tronçon et située à gauche de la voie physique à laquelle il est associé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON
ADD CONSTRAINTS VM_TAMPON_LITTERALIS_TRONCON_PK
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
    'VM_TAMPON_LITTERALIS_TRONCON',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création des index
CREATE INDEX VM_TAMPON_LITTERALIS_TRONCON_SIDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTILINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

CREATE INDEX VM_TAMPON_LITTERALIS_TRONCON_CODE_TRONCON_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON(CODE_TRONC)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_TRONCON_CLASSEMENT_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON(CLASSEMENT)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_TRONCON_ID_VOIE_DROITE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON(ID_VOIE_DROITE)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_TRONCON_ID_VOIE_GAUCHE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON(ID_VOIE_GAUCHE)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_TRONCON_CODE_INSEE_VOIE_DROITE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON(CODE_INSEE_VOIE_DROITE)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_TRONCON_CODE_INSEE_VOIE_GAUCHE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON(CODE_INSEE_VOIE_GAUCHE)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_TRONCON_NOM_VOIE_DROITE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON(NOM_VOIE_DROITE)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_TRONCON_NOM_VOIE_GAUCHE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON(NOM_VOIE_GAUCHE)
TABLESPACE G_ADT_INDX;

-- 6. Affection des droits
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON TO G_ADMIN_SIG;

/

