/*
Création de la vue matérialisée VM_CONSULTATION_SEUIL regroupant les seuils de la MEL et leur tronçon.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_SEUIL;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_CONSULTATION_SEUIL';
COMMIT;
*/
-- 1. Création de la vue matérialisée
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_SEUIL(
    id_seuil,
    id_troncon,
    id_voie_physique,
    id_voie_administrative,
    numero,
    complement_numero,
    code_insee,
    nom_commune,
    lateralite,
    position,
    type_voie,
    libelle_voie,
    complement_nom_voie,
    nom_voie,
    hierarchie_voie_admin,
    date_saisie,
    date_modification,
    geom
)
REFRESH FORCE
START WITH TO_DATE('31-05-2023 17:00:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 240/24/1440
DISABLE QUERY REWRITE AS
SELECT
    a.objectid AS id_seuil,
    b.fid_troncon AS id_troncon,
    d.objectid AS id_voie_physique,
    f.objectid AS id_voie_administrative,
    a.numero_seuil,
    a.complement_numero_seuil,
    b.code_insee,
    j.nom AS nom_commune,
    g.libelle_court AS lateralite,
    k.libelle_court AS position,
    TRIM(SUBSTR(UPPER(h.libelle), 1, 1) || SUBSTR(LOWER(h.libelle), 2)) AS type_voie,
    TRIM(f.libelle_voie) AS libelle_voie,
    TRIM(f.complement_nom_voie) AS complement_nom_voie,
    TRIM(SUBSTR(UPPER(h.libelle), 1, 1) || SUBSTR(LOWER(h.libelle), 2) || ' ' || TRIM(f.libelle_voie) || ' ' || TRIM(f.complement_nom_voie)) || CASE WHEN f.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN f.code_insee = '59355' THEN ' (Lomme)' END AS nom_voie,
    CASE 
        WHEN i.fid_voie_secondaire IS NOT NULL
            THEN 'Voie secondaire'
        ELSE 
            'Voie principale'
    END AS hierarchie_voie_admin,
    a.date_saisie,
    a.date_modification,
    b.geom
FROM
    G_BASE_VOIE.TA_INFOS_SEUIL a
    INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
    INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.objectid = b.fid_troncon
    INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE d ON d.objectid = c.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE e ON e.fid_voie_physique = d.objectid
    INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE f ON f.objectid = e.fid_voie_administrative AND f.code_insee = b.code_insee
    LEFT JOIN G_BASE_VOIE.TA_LIBELLE g ON g.objectid = b.fid_lateralite
    LEFT JOIN G_BASE_VOIE.TA_LIBELLE k ON k.objectid = b.fid_position
    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE h ON h.objectid = f.fid_type_voie
    LEFT JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE i ON i.fid_voie_secondaire = f.objectid
    INNER JOIN G_REFERENTIEL.MEL_COMMUNE_LLH j ON j.code_insee = b.code_insee;

-- 2. Création des commentaires de table et de colonnes
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_SEUIL IS 'Vue matérialisée regroupant les seuils de la MEL, leur tronçon, voie physique et voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.id_seuil IS 'Clé primaire de la VM correspondant aux identifiants de chaque seuil (TA_INFOS_SEUIL).';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.id_troncon IS 'Identifiant du tronçon auquel est rattaché le seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.id_voie_physique IS 'Identifiant de la voie physique à laquelle est rattaché le seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.id_voie_administrative IS 'Identifiant de la voie administrative à laquelle est rattaché le seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.numero IS 'Numéro du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.complement_numero IS 'Complément du numéro de seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.code_insee IS 'Code INSEE du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.nom_commune IS 'Nom de la commune du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.lateralite IS 'Latéralité du seuil par rapport au tronçon (droite/gauche).';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.position IS 'Position de l''adresse : au seuil, à la boîte postale, au début de la rue, etc.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.type_voie IS 'Type de voie administrative';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.libelle_voie IS 'Libellé de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.complement_nom_voie IS 'Complément de nom de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.nom_voie IS 'Nom de la voie à laquelle le seuil est affecté.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.hierarchie_voie_admin IS 'Hiérarchie de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.date_saisie IS 'Date de saisie du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.date_modification IS 'Date de la dernière modification du seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_SEUIL.geom IS 'Géométrie de type point des seuils.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_CONSULTATION_SEUIL',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_CONSULTATION_SEUIL 
ADD CONSTRAINT VM_CONSULTATION_SEUIL_PK 
PRIMARY KEY (ID_SEUIL);

-- 5. Création des index
-- index spatial
CREATE INDEX VM_CONSULTATION_SEUIL_SIDX
ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=POINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- Autres index  
CREATE INDEX VM_CONSULTATION_SEUIL_NUMERO_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(NUMERO)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_SEUIL_COMPLEMENT_NUMERO_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(COMPLEMENT_NUMERO)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_SEUIL_CODE_INSEE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(CODE_INSEE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_SEUIL_NOM_COMMUNE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(NOM_COMMUNE)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_CONSULTATION_SEUIL_LATERALITE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(lateralite)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_CONSULTATION_SEUIL_POSITION_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(position)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_SEUIL_ID_TRONCON_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(ID_TRONCON)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_SEUIL_ID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(ID_VOIE_PHYSIQUE)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_CONSULTATION_SEUIL_ID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(ID_VOIE_ADMINISTRATIVE)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_CONSULTATION_SEUIL_TYPE_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(TYPE_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_SEUIL_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(LIBELLE_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_SEUIL_COMPLEMENT_NOM_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(COMPLEMENT_NOM_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_SEUIL_NOM_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(NOM_VOIE)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_CONSULTATION_SEUIL_DATE_SAISIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(DATE_SAISIE)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_CONSULTATION_SEUIL_DATE_MODIFICATION_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(DATE_MODIFICATION)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_CONSULTATION_SEUIL_HIERARCHIE_VOIE_ADMIN_IDX ON G_BASE_VOIE.VM_CONSULTATION_SEUIL(HIERARCHIE_VOIE_ADMIN)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_CONSULTATION_SEUIL TO G_ADMIN_SIG;

/

/*
Création de la vue matérialisée VM_CONSULTATION_BASE_VOIE contenant les tronçons, voies physiques et voies administratives de la base voie. Mise à jour quotidienne à 21h00
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_CONSULTATION_BASE_VOIE';
COMMIT;
*/
-- 1. Création de la vue matérialisée
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(
    objectid,
    id_troncon,
    id_voie_physique,
    id_voie_administrative,
    code_insee,
    nom_commune,
    action_sens,
    type_voie,
    libelle_voie,
    complement_nom_voie,
    nom_voie,
    lateralite,
    hierarchie,
    commentaire,
    geom
)
REFRESH FORCE
START WITH TO_DATE('01-06-2023 21:00:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 1
DISABLE QUERY REWRITE AS
SELECT
    rownum AS objectid,
    a.objectid AS id_troncon,
    b.objectid AS id_voie_physique,
    d.objectid AS id_voie_administrative,
    d.code_insee,
    h.nom AS nom_commune,
    i.libelle_court AS action_sens,
    TRIM(SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 2)) AS type_voie,
    TRIM(d.libelle_voie) AS libelle_voie,
    TRIM(d.complement_nom_voie) AS complement_nom_voie,
    TRIM(SUBSTR(UPPER(e.libelle), 1, 1) || SUBSTR(LOWER(e.libelle), 2) || ' ' || TRIM(d.libelle_voie) || ' ' || TRIM(d.complement_nom_voie)) || CASE WHEN d.code_insee = '59298' THEN ' (Hellemmes-Lille)' WHEN d.code_insee = '59355' THEN ' (Lomme)' END AS nom_voie,
    f.libelle_court AS lateralite,
    CASE WHEN COALESCE(g.fid_voie_secondaire, 0) = 0 THEN 'Voie Principale' ELSE 'Voie secondaire' END AS hierarchie,
    d.commentaire,
    a.geom
FROM
    G_BASE_VOIE.TA_TRONCON a
    INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
    INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE d ON d.objectid = c.fid_voie_administrative
    LEFT JOIN G_BASE_VOIE.TA_TYPE_VOIE e ON e.objectid = d.fid_type_voie
    LEFT JOIN G_BASE_VOIE.TA_LIBELLE f ON f.objectid = c.fid_lateralite
    LEFT JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE g ON g.fid_voie_secondaire = d.objectid
    INNER JOIN G_REFERENTIEL.MEL_COMMUNE_LLH h ON h.code_insee = d.code_insee
    LEFT JOIN G_BASE_VOIE.TA_LIBELLE i ON i.objectid = b.fid_action;

-- 2. Création des commentaires sur la table et les champs
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE IS 'Vue matérialisée contenant les tronçons, voies physiques et voies administratives de la base voie. Mise à jour quotidienne à 21h00.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.objectid IS 'Clé primaire de la VM.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.id_troncon IS 'Identifiant du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.id_voie_physique IS 'Identifiant de la voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.action_sens IS 'Action sur le sens de la voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.id_voie_administrative IS 'Identifiant de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.code_insee IS 'Code INSEE de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.nom_commune IS 'Nom de la commune d''appartenance de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.type_voie IS 'Type de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.libelle_voie IS 'Libelle de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.complement_nom_voie IS 'Complément de nom de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.nom_voie IS 'Nom de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.hierarchie IS 'Hiérarchie de la voie administrative : principale ou secondaire.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.lateralite IS 'Latéralité de la voie administrative par rapport à sa voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.commentaire IS 'Commentaire de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE.geom IS 'Géométrie du tronçon de type ligne simple.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE 
ADD CONSTRAINT VM_CONSULTATION_BASE_VOIE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_CONSULTATION_BASE_VOIE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX VM_CONSULTATION_BASE_VOIE_SIDX
ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des index sur les clés étrangères et autres
CREATE INDEX VM_CONSULTATION_BASE_VOIE_ID_TRONCON_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(id_troncon)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_ID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(id_voie_physique)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_ACTION_SENS_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(action_sens)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_ID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(id_voie_administrative)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_CODE_INSEE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(code_insee)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_NOM_COMMUNE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(nom_commune)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_TYPE_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(type_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(libelle_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_COMPLEMENT_NOM_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(complement_nom_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_NOM_VOIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(nom_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_HIERARCHIE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(hierarchie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_CONSULTATION_BASE_VOIE_LATERALITE_IDX ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE(lateralite)
    TABLESPACE G_ADT_INDX;

-- 7. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE TO G_ADMIN_SIG;

/

/*
Création de la vue matérialisée VM_CONSULTATION_VOIE_ADMINISTRATIVE - du projet j de test de production - matérialisant la géométrie des voies administratives avec leur nom, code insee, latéralité et hiérarchie.
*/
-- 1. Suppression de la VM et de ses métadonnées
/*
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
START WITH TO_DATE('31-05-2023 17:00:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 120/24/1440
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
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE IS 'Vue matérialisée - du projet j de test de production - matérialisant la géométrie des voies administratives avec leur nom, code insee, latéralité et hiérarchie.';
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

/*
Création de la VM VM_CONSULTATION_VOIE_PHYSIQUE matérialisant les voies physiques, permettant de distinguer les voies dont le sens géométrique est inversé ou non.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_CONSULTATION_VOIE_PHYSIQUE';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_CONSULTATION_VOIE_PHYSIQUE" (
    ID_VOIE_PHYSIQUE, 
    TYPE_SENS, 
    GEOM
)        
REFRESH FORCE
START WITH TO_DATE('31-05-2023 17:00:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 1440/24/1440
DISABLE QUERY REWRITE AS
SELECT
    b.objectid AS id_voie_physique,
    'sens conservé' AS type_sens,
    SDO_AGGR_UNION(
        SDOAGGRTYPE(a.geom , 0.005)
    ) AS geom
FROM
    G_BASE_VOIE.TA_TRONCON a
    INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TA_LIBELLE c ON c.objectid = b.fid_action
WHERE
    c.libelle_court = 'à conserver'
GROUP BY
    b.objectid,
    'sens conservé'-- sens de saisie conservé
UNION ALL
SELECT
    b.objectid AS id_voie_physique,
    'sens inversé' AS type_sens,
    SDO_UTIL.REVERSE_LINESTRING(SDO_AGGR_UNION(SDOAGGRTYPE(a.geom , 0.005))) AS geom
FROM
    G_BASE_VOIE.TA_TRONCON a
    INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
    INNER JOIN G_BASE_VOIE.TA_LIBELLE c ON c.objectid = b.fid_action
WHERE
    c.libelle_court = 'à inverser'
GROUP BY
    b.objectid,
    'sens inversé';

-- 2. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE IS 'Vue matérialisée matérialisant les voies physiques, permettant de distinguer les voies dont le sens géométrique est inversé ou non.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE.id_voie_physique IS 'Clé primaire de la VM et identifiant des voies physiques.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE.type_sens IS 'Types de sens géométrique des voies. Si elles ont été taguées en "à inverser" dans TA_VOIE_PHYSIQUE, alors le sens géométrique de la voie a été inversé, sinon il a été conservé.';
COMMENT ON COLUMN G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE.geom IS 'Géométries de type multiligne.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_CONSULTATION_VOIE_PHYSIQUE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_CONSULTATION_VOIE_PHYSIQUE 
ADD CONSTRAINT VM_CONSULTATION_VOIE_PHYSIQUE_PK 
PRIMARY KEY (ID_VOIE_PHYSIQUE);

-- 5. Création des index
CREATE INDEX VM_CONSULTATION_VOIE_PHYSIQUE_SIDX
ON G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_CONSULTATION_VOIE_PHYSIQUE_TYPE_SENS_IDX ON G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE(type_sens)
    TABLESPACE G_ADT_INDX;

-- 6. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE TO G_ADMIN_SIG;

/

/*
Vue matérialisée permettant d'identifier les seuils distants d'1km ou plus de leur tronçon d'affectation.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM;
DELETE FROM USER_SDO_GEOM_METADATA WHERE table_name = 'VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM (
    ID_INFOS_SEUIL,
    POSITION_SEUIL,
    CODE_INSEE_SEUIL,
    ID_TRONCON,
    DISTANCE,  
    GEOM
)        
REFRESH FORCE
START WITH TO_DATE('31-05-2023 20:00:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 1
DISABLE QUERY REWRITE AS
  SELECT
    b.objectid AS id_infos_seuil,
    d.libelle_court AS position_seuil,
    a.code_insee AS code_insee_seuil,
    c.objectid AS id_troncon,
    ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
        SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
            SDO_LRS.CONVERT_TO_LRS_GEOM(c.geom, m.diminfo),
            SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(c.geom, m.diminfo), a.geom),
            0
        ),
        a.geom
    ), 2) AS distance,
    a.geom
FROM
    G_BASE_VOIE.TA_SEUIL a
    INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL b ON b.fid_seuil = a.objectid
    INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.objectid = a.fid_troncon
    INNER JOIN G_BASE_VOIE.TA_LIBELLE d ON d.objectid = a.fid_position,
    USER_SDO_GEOM_METADATA m
WHERE
    m.table_name = 'TA_TRONCON'
    AND ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
        SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
            SDO_LRS.CONVERT_TO_LRS_GEOM(c.geom, m.diminfo),
            SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(c.geom, m.diminfo), a.geom),
            0
        ),
        a.geom
    ), 2) >=1000;

-- 2. Création des commentaires
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM  IS 'Vue permettant d''identifier les seuils distants d''1km ou plus de leur tronçon d''affectation.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM.id_infos_seuil IS 'Identifiants des seuils utilisés en tant que clé primaire (objectid de TA_INFOS_SEUIL).';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM.position_seuil IS 'Position géographique du seuil (entrée du bâtiment/seuil, boîte postale, entrée de rue, portail, etc).';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM.code_insee_seuil IS 'Code INSEE de la commune dans laquelle se situe le seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM.id_troncon IS 'Identifiant du tronçon affecté au seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM.distance IS 'Distance minimale entre un seuil et le tronçon qui lui est affecté.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM.geom IS 'Champ géométrique de type point contenant la géométrie des seuils.';

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM 
ADD CONSTRAINT VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM_PK 
PRIMARY KEY (ID_INFOS_SEUIL);

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 4. Création des index
-- index spatial
CREATE INDEX VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM_SIDX
ON G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTIPOINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- Autres index  
CREATE INDEX VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM_POSITION_SEUIL_IDX ON G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM(POSITION_SEUIL)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM_CODE_INSEE_SEUIL_IDX ON G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM(CODE_INSEE_SEUIL)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM_ID_TRONCON_IDX ON G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM(ID_TRONCON)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM_DISTANCE_IDX ON G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM(DISTANCE)
    TABLESPACE G_ADT_INDX;
        
-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM TO G_ADMIN_SIG;

/

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
START WITH TO_DATE('31-05-2023 17:00:00', 'dd-mm-yyyy hh24:mi:ss')
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

/*
Création de la vue VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE dénombrant et géolocalisant les doublons de numéros de seuil par voie administrative et par commune.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE';
COMMIT;
*/

-- 1. Création de la vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE (
    OBJECTID, 
    NUMERO, 
    ID_VOIE_ADMINISTRATIVE, 
    NOM_VOIE,
    CODE_INSEE, 
    NOM_COMMUNE,
    NOMBRE,
    GEOM
)        
REFRESH FORCE
START WITH TO_DATE('31-05-2023 17:00:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 120/24/1440
DISABLE QUERY REWRITE AS
    WITH 
        C_1 AS(-- Sélection des doublons de numéro de seuil
            SELECT
                a.numero || ' ' || a.complement_numero AS numero,
                a.code_insee,
                a.nom_commune,
                a.id_voie_administrative,
                a.nom_voie,
                COUNT(a.id_seuil) AS nombre,
                SDO_CS.MAKE_2D(SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.001))) AS geom
            FROM
                G_BASE_VOIE.VM_CONSULTATION_SEUIL a
            GROUP BY
                a.numero || ' ' || a.complement_numero,
                a.code_insee,
                a.nom_commune,
                a.id_voie_administrative,
                a.nom_voie
            HAVING
                COUNT(a.id_seuil) > 1
        )

    SELECT
        rownum AS objectid,
        a.numero,
        a.id_voie_administrative,
        a.nom_voie,
        a.code_insee,
        a.nom_commune,
        a.nombre,
        a.geom
    FROM
        C_1 a;

-- 2. Création des commentaires
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE IS 'Vue matérialisée dénombrant et géolocalisant les doublons de numéros de seuil par voie administrative et par commune.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE.objectid IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE.numero IS 'Numéro du seuil (numéro + concaténation).';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE.code_insee IS 'Code INSEE de la commune d''appartenance du seuil et de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE.nom_commune IS 'Nom de la commune.';
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
CREATE INDEX VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE_NUMERO_IDX ON G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE(NUMERO)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE_CODE_INSEE_IDX ON G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE(CODE_INSEE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE_NOM_COMMUNE_IDX ON G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE(NOM_COMMUNE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE_ID_VOIE_ADMINISTRATIVE_IDX ON G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE(ID_VOIE_ADMINISTRATIVE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE_NOM_VOIE_IDX ON G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE(NOM_VOIE)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE_NOMBRE_IDX ON G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE(NOMBRE)
    TABLESPACE G_ADT_INDX;
    
-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

/*
Création de la vue matérialisée VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR - du projet j de test de production - matérialisant la géométrie des voies administratives avec leur nom, code insee, latéralité et hiérarchie.
*/
-- Suppression de la VM
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR (
    ID_SEUIL,
    ID_GEOM_SEUIL,
    CODE_INSEE_BASE,
    CODE_INSEE_CALCULE,
    GEOM
)        
REFRESH FORCE
START WITH TO_DATE('31-05-2023 17:00:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 6/24
DISABLE QUERY REWRITE AS
SELECT
    b.objectid AS id_seuil,
    a.objectid AS id_geom_seuil,
    a.code_insee AS code_insee_base,
    TRIM(GET_CODE_INSEE_97_COMMUNES_CONTAIN_POINT('TA_SEUIL', a.geom)) AS code_insee_calcule,
    a.geom
FROM
    G_BASE_VOIE.TA_SEUIL a 
    INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL b ON b.fid_seuil = a.objectid 
WHERE
    TRIM(GET_CODE_INSEE_97_COMMUNES_CONTAIN_POINT('TA_SEUIL', a.geom)) <> a.code_insee;

-- 2. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR IS 'Vue matérialisée identifiant les seuils dont le code INSEE ne correspond pas au référentiel des communes (G_REFERENTIEL.MEL_COMMUNE_LLH).';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR.id_seuil IS 'Identifiants des seuils correspondant à la clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR.id_geom_seuil IS 'Identifiants de la géométrie des seuils.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR.code_insee_base IS 'Code INSEE du seuil en base.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR.code_insee_calcule IS 'Code INSEE du seuil obtenu par requête spatiale.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR.geom IS 'Géométrie du seuil de type point.';

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR 
ADD CONSTRAINT VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR_PK 
PRIMARY KEY (ID_SEUIL);

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création des index
CREATE INDEX VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR_SIDX
ON G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

CREATE INDEX VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR_ID_GEOM_SEUIL_IDX ON G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR(id_geom_seuil)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR_CODE_INSEE_BASE_IDX ON G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR(CODE_INSEE_BASE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR_CODE_INSEE_CALCULE_IDX ON G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR(CODE_INSEE_CALCULE)
    TABLESPACE G_ADT_INDX;

-- 5. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR TO G_ADMIN_SIG;

/

/*
Création de la vue V_STAT_NOMBRE_OBJET dénombrant tous les objets de la base voie et de la base adresse.
*/
/*
DROP VIEW G_BASE_VOIE.V_STAT_NOMBRE_OBJET;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_STAT_NOMBRE_OBJET" ("OBJECTID", "TYPE_OBJET", "NOMBRE", 
    CONSTRAINT "V_STAT_NOMBRE_OBJET_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
    WITH
        C_1 AS(-- Sélection des voies physiques composées d'un seul tronçon
            SELECT
                a.fid_voie_physique
            FROM
                G_BASE_VOIE.TA_TRONCON a
            GROUP BY
                a.fid_voie_physique
            HAVING
                COUNT(a.objectid) = 1
        ),

        C_2 AS(-- Sélection des voies physiques composées de plusieurs tronçons
            SELECT
                a.fid_voie_physique
            FROM
                G_BASE_VOIE.TA_TRONCON a
            GROUP BY
                a.fid_voie_physique
            HAVING
                COUNT(a.objectid) > 1
        ),

        C_3 AS(-- Sélection des voies administratives composées d'une seule voie physique
            SELECT
                a.fid_voie_administrative
            FROM
                G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
            GROUP BY
                a.fid_voie_administrative
            HAVING
                COUNT(a.fid_voie_physique) = 1
        ),

        C_4 AS(-- Sélection des voies administratives composées de plusieurs voies physiques
            SELECT
                a.fid_voie_administrative
            FROM
                G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE a
            GROUP BY
                a.fid_voie_administrative
            HAVING
                COUNT(a.fid_voie_physique) > 1
        ),

        C_5 AS(
            SELECT
                'Seuils' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_INFOS_SEUIL
            GROUP BY
                'Seuils'
            UNION ALL
            SELECT
                'Géométries de seuil' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_SEUIL
            GROUP BY
                'Géométries de seuil'
            UNION ALL
            SELECT
                'Tronçons' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_TRONCON
            GROUP BY
                'Tronçons'
            UNION ALL
            SELECT
                'Voies physiques' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_VOIE_PHYSIQUE
            GROUP BY
                'Voies physiques'
            UNION ALL
            SELECT
                'Voies administratives' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE
            GROUP BY
                'Voies administratives'
            UNION ALL
            SELECT
                'Type de voie' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_TYPE_VOIE
            GROUP BY
                'Type de voie'
            UNION ALL
            SELECT
                'Relation seuil/tronçon' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_SEUIL
            WHERE
                fid_troncon IS NOT NULL
            GROUP BY
                'Relation seuil/tronçon'
            UNION ALL
            SELECT
                'Relation Tronçon/voie physique' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_TRONCON
            WHERE
                fid_voie_physique IS NOT NULL
            GROUP BY
                'Relation Tronçon/voie physique'
            UNION ALL
            SELECT
                'Relation voie physique/voie administrative' AS type_objet,
                COUNT(objectid) AS nb
            FROM
                G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
            WHERE
                fid_voie_physique IS NOT NULL
                AND fid_voie_administrative IS NOT NULL
            GROUP BY
                'Relation voie physique/voie administrative'
            UNION ALL
            SELECT
                'Voies physiques composées d''un seul tronçon' AS type_objet,
                COUNT(fid_voie_physique) AS nb
            FROM
                C_1
            GROUP BY
                'Voies physiques composées d''un seul tronçon'
            UNION ALL
            SELECT
                'Voies physiques composées de plusieurs tronçons' AS type_objet,
                COUNT(fid_voie_physique) AS nb
            FROM
                C_2
            GROUP BY
                'Voies physiques composées de plusieurs tronçons'
            UNION ALL
            SELECT
                'Voies administratives composées d''une seule voie physique' AS type_objet,
                COUNT(fid_voie_administrative) AS nb
            FROM
                C_3
            GROUP BY
                'Voies administratives composées d''une seule voie physique'
            UNION ALL
            SELECT
                'Voies administratives composées de plusieurs voies physiques' AS type_objet,
                COUNT(fid_voie_administrative) AS nb
            FROM
                C_4
            GROUP BY
                'Voies administratives composées de plusieurs voies physiques'
        )
        
        SELECT
            rownum AS objectid,
            type_objet,
            nb AS nombre
        FROM
            C_5;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_STAT_NOMBRE_OBJET IS 'Vue dénombrant tous les objets de la base voie et de la base adresse.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_OBJET.objectid IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_OBJET.type_objet IS 'Type d''objets de la base voie et de la base adresse.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_OBJET.nombre IS 'Nombre d''objets par type.';

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_STAT_NOMBRE_OBJET TO G_ADMIN_SIG;

/

/*
Création de la vue V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE permettant de connaître le nombre de voies administratives composées de plusieurs voies physiques et ce, dans le détail.
*/
/*
DROP VIEW G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE" (
    OBJECTID, 
    NBR_VOIE_ADMINISTRATIVE, 
    NBR_VOIE_PHYSIQUE, 
    CONSTRAINT "V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
WITH
    C_1 AS(
        SELECT
            fid_voie_administrative,
            COUNT(fid_voie_physique) AS nb_voie_physique
        FROM
            G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE
        GROUP BY
            fid_voie_administrative
    ),
    
    C_2 AS(
        SELECT
            COUNT(fid_voie_administrative) AS nb_voie_administrative,
            nb_voie_physique
        FROM
            C_1
        GROUP BY
            nb_voie_physique
    )
    
    SELECT
        rownum AS objectid,
        nb_voie_administrative,
        nb_voie_physique
    FROM
        C_2;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE IS 'Vue permettant de connaître le nombre de voies administratives réparties par le nombre de voies physiques les composant.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE.objectid IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE.nbr_voie_administrative IS 'Nombre de voies administratives réparties par le nombre de voies physiques les composant.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE.nbr_voie_physique IS 'Nombre de voies physiques.';

-- 3. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE TO G_ADMIN_SIG;

/

/*
Création de la vue V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE dénombrant tous les objets de la base voie et de la base adresse.
*/
/*
DROP VIEW G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE;
*/

-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE" (
    OBJECTID, 
    NOMBRE, 
    GEOM, 
    CONSTRAINT "V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
    WITH
        C_1 AS(
            SELECT
                a.fid_seuil,
                COUNT(a.objectid) AS nombre
            FROM
                G_BASE_VOIE.TA_INFOS_SEUIL a
            GROUP BY 
                a.fid_seuil
            HAVING
                COUNT(a.objectid) > 1
        )
        
        SELECT
            a.objectid,
            b.nombre,
            a.geom
        FROM
            G_BASE_VOIE.TA_SEUIL a
            INNER JOIN C_1 b ON b.fid_seuil = a.objectid;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE IS 'Vue dénombrant les seuils partageant la même géométrie (seules les géométries associées à plusieurs seuils sont sélectionnées dans cette vue).';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE.objectid IS 'Clé primaire de la vue correspondant aux identifiants des géométries des seuils présents dans G_BASE_VOIE.TA_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE.nombre IS 'Nombre de seuils (de la table G_BASE_VOIE_INFOS_SEUIL) par géométrie. Seuls les géométries associées à plusieurs seuils sont présentes dans cette table.';
COMMENT ON COLUMN G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE.geom IS 'Géométrie de type point.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE TO G_ADMIN_SIG;

/

