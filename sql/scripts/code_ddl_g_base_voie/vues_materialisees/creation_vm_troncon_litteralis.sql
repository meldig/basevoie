/*
Création de la vue matérialisée VM_TRONCON_LITTERALIS regroupant tous les tronçons de la base voie au format LITTERALIS.
Cette VM est utilisée pour exporter les données pour le prestataire Sogelink.
*/
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TRONCON_LITTERALIS;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TRONCON_LITTERALIS';
*/

-- 1. Création de la vue matérialisée   
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_TRONCON_LITTERALIS" ("OBJECTID","CODE_TRONC","CLASSEMENT","CODE_RUE_G","NOM_RUE_G","CODE_INSEE_G","CODE_RUE_D","NOM_RUE_D","CODE_INSEE_D","GEOMETRY")        
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS 
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
    
    C_2 AS(-- Mise en concordance des domanialités de la DEPV et des classements de LITTERALIS
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
    
    C_4 AS(
        SELECT
            cnumtrc
        FROM
            SIREO_LEC.OUT_DOMANIALITE
        GROUP BY
            cnumtrc
        HAVING
            COUNT(DISTINCT domania) = 1  
    ),
    
    C_5 AS(
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
    
    C_6 AS(  
        SELECT DISTINCT
            a.objectid,
            CAST(a.objectid AS VARCHAR2(254)) AS CODE_TRONC,
            TRIM(CAST(b.domania AS VARCHAR2(254))) AS CLASSEMENT,
            CASE
                WHEN g.fid_lateralite = 2 THEN
                    CAST(h.objectid AS VARCHAR2(254))
                WHEN g.fid_lateralite = 3 THEN
                    CAST(h.objectid AS VARCHAR2(254))
            END AS CODE_RUE_G,
                CASE
                    WHEN g.fid_lateralite = 2 THEN
                        CAST(SUBSTR(UPPER(i.libelle), 1, 1) || SUBSTR(LOWER(i.libelle), 2) || ' ' || h.libelle_voie || ' ' || h.complement_nom_voie AS VARCHAR2(254))
                    WHEN g.fid_lateralite = 3 THEN
                        CAST(SUBSTR(UPPER(i.libelle), 1, 1) || SUBSTR(LOWER(i.libelle), 2) || ' ' || h.libelle_voie || ' ' || h.complement_nom_voie AS VARCHAR2(254))
                END AS NOM_RUE_G,
                CASE
                    WHEN g.fid_lateralite = 2 THEN
                        CAST(h.code_insee AS VARCHAR2(254))
                    WHEN g.fid_lateralite = 3 THEN
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
                        CAST(SUBSTR(UPPER(f.libelle), 1, 1) || SUBSTR(LOWER(f.libelle), 2) || ' ' || e.libelle_voie || ' ' || e.complement_nom_voie AS VARCHAR2(254))
                    WHEN d.fid_lateralite = 3 THEN
                        CAST(SUBSTR(UPPER(f.libelle), 1, 1) || SUBSTR(LOWER(f.libelle), 2) || ' ' || e.libelle_voie || ' ' || e.complement_nom_voie AS VARCHAR2(254))
                END AS NOM_RUE_D,
                CASE
                    WHEN d.fid_lateralite = 1 THEN
                        CAST(e.code_insee AS VARCHAR2(254))
                    WHEN d.fid_lateralite = 3 THEN
                        CAST(e.code_insee AS VARCHAR2(254))
                END AS CODE_INSEE_D
        FROM
            G_BASE_VOIE.TEMP_H_TRONCON a
            LEFT JOIN C_5 b ON b.cnumtrc = a.old_objectid
            INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_PHYSIQUE c ON c.objectid = a.fid_voie_physique
            INNER JOIN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE d ON d.fid_voie_physique = c.objectid
            INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE e ON e.objectid = d.fid_voie_administrative
            INNER JOIN G_BASE_VOIE.TEMP_H_TYPE_VOIE f ON f.objectid = e.fid_type_voie
            INNER JOIN G_BASE_VOIE.TEMP_H_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE g ON g.fid_voie_physique = c.objectid
            INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE h ON h.objectid = g.fid_voie_administrative
            INNER JOIN G_BASE_VOIE.TEMP_H_TYPE_VOIE i ON i.objectid = h.fid_type_voie
        WHERE
            d.fid_lateralite IN(1,3)
            AND g.fid_lateralite IN(2,3)
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
        
-- 2. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TRONCON_LITTERALIS IS 'Vue matérialisée regroupant tous les tronçons de la Base Voie au format LITTERALIS.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS.objectid IS 'Clé primaire correspondant aux identifiants des tronçons au format numérique.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS.code_tronc IS 'Code du tronçon au format texte.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS.classement IS 'Domanialité du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS.code_rue_g IS ' Identifiant de la voie de gauche du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS.nom_rue_g IS 'Nom de la voie de gauche du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS.code_insee_g IS 'Code Insee de la voie de gauche du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS.code_rue_d IS 'Identifiant de la voie de droite du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS.nom_rue_d IS 'Nom de la voie de droite du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS.code_insee_d IS 'Code Insee de la voie de droite du tronçon.';
COMMENT ON COLUMN G_BASE_VOIE.VM_TRONCON_LITTERALIS.geometry IS 'Géométrie des tronçons de type polyligne.';

-- 3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'VM_TRONCON_LITTERALIS',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);
COMMIT;

-- 4. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_TRONCON_LITTERALIS 
ADD CONSTRAINT VM_TRONCON_LITTERALIS_PK 
PRIMARY KEY (OBJECTID);

-- 5. Création des index
CREATE INDEX VM_TRONCON_LITTERALIS_SIDX
ON G_BASE_VOIE.VM_TRONCON_LITTERALIS(GEOMETRY)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS(
  'sdo_indx_dims=2, 
  layer_gtype=MULTILINE, 
  tablespace=G_ADT_INDX, 
  work_tablespace=DATA_TEMP'
);

CREATE INDEX VM_TRONCON_LITTERALIS_CODE_RUE_G_IDX ON G_BASE_VOIE.VM_TRONCON_LITTERALIS(CODE_RUE_G)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TRONCON_LITTERALIS_NOM_RUE_G_IDX ON G_BASE_VOIE.VM_TRONCON_LITTERALIS(NOM_RUE_G)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TRONCON_LITTERALIS_CODE_INSEE_G_IDX ON G_BASE_VOIE.VM_TRONCON_LITTERALIS(CODE_INSEE_G)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TRONCON_LITTERALIS_CODE_RUE_G_IDX ON G_BASE_VOIE.VM_TRONCON_LITTERALIS(CODE_RUE_D)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TRONCON_LITTERALIS_NOM_RUE_G_IDX ON G_BASE_VOIE.VM_TRONCON_LITTERALIS(NOM_RUE_D)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_TRONCON_LITTERALIS_CODE_INSEE_G_IDX ON G_BASE_VOIE.VM_TRONCON_LITTERALIS(CODE_INSEE_D)
    TABLESPACE G_ADT_INDX;
    
-- 6. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_TRONCON_LITTERALIS TO G_ADMIN_SIG;

/

