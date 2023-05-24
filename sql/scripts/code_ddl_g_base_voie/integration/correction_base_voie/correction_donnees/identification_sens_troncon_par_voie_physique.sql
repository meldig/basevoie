-- Identification des sens des tronçons par voie physique de type 2002, composant complètement deux voies administratives (autrement dit, ces deux voies administratives sont affectées à une et une seule voie physique)
WITH
    C_1 AS(-- Sélection des voies physiques associées à plus d'une seule voie administrative - afin d'identifier les voies en limite de commune
        SELECT
            c.objectid,
            COUNT(e.objectid) AS nbr_voie_admin
        FROM
            G_BASE_VOIE.TEMP_G_VOIE_PHYSIQUE c
            INNER JOIN G_BASE_VOIE.TEMP_G_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = c.objectid
            INNER JOIN G_BASE_VOIE.TEMP_G_VOIE_ADMINISTRATIVE e ON e.objectid = d.fid_voie_administrative
        GROUP BY
            c.objectid
        HAVING
            COUNT(e.objectid) > 1
    ),
    
    C_2 AS(-- Sélection des voies administratives en limite de commune (plusieurs voies admin par voie physique)
        SELECT
            a.objectid AS id_voie_physique,
            c.objectid AS id_voie_administrative
        FROM
            C_1 a
            INNER JOIN G_BASE_VOIE.TEMP_G_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE b ON b.fid_voie_physique = a.objectid
            INNER JOIN G_BASE_VOIE.TEMP_G_VOIE_ADMINISTRATIVE c ON c.objectid = b.fid_voie_administrative
    ),

    C_3 AS(-- Sélection des voies admin affectées à 1 et 1 seule voie physique
        SELECT
            id_voie_administrative,
            id_voie_physique,
            COUNT(id_voie_physique) AS nbr_voie_physique
        FROM
            C_2
        GROUP BY
            id_voie_administrative,
            id_voie_physique
        HAVING
            COUNT(id_voie_physique) = 1
    ),
    
    C_4 AS(-- Sélection du nombre de connexions entre tronçons par voie physique
        SELECT
            a.id_voie_administrative,
            c.id_voie_physique,
            COUNT(d.objectid) - 1 AS nb_connexions
        FROM
            C_3 a
            INNER JOIN G_BASE_VOIE.TEMP_G_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE b ON b.fid_voie_physique = a.id_voie_administrative
            INNER JOIN G_BASE_VOIE.VM_TEMP_G_VOIE_PHYSIQUE c ON c.id_voie_physique = b.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TEMP_G_TRONCON d ON d.fid_voie_physique = c.id_voie_physique
        WHERE
            c.geom.sdo_gtype = 2002
        GROUP BY
            a.id_voie_administrative,
            c.id_voie_physique
    )
    
    SELECT
        c.id_voie_administrative,
        a.fid_voie_physique,
        a.objectid AS id_trc_1,
        b.objectid AS id_trc_2,
        GET_STATUT_CONNEXION_TRONCON(a.geom, b.geom) AS statut_connexion
    FROM
        G_BASE_VOIE.TEMP_G_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_G_TRONCON b ON b.fid_voie_physique = a.fid_voie_physique
        INNER JOIN C_4 c ON c.id_voie_physique = a.fid_voie_physique,
        USER_SDO_GEOM_METADATA m
    WHERE 
        a.objectid < b.objectid
        AND table_name = 'TEMP_G_TRONCON'
        AND SDO_ANYINTERACT(a.geom, b.geom) = 'TRUE'
    ORDER BY
        c.id_voie_administrative,
        a.fid_voie_physique;