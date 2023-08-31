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