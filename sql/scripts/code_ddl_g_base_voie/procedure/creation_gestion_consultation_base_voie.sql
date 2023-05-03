CREATE OR REPLACE PROCEDURE GESTION_CONSULTATION_BASE_VOIE
    IS
    BEGIN
	    /*
			Objectif : Mise à jour de la table TEMP_J_CONSULTATION_BASE_VOIE
	    */
	    SAVEPOINT POINT_SAUVERGARDE_GESTION_CONSULTATION_BASE_VOIE;

	    MERGE INTO G_BASE_VOIE.TEMP_J_CONSULTATION_BASE_VOIE a 
	    	USING(
	    		SELECT
				    a.objectid AS id_troncon,
				    b.objectid AS id_voie_physique,
				    d.libelle_court AS action_sens,
				    e.objectid AS id_voie_administrative,
				    e.code_insee,
				    f.libelle AS type_voie,
				    e.libelle_voie,
				    e.complement_nom_voie,
				    g.libelle_court AS lateralite,
				    e.commentaire,
				    a.geom
				FROM
				    G_BASE_VOIE.TEMP_J_TRONCON a
				    INNER JOIN G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
				    INNER JOIN G_BASE_VOIE.TEMP_J_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
				    INNER JOIN G_BASE_VOIE.TEMP_J_LIBELLE d ON d.objectid = b.fid_action
				    INNER JOIN G_BASE_VOIE.TEMP_J_VOIE_ADMINISTRATIVE e ON e.objectid = c.fid_voie_administrative
				    INNER JOIN G_BASE_VOIE.TEMP_J_TYPE_VOIE f ON f.objectid = e.fid_type_voie
				    INNER JOIN G_BASE_VOIE.TEMP_J_LIBELLE g ON g.objectid = c.fid_lateralite
	    	)t 
	    ON(a.id_troncon = t.id_troncon)
	    WHEN MATCHED THEN
	    	UPDATE SET a.id_voie_physique = t.id_voie_physique, a.action_sens = t.action_sens, a.id_voie_administrative = t.id_voie_administrative, a.code_insee = t.code_insee, a.type_voie = t.type_voie, a.libelle_voie = t.libelle_voie, a.complement_nom_voie = t.complement_nom_voie, a.lateralite = t.lateralite, a.commentaire = t.commentaire, a.geom = t.geom;

	    MERGE INTO G_BASE_VOIE.TEMP_J_CONSULTATION_BASE_VOIE a 
	    	USING(
	    		SELECT
				    a.objectid AS id_troncon,
				    b.objectid AS id_voie_physique,
				    d.libelle_court AS action_sens,
				    e.objectid AS id_voie_administrative,
				    e.code_insee,
				    f.libelle AS type_voie,
				    e.libelle_voie,
				    e.complement_nom_voie,
				    g.libelle_court AS lateralite,
				    e.commentaire,
				    a.geom
				FROM
				    G_BASE_VOIE.TEMP_J_TRONCON a
				    INNER JOIN G_BASE_VOIE.TEMP_J_VOIE_PHYSIQUE b ON b.objectid = a.fid_voie_physique
				    INNER JOIN G_BASE_VOIE.TEMP_J_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE c ON c.fid_voie_physique = b.objectid
				    INNER JOIN G_BASE_VOIE.TEMP_J_LIBELLE d ON d.objectid = b.fid_action
				    INNER JOIN G_BASE_VOIE.TEMP_J_VOIE_ADMINISTRATIVE e ON e.objectid = c.fid_voie_administrative
				    INNER JOIN G_BASE_VOIE.TEMP_J_TYPE_VOIE f ON f.objectid = e.fid_type_voie
				    INNER JOIN G_BASE_VOIE.TEMP_J_LIBELLE g ON g.objectid = c.fid_lateralite
	    	)t 
	    ON(a.id_troncon = t.id_troncon)
	    WHEN NOT MATCHED THEN
	    	INSERT(a.id_troncon,a.id_voie_physique,a.action_sens,a.id_voie_administrative,a.code_insee,a.type_voie,a.libelle_voie,a.complement_nom_voie,a.lateralite,a.commentaire,a.geom)
	    	VALUES(t.id_troncon,t.id_voie_physique,t.action_sens,t.id_voie_administrative,t.code_insee,t.type_voie,t.libelle_voie,t.complement_nom_voie,t.lateralite,t.commentaire,t.geom);

	EXCEPTION
	    WHEN OTHERS THEN
	    DBMS_OUTPUT.put_line('une erreur est survenue, un rollback va être effectué: ' || SQLCODE || ' : '  || SQLERRM(SQLCODE));
	    ROLLBACK TO POINT_SAUVERGARDE_GESTION_CONSULTATION_BASE_VOIE;
END GESTION_CONSULTATION_BASE_VOIE;

/

