/*
Création de la table TA_RIVOLI regroupant tous les codes RIVOLI des voies de la base voie.
*/

-- 1. Création de la table TA_RIVOLI
CREATE TABLE G_BASE_VOIE.TA_RIVOLI(
    objectid NUMBER(38,0) DEFAULT SEQ_TA_RIVOLI_OBJECTID.NEXTVAL,
    code_rivoli CHAR(4) NOT NULL,
    cle_controle CHAR(1)
);

-- 2. Création des commentaires sur la table et les champs
COMMENT ON TABLE G_BASE_VOIE.TA_RIVOLI IS 'Table rassemblant tous les codes fantoirs issus du fichier fantoir et correspondants aux voies présentes sur le territoire de la MEL.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RIVOLI.objectid IS 'Clé primaire auto-incrémentée de la table.';
COMMENT ON COLUMN G_BASE_VOIE.TA_RIVOLI.code_rivoli IS 'Code RIVOLI du code fantoir. Ce code est l''identifiant sur 4 caractères de la voie au sein de la commune. Attention : il ne faut pas confondre ce code avec le code de l''ancien fichier RIVOLI, devenu depuis fichier fantoir. Le code RIVOLI fait partie du code fantoir. Attention cet identifiant est recyclé dans le fichier fantoir, ce champ ne doit donc jamais être utilisé en tant que clé primaire ou étrangère.' ;
COMMENT ON COLUMN G_BASE_VOIE.TA_RIVOLI.cle_controle IS 'Clé de contrôle du code fantoir issue du fichier fantoir.';

-- 3. Création de la clé primaire
ALTER TABLE G_BASE_VOIE.TA_RIVOLI 
ADD CONSTRAINT TA_RIVOLI_PK 
PRIMARY KEY("OBJECTID") 
USING INDEX TABLESPACE "G_ADT_INDX";

-- 4. Création des index
CREATE INDEX TA_RIVOLI_CODE_RIVOLI_IDX ON G_BASE_VOIE.TA_RIVOLI(code_rivoli)
    TABLESPACE G_ADT_INDX;

CREATE INDEX TA_RIVOLI_CLE_CONTROLE_IDX ON G_BASE_VOIE.TA_RIVOLI(cle_controle)
    TABLESPACE G_ADT_INDX;

-- 5. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.TA_RIVOLI TO G_ADMIN_SIG;

/

