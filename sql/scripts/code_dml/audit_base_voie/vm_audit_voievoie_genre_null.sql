-- VM_AUDIT_VOIEVOIE_GENRE_NULL: Genre des voies valides NULL Le genre de certaines voies valides n'est pas renseigné (hors c'était une demande des élus)

-- 0. Suppression de l'ancienne vue matérialisée
-- DROP MATERIALIZED VIEW VM_AUDIT_VOIEVOIE_GENRE_NULL;

--1. Creation de la vue
CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_VOIEVOIE_GENRE_NULL (IDENTIFIANT, CODE_VOIE)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE
AS
SELECT
    rownum,
    CCOMVOI
FROM
    G_BASE_VOIE.TEMP_VOIEVOI
WHERE
    genre IS NULL
AND
    cdvalvoi = 'V'
;


-- 2. Clé primaire
ALTER TABLE G_BASE_VOIE.VM_AUDIT_VOIEVOIE_GENRE_NULL
ADD CONSTRAINT VM_AUDIT_VOIEVOIE_GENRE_NULL_PK 
PRIMARY KEY (IDENTIFIANT);


-- 3. Commentaire de la vue materialisée
COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_AUDIT_VOIEVOIE_GENRE_NULL  IS 'Vue permettant de reperer les voies dont le genre est NULL';


-- 4. Commentaire des colonnes
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_VOIEVOIE_GENRE_NULL.IDENTIFIANT IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.VM_AUDIT_VOIEVOIE_GENRE_NULL.code_voie IS 'identifiant de la voie.';