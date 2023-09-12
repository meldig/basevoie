/*
Création de la Vue V_ADMIN_FREQUENCE_MAJ_VUE_MATERIALISEE indiquant pour chaque vue matérialisée du schéma, sa fréquence de mise à jour.
*/

CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_ADMIN_FREQUENCE_MAJ_VUE_MATERIALISEE(
    OBJECTID,
    SCHEMA_PROPRIETAIRE,
    DERNIER_RAFRAICHISSEMENT,
    PROCHAIN_RAFRAICHISSEMENT,
    NOM_VUE_MATERIALISEE,
    CONSTRAINT "V_ADMIN_FREQUENCE_MAJ_VUE_MATERIALISEE_PK" PRIMARY KEY ("OBJECTID") DISABLE
) 
AS(
    SELECT
        ROWNUM AS objectid,
        SCHEMA_USER AS schema_proprietaire,
        TO_CHAR(LAST_DATE, 'DD/MM/YYY HH:MI') AS Dernier_rafraichissement,
        TO_CHAR(NEXT_DATE, 'DD/MM/YYY HH:MI') AS Prochain_rafraichissement,
        TRIM(REPLACE(SUBSTR(WHAT, 23, LENGTH(SUBSTR(WHAT, 23))-3), '"', '')) nom_vue_materialisee
FROM
    user_jobs
WHERE
    WHAT LIKE '%refresh%'
    AND WHAT LIKE '%VM_%'
    AND SCHEMA_USER='G_BASE_VOIE'
);

COMMENT ON TABLE G_BASE_VOIE.V_ADMIN_FREQUENCE_MAJ_VUE_MATERIALISEE IS 'Vue indiquant pour chaque vue matérialisée du schéma, sa fréquence de mise à jour.' ;
COMMENT ON COLUMN G_BASE_VOIE.V_ADMIN_FREQUENCE_MAJ_VUE_MATERIALISEE.OBJECTID IS 'Identifiant de chaque entité. Ce champ n''a aucune autre utilité que celle d''être une clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_ADMIN_FREQUENCE_MAJ_VUE_MATERIALISEE.SCHEMA_PROPRIETAIRE IS 'Schéma propriétaire des vues matérialisées.';
COMMENT ON COLUMN G_BASE_VOIE.V_ADMIN_FREQUENCE_MAJ_VUE_MATERIALISEE.DERNIER_RAFRAICHISSEMENT IS 'Date et heure du dernier rafraîchissement des vues matérialisées.';
COMMENT ON COLUMN G_BASE_VOIE.V_ADMIN_FREQUENCE_MAJ_VUE_MATERIALISEE.PROCHAIN_RAFRAICHISSEMENT IS 'Date et heure du prochain rafraîchissement des vues matérialisées.';
COMMENT ON COLUMN G_BASE_VOIE.V_ADMIN_FREQUENCE_MAJ_VUE_MATERIALISEE.NOM_VUE_MATERIALISEE IS 'Nom des vues matérialisées.'; 

/

