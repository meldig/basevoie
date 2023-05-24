/*
Création de la vue V_TEMP_H_AUDIT_SEUIL_VOIE_SANS_NOM - du projet H de correction des relations tronçons/seuils - identifiant tous les seuils affectés à des voies n''ayant que le type de voie en tant que nom.
*/
/*
DROP VIEW G_BASE_VOIE.V_TEMP_H_AUDIT_SEUIL_VOIE_SANS_NOM;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'V_TEMP_H_AUDIT_SEUIL_VOIE_SANS_NOM';
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_TEMP_H_AUDIT_SEUIL_VOIE_SANS_NOM(
    id_seuil,
    id_voie_administrative,
    nom_voie,
    geom,
    CONSTRAINT "V_TEMP_H_AUDIT_SEUIL_VOIE_SANS_NOM_PK" PRIMARY KEY ("ID_SEUIL") DISABLE
)
AS(
    SELECT
        z.objectid AS id_seuil,
        c.id_voie,
        c.nom_voie,
        z.geom
    FROM
        G_BASE_VOIE.TEMP_H_SEUIL z
        INNER JOIN  G_BASE_VOIE.TEMP_H_INFOS_SEUIL a ON a.fid_seuil = z.objectid
        INNER JOIN G_BASE_VOIE.TEMP_H_VOIE_ADMINISTRATIVE b ON b.objectid = a.fid_voie_administrative
        INNER JOIN G_BASE_VOIE.VM_TEMP_H_VOIE_AGREGE c ON c.id_voie = b.objectid
    WHERE
        c.nom_voie IN(SELECT UPPER(SUBSTR(libelle, 1, 1)) || LOWER(SUBSTR(libelle, 2)) FROM G_BASE_VOIE.TEMP_H_TYPE_VOIE)
);

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_H_AUDIT_SEUIL_VOIE_SANS_NOM IS 'Vue - du projet H de correction des relations tronçons/seuils - identifiant tous les seuils affectés à des voies n''ayant que le type de voie en tant que nom.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_AUDIT_SEUIL_VOIE_SANS_NOM.id_seuil IS 'Identifiant des seuils de la table TEMP_H_SEUIL.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_AUDIT_SEUIL_VOIE_SANS_NOM.id_voie_administrative IS 'Identifiant des voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_H_AUDIT_SEUIL_VOIE_SANS_NOM.nom_voie IS 'Nom des voies administratives : type + libelle_voie + complement_nom_voie.';

--3. Création des métadonnées spatiales
INSERT INTO USER_SDO_GEOM_METADATA(
    TABLE_NAME, 
    COLUMN_NAME, 
    DIMINFO, 
    SRID
)
VALUES(
    'V_TEMP_H_AUDIT_SEUIL_VOIE_SANS_NOM',
    'GEOM',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 684540, 719822.2, 0.005),SDO_DIM_ELEMENT('Y', 7044212, 7078072, 0.005)), 
    2154
);

-- 4. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_TEMP_H_AUDIT_SEUIL_VOIE_SANS_NOM TO G_ADMIN_SIG;

/

