/*
Création de la vue matérialisée VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT - de la structure tampon du projet LITTERALIS - faisant le lien entre les domanialités de la DEPV et les classements du format LITTERALIS. Mise à jour le dernier dimanche du mois à 08h00.
*/
-- Suppression de la VM
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT (
    objectid,
    domanialite, 
    classement
)        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(
        SELECT DISTINCT
            domania
        FROM
            SIREO_LEC.OUT_DOMANIALITE
    )

    SELECT
        rownum AS objectid,
        a.domania,
        CASE 
            WHEN a.domania = 'AUTOROUTE OU VOIE A CARACTERE AUTOROUTIER'
                THEN 'A'
            WHEN a.domania = 'ROUTE NATIONALE'
                THEN 'RN' -- Route Nationale
            WHEN a.domania IN ('VOIE PRIVEE ENTRETENUE PAR LA CUDL','VOIE PRIVEE FERMEE','VOIE PRIVEE OUVERTE','AUTRE VOIE PRIVEE','DECLASSEMENT EN COURS')
                THEN 'VP' -- Voie Privée
            WHEN a.domania = 'CHEMIN RURAL'
                THEN 'CR' -- Chemin Rural
            WHEN a.domania IN ('VOIE METROPOLITAINE','GESTION COMMUNAUTAIRE','AUTRE VOIE PUBLIQUE')
                THEN 'VC' -- Voie Communale
            WHEN a.domania IS NULL
                THEN 'VC' -- Voie Communale
        END AS CLASSEMENT
    FROM
        C_1 a;

-- 2. Création des commentaires sur la table et les champs
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT IS 'Vue matérialisée - de la structure tampon du projet LITTERALIS - faisant le lien entre les domanialités de la DEPV et les classements du format LITTERALIS. Mise à jour le dernier dimanche du mois à 08h00.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT.objectid IS 'Clé primaire de la VM.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT.domanialite IS 'Domanialités présentes dans la table SIREO_LEC.OUT_DOMANIALITE associant un tronÃ§on et son/ses sous-tronÃ§on(s) à une domanialité au format MEL.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT.classement IS 'Classement du tronÃ§on au format LITTERALIS.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT
ADD CONSTRAINTS VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT_PK
PRIMARY KEY(OBJECTID)
USING INDEX TABLESPACE "G_ADT_INDX";

-- 5. Création des index
CREATE INDEX VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT_DOMANIALITE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT(DOMANIALITE)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT_CLASSEMENT_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT(CLASSEMENT)
TABLESPACE G_ADT_INDX;

-- 6. Affection des droits
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT TO G_ADMIN_SIG;

/

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

/*
Création de la vue matérialisée VM_TAMPON_LITTERALIS_TRONCON - de la structure tampon du projet LITTERALIS - regroupant les tronÃ§ons de la table TA_TRONCON les informations nécessaires à l''export LITTERALIS.
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
    C_1 AS(-- Sélection des tronÃ§ons composés de plusieurs sous-tronÃ§ons de domanialités différentes
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
    
    C_3 AS(-- Si un tronÃ§on se compose de plusieurs sous-tronÃ§ons de domanialités différentes, alors on utilise le système de priorité de la DEPV (présent dans G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT) pour déterminer une domanialité pour le tronÃ§on
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
    
    C_4 AS(-- Sélection des tronÃ§ons n'ayant qu'une seule domanialité
        SELECT
            cnumtrc
        FROM
            SIREO_LEC.OUT_DOMANIALITE
        GROUP BY
            cnumtrc
        HAVING
            COUNT(DISTINCT domania) = 1  
    ),
    
    C_5 AS(-- Mise en forme des tronÃ§ons ayant une seule domanialité et compilation avec ceux disposant de deux domanialités dans les tables source 
        SELECT DISTINCT --Le DISTINCT est indispensable car certains tronÃ§ons peuvent être composés de plusieurs sous-tronÃ§ons de même domanialité
            d.id_troncon,
            CAST(d.id_troncon AS VARCHAR2(254 BYTE)) AS code_tronc,
            c.classement,
            d.id_voie_physique,
            d.id_voie_administrative,
            d.lateralite_voie_administrative AS lateralite
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
            b.lateralite_voie_administrative AS lateralite
        FROM
            C_3 a
            INNER JOIN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE b ON b.id_troncon = a.cnumtrc
        UNION ALL
        SELECT -- Sélection des tronÃ§ons n'ayant pas de domanialité - dans ce cas le classement est 'VC'
            a.objectid,
            CAST(a.objectid AS VARCHAR2(254 BYTE)) AS code_tronc,
            'VC' AS classement,
            a.id_voie_physique,
            a.id_voie_administrative,
            a.lateralite_voie_administrative AS lateralite
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
        a.id_troncon AS objectid,
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
        AND a.id_troncon NOT IN(1851, 51654, 90222);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON IS 'Vue matérialisée - de la structure tampon du projet LITTERALIS - regroupant les tronÃ§ons de la table TA_TRONCON les informations nécessaires à l''export LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.GEOMETRY IS 'Géométrie des tronÃ§ons de ligne simple.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.OBJECTID IS 'Clé primaire de la VM correspondant aux identifiants des tronÃ§ons de la table TA_TRONCON.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.CODE_TRONC IS 'Identifiant du tronÃ§on au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.CLASSEMENT IS 'Domanialité de chaque voie respectant les règles de priorité de la DEPV (TYPOVOIE.COD_DOMANIALITE).';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.ID_VOIE_DROITE IS 'Identifiant de la voie administrative associée au tronÃ§on et située à droite de la voie physique à laquelle il est associé.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.ID_VOIE_GAUCHE IS 'Identifiant de la voie administrative associée au tronÃ§on et située à gauche de la voie physique à laquelle il est associé.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.CODE_INSEE_VOIE_DROITE IS 'Code INSEE de la voie administrative associée au tronÃ§on et située à droite de la voie physique à laquelle il est associé.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.CODE_INSEE_VOIE_GAUCHE IS 'Code INSEE de la voie administrative associée au tronÃ§on et située à gauche de la voie physique à laquelle il est associé.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.NOM_VOIE_DROITE IS 'Nom de la voie administrative (type + nom + complément de nom + Annexe 1,2,3,etc pour les voies secondaires) associée au tronÃ§on et située à droite de la voie physique à laquelle il est associé.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON.NOM_VOIE_GAUCHE IS 'Nom de la voie administrative (type + nom + complément de nom + Annexe 1,2,3,etc pour les voies secondaires) associée au tronÃ§on et située à gauche de la voie physique à laquelle il est associé.';

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
/*
Création de la vue matérialisée VM_TAMPON_LITTERALIS_ADRESSE - de la structure tampon du projet LITTERALIS - regroupant les données des seuils des tables TA_INFOS_SEUIL et TA_SEUIL.
*/
-- Suppression de la VM
/*
DROP INDEX VM_TAMPON_LITTERALIS_ADRESSE_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TAMPON_LITTERALIS_ADRESSE';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE (
    geometry, 
    objectid, 
    code_point, 
    code_voie, 
    nature, 
    libelle, 
    numero, 
    repetition, 
    cote, 
    fid_voie
)        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(
        SELECT DISTINCT
            a.id_seuil AS OBJECTID,
            a.id_geom,
            CAST(d.objectid AS VARCHAR2(254 BYTE)) AS CODE_VOIE,
            CAST(a.id_seuil AS VARCHAR2(254)) AS CODE_POINT,
            d.objectid AS ID_VOIE,
            b.objectid AS ID_TRONCON,
            c.id_voie_physique,
            CAST('ADR' AS VARCHAR2(254)) AS NATURE,
            d.nom_voie AS LIBELLE,
            CAST(a.numero  AS NUMBER(8,0)) AS NUMERO,
            CAST(TRIM(a.complement_numero) AS VARCHAR2(254)) AS REPETITION,
            CASE
                WHEN c.lateralite_voie_administrative = 'droit'
                    THEN 'Pair'
                WHEN c.lateralite_voie_administrative = 'gauche'
                    THEN 'Impair'
                ELSE
                    'LesDeuxCotes' 
            END AS COTE
        FROM
            G_BASE_VOIE.VM_CONSULTATION_SEUIL a
            INNER JOIN G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON b ON b.objectid = a.id_troncon
            INNER JOIN G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE c ON c.id_troncon = b.objectid AND c.code_insee = a.code_insee
            INNER JOIN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE d ON d.objectid = c.id_voie_administrative AND c.code_insee = CASE WHEN a.code_insee IN('59355', '59298') THEN '59350' ELSE a.code_insee END
        WHERE
            -- Cette condition est nécessaire pour supprimer certains doublons de code_voie, nature, numero, repetition : le numéro 97T est en doublon (doublon aussi dans la BdTopo) car il est affecté à deux parcelles.
            a.id_seuil NOT IN(241295, 32915, 423830, 405371, 405372, 405373, 403572, 405374, 429444, 418366, 37897, 39111, 41292, 41293, 426054, 355617, 359366, 359365, 359364, 359363, 359362, 359361, 359360, 359244, 51594, 64736, 65124, 393958, 373827, 394209, 65585, 65583, 65581, 65580, 65579, 65584, 65582, 373826, 373825, 394325, 418154, 418155, 374459, 81178, 90190, 90189, 330688, 368214, 393303, 106029, 330781, 330782, 428501, 145112, 330819, 383476, 383475, 145111, 145716, 330862, 125358, 383284, 126822, 427937, 428676, 429030, 428198, 330981, 428178, 328367, 369418, 328368, 142229, 428687, 427810, 333163, 159049, 374858, 367335, 429551, 398549, 189812, 189114, 380857, 206308, 384462, 431311, 376634, 27207, 27261, 242734, 242735, 242736, 242743, 407604, 407605, 407606, 407593, 407594, 407595, 407596, 407597, 407518, 406363, 406364, 406365, 243643, 247063, 247068, 367139, 379324, 249233, 430507, 430735, 430691, 256788, 256787, 256789, 256790, 257524, 258408, 367564, 396741, 294271, 302007, 377745, 5754, 377746, 377743, 370688, 370964, 324107, 371347, 326672, 29744, 5755, 5757, 8858, 429850, 429851, 392134, 371755)
    )
    
    SELECT
        b.GEOM,
        a.OBJECTID,
        a.CODE_POINT,
        a.CODE_VOIE,
        a.NATURE,
        a.LIBELLE,
        a.NUMERO,
        a.REPETITION,
        a.COTE,
        a.ID_VOIE
    FROM
        C_1 a
        INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.id_geom;

-- 2. Création des commentaires sur la table et les champs
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE IS 'Vue matérialisée - de la structure tampon du projet LITTERALIS - regroupant les données des seuils des tables TA_INFOS_SEUIL et TA_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE.GEOMETRY IS 'Géométrie du seuil de type point.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE.OBJECTID IS 'Clé primaire de la table correspondant aux identifiants des seuils de la table TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE.CODE_POINT IS 'Identifiant des seuils au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE.CODE_VOIE IS 'Identifiant de la voie associée au seuil et présente dans TA_TAMPON_VOIE_ADMINISTRATIVE.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE.NATURE IS 'Nature du seuil : ADR = Adresse.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE.LIBELLE IS 'Libellé du point au format LITTERALIS. C''est le libellé qui sera affiché sur les arrêtés.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE.NUMERO IS 'Numéro du seuil sur la voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE.REPETITION IS 'Valeur de répétition d''un numéro sur une rue (quand elle existe).';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE.COTE IS 'Côté du seuil par rapport à la voie : LesDeuxCotes ; Impair ; Pair.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE
ADD CONSTRAINTS VM_TAMPON_LITTERALIS_ADRESSE_PK
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
    'VM_TAMPON_LITTERALIS_ADRESSE',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 6. Création de l'index spatial sur le champ geom
CREATE INDEX VM_TAMPON_LITTERALIS_ADRESSE_SIDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

CREATE INDEX VM_TAMPON_LITTERALIS_ADRESSE_CODE_POINT_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE(CODE_POINT)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_ADRESSE_CODE_VOIE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE(CODE_VOIE)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_ADRESSE_NATURE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE(NATURE)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_ADRESSE_LIBELLE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE(LIBELLE)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_ADRESSE_NUMERO_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE(NUMERO)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_ADRESSE_REPETITION_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE(REPETITION)
TABLESPACE G_ADT_INDX;

-- 6. Affection des droits
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE TO G_ADMIN_SIG;

/

/*
Création de la vue matérialisée G_BASE_VOIE.VM_TERRITOIRE_VOIRIE qui regroupe les secteurs de voirie par territoire de voirie.
ATTENTION : ces territoires sont différents des territoires du référentiel administratif du schéma G_REFERENTIEL.
*/
-- Suppression de la VM
/*
DROP INDEX VM_TERRITOIRE_VOIRIE_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TERRITOIRE_VOIRIE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TERRITOIRE_VOIRIE';
COMMIT;
*/
-- 1. Création de la vue matérialisée
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TERRITOIRE_VOIRIE(
    identifiant,
    nom,
    type,
    geometry
)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
    1,
    'UTLS 1' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'LILLE OUEST',
        'LILLE SUD'
    )
