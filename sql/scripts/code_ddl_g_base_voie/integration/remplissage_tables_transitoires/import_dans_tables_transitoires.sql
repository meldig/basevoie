/*
Migration des données des tables d'import vers les tables transitoires
*/

SET SERVEROUTPUT ON
DECLARE
BEGIN
	SAVEPOINT POINT_STRUCTURE_TRANSITOIRE;
	
	-- 1. Désactivation des triggers
	EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TEMP_TRONCON_DATE_PNOM DISABLE';
	EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TEMP_VOIE_DATE_PNOM DISABLE';

	-- 2. Les types de voies
	MERGE INTO G_BASE_VOIE.TEMP_TYPE_VOIE a
		USING(
			SELECT
	            CCODTVO AS code_type_voie,
	            LITYVOIE AS libelle
	        FROM
	            G_BASE_VOIE.TEMP_TYPEVOIE
	        WHERE
	            LITYVOIE IS NOT NULL
		)t
	ON(a.code_type_voie = t.code_type_voie AND a.libelle = t.libelle)
	WHEN NOT MATCHED THEN
	INSERT(a.code_type_voie, a.libelle)
	VALUES(t.code_type_voie, t.libelle);

	-- 3. Les voies
	MERGE INTO G_BASE_VOIE.TEMP_VOIE a
		USING(
			SELECT
	            b.objectid AS FID_TYPEVOIE,
	            a.CCOMVOI AS OBJECTID,
	            a.CINFOS AS COMPLEMENT_NOM_VOIE,
	            a.CNOMINUS AS LIBELLE_VOIE,
	            a.cnumcom,
	            a.ccodrvo,
	            a.cdvalvoi,
	            a.genre AS genre,
	            a.CDTSVOI AS DATE_SAISIE,
	            a.CDTMVOI AS DATE_MODIFICATION,
	            c.numero_agent AS FID_PNOM_SAISIE,
	            c.numero_agent AS FID_PNOM_MODIFICATION
	        FROM
	            G_BASE_VOIE.TEMP_VOIEVOI a
	            INNER JOIN G_BASE_VOIE.TEMP_TYPE_VOIE b ON b.code_type_voie = a.ccodtvo,
	            G_BASE_VOIE.TEMP_AGENT c
	        WHERE
	        	c.pnom = 'import_donnees'
		)t
	ON(a.OBJECTID = t.OBJECTID)
	WHEN NOT MATCHED THEN
	INSERT(a.FID_TYPEVOIE, a.OBJECTID, a.COMPLEMENT_NOM_VOIE, a.LIBELLE_VOIE, a.cnumcom, a.ccodrvo, a.cdvalvoi, a.genre, a.DATE_SAISIE, a.DATE_MODIFICATION, a.FID_PNOM_SAISIE, a.FID_PNOM_MODIFICATION)
	VALUES(t.FID_TYPEVOIE, t.OBJECTID, t.COMPLEMENT_NOM_VOIE, t.LIBELLE_VOIE, t.cnumcom, t.ccodrvo, t.cdvalvoi, t.genre, t.DATE_SAISIE, t.DATE_MODIFICATION, t.FID_PNOM_SAISIE, t.FID_PNOM_MODIFICATION);

	-- 4. Les tronçons
	MERGE INTO G_BASE_VOIE.TEMP_TRONCON a
		USING(
			SELECT
	            a.cnumtrc AS objectid,
	            a.ora_geometry AS geom,
	            a.cdvaltro,
	            a.cdtstrc AS date_saisie,
	            a.cdtmtrc AS date_modification,
	            b.numero_agent AS fid_pnom_saisie,
	            b.numero_agent AS fid_pnom_modification
	        FROM
	            G_BASE_VOIE.TEMP_ILTATRC a,
	            G_BASE_VOIE.TEMP_AGENT b
	        WHERE
	        	b.pnom = 'import_donnees'
		)t
	ON(a.objectid = t.objectid)
	WHEN NOT MATCHED THEN
	INSERT(a.objectid, a.geom, a.cdvaltro, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification)
	VALUES(t.objectid, t.geom, t.cdvaltro, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification);

	-- 5. Les relations tronçons/voies
	MERGE INTO G_BASE_VOIE.TEMP_RELATION_TRONCON_VOIE a
		USING(
			SELECT
	            a.cnumtrc,
	            a.ccomvoi,
	            a.ccodstr,
	            a.cvalide,
	            a.cdtscvt,
	            a.cdtmcvt,
	            b.numero_agent AS fid_pnom_saisie,
	            b.numero_agent AS fid_pnom_modification
	        FROM
	            G_BASE_VOIE.TEMP_VOIECVT a,       
	            G_BASE_VOIE.TEMP_AGENT b
	        WHERE
	            b.pnom = 'import_donnees'
		)t
	ON(a.fid_troncon = t.cnumtrc AND a.fid_voie = t.ccomvoi)
	WHEN NOT MATCHED THEN
	INSERT(a.sens, a.cvalide, a.fid_voie, a.fid_troncon, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification)
	VALUES(t.ccodstr, t.cvalide, t.ccomvoi, t.cnumtrc, t.cdtscvt, t.cdtmcvt, t.fid_pnom_saisie, t.fid_pnom_modification);

	-- 1. Réactivation des triggers
	EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TEMP_TRONCON_DATE_PNOM ENABLE';
	EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TEMP_VOIE_DATE_PNOM ENABLE';

    -- En cas d'erreur une exception est levée et un rollback effectué, empêchant ainsi toute insertion de se faire et de retourner à l'état des tables précédent l'insertion.
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('L''erreur ' || SQLCODE || 'est survenue. Un rollback a été effectué : ' || SQLERRM(SQLCODE));
            ROLLBACK TO POINT_STRUCTURE_TRANSITOIRE;
END;