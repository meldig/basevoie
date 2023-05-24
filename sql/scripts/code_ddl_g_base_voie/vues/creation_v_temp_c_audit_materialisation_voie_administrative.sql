/*
Création de la vue V_TEMP_C_AUDIT_MATERIALISATION_VOIE_ADMINISTRATIVE - du projet C de correction de la latéralité des voies - permettant d'identifier les voies administratives qui ne peuvent pas être matérialisées
*/
/*
DROP VIEW G_BASE_VOIE.V_TEMP_C_AUDIT_MATERIALISATION_VOIE_ADMINISTRATIVE;
*/
CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_TEMP_C_AUDIT_MATERIALISATION_VOIE_ADMINISTRATIVE(
    OBJECTID,
    GENRE_VOIE,
    TYPE_VOIE,
    LIBELLE_VOIE,
    COMPLEMENT_NOM_VOIE,
    LATERALITE,
    CODE_INSEE,
    DATE_SAISIE,
    DATE_MODIFICATION,
    PNOM_SAISIE,
    PNOM_MODIFICATION,
    CONSTRAINT "V_TEMP_C_AUDIT_MATERIALISATION_VOIE_ADMINISTRATIVE_PK" PRIMARY KEY ("OBJECTID") DISABLE
)
AS
SELECT
    a.objectid,
    a.genre_voie,
    b.libelle AS type_voie,
    a.libelle_voie,
    a.complement_nom_voie,
    c.libelle_court AS lateralite,
    a.code_insee,
    a.date_saisie,
    a.date_modification,
    d.pnom AS pnom_saisie,
    e.pnom AS pnom_modification
FROM
    G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE a
    INNER JOIN G_BASE_VOIE.TEMP_C_TYPE_VOIE b ON b.objectid = a.fid_type_voie
    INNER JOIN G_BASE_VOIE.TEMP_C_LIBELLE c ON c.objectid = a.fid_lateralite
    INNER JOIN G_BASE_VOIE.TEMP_C_AGENT d ON d.numero_agent = a.fid_pnom_saisie
    INNER JOIN G_BASE_VOIE.TEMP_C_AGENT e ON e.numero_agent = a.fid_pnom_modification
WHERE
    a.objectid NOT IN(SELECT id_voie_administrative FROM VM_TEMP_C_VOIE_ADMINISTRATIVE);
    
-- 2. Création des commentaires sur la vue et les champs
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_C_AUDIT_MATERIALISATION_VOIE_ADMINISTRATIVE IS 'Vue - du projet C de correction de la latéralité des voies - permettant d''identifier les voies administratives qui ne peuvent pas être matérialisées.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_MATERIALISATION_VOIE_ADMINISTRATIVE.objectid IS 'Clé primaire de la vue correspondant aux identifiants des voies administratives..';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_MATERIALISATION_VOIE_ADMINISTRATIVE.genre_voie IS 'Genre du nom de la voie (féminin, masculin, neutre, etc).';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_MATERIALISATION_VOIE_ADMINISTRATIVE.type_voie IS 'Type de voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_MATERIALISATION_VOIE_ADMINISTRATIVE.libelle_voie IS 'Nom de voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_MATERIALISATION_VOIE_ADMINISTRATIVE.complement_nom_voie IS 'Complément de nom de voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_MATERIALISATION_VOIE_ADMINISTRATIVE.code_insee IS 'Code insee de la voie "administrative".';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_MATERIALISATION_VOIE_ADMINISTRATIVE.date_saisie IS 'Date de création du libellé de voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_MATERIALISATION_VOIE_ADMINISTRATIVE.date_modification IS 'Date de modification du libellé de voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_MATERIALISATION_VOIE_ADMINISTRATIVE.pnom_saisie IS 'Pnom de l''agent créateur de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_MATERIALISATION_VOIE_ADMINISTRATIVE.pnom_modification IS 'Pnom de l''agent modificateur de la voie administrative.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_MATERIALISATION_VOIE_ADMINISTRATIVE.lateralite IS 'Latéralité de la voie administrative par rapport à sa voie physique.';

-- 8. Affectation du droit de sélection sur les objets de la table aux administrateurs
GRANT SELECT ON G_BASE_VOIE.V_TEMP_C_AUDIT_MATERIALISATION_VOIE_ADMINISTRATIVE TO G_ADMIN_SIG;

/

