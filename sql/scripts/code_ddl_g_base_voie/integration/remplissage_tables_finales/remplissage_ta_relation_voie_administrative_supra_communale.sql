/*
Remplissage de la table G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE permettant de faire la relation
entre les voies supra-communales et les voies administratives.
*/
MERGE INTO G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE a 
    USING(
            SELECT DISTINCT -- Sélection des relations voies administratives/supra-communales                    
                f.objectid AS id_voie_supra_communale,
                e.objectid AS id_voie_administrative
            FROM
                SIREO_LEC.OUT_DOMANIALITE a 
                INNER JOIN G_BASE_VOIE.TA_TRONCON b ON b.old_objectid = a.cnumtrc
                INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE c ON c.objectid = b.fid_voie_physique
                INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = c.objectid
                INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE e ON e.objectid = d.fid_voie_administrative
                INNER JOIN G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE f ON f.id_sireo = a.idvoie          
    )t 
ON(a.fid_voie_supra_communale = t.id_voie_supra_communale AND a.fid_voie_administrative = t.id_voie_administrative)
WHEN NOT MATCHED THEN
    INSERT(a.fid_voie_supra_communale, a.fid_voie_administrative)
    VALUES(t.id_voie_supra_communale, t.id_voie_administrative);
COMMIT;

/

-- Résultat : 1947 lignes fusionnées