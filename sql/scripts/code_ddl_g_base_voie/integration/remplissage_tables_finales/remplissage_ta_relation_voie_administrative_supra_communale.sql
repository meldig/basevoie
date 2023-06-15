/*
Remplissage de la table G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE permettant de faire la relation
entre les voies supra-communales et les voies administratives.
*/
MERGE INTO G_BASE_VOIE.TA_RELATION_VOIE_ADMINISTRATIVE_SUPRA_COMMUNALE a 
    USING(
        SELECT DISTINCT
            a.idsupvoi AS id_voie_supra_communale,
            f.objectid AS id_voie_administrative
        FROM
            SIREO_LEC.EXRD_IDSUPVOIE a 
            INNER JOIN SIREO_LEC.OUT_DOMANIALITE b ON b.idvoie = a.idsupvoi
            INNER JOIN G_BASE_VOIE.TA_TRONCON c ON c.old_objectid = b.cnumtrc
            INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE d ON d.objectid = c.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE e ON e.fid_voie_physique = d.objectid
            INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE f ON f.objectid = e.fid_voie_administrative
            
    )t 
ON(a.fid_voie_supra_communale = t.id_voie_supra_communale AND a.fid_voie_administrative = t.id_voie_administrative)
WHEN NOT MATCHED THEN
    INSERT(a.fid_voie_supra_communale, a.fid_voie_administrative)
    VALUES(t.id_voie_supra_communale, t.id_voie_administrative);
COMMIT;

/

