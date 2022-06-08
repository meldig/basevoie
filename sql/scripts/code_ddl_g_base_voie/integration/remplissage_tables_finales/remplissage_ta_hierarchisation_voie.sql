
-- Import des relations voies principales / secondaires de la VM VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR dans la table TA_HIERARCHISATION_VOIE
MERGE INTO G_BASE_VOIE.TA_HIERARCHISATION_VOIE a
    USING(
        SELECT
            id_voie_principale,
            id_voie_secondaire
        FROM
            G_BASE_VOIE.VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR
    )t
    ON(a.fid_voie_principale = t.id_voie_principale AND a.fid_voie_secondaire = t.id_voie_secondaire)
WHEN NOT MATCHED THEN
    INSERT(a.fid_voie_principale, a.fid_voie_secondaire)
    VALUES(t.id_voie_principale, t.id_voie_secondaire);
COMMIT;

-- Lors du remplissage de la table TA_VOIE_LITTERALIS, je me suis aperçu que toutes les voies secondaires n'étaient pas dans TA_HIERARCHISATION_VOIE, le code ci-dessous permet de rectifier la situation :
/*INSERT INTO G_BASE_VOIE.TA_HIERARCHISATION_VOIE(fid_voie_principale, fid_voie_secondaire)
WITH
        C_1 AS(
            SELECT
                libelle_voie,
                GET_CODE_INSEE_97_COMMUNES_TRONCON('TA_VOIE_LITTERALIS', geom) AS insee
            FROM
                TA_VOIE_LITTERALIS
            GROUP BY
                libelle_voie, GET_CODE_INSEE_97_COMMUNES_TRONCON('TA_VOIE_LITTERALIS', geom)
            HAVING
                COUNT(libelle_voie) > 1
                AND COUNT(GET_CODE_INSEE_97_COMMUNES_TRONCON('TA_VOIE_LITTERALIS', geom)) > 1
        )
        
            SELECT DISTINCT
                c.id_voie AS id_voie_principale,
                --c.libelle_voie AS nom_voie_principale,
                --c.insee,
                --c.mesure_voie,
                a.ID_VOIE AS id_voie_secondaire
                --a.LIBELLE_VOIE,
                --a.INSEE,
                --a.MESURE_VOIE,
                --a.COMPLEMENT_NOM_VOIE,
                --a.DATE_SAISIE,
                --a.DATE_MODIFICATION,
                --a.FID_PNOM_SAISIE,
                --a.FID_PNOM_MODIFICATION,
                --a.FID_TYPEVOIE,
                --a.FID_GENRE_VOIE,
                --a.FID_RIVOLI,
                --a.FID_METADONNEE
            FROM
                TA_VOIE_LITTERALIS a
                INNER JOIN C_1 b ON UPPER(b.libelle_voie) = UPPER(a.libelle_voie) AND b.insee = GET_CODE_INSEE_97_COMMUNES_TRONCON('TA_VOIE_LITTERALIS', a.geom)
                INNER JOIN TA_VOIE_LITTERALIS c ON UPPER(c.libelle_voie) = UPPER(a.libelle_voie) AND c.insee = GET_CODE_INSEE_97_COMMUNES_TRONCON('TA_VOIE_LITTERALIS', a.geom)
                INNER JOIN TA_HIERARCHISATION_VOIE d ON d.fid_voie_principale = c.id_voie
        WHERE
            a.id_voie <> c.id_voie
            AND a.id_voie NOT IN(SELECT fid_voie_secondaire FROM TA_HIERARCHISATION_VOIE);
*/