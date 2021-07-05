CREATE OR REPLACE FORCE VIEW V_ADRESSE_LITTERALIS (
    IDENTIFIANT,
    CODE_VOIE,
    CODE_POINT,
    NATURE,
    LIBELLE,
    NUMERO,
    REPETITION,
    COTE,
    GEOMETRY,
    CONSTRAINT "V_ADRESSE_LITTERALIS_PK" PRIMARY KEY ("CODE_POINT") DISABLE)
    AS (
            SELECT
                ROWNUM AS IDENTIFIANT,
                f.objectid AS CODE_VOIE,
                b.objectid AS CODE_POINT,
                'ADR' AS NATURE,
                CASE
                    WHEN LENGTH(a.numero_seuil) = 1 THEN '0' || CAST(a.numero_seuil AS VARCHAR2(50))
                    WHEN LENGTH(a.numero_seuil) > 1 THEN CAST(a.numero_seuil AS VARCHAR2(50))
                END AS LIBELLE,
                a.numero_seuil AS NUMERO,
                a.complement_numero_seuil AS REPETITION,
                'LesDeuxCotes' AS COTE,
                b.geom AS GEOMETRY
            FROM
                G_BASE_VOIE.TA_INFOS_SEUIL a
                INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = b.objectid
                INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = c.fid_troncon
                INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE e ON e.fid_troncon = d.objectid
                INNER JOIN G_BASE_VOIE.TA_VOIE f ON f.objectid = e.fid_voie
        );


-- 2. Création des commentaires de la vue
COMMENT ON TABLE G_BASE_VOIE.V_ADRESSE_LITTERALIS IS 'Vue regroupant la liste des adresses postales par rue pour LITTERALIS' ;
COMMENT ON COLUMN G_BASE_VOIE.V_ADRESS_LITTERALIS.IDENTIFIANT IS "Cle primaire de la vue"
COMMENT ON COLUMN G_BASE_VOIE.V_ADRESSE_LITTERALIS.CODE_VOIE IS 'Liaison avec la classe TRONCON sur la colonne CODE_RUE_G ou CODE_RUE_D.';
COMMENT ON COLUMN G_BASE_VOIE.V_ADRESSE_LITTERALIS.CODE_POINT IS 'Identificateur unique et immuable du point partagé entre Littéralis Expert et le SIG.';
COMMENT ON COLUMN G_BASE_VOIE.V_ADRESSE_LITTERALIS.NATURE IS 'Indique la nature du point: ADR = Adresse.';
COMMENT ON COLUMN G_BASE_VOIE.V_ADRESSE_LITTERALIS.LIBELLE IS 'Libellé du point affiché dans les textes (dans les actes…).';
COMMENT ON COLUMN G_BASE_VOIE.V_ADRESSE_LITTERALIS.NUMERO IS 'Code INSEE de la commune côté gauche du tronçon..';
COMMENT ON COLUMN G_BASE_VOIE.V_ADRESSE_LITTERALIS.REPETITION IS 'Indique la valeur de répétition d’un numéro sur une rue. La saisie de la répétition est libre.';
COMMENT ON COLUMN G_BASE_VOIE.V_ADRESSE_LITTERALIS.COTE IS 'Définit sur quel côté de la voie s’appuie l’adresse: LesDeuxCotes, Impair, Pair.';