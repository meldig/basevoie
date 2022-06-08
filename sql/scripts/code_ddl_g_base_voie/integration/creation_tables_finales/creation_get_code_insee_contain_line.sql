
CREATE OR REPLACE FUNCTION GET_CODE_INSEE_CONTAIN_LINE(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
/*
Cette fonction a pour objectif de récupérer le code INSEE de la commune dans laquelle se situe le point médian d'un objet linéaire.
La variable v_table_name doit contenir le nom de la table dont on veut connaître le code INSEE des objets.
La variable v_geometry doit contenir le nom du champ géométrique de la table interrogée.
*/
    DETERMINISTIC
    As
    v_code_insee CHAR(8);
    BEGIN
        SELECT 
            TRIM(b.code_insee)
            INTO v_code_insee 
        FROM 
            G_REFERENTIEL.MEL_COMMUNE b, 
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
    END GET_CODE_INSEE_CONTAIN_LINE;

/

create or replace FUNCTION GET_CODE_INSEE_CONTAIN_POINT(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
/*
Cette fonction a pour objectif de récupérer le code INSEE de la commune dans laquelle se situe le point médian d'un objet ponctuel (de type point).
La variable v_table_name doit contenir le nom de la table dont on veut connaître le code INSEE des objets.
La variable v_geometry doit contenir le nom du champ géométrique de la table interrogée.
*/
    DETERMINISTIC
    As
    v_code_insee CHAR(8);
    BEGIN
        SELECT
            TRIM(b.code_insee)
            INTO v_code_insee
        FROM
            G_REFERENTIEL.MEL_COMMUNE b,
            USER_SDO_GEOM_METADATA m
        WHERE
            m.table_name = v_table_name
            AND SDO_CONTAINS(
                    b.geom,
                    v_geometry
                )='TRUE';
        RETURN v_code_insee;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'error';
    END GET_CODE_INSEE_CONTAIN_POINT;

/

CREATE OR REPLACE FUNCTION GET_CODE_INSEE_CONTAIN_LINE(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
/*
Cette fonction a pour objectif de récupérer le code INSEE de la commune dans laquelle se situe le point médian d'un objet linéaire.
La variable v_table_name doit contenir le nom de la table dont on veut connaître le code INSEE des objets.
La variable v_geometry doit contenir le nom du champ géométrique de la table interrogée.
*/
    DETERMINISTIC
    As
    v_code_insee CHAR(8);
    BEGIN
        SELECT 
            TRIM(b.code_insee)
            INTO v_code_insee 
        FROM 
            G_REFERENTIEL.MEL_COMMUNE b, 
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
    END GET_CODE_INSEE_CONTAIN_LINE;

/

CREATE OR REPLACE FUNCTION GET_CODE_INSEE_POURCENTAGE(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
/*
Cette fonction a pour objectif de récupérer le code INSEE de la commune dans laquelle se situe plus de 50% d'un objet linéaire.
La variable v_table_name doit contenir le nom de la table dont on veut connaître le code INSEE des objets.
La variable v_geometry doit contenir le nom du champ géométrique de la table interrogée.
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
            G_REFERENTIEL.MEL_COMMUNE b, 
            USER_SDO_GEOM_METADATA m
        WHERE
            m.table_name = v_table_name
            AND (SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(v_geometry, b.geom, 0.005))/ SDO_GEOM.SDO_LENGTH(v_geometry,m.diminfo))*100 > 50;
        RETURN v_code_insee;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'error';
    END GET_CODE_INSEE_POURCENTAGE;

/

CREATE OR REPLACE FUNCTION GET_CODE_INSEE_WITHIN_DISTANCE(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
/*
Cette fonction a pour objectif de récupérer le code INSEE de la commune située à deux mètres maximum de l'objet interrogé, sachant que ce dernier n'est pas dans les communes de la MEL.
La fonction localise le point médian de l'objet (situé en-dehors de la MEL) et, s'il se trouve à plus de deux mètres d'une commune, elle renvoie 'error', sinon, elle renvoie le code INSEE de la commune.
La variable v_table_name doit contenir le nom de la table dont on veut connaître le code INSEE des objets.
La variable v_geometry doit contenir le nom du champ géométrique de la table interrogée.
*/
    DETERMINISTIC
    As
    v_code_insee CHAR(8);
    BEGIN
        SELECT 
            TRIM(b.code_insee)
            INTO v_code_insee 
        FROM 
            G_REFERENTIEL.MEL_COMMUNE b, 
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
    END GET_CODE_INSEE_WITHIN_DISTANCE;
    
/

CREATE OR REPLACE FUNCTION GET_CODE_INSEE_TRONCON(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
/*
Cette fonction a pour objectif de récupérer le code INSEE de chaque tronçon.
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
        IF GET_CODE_INSEE_CONTAIN_LINE(v_table_name, v_geometry) <> 'error' THEN
            v_code_insee := GET_CODE_INSEE_CONTAIN_LINE(v_table_name, v_geometry);
        ELSIF GET_CODE_INSEE_POURCENTAGE(v_table_name, v_geometry) <> 'error' THEN
            v_code_insee := GET_CODE_INSEE_POURCENTAGE(v_table_name, v_geometry);
        ELSIF GET_CODE_INSEE_WITHIN_DISTANCE(v_table_name, v_geometry) <> 'error' THEN
            v_code_insee := GET_CODE_INSEE_WITHIN_DISTANCE(v_table_name, v_geometry);
        END IF;
        RETURN v_code_insee;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'erreur';
    END GET_CODE_INSEE_TRONCON;
    
/

create or replace FUNCTION GET_CODE_INSEE_97_COMMUNES_CONTAIN_LINE(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
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
    END GET_CODE_INSEE_97_COMMUNES_CONTAIN_LINE;

/


create or replace FUNCTION GET_CODE_INSEE_97_COMMUNES_POURCENTAGE(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
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
    END GET_CODE_INSEE_97_COMMUNES_POURCENTAGE;

/


create or replace FUNCTION GET_CODE_INSEE_97_COMMUNES_WITHIN_DISTANCE(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
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
    END GET_CODE_INSEE_97_COMMUNES_WITHIN_DISTANCE;

/


create or replace FUNCTION GET_CODE_INSEE_97_COMMUNES_TRONCON(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
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
    END GET_CODE_INSEE_97_COMMUNES_TRONCON;

/

/*
SEQ_TA_TRONCON_OBJECTID : création de la séquence d'auto-incrémentation de la clé primaire de la table TA_TRONCON
*/

CREATE SEQUENCE SEQ_TA_TRONCON_OBJECTID START WITH 1 INCREMENT BY 1;

/

/*
La table TA_AGENT regroupant les pnoms de tous les agents ayant travaillés et qui travaillent encore pour la base voie.
*/

-- 1. Création de la table TA_AGENT
CREATE TABLE G_BASE_VOIE.TA_AGENT(
    numero_agent NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    pnom VARCHAR2(50) NOT NULL,
    validite NUMBER(1) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_AGENT IS 'Table listant les pnoms de tous les agents ayant travaillés et qui travaillent encore pour la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_AGENT.numero_agent IS 'Numéro d''agent présent sur la carte de chaque agent.';
COMMENT ON COLUMN G_BASE_VOIE.TA_AGENT.pnom IS 'Pnom de l''agent, c''est-à-dire la concaténation de l''initiale de son prénom et de son nom entier.';
COMMENT ON COLUMN G_BASE_VOIE.TA_AGENT.validite IS 'Validité de l''agent, c''est-à-dire que ce champ permet de savoir si l''agent continue de travailler dans/pour la base voie ou non : 1 = oui ; 0 = non.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_AGENT 
ADD CONSTRAINT TA_AGENT_PK 
PRIMARY KEY("NUMERO_AGENT") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_AGENT TO G_ADMIN_SIG;
/*
La table TA_RIVOLI regroupe tous les tronçons de la base voie.
*/

-- 1. Création de la table TA_RIVOLI
CREATE TABLE G_BASE_VOIE.TA_RIVOLI(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    code_rivoli CHAR(4) NOT NULL,
    cle_controle CHAR(1)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_RIVOLI IS 'Table rassemblant tous les codes fantoirs issus du fichier fantoir et correspondants aux voies présentes sur le territoire de la MEL.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RIVOLI.objectid IS 'Clé primaire auto-incrémentée de la table identifiant.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RIVOLI.code_rivoli IS 'Code RIVOLI du code fantoir. Ce code est l''identifiant sur 4 caractères de la voie au sein de la commune. Attention : il ne faut pas confondre ce code avec le code de l''ancien fichier RIVOLI, devenu depuis fichier fantoir. Le code RIVOLI fait partie du code fantoir. Attention cet identifiant est recyclé dans le fichier fantoir, ce champ ne doit donc jamais être utilisé en tant que clé primaire ou étrangère.' ;
COMMENT ON COLUMN G_BASE_VOIE.TA_RIVOLI.cle_controle IS 'Clé de contrôle du code fantoir issue du fichier fantoir.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_RIVOLI 
ADD CONSTRAINT TA_RIVOLI_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des index
CREATE INDEX TA_RIVOLI_code_rivoli_IDX ON G_BASE_VOIE.TA_RIVOLI(code_rivoli)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_RIVOLI_cle_controle_IDX ON G_BASE_VOIE.TA_RIVOLI(cle_controle)
    TABLESPACE G_ADT_INDX;

-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_RIVOLI TO G_ADMIN_SIG;

/

/*
La table TA_TYPE_VOIE regroupe tous les types de voies de la base voie tels que les avenues, boulevards, rues, senteir, etc.
*/

-- 1. Création de la table TA_TYPE_VOIE
CREATE TABLE G_BASE_VOIE.TA_TYPE_VOIE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    code_type_voie CHAR(4) NOT NULL,
    libelle VARCHAR2(100) NOT NULL   
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_TYPE_VOIE IS 'Table rassemblant tous les types de voies présents dans la base voie. Ancienne table : TYPEVOIE.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TYPE_VOIE.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TYPE_VOIE.code_type_voie IS 'Code des types de voie présents dans la base voie. Ce champ remplace le champ CCODTVO.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TYPE_VOIE.libelle IS 'Libellé des types de voie. Exemple : Boulevard, avenue, reu, sentier, etc.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_TYPE_VOIE 
ADD CONSTRAINT TA_TYPE_VOIE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 5. Création des index
CREATE INDEX TA_TYPE_VOIE_CODE_TYPE_VOIE_IDX ON G_BASE_VOIE.TA_TYPE_VOIE(code_type_voie)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_TYPE_VOIE TO G_ADMIN_SIG;

/

/*
La table TA_VOIE regroupe tous les informations de chaque voie de la base voie.
*/

-- 1. Création de la table TA_VOIE
CREATE TABLE G_BASE_VOIE.TA_VOIE(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    libelle_voie VARCHAR2(50) NOT NULL,
    complement_nom_voie VARCHAR2(50),
    date_saisie DATE DEFAULT sysdate NOT NULL,
    date_modification DATE DEFAULT sysdate NOT NULL,
    fid_pnom_saisie NUMBER(38,0) NOT NULL,
    fid_pnom_modification NUMBER(38,0) NOT NULL,
    fid_typevoie NUMBER(38,0) NOT NULL,
    fid_genre_voie NUMBER(38,0) NOT NULL,
    fid_rivoli NUMBER(38,0) NULL,
    fid_metadonnee NUMBER(38,0) NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_VOIE IS 'Table rassemblant toutes les informations pour chaque voie de la base. Ancienne table : VOIEVOI';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.objectid IS 'Clé primaire auto-incrémentée de la table. Elle remplace l''ancien identifiant ccomvoie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.libelle_voie IS 'Nom de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.complement_nom_voie IS 'Complément du nom de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.date_saisie IS 'Date de saisie de la voie (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.date_modification IS 'Date de modification de la voie (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé une voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié une voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.fid_typevoie IS 'Clé étangère vers la table TA_TYPE_VOIE permettant de catégoriser les voies de la base.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.fid_genre_voie IS 'Clé étrangère vers la table TA_LIBELLE permettant de connaître le genre du nom de la voie : masculin, féminin, neutre et non-identifié.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.fid_rivoli IS 'Clé étrangère vers la table TA_RIVOLI permettant d''associer un code RIVOLI à chaque voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE.fid_metadonnee IS 'Clé étrangère vers la table G_GEO.TA_METADONNEE permettant de connaître la source des voies (MEL ou IGN).';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_VOIE 
ADD CONSTRAINT TA_VOIE_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_VOIE
ADD CONSTRAINT TA_VOIE_FID_PNOM_SAISIE_FK
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_VOIE
ADD CONSTRAINT TA_VOIE_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_VOIE
ADD CONSTRAINT TA_VOIE_FID_TYPEVOIE_FK 
FOREIGN KEY (fid_typevoie)
REFERENCES G_BASE_VOIE.ta_type_voie(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE
ADD CONSTRAINT TA_VOIE_FID_GENRE_VOIE_FK
FOREIGN KEY (fid_genre_voie)
REFERENCES G_GEO.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE
ADD CONSTRAINT TA_VOIE_FID_RIVOLI_FK
FOREIGN KEY (fid_rivoli)
REFERENCES G_BASE_VOIE.ta_rivoli(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE
ADD CONSTRAINT TA_VOIE_FID_METADONNEE_FK
FOREIGN KEY (fid_metadonnee)
REFERENCES G_GEO.ta_metadonnee(objectid);

-- 5. Création des index sur les clés étrangères
CREATE INDEX TA_VOIE_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TA_VOIE(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TA_VOIE(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_FID_TYPEVOIE_IDX ON G_BASE_VOIE.TA_VOIE(fid_typevoie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_FID_GENRE_VOIE_IDX ON G_BASE_VOIE.TA_VOIE(fid_genre_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_FID_RIVOLI_IDX ON G_BASE_VOIE.TA_VOIE(fid_rivoli)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_FID_METADONNEE_IDX ON G_BASE_VOIE.TA_VOIE(fid_metadonnee)
    TABLESPACE G_ADT_INDX;
    
-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_VOIE TO G_ADMIN_SIG;

/

/*
La table TA_HIERARCHISATION_VOIE permet de hiérarchiser les voies en associant les voies secondaires à leur voie principale.
*/

-- 1. Création de la table TA_HIERARCHISATION_VOIE
CREATE TABLE G_BASE_VOIE.TA_HIERARCHISATION_VOIE(
    fid_voie_principale NUMBER(38,0) NOT NULL,
    fid_voie_secondaire NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_HIERARCHISATION_VOIE IS 'Table permettant de hiérarchiser les voies en associant les voies secondaires à leur voie principale.';
COMMENT ON COLUMN G_BASE_VOIE.TA_HIERARCHISATION_VOIE.fid_voie_principale IS 'Clé primaire (partie 1) de la table et clé étrangère vers TA_VOIE permettant d''associer une voie principale à une voie secondaire';
COMMENT ON COLUMN G_BASE_VOIE.TA_HIERARCHISATION_VOIE.fid_voie_secondaire IS 'Clé primaire (partie 2) et clé étrangère vers TA_VOIE permettant d''associer une voie secondaire à une voie principale.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_HIERARCHISATION_VOIE 
ADD CONSTRAINT TA_HIERARCHISATION_VOIE_PK 
PRIMARY KEY("FID_VOIE_PRINCIPALE", "FID_VOIE_SECONDAIRE") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_HIERARCHISATION_VOIE
ADD CONSTRAINT TA_HIERARCHISATION_VOIE_FID_VOIE_PRINCIPALE_FK 
FOREIGN KEY (fid_voie_principale)
REFERENCES G_BASE_VOIE.ta_voie(objectid);

ALTER TABLE G_BASE_VOIE.TA_HIERARCHISATION_VOIE
ADD CONSTRAINT TA_HIERARCHISATION_VOIE_FID_VOIE_SECONDAIRE_FK 
FOREIGN KEY (fid_voie_secondaire)
REFERENCES G_BASE_VOIE.ta_voie(objectid);

-- 5. Création des index sur les clés étrangères et autres champs
CREATE INDEX TA_HIERARCHISATION_VOIE_FID_VOIE_PRINCIPALE_IDX ON G_BASE_VOIE.TA_HIERARCHISATION_VOIE(fid_voie_principale)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_HIERARCHISATION_VOIE_FID_VOIE_SECONDAIRE_IDX ON G_BASE_VOIE.TA_HIERARCHISATION_VOIE(fid_voie_secondaire)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_HIERARCHISATION_VOIE TO G_ADMIN_SIG;

/

/*
La table TA_VOIE_LOG rassemble toutes les évolutions de chaque voie issue de TA_VOIE.
*/

-- 1. Création de la table TA_VOIE_LOG
CREATE TABLE G_BASE_VOIE.TA_VOIE_LOG(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    libelle_voie VARCHAR2(50) NOT NULL,
    complement_nom_voie VARCHAR2(50),
    date_action DATE NOT NULL,
    fid_typevoie NUMBER(38,0) NOT NULL,
    fid_genre_voie NUMBER(38,0) NOT NULL,
    fid_rivoli NUMBER(38,0) NOT NULL,
    fid_voie NUMBER(38,0) NOT NULL,
    fid_type_action NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0),
    fid_metadonnee NUMBER(38,0) NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_VOIE_LOG IS 'Table rassemblant toutes les informations pour chaque voie de la base. Ancienne table : VOIEVOI';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LOG.objectid IS 'Clé primaire auto-incrémentée de la table. Elle remplace l''ancien identifiant ccomvoie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LOG.libelle_voie IS 'Nom de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LOG.complement_nom_voie IS 'Complément du nom de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LOG.date_action IS 'Date de saisie, modification ou suppression de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LOG.fid_typevoie IS 'Clé étangère vers la table TA_TYPE_VOIE permettant de catégoriser les voies de la base.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LOG.fid_genre_voie IS 'Clé étrangère vers la table TA_LIBELLE permettant de connaître le genre du nom de la voie : masculin, féminin, neutre et non-identifié.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LOG.fid_rivoli IS 'Clé étrangère vers la table TA_FANTOIR permettant d''associer un code fantoir à chaque voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LOG.fid_voie IS 'Identifiant de tronçon de la table TA_VOIE permettant d''identifier la voie qui a été créée, modifiée ou supprimée.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE, permettant d''associer un type d''action à une voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant d''associer le pnom d''un agent à la voie qu''il a créé, modifié ou supprimé.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LOG.fid_metadonnee IS 'Clé étrangère vers la table G_GEO.TA_METADONNEE permettant de connaître notamment la source et l''organisme créateur de la données.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_VOIE_LOG 
ADD CONSTRAINT TA_VOIE_LOG_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_VOIE_LOG
ADD CONSTRAINT TA_VOIE_LOG_FID_TYPE_ACTION_FK
FOREIGN KEY (fid_type_action)
REFERENCES G_GEO.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_VOIE_LOG
ADD CONSTRAINT TA_VOIE_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_VOIE_LOG
ADD CONSTRAINT TA_VOIE_LOG_FID_METADONNEE_FK
FOREIGN KEY (fid_metadonnee)
REFERENCES G_GEO.ta_metadonnee(objectid);

-- 5. Création des index sur les clés étrangères et autres
CREATE INDEX TA_VOIE_LOG_FID_TYPEVOIE_IDX ON G_BASE_VOIE.TA_VOIE_LOG(fid_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_LOG_FID_FANTOIR_IDX ON G_BASE_VOIE.TA_VOIE_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_LOG_FID_GENRE_VOIE_IDX ON G_BASE_VOIE.TA_VOIE_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_VOIE_LOG_FID_METADONNEE_IDX ON G_BASE_VOIE.TA_VOIE_LOG(fid_metadonnee)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_VOIE_LOG TO G_ADMIN_SIG;

/

/*
La table TA_TRONCON regroupe tous les tronçons de la base voie.
*/

-- 1. Création de la table TA_TRONCON
CREATE TABLE G_BASE_VOIE.TA_TRONCON(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    geom SDO_GEOMETRY NOT NULL,
    sens CHAR(1 BYTE),
    ordre_troncon NUMBER(2,0),
    date_saisie DATE DEFAULT sysdate NOT NULL,
    date_modification DATE DEFAULT sysdate NOT NULL,
    fid_voie NUMBER(38,0),
    fid_pnom_saisie NUMBER(38,0) NOT NULL,
    fid_pnom_modification NUMBER(38,0) NOT NULL,
    fid_metadonnee NUMBER(38,0) NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_TRONCON IS 'Table contenant les tronçons de la base voie. Les tronçons sont les objets de base de la base voie servant à constituer les rues qui elles-mêmes constituent les voies. Ancienne table : ILTATRC.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.objectid IS 'Clé primaire de la table identifiant chaque tronçon. Cette pk est auto-incrémentée et remplace l''ancien identifiant cnumtrc.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.geom IS 'Géométrie de type ligne simple de chaque tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.sens IS 'Code permettant de connaître le sens de saisie du tronçon par rapport au sens de la voie : + = dans le sens de la voie ; - = dans le sens inverse de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.ordre_troncon IS 'Ordre dans lequel les tronçons se positionnent afin de constituer la voie. 1 est égal au début de la voie et 1 + n est égal au tronçon suivant.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.date_saisie IS 'date de saisie du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.date_modification IS 'Dernière date de modification du tronçon (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié un tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.fid_voie IS 'Clé étrangère vers la table TA_VOIE permettant d''associer une voie à un ou plusieurs tronçons. Ancien champ : CCOMVOI.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON.fid_metadonnee IS 'Clé étrangère vers la table G_GEO.TA_METADONNEE permettant de connaître la source des tronçons (MEL ou IGN).';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_TRONCON 
ADD CONSTRAINT TA_TRONCON_PK 
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
    'TA_TRONCON',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TA_TRONCON_SIDX
ON G_BASE_VOIE.TA_TRONCON(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_TRONCON
ADD CONSTRAINT TA_TRONCON_FID_PNOM_SAISIE_FK 
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_TRONCON
ADD CONSTRAINT TA_TRONCON_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_TRONCON
ADD CONSTRAINT TA_TRONCON_FID_VOIE_FK
FOREIGN KEY (fid_voie)
REFERENCES G_BASE_VOIE.TA_VOIE(objectid);

ALTER TABLE G_BASE_VOIE.TA_TRONCON
ADD CONSTRAINT TA_TRONCON_FID_METADONNEE_FK
FOREIGN KEY (fid_metadonnee)
REFERENCES G_GEO.ta_metadonnee(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TA_TRONCON_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TA_TRONCON(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TA_TRONCON(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_FID_VOIE_IDX ON G_BASE_VOIE.TA_TRONCON(fid_voie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_FID_METADONNEE_IDX ON G_BASE_VOIE.TA_TRONCON(fid_metadonnee)
    TABLESPACE G_ADT_INDX;

-- Cet index dispose d'une fonction permettant d'accélérer la récupération du code INSEE de la commune d'appartenance du tronçon. 
-- Il créé également un champ virtuel dans lequel on peut aller chercher ce code INSEE.
CREATE INDEX TA_TRONCON_CODE_INSEE_IDX
ON G_BASE_VOIE.TA_TRONCON(GET_CODE_INSEE_TRONCON('TA_TRONCON', geom))
TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_TRONCON TO G_ADMIN_SIG;

/

/*
La table TA_TRONCON_LOG regroupe toutes les évolutions des tronçons de la base voie situés dans TA_TRONCON.
*/

-- 1. Création de la table TA_TRONCON_LOG
CREATE TABLE G_BASE_VOIE.TA_TRONCON_LOG(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    geom SDO_GEOMETRY NOT NULL,
    date_action DATE NOT NULL,
    fid_type_action NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0) NOT NULL,
    fid_troncon NUMBER(38,0) NOT NULL,
    fid_troncon_pere NUMBER(38,0),
    fid_metadonnee NUMBER(38,0) NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_TRONCON_LOG IS 'Table d''historisation des actions effectuées sur les tronçons de la base voie. Cette table reprend notamment le champ fid_troncon_pere de l''ancienne table ILTAFILIA.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.geom IS 'Géométrie de type ligne simple de chaque tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.date_action IS 'date de saisie, modification et suppression du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de catégoriser le type d''action effectué sur les tronçons.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant d''associer le pnom d''un agent au tronçon qu''il a créé, modifié ou supprimé.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.fid_troncon IS 'Clé étrangère vers la table TA_TRONCON permettant de savoir sur quel tronçon ont été effectué les actions.';
COMMENT ON COLUMN G_BASE_VOIE.TA_TRONCON_LOG.fid_troncon_pere IS 'Clé étrangère vers la table TA_TRONCON permettant, en cas de coupure de tronçon, de savoir quel était le tronçon original.';
COMMENT ON COLUMN G_BASE_VOIE.TA_VOIE_LOG.fid_metadonnee IS 'Clé étrangère vers la table G_GEO.TA_METADONNEE permettant de connaître notamment la source et l''organisme créateur de la données.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_TRONCON_LOG 
ADD CONSTRAINT TA_TRONCON_LOG_PK 
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
    'TA_TRONCON_LOG',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TA_TRONCON_LOG_SIDX
ON G_BASE_VOIE.TA_TRONCON_LOG(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=LINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_TRONCON_LOG
ADD CONSTRAINT TA_TRONCON_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_GEO.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_TRONCON_LOG
ADD CONSTRAINT TA_TRONCON_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_TRONCON_LOG
ADD CONSTRAINT TA_TRONCON_LOG_FID_METADONNEE_FK
FOREIGN KEY (fid_metadonnee)
REFERENCES G_GEO.TA_METADONNEE(objectid);

-- 7. Création des index sur les clés étrangères
CREATE INDEX TA_TRONCON_LOG_FID_TRONCON_IDX ON G_BASE_VOIE.TA_TRONCON_LOG(fid_troncon)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_LOG_FID_TRONCON_PERE_IDX ON G_BASE_VOIE.TA_TRONCON_LOG(fid_troncon_pere)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_TRONCON_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_TRONCON_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_TRONCON_LOG_FID_METADONNEE_IDX ON G_BASE_VOIE.TA_TRONCON_LOG(fid_metadonnee)
    TABLESPACE G_ADT_INDX;
    
-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_TRONCON_LOG TO G_ADMIN_SIG;

/

/*
La table TA_SEUIL regroupe tous les seuils de la base voie.
*/

-- 1. Création de la table TA_SEUIL
CREATE TABLE G_BASE_VOIE.TA_SEUIL(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    geom SDO_GEOMETRY,
    cote_troncon CHAR(1),
    code_insee AS (TRIM(GET_CODE_INSEE_97_COMMUNES_CONTAIN_POINT('TA_SEUIL', geom))),
    date_saisie DATE DEFAULT sysdate NOT NULL,
    date_modification DATE DEFAULT sysdate NOT NULL,
    fid_pnom_saisie NUMBER(38,0) NOT NULL,
    fid_pnom_modification NUMBER(38,0) NOT NULL,
    fid_troncon NUMBER(38,0),
    temp_idseui NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_SEUIL IS 'Table contenant les seuils de la Base Voie. Plusieurs seuils peuvent se situer sur le même point géographique. Ancienne table : ILTASEU';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.objectid IS 'Clé primaire auto-incrémentée de la table identifiant chaque seuil. Cette pk remplace l''ancien identifiant idseui.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.geom IS 'Géométrie de type point de chaque seuil présent dans la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.cote_troncon IS 'Côté du tronçon auquel est rattaché le seuil. G = gauche ; D = droite. En agglomération le sens des tronçons est déterminé par ses numéros de seuils. En d''autres termes il commence au niveau du seuil dont le numéro est égal à 1. Hors agglomération, le sens du tronçon dépend du sens de circulation pour les rues à sens unique. Pour les rues à double-sens chaque tronçon est doublé donc leur sens dépend aussi du sens de circulation;';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.code_insee IS 'Code INSEE de chaque seuil calculé à partir du référentiel des communes G_REFERENTIEL.MEL_COMMUNE_LLH.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.date_saisie IS 'date de saisie du seuil (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.date_modification IS 'Dernière date de modification du seuil(par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.fid_troncon IS 'Clé étrangère vers la table TA_TRONCON permettant d''associer un troncon à un ou plusieurs seuils.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL.temp_idseui IS 'Champ temporaire servant à l''import des données. Ce champ sera supprimé une fois l''import terminé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_SEUIL 
ADD CONSTRAINT TA_SEUIL_PK 
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
    'TA_SEUIL',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TA_SEUIL_SIDX
ON G_BASE_VOIE.TA_SEUIL(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_SEUIL
ADD CONSTRAINT TA_SEUIL_FID_PNOM_SAISIE_FK
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_SEUIL
ADD CONSTRAINT TA_SEUIL_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_SEUIL
ADD CONSTRAINT TA_SEUIL_FID_TRONCON_FK
FOREIGN KEY (fid_troncon)
REFERENCES G_BASE_VOIE.TA_TRONCON(objectid);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TA_SEUIL_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TA_SEUIL(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TA_SEUIL(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_FID_TRONCON_IDX ON G_BASE_VOIE.TA_SEUIL(fid_troncon)
    TABLESPACE G_ADT_INDX;
    
-- Cet index dispose d'une fonction permettant d'accélérer la récupération du code INSEE de la commune d'appartenance du seuil. 
-- Il créé également un champ virtuel dans lequel on peut aller chercher ce code INSEE.
CREATE INDEX TA_SEUIL_CODE_INSEE_IDX
ON G_BASE_VOIE.TA_SEUIL(GET_CODE_INSEE_CONTAIN_POINT('TA_SEUIL', geom))
TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_SEUIL TO G_ADMIN_SIG;

/

/*
La table TA_SEUIL_LOG  permet d''avoir l''historique de toutes les évolutions des seuils de la base voie.
*/

-- 1. Création de la table TA_SEUIL_LOG
CREATE TABLE G_BASE_VOIE.TA_SEUIL_LOG(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    geom SDO_GEOMETRY NOT NULL,
    cote_troncon CHAR(1) NOT NULL,
    code_insee VARCHAR2(4000) NOT NULL,
    date_action DATE NOT NULL,
    fid_type_action NUMBER(38,0),
    fid_seuil NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_SEUIL_LOG IS 'Table de log de la table TA_SEUIL permettant d''avoir l''historique de toutes les évolutions des seuils.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.geom IS 'Géométrie de type point de chaque seuil présent dans la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.cote_troncon IS 'Côté du tronçon auquel est rattaché le seuil. G = gauche ; D = droite. En agglomération le sens des tronçons est déterminé par ses numéros de seuils. En d''autres termes il commence au niveau du seuil dont le numéro est égal à 1. Hors agglomération, le sens du tronçon dépend du sens de circulation pour les rues à sens unique. Pour les rues à double-sens chaque tronçon est doublé donc leur sens dépend aussi du sens de circulation.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.code_insee IS 'Champ calculé via une requête spatiale, permettant d''associer à chaque seuil le code insee de la commune dans laquelle il se trouve (issue de la table G_REFERENTIEL.MEL_COMMUNES).';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.date_action IS 'Date de création, modification ou suppression d''un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de savoir quelle action a été effectuée sur le seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.fid_seuil IS 'Clé étrangère vers la table TA_SEUIL permettant de savoir sur quel seuil les actions ont été entreprises.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant d''associer le pnom d''un agent au seuil qu''il a créé, modifié ou supprimé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_SEUIL_LOG 
ADD CONSTRAINT TA_SEUIL_LOG_PK 
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
    'TA_SEUIL_LOG',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TA_SEUIL_LOG_SIDX
ON G_BASE_VOIE.TA_SEUIL_LOG(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_SEUIL_LOG
ADD CONSTRAINT TA_SEUIL_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_GEO.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_SEUIL_LOG
ADD CONSTRAINT TA_SEUIL_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TA_SEUIL_LOG_FID_SEUIL_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(fid_seuil)
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX TA_SEUIL_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_SEUIL_LOG_CODE_INSEE_IDX ON G_BASE_VOIE.TA_SEUIL_LOG(code_insee)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_SEUIL_LOG TO G_ADMIN_SIG;

/

/*
La table TA_INFOS_SEUIL regroupe le détail des seuils de la base voie.
*/

-- 1. Création de la table TA_INFOS_SEUIL
CREATE TABLE G_BASE_VOIE.TA_INFOS_SEUIL(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    numero_seuil NUMBER(5,0) NOT NULL,
    numero_parcelle CHAR(9) NOT NULL,
    complement_numero_seuil VARCHAR2(10),
    date_saisie DATE DEFAULT sysdate NOT NULL,
    date_modification DATE DEFAULT sysdate NOT NULL,
    fid_seuil NUMBER(38,0) NOT NULL,
    fid_pnom_saisie NUMBER(38,0),
    fid_pnom_modification NUMBER(38,0)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_INFOS_SEUIL IS 'Table contenant le détail des seuils, c''est-à-dire les numéros de seuil, de parcelles et les compléments de numéro de seuil. Cela permet d''associer un ou plusieurs seuils à un et un seul point géométrique au besoin.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL.numero_seuil IS 'Numéro de seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL.numero_parcelle IS 'Numéro de parcelle issu du cadastre.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL.complement_numero_seuil IS 'Complément du numéro de seuil. Exemple : 1 bis';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL.date_saisie IS 'Date de saisie des informations du seuil (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL.date_modification IS 'Date de modification des informations du seuil (par défaut la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL.fid_seuil IS 'Clé étrangère vers la table TA_SEUIL, permettant d''affecter une géométrie à un ou plusieurs seuils, dans le cas où plusieurs se superposent sur le même point.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé les informations d''un seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié les informations d''un seuil.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_INFOS_SEUIL 
ADD CONSTRAINT TA_INFOS_SEUIL_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_INFOS_SEUIL
ADD CONSTRAINT TA_INFOS_SEUIL_FID_SEUIL_FK 
FOREIGN KEY (fid_seuil)
REFERENCES G_BASE_VOIE.ta_seuil(objectid);

ALTER TABLE G_BASE_VOIE.TA_INFOS_SEUIL
ADD CONSTRAINT TA_INFOS_SEUIL_FID_PNOM_SAISIE_FK 
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_INFOS_SEUIL
ADD CONSTRAINT TA_INFOS_SEUIL_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

-- 5. Création des index sur les clés étrangères et autres champs
CREATE INDEX TA_INFOS_SEUIL_FID_SEUIL_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL(fid_seuil)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_SEUIL_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_SEUIL_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_SEUIL_NUMERO_SEUIL_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL(numero_seuil)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_INFOS_SEUIL TO G_ADMIN_SIG;

/

/*
La table TA_INFOS_SEUIL_LOG regroupe toutes les évlutions des objets présents dans la table TA_INFOS_SEUIL de la base voie.
*/

-- 1. Création de la table TA_INFOS_SEUIL_LOG
CREATE TABLE G_BASE_VOIE.TA_INFOS_SEUIL_LOG(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    numero_seuil NUMBER(5,0) NOT NULL,
    numero_parcelle CHAR(9) NOT NULL,
    complement_numero_seuil VARCHAR2(10),
    date_action DATE NOT NULL,
    fid_infos_seuil NUMBER(38,0) NOT NULL,
    fid_seuil NUMBER(38,0) NOT NULL,
    fid_type_action NUMBER(38,0) NOT NULL,
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_INFOS_SEUIL_LOG IS 'Table de log permettant d''enregistrer toutes les évlutions des objets présents dans la table TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.numero_seuil IS 'Numéro de seuil.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.numero_parcelle IS 'Numéro de parcelle issu du cadastre.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.complement_numero_seuil IS 'Complément du numéro de seuil. Exemple : 1 bis';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.date_action IS 'Date de chaque action effectuée sur les objets de la table TA_INFOS_SEUILS.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.fid_infos_seuil IS 'Identifiant du seuil dans la table TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.fid_seuil IS 'Identifiant de la table TA_SEUIL, permettant d''affecter une géométrie à un ou plusieurs seuils, dans le cas où plusieurs se superposent sur le même point.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de catégoriser les actions effectuées sur la table TA_INFOS_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_SEUIL_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé, modifié ou supprimé des données dans TA_INFOS_SEUIL.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_INFOS_SEUIL_LOG 
ADD CONSTRAINT TA_INFOS_SEUIL_LOG_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_INFOS_SEUIL_LOG
ADD CONSTRAINT TA_INFOS_SEUIL_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_GEO.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_INFOS_SEUIL_LOG
ADD CONSTRAINT TA_INFOS_SEUIL_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

-- 5. Création des index sur les clés étrangères et les autres champs
CREATE INDEX TA_INFOS_SEUIL_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_SEUIL_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_SEUIL_LOG_FID_INFOS_SEUIL_IDX ON G_BASE_VOIE.TA_INFOS_SEUIL_LOG(fid_infos_seuil)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_INFOS_SEUIL_LOG TO G_ADMIN_SIG;

/

/*
La table TA_POINT_INTERET regroupe toutes les géométries des point d''intérêts de la base voie.
*/

-- 1. Création de la table TA_POINT_INTERET
CREATE TABLE G_BASE_VOIE.TA_POINT_INTERET(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    geom SDO_GEOMETRY,
    date_saisie DATE DEFAULT sysdate NOT NULL,
    date_modification DATE DEFAULT sysdate NOT NULL,
    fid_pnom_saisie NUMBER(38,0) NOT NULL,
    fid_pnom_modification NUMBER(38,0) NOT NULL,
    temp_idpoi NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_POINT_INTERET IS 'Table regroupant toutes les géométries des points d''intérêt de type mairie ou mairie de quartier. Ancienne table : ILTALPU.';
COMMENT ON COLUMN G_BASE_VOIE.TA_POINT_INTERET.objectid IS 'Clé primaire auto-incrémentée de la table identifiant chaque point d''intérêt. Cette pk remplace l''ancien identifiant cnumlpu.';
COMMENT ON COLUMN G_BASE_VOIE.TA_POINT_INTERET.geom IS 'Géométrie de type point de chaque point d''intérêt présent dans la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_POINT_INTERET.date_saisie IS 'Date de saisie du point d''intérêt (par défaut il s''agit de la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_POINT_INTERET.date_modification IS 'Dernière date de modification du point d''intérêt (par défaut il s''agit de la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_POINT_INTERET.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé un point d''intérêt.';
COMMENT ON COLUMN G_BASE_VOIE.TA_POINT_INTERET.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié un point d''intérêt.';
COMMENT ON COLUMN G_BASE_VOIE.TA_POINT_INTERET.temp_idpoi IS 'Champ temporaire permettant de stocker l''identifiant de chaque POI et de faire la migration. A l''issue de cette dernière, ce champ doit être supprimé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_POINT_INTERET 
ADD CONSTRAINT TA_POINT_INTERET_PK 
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
    'TA_POINT_INTERET',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TA_POINT_INTERET_SIDX
ON G_BASE_VOIE.TA_POINT_INTERET(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_POINT_INTERET
ADD CONSTRAINT TA_POINT_INTERET_FID_PNOM_SAISIE_FK
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_POINT_INTERET
ADD CONSTRAINT TA_POINT_INTERET_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

-- 7. Création des index sur les clés étrangères et autres
CREATE INDEX TA_POINT_INTERET_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TA_POINT_INTERET(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_POINT_INTERET_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TA_POINT_INTERET(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_POINT_INTERET_CODE_INSEE_IDX
ON G_BASE_VOIE.TA_POINT_INTERET(GET_CODE_INSEE_CONTAIN_POINT('TA_POINT_INTERET', geom))
TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_POINT_INTERET TO G_ADMIN_SIG;

/

/*
La table TA_POINT_INTERET_LOG  permet d''avoir l''historique de toutes les évolutions des seuils de la base voie.
*/

-- 1. Création de la table TA_POINT_INTERET_LOG
CREATE TABLE G_BASE_VOIE.TA_POINT_INTERET_LOG(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    geom SDO_GEOMETRY NOT NULL,
    code_insee VARCHAR2(4000) NOT NULL,
    date_action DATE NOT NULL,
    fid_point_interet NUMBER(38,0) NOT NULL,
    fid_type_action NUMBER(38,0),
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_POINT_INTERET_LOG IS 'Table de log de la table TA_POINT_INTERET permettant d''avoir l''historique de toutes les évolutions des POI.';
COMMENT ON COLUMN G_BASE_VOIE.TA_POINT_INTERET_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_POINT_INTERET_LOG.geom IS 'Géométrie de type point de chaque objet de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_POINT_INTERET_LOG.fid_point_interet IS 'Identifiant de la table TA_POINT_INTERET permettant de savoir sur quel POI les actions ont été entreprises.';
COMMENT ON COLUMN G_BASE_VOIE.TA_SEUIL_LOG.code_insee IS 'Champ permettant d''associer à chaque POI le code insee de la commune dans laquelle il se trouve (issue de la table G_REFERENTIEL.MEL_COMMUNES).';
COMMENT ON COLUMN G_BASE_VOIE.TA_POINT_INTERET_LOG.date_action IS 'Date de création, modification ou suppression d''un POI.';
COMMENT ON COLUMN G_BASE_VOIE.TA_POINT_INTERET_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de savoir quelle action a été effectuée sur le POI.';
COMMENT ON COLUMN G_BASE_VOIE.TA_POINT_INTERET_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant d''associer le pnom d''un agent au POI qu''il a créé, modifié ou supprimé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_POINT_INTERET_LOG 
ADD CONSTRAINT TA_POINT_INTERET_LOG_PK 
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
    'TA_POINT_INTERET_LOG',
    'geom',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 5. Création de l'index spatial sur le champ geom
CREATE INDEX TA_POINT_INTERET_LOG_SIDX
ON G_BASE_VOIE.TA_POINT_INTERET_LOG(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=POINT, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_POINT_INTERET_LOG
ADD CONSTRAINT TA_POINT_INTERET_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_GEO.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_POINT_INTERET_LOG
ADD CONSTRAINT TA_POINT_INTERET_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

-- 7. Création des index sur les clés étrangères et autres champs
CREATE INDEX TA_POINT_INTERET_LOG_fid_point_interet_IDX ON G_BASE_VOIE.TA_POINT_INTERET_LOG(fid_point_interet)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_POINT_INTERET_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_POINT_INTERET_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_POINT_INTERET_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_POINT_INTERET_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_POINT_INTERET_LOG_CODE_INSEE_IDX ON G_BASE_VOIE.TA_POINT_INTERET_LOG(code_insee)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_POINT_INTERET_LOG TO G_ADMIN_SIG;

/


/*
La table TA_INFOS_POINT_INTERET regroupe tous les point d''intérêts de la base voie.
*/

-- 1. Création de la table TA_INFOS_POINT_INTERET
CREATE TABLE G_BASE_VOIE.TA_INFOS_POINT_INTERET(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    nom VARCHAR2(200),
    complement_infos VARCHAR2(250),
    date_saisie DATE DEFAULT sysdate NOT NULL,
    date_modification DATE DEFAULT sysdate NOT NULL,
    fid_libelle NUMBER(38,0),
    fid_point_interet NUMBER(38,0),
    fid_pnom_saisie NUMBER(38,0) NOT NULL,
    fid_pnom_modification NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_INFOS_POINT_INTERET IS 'Table contenant les informations de tous les points d''intérêts que nous gérons, c''est-à-dire les mairies et les mairies annexes. Ancienne table : ILTALPU.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET.objectid IS 'Clé primaire auto-incrémentée de la table identifiant chaque point d''intérêt. Cette pk remplace l''ancien identifiant cnumlpu.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET.nom IS 'Nom du Point d''intérêt correspondant au champ CLIBLPU de l''ancienne table ILTALPU.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET.complement_infos IS 'Complément d''informations du point d''intérêt.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET.date_saisie IS 'Date de saisie du point d''intérêt (par défaut il s''agit de la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET.date_modification IS 'Dernière date de modification du point d''intérêt (par défaut il s''agit de la date du jour).';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET.fid_libelle IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé un point d''intérêt.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET.fid_point_interet IS 'Clé étrangère vers la table TA_POINT_INTERET permettant d''associer un POI à sa géométrie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET.fid_pnom_saisie IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant créé un point d''intérêt.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET.fid_pnom_modification IS 'Clé étrangère vers la table TA_AGENT permettant de récupérer le pnom de l''agent ayant modifié un point d''intérêt.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_INFOS_POINT_INTERET 
ADD CONSTRAINT TA_INFOS_POINT_INTERET_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 6. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_INFOS_POINT_INTERET
ADD CONSTRAINT TA_INFOS_POINT_INTERET_FID_PNOM_SAISIE_FK
FOREIGN KEY (fid_pnom_saisie)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_INFOS_POINT_INTERET
ADD CONSTRAINT TA_INFOS_POINT_INTERET_FID_PNOM_MODIFICATION_FK
FOREIGN KEY (fid_pnom_modification)
REFERENCES G_BASE_VOIE.TA_AGENT(numero_agent);

ALTER TABLE G_BASE_VOIE.TA_INFOS_POINT_INTERET
ADD CONSTRAINT TA_INFOS_POINT_INTERET_FID_LIBELLE_FK
FOREIGN KEY (fid_libelle)
REFERENCES G_GEO.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_INFOS_POINT_INTERET
ADD CONSTRAINT TA_INFOS_POINT_INTERET_FID_POINT_INTERET_FK
FOREIGN KEY (fid_point_interet)
REFERENCES G_BASE_VOIE.TA_POINT_INTERET(objectid);

-- 7. Création des index sur les clés étrangères
CREATE INDEX TA_INFOS_POINT_INTERET_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TA_INFOS_POINT_INTERET(fid_pnom_saisie)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_POINT_INTERET_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TA_INFOS_POINT_INTERET(fid_pnom_modification)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_POINT_INTERET_FID_LIBELLE_IDX ON G_BASE_VOIE.TA_INFOS_POINT_INTERET(fid_libelle)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_POINT_INTERET_FID_INFOS_POINT_INTERET_IDX ON G_BASE_VOIE.TA_INFOS_POINT_INTERET(fid_point_interet)
    TABLESPACE G_ADT_INDX;

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_INFOS_POINT_INTERET TO G_ADMIN_SIG;

/


/*
La table TA_INFOS_POINT_INTERET_LOG  permet d''avoir l''historique de toutes les évolutions des seuils de la base voie.
*/

-- 1. Création de la table TA_INFOS_POINT_INTERET_LOG
CREATE TABLE G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG(
    objectid NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY,
    complement_infos VARCHAR2(250) NULL,
    nom VARCHAR2(200) NOT NULL,
    date_action DATE NOT NULL,
    fid_infos_point_interet NUMBER(38,0) NOT NULL,
    fid_point_interet NUMBER(38,0) NOT NULL,
    fid_libelle NUMBER(38,0) NOT NULL,
    fid_type_action NUMBER(38,0),
    fid_pnom NUMBER(38,0) NOT NULL
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG IS 'Table d''historisation des actions effectuées sur les POI de la base voie.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG.complement_infos IS 'Complément d''informations du point d''intérêt.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG.nom IS 'Nom du point d''intérêt correspondant au champ CLIBLPU de l''ancienne table ILTALPU.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG.date_action IS 'Date de création, modification ou suppression d''un POI.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG.fid_infos_point_interet IS 'Identifiant de la table TA_INFOS_POINT_INTERET permettant de savoir sur quel POI les actions ont été entreprises.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG.fid_point_interet IS 'Identifiant de la table TA_POINT_INTERET permettant de relier la géométrie du point d''intérêt (TA_POINT_INTERET) à ses informations.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG.fid_libelle IS 'Identifiant de la table TA_LIBELLE permettant de connaître le type de chaque POI (point d''intérêt).';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG.fid_type_action IS 'Clé étrangère vers la table TA_LIBELLE permettant de savoir quelle action a été effectuée sur le POI.';
COMMENT ON COLUMN G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG.fid_pnom IS 'Clé étrangère vers la table TA_AGENT permettant d''associer le pnom d''un agent au POI qu''il a créé, modifié ou supprimé.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG 
ADD CONSTRAINT TA_INFOS_POINT_INTERET_LOG_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des clés étrangères
ALTER TABLE G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG
ADD CONSTRAINT TA_INFOS_POINT_INTERET_LOG_FID_TYPE_ACTION_FK 
FOREIGN KEY (fid_type_action)
REFERENCES G_GEO.TA_LIBELLE(objectid);

ALTER TABLE G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG
ADD CONSTRAINT TA_INFOS_POINT_INTERET_LOG_FID_PNOM_FK
FOREIGN KEY (fid_pnom)
REFERENCES G_BASE_VOIE.ta_agent(numero_agent);

-- 5. Création des index sur les clés étrangères et autres champs
CREATE INDEX TA_INFOS_POINT_INTERET_LOG_FID_INFOS_POINT_INTERET_IDX ON G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG(fid_infos_point_interet)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_POINT_INTERET_LOG_FID_POINT_INTERET_IDX ON G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG(fid_point_interet)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_POINT_INTERET_LOG_FID_TYPE_ACTION_IDX ON G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG(fid_type_action)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_INFOS_POINT_INTERET_LOG_FID_PNOM_IDX ON G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG(fid_pnom)
    TABLESPACE G_ADT_INDX;

-- 6. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG TO G_ADMIN_SIG;

/
/*
Création d'un champ temporaire nécessaire à l'import des données dans les tables finales de la Base Voie
*/

ALTER TABLE G_BASE_VOIE.TEMP_VOIEVOI ADD temp_code_fantoir CHAR(11);
COMMENT ON COLUMN G_BASE_VOIE.TEMP_VOIEVOI.temp_code_fantoir IS 'Champ temporaire contenant le VRAI code fantoir des voies.';/*
Déclencheur permettant de remplir la table de logs TA_INFOS_SEUIL_LOG dans laquelle sont enregistrés chaque insertion, 
modification et suppression des données de la table TA_INFOS_SEUIL avec leur date et le pnom de l'agent les ayant effectuées.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUD_TA_INFOS_SEUIL_LOG
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TA_INFOS_SEUIL
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_insertion NUMBER(38,0);
    v_id_modification NUMBER(38,0);
    v_id_suppression NUMBER(38,0);
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- Sélection des id des actions présentes dans la table TA_LIBELLE
    SELECT 
        a.objectid INTO v_id_insertion 
    FROM 
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long 
    WHERE 
        b.valeur = 'insertion';

    SELECT 
        a.objectid INTO v_id_modification 
    FROM 
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long 
    WHERE 
        b.valeur = 'édition';
            
    SELECT 
        a.objectid INTO v_id_suppression 
    FROM 
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long 
    WHERE 
        b.valeur = 'suppression';

    IF INSERTING THEN -- En cas d'insertion on insère les valeurs de la table TA_INFOS_SEUIL, le numéro d'agent correspondant à l'utilisateur, la date de insertion et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_INFOS_SEUIL_LOG(fid_infos_seuil, numero_seuil, numero_parcelle, complement_numero_seuil, date_action, fid_seuil, fid_type_action, fid_pnom)
            VALUES(
                    :new.objectid, 
                    :new.numero_seuil, 
                    :new.numero_parcelle, 
                    :new.complement_numero_seuil, 
                    sysdate,
                    :new.fid_seuil,
                    v_id_insertion,
                    v_id_agent);
    ELSE
        IF UPDATING THEN -- En cas de modification on insère les valeurs de la table TA_INFOS_SEUIL, le numéro d'agent correspondant à l'utilisateur, la date de modification et le type de modification.
            INSERT INTO G_BASE_VOIE.TA_INFOS_SEUIL_LOG(fid_infos_seuil, numero_seuil, numero_parcelle, complement_numero_seuil, date_action, fid_seuil, fid_type_action, fid_pnom)
            VALUES(
                    :old.objectid, 
                    :old.numero_seuil, 
                    :old.numero_parcelle, 
                    :old.complement_numero_seuil, 
                    sysdate,
                    :old.fid_seuil,
                    v_id_modification,
                    v_id_agent);
        END IF;
    END IF;
    IF DELETING THEN -- En cas de suppression on insère les valeurs de la table TA_INFOS_SEUIL, le numéro d'agent correspondant à l'utilisateur, la date de suppression et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_INFOS_SEUIL_LOG(fid_infos_seuil, numero_seuil, numero_parcelle, complement_numero_seuil, date_action, fid_seuil, fid_type_action, fid_pnom)
        VALUES(
                :old.objectid, 
                :old.numero_seuil, 
                :old.numero_parcelle, 
                :old.complement_numero_seuil, 
                sysdate,
                :old.fid_seuil,
                v_id_suppression,
                v_id_agent);
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUD_TA_INFOS_SEUIL_LOG','bjacq@lillemetropole.fr');
END;

/
/*
Déclencheur permettant de remplir la table de logs TA_SEUIL_LOG dans laquelle sont enregistrés chaque insertion, 
modification et suppression des données de la table TA_SEUIL avec leur date et le pnom de l'agent les ayant effectuées.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUD_TA_SEUIL_LOG
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TA_SEUIL
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_insertion NUMBER(38,0);
    v_id_modification NUMBER(38,0);
    v_id_suppression NUMBER(38,0);
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- Sélection des id des actions présentes dans la table TA_LIBELLE
    SELECT 
        a.objectid INTO v_id_insertion 
    FROM 
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long 
    WHERE 
        b.valeur = 'insertion';

    SELECT 
        a.objectid INTO v_id_modification 
    FROM 
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long 
    WHERE 
        b.valeur = 'édition';
            
    SELECT 
        a.objectid INTO v_id_suppression 
    FROM 
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long 
    WHERE 
        b.valeur = 'suppression';

    IF INSERTING THEN -- En cas d'insertion on insère les valeurs de la table TA_SEUIL_LOG, le numéro d'agent correspondant à l'utilisateur, la date de insertion et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_SEUIL_LOG(fid_seuil, geom, code_insee, cote_troncon, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :new.objectid, 
                    :new.geom,
                    GET_CODE_INSEE_CONTAIN_POINT('TA_SEUIL', :new.geom),
                    :new.cote_troncon,
                    sysdate,
                    v_id_insertion,
                    v_id_agent);
    ELSE
        IF UPDATING THEN -- En cas de modification on insère les valeurs de la table TA_SEUIL_LOG, le numéro d'agent correspondant à l'utilisateur, la date de modification et le type de modification.
            INSERT INTO G_BASE_VOIE.TA_SEUIL_LOG(fid_seuil, geom, code_insee, cote_troncon, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :old.objectid,
                    :old.geom,
                    GET_CODE_INSEE_CONTAIN_POINT('TA_SEUIL', :old.geom),
                    :old.cote_troncon,
                    sysdate,
                    v_id_modification,
                    v_id_agent);
        END IF;
    END IF;
    IF DELETING THEN -- En cas de suppression on insère les valeurs de la table TA_SEUIL_LOG, le numéro d'agent correspondant à l'utilisateur, la date de suppression et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_SEUIL_LOG(fid_seuil, geom, code_insee, cote_troncon, date_action, fid_type_action, fid_pnom)
        VALUES(
                :old.objectid,
                :old.geom,
                GET_CODE_INSEE_CONTAIN_POINT('TA_SEUIL', :old.geom), 
                :old.cote_troncon,
                sysdate,
                v_id_suppression,
                v_id_agent);
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUD_TA_SEUIL_LOG','bjacq@lillemetropole.fr');
END;

/
/*
Déclencheur permettant de remplir la table de logs TA_TRONCON_LOG dans laquelle sont enregistrés chaque insertion, 
modification et suppression des données de la table TA_TRONCON avec leur date et le pnom de l'agent les ayant effectuées.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUD_TA_TRONCON_LOG
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TA_TRONCON
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_insertion NUMBER(38,0);
    v_id_modification NUMBER(38,0);
    v_id_suppression NUMBER(38,0);
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- Sélection des id des actions présentes dans la table TA_LIBELLE
    SELECT
        a.objectid INTO v_id_insertion
    FROM
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long
    WHERE
        b.valeur = 'insertion';

    SELECT
        a.objectid INTO v_id_modification
    FROM
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long
    WHERE
        b.valeur = 'édition';

    SELECT
        a.objectid INTO v_id_suppression
    FROM
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long
    WHERE
        b.valeur = 'suppression';

    IF INSERTING THEN -- En cas d'insertion on insère les valeurs de la table TA_TRONCON_LOG, le numéro d'agent correspondant à l'utilisateur, la date de insertion et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(fid_troncon, geom, date_action, fid_type_action, fid_pnom, fid_metadonnee)
            VALUES(
                    :new.objectid,
                    :new.geom,
                    sysdate,
                    v_id_insertion,
                    v_id_agent,
                    :new.fid_metadonnee);
    ELSE
        IF UPDATING THEN -- En cas de modification on insère les valeurs de la table TA_TRONCON_LOG, le numéro d'agent correspondant à l'utilisateur, la date de modification et le type de modification.
            INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(fid_troncon, geom, date_action, fid_type_action, fid_pnom, fid_metadonnee)
            VALUES(
                    :old.objectid,
                    :old.geom,
                    sysdate,
                    v_id_modification,
                    v_id_agent,
                    :old.fid_metadonnee);
        END IF;
    END IF;
    IF DELETING THEN -- En cas de suppression on insère les valeurs de la table TA_TRONCON_LOG, le numéro d'agent correspondant à l'utilisateur, la date de suppression et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(fid_troncon, geom, date_action, fid_type_action, fid_pnom, fid_metadonnee)
        VALUES(
                :old.objectid,
                :old.geom,
                sysdate,
                v_id_suppression,
                v_id_agent,
                :old.fid_metadonnee);
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUD_TA_TRONCON_LOG','bjacq@lillemetropole.fr');
END;

/
/*
Déclencheur permettant de remplir la table de logs TA_TRONCON_LOG dans laquelle sont enregistrés chaque insertion, 
modification et suppression des données de la table TA_TRONCON avec leur date et le pnom de l'agent les ayant effectuées.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUD_TA_VOIE_LOG
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TA_VOIE
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_insertion NUMBER(38,0);
    v_id_modification NUMBER(38,0);
    v_id_suppression NUMBER(38,0);
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- Sélection des id des actions présentes dans la table TA_LIBELLE
    SELECT
        a.objectid INTO v_id_insertion
    FROM
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long
    WHERE
        b.valeur = 'insertion';

    SELECT
        a.objectid INTO v_id_modification
    FROM
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long
    WHERE
        b.valeur = 'édition';

    SELECT
        a.objectid INTO v_id_suppression
    FROM
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long
    WHERE
        b.valeur = 'suppression';

    IF INSERTING THEN -- En cas d'insertion on insère les valeurs de la table TA_VOIE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de insertion et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_VOIE_LOG(fid_voie, fid_typevoie, fid_rivoli, complement_nom_voie, libelle_voie, fid_genre_voie, date_action, fid_type_action, fid_pnom, fid_metadonnee)
            VALUES(
                    :new.objectid,
                    :new.fid_typevoie,
                    :new.fid_rivoli,
                    :new.complement_nom_voie,
                    :new.libelle_voie,
                    :new.fid_genre_voie,
                    sysdate,
                    v_id_insertion,
                    v_id_agent,
                    :new.fid_metadonnee);
    ELSE
        IF UPDATING THEN -- En cas de modification on insère les valeurs de la table TA_VOIE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de modification et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_VOIE_LOG(fid_voie, fid_typevoie, fid_rivoli, complement_nom_voie, libelle_voie, fid_genre_voie, date_action, fid_type_action, fid_pnom, fid_metadonnee)
            VALUES(
                    :old.objectid,
                    :old.fid_typevoie,
                    :old.fid_rivoli,
                    :old.complement_nom_voie,
                    :old.libelle_voie,
                    :old.fid_genre_voie,
                    sysdate,
                    v_id_modification,
                    v_id_agent,
                    :old.fid_metadonnee);
        END IF;
    END IF;
    IF DELETING THEN -- En cas de suppression on insère les valeurs de la table TA_VOIE_LOG, le numéro d'agent correspondant à l'utilisateur, la date de suppression et le type de modification.
    INSERT INTO G_BASE_VOIE.TA_VOIE_LOG(fid_voie, fid_typevoie, fid_rivoli, complement_nom_voie, libelle_voie, fid_genre_voie, date_action, fid_type_action, fid_pnom, fid_metadonnee)
        VALUES(
                :old.objectid,
                :old.fid_typevoie,
                :old.fid_rivoli,
                :old.complement_nom_voie,
                :old.libelle_voie,
                :old.fid_genre_voie,
                sysdate,
                v_id_suppression,
                v_id_agent,
                :old.fid_metadonnee);
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUD_TA_VOIE_LOG','bjacq@lillemetropole.fr');
END;

/
/*
Déclencheur permettant de remplir la table de logs TA_POINT_INTERET_LOG dans laquelle sont enregistrés chaque création, 
modification et suppression des données de la table TA_POINT_INTERET avec leur date et le pnom de l'agent les ayant effectuées.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUD_TA_POINT_INTERET_LOG
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TA_POINT_INTERET
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_insertion NUMBER(38,0);
    v_id_modification NUMBER(38,0);
    v_id_suppression NUMBER(38,0);
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- Sélection des id des actions présentes dans la table TA_LIBELLE
    SELECT 
        a.objectid INTO v_id_insertion 
    FROM 
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long 
    WHERE 
        b.valeur = 'insertion';

    SELECT 
        a.objectid INTO v_id_modification 
    FROM 
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long 
    WHERE 
        b.valeur = 'édition';
            
    SELECT 
        a.objectid INTO v_id_suppression 
    FROM 
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long 
    WHERE 
        b.valeur = 'suppression';

    IF INSERTING THEN -- En cas d'insertion on insère les valeurs de la table TA_POINT_INTERET_LOG, le numéro d'agent correspondant à l'utilisateur, la date de création et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_POINT_INTERET_LOG(fid_point_interet, geom, code_insee, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :new.objectid,
                    :new.geom,
                    GET_CODE_INSEE_CONTAIN_POINT('TA_SEUIL', :new.geom),
                    sysdate,
                    v_id_insertion,
                    v_id_agent);
    ELSE
        IF UPDATING THEN -- En cas de modification on insère les valeurs de la table TA_POINT_INTERET_LOG, le numéro d'agent correspondant à l'utilisateur, la date de modification et le type de modification.
            INSERT INTO G_BASE_VOIE.TA_POINT_INTERET_LOG(fid_point_interet, geom, code_insee, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :new.objectid,
                    :old.geom,
                    GET_CODE_INSEE_CONTAIN_POINT('TA_SEUIL', :old.geom),
                    sysdate,
                    v_id_modification,
                    v_id_agent);
        END IF;
    END IF;
    IF DELETING THEN -- En cas de suppression on insère les valeurs de la table TA_POINT_INTERET_LOG, le numéro d'agent correspondant à l'utilisateur, la date de suppression et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_POINT_INTERET_LOG(fid_point_interet, geom, code_insee, date_action, fid_type_action, fid_pnom)
        VALUES(
                    :new.objectid,
                    :old.geom,
                    GET_CODE_INSEE_CONTAIN_POINT('TA_SEUIL', :old.geom),
                    sysdate,
                    v_id_suppression,
                    v_id_agent);
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUD_TA_POINT_INTERET_LOG','bjacq@lillemetropole.fr');
END;

/
/*
Déclencheur permettant de remplir la table de logs TA_INFOS_POINT_INTERET_LOG dans laquelle sont enregistrés chaque création, 
modification et suppression des données de la table TA_INFOS_POINT_INTERET avec leur date et le pnom de l'agent les ayant effectuées.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUD_TA_INFOS_POINT_INTERET_LOG
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TA_INFOS_POINT_INTERET
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_insertion NUMBER(38,0);
    v_id_modification NUMBER(38,0);
    v_id_suppression NUMBER(38,0);
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- Sélection des id des actions présentes dans la table TA_LIBELLE
    SELECT 
        a.objectid INTO v_id_insertion 
    FROM 
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long 
    WHERE 
        b.valeur = 'insertion';

    SELECT 
        a.objectid INTO v_id_modification 
    FROM 
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long 
    WHERE 
        b.valeur = 'édition';
            
    SELECT 
        a.objectid INTO v_id_suppression 
    FROM 
        G_GEO.TA_LIBELLE a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long 
    WHERE 
        b.valeur = 'suppression';

    IF INSERTING THEN -- En cas d'insertion on insère les valeurs de la table TA_INFOS_POINT_INTERET_LOG, le numéro d'agent correspondant à l'utilisateur, la date de création et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG(fid_infos_point_interet, complement_infos, nom, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :new.objectid,
                    :new.complement_infos,
                    :new.nom,
                    sysdate,
                    v_id_insertion,
                    v_id_agent);
    ELSE
        IF UPDATING THEN -- En cas de modification on insère les valeurs de la table TA_INFOS_POINT_INTERET_LOG, le numéro d'agent correspondant à l'utilisateur, la date de modification et le type de modification.
            INSERT INTO G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG(fid_infos_point_interet, complement_infos, nom, date_action, fid_type_action, fid_pnom)
            VALUES(
                    :new.objectid,
                    :old.complement_infos,
                    :old.nom,
                    sysdate,
                    v_id_modification,
                    v_id_agent);
        END IF;
    END IF;
    IF DELETING THEN -- En cas de suppression on insère les valeurs de la table TA_INFOS_POINT_INTERET_LOG, le numéro d'agent correspondant à l'utilisateur, la date de suppression et le type de modification.
        INSERT INTO G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG(fid_infos_point_interet, complement_infos, nom, date_action, fid_type_action, fid_pnom)
        VALUES(
                    :new.objectid,
                    :old.complement_infos,
                    :old.nom,
                    sysdate,
                    v_id_suppression,
                    v_id_agent);
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUD_TA_INFOS_POINT_INTERET_LOG','bjacq@lillemetropole.fr');
END;

/
/*
Déclencheur permettant de récupérer dans la table TA_INFOS_SEUIL, les dates de création/modification des entités ainsi que le pnom de l'agent les ayant effectués.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUX_TA_INFOS_SEUIL_DATE_PNOM
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TA_INFOS_SEUIL
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    IF INSERTING THEN -- En cas d'insertion on insère la FK du pnom de l'agent, ayant créé les infos du seuil, présent dans TA_AGENT.
       :new.fid_pnom_saisie := v_id_agent;
       :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
       :new.fid_pnom_modification := v_id_agent;
       :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
    ELSE
        IF UPDATING THEN -- En cas de mise à jour on édite le champ date_modification avec la date du jour et le champ fid_pnom_modification avec la FK du pnom de l'agent, ayant modifié les informations du seuil, présent dans TA_AGENT.
            :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
            :new.fid_pnom_modification := v_id_agent;
        END IF;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - B_IUX_TA_INFOS_SEUIL_DATE_PNOM','bjacq@lillemetropole.fr');
END;

/
/*
Déclencheur permettant de récupérer dans la table TA_SEUIL, les dates de création/modification des entités ainsi que le pnom de l'agent les ayant effectués.
*/

create or replace TRIGGER G_BASE_VOIE.B_IUX_TEST_MIGRATION_SEUIL_DATE_PNOM
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TEST_MIGRATION_SEUIL
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    v_id_troncon NUMBER(38,0);
    
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TEST_MIGRATION_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TEST_MIGRATION_AGENT WHERE pnom = username;

    -- Sélection du tronçon le plus proche
    WITH
        C_1 AS(-- Sélection des tronçons et de la distance seuil/tronçon dans un rayon de 50 mètres autours du seuil
            SELECT
                b.objectid AS id_troncon,
                SDO_NN_DISTANCE(1) AS distance
            FROM
                G_BASE_VOIE.TEST_MIGRATION_TRONCON b
            WHERE
                SDO_NN(b.geom, :new.geom, 'sdo_batch_size=10 distance=500 unit=meter', 1) = 'TRUE'
    
        ),
        
        C_2 AS(-- Sélection de la distance seuil/tronçon minimum
            SELECT
                MIN(distance) AS distance
            FROM
                C_1
        )
        
        SELECT -- Récupération du tronçon situé à la distance minimum du seuil
            a.id_troncon INTO v_id_troncon
        FROM
            C_1 a
            INNER JOIN C_2 b ON b.distance = a.distance;
    
    IF INSERTING THEN -- En cas d'insertion on insère la FK du pnom de l'agent, ayant créé le seuil, présent dans TEST_MIGRATION_AGENT.
       :new.fid_pnom_saisie := v_id_agent;
       :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
       :new.fid_pnom_modification := v_id_agent;
       :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
       :new.fid_troncon := v_id_troncon;
    ELSE
        IF UPDATING THEN -- En cas de mise à jour on édite le champ date_modification avec la date du jour et le champ fid_pnom_modification avec la FK du pnom de l'agent, ayant modifié le seuil, présent dans TEST_MIGRATION_AGENT.
            :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
            :new.fid_pnom_modification := v_id_agent;
        END IF;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUX_TEST_MIGRATION_SEUIL_DATE_PNOM','bjacq@lillemetropole.fr');
END;

/

/*
Déclencheur permettant de récupérer dans la table TA_TRONCON, les dates de création/modification des entités ainsi que le pnom de l'agent les ayant effectués.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUX_TA_TRONCON_DATE_PNOM
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TA_TRONCON
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    fid_mtd NUMBER(38,0);

BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- En cas d'insertion on insère la FK du pnom de l'agent, ayant créé le tronçon, présent dans TA_AGENT. 
    IF INSERTING THEN 
        :new.objectid := SEQ_TA_TRONCON_OBJECTID.NEXTVAL;
        :new.fid_pnom_saisie := v_id_agent;
        :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
        :new.fid_pnom_modification := v_id_agent;
        :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
    ELSE
        -- En cas de mise à jour on édite le champ date_modification avec la date du jour et le champ fid_pnom_modification avec la FK du pnom de l'agent, ayant modifié le tronçon, présent dans TA_AGENT.
        IF UPDATING THEN 
             :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
             :new.fid_pnom_modification := v_id_agent;
        END IF;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - G_BASE_VOIE.B_IUX_TA_TRONCON_DATE_PNOM','bjacq@lillemetropole.fr');
END;

/
/*
Déclencheur permettant de récupérer dans la table TA_VOIE, les dates de création/modification des entités ainsi que le pnom de l'agent les ayant effectués.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUX_TA_VOIE_DATE_PNOM
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TA_VOIE
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
    fid_mtd NUMBER(38,0);
    
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    -- En cas d'insertion on insère la FK du pnom de l'agent, ayant créé la voie, présent dans TA_AGENT.
    IF INSERTING THEN
       :new.fid_pnom_saisie := v_id_agent;
       :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
       :new.fid_pnom_modification := v_id_agent;
       :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
    ELSE
        IF UPDATING THEN -- En cas de mise à jour on édite le champ date_modification avec la date du jour et le champ fid_pnom_modification avec la FK du pnom de l'agent, ayant modifié la voie, présent dans TA_AGENT.
            :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
            :new.fid_pnom_modification := v_id_agent;
        END IF;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - B_IUX_TA_VOIE_DATE_PNOM','bjacq@lillemetropole.fr');
END;

/
/*
Déclencheur permettant de récupérer dans la table TA_POINT_INTERET le pnom de l'agent ayant effectué la création et l'édition des objets.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUX_TA_POINT_INTERET_DATE_PNOM
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TA_POINT_INTERET
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
             
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    IF INSERTING THEN -- En cas d'insertion on insère la FK du pnom de l'agent, ayant créé le POI, présent dans TA_AGENT.
       :new.fid_pnom_saisie := v_id_agent;
       :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
       :new.fid_pnom_modification := v_id_agent;
       :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
    ELSE
        IF UPDATING THEN -- En cas de mise à jour on édite le champ fid_pnom_modification avec la FK du pnom de l'agent, ayant modifié le POI, présent dans TA_AGENT.
            :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
            :new.fid_pnom_modification := v_id_agent;
        END IF;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - B_IUX_TA_POINT_INTERET_DATE_PNOM','bjacq@lillemetropole.fr');
END;

/
/*
Déclencheur permettant de récupérer dans la table TA_INFOS_POINT_INTERET, les dates de création/modification des géométries des POI ainsi que le pnom de l'agent les ayant effectués.
*/

CREATE OR REPLACE TRIGGER G_BASE_VOIE.B_IUX_TA_INFOS_POINT_INTERET_DATE_PNOM
BEFORE INSERT OR UPDATE ON G_BASE_VOIE.TA_INFOS_POINT_INTERET
FOR EACH ROW
DECLARE
    username VARCHAR2(100);
    v_id_agent NUMBER(38,0);
             
BEGIN
    -- Sélection du pnom
    SELECT sys_context('USERENV','OS_USER') into username from dual;

    -- Sélection de l'id du pnom correspondant dans la table TA_AGENT
    SELECT numero_agent INTO v_id_agent FROM G_BASE_VOIE.TA_AGENT WHERE pnom = username;

    IF INSERTING THEN -- En cas d'insertion on insère la FK du pnom de l'agent, ayant créé la géométrie du POI, présent dans TA_AGENT.
       :new.fid_pnom_saisie := v_id_agent;
       :new.date_saisie := TO_DATE(sysdate, 'dd/mm/yy');
       :new.fid_pnom_modification := v_id_agent;
       :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
    ELSE
        IF UPDATING THEN -- En cas de mise à jour on édite le champ date_modification avec la date du jour et le champ fid_pnom_modification avec la FK du pnom de l'agent, ayant modifié la géométrie du POI, présent dans TA_AGENT.
            :new.date_modification := TO_DATE(sysdate, 'dd/mm/yy');
            :new.fid_pnom_modification := v_id_agent;
        END IF;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            mail.sendmail('bjacq@lillemetropole.fr',SQLERRM,'ERREUR TRIGGER - B_IUX_TA_INFOS_POINT_INTERET_DATE_PNOM','bjacq@lillemetropole.fr');
END;

/
/*
Création d'une vue matérialisée matérialisant la géométrie des voies.
*/
-- 1. Suppression de la VM et de ses métadonnées
/*DROP MATERIALIZED VIEW G_BASE_VOIE.VM_VOIE_AGGREGEE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_VOIE_AGGREGEE';
COMMIT;
*/
-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_VOIE_AGGREGEE" ("ID_VOIE","TYPE_DE_VOIE","LIBELLE_VOIE","COMPLEMENT_NOM_VOIE", "GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
    a.objectid AS id_voie,
    UPPER(TRIM(c.libelle)) AS type_de_voie,
    UPPER(TRIM(a.libelle_voie)) AS libelle_voie,
    UPPER(TRIM(a.complement_nom_voie)) AS complement_nom_voie,
    SDO_AGGR_UNION(
        SDOAGGRTYPE(b.geom, 0.005)
    ) AS geom
FROM
    G_BASE_VOIE.TA_VOIE a
    INNER JOIN G_BASE_VOIE.TA_TRONCON b ON b.fid_voie = a.objectid
    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE c ON c.objectid = a.fid_typevoie
GROUP BY
    a.objectid,
    UPPER(TRIM(c.libelle)),
    UPPER(TRIM(a.libelle_voie)),
    UPPER(TRIM(a.complement_nom_voie));

-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_VOIE_AGGREGEE IS 'Vue matérialisée matérialisant la géométrie des voies.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_VOIE_AGGREGEE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_VOIE_AGGREGEE 
ADD CONSTRAINT VM_VOIE_AGGREGEE_PK 
PRIMARY KEY (ID_VOIE);

-- 6. Création des index
CREATE INDEX VM_VOIE_AGGREGEE_SIDX
ON G_BASE_VOIE.VM_VOIE_AGGREGEE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_VOIE_AGGREGEE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_VOIE_AGGREGEE(LIBELLE_VOIE)
    TABLESPACE G_ADT_INDX;

-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_VOIE_AGGREGEE TO G_ADMIN_SIG;

/

/*
Création de la vue matérialisée G_BASE_VOIE.VM_GRU_ADRESSE proposant les adresses de la MEL pour la Gestion des Relations des Usagers.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_GRU_ADRESSE;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_GRU_ADRESSE';
COMMIT;
*/
-- 1. Création de la vue matérialisée
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_GRU_ADRESSE(
    id_seuil,
    numero,
    nom_voie,
    code_insee,
    geom
)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
    SELECT -- Sélection des seuils affectés aux voies secondaires pour lesquelles on conserve les noms des voies principales
        b.objectid AS id_seuil,
        TRIM(b.numero_seuil || ' ' || COALESCE(b.complement_numero_seuil, '')) AS numero,
        UPPER(f.libelle) || ' ' || UPPER(e.libelle_voie) || ' ' || UPPER(e.complement_nom_voie) AS nom_voie,
        CAST(TRIM(GET_CODE_INSEE_LLH_CONTAIN_POINT('TA_SEUIL', a.geom)) AS VARCHAR2(8 BYTE)) AS code_insee,
        b.geom
    FROM
        G_BASE_VOIE.TA_SEUIL a
        INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL b ON b.fid_seuil = a.objectid
        INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.objectid = a.fid_troncon  
        INNER JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE d ON d.fid_voie_secondaire = c.fid_voie
        INNER JOIN G_BASE_VOIE.TA_VOIE e ON e.objectid = d.fid_voie_principale
        INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE f on f.objectid = e.fid_typevoie
    UNION ALL
    SELECT -- Sélection des seuils affectés aux voies principales dont on conserve les noms
        b.objectid AS id_seuil,
        TRIM(b.numero_seuil || ' ' || COALESCE(b.complement_numero_seuil, '')) AS numero,
        UPPER(f.libelle) || ' ' || UPPER(e.libelle_voie) || ' ' || UPPER(e.complement_nom_voie) AS nom_voie,
        CAST(TRIM(GET_CODE_INSEE_LLH_CONTAIN_POINT('TA_SEUIL', a.geom)) AS VARCHAR2(8 BYTE)) AS code_insee,
        b.geom
    FROM
        G_BASE_VOIE.TA_SEUIL a
        INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL b ON b.fid_seuil = a.objectid
        INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.objectid = a.fid_troncon  
        INNER JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE d ON d.fid_voie_secondaire = c.fid_voie
        INNER JOIN G_BASE_VOIE.TA_VOIE e ON e.objectid = d.fid_voie_principale
        INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE f on f.objectid = e.fid_typevoie
    WHERE
        e.objectid NOT IN(SELECT fid_voie_secondaire FROM G_BASE_VOIE.TA_HIERARCHISATION_VOIE);
    
-- 2. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_GRU_ADRESSE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_GRU_ADRESSE 
ADD CONSTRAINT VM_GRU_ADRESSE_PK 
PRIMARY KEY (ID_SEUIL);

-- 4. Création des index
-- index spatial
CREATE INDEX VM_GRU_ADRESSE_SIDX
ON G_BASE_VOIE.VM_GRU_ADRESSE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=POINT, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

-- autres index
CREATE INDEX VM_GRU_ADRESSE_COMMUNE_NOM_VOIE_NUMERO_IDX ON G_BASE_VOIE.VM_GRU_ADRESSE(CODE_INSEE, NOM_VOIE, NUMERO)
    TABLESPACE G_ADT_INDX;

-- 5. Création des commentaires de table et de colonnes
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_GRU_ADRESSE IS 'Vue matérialisée proposant les adresses de la MEL pour la Gestion des Relations des Usagers.';
COMMENT ON COLUMN G_BASE_VOIE.VM_GRU_ADRESSE.id_seuil IS 'Clé primaire de la VM correspondant aux identifiants de chaque seuil.';
COMMENT ON COLUMN G_BASE_VOIE.VM_GRU_ADRESSE.numero IS 'Numéro de chaque seuil avec son suffixe b, bis, ter, etc quand il existe.';
COMMENT ON COLUMN G_BASE_VOIE.VM_GRU_ADRESSE.nom_voie IS 'Nom de chaque voie : type de voie + nom de la voie + complément du nom.';
COMMENT ON COLUMN G_BASE_VOIE.VM_GRU_ADRESSE.code_insee IS 'Code INSEE de la commune d''appartenance du seuil (calculé à partir de MEL LLH (97 communes)).';
COMMENT ON COLUMN G_BASE_VOIE.VM_GRU_ADRESSE.geom IS 'géométries de type point de chaque seuil.';

-- 6. Création des droits de lecture pour les admins
GRANT SELECT ON G_BASE_VOIE.VM_GRU_ADRESSE TO G_ADMIN_SIG;

/

/*
Création de la VM VM_TRAVAIL_VOIE_AGGREGEE_CODE_INSEE permettant de récupérer la géométrie et le code INSEE de chaque voie.
*/

CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TRAVAIL_VOIE_AGGREGEE_CODE_INSEE" ("ID_VOIE","TYPE_DE_VOIE","LIBELLE_VOIE","COMPLEMENT_NOM_VOIE", "CODE_INSEE", "GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
    id_voie,
    type_de_voie,
    libelle_voie,
    complement_nom_voie,
    TRIM(GET_CODE_INSEE_97_COMMUNES_TRONCON('VM_VOIE_AGGREGEE', geom)) AS code_insee,
    geom
FROM
    G_BASE_VOIE.VM_VOIE_AGGREGEE;
    
-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TRAVAIL_VOIE_AGGREGEE_CODE_INSEE IS 'Vue matérialisée de travail permettant de récupérer le code insee et la géométrie des voies.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TRAVAIL_VOIE_AGGREGEE_CODE_INSEE',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 594000, 964000, 0.005),SDO_DIM_ELEMENT('Y', 6987000, 7165000, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TRAVAIL_VOIE_AGGREGEE_CODE_INSEE 
ADD CONSTRAINT VM_TRAVAIL_VOIE_AGGREGEE_CODE_INSEE_PK 
PRIMARY KEY (ID_VOIE);

-- 6. Création des index
CREATE INDEX VM_TRAVAIL_VOIE_AGGREGEE_CODE_INSEE_SIDX
ON G_BASE_VOIE.VM_TRAVAIL_VOIE_AGGREGEE_CODE_INSEE(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_TRAVAIL_VOIE_AGGREGEE_CODE_INSEE_IDX ON G_BASE_VOIE.VM_TRAVAIL_VOIE_AGGREGEE_CODE_INSEE(CODE_INSEE, TYPE_DE_VOIE, LIBELLE_VOIE, COMPLEMENT_NOM_VOIE)
    TABLESPACE G_ADT_INDX;

-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TRAVAIL_VOIE_AGGREGEE_CODE_INSEE TO G_ADMIN_SIG;

/

/*
Création d'une vue matérialisée regroupant toutes les voies avec leur nom, code INSEE et longueur
*/

-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR" ("ID_VOIE","TYPE_DE_VOIE","LIBELLE_VOIE","COMPLEMENT_NOM_VOIE","CODE_INSEE","LONGUEUR_VOIE", "GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
    b.id_voie,
    b.type_de_voie,
    b.libelle_voie,
    b.complement_nom_voie,
    b.code_insee,
    SDO_GEOM.SDO_LENGTH(b.geom) AS longueur_voie,
    b.geom
FROM
    G_BASE_VOIE.TA_VOIE a
    INNER JOIN G_BASE_VOIE.VM_TRAVAIL_VOIE_AGGREGEE_CODE_INSEE b ON b.id_voie = a.objectid;

-- 3. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR IS 'Vue matérialisée récupérant le code INSEE, la longueur, le type , le nom, la géométrie et le complément de chaque voie.';

-- 2. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR 
ADD CONSTRAINT VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR_PK 
PRIMARY KEY (ID_VOIE);

-- 4. Création des index
CREATE INDEX VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR_SIDX
ON G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR_CODE_INSEE_IDX ON G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR(CODE_INSEE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR_LONGUEUR_VOIE_IDX ON G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR(LONGUEUR_VOIE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR_LIBELLE_VOIE_IDX ON G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR(LIBELLE_VOIE)
    TABLESPACE G_ADT_INDX;

-- 5. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR TO G_ADMIN_SIG;

/

/*
VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR : Vue matérialisée regroupant toutes les voies dites principales de la base, c-a-d les voies ayant la plus grande longueur au sein d''un ensemble de voie ayant le même libellé et code insee.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR';
*/

-- 2. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR" ("OBJECTID", "ID_VOIE", "LIBELLE_VOIE", "CODE_INSEE", "LONGUEUR", "GEOM")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(-- Sélection des noms, code insee et longueur des voies principales
        SELECT
            TRIM(UPPER(libelle_voie)) AS libelle_voie_principale,
            code_insee AS code_insee_voie_principale,
            MAX(longueur_voie) AS longueur_voie_principale
        FROM
            G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR
        GROUP BY
            libelle_voie,
            code_insee
        HAVING
            COUNT(TRIM(UPPER(libelle_voie)))>1
            AND COUNT(code_insee)>1
    )
    
    SELECT
        rownum AS objectid,
        a.id_voie AS id_voie_principale,
        b.libelle_voie_principale,
        b.code_insee_voie_principale,
        b.longueur_voie_principale,
        a.geom
    FROM
        G_BASE_VOIE.VM_TRAVAIL_VOIE_CODE_INSEE_LONGUEUR a
        INNER JOIN C_1 b ON TRIM(UPPER(b.libelle_voie_principale)) = TRIM(UPPER(a.libelle_voie))
                        AND b.code_insee_voie_principale = a.code_insee
                        AND b.longueur_voie_principale = a.longueur_voie;

-- 3. Création des commentaires
COMMENT ON MATERIALIZED VIEW VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR IS 'Vue matérialisée regroupant toutes les voies dites principales de la base, c-a-d les voies ayant la plus grande longueur au sein d''un ensemble de voie ayant le même libellé et code insee.';

-- 4. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 5. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR 
ADD CONSTRAINT VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR_PK 
PRIMARY KEY (OBJECTID);

-- 6. Création des index
CREATE INDEX VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR_SIDX
ON G_BASE_VOIE.VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR(GEOM)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS('sdo_indx_dims=2, layer_gtype=MULTILINE, tablespace=G_ADT_INDX, work_tablespace=DATA_TEMP');

CREATE INDEX VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR_COMPOSE_IDX ON G_BASE_VOIE.VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR("CODE_INSEE", "LIBELLE_VOIE")
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR_LONGUEUR_IDX ON G_BASE_VOIE.VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR("LONGUEUR")
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR_ID_VOIE_IDX ON G_BASE_VOIE.VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR("ID_VOIE")
    TABLESPACE G_ADT_INDX;

-- 7. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR TO G_ADMIN_SIG;

/

