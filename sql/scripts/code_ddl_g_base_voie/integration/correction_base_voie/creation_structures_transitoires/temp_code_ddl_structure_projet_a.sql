
create or replace FUNCTION GET_TEMP_CODE_INSEE_97_COMMUNES_CONTAIN_LINE(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
/*
Cette fonction a pour objectif de récupérer le code INSEE de la commune dans laquelle se situe le point médian d'un objet linéaire.
La variable v_table_name doit contenir le nom de la table dont on veut connaître le code INSEE des objets.
La variable v_geometry doit contenir le nom du champ géométrique de la table interrogée.
Le référentiel utilisé pour récupérer le code INSEE est celui des 97 communes car avec les communes associées, nous pouvons avoir deux voies du même nom et complément à Lille par exemple, alors qu'une se situe à Lomme et l'autre à Lille.
*/
    DETERMINISTIC
    As
    v_code_insee CHAR(8);
    BEGIN
        SELECT
            TRIM(b.code_insee)
            INTO v_code_insee
        FROM
            G_REFERENTIEL.MEL_COMMUNE_LLH b,
            USER_SDO_GEOM_METADATA m
        WHERE
            m.table_name = v_table_name
            AND SDO_CONTAINS(
                    b.geom,
                    SDO_LRS.CONVERT_TO_STD_GEOM(
                        SDO_LRS.LOCATE_PT(
                                        SDO_LRS.CONVERT_TO_LRS_GEOM(v_geometry,m.diminfo),
                                        SDO_GEOM.SDO_LENGTH(v_geometry,m.diminfo)/2
                        )
                    )
                )='TRUE';
        RETURN v_code_insee;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'error';
    END GET_TEMP_CODE_INSEE_97_COMMUNES_CONTAIN_LINE;

/


create or replace FUNCTION GET_TEMP_CODE_INSEE_97_COMMUNES_POURCENTAGE(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
/*
Cette fonction a pour objectif de récupérer le code INSEE de la commune dans laquelle se situe plus de 50% d'un objet linéaire.
La variable v_table_name doit contenir le nom de la table dont on veut connaître le code INSEE des objets.
La variable v_geometry doit contenir le nom du champ géométrique de la table interrogée.
Le référentiel utilisé pour récupérer le code INSEE est celui des 97 communes car avec les communes associées, nous pouvons avoir deux voies du même nom et complément à Lille par exemple, alors qu'une se situe à Lomme et l'autre à Lille.
ATTENTION : Cette fonction N'EST PAS A UTILISER pour des objets de types points.
*/
    DETERMINISTIC
    As
    v_code_insee CHAR(8);
    BEGIN
        SELECT
            TRIM(b.code_insee)
            INTO v_code_insee
        FROM
            G_REFERENTIEL.MEL_COMMUNE_LLH b,
            USER_SDO_GEOM_METADATA m
        WHERE
            m.table_name = v_table_name
            AND (SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(v_geometry, b.geom, 0.005))/ SDO_GEOM.SDO_LENGTH(v_geometry,m.diminfo))*100 > 50;
        RETURN v_code_insee;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'error';
    END GET_TEMP_CODE_INSEE_97_COMMUNES_POURCENTAGE;

/


create or replace FUNCTION GET_TEMP_CODE_INSEE_97_COMMUNES_WITHIN_DISTANCE(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
/*
Cette fonction a pour objectif de récupérer le code INSEE de la commune située à deux mètres maximum de l'objet interrogé, sachant que ce dernier n'est pas dans les communes de la MEL.
La fonction localise le point médian de l'objet (situé en-dehors de la MEL) et, s'il se trouve à plus de deux mètres d'une commune, elle renvoie 'error', sinon, elle renvoie le code INSEE de la commune.
La variable v_table_name doit contenir le nom de la table dont on veut connaître le code INSEE des objets.
La variable v_geometry doit contenir le nom du champ géométrique de la table interrogée.
Le référentiel utilisé pour récupérer le code INSEE est celui des 97 communes car avec les communes associées, nous pouvons avoir deux voies du même nom et complément à Lille par exemple, alors qu'une se situe à Lomme et l'autre à Lille.
*/
    DETERMINISTIC
    As
    v_code_insee CHAR(8);
    BEGIN
        SELECT
            TRIM(b.code_insee)
            INTO v_code_insee
        FROM
            G_REFERENTIEL.MEL_COMMUNE_LLH b,
            USER_SDO_GEOM_METADATA m
        WHERE
            m.table_name = v_table_name
            AND SDO_FILTER(b.geom, v_geometry) <> 'TRUE'
            AND SDO_GEOM.WITHIN_DISTANCE(SDO_LRS.CONVERT_TO_STD_GEOM(
                SDO_LRS.LOCATE_PT(
                                SDO_LRS.CONVERT_TO_LRS_GEOM(v_geometry,m.diminfo),
                                SDO_GEOM.SDO_LENGTH(v_geometry,m.diminfo)/2
                )
            ), 2, b.geom, 0.005) = 'TRUE';
        RETURN v_code_insee;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'error';
    END GET_TEMP_CODE_INSEE_97_COMMUNES_WITHIN_DISTANCE;

/


create or replace FUNCTION GET_TEMP_CODE_INSEE_97_COMMUNES_TRONCON(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
/*
Cette fonction a pour objectif de récupérer le code INSEE de chaque tronçon. Le référentiel utilisé pour récupérer le code INSEE est celui des 97 communes car avec les communes associées, nous pouvons avoir deux voies du même nom et complément à Lille par exemple, alors qu'une se situe à Lomme et l'autre à Lille.
La variable v_table_name doit contenir le nom de la table dont on veut connaître le code INSEE des objets.
La variable v_geometry doit contenir le nom du champ géométrique de la table interrogée.
Pour cela elle traite différents cas via les fonctions ci-dessous :
- GET_CODE_INSEE_CONTAIN ;
- GET_CODE_INSEE_POURCENTAGE ;
- GET_CODE_INSEE_WITHIN_DISTANCE ;
*/
    DETERMINISTIC
    As
    v_code_insee CHAR(8);
    BEGIN
        IF GET_CODE_INSEE_97_COMMUNES_CONTAIN_LINE(v_table_name, v_geometry) <> 'error' THEN
            v_code_insee := GET_CODE_INSEE_97_COMMUNES_CONTAIN_LINE(v_table_name, v_geometry);
        ELSIF GET_CODE_INSEE_97_COMMUNES_POURCENTAGE(v_table_name, v_geometry) <> 'error' THEN
            v_code_insee := GET_CODE_INSEE_97_COMMUNES_POURCENTAGE(v_table_name, v_geometry);
        ELSIF GET_CODE_INSEE_97_COMMUNES_WITHIN_DISTANCE(v_table_name, v_geometry) <> 'error' THEN
            v_code_insee := GET_CODE_INSEE_97_COMMUNES_WITHIN_DISTANCE(v_table_name, v_geometry);
        END IF;
        RETURN v_code_insee;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'erreur';
    END GET_TEMP_CODE_INSEE_97_COMMUNES_TRONCON;

/

/*
SEQ_TEMP_A_TRONCON_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TEMP_A_TRONCON
*/

CREATE SEQUENCE SEQ_TEMP_A_TRONCON_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
La table TEMP_A_AGENT regroupant les pnoms de tous les agents ayant travaillés et qui travaillent encore pour la base voie.
*/

-- 1. Création de la table TEMP_A_AGENT
CREATE TABLE G_BASE_VOIE.TEMP_A_AGENT(
    numero_agent NUMBER(38,0) NOT NULL,
    pnom VARCHAR2(50) NOT NULL,
    validite NUMBER(1) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_A_AGENT IS 'Table temporaire pour le projet A de correction listant les pnoms de tous les agents ayant travaillés et qui travaillent encore pour la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_AGENT.numero_agent IS 'Numéro d''agent présent sur la carte de chaque agent.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_AGENT.pnom IS 'Pnom de l''agent, c''est-à-dire la concaténation de l''initiale de son prénom et de son nom entier.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_AGENT.validite IS 'Validité de l''agent, c''est-à-dire que ce champ permet de savoir si l''agent continue de travailler dans/pour la base voie ou non : 1 = oui ; 0 = non.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_A_AGENT 
ADD CONSTRAINT TEMP_A_AGENT_PK 
PRIMARY KEY("NUMERO_AGENT") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_A_AGENT TO G_ADMIN_SIG;

/

/*
La table TEMP_A_LIBELLE Table liste les types et états permettant de catégoriser les objets de la base voie.
*/

-- 1. Création de la table TEMP_A_LIBELLE
CREATE TABLE G_BASE_VOIE.TEMP_A_LIBELLE(
    objectid NUMBER(38,0) GENERATED ALWAYS AS IDENTITY,
    libelle_court VARCHAR2(100 BYTE),
    libelle_long VARCHAR2(4000 BYTE)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_A_LIBELLE IS 'Table listant les types et états permettant de catégoriser les objets de la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_LIBELLE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_LIBELLE.libelle_court IS 'Valeur courte pouvant être prise par un libellé de la nomenclature de la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_LIBELLE.libelle_long IS 'Valeur longue pouvant être prise par un libellé de la nomenclature de la base voie.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_A_LIBELLE 
ADD CONSTRAINT TEMP_A_LIBELLE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_A_LIBELLE_LIBELLE_COURT_IDX ON G_BASE_VOIE.TEMP_A_LIBELLE(libelle_court)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_A_LIBELLE TO G_ADMIN_SIG;

/

/*
La table TEMP_A_TYPE_VOIE regroupe tous les types de voies de la base voie tels que les avenues, boulevards, rues, senteir, etc.
*/

-- 1. Création de la table TEMP_A_TYPE_VOIE
CREATE TABLE G_BASE_VOIE.TEMP_A_TYPE_VOIE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    code_type_voie CHAR(4) NULL,
    libelle VARCHAR2(100) NULL   
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_A_TYPE_VOIE IS 'Table transitoire permettant les corrections du projet A (latéralité des voies + tronçon affecté à plusieurs voies) pour ensuite intégrer les données dans les tables de production. Elle rassemble tous les types de voies présents dans la base voie. Ancienne table : TYPEVOIE.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_TYPE_VOIE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_TYPE_VOIE.code_type_voie IS 'Code des types de voie présents dans la base voie. Ce champ remplace le champ CCODTVO.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_TYPE_VOIE.libelle IS 'Libellé des types de voie. Exemple : Boulevard, avenue, reu, sentier, etc.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_A_TYPE_VOIE 
ADD CONSTRAINT TEMP_A_TYPE_VOIE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 5. Création des index
CREATE INDEX TEMP_A_TYPE_VOIE_CODE_TYPE_VOIE_IDX ON G_BASE_VOIE.TEMP_A_TYPE_VOIE(code_type_voie)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_A_TYPE_VOIE TO G_ADMIN_SIG;

/

/*
La table TEMP_A_VOIE_PHYSIQUE regroupe tous les informations de chaque voie de la base voie.
*/

-- 1. Création de la table TEMP_A_VOIE_PHYSIQUE
CREATE TABLE G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE IS 'Table rassemblant les identifiant de toutes les voies PHYSIQUES (en opposition aux voies administratives : une voie physique peut correspondre à deux voies administratives si elle appartient à deux communes différentes).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE.objectid IS 'Clé primaire auto-incrémentée de la table (ses identifiants ne reprennent PAS ceux de VOIEVOI).';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE 
ADD CONSTRAINT TEMP_A_VOIE_PHYSIQUE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE TO G_ADMIN_SIG;

/

/*
La table TEMP_A_VOIE_ADMINISTRATIVE regroupe tous les informations de chaque voie de la base voie. Cette séparation de l'identifiant de voie permet d''affecter deux noms à une voie physique.
*/

-- 1. Création de la table TEMP_A_VOIE_ADMINISTRATIVE
CREATE TABLE G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    genre_voie VARCHAR2(50 BYTE),
    libelle_voie VARCHAR2(1000 BYTE),
    complement_nom_voie VARCHAR2(200),
    fid_lateralite NUMBER(38,0),
    code_insee VARCHAR2(5),
    date_saisie DATE,
    date_modification DATE,
    fid_pnom_saisie NUMBER(38,0),
    fid_pnom_modification NUMBER(38,0),
    fid_voie_physique NUMBER(38,0),
    fid_type_voie NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE IS 'Table rassemblant les informations de chaque voie et notamment leurs libellés : une voie physique peut avoir deux noms différents si elle traverse deux communes différentes.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE.objectid IS 'Clé primaire auto-incrémentée de la table. Elle remplace l''ancien identifiant ccomvoie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE.genre_voie IS 'Genre du nom de la voie (féminin, masculin, neutre, etc).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE.libelle_voie IS 'Nom de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE.complement_nom_voie IS 'Complément de nom de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE.code_insee IS 'Code insee de la voie "administrative".';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE.date_saisie IS 'Date de création du libellé de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE.date_modification IS 'Date de modification du libellé de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE.fid_pnom_saisie IS 'Clé étrangère vers la table TEMP_A_AGENT indiquant le pnom de l''agent créateur du libellé de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE.fid_pnom_modification IS 'Clé étrangère vers la table TEMP_A_AGENT indiquant le pnom de l''agent éditeur du libellé de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE.fid_type_voie IS 'Clé étrangère vers la table TEMP_A_TYPE_VOIE permettant d''associer une voie à un type de voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE.fid_voie_physique IS 'Clé étrangère vers la table TA_VOIE permettant d''affecter un ou plusieurs noms à une voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE.fid_lateralite IS 'Clé étrangère vers la table TA_LIBELLE permettant de récupérer la latéralité de la voie. En limite de commune le côté gauche de la voie physique peut appartenir à la commune A et le côté droit à la comune B, tandis qu''au sein de la commune la voie physique appartient à une et une seule commune et est donc affectée à une et une seule voie administrative. Cette distinction se fait grâce à ce champ.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE 
ADD CONSTRAINT TEMP_A_VOIE_ADMINISTRATIVE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE
ADD CONSTRAINT TEMP_A_VOIE_ADMINISTRATIVE_FID_LATERALITE_FK
FOREIGN KEY (fid_lateralite)
REFERENCES G_BASE_VOIE.TEMP_A_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE
ADD CONSTRAINT TEMP_A_VOIE_ADMINISTRATIVE_FID_VOIE_PHYSIQUE_FK
FOREIGN KEY (fid_voie_physique)
REFERENCES G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE(objectid);

ALTER TABLE G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE
ADD CONSTRAINT TEMP_A_VOIE_ADMINISTRATIVE_FID_TYPE_VOIE_FK
FOREIGN KEY (fid_type_voie)
REFERENCES G_BASE_VOIE.TEMP_A_TYPE_VOIE(objectid);

ALTER TABLE G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE
ADD CONSTRAINT TEMP_A_VOIE_ADMINISTRATIVE_FID_PNOM_SAISIE_FK
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TEMP_A_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE
ADD CONSTRAINT TEMP_A_VOIE_ADMINISTRATIVE_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TEMP_A_AGENT(numero_agent);

-- 4. Création des index sur les clés étrangères et autres   
CREATE INDEX TEMP_A_VOIE_ADMINISTRATIVE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE(libelle_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_A_VOIE_ADMINISTRATIVE_COMPLEMENT_NOM_VOIE_IDX ON G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE(complement_nom_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_A_VOIE_ADMINISTRATIVE_CODE_INSEE_IDX ON G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE(code_insee)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_A_VOIE_ADMINISTRATIVE_FID_LATERALITE_IDX ON G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE(fid_lateralite)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_A_VOIE_ADMINISTRATIVE_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_A_VOIE_ADMINISTRATIVE_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_A_VOIE_ADMINISTRATIVE_FID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE(fid_voie_physique)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_A_VOIE_ADMINISTRATIVE_FID_TYPE_VOIE_IDX ON G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE(fid_type_voie)
    TABLESPACE G_ADT_INDX;

-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

/*
La table TEMP_A_TRONCON regroupe tous les tronçons de la base voie.
*/

-- 1. Création de la table TEMP_A_TRONCON
CREATE TABLE G_BASE_VOIE.TEMP_A_TRONCON(
    objectid NUMBER(38,0),
    geom SDO_GEOMETRY NULL,
    sens CHAR(1 BYTE),
    date_saisie DATE DEFAULT sysdate NULL,
    date_modification DATE DEFAULT sysdate NULL,
    fid_pnom_saisie NUMBER(38,0) NULL,
    fid_pnom_modification NUMBER(38,0) NULL,
    fid_voie_physique NUMBER(38,0),
    fid_metadonnee NUMBER(38,0) NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_A_TRONCON IS 'Table contenant les tronçons de la base voie. Il s''agit d''une table temporaire servant à tester la structure de la base en teant compte des latéralités de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_TRONCON.objectid IS 'Clé primaire de la table identifiant chaque tronçon. Cette pk est auto-incrémentée et remplace l''ancien identifiant cnumtrc.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_TRONCON.geom IS 'Géométrie de type ligne simple de chaque tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_TRONCON.sens IS 'Sense de circulation du tronçon par rapport au sens de saisie : "+" = saisie de saisie égal au sens de circulation ; "-" = sens de saisie opposé au sens de circulation.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_TRONCON.date_saisie IS 'date de saisie du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_TRONCON.date_modification IS 'Dernière date de modification du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_TRONCON.fid_pnom_saisie IS 'Clé étrangère vers la table TEMP_A_AGENT permettant de récupérer le pnom de l''agent ayant créé un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_TRONCON.fid_pnom_modification IS 'Clé étrangère vers la table TEMP_A_AGENT permettant de récupérer le pnom de l''agent ayant modifié un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_TRONCON.fid_voie_physique IS 'Clé étrangère vers la table TEMP_A_VOIE_PHYSIQUE, permettant d''associer un tronçon à une et une seule voie physique.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_A_TRONCON.fid_metadonnee IS 'Clé étrangère vers la table G_GEO.TA_METADONNEE permettant de connaître la source des tronçons (MEL ou IGN).';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_A_TRONCON 
ADD CONSTRAINT TEMP_A_TRONCON_PK 
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
    'TEMP_A_TRONCON',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_A_TRONCON_SIDX
ON G_BASE_VOIE.TEMP_A_TRONCON(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TEMP_A_TRONCON
ADD CONSTRAINT TEMP_A_TRONCON_FID_PNOM_SAISIE_FK 
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TEMP_A_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_A_TRONCON
ADD CONSTRAINT TEMP_A_TRONCON_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TEMP_A_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TEMP_A_TRONCON
ADD CONSTRAINT TEMP_A_TRONCON_FID_VOIE_PHYSIQUE_FK
FOREIGN KEY (fid_voie_physique)
REFERENCES G_BASE_VOIE.TEMP_A_VOIE_PHYSIQUE(objectid);

ALTER TABLE G_BASE_VOIE.TEMP_A_TRONCON
ADD CONSTRAINT TEMP_A_TRONCON_FID_METADONNEE_FK
FOREIGN KEY (fid_metadonnee)
REFERENCES G_GEO.TA_METADONNEE(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TEMP_A_TRONCON_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TEMP_A_TRONCON(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_A_TRONCON_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TEMP_A_TRONCON(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_A_TRONCON_fid_voie_physique_IDX ON G_BASE_VOIE.TEMP_A_TRONCON(fid_voie_physique)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_A_TRONCON_FID_METADONNEE_IDX ON G_BASE_VOIE.TEMP_A_TRONCON(fid_metadonnee)
    TABLESPACE G_ADT_INDX;

-- Cet index dispose d'une fonction permettant d'accélérer la récupération du code INSEE de la commune d'appartenance du tronçon. 
-- Il créé également un champ virtuel dans lequel on peut aller chercher ce code INSEE.
CREATE INDEX TEMP_A_TRONCON_CODE_INSEE_IDX
ON G_BASE_VOIE.TEMP_A_TRONCON(GET_CODE_INSEE_TRONCON('TEMP_A_TRONCON', geom))
TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_A_TRONCON TO G_ADMIN_SIG;

/

/*
Déclencheur permettant de récupérer dans la table TEMP_A_TRONCON, les dates de création/modification des entités ainsi que le pnom de l'agent les ayant effectués.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUX_TEMP_A_TRONCON_DATE_PNOM
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TEMP_A_TRONCON
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TEMP_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TEMP_AGENT WHERE pnom = username;

    -- En cas d'insertion on insère la FK du pnom de l'agent, ayant créé le tronçon, présent dans TEMP_AGENT. 
    IF INSERTING THEN 
        :new.objectid := SEQ_TEMP_A_TRONCON_OBJECTID.NEXTVAL;
        :new.fid_pnom_saisie := v_id_agent;
        :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
        :new.fid_pnom_modification := v_id_agent;
        :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
    ELSE
        -- En cas de mise à jour on édite le champ date_modification avec la date du jour et le champ fid_pnom_modification avec la FK du pnom de l'agent, ayant modifié le tronçon, présent dans TEMP_AGENT.
        IF UPDATING THEN 
             :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
             :new.fid_pnom_modification := v_id_agent;
        END IF;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUX_TEMP_A_TRONCON_DATE_PNOM','bjacq@lillemetropole.fr');
END;

/

CREATE OR REPLACE FORCE VIEW "G_BASE_VOIE"."V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE" (ID_VOIE, LIBELLE_VOIE, FID_LATERALITE, GEOM, 
    CONSTRAINT "V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE_PK" PRIMARY KEY (ID_VOIE) DISABLE) AS 
WITH
    C_1 AS(-- interversion du endpoint avec le startpoint pour les tronçons saisis dans le sens opposé au sens de circulation
        SELECT
            a.objectid,
            a.fid_voie_physique,
            CASE
                WHEN a.sens = '-'
                    THEN SDO_LRS.REVERSE_GEOMETRY(a.geom, m.diminfo)
                ELSE
                    a.geom
            END AS geom
        FROM
            G_BASE_VOIE.TEMP_A_TRONCON a,
            USER_SDO_GEOM_METADATA m
        WHERE
            m.table_name = 'TEMP_A_TRONCON'
    ),

    C_2 AS(
        SELECT
            fid_voie_physique AS id_voie,
            SDO_AGGR_CONCAT_LINES(geom) AS geom
        FROM
            C_1
        GROUP BY
            fid_voie_physique
    )
    
    SELECT
        b.objectid AS id_voie,
        TRIM(UPPER(TRIM(c.libelle)) || ' ' || UPPER(TRIM(b.libelle_voie)) || ' ' || UPPER(TRIM(b.complement_nom_voie))) AS libelle_voie,
        b.fid_lateralite,
        a.geom
    FROM
        C_2 a
        INNER JOIN G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE b ON b.fid_voie_physique = a.id_voie
        INNER JOIN G_BASE_VOIE.TEMP_A_TYPE_VOIE c ON c.objectid = b.fid_type_voie;
        
-- 2. Création des commentaires de VM et de champs
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE IS 'Cette vue matérialise la géométrie des voies valides (disposant d''un type valide) de sorte que le sens géométrique soit égal au sens de circulation : si le sens de saisie d''un tronçon est opposé au sens de circulation de la voie, les startpoint et endpoint sont intervertis, puis les tronçons sont fusionnés par voie d''appartenance. ';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE.id_voie IS 'Identifiant de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE.libelle_voie IS 'nom de la voie : type de voie + nom de voie + complément de nom.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE.fid_lateralite IS 'Identifiant des différentes latéralités possible de la voie administrative (par rapport à la voie physique).';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE.geom IS 'Géométrie des voies de type multiligne.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_TEMP_VOIE_AGREGEE_SENS_CIRCULATION_RECTIFIE TO G_ADMIN_SIG;

/

-- Désactivation des contraintes et des index des tables de correction des tronçons affectés à plusieurs voies et de la latéralité des voies.
-- Désactivation des contraintes
ALTER TABLE G_BASE_VOIE.TEMP_A_TRONCON DISABLE CONSTRAINT TEMP_A_TRONCON_FID_PNOM_SAISIE_FK;
ALTER TABLE G_BASE_VOIE.TEMP_A_TRONCON DISABLE CONSTRAINT TEMP_A_TRONCON_FID_PNOM_MODIFICATION_FK;
ALTER TABLE G_BASE_VOIE.TEMP_A_TRONCON DISABLE CONSTRAINT TEMP_A_TRONCON_FID_VOIE_PHYSIQUE_FK;
ALTER TABLE G_BASE_VOIE.TEMP_A_TRONCON DISABLE CONSTRAINT TEMP_A_TRONCON_FID_METADONNEE_FK;
ALTER TABLE G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE DISABLE CONSTRAINT TEMP_A_VOIE_ADMINISTRATIVE_FID_VOIE_PHYSIQUE_FK;
ALTER TABLE G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE DISABLE CONSTRAINT TEMP_A_VOIE_ADMINISTRATIVE_FID_TYPE_VOIE_FK;
ALTER TABLE G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE DISABLE CONSTRAINT TEMP_A_VOIE_ADMINISTRATIVE_FID_PNOM_SAISIE_FK;
ALTER TABLE G_BASE_VOIE.TEMP_A_VOIE_ADMINISTRATIVE DISABLE CONSTRAINT TEMP_A_VOIE_ADMINISTRATIVE_FID_PNOM_MODIFICATION_FK;

-- Suppression des index
DROP INDEX TEMP_A_TRONCON_FID_METADONNEE_IDX;
DROP INDEX TEMP_A_TRONCON_FID_PNOM_SAISIE_IDX;
DROP INDEX TEMP_A_TRONCON_FID_PNOM_MODIFICATION_IDX;
DROP INDEX TEMP_A_TRONCON_FID_VOIE_PHYSIQUE_IDX;
DROP INDEX TEMP_A_VOIE_ADMINISTRATIVE_LIBELLE_VOIE_IDX;
DROP INDEX TEMP_A_VOIE_ADMINISTRATIVE_COMPLEMENT_NOM_VOIE_IDX;
DROP INDEX TEMP_A_VOIE_ADMINISTRATIVE_CODE_INSEE_IDX;
DROP INDEX TEMP_A_VOIE_ADMINISTRATIVE_FID_LATERALITE_IDX;
DROP INDEX TEMP_A_VOIE_ADMINISTRATIVE_FID_PNOM_SAISIE_IDX;
DROP INDEX TEMP_A_VOIE_ADMINISTRATIVE_FID_PNOM_MODIFICATION_IDX;
DROP INDEX TEMP_A_VOIE_ADMINISTRATIVE_FID_VOIE_PHYSIQUE_IDX;
DROP INDEX TEMP_A_VOIE_ADMINISTRATIVE_FID_TYPE_VOIE_IDX;

