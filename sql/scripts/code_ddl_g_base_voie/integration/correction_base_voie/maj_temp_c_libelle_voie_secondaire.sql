-- Mise à jour des libellés des voies secondaires par rapport à celui de leur voie principale
MERGE INTO G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE a
    USING(
        SELECT
            a.objectid AS id_voie_principale,
            b.fid_voie_secondaire,
            a.libelle_voie
        FROM
            G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE a
            INNER JOIN G_BASE_VOIE.TA_HIERARCHISATION_VOIE b ON b.fid_voie_principale = a.objectid
    )t
ON(a.objectid = t.fid_voie_secondaire)
WHEN MATCHED THEN
    UPDATE SET a.libelle_voie = t.libelle_voie;
COMMIT;  
        