UNION ALL
SELECT
    2,
    'UTLS 2' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'LILLE NORD',
        'LILLE CENTRE'
    )
UNION ALL
SELECT
    3,
    'UTLS 3' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'RONCHIN',
        'COURONNE SUD'
    )
UNION ALL
SELECT
    4,
    'UTLS 4' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'CCHD-SECLIN',
        'COURONNE OUEST'
    )
UNION ALL
SELECT
    5,
    'UTML 1' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'HAUBOURDIN',
        'WAVRIN',
        'BASSEEN'
    )
UNION ALL
SELECT
    6,
    'UTML 2' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'WEPPES',
        'MARCQUOIS'
    )
UNION ALL
SELECT
    7,
    'UTML 3' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'LAMBERSART',
        'WAMBRECHIES'
    )
UNION ALL
SELECT
    8,
    'UTRV 1' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'WATTRELOS',
        'ROUBAIX OUEST',
        'ROUBAIX EST'
    )
UNION ALL
SELECT
    9,
    'UTRV 2' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'CROIX',
        'LANNOY',
        'LEERS'
    )
UNION ALL
SELECT
    10,
    'UTRV 3' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'VA OUEST',
        'VA EST',
        'MELANTOIS'
    )
UNION ALL
SELECT
    11,
    'UTTA 1' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'ARMENTIERES',
        'HOUPLINES'
    )
UNION ALL
SELECT
    12,
    'UTTA 2' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'COMINES HALLUIN',
        'BONDUES'
    )
UNION ALL
SELECT
    13,
    'UTTA 3' AS NOM,
    'Territoire' AS TYPE,
    SDO_AGGR_UNION(SDOAGGRTYPE(a.geom, 0.005)) AS GEOMETRY
FROM
    G_BASE_VOIE.TA_SECTEUR_VOIRIE a
WHERE
    a.NOM IN(
        'TOURCOING NORD',
        'TOURCOING SUD',
        'MOUVAUX-NEUVILLE'
    );

-- 2. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TERRITOIRE_VOIRIE',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TERRITOIRE_VOIRIE 
ADD CONSTRAINT VM_TERRITOIRE_VOIRIE_PK 
PRIMARY KEY (IDENTIFIANT);

