/*
Objectif : remplissage de la table TA_VOIE_SUPRA_COMMUNALE afin d'avoir dans une table hébergée sur le schéma G_BASE_VOIE 
toutes les voies supra-communales, afin que leur gestion se fasse désormais du côté DDIG et non plus DEPV.
Le remplissage des objectid, dates de saisie/modification + pnom se font automatiquement par des triggers ou des séquences.
Nomenclature - vue avec la DEPV : si le nom de la voie est MD0005, il faut supprimer le "D" correspondant à départemental ainsi que les zéros pour passer à "M5".
*/

MERGE INTO G_BASE_VOIE.TA_VOIE_SUPRA_COMMUNALE a
    USING(
        SELECT DISTINCT -- Sélection des voies supra-communales absentes de la table EXRD_IDSUPVOIE
                a.idvoie AS id_sireo,
                CASE
                    WHEN SUBSTR(TRIM(a.idvoie),0, 2) = 'MD' AND INSTR(SUBSTR(TRIM(a.idvoie), 3), '000') = 1
                        THEN 'M' || SUBSTR(TRIM(a.idvoie), 6)
                    WHEN SUBSTR(TRIM(a.idvoie),0, 2) = 'MD' AND INSTR(SUBSTR(TRIM(a.idvoie), 3), '00') = 1
                        THEN 'M' || SUBSTR(TRIM(a.idvoie), 5)
                    WHEN SUBSTR(TRIM(a.idvoie),0, 2) = 'MD' AND INSTR(SUBSTR(TRIM(a.idvoie), 3), '0') = 1
                        THEN 'M' || SUBSTR(TRIM(a.idvoie), 4)
                    WHEN SUBSTR(TRIM(a.idvoie),0, 2) = 'MD'
                        THEN 'M' || SUBSTR(TRIM(a.idvoie), 3)
                    ELSE
                        TRIM(a.idvoie)
                END AS nom
            FROM
                SIREO_LEC.OUT_DOMANIALITE a 
                INNER JOIN G_BASE_VOIE.TA_TRONCON b ON b.old_objectid = a.cnumtrc
                INNER JOIN G_BASE_VOIE.TA_VOIE_PHYSIQUE c ON c.objectid = b.fid_voie_physique
                INNER JOIN G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = c.objectid
                INNER JOIN G_BASE_VOIE.TA_VOIE_ADMINISTRATIVE e ON e.objectid = d.fid_voie_administrative
            WHERE
                a.idvoie NOT IN(SELECT idsupvoi FROM SIREO_LEC.EXRD_IDSUPVOIE)
            GROUP BY
                a.idvoie
            HAVING
                COUNT(DISTINCT e.code_insee) > 1
            UNION ALL
            SELECT DISTINCT -- Sélection des relations voies administratives/supra-communales présentes dans la table EXRD_IDSUPVOIE
                a.idsupvoi AS id_sireo,
                CASE
                    WHEN SUBSTR(TRIM(a.idsupvoi),0, 2) = 'MD' AND INSTR(SUBSTR(TRIM(a.idsupvoi), 3), '000') = 1
                        THEN 'M' || SUBSTR(TRIM(a.idsupvoi), 6)
                    WHEN SUBSTR(TRIM(a.idsupvoi),0, 2) = 'MD' AND INSTR(SUBSTR(TRIM(a.idsupvoi), 3), '00') = 1
                        THEN 'M' || SUBSTR(TRIM(a.idsupvoi), 5)
                    WHEN SUBSTR(TRIM(a.idsupvoi),0, 2) = 'MD' AND INSTR(SUBSTR(TRIM(a.idsupvoi), 3), '0') = 1
                        THEN 'M' || SUBSTR(TRIM(a.idsupvoi), 4)
                    WHEN SUBSTR(TRIM(a.idsupvoi),0, 2) = 'MD'
                        THEN 'M' || SUBSTR(TRIM(a.idsupvoi), 3)
                    ELSE
                        TRIM(a.idsupvoi)
                END AS nom
            FROM
                SIREO_LEC.EXRD_IDSUPVOIE a
    )t
ON (a.nom = t.nom AND a.id_sireo = t.id_sireo)
WHEN NOT MATCHED THEN
INSERT(a.id_sireo, a.nom)
VALUES(t.id_sireo, t.nom);

/

-- Résultat : 697 lignes fusionnées.