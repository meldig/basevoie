
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