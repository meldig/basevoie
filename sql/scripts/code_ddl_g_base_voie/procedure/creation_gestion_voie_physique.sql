/*
Création de la procédure GESTION_VOIE_PHYSIQUE - du projet j de test de production - supprimant toute voie physique rattachée à aucun tronçon et aucune voie administrative
*/

CREATE OR REPLACE PROCEDURE GESTION_VOIE_PHYSIQUE
    IS
    BEGIN
        -- Objectif : Si une voie physique n'est rattachée ni à un tronçon, ni à une voie administrative, cette procédure la supprime. 
	    SAVEPOINT POINT_SAUVERGARDE_GESTION_VOIE_PHYSIQUE;

	    DELETE
	    FROM
	    	G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE
	    WHERE
	    	objectid NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TEMP_J_TRONCON)
	    	AND objectid NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TEMP_J_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE);


	EXCEPTION
	    WHEN OTHERS THEN
	    DBMS_OUTPUT.put_line('une erreur est survenue, un rollback va être effectué: ' || SQLCODE || ' : '  || SQLERRM(SQLCODE));
	    ROLLBACK TO POINT_SAUVERGARDE_GESTION_VOIE_PHYSIQUE;
END GESTION_VOIE_PHYSIQUE;

/

