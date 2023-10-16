/*
Suppression de la sequence :
*/

DROP SEQUENCE SEQ_TA_SECTEUR_VOIRIE_OBJECTID;


/*
Insertion des secteurs de voirie
*/

INSERT INTO G_BASE_VOIE.TA_SECTEUR_VOIRIE(objectid, nom, geom)
SELECT
	objectid, 
	nom, 
	geom
FROM
	G_BASE_VOIE.TA_SECTEUR_VOIRIE@DBL_MULTIT_G_BASE_VOIE_MAJ;

COMMIT;


-- Réinitialisation de la séquence d'incrémentation de la clé primaire de la table TA_SECTEUR_VOIRIE
SET SERVEROUTPUT ON
DECLARE
	id_max NUMBER(38,0);
BEGIN
	SELECT
		MAX(objectid)+1
		INTO id_max
	FROM
		G_BASE_VOIE.TA_SECTEUR_VOIRIE;


    	EXECUTE IMMEDIATE 'CREATE SEQUENCE SEQ_TA_SECTEUR_VOIRIE_OBJECTID START WITH '||id_max||' INCREMENT BY 1';
		
END;