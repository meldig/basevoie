-- Insertion des nouveaux tronçons résultant d'un découpage d'un ancien tronçon - opérateur spatial utilisé : SDO_COVERS
INSERT INTO G_BASE_VOIE.TEMP_D_TRONCON(NEW_ID_TRONCON, OLD_ID_TRONCON,GEOM,SENS,DATE_SAISIE,DATE_MODIFICATION,FID_VOIE,FID_PNOM_SAISIE,FID_PNOM_MODIFICATION)
    WITH
        C_1 AS(
            SELECT DISTINCT 
                a.objectid AS ancien_troncon,
                c.objectid AS nouveau_troncon,
                b.ccodstr AS sens
            FROM
                G_BASE_VOIE.TA_TRONCON a
                INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.objectid,
                G_BASE_VOIE.TEMP_C_TRONCON c
            WHERE
                b.cvalide = 'V'
                AND c.objectid > 91014
                AND SDO_COVERS(a.geom, c.geom) = 'TRUE'
        )
        
        SELECT
            a.nouveau_troncon,
            a.ancien_troncon,
            b.geom,
            a.sens,
            b.date_saisie,
            b.date_modification,
            c.fid_voie_physique,
            b.fid_pnom_saisie,
            b.fid_pnom_modification
        FROM
            C_1 a
            INNER JOIN G_BASE_VOIE.TEMP_C_TRONCON b ON b.objectid = a.nouveau_troncon
            INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE c ON c.fid_troncon = b.objectid
        WHERE
            a.nouveau_troncon NOT IN(91158,92415,92415,91186,91186,91595);
-- Résultat : 522 lignes insérées.

-- Insertion des nouveaux tronçons résultant d'un découpage d'un ancien tronçon - opérateur spatial utilisé : SDO_CONTAINS
MERGE INTO G_BASE_VOIE.TEMP_D_TRONCON a
    USING(
        SELECT 
            a.objectid AS nouveau_troncon,
            d.objectid AS ancien_troncon,
            a.geom,
            b.ccodstr AS sens,
            a.date_saisie,
            a.date_modification,
            c.fid_voie_physique,
            a.fid_pnom_saisie,
            a.fid_pnom_modification
        FROM
            G_BASE_VOIE.TEMP_C_TRONCON a
            INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE c ON c.fid_troncon = a.objectid,
            G_BASE_VOIE.TA_TRONCON d
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = d.objectid
        WHERE
            b.cvalide = 'V'
            AND a.objectid > 91014
            AND a.objectid <> 92376
            AND SDO_CONTAINS(d.geom, a.geom) = 'TRUE'
            AND a.objectid NOT IN(SELECT new_id_troncon FROM G_BASE_VOIE.TEMP_D_TRONCON)
    )t
ON(a.new_id_troncon = t.nouveau_troncon)
WHEN NOT MATCHED THEN
    INSERT(a.new_id_troncon, a.old_id_troncon, a.geom, a.sens, a.date_saisie, a.date_modification, a.fid_voie, a.fid_pnom_saisie, a.fid_pnom_modification)
    VALUES(t.nouveau_troncon, t.ancien_troncon, t.geom, t.sens, t.date_saisie, t.date_modification, t.fid_voie_physique, t.fid_pnom_saisie, t.fid_pnom_modification);
-- Résultat : 110 lignes fusionnées.

-- Insertion des nouveaux tronçons résultant d'un découpage d'un ancien tronçon - opérateur spatial utilisé : SDO_OVERLAPBDYINTERSECT
MERGE INTO G_BASE_VOIE.TEMP_D_TRONCON a
    USING(
        WITH
            C_1 AS(-- Sélection des nouveaux tronçons de TEMP_C_TRONCON
                SELECT
                    objectid
                FROM
                    TEMP_C_TRONCON
                WHERE
                    objectid >91014
            ),
            
            C_2 AS(
                SELECT -- Sélection des tronçons absents de TEMP_D_TRONCON
                    a.objectid,
                    b.new_id_troncon
                FROM
                    C_1 a
                    LEFT JOIN G_BASE_VOIE.TEMP_D_TRONCON b ON b.new_id_troncon = a.objectid
            )
            
            SELECT 
                a.objectid AS nouveau_troncon,
                d.objectid AS ancien_troncon,
                a.geom,
                b.ccodstr AS sens,
                a.date_saisie,
                a.date_modification,
                c.fid_voie_physique,
                a.fid_pnom_saisie,
                a.fid_pnom_modification
            FROM
                G_BASE_VOIE.TEMP_C_TRONCON a
                INNER JOIN C_2 e ON e.objectid = a.objectid
                INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE c ON c.fid_troncon = a.objectid,
                G_BASE_VOIE.TA_TRONCON d
                INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = d.objectid
            WHERE
                b.cvalide = 'V'
                AND a.objectid > 91014
                AND a.objectid <> 92376
                AND e.new_id_troncon IS NULL
                AND SDO_OVERLAPBDYINTERSECT(d.geom, a.geom) = 'TRUE'
    )t