-- 4. Création de l'index spatial
CREATE INDEX VM_TERRITOIRE_VOIRIE_SIDX
ON G_BASE_VOIE.VM_TERRITOIRE_VOIRIE(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTIPOLYGON, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 5. Création des commentaires de table et de colonnes
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TERRITOIRE_VOIRIE IS 'Vue matérialisée proposant les Territoires de la voirie. ATTENTION : ces territoires sont différents des territoires du référentiel administratif du schéma G_REFERENTIEL.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TERRITOIRE_VOIRIE.identifiant IS 'Clé primaire de chaque enregistrement.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TERRITOIRE_VOIRIE.nom IS 'Nom de chaque territoire.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TERRITOIRE_VOIRIE.geometry IS 'géométries des Territoires.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TERRITOIRE_VOIRIE.type IS 'Type de regroupement.';

/

/*
Création de la vue matérialisée VM_UNITE_TERRITORIALE_VOIRIE proposant les Unités Territoriales de la voirie.
*/
-- Suppression de la VM
/*
DROP INDEX VM_UNITE_TERRITORIALE_VOIRIE_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_UNITE_TERRITORIALE_VOIRIE';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE (
    identifiant,
    nom,
    type,
    geometry
)        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
  WITH 
    C_1 AS(-- Création de l'UT LS
    SELECT
        'UTLS' AS NOM,
        'Unité Territoriale' AS TYPE,
        SDO_AGGR_UNION(SDOAGGRTYPE(a.geometry, 0.005)) AS GEOMETRY
    FROM
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE a
    WHERE
        a.identifiant IN(1, 2, 3)
    GROUP BY
        'UTLS',
        'Unité Territoriale'
    ),

    C_2 AS(
    SELECT
        'UTLS' AS NOM, 
        'Unité Territoriale' AS TYPE,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        C_1 a,
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE b
    WHERE
        b.identifiant = 4
    ),
    
    C_3 AS(-- Création de l'UT ML
    SELECT
        'UTML' AS NOM, 
        'Unité Territoriale' AS TYPE,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE a,
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE b
    WHERE
        a.identifiant = 5
        AND b.identifiant = 6
    ),
    
    C_4 AS(
    SELECT
        'UTML' AS NOM, 
        'Unité Territoriale' AS TYPE,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        C_3 a,
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE b
    WHERE
        b.identifiant = 7
    ),
    
    C_5 AS(-- Création de l'UT RV
    SELECT
        'UTRV' AS NOM, 
        'Unité Territoriale' AS TYPE,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE a,
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE b
    WHERE
        a.identifiant = 8
        AND b.identifiant = 9
    ),
    
    C_6 AS(
    SELECT
        'UTRV' AS NOM, 
        'Unité Territoriale' AS TYPE,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        C_5 a,
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE b
    WHERE
        b.identifiant = 10
    ),
    
    C_7 AS(-- Création de l'UT TA
    SELECT
        'UTTA' AS NOM, 
        'Unité Territoriale' AS TYPE,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE a,
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE b
    WHERE
        a.identifiant = 11
        AND b.identifiant = 12
    ),
    
    C_8 AS(
    SELECT
        'UTTA' AS NOM, 
        'Unité Territoriale' AS TYPE,
        SDO_GEOM.SDO_UNION(a.geometry, b.geometry, 0.005) AS geometry
    FROM
        C_7 a,
        G_BASE_VOIE.VM_TERRITOIRE_VOIRIE b
    WHERE
        b.identifiant = 13
    )
    
    SELECT
        1 AS identifiant,
        nom,
        type,
        geometry
    FROM
        C_2
    UNION ALL
    SELECT
        2 AS identifiant,
        nom,
        type,
        geometry
    FROM
        C_4
    UNION ALL
    SELECT
        3 AS identifiant,
        nom,
        type,
        geometry
    FROM
        C_6
    UNION ALL
    SELECT
        4 AS identifiant,
        nom,
        type,
        geometry
    FROM
        C_8;

-- 2. Création des commentaires de la vue matérialisée
COMMENT ON MATERIALIZED VIEW "G_BASE_VOIE"."VM_UNITE_TERRITORIALE_VOIRIE"  IS 'Vue matérialisée proposant les Unités Territoriales de la voirie.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_UNITE_TERRITORIALE_VOIRIE"."IDENTIFIANT" IS 'Clé primaire de chaque enregistrement.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_UNITE_TERRITORIALE_VOIRIE"."NOM" IS 'Nom de chaque Unité Territoriale.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_UNITE_TERRITORIALE_VOIRIE"."TYPE" IS 'Type de regroupement.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_UNITE_TERRITORIALE_VOIRIE"."GEOMETRY" IS 'géométries des Unités Territoriales.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE 
ADD CONSTRAINT VM_UNITE_TERRITORIALE_VOIRIE_PK 
PRIMARY KEY("IDENTIFIANT") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_UNITE_TERRITORIALE_VOIRIE',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création des index
CREATE INDEX VM_UNITE_TERRITORIALE_VOIRIE_SIDX
ON G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE (GEOMETRY) 
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS ('sdo_indx_dims=2, layer_gtype=MULTIPOLYGON, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

CREATE INDEX VM_UNITE_TERRITORIALE_VOIRIE_NOM_IDX
ON G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE(NOM)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_UNITE_TERRITORIALE_VOIRIE_TYPE_IDX
ON G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE(TYPE)
TABLESPACE G_ADT_INDX;

-- 6. Affection des droits de lecture
GRANT SELECT ON G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE TO G_ADMIN_SIG;

/   

/*
Création de la vue matérialisée VM_TAMPON_LITTERALIS_REGROUPEMENT - regroupant regroupements administratifs territoriaux pour le projet LITTERALIS du service voirie.
*/
-- Suppression de la VM
/*
DROP INDEX VM_TAMPON_LITTERALIS_REGROUPEMENT_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TAMPON_LITTERALIS_REGROUPEMENT';
COMMIT;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT (
    CODE_REGR, 
    NOM, 
    CODE_INSEE, 
    TYPE, 
    GEOMETRY
)        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
    WITH
        C_1 AS(
            SELECT
                TRIM(UPPER(SUBSTR(a.nom, 0, 1)) || LOWER(SUBSTR(a.nom, 2, LENGTH(a.nom)))) AS nom,
                'Zone' AS TYPE,
                '' AS code_insee,
                a.geom AS geometry
            FROM
                G_BASE_VOIE.TA_SECTEUR_VOIRIE a
            UNION ALL
            SELECT
                TRIM(UPPER(SUBSTR(nom, 0, 1)) || LOWER(SUBSTR(nom, 2, LENGTH(nom)))) AS nom,
                'Zone' AS type,
                '' AS code_insee,
                geometry
            FROM
                G_BASE_VOIE.VM_TERRITOIRE_VOIRIE
            UNION ALL
            SELECT
                TRIM(UPPER(SUBSTR(nom, 0, 1)) || LOWER(SUBSTR(nom, 2, LENGTH(nom)))) AS nom,
                'Zone' AS type,
                '' AS code_insee,
                geometry
            FROM
                G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE
        )
    SELECT
        CAST(ROWNUM AS VARCHAR2(254 BYTE)) AS code_regr,
        CAST(a.nom AS VARCHAR2(254 BYTE)) AS nom,
        CAST(a.code_insee AS VARCHAR2(254 BYTE)) AS code_insee,
        CAST(a.type AS VARCHAR2(254 BYTE)) AS type,
        a.geometry
    FROM
        C_1 a;

-- 2. Création des commentaires de la vue matérialisée
COMMENT ON MATERIALIZED VIEW "G_BASE_VOIE"."VM_TAMPON_LITTERALIS_REGROUPEMENT"  IS 'Vue matérialisée des regroupements administratifs territoriaux pour le projet LITTERALIS du service voirie.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TAMPON_LITTERALIS_REGROUPEMENT"."CODE_REGR" IS 'Identificateur unique et immuable du regroupement partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TAMPON_LITTERALIS_REGROUPEMENT"."NOM" IS 'Nom du regroupement.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TAMPON_LITTERALIS_REGROUPEMENT"."CODE_INSEE" IS 'Code INSEE de la commune. Etant donné que les secteurs (regoupements à partir desquels tous les autres sont construits) peuvent recouvrir une partie de commune (Lille) il a été décidé avec le prestataire de ne mettre aucun code INSEE.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TAMPON_LITTERALIS_REGROUPEMENT"."TYPE" IS 'Type de regroupement. A la demande du prestataire, le type est "Zone" pour tous les types de regroupements (sous-territoires, territoires, unités territoriales) afin que les données s''insèrent correctement dans leur application... Bref.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_TAMPON_LITTERALIS_REGROUPEMENT"."GEOMETRY" IS 'Géométries de type surfacique.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT 
ADD CONSTRAINT VM_TAMPON_LITTERALIS_REGROUPEMENT_PK 
PRIMARY KEY("CODE_REGR") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TAMPON_LITTERALIS_REGROUPEMENT',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création des index
CREATE INDEX VM_TAMPON_LITTERALIS_REGROUPEMENT_SIDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTIPOLYGON, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

CREATE INDEX VM_TAMPON_LITTERALIS_REGROUPEMENT_NOM_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT(NOM)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_REGROUPEMENT_CODE_INSEE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT(CODE_INSEE)
TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TAMPON_LITTERALIS_REGROUPEMENT_TYPE_IDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT(TYPE)
TABLESPACE G_ADT_INDX;

-- 6. Affection des droits de lecture
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT TO G_ADMIN_SIG;

/


/*
Création de la VM VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION - de la structure tampon du projet LITTERALIS - faisant la fusion de toutes les zones d'agglomération permettant d'accélérer la distinction des voies en/hors zone d'agglomération.
*/
/*
DROP INDEX VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION';
COMMIT;
*/

CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION(OBJECTID, GEOM)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
    WITH
        C_1 AS(
            SELECT 
                SDO_AGGR_UNION(SDOAGGRTYPE(geom, 0.005)) AS geom
            FROM
                G_VOIRIE.SIVR_ZONE_AGGLO
        )
        
        SELECT
            rownum,
            SDO_GEOM.SDO_SELF_UNION(geom, 0.001)
        FROM
            C_1;

-- 2. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION IS 'Vue matérialisée - de la structure tampon du projet LITTERALIS - faisant la fusion de toutes les zones d''agglomération de la voirie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION.objectid IS 'Clé primaire de la VM.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION.geom IS 'Géométrie de type multipolygone.';

-- 3. Remplissage des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION 
ADD CONSTRAINT VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION_PK 
PRIMARY KEY (OBJECTID);

-- 5. Création de l'index spatial
CREATE INDEX VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION_SIDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTIPOLYGON, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 6. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION TO G_ADMIN_SIG;

/

/*
Création de la VM VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO rassemblant les voies complètement contenues dans une zone d'agglomération
*/
/*
DROP INDEX VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO';
COMMIT;
*/

CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO(
    OBJECTID, 
    TYPE_ZONE, 
    CODE_VOIE, 
    COTE_VOIE, 
    CODE_INSEE, 
    CATEGORIE, 
    GEOMETRY
)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(
        SELECT DISTINCT-- Sélection des voies entièrement incluses dans les zones d''agglomération
            CAST('Agglomeration' AS VARCHAR2(254)) AS type_zone,
            a.id_voie_administrative AS code_voie,
            CASE
                WHEN a.lateralite = 'droit'
                    THEN 'Droit'
                WHEN a.lateralite = 'gauche'
                    THEN 'Gauche'
                WHEN a.lateralite = 'les deux côtés'
                    THEN 'LesDeuxCotes' 
                END AS cote_voie,
            a.code_insee,
            0 AS categorie
        FROM
            G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE a,
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION b
        WHERE
            SDO_CONTAINS(b.geom, a.geom) = 'TRUE'
    )

    SELECT
        rownum AS objectid,
        a.type_zone,
        CAST(a.code_voie AS VARCHAR2(254)) AS code_voie,
        CAST(a.cote_voie AS VARCHAR2(254)) AS cote_voie,
        CAST(a.code_insee AS VARCHAR2(254)) AS code_insee,
        CAST(a.categorie AS NUMBER(8)) AS categorie,
        b.geom AS geometry
    FROM
        C_1 a
        INNER JOIN G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE b ON b.id_voie_administrative = a.code_voie;

-- 2. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO IS 'Vue matérialisée - pour le projet LITTERALIS - regroupant toutes les voies totalement contenues dans une agglomération.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO.OBJECTID IS 'Clé primaire de la vue matérialisée.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO.TYPE_ZONE IS 'Type de zone : Agglomeration ; InteretCommunautaire';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO.CODE_VOIE IS 'Liaison avec la classe TRONCON sur la colonne CODE_RUE_G ou CODE_RUE_D';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO.COTE_VOIE IS 'Définit sur quel côté de la voie s''appuie la zone particulière : LesDeuxCotes, Gauche, Droit.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO.CODE_INSEE IS 'Code INSEE de la commune. Obligatoire pour les entrées Commune et Agglomeration.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO.CATEGORIE IS 'Valeur définissant la catégorie de la rue sur cette zone';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO.GEOMETRY IS 'Géométrie de type multiligne.';

-- 3. Remplissage des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO 
ADD CONSTRAINT VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO_PK 
PRIMARY KEY (OBJECTID);

-- 5. Création de l'index spatial
CREATE INDEX VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO_SIDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 6. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO TO G_ADMIN_SIG;

/

/*
Création de la VM VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO- pour le projet LITTERALIS - regroupant toutes les parties de voie intersectant une agglomération.
*/
/*
DROP INDEX VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO';
COMMIT;
*/

CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO(
    OBJECTID, 
    TYPE_ZONE, 
    CODE_VOIE, 
    COTE_VOIE, 
    CODE_INSEE, 
    CATEGORIE, 
    GEOMETRY
)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(
        SELECT -- Sélection des voies distantes d''1mm des zones d'agglomération
            'InteretCommunautaire' AS type_zone,
            a.id_voie_administrative AS code_voie,
            CASE
                WHEN a.lateralite = 'droit'
                    THEN 'Droit'
                WHEN a.lateralite = 'gauche'
                    THEN 'Gauche'
                WHEN a.lateralite = 'les deux côtés'
                    THEN 'LesDeuxCotes' 
                END AS cote_voie,
            a.code_insee,
            0 AS categorie,
            a.geom
        FROM
            G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE a,
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION b,
            USER_SDO_GEOM_METADATA c,
            USER_SDO_GEOM_METADATA d
        WHERE
            c.table_name = 'VM_CONSULTATION_VOIE_ADMINISTRATIVE'
            AND d.table_name = 'VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION'
            AND SDO_GEOM.SDO_DISTANCE(a.geom, c.diminfo, b.geom, d.diminfo)>0.001
        UNION ALL
        SELECT -- Sélection des voies touchant uniquement le périmètre extérieur des zones d''agglomération
            'InteretCommunautaire' AS type_zone,
            a.id_voie_administrative AS code_voie,
            CASE
                WHEN a.lateralite = 'droit'
                    THEN 'Droit'
                WHEN a.lateralite = 'gauche'
                    THEN 'Gauche'
                WHEN a.lateralite = 'les deux côtés'
                    THEN 'LesDeuxCotes' 
                END AS cote_voie,
            a.code_insee,
            0 AS categorie,
            a.geom
        FROM
            G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE a,
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION b
        WHERE
             SDO_TOUCH(a.geom, b.geom) = 'TRUE'
    )

    SELECT
        rownum AS objectid,
        CAST(a.type_zone AS VARCHAR2(254)) AS type_zone,
        CAST(a.code_voie AS VARCHAR2(254)) AS code_voie,
        CAST(a.cote_voie AS VARCHAR2(254)) AS cote_voie,
        CAST(a.code_insee AS VARCHAR2(254)) AS code_insee,
        CAST(a.categorie AS NUMBER(8)),
        a.geom AS geometry
    FROM
        C_1 a;

-- 2. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO IS 'Vue matérialisée - pour le projet LITTERALIS - regroupant toutes les voies situées complètement hors agglomération.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO.OBJECTID IS 'Clé primaire de la vue matérialisée.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO.TYPE_ZONE IS 'Type de zone : Agglomeration ; InteretCommunautaire';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO.CODE_VOIE IS 'Liaison avec la classe TRONCON sur la colonne CODE_RUE_G ou CODE_RUE_D';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO.COTE_VOIE IS 'Définit sur quel côté de la voie s''appuie la zone particulière : LesDeuxCotes, Gauche, Droit.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO.CODE_INSEE IS 'Code INSEE de la commune. Obligatoire pour les entrées Commune et Agglomeration.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO.CATEGORIE IS 'Valeur définissant la catégorie de la rue sur cette zone';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO.GEOMETRY IS 'Géométrie de type multiligne.';

-- 3. Remplissage des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO 
ADD CONSTRAINT VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO_PK 
PRIMARY KEY (OBJECTID);

-- 5. Création de l'index spatial
CREATE INDEX VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO_SIDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 6. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO TO G_ADMIN_SIG;

/

/*
Création de la VM VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO- pour le projet LITTERALIS - regroupant toutes les parties de voie intersectant une agglomération.
*/
/*
DROP INDEX VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO';
COMMIT;
*/

CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO(
    OBJECTID, 
    TYPE_ZONE, 
    CODE_VOIE, 
    COTE_VOIE, 
    CODE_INSEE, 
    CATEGORIE, 
    GEOMETRY
)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH C_1 AS( -- Pour toutes les voies intersectant les zones d'agglomération, on sélectionne uniquement la partie située à l''intérieur des zones
        SELECT
            'Agglomeration' AS type_zone,
            a.id_voie_administrative AS code_voie,
            CASE
                WHEN a.lateralite = 'droit'
                    THEN 'Droit'
                WHEN a.lateralite = 'gauche'
                    THEN 'Gauche'
                WHEN a.lateralite = 'les deux côtés'
                    THEN 'LesDeuxCotes' 
                END AS cote_voie,
            a.code_insee,
            0 AS categorie,
           SDO_GEOM.SDO_INTERSECTION(a.geom, b.geom, 0.005) AS geometry
        FROM
            G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE a,
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION b
        WHERE
            SDO_GEOM.SDO_INTERSECTION(a.geom, b.geom, 0.005).sdo_gtype IN(2002, 2006)
            AND SDO_RELATE(a.geom, b.geom, 'mask=OVERLAPBDYDISJOINT+OVERLAPBDYINTERSECT') = 'TRUE'
    ),

    C_2 AS(
        SELECT
            rownum AS objectid,
            type_zone,
            code_voie,
            cote_voie,
            code_insee,
            categorie,
            geometry
        FROM
            C_1
    ),

    C_3 AS(
        SELECT
            MIN(objectid) AS objectid,
            type_zone,
            code_voie,
            cote_voie,
            code_insee,
            categorie
        FROM
            C_2
        GROUP BY
            type_zone,
            code_voie,
            cote_voie,
            code_insee,
            categorie
    )

    SELECT
        rownum AS objectid,
        CAST(a.type_zone AS VARCHAR2(254)) AS type_zone,
        CAST(a.code_voie AS VARCHAR2(254)) AS code_voie,
        CAST(a.cote_voie AS VARCHAR2(254)) AS cote_voie,
        CAST(a.code_insee AS VARCHAR2(254)) AS code_insee,
        CAST(a.categorie AS NUMBER(8)) AS categorie,
        a.geometry
    FROM
        C_2 a
        INNER JOIN C_3 b ON b.objectid = a.objectid;

-- 2. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO IS 'Vue matérialisée - pour le projet LITTERALIS - regroupant toutes les parties de voie intersectant une agglomération.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO.OBJECTID IS 'Clé primaire de la vue matérialisée.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO.TYPE_ZONE IS 'Type de zone : Agglomeration ; InteretCommunautaire';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO.CODE_VOIE IS 'Liaison avec la classe TRONCON sur la colonne CODE_RUE_G ou CODE_RUE_D';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO.COTE_VOIE IS 'Définit sur quel côté de la voie s''appuie la zone particulière : LesDeuxCotes, Gauche, Droit.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO.CODE_INSEE IS 'Code INSEE de la commune. Obligatoire pour les entrées Commune et Agglomeration.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO.CATEGORIE IS 'Valeur définissant la catégorie de la rue sur cette zone';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO.GEOMETRY IS 'Géométrie de type multiligne.';

-- 3. Remplissage des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO 
ADD CONSTRAINT VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO_PK 
PRIMARY KEY (OBJECTID);

-- 5. Création de l'index spatial
CREATE INDEX VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO_SIDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 6. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO TO G_ADMIN_SIG;

/

/*
Création de la VM VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO- pour le projet LITTERALIS - regroupant toutes les parties de voie intersectant une agglomération.
*/
/*
DROP INDEX VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO_SIDX;
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO';
COMMIT;
*/

CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO(
    OBJECTID, 
    TYPE_ZONE, 
    CODE_VOIE, 
    COTE_VOIE, 
    CODE_INSEE, 
    CATEGORIE, 
    GEOMETRY
)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT -- Pour toutes les voies intersectant les zones d'agglomération, on sélectionne uniquement la partie située en-dehors des zones
        rownum AS objectid,
        'InteretCommunautaire' AS type_zone,
        a.id_voie_administrative AS code_voie,
        CASE
            WHEN a.lateralite = 'droit'
                THEN 'Droit'
            WHEN a.lateralite = 'gauche'
                THEN 'Gauche'
            WHEN a.lateralite = 'les deux côtés'
                THEN 'LesDeuxCotes' 
            END AS cote_voie,
        CAST(a.code_insee AS VARCHAR2(254)) AS code_insee,
        CAST(0 AS NUMBER(8)) AS categorie,
        SDO_GEOM.SDO_DIFFERENCE(a.geom, b.geom, 0.001) AS geometry
    FROM
        G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE a,
        G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION b
    WHERE
         SDO_OVERLAPBDYDISJOINT(a.geom, b.geom) = 'TRUE';

-- 2. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO IS 'Vue matérialisée - pour le projet LITTERALIS - regroupant toutes les parties de voies situées hors agglomération.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO.OBJECTID IS 'Clé primaire de la vue matérialisée.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO.TYPE_ZONE IS 'Type de zone : Agglomeration ; InteretCommunautaire';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO.CODE_VOIE IS 'Liaison avec la classe TRONCON sur la colonne CODE_RUE_G ou CODE_RUE_D';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO.COTE_VOIE IS 'Définit sur quel côté de la voie s''appuie la zone particulière : LesDeuxCotes, Gauche, Droit.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO.CODE_INSEE IS 'Code INSEE de la commune. Obligatoire pour les entrées Commune et Agglomeration.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO.CATEGORIE IS 'Valeur définissant la catégorie de la rue sur cette zone';
COMMENT ON COLUMN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO.GEOMETRY IS 'Géométrie de type multiligne.';

-- 3. Remplissage des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO 
ADD CONSTRAINT VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO_PK 
PRIMARY KEY (OBJECTID);

-- 5. Création de l'index spatial
CREATE INDEX VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO_SIDX
ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- 6. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO TO G_ADMIN_SIG;

/

/*
Création de la Vue matérialisée VM_INFORMATION_VOIE_LITTERALIS rassemblant les informations nécessaires aux agents de la DEPV pour gérer les travaux de voirie via l'application LITTERALIS.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS;
*/
-- 1. Création de la vue matérialisée
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS (
    OBJECTID, 
    ID_VOIE,
    DOMANIALITE,
    TRAFIC,
    AGE_DES_TRAVAUX,
    ANCIENNETE_DES_TRAVAUX
)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
    WITH C_1 AS(
        SELECT
            a.idvoie AS id_voie,
            a.domania AS domanialite,
            b.clastrf AS trafic,
            c.age_travaux AS age_des_travaux,
            CASE
                WHEN c.age_travaux< 5
                    THEN 'Voirie de moins de 5 ans'
                ELSE
                    'Voirie de plus de 5 ans'
            END AS anciennete_des_travaux
        FROM
            SIREO_LEC.OUT_DOMANIALITE a
            INNER JOIN SIREO_LEC.OUT_CLAS_TRAF b ON a.idvoie = b.idvoie 
            INNER JOIN SIREO_LEC.OUT_TRAVAUX_VOIE c ON c.idvoie = b.idvoie
        GROUP BY
            a.idvoie,
            a.domania,
            b.clastrf,
            c.age_travaux,
            CASE
                WHEN c.age_travaux< 5
                    THEN 'Voirie de moins de 5 ans'
                ELSE
                    'Voirie de plus de 5 ans'
            END
    )

    SELECT
        rownum AS objectid,
        a.id_voie,
        a.domanialite,
        a.trafic,
        a.age_des_travaux,
        a.anciennete_des_travaux
    FROM
        C_1 a;

-- 2. Création des commentaires
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS IS 'Vue matérialisée rassemblant les informations nécessaires aux agents de la DEPV pour gérer les travaux de voirie via l''application LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS.OBJECTID IS 'Clé primaire de la VM.';
COMMENT ON COLUMN G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS.ID_VOIE IS 'Identifiant de la voie récupéré dans le schéma SIREO_LEC.';
COMMENT ON COLUMN G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS.DOMANIALITE IS 'Domanialité de la voie, c''est-à-dire le propriétaire de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS.TRAFIC IS 'Type de trafic des voies.';
COMMENT ON COLUMN G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS.AGE_DES_TRAVAUX IS 'Age des travaux de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS.ANCIENNETE_DES_TRAVAUX IS 'Ancienneté des travaux permettant de savoir s''ils ont plus ou moins de 5 ans d''ancienneté.';

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_INFORMATION_VOIE_LITTERALIS 
ADD CONSTRAINT VM_INFORMATION_VOIE_LITTERALIS_PK 
PRIMARY KEY (OBJECTID);

-- 4. Création des index
CREATE INDEX VM_INFORMATION_VOIE_LITTERALIS_ID_VOIE_IDX ON G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS(ID_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_INFORMATION_VOIE_LITTERALIS_DOMANIALITE_IDX ON G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS(DOMANIALITE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_INFORMATION_VOIE_LITTERALIS_TRAFIC_IDX ON G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS(TRAFIC)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_INFORMATION_VOIE_LITTERALIS_AGE_DES_TRAVAUX_IDX ON G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS(AGE_DES_TRAVAUX)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_INFORMATION_VOIE_LITTERALIS_ANCIENNETE_DES_TRAVAUX_IDX ON G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS(ANCIENNETE_DES_TRAVAUX)
    TABLESPACE G_ADT_INDX;

-- 5. Création des droits de lecture
GRANT SELECT ON G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS TO G_ADMIN_SIG;

/

/*
Création de la vue V_LITTERALIS_TRONCON - du jeux d'export du projet LITTERALIS - contenant tous les tronÃ§ons au format LITTERALIS.
*/
/*
DROP VIEW G_BASE_VOIE.V_LITTERALIS_TRONCON;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'V_LITTERALIS_TRONCON';
COMMIT;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_LITTERALIS_TRONCON" ("IDENTIFIANT", "CODE_TRONC", "CLASSEMENT", "CODE_RUE_G", "NOM_RUE_G", "INSEE_G", "CODE_RUE_D", "NOM_RUE_D", "INSEE_D", "LARGEUR", "GEOMETRY", 
   CONSTRAINT "V_LITTERALIS_TRONCON_PK" PRIMARY KEY ("CODE_TRONC") DISABLE) AS 
    SELECT
        a.objectid AS identifiant,
        a.code_tronc,
        a.classement,
        a.id_voie_gauche AS code_rue_g,
        a.nom_voie_gauche AS nom_rue_g,
        a.code_insee_voie_gauche AS insee_g,
        a.id_voie_droite AS code_rue_d,
        a.nom_voie_droite AS nom_rue_d,
        a.code_insee_voie_droite AS insee_d,
        CAST('' AS NUMBER(8,0)) AS largeur,
        a.geometry
    FROM
        G_BASE_VOIE.TA_TAMPON_LITTERALIS_TRONCON a;
        
-- Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_LITTERALIS_TRONCON IS 'Vue - du jeux d''export du projet LITTERALIS - contenant tous les tronÃ§ons au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.CODE_TRONC IS 'Identificateur unique et immuable du tronÃ§on de voie partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.CLASSEMENT IS 'Classement de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.CODE_RUE_G IS 'Code unique de la rue côté gauche du tronÃ§on partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.NOM_RUE_G IS 'Nom de la voie côté gauche du tronÃ§on (telle qu''affichée dans les arrêtés et autorisations).';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.INSEE_G IS 'Code INSEE de la commune côté gauche du tronÃ§on.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.CODE_RUE_D IS 'Code unique de la rue côté droit du tronÃ§on partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.NOM_RUE_D IS 'Nom de la voie côté droit du tronÃ§on (telle qu''affichée dans les arrêtés et autorisations).';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.INSEE_D IS 'Code INSEE de la commune côté droit du tronÃ§on.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.LARGEUR IS 'Valeur indiquant une largeur de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_TRONCON.GEOMETRY IS 'Géométrie de l''adresse de type ligne simple.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_LITTERALIS_TRONCON',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Affection des droits
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_TRONCON TO G_ADMIN_SIG;

/

/*
Création de la vue V_LITTERALIS_ADRESSE - du jeux d'export du projet LITTERALIS - contenant tous les seuils au format LITTERALIS.
*/
/*
DROP VIEW G_BASE_VOIE.V_LITTERALIS_ADRESSE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'V_LITTERALIS_ADRESSE';
COMMIT;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_LITTERALIS_ADRESSE" (
    IDENTIFIANT, 
    CODE_VOIE, 
    CODE_POINT, 
    NATURE, 
    LIBELLE, 
    NUMERO, 
    REPETITION, 
    COTE, 
    GEOMETRY, 
    CONSTRAINT "V_LITTERALIS_ADRESSE_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS 
    SELECT
        objectid AS identifiant,
        code_voie,
        code_point,
        nature,
        libelle,
        numero,
        repetition,
        cote,
        geometry
    FROM
        G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE
    WHERE
        objectid NOT IN(32915, 423830, 405371, 405372, 405373, 403572, 405374, 429444, 418366, 37897, 39111, 41292, 41293, 426054, 355617, 359366, 359365, 359364, 359363, 359362, 359361, 359360, 359244, 51594, 64736, 65124, 393958, 373827, 394209, 65585, 65583, 65581, 65580, 65579, 65584, 65582, 373826, 373825, 394325, 418154, 418155, 374459, 81178, 90190, 90189, 330688, 368214, 393303, 106029, 330781, 330782, 428501, 145112, 330819, 383476, 383475, 145111, 145716, 330862, 125358, 383284, 126822, 427937, 428676, 429030, 428198, 330981, 428178, 328367, 369418, 328368, 142229, 428687, 427810, 333163, 159049, 374858, 367335, 429551, 398549, 189812, 189114, 380857, 206308, 384462, 431311, 376634, 27207, 27261, 242734, 242735, 242736, 242743, 407604, 407605, 407606, 407593, 407594, 407595, 407596, 407597, 407518, 406363, 406364, 406365, 243643, 247063, 247068, 367139, 379324, 249233, 430507, 430735, 430691, 256788, 256787, 256789, 256790, 257524, 258408, 367564, 396741, 294271, 302007, 377745, 5754, 377746, 377743, 370688, 370964, 324107, 371347, 326672, 29744, 5755, 5757, 8858, 429850, 429851, 392134);
      
-- Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_LITTERALIS_ADRESSE IS 'Vue - du jeux d''export du projet LITTERALIS - contenant tous les seuils au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.CODE_VOIE IS 'Liaison avec la vue V_LITTERALIS_TRONCON sur la colonne CODE_RUE_G ou CODE_RUE_D.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.CODE_POINT IS 'Identificateur unique et immuable du point partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.NATURE IS 'Indique la nature du point : ADR = Adresse.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.LIBELLE IS 'Libellé du point affiché dans les textes (dans les actesâ€¦).';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.NUMERO IS 'Numéro postal.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.REPETITION IS 'Indique la valeur de répétition d''un numéro sur une rue. La saisie de la répétition est libre.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.COTE IS 'Définit sur quel côté de la voie s''appuie l''adresse : LesDeuxCotes, Impair, Pair.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ADRESSE.GEOMETRY IS 'Géométrie de l''adresse de type point.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_LITTERALIS_ADRESSE',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Affection des droits
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_ADRESSE TO G_ADMIN_SIG;

/

/*
Création de la vue V_LITTERALIS_REGROUPEMENT - du jeux d'export du projet LITTERALIS - contenant tous les regroupements (secteurs, territoires, unités territoriales) au format LITTERALIS.
*/
/*
DROP VIEW G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'V_LITTERALIS_REGROUPEMENT';
COMMIT;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_LITTERALIS_REGROUPEMENT" (
    NOM,
    CODE_REGR,
    TYPE,
    CODE_INSEE,
    GEOMETRY, 
   CONSTRAINT "V_LITTERALIS_REGROUPEMENT_PK" PRIMARY KEY ("CODE_REGR") DISABLE
) AS 
    SELECT
        nom,
        code_regr,
        type,
        code_insee,
        geometry
    FROM
        G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT;
        
-- Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT IS 'Vue - du jeux d''export du projet LITTERALIS - contenant tous les regroupements (secteurs, territoires, unités territoriales) au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT.NOM IS 'Nom du regroupement.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT.CODE_REGR IS 'Clé primaire - Identificateur unique et immuable du regroupement partagé entre Littéralis Expert et le SIG';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT.TYPE IS 'Type de regroupement. En accord avec le prestataire tous les regroupements sont de type "Zone".';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT.CODE_INSEE IS 'Code INSEE de la commune. Les regroupements pouvant recouvrir plusieurs communes il a été convenu avec le prestataire de ne rien mettre dans ce champ.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT.GEOMETRY IS 'Géométries de type multipolygone des secteurs, territoires et unités territoriales du service voirie.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_LITTERALIS_REGROUPEMENT',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Affection des droits
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT TO G_ADMIN_SIG;

/

/*
Création de la vue V_LITTERALIS_ZONE_PARTICULIERE - du jeux d'export du projet LITTERALIS - contenant tous les tronÃ§ons au format LITTERALIS.
*/
/*
DROP VIEW G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'V_LITTERALIS_ZONE_PARTICULIERE';
COMMIT;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_LITTERALIS_ZONE_PARTICULIERE" (
    IDENTIFIANT, 
    TYPE_ZONE, 
    CODE_VOIE, 
    COTE_VOIE, 
    CODE_INSEE, 
    CATEGORIE, 
    GEOMETRY, 
   CONSTRAINT "V_LITTERALIS_ZONE_PARTICULIERE_PK" PRIMARY KEY ("IDENTIFIANT") DISABLE) AS 
    WITH C_1 AS(
        SELECT
            CAST(type_zone AS VARCHAR2(254 BYTE)) AS type_zone,
            CAST(code_voie AS VARCHAR2(254 BYTE)) AS code_voie,
            CAST(cote_voie AS VARCHAR2(254 BYTE)) AS cote_voie,
            CAST(code_insee AS VARCHAR2(254 BYTE)) AS code_insee,
            CAST(categorie  AS NUMBER(8,0)) AS categorie,
            geometry
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO
        UNION ALL
        SELECT
            CAST(type_zone AS VARCHAR2(254 BYTE)) AS type_zone,
            CAST(code_voie AS VARCHAR2(254 BYTE)) AS code_voie,
            CAST(cote_voie AS VARCHAR2(254 BYTE)) AS cote_voie,
            CAST(code_insee AS VARCHAR2(254 BYTE)) AS code_insee,
            CAST(categorie  AS NUMBER(8,0)) AS categorie,
            geometry
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO
        UNION ALL
        SELECT
            CAST(type_zone AS VARCHAR2(254 BYTE)) AS type_zone,
            CAST(code_voie AS VARCHAR2(254 BYTE)) AS code_voie,
            CAST(cote_voie AS VARCHAR2(254 BYTE)) AS cote_voie,
            CAST(code_insee AS VARCHAR2(254 BYTE)) AS code_insee,
            CAST(categorie  AS NUMBER(8,0)) AS categorie,
            geometry
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO
        UNION ALL
        SELECT
            CAST(type_zone AS VARCHAR2(254 BYTE)) AS type_zone,
            CAST(code_voie AS VARCHAR2(254 BYTE)) AS code_voie,
            CAST(cote_voie AS VARCHAR2(254 BYTE)) AS cote_voie,
            CAST(code_insee AS VARCHAR2(254 BYTE)) AS code_insee,
            CAST(categorie  AS NUMBER(8,0)) AS categorie,
            geometry
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO
    )

    SELECT
        rownum AS identifiant,
        type_zone,
        code_voie,
        cote_voie,
        code_insee,
        categorie,
        geometry
    FROM
        C_1;
        
-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE IS 'Vue - du jeux d''export du projet LITTERALIS - contenant toutes les zones particulières au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.TYPE_ZONE IS 'Type de zone : Commune, Agglomeration, RGC, Categorie, InteretCommunautaire.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.CODE_VOIE IS 'Liaison avec la classe TRONCON sur la colonne CODE_RUE_G ou CODE_RUE_D.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.COTE_VOIE IS 'Définit sur quel côté de la voie s''appuie la zone particulière : LesDeuxCotes, Gauche, Droit.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.CODE_INSEE IS 'Code INSEE de la commune. * Obligatoire pour les entrées Â« Commune Â» et Â« Agglomeration Â».';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.CATEGORIE IS 'Valeur définissant la catégorie de la rue sur cette zone (1,2,3..). A définir à 0 lorsque le champ TYPE_ZONE <> Â« Categorie Â».';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.GEOMETRY IS 'Géométries de type multiligne des zones particulières.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_LITTERALIS_ZONE_PARTICULIERE',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Affection des droits
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE TO G_ADMIN_SIG;

/

/*
Création de la vue V_LITTERALIS_AUDIT_TRONCON - de la structure tampon du projet LITTERALIS - vérifiant la présence d''erreur dans la table VM_TAMPON_LITTERALIS_TRONCON. Les erreurs vérifiées sont celles qui ont été remontées dans les rapports d''erreurs.
*/
/*
DROP VIEW G_BASE_VOIE.V_LITTERALIS_AUDIT_TRONCON;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_LITTERALIS_AUDIT_TRONCON" (
    OBJECTID, 
    THEMATIQUE, 
    ID_TRONCON, 
    CLASSEMENT, 
    CODE_INSEE, 
    CONSTRAINT "V_LITTERALIS_AUDIT_TRONCON_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS
WITH
    C_1 AS(-- Sélection des tronÃ§on dont le code INSEE est en erreur (absent de la couche des communes ou NULL)
        SELECT
            objectid,
            code_insee_voie_gauche AS code_insee
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON
        WHERE
            code_insee_voie_gauche NOT IN(SELECT code_insee FROM G_REFERENTIEL.MEL_COMMUNE_LLH)
            OR code_insee_voie_gauche IS NULL
        UNION ALL
        SELECT
            objectid,
            code_insee_voie_gauche AS code_insee
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON
        WHERE
            code_insee_voie_gauche NOT IN(SELECT code_insee FROM G_REFERENTIEL.MEL_COMMUNE_LLH)
            OR code_insee_voie_droite IS NULL
    ),
    
    C_2 AS(-- Mise en forme des tronÃ§ons dont le code INSEE est en erreur
        SELECT
            'Code INSEE en erreur' AS thematique,
            objectid AS id_troncon,
            '' AS classement,
            code_insee
        FROM
            C_1
    ),
    
    C_3 AS(-- Sélection des doublons d'identifiant de tronÃ§ons
        SELECT
            'Doublons d''dentifiants de tronÃ§on' AS thematique,
            objectid AS id_troncon,
            '' AS classement,
            '' AS code_insee
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON
        GROUP BY
            'Doublons d''dentifiants de tronÃ§on',
            objectid,
            '',
            ''
        HAVING
            COUNT(objectid) > 1
    ),
    
    C_4 AS(-- Sélection des doublons de géométrie pour des tronÃ§ons ayant un identifiant différent
        SELECT
            a.objectid AS id_troncon_1,
            b.objectid AS id_troncon_2
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON a,
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON b
        WHERE
            SDO_EQUAL(a.geometry, b.geometry) = 'TRUE'
            AND a.objectid < b.objectid
    ),
    
    C_5 AS(-- Mise en forme des tronÃ§ons en doublon de géométrie mais d'identifiant différent
        SELECT
            'Doublons de Géométrie de tronÃ§ons ayant un identifiant différent : ' || id_troncon_1 || ' - ' || id_troncon_2 AS thematique,
            id_troncon_1 AS id_troncon,
            '' AS classement,
            '' AS code_insee
        FROM
            C_4
    ),

    C_6 AS(-- Sélection des classements absents du cahier des charges
        SELECT
            'Classement non-conforme au cahier des charges' AS thematique,
            objectid AS id_troncon,
            classement,
            '' AS code_insee
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON
        WHERE
            classement NOT IN(SELECT classement FROM G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT)
    ),
    
    C_7 AS(
        SELECT
            thematique,
            id_troncon,
            classement,
            code_insee
        FROM
            C_2
        UNION ALL
        SELECT
            thematique,
            id_troncon,
            classement,
            code_insee
        FROM
            C_3
        UNION ALL
        SELECT
            thematique,
            id_troncon,
            classement,
            code_insee
        FROM
            C_5
        UNION ALL
        SELECT
            thematique,
            id_troncon,
            classement,
            code_insee
        FROM
            C_6
    )
    
    SELECT
        rownum AS objectid,
        thematique,
        id_troncon,
        classement,
        code_insee
    FROM
        C_7;
        
-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_LITTERALIS_AUDIT_TRONCON IS 'Vue d''audit - de la structure tampon du projet LITTERALIS - vérifiant la présence d''erreur dans la table VM_TAMPON_LITTERALIS_TRONCON. Les erreurs vérifiées sont celles qui ont été remontées dans les rapports d''erreurs.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_TRONCON.OBJECTID IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_TRONCON.THEMATIQUE IS 'Thème de l''erreur identifiée.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_TRONCON.ID_TRONCON IS 'Identifiant des tronÃ§ons.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_TRONCON.CLASSEMENT IS 'Classement des tronÃ§ons.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_TRONCON.CODE_INSEE IS 'Code INSEE des tronÃ§ons.';

-- 3. Création des droits de lecture
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_AUDIT_TRONCON TO G_ADMIN_SIG;

/

/*
Création de la vue V_LITTERALIS_AUDIT_ADRESSE - de la structure tampon du projet LITTERALIS - vérifiant la présence d''erreur dans la table VM_TAMPON_LITTERALIS_ADRESSE. Les erreurs vérifiées sont celles qui ont été remontées dans les rapports d''erreurs.
*/
/*
DROP VIEW G_BASE_VOIE.V_LITTERALIS_AUDIT_ADRESSE;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_LITTERALIS_AUDIT_ADRESSE" (
    OBJECTID, 
    THEMATIQUE, 
    ID_ADRESSE, 
    CODE_VOIE, 
    NATURE, 
    NUMERO, 
    REPETITION, 
    DISTANCE, 
    CONSTRAINT "V_LITTERALIS_AUDIT_ADRESSE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS
WITH
    C_1 AS(-- Sélection des doublons de code_voie, nature, numero, repetition
        SELECT
            code_voie,
            nature,
            numero,
            repetition
        FROM
           G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE
        GROUP BY
            code_voie,
            nature,
            numero,
            repetition
        HAVING
            COUNT(objectid) > 1
    ),
    
    C_2 AS(-- Mise en forme des doublons de code_voie, nature, numero, repetition
        SELECT
            'Doublons de code_voie, nature, numero, repetition' AS thematique,
            b.objectid AS id_adresse,
            b.code_voie,
            b.nature,
            b.numero,
            CASE 
                WHEN a.repetition IS NULL 
                    THEN '' 
                WHEN a.repetition IS NOT NULL AND a.repetition = b.repetition 
                    THEN a.repetition 
            END AS repetition,
            0 AS distance
        FROM
            C_1 a
            INNER JOIN G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE b ON b.code_voie = a.code_voie AND b.nature = a.nature AND b.numero = a.numero
    ),
    
    C_3 AS(-- Sélection des adresses situées à 1km ou plus de leur voie
        SELECT
            'Adresse située à 1km ou plus de sa voie' AS thematique,
            a.objectid AS id_adresse,
            a.code_voie,
            a.nature,
            a.numero,
            a.repetition,
            ROUND(SDO_GEOM.SDO_DISTANCE(
                a.geometry,
                SDO_LRS.PROJECT_PT(
                    SDO_LRS.CONVERT_TO_LRS_GEOM(b.geometry, m.diminfo),
                    a.geometry,
                    0.005
                )
            ), 2) AS distance
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE a
            INNER JOIN G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE b ON b.objectid = a.fid_voie,
            USER_SDO_GEOM_METADATA m
        WHERE
            m.TABLE_NAME = 'VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE'
            AND ROUND(SDO_GEOM.SDO_DISTANCE(
                a.geometry,
                SDO_LRS.PROJECT_PT(
                    SDO_LRS.CONVERT_TO_LRS_GEOM(b.geometry, m.diminfo),
                    a.geometry,
                    0.005
                )
            ),2) >=1000
    ),
    
    C_4 AS(-- Sélection des adresses n''ayant pas de numéro
        SELECT
            'Adresse sans numéro' AS thematique,
            objectid AS id_adresse,
            code_voie,
            nature,
            numero,
            repetition,
            0 AS distance
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE
        WHERE
            numero IS NULL
    ),

    C_5 AS(-- Sélection des voies présentes dans la table des tronÃ§ons
        SELECT
            id_voie_gauche AS code_voie
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON
        UNION ALL
        SELECT
            id_voie_droite AS code_voie
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON
    ),

    C_6 AS(-- Sélection des voies associées aux adresses absentes de la table des tronÃ§ons
        SELECT
            'Voie absente de la table des tronÃ§ons' AS thematique,
            objectid AS id_adresse,
            code_voie,
            nature,
            numero,
            repetition,
            0 AS distance
        FROM
            G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE
        WHERE
            code_voie NOT IN(SELECT DISTINCT code_voie FROM C_5)
    ),
    
    C_7 AS(-- Mise en forme des données
        SELECT
            thematique,
            id_adresse,
            code_voie,
            nature,
            numero,
            repetition,
            distance
        FROM
            C_2
        UNION ALL
        SELECT
            thematique,
            id_adresse,
            code_voie,
            nature,
            numero,
            repetition,
            distance
        FROM
            C_3
        UNION ALL
        SELECT
            thematique,
            id_adresse,
            code_voie,
            nature,
            numero,
            repetition,
            distance
        FROM
            C_4
        UNION ALL
        SELECT
            thematique,
            id_adresse,
            code_voie,
            nature,
            numero,
            repetition,
            distance
        FROM
            C_6
    )
    
    SELECT
        rownum AS objectid,
        thematique,
        id_adresse,
        code_voie,
        nature,
        numero,
        repetition,
        distance
    FROM
        C_7
    ORDER BY
        thematique,
        code_voie,
        numero,
        repetition;
        
-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_LITTERALIS_AUDIT_ADRESSE IS 'Vue d''audit - de la structure tampon du projet LITTERALIS - vérifiant la présence d''erreur dans la table VM_TAMPON_LITTERALIS_ADRESSE. Les erreurs vérifiées sont celles qui ont été remontées dans les rapports d''erreurs.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_ADRESSE.OBJECTID IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_ADRESSE.THEMATIQUE IS 'Thème de l''erreur identifiée.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_ADRESSE.ID_ADRESSE IS 'Identifiant des adresses (présents dans TA_INFOS_SEUIL).';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_ADRESSE.CODE_VOIE IS 'Identifiant de la voie associée à l''adresse.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_ADRESSE.NATURE IS 'Nature de l''adresse';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_ADRESSE.NUMERO IS 'Numéro de l''adresse';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_ADRESSE.REPETITION IS 'Complément de numéro de l''adresse.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_ADRESSE.DISTANCE IS 'Valeur en erreur.';

-- 3. Création des droits de lecture
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_AUDIT_ADRESSE TO G_ADMIN_SIG;

/

/*
Création de la vue V_LITTERALIS_AUDIT_ZONE_PARTICULIERE - de la structure tampon du projet LITTERALIS - vérifiant la présence d''erreur dans la table VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE. Les erreurs vérifiées sont celles qui ont été remontées dans les rapports d''erreurs.
*/
/*
DROP VIEW G_BASE_VOIE.V_LITTERALIS_AUDIT_ZONE_PARTICULIERE;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE EDITIONABLE VIEW "G_BASE_VOIE"."V_LITTERALIS_AUDIT_ZONE_PARTICULIERE" (
    OBJECTID,
    THEMATIQUE,
    IDENTIFIANT,
    TYPE_ZONE,
    CODE_VOIE,
    COTE_VOIE,
    CODE_INSEE,
    CATEGORIE,
    GEOMETRY,
    CONSTRAINT "V_LITTERALIS_AUDIT_ZONE_PARTICULIERE_PK" PRIMARY KEY ("OBJECTID") DISABLE) AS 
    WITH
        C_1 AS(
            SELECT DISTINCT
                 id_voie_droite as code_voie
            FROM
                G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON
           UNION
            SELECT DISTINCT
                 id_voie_gauche as code_voie
            FROM
                G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON
        ),
        
        C_2 AS(
            SELECT -- Sélection des voies présentes dans les zones particulières, mais absentes de la table des tronÃ§ons.
                'Voies présentes dans les zones particulières mais absentes de la table des tronÃ§ons' AS thematique,
                a.identifiant,
                a.type_zone,
                a.code_voie,
                a.cote_voie,
                a.code_insee,
                a.categorie,
                a.geometry
            FROM
                G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE a
            WHERE
                a.code_voie NOT IN (SELECT DISTINCT code_voie FROM C_1)
            UNION ALL
            SELECT -- Sélection des zones particulières dont le type de zone est non-conforme au cahier des charges
                'Zones particulières dont le type de zone est non-conforme au cahier des charges' AS thematique,
                a.identifiant,
                a.type_zone,
                a.code_voie,
                a.cote_voie,
                a.code_insee,
                a.categorie,
                a.geometry
            FROM
                G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE a
            WHERE
                a.type_zone NOT IN('Commune', 'Agglomeration', 'RGC', 'Categorie', 'InteretCommunautaire')
            UNION ALL
            SELECT -- Sélection des zones particulières dont le type de zone est Commune ou Agglomeration, mais ne disposant pas de code INSEE
                'Zones particulières dont le type de zone est Commune ou Agglomeration, mais ne disposant pas de code INSEE' AS thematique,
                a.identifiant,
                a.type_zone,
                a.code_voie,
                a.cote_voie,
                a.code_insee,
                a.categorie,
                a.geometry
            FROM
                G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE a
            WHERE
                a.type_zone IN('Commune', 'Agglomeration')
                AND (
                        a.code_insee IS NULL
                    )
            UNION ALL
            SELECT -- Sélection des zones particulières dont le code INSEE différe de son tronÃ§on de rattachement
                'Zones particulières dont le code INSEE différe de son tronÃ§on de rattachement' AS thematique,
                a.identifiant,
                a.type_zone,
                a.code_voie,
                a.cote_voie,
                a.code_insee,
                a.categorie,
                a.geometry
            FROM
                G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE a,
                G_BASE_VOIE.V_LITTERALIS_TRONCON b,
                G_BASE_VOIE.V_LITTERALIS_TRONCON c
            WHERE
                (
                    b.code_rue_d = a.code_voie
                    AND a.code_insee = b.insee_d
                    AND a.cote_voie = 'Droit'
                )
                OR (
                    b.code_rue_g = a.code_voie
                    AND a.code_insee = b.insee_g
                    AND a.cote_voie = 'Gauche'
                )
                OR (
                    b.code_rue_g = a.code_voie
                    AND b.code_rue_d = a.code_voie
                    AND a.code_insee = b.insee_g
                    AND a.code_insee = b.insee_d
                    AND a.cote_voie = 'LesDeuxCotes')       
        )

        SELECT
            rownum AS objectid,
            thematique,
            identifiant,
            type_zone,
            code_voie,
            cote_voie,
            code_insee,
            categorie,
            geometry
        FROM
            C_2;
        
-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_LITTERALIS_AUDIT_ZONE_PARTICULIERE IS 'Vue d''audit - de la structure tampon du projet LITTERALIS - vérifiant la présence d''erreur dans la table V_LITTERALIS_ZONE_PARTICULIERE. Les erreurs vérifiées sont celles qui ont été remontées dans les rapports d''erreurs.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_ZONE_PARTICULIERE.OBJECTID IS 'Clé primaire de la vue correspondant à l''identifiant de chaque zone particulière.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_AUDIT_ZONE_PARTICULIERE.THEMATIQUE IS 'Thème de l''erreur identifiée.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.IDENTIFIANT IS 'Identifiant des zones particulières.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.TYPE_ZONE IS 'Type de zone : Commune, Agglomeration, RGC, Categorie, InteretCommunautaire.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.CODE_VOIE IS 'Liaison avec la classe TRONCON sur la colonne CODE_RUE_G ou CODE_RUE_D.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.COTE_VOIE IS 'Définit sur quel côté de la voie s''appuie la zone particulière : LesDeuxCotes, Gauche, Droit.';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.CODE_INSEE IS 'Code INSEE de la commune. * Obligatoire pour les entrées Â« Commune Â» et Â« Agglomeration Â».';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.CATEGORIE IS 'Valeur définissant la catégorie de la rue sur cette zone (1,2,3..). A définir à 0 lorsque le champ TYPE_ZONE <> Â« Categorie Â».';
COMMENT ON COLUMN G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE.GEOMETRY IS 'Géométries de type multiligne des zones particulières.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_LITTERALIS_AUDIT_ZONE_PARTICULIERE',
    'GEOMETRY',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 4. Création des droits de lecture
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_AUDIT_ZONE_PARTICULIERE TO G_ADMIN_SIG;

/

/*
Création des droits de lecture et de mise à jour des objets du projet LITTERALIS présents sur le schéma G_BASE_VOIE
*/

-- Tables
GRANT SELECT ON G_BASE_VOIE.TA_SECTEUR_VOIRIE TO G_BASE_VOIE_LEC;
GRANT SELECT, INSERT, UPDATE, DELETE ON G_BASE_VOIE.TA_SECTEUR_VOIRIE TO G_BASE_VOIE_MAJ;

-- Vues
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_AUDIT_TRONCON TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_AUDIT_ADRESSE TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_AUDIT_ZONE_PARTICULIERE TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_TRONCON TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_ADRESSE TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_REGROUPEMENT TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.V_LITTERALIS_ZONE_PARTICULIERE TO G_BASE_VOIE_LEC;

-- Vues matérialisées
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.VM_TERRITOIRE_VOIRIE TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO TO G_BASE_VOIE_LEC;
GRANT SELECT ON G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS TO G_BASE_VOIE_LEC;

/

