/*
Création de la vue vue V_BAL_VERSION_1_3 permettant de faire l'export BAL pour 91 communes.
*/

-- 1. Création de la vue matérialisée
CREATE OR REPLACE FORCE EDITIONABLE VIEW "G_BASE_VOIE"."V_BAL_VERSION_1_3" ("UID_ADRESSE", "CLE_INTEROP", "COMMUNE_INSEE", "COMMUNE_NOM", "COMMUNE_DELEGUEE_INSEE", "COMMUNE_DELEGUEE_NOM", "VOIE_NOM", "LIEUDIT_COMPLEMENT_NOM", "NUMERO", "SUFFIXE", "POSITION", "X", "Y", "LONG", "LAT", "CAD_PARCELLES", "SOURCE", "DATE_DER_MAJ", "CERTIFICATION_COMMUNE", 
	 CONSTRAINT "V_BAL_VERSION_1_3_PK" PRIMARY KEY ("UID_ADRESSE") DISABLE) AS 
    SELECT DISTINCT
        UID_ADRESSE,
        CLE_INTEROP,
        COMMUNE_INSEE,
        COMMUNE_NOM,
        COMMUNE_DELEGUEE_INSEE,
        COMMUNE_DELEGUEE_NOM,
        TRIM(VOIE_NOM) AS voie_nom,
        LIEUDIT_COMPLEMENT_NOM,
        NUMERO,
        SUFFIXE,
        POSITION,
        X,
        Y,
        LONG,
        LAT,
        TRIM(CAD_PARCELLES),
        SOURCE,
        DATE_DER_MAJ,
        CERTIFICATION_COMMUNE
    FROM
        G_BASE_VOIE.VM_BAN_VERSION_1_3_2023
    WHERE
        COMMUNE_INSEE NOT IN('59017','59482','59599','59009','59298','59355');

-- 2. Création des commentaires
COMMENT ON TABLE "G_BASE_VOIE"."V_BAL_VERSION_1_3"  IS 'Vue proposant la base adresse locale de la MEL sur 91 communes (les 4 autres alimentant déjà la BAL avec leurs données).';

-- 3. Création des droits
GRANT SELECT ON G_BASE_VOIE.V_BAL_VERSION_1_3 TO G_ADMIN_SIG;

/

