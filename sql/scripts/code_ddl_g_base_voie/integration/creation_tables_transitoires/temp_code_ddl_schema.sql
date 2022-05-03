
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
SEQ_TEMP_TRONCON_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TEMP_TRONCON
*/

CREATE SEQUENCE SEQ_TEMP_TRONCON_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
La table TEMP_TYPE_VOIE regroupe tous les types de voies de la base voie tels que les avenues, boulevards, rues, senteir, etc.
*/

-- 1. Création de la table TEMP_TYPE_VOIE
CREATE TABLE G_BASE_VOIE.TEMP_TYPE_VOIE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    code_type_voie CHAR(4) NULL,
    libelle VARCHAR2(100) NULL   
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_TYPE_VOIE IS 'Table transitoire permettant les corrections pour ensuite intégrer les données dans les tables de production. Elle rassemble tous les types de voies présents dans la base voie. Ancienne table : TYPEVOIE.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TYPE_VOIE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TYPE_VOIE.code_type_voie IS 'Code des types de voie présents dans la base voie. Ce champ remplace le champ CCODTVO.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TYPE_VOIE.libelle IS 'Libellé des types de voie. Exemple : Boulevard, avenue, reu, sentier, etc.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_TYPE_VOIE 
ADD CONSTRAINT TEMP_TYPE_VOIE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 5. Création des index
CREATE INDEX TEMP_TYPE_VOIE_CODE_TYPE_VOIE_IDX ON G_BASE_VOIE.TEMP_TYPE_VOIE(code_type_voie)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_TYPE_VOIE TO G_ADMIN_SIG;

/

/*
La table TEMP_VOIE regroupe tous les informations de chaque voie de la base voie.
*/

