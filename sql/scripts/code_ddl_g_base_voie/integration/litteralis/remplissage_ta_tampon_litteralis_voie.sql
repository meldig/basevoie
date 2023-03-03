WITH
    C_1 AS(-- Sélection des tronçons composés de plusieurs sous-tronçons de domanialités différentes
        SELECT
            cnumtrc
        FROM
            SIREO_LEC.OUT_DOMANIALITE
        GROUP BY
            cnumtrc
        HAVING
            COUNT(DISTINCT domania) > 1
    ),
    
    C_2 AS(-- Mise en concordance des domanialités de la DEPV et des classements de LITTERALIS ayant plusieurs domanialités
        SELECT
            a.cnumtrc,
            CASE 
                WHEN a.domania = 'AUTOROUTE OU VOIE A CARACTERE AUTOROUTIER'
                THEN 'A'
                WHEN a.domania = 'ROUTE NATIONALE'
                THEN 'RN' -- Route Nationale
                WHEN a.domania IN ('VOIE PRIVEE ENTRETENUE PAR LA CUDL','VOIE PRIVEE FERMEE','VOIE PRIVEE OUVERTE','AUTRE VOIE PRIVEE','DECLASSEMENT EN COURS')
                THEN 'VP' -- Voie Privée
                WHEN a.domania = 'CHEMIN RURAL'
                THEN 'CR' -- Chemin Rural
                WHEN a.domania IN ('VOIE METROPOLITAINE','GESTION COMMUNAUTAIRE','AUTRE VOIE PUBLIQUE')
                THEN 'VC' -- Voie Communale
            END AS CLASSEMENT
        FROM
            SIREO_LEC.OUT_DOMANIALITE a
            INNER JOIN C_1 b ON b.cnumtrc = a.cnumtrc
    ),
    
    C_3 AS(-- Si un tronçon se compose de plusieurs sous-tronçons de domanialités différentes, alors on utilise le système de priorité de la DEPV pour déterminer une domanialité pour le tronçon
        SELECT
            a.cnumtrc,
            CASE
                WHEN a.classement IN('VC', 'VP')
                    THEN 'VC'
                WHEN a.classement IN('VC', 'CR')
                    THEN 'VC'
                WHEN a.classement IN('A', 'RN')
                    THEN 'A'
            END AS domania
        FROM
            C_2 a
        GROUP BY
            a.cnumtrc,
            CASE
                WHEN a.classement IN('VC', 'VP')
                    THEN 'VC'
                WHEN a.classement IN('VC', 'CR')
                    THEN 'VC'
                WHEN a.classement IN('A', 'RN')
                    THEN 'A'
            END
    ),
    
    C_4 AS(-- Sélection des tronçons disposant d'une et d'une seule domanialité
        SELECT
            cnumtrc
        FROM
            SIREO_LEC.OUT_DOMANIALITE
        GROUP BY
            cnumtrc
        HAVING
            COUNT(DISTINCT domania) = 1  
    ),
    
    C_5 AS(-- Mise en concordance des domanialités de la DEPV et des classements de LITTERALIS pour les tronçons ayant une et une seule domanialité
        SELECT
            a.cnumtrc,
            CASE 
                WHEN a.domania = 'AUTOROUTE OU VOIE A CARACTERE AUTOROUTIER'
                THEN 'A'
                WHEN a.domania = 'ROUTE NATIONALE'
                THEN 'RN' -- Route Nationale
                WHEN a.domania IN ('VOIE PRIVEE ENTRETENUE PAR LA CUDL','VOIE PRIVEE FERMEE','VOIE PRIVEE OUVERTE','AUTRE VOIE PRIVEE','DECLASSEMENT EN COURS')
                THEN 'VP' -- Voie Privée
                WHEN a.domania = 'CHEMIN RURAL'
                THEN 'CR' -- Chemin Rural
                WHEN a.domania IN ('VOIE METROPOLITAINE','GESTION COMMUNAUTAIRE','AUTRE VOIE PUBLIQUE')
                THEN 'VC' -- Voie Communale
            END AS domania
        FROM
            SIREO_LEC.OUT_DOMANIALITE a
            INNER JOIN C_4 b ON b.cnumtrc = a.cnumtrc
        UNION ALL
        SELECT
            cnumtrc,
            domania
        FROM
            C_3
    ),
    
    C_6 AS(-- Compilation des tronçons avec 1 domanialité et et ceux avec plusieurs domanialités mis au format LITTERALIS
        SELECT
            cnumtrc,
            domania
        FROM
            C_3
        UNION ALL
        SELECT
            cnumtrc,
            domania
        FROM
            C_5
    )

    C_7 AS(  
        SELECT DISTINCT
            a.objectid,
            CAST(a.objectid AS VARCHAR2(254)) AS CODE_TRONC,
            TRIM(CAST(b.domania AS VARCHAR2(254))) AS CLASSEMENT,
            CASE
                WHEN f.fid_lateralite = 2 THEN
                    CAST(h.objectid AS VARCHAR2(254))
                WHEN f.fid_lateralite = 3 THEN
                    CAST(h.objectid AS VARCHAR2(254))
            END AS CODE_RUE_G,
                CASE
                    WHEN f.fid_lateralite = 2 THEN
                        e.nom_voie
                    WHEN f.fid_lateralite = 3 THEN
                        e.nom_voie
                END AS NOM_RUE_G,
                CASE
                    WHEN f.fid_lateralite = 2 THEN
                        CAST(h.code_insee AS VARCHAR2(254))
                    WHEN f.fid_lateralite = 3 THEN
                        CAST(h.code_insee AS VARCHAR2(254))
                END AS CODE_INSEE_G,    
                CASE
                    WHEN d.fid_lateralite = 1 THEN
                        CAST(e.objectid AS VARCHAR2(254))
                    WHEN d.fid_lateralite = 3 THEN
                        CAST(e.objectid AS VARCHAR2(254))
                END AS CODE_RUE_D,
                CASE
                    WHEN d.fid_lateralite = 1 THEN
                        e.nom_voie
                    WHEN d.fid_lateralite = 3 THEN
                        e.nom_voie
                END AS NOM_RUE_D,
                CASE
                    WHEN d.fid_lateralite = 1 THEN
                        CAST(e.code_insee AS VARCHAR2(254))
                    WHEN d.fid_lateralite = 3 THEN
                        CAST(e.code_insee AS VARCHAR2(254))
                END AS CODE_INSEE_D
        FROM
            G_BASE_VOIE.TEMP_H_TRONCON a
            LEFT JOIN C_6 b ON b.cnumtrc = a.old_objectid -- relation nécessaire pour prendre en compte les nouveaux tronçons résultant de nos corrections topologiques
            INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE c ON c.objectid = a.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = c.objectid
            INNER JOIN G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE e ON e.objectid = d.fid_voie_administrative
            INNER JOIN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE f ON f.fid_voie_physique = c.objectid
            INNER JOIN G_BASE_VOIE.TA_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE g ON g.objectid = d.fid_voie_administrative
        WHERE
            d.fid_lateralite IN(1,3)
            AND f.fid_lateralite IN(2,3)
    )
    
    SELECT
        a.objectid,
        a.code_tronc,
        CASE -- Si un tronçon n'a pas de domanialité on lui donne la domanialité Voie Communale ('VC') par défaut
            WHEN a.classement IS NULL
                THEN 'VC'
            ELSE a.classement
        END AS classement,
        a.code_rue_g,
        CASE -- Si la voie de gauche se trouve à Lomme ou Hellemmes-Lille alors on ajoute le nom de la commune associée en suffixe au nom de la voie 
            WHEN a.code_insee_g = '59355'
                THEN a.nom_rue_g || '(Lomme)'
            WHEN a.code_insee_g = '59298'
                THEN a.nom_rue_g || '(Hellemmes-Lille)'
            ELSE TRIM(a.nom_rue_g)
        END AS nom_rue_g,
        CASE -- Si la voie de gauche se trouve dans les communes associées Lomme ou Hellemmes-Lille alors on lui donne le code INSEE de Lille
            WHEN a.code_insee_g IN('59298', '59355')
                THEN '59350'
            ELSE a.code_insee_g
        END AS code_insee_g,
        a.code_rue_d,
        CASE -- Si la voie de droite se trouve à Lomme ou Hellemmes-Lille alors on ajoute le nom de la commune associée en suffixe au nom de la voie
            WHEN a.code_insee_d = '59355'
                THEN a.nom_rue_d || '(Lomme)'
            WHEN a.code_insee_d = '59298'
                THEN a.nom_rue_d || '(Hellemmes-Lille)'
            ELSE TRIM(a.nom_rue_d)
        END AS nom_rue_d,
        CASE -- Si la voie de droite se trouve dans les communes associées Lomme ou Hellemmes-Lille alors on lui donne le code INSEE de Lille
            WHEN a.code_insee_d IN('59298', '59355')
                THEN '59350'
            ELSE a.code_insee_d
        END AS code_insee_d,
        b.geom AS geometry
    FROM
        C_6 a
        INNER JOIN G_BASE_VOIE.TEMP_H_TRONCON b ON b.objectid = a.objectid;