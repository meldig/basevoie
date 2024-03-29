-- Réinitialisation de la séquence d'incrémentation de la clé primaire de la table TEMP_B_TRONCON et réactivation des contraintes et index
SET SERVEROUTPUT ON
DECLARE
	id_max NUMBER(38,0);
BEGIN
	SELECT
		MAX(objectid)+1
		INTO id_max
	FROM
		G_BASE_VOIE.TEMP_B_TRONCON;

	EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TEMP_B_TRONCON_OBJECTID';
	EXECUTE IMMEDIATE 'CREATE SEQUENCE SEQ_TEMP_B_TRONCON_OBJECTID START WITH ' ||id_max|| ' INCREMENT BY 1';

	SELECT
		MAX(objectid)+1
		INTO id_max
	FROM
		G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE;

	EXECUTE IMMEDIATE 'ALTER TABLE TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE MODIFY OBJECTID NUMBER(38,0) GENERATED BY DEFAULT AS IDENTITY (START WITH ' ||id_max|| ' INCREMENT BY 1)';


	-- Réactivation des contraintes et des index des tables de correction des tronçons disposant d'erreurs de topologie.
	-- Réactivation des contraintes
	EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TEMP_B_TRONCON ENABLE CONSTRAINT TEMP_B_TRONCON_FID_PNOM_SAISIE_FK';
	EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TEMP_B_TRONCON ENABLE CONSTRAINT TEMP_B_TRONCON_FID_PNOM_MODIFICATION_FK';
	EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE ENABLE CONSTRAINT TEMP_B_VOIE_ADMINISTRATIVE_FID_VOIE_PHYSIQUE_FK';
	EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE ENABLE CONSTRAINT TEMP_B_VOIE_ADMINISTRATIVE_FID_TYPE_VOIE_FK';
	EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE ENABLE CONSTRAINT TEMP_B_VOIE_ADMINISTRATIVE_FID_PNOM_SAISIE_FK';
	EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE ENABLE CONSTRAINT TEMP_B_VOIE_ADMINISTRATIVE_FID_PNOM_MODIFICATION_FK';

	-- Re-création des index
	EXECUTE IMMEDIATE 'CREATE INDEX TEMP_B_VOIE_ADMINISTRATIVE_LIBELLE_VOIE_IDX ON G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE(libelle_voie) TABLESPACE G_ADT_INDX';
	EXECUTE IMMEDIATE 'CREATE INDEX TEMP_B_VOIE_ADMINISTRATIVE_COMPLEMENT_NOM_VOIE_IDX ON G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE(complement_nom_voie) TABLESPACE G_ADT_INDX';
	EXECUTE IMMEDIATE 'CREATE INDEX TEMP_B_VOIE_ADMINISTRATIVE_CODE_INSEE_IDX ON G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE(code_insee) TABLESPACE G_ADT_INDX';
	EXECUTE IMMEDIATE 'CREATE INDEX TEMP_B_VOIE_ADMINISTRATIVE_FID_LATERALITE_IDX ON G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE(fid_lateralite) TABLESPACE G_ADT_INDX';
	EXECUTE IMMEDIATE 'CREATE INDEX TEMP_B_VOIE_ADMINISTRATIVE_FID_PNOM_SAISIE_IDX ON G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE(fid_pnom_saisie) TABLESPACE G_ADT_INDX';
	EXECUTE IMMEDIATE 'CREATE INDEX TEMP_B_VOIE_ADMINISTRATIVE_FID_PNOM_MODIFICATION_IDX ON G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE(fid_pnom_modification) TABLESPACE G_ADT_INDX';
	EXECUTE IMMEDIATE 'CREATE INDEX TEMP_B_VOIE_ADMINISTRATIVE_FID_VOIE_PHYSIQUE_IDX ON G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE(fid_voie_physique) TABLESPACE G_ADT_INDX';
	EXECUTE IMMEDIATE 'CREATE INDEX TEMP_B_VOIE_ADMINISTRATIVE_FID_TYPE_VOIE_IDX ON G_BASE_VOIE.TEMP_B_VOIE_ADMINISTRATIVE(fid_type_voie) TABLESPACE G_ADT_INDX';

	-- Réactivation des triggers
	EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TEMP_B_TRONCON_DATE_PNOM ENABLE';

END;

