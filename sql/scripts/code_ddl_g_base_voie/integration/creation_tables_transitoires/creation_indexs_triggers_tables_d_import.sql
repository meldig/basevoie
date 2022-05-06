/*
Code permettant de créer des index sur les tables d'import et des triggers NO_DELETE empêchant toute action sur ces tables.
*/

-- 1. Création d'index sur les tables d'import
CREATE INDEX TEMP_ILTASEU_IDSEUI_IDX ON G_BASE_VOIE.TEMP_ILTASEU(idseui) TABLESPACE G_ADT_INDX;
CREATE INDEX TEMP_ILTASEU_NUSEUI_IDX ON G_BASE_VOIE.TEMP_ILTASEU(nuseui) TABLESPACE G_ADT_INDX;
CREATE INDEX TEMP_ILTASEU_NSSEUI_IDX ON G_BASE_VOIE.TEMP_ILTASEU(nsseui) TABLESPACE G_ADT_INDX;
CREATE INDEX TEMP_ILTASIT_IDSEUI_IDX ON G_BASE_VOIE.TEMP_ILTASIT(idseui) TABLESPACE G_ADT_INDX;
CREATE INDEX TEMP_ILTASIT_CNUMTRC_IDX ON G_BASE_VOIE.TEMP_ILTASIT(cnumtrc) TABLESPACE G_ADT_INDX;
CREATE INDEX TEMP_ILTATRC_CNUMTRC_IDX ON G_BASE_VOIE.TEMP_ILTATRC(cnumtrc) TABLESPACE G_ADT_INDX;  
CREATE INDEX TEMP_VOIECVT_CNUMTRC_IDX ON G_BASE_VOIE.TEMP_VOIECVT(cnumtrc) TABLESPACE G_ADT_INDX; 
CREATE INDEX TEMP_VOIECVT_CCOMVOI_IDX ON G_BASE_VOIE.TEMP_VOIECVT(ccomvoi) TABLESPACE G_ADT_INDX;
CREATE INDEX TEMP_VOIEVOI_CCOMVOI_IDX ON G_BASE_VOIE.TEMP_VOIEVOI(ccomvoi) TABLESPACE G_ADT_INDX;

/

-- 2. Création des triggers NO_DELETE
-- 2.1. TEMP_ILTASEU
CREATE OR REPLACE TRIGGER BIUD_TEMP_ILTASEU_NO_DELETE
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TEMP_ILTASEU
FOR EACH ROW
DECLARE
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Il est interdit d''insérer, modifier ou supprimer les objets de la table G_BASE_VOIE.TEMP_ILTASEU.');
END;

/

-- 2.2. TEMP_ILTATRC
CREATE OR REPLACE TRIGGER BIUD_TEMP_ILTATRC_NO_DELETE
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TEMP_ILTATRC
FOR EACH ROW
DECLARE
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Il est interdit d''insérer, modifier ou supprimer les objets de la table G_BASE_VOIE.TEMP_ILTATRC.');
END;

/

-- 2.3. TEMP_ILTASIT
CREATE OR REPLACE TRIGGER BIUD_TEMP_ILTASIT_NO_DELETE
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TEMP_ILTASIT
FOR EACH ROW
DECLARE
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Il est interdit d''insérer, modifier ou supprimer les objets de la table G_BASE_VOIE.TEMP_ILTASIT.');
END;

/

-- 2.4. TEMP_VOIECVT
CREATE OR REPLACE TRIGGER BIUD_TEMP_VOIECVT_NO_DELETE
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TEMP_VOIECVT
FOR EACH ROW
DECLARE
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Il est interdit d''insérer, modifier ou supprimer les objets de la table G_BASE_VOIE.TEMP_VOIECVT.');
END;

/

-- 2.4. TEMP_VOIEVOI
CREATE OR REPLACE TRIGGER BIUD_TEMP_VOIEVOI_NO_DELETE
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TEMP_VOIEVOI
FOR EACH ROW
DECLARE
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Il est interdit d''insérer, modifier ou supprimer les objets de la table G_BASE_VOIE.TEMP_VOIEVOI.');
END;

/

-- 2.4. TEMP_TYPEVOIE
CREATE OR REPLACE TRIGGER BIUD_TEMP_TYPEVOIE_NO_DELETE
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TEMP_TYPEVOIE
FOR EACH ROW
DECLARE
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Il est interdit d''insérer, modifier ou supprimer les objets de la table G_BASE_VOIE.TEMP_TYPEVOIE.');
END;

/

-- 2.4. TEMP_ILTAPTZ
CREATE OR REPLACE TRIGGER BIUD_TEMP_ILTAPTZ_NO_DELETE
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TEMP_ILTAPTZ
FOR EACH ROW
DECLARE
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Il est interdit d''insérer, modifier ou supprimer les objets de la table G_BASE_VOIE.TEMP_ILTAPTZ.');
END;

/

-- 2.4. TEMP_ILTADTN
CREATE OR REPLACE TRIGGER BIUD_TEMP_ILTADTN_NO_DELETE
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TEMP_ILTADTN
FOR EACH ROW
DECLARE
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Il est interdit d''insérer, modifier ou supprimer les objets de la table G_BASE_VOIE.TEMP_ILTADTN.');
END;

/

-- 2.4. TEMP_ILTAFILIA
CREATE OR REPLACE TRIGGER BIUD_TEMP_ILTAFILIA_NO_DELETE
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TEMP_ILTAFILIA
FOR EACH ROW
DECLARE
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Il est interdit d''insérer, modifier ou supprimer les objets de la table G_BASE_VOIE.TEMP_ILTAFILIA.');
END;

/

-- 2.4. TEMP_FUSION_SEUIL
CREATE OR REPLACE TRIGGER BIUD_TEMP_FUSION_SEUIL_NO_DELETE
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TEMP_FUSION_SEUIL
FOR EACH ROW
DECLARE
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Il est interdit d''insérer, modifier ou supprimer les objets de la table G_BASE_VOIE.TEMP_FUSION_SEUIL.');
END;

/

-- 2.4. TEMP_ILTALPU
CREATE OR REPLACE TRIGGER BIUD_TEMP_ILTALPU_NO_DELETE
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TEMP_ILTALPU
FOR EACH ROW
DECLARE
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Il est interdit d''insérer, modifier ou supprimer les objets de la table G_BASE_VOIE.TEMP_ILTALPU.');
END;

/

-- 2.4. TEMP_CODE_FANTOIR
CREATE OR REPLACE TRIGGER BIUD_TEMP_CODE_FANTOIR_NO_DELETE
BEFORE INSERT OR UPDATE OR DELETE ON G_BASE_VOIE.TEMP_CODE_FANTOIR
FOR EACH ROW
DECLARE
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Il est interdit d''insérer, modifier ou supprimer les objets de la table G_BASE_VOIE.TEMP_CODE_FANTOIR.');
END;

/

