     
/*
Vue V_TEMP_C_AUDIT_NOMENCLATURE_A_RETRAVAILLER - du projet C de correction de la nomenclature des voies - permettant de retrouver toutes les voies dont le nom suscite des questions.
*/ 
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_TEMP_C_AUDIT_NOMENCLATURE_A_RETRAVAILLER(
    id_voie_administrative,
    type_voie,
    libelle_voie,
    complement_nom_voie,
    commentaire,
    agent_verification,
    date_modification,
    agent_modification,
    etat_verification,
    CONSTRAINT "V_TEMP_C_AUDIT_NOMENCLATURE_A_RETRAVAILLER_PK" PRIMARY KEY ("ID_VOIE_ADMINISTRATIVE") DISABLE
)
AS
SELECT 
    f.objectid AS id_voie_administrative,
    g.libelle AS type_voie,
    f.libelle_voie,
    f.complement_nom_voie,
    f.commentaire,
    b.pnom AS agent_verification,
    TRUNC(f.date_modification) AS date_modification,
    h.pnom AS agent_modification,
    e.libelle_court AS etat_verification
FROM
    G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE_PRINCIPALE_MATERIALISE d
    INNER JOIN G_BASE_VOIE.TEMP_C_LIBELLE e ON e.objectid = d.fid_etat_verification
    INNER JOIN G_BASE_VOIE.TEMP_C_AGENT b ON b.numero_agent = d.fid_agent_verification
    INNER JOIN G_BASE_VOIE.TEMP_C_VOIE_ADMINISTRATIVE f ON f.objectid = d.id_voie_administrative
    INNER JOIN G_BASE_VOIE.TEMP_C_TYPE_VOIE g ON g.objectid = f.fid_type_voie
    INNER JOIN G_BASE_VOIE.TEMP_C_AGENT h ON h.numero_agent = f.fid_pnom_modification
WHERE
    (d.fid_etat_verification = 4
    AND d.commentaire IS NOT NULL
    AND TRUNC(f.date_modification) > TO_DATE('02/12/2022', 'dd/mm/yyyy')
    AND f.fid_pnom_modification <> 40277)
    OR d.fid_verification = 24;
    
-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_C_AUDIT_NOMENCLATURE_A_RETRAVAILLER IS 'Vue - du projet C de correction de la nomenclature des voies - permettant de retrouver toutes les voies dont le nom suscite des questions.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_NOMENCLATURE_A_RETRAVAILLER.id_voie_administrative IS 'Clé primaire de la vue correspondant aux identifiants de voies administratives.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_NOMENCLATURE_A_RETRAVAILLER.type_voie IS 'Type de voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_NOMENCLATURE_A_RETRAVAILLER.libelle_voie IS 'Nom de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_NOMENCLATURE_A_RETRAVAILLER.complement_nom_voie IS 'Complément de nom de la voie.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_NOMENCLATURE_A_RETRAVAILLER.commentaire IS 'Commentaire lors de la phase de correction ou celle de vérification, ou comportant une information à conserver en interne.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_NOMENCLATURE_A_RETRAVAILLER.agent_verification IS 'Pnom de l''agent chargé des vérifications de la nomenclature des voies.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_NOMENCLATURE_A_RETRAVAILLER.date_modification IS 'Date de la dernière modification de l''entité.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_NOMENCLATURE_A_RETRAVAILLER.agent_modification IS 'Pnom de l''agent ayant modifié l''entité en dernier.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_C_AUDIT_NOMENCLATURE_A_RETRAVAILLER.etat_verification IS 'Etat d''avancement de la vérification de la nomenclature.';

/