-- 1. Création de la table TEMP_VOIE
CREATE TABLE G_BASE_VOIE.TEMP_VOIE(
    objectid NUMBER(38,0),
    libelle_voie VARCHAR2(50) NULL,
    complement_nom_voie VARCHAR2(50),
    cnumcom NUMBER(3,0),
    ccodrvo VARCHAR2(4 BYTE),
    cdvalvoi VARCHAR2(1 BYTE),
    date_saisie DATE DEFAULT sysdate NULL,
    date_modification DATE DEFAULT sysdate NULL,
    fid_pnom_saisie NUMBER(38,0) NULL,
    fid_pnom_modification NUMBER(38,0) NULL,
    fid_typevoie NUMBER(38,0) NULL,
    fid_genre_voie NUMBER(38,0) NULL,
    fid_rivoli NUMBER(38,0) NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_VOIE IS 'Table transitoire permettant les corrections pour ensuite intégrer les données dans les tables de production. Elle rassemblent toutes les informations pour chaque voie de la base. Ancienne table : VOIEVOI';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_VOIE.objectid IS 'Clé primaire auto-incrémentée de la table. Elle remplace l''ancien identifiant ccomvoie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_VOIE.libelle_voie IS 'Nom de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_VOIE.complement_nom_voie IS 'Complément du nom de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_VOIE.cnumcom IS 'Code commune (différent du code INSEE) de la voie rempli à la main.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_VOIE.ccodrvo IS 'Code RIVOLI de la voie (différent du code fantoir).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_VOIE.cdvalvoi IS 'Champ permettant de distinguer les voies valides des voies invalides.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_VOIE.date_saisie IS 'Date de saisie de la voie (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_VOIE.date_modification IS 'Date de modification de la voie (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_VOIE.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé une voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_VOIE.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié une voie.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_VOIE.fid_typevoie IS 'Clé étangère vers la table TA_TYPE_VOIE permettant de catégoriser les voies de la base.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_VOIE.fid_genre_voie IS 'Clé étrangère vers la table TA_LIBELLE permettant de connaître le genre du nom de la voie : masculin, féminin, neutre et non-identifié.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_VOIE.fid_rivoli IS 'Clé étrangère vers la table TA_RIVOLI permettant d''associer un code RIVOLI à chaque voie.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_VOIE 
ADD CONSTRAINT TEMP_VOIE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 5. Création des index
CREATE INDEX TEMP_VOIE_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TEMP_VOIE(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_VOIE_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TEMP_VOIE(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_VOIE_FID_TYPEVOIE_IDX ON G_BASE_VOIE.TEMP_VOIE(fid_typevoie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_VOIE_FID_GENRE_VOIE_IDX ON G_BASE_VOIE.TEMP_VOIE(fid_genre_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_VOIE_FID_RIVOLI_IDX ON G_BASE_VOIE.TEMP_VOIE(fid_rivoli)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX TEMP_VOIE_CNUMCOM_IDX ON G_BASE_VOIE.TEMP_VOIE(cnumcom)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_VOIE_CCODRVO_IDX ON G_BASE_VOIE.TEMP_VOIE(ccodrvo)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_VOIE_CDVALVOI_IDX ON G_BASE_VOIE.TEMP_VOIE(cdvalvoi)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_VOIE TO G_ADMIN_SIG;

/

/*
La table TEMP_TRONCON regroupe tous les tronçons de la base voie. C'est une table transitoire qui permet la correction des données avant leur insertion dans les tables de production.
*/

-- 1. Création de la table TEMP_TRONCON
CREATE TABLE G_BASE_VOIE.TEMP_TRONCON(
    objectid NUMBER(38,0),
    geom SDO_GEOMETRY NOT NULL,
    cdvaltro VARCHAR2(1 BYTE),
    date_saisie DATE DEFAULT sysdate NULL,
    date_modification DATE DEFAULT sysdate NULL,
    fid_voie NUMBER(38,0),
    fid_pnom_saisie NUMBER(38,0) NULL,
    fid_pnom_modification NUMBER(38,0) NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_TRONCON IS 'Table transitoire permettant les corrections pour ensuite intégrer les données dans les tables de production. Elle contient les tronçons de la base voie qui servent à constituer les rues qui elles-mêmes constituent les voies. Ancienne table : ILTATRC.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON.objectid IS 'Clé primaire de la table identifiant chaque tronçon. Cette pk est auto-incrémentée et remplace l''ancien identifiant cnumtrc.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON.geom IS 'Géométrie de type ligne simple de chaque tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON.cdvaltro IS 'Champ permettant de distinguer les tronçons valides des tronçons invalides.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON.date_saisie IS 'date de saisie du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON.date_modification IS 'Dernière date de modification du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_TRONCON.fid_voie IS 'Clé étrangère vers la table TA_VOIE permettant d''associer une voie à un ou plusieurs tronçons. Ancien champ : CCOMVOI.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_TRONCON 
ADD CONSTRAINT TEMP_TRONCON_PK 
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
    'TEMP_TRONCON',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TEMP_TRONCON_SIDX
ON G_BASE_VOIE.TEMP_TRONCON(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 7. Création des index 
CREATE INDEX TEMP_TRONCON_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TEMP_TRONCON(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_TRONCON_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TEMP_TRONCON(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_TRONCON_FID_VOIE_IDX ON G_BASE_VOIE.TEMP_TRONCON(fid_voie)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_TRONCON TO G_ADMIN_SIG;

/

/*
La table TEMP_RELATION_TRONCON_VOIE regroupant tous les types et états permettant de catégoriser les objets de la base voie.
*/

-- 1. Création de la table TEMP_RELATION_TRONCON_VOIE
CREATE TABLE G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    sens CHAR(1) NULL,
    cvalide VARCHAR2(1 BYTE),
    fid_voie NUMBER(38,0) NULL,
    fid_troncon NUMBER(38,0) NULL,
    date_saisie DATE DEFAULT sysdate NULL,
    date_modification DATE DEFAULT sysdate NULL,
    fid_pnom_saisie NUMBER(38,0) NULL,
    fid_pnom_modification NUMBER(38,0) NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE IS 'Table pivot transitoire permettant les corrections pour ensuite intégrer les données dans les tables de production. Elle permet d''associer les tronçons de la table temp_troncon à leur voie présente dans temp_voie. Ancienne table : VOIECVT.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE.sens IS 'Code permettant de connaître le sens du tronçon. Ancien champ : CCODSTR. A préciser avec Marie-Hélène, car les valeurs ne sont pas compréhensibles sans documentation.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE.cvalide IS 'Champ permettant d''identifier les relations tronçon/voie valides ou invalides.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE.fid_voie IS 'Clé étrangère vers la table temp_voie permettant d''associer une voie à un ou plusieurs tronçons. Ancien champ : CCOMVOI.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE.fid_troncon IS 'Clé étrangère vers la table temp_troncon permettant d''associer un ou plusieurs tronçons à une voie. Ancien champ : CNUMTRC.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE.date_saisie IS 'Date de saisie de la relation troncon/voie en base (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE.date_modification IS 'Date de la dernière modification de la relation troncon/voie en base (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé la relation.';
COMMENT ON COLUMN G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié la relation.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE 
ADD CONSTRAINT TEMP_RELATION_TRONCON_VOIE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 5. Création des index sur les clés étrangères
CREATE INDEX TEMP_RELATION_TRONCON_VOIE_FID_VOIE_IDX ON G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE(fid_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_RELATION_TRONCON_VOIE_FID_TRONCON_IDX ON G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE(fid_troncon)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TEMP_RELATION_TRONCON_VOIE_CVALIDE_IDX ON G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE(cvalide)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE TO G_ADMIN_SIG;

/

/*
Déclencheur permettant de récupérer dans la table TEMP_TRONCON, les dates de création/modification des entités ainsi que le pnom de l'agent les ayant effectués.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUX_TEMP_TRONCON_DATE_PNOM
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TEMP_TRONCON
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    fid_mtd NUMBER(38,0);

BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TEMP_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TEMP_AGENT WHERE pnom = username;

    -- En cas d'insertion on insère la FK du pnom de l'agent, ayant créé le tronçon, présent dans TEMP_AGENT. 
    IF INSERTING THEN 
        :new.objectid := SEQ_TEMP_TRONCON_OBJECTID.NEXTVAL;
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
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUX_TEMP_TRONCON_DATE_PNOM','bjacq@lillemetropole.fr');
END;

/

/*
Déclencheur permettant de récupérer dans la table TEMP_VOIE, les dates de création/modification des entités ainsi que le pnom de l'agent les ayant effectués.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUX_TEMP_VOIE_DATE_PNOM
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TEMP_VOIE
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    fid_mtd NUMBER(38,0);
    
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TEMP_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TEMP_AGENT WHERE pnom = username;

    -- En cas d'insertion on insère la FK du pnom de l'agent, ayant créé la voie, présent dans TEMP_AGENT.
    IF INSERTING THEN
       :new.fid_pnom_saisie := v_id_agent;
       :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
       :new.fid_pnom_modification := v_id_agent;
       :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
    ELSE
        IF UPDATING THEN -- En cas de mise à jour on édite le champ date_modification avec la date du jour et le champ fid_pnom_modification avec la FK du pnom de l'agent, ayant modifié la voie, présent dans TEMP_AGENT.
            :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
            :new.fid_pnom_modification := v_id_agent;
        END IF;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUX_TEMP_VOIE_DATE_PNOM','bjacq@lillemetropole.fr');
END;

/

/*
Création d'une vue matérialisée transitoire matérialisant la géométrie des voies pour corriger les tronçons affectés à plusieurs voies.
*/
-- 1. Suppression de la VM et de ses métadonnées
/*DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_VOIE_AGGREGEE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TEMP_VOIE_AGGREGEE';
COMMIT;
*/
-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TEMP_VOIE_AGGREGEE" ("ID_VOIE","LIBELLE_VOIE","LONGUEUR","GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
    a.objectid AS id_voie,
    TRIM(UPPER(b.libelle)) ||' '|| TRIM(UPPER(a.libelle_voie)) ||' '|| TRIM(UPPER(a.complement_nom_voie)) AS libelle_voie,
    ROUND(SDO_GEOM.SDO_LENGTH(SDO_AGGR_UNION(SDOAGGRTYPE(d.geom, 0.005)), 0.001), 2) AS longueur,
    SDO_AGGR_UNION(SDOAGGRTYPE(d.geom, 0.005)) AS geom
FROM
    G_BASE_VOIE.TEMP_VOIE a
    INNER JOIN G_BASE_VOIE.TEMP_TYPE_VOIE b ON b.objectid = a.fid_typevoie
    INNER JOIN G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE c ON c.fid_voie = a.objectid
    INNER JOIN G_BASE_VOIE.TEMP_TRONCON d ON d.objectid = c.fid_troncon
WHERE
    a.cdvalvoi = 'V'
    AND c.cvalide = 'V'
    AND d.cdvaltro ='V'
GROUP BY
    a.objectid,
    TRIM(UPPER(b.libelle)) ||' '|| TRIM(UPPER(a.libelle_voie)) ||' '|| TRIM(UPPER(a.complement_nom_voie));
    
-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_VOIE_AGGREGEE IS 'Vue matérialisée transitoire matérialisant la géométrie des voies depuis les tables d''import. Cette VM sert UNIQUEMENT à corriger les tronçons affectés à plusieurs voies avant d''insérer les données dans les tables de production.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TEMP_VOIE_AGGREGEE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TEMP_VOIE_AGGREGEE 
ADD CONSTRAINT VM_TEMP_VOIE_AGGREGEE_PK 
PRIMARY KEY (ID_VOIE);

-- 6. Création des index
CREATE INDEX VM_TEMP_VOIE_AGGREGEE_SIDX
ON G_BASE_VOIE.VM_TEMP_VOIE_AGGREGEE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_TEMP_VOIE_AGGREGEE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_TEMP_VOIE_AGGREGEE(LIBELLE_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TEMP_VOIE_AGGREGEE_LONGUEUR_IDX ON G_BASE_VOIE.VM_TEMP_VOIE_AGGREGEE(LONGUEUR)
    TABLESPACE G_ADT_INDX;
    
-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TEMP_VOIE_AGGREGEE TO G_ADMIN_SIG;

/

