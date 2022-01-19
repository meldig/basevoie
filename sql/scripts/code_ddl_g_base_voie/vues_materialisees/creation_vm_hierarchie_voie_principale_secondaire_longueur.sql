/*
VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR : Vue matérialisée regroupant chaque voie secondaire avec sa voie principale. Une voie principale la voie la plus grande au sein d''un ensemble de voies ayant le même nom et le même code INSEE, les autres sont les voies secondaires. De plus, ces dernières doivent obligatoirement intersecter directement ou non leur voie principale.
*/

-- 1. Suppression de la VM et de ses métadonnées
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR;

-- 1. Création de la VM
CREATE MATERIALIZED VIEW "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR" ("OBJECTID", "ID_VOIE_PRINCIPALE","TYPE_VOIE_PRINCIPALE","LIBELLE_VOIE_PRINCIPALE","CODE_INSEE_VOIE_PRINCIPALE","LONGUEUR_VOIE_PRINCIPALE","ID_VOIE_SECONDAIRE","TYPE_VOIE_SECONDAIRE","LIBELLE_VOIE_SECONDAIRE","CODE_INSEE_VOIE_SECONDAIRE","LONGUEUR_VOIE_SECONDAIRE")
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
SELECT
    rownum AS objectid,
    a.id_voie AS id_voie_principale,
    d.libelle AS type_voie_principale,
    a.libelle_voie AS libelle_voie_principale,
    a.code_insee AS code_insee_voie_principale,
    a.longueur AS longueur_voie_principale,
    b.id_voie AS id_voie_secondaire,
    f.libelle AS type_voie_secondaire,
    b.libelle_voie AS libelle_voie_secondaire,
    b.code_insee AS code_insee_voie_secondaire,
    b.longueur AS longueur_voie_secondaire
FROM
    G_BASE_VOIE.VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR a
    INNER JOIN G_BASE_VOIE.VM_TRAVAIL_VOIE_SECONDAIRE_LONGUEUR b ON b.libelle_voie = a.libelle_voie AND b.code_insee = a.code_insee
    INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = a.id_voie
    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE d ON d.objectid = c.fid_typevoie
    INNER JOIN G_BASE_VOIE.TA_VOIE e ON e.objectid = b.id_voie
    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE f ON f.objectid = e.fid_typevoie
WHERE
    a.longueur > b.longueur;
    
-- 2. Création des commentaires de la vue matérialisée et des champs
COMMENT ON MATERIALIZED VIEW "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR"  IS 'Vue matérialisée regroupant chaque voie secondaire avec sa voie principale. Une voie principale la voie la plus grande au sein d''un ensemble de voies ayant le même nom et le même code INSEE, les autres sont les voies secondaires. De plus, ces dernières doivent obligatoirement intersecter directement ou non leur voie principale.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR"."OBJECTID" IS 'Clé primaire de la vue. Cet identifiant n''a pas d''autre utilité que celle d''identifier chaque entité.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR"."ID_VOIE_PRINCIPALE" IS 'Identifiant de chaque voie principale se trouvant dans VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR"."LIBELLE_VOIE_PRINCIPALE" IS 'Libelle de chaque voie principale (sans son type) se trouvant dans VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR.';
COMMENT ON COLUMN "G_BASE_VOIE"."VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR"."LIBELLE_VOIE_PRINCIPALE" IS 'Libelle de chaque voie principale se trouvant dans VM_TRAVAIL_VOIE_PRINCIPALE_LONGUEUR.';

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR 
ADD CONSTRAINT VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR_PK 
PRIMARY KEY (OBJECTID);

-- 4. Création des index
CREATE INDEX VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR_VOIE_PRINCIPALE_IDX ON G_BASE_VOIE.VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR("CODE_INSEE_VOIE_PRINCIPALE", "TYPE_VOIE_PRINCIPALE", "LIBELLE_VOIE_PRINCIPALE", "LONGUEUR_VOIE_PRINCIPALE")
    TABLESPACE G_ADT_INDX;
    
CREATE INDEX VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR_VOIE_SECONDAIRE_IDX ON G_BASE_VOIE.VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR("CODE_INSEE_VOIE_SECONDAIRE", "TYPE_VOIE_SECONDAIRE", "LIBELLE_VOIE_SECONDAIRE", "LONGUEUR_VOIE_SECONDAIRE")
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR_ID_VOIE_PRINCIPALE_IDX ON G_BASE_VOIE.VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR("ID_VOIE_PRINCIPALE")
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR_ID_VOIE_SECONDAIRE_IDX ON G_BASE_VOIE.VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR("ID_VOIE_SECONDAIRE")
    TABLESPACE G_ADT_INDX;
    
-- 5. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_HIERARCHIE_VOIE_PRINCIPALE_SECONDAIRE_LONGUEUR TO G_ADMIN_SIG;

/

