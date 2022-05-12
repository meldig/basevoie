-- Insertion des types de voie
MERGE INTO G_BASE_VOIE.TEMP_A_TYPE_VOIE a
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

-- Insertion des voies en doublon de géométrie (en limite de commune)
MERGE INTO G_BASE_VOIE.TEMP_A_VOIE a
	USING(
		WITH
			C_1 AS(
				SELECT
				    a.id_voie AS id_voie_min,
				    b.id_voie AS id_voie_max
				FROM
				    VM_TEMP_IMPORT_VOIE_AGREGEE a,
				    VM_TEMP_IMPORT_VOIE_AGREGEE b
				WHERE
				    a.objectid < b.objectid
				    AND SDO_EQUAL(a.geom, b.geom) = 'TRUE'
			)

		SELECT
           id_voie_min AS objectid
        FROM
            C_1
	)t
	ON(a.OBJECTID = t.OBJECTID)
WHEN NOT MATCHED THEN
	INSERT(a.objectid)
	VALUES(t.objectid);

-- Insertion des libellés de voies
MERGE INTO G_BASE_VOIE.TEMP_A_LIBELLE_VOIE a
	USING(
		WITH
			C_1 AS(-- Sélection des voies ayant des identifiant différents, mais des géométries identiques
				SELECT
		            a.id_voie AS id_voie_min,
		            c.cnominus AS libele_voie_min,
		            b.id_voie AS id_voie_max,
		            f.cnominus AS libele_voie_max
		        FROM
		            VM_TEMP_IMPORT_VOIE_AGREGEE a
		            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = a.id_voie
		            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT d ON d.ccomvoi = c.ccomvoi
		            INNER JOIN G_BASE_VOIE.TEMP_ILTATRC e ON e.cnumtrc = d.cnumtrc,
		            VM_TEMP_IMPORT_VOIE_AGREGEE b
		            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI f ON f.ccomvoi = b.id_voie
		            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT g ON g.ccomvoi = f.ccomvoi
		            INNER JOIN G_BASE_VOIE.TEMP_ILTATRC h ON h.cnumtrc = g.cnumtrc
		        WHERE
		            a.objectid < b.objectid
		            AND c.cdvalvoi = 'V'
		            AND d.cvalide = 'V'
		            AND e.cdvaltro = 'V'
		            AND f.cdvalvoi = 'V'
		            AND g.cvalide = 'V'
		            AND h.cdvaltro = 'V'
		            AND SDO_EQUAL(a.geom, b.geom) = 'TRUE'
		     
			)

		SELECT
			a.ccomvoi AS objectid,
			a.cnominus AS libelle_voie,
			a.cinfos AS complement_nom_voie,
		FROM
			G_BASE_VOIE.TEMP_VOIEVOI a
			INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.ccomvoi = a.ccomvoi
		WHERE
			a.cdvalvoi = 'V'
			AND b.cvalide = 'V'
		)t
	ON(a.OBJECTID = t.OBJECTID)
WHEN NOT MATCHED THEN
	INSERT()
	VALUES();



-- Insertion des tronçons