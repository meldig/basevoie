/*
Création de la vue matérialisée VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR - du projet j de test de production - matérialisant la géométrie des voies administratives avec leur nom, code insee, latéralité et hiérarchie.
*/
-- Suppression de la VM
/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR;
*/
-- 1. Création de la VM
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR (
    ID_SEUIL,
    ID_GEOM_SEUIL,
    CODE_INSEE_BASE,
    CODE_INSEE_CALCULE
)        
REFRESH FORCE
START WITH TO_DATE('17-05-2023 06:00:00', 'dd-mm-yyyy hh24:mi:ss')
NEXT sysdate + 6/24
DISABLE QUERY REWRITE AS
SELECT
    b.objectid AS id_seuil,
    a.objectid AS id_geom_seuil,
    a.code_insee AS code_insee_base,
    TRIM(GET_CODE_INSEE_97_COMMUNES_CONTAIN_POINT('TA_SEUIL', a.geom)) AS code_insee_calcule
FROM
    G_BASE_VOIE.TA_SEUIL a 
    INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL b ON b.fid_seuil = a.objectid 
WHERE
    TRIM(GET_CODE_INSEE_97_COMMUNES_CONTAIN_POINT('TA_SEUIL', a.geom)) <> a.code_insee;

-- 2. Création des commentaires de la VM
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR IS 'Vue matérialisée identifiant les seuils dont le code INSEE ne correspond pas au référentiel des communes (G_REFERENTIEL.MEL_COMMUNE_LLH).';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR.id_seuil IS 'Identifiants des seuils correspondant à la clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR.id_geom_seuil IS 'Identifiants de la géométrie des seuils.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR.code_insee_base IS 'Code INSEE du seuil en base.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR.code_insee_calcule IS 'Code INSEE du seuil obtenu par requête spatiale.';

-- 3. Création de la clé primaire
ALTER MATERIALIZED VIEW VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR 
ADD CONSTRAINT VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR_PK 
PRIMARY KEY (ID_SEUIL);

-- 4. Création des index
CREATE INDEX VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR_ID_GEOM_SEUIL_IDX ON G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR(id_geom_seuil)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR_CODE_INSEE_BASE_IDX ON G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR(CODE_INSEE_BASE)
    TABLESPACE G_ADT_INDX;

CREATE INDEX VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR_CODE_INSEE_CALCULE_IDX ON G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR(CODE_INSEE_CALCULE)
    TABLESPACE G_ADT_INDX;
    
-- 5. Affectations des droits
GRANT SELECT ON G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR TO G_ADMIN_SIG;

/