ON(a.new_id_troncon = t.nouveau_troncon)
WHEN NOT MATCHED THEN
    INSERT(a.new_id_troncon, a.old_id_troncon, a.geom, a.sens, a.date_saisie, a.date_modification, a.fid_voie, a.fid_pnom_saisie, a.fid_pnom_modification)
    VALUES(t.nouveau_troncon, t.ancien_troncon, t.geom, t.sens, t.date_saisie, t.date_modification, t.fid_voie_physique, t.fid_pnom_saisie, t.fid_pnom_modification);
-- Résultat : 21 lignes fusionnées.;

MERGE INTO G_BASE_VOIE.TEMP_D_TRONCON a
    USING(
        WITH
            C_1 AS(-- Sélection des nouveaux tronçons de TEMP_C_TRONCON
                SELECT
                    objectid
                FROM
                    TEMP_C_TRONCON
                WHERE
                    objectid >91014
            ),
            
            C_2 AS(
                SELECT -- Sélection des tronçons absents de TEMP_D_TRONCON
                    a.objectid,
                    b.new_id_troncon
                FROM
                    C_1 a
                    LEFT JOIN G_BASE_VOIE.TEMP_D_TRONCON b ON b.new_id_troncon = a.objectid
            )
            
            SELECT
                a.objectid AS nouveau_id_troncon,
                c.objectid AS ancien_id_troncon,
                b.geom,
                b.date_saisie,
                b.date_modification,
                b.fid_pnom_saisie,
                b.fid_pnom_modification
            FROM
                C_2 a
                INNER JOIN G_BASE_VOIE.TEMP_C_TRONCON b ON b.objectid = a.objectid,
                G_BASE_VOIE.TA_TRONCON c,
                USER_SDO_GEOM_METADATA m
            WHERE
                a.new_id_troncon IS NULL
                AND m.table_name = 'TEMP_C_TRONCON'
                AND SDO_GEOM.WITHIN_DISTANCE(
                    SDO_CS.MAKE_2D(
                    SDO_LRS.LOCATE_PT(
                        SDO_LRS.CONVERT_TO_LRS_GEOM(b.geom, m.diminfo),
                        SDO_GEOM.SDO_LENGTH(b.geom, 0.005)/2
                    ),
                    2154
                ),
                1, 
                c.geom,
                0.005
            ) = 'TRUE'
    )t
ON(a.new_id_troncon = t.nouveau_id_troncon)
WHEN NOT MATCHED THEN
    INSERT(a.new_id_troncon, a.old_id_troncon, a.geom,a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification)
    VALUES(t.nouveau_id_troncon, t.ancien_id_troncon, t.geom, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification);
-- Résultat : 58 lignes fusionnées

MERGE INTO G_BASE_VOIE.TEMP_D_TRONCON a
    USING(
        SELECT DISTINCT
            b.ccodstr AS sens,
            c.fid_voie_physique,
            a.new_id_troncon
        FROM
            G_BASE_VOIE.TEMP_D_TRONCON a
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.old_id_troncon
            INNER JOIN G_BASE_VOIE.TEMP_C_RELATION_TRONCON_VOIE_PHYSIQUE c ON c.fid_troncon = a.new_id_troncon
        WHERE
            a.sens IS NULL
            AND a.new_id_troncon NOT IN(91186,92415,91158,91595)
    )t
ON(a.new_id_troncon = t.new_id_troncon)
WHEN MATCHED THEN
    UPDATE SET a.sens = t.sens, a.fid_voie = t.fid_voie_physique;
-- Résultat : 54 lignes fusionnées

COMMIT;

/

