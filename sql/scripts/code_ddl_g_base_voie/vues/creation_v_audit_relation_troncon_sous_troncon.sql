/*
La vue V_AUDIT_RELATION_TRONCON_SOUS_TRONCON permet de faire l'état des lieux des relations entre tronçon, sous-tronçons et domanialité dans la table SIREO_LEC.OUT_DOMANIALITE
*/
/*
DROP VIEW G_BASE_VOIE.V_AUDIT_RELATION_TRONCON_SOUS_TRONCON;
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_AUDIT_RELATION_TRONCON_SOUS_TRONCON(
    objectid,
    thematique,
    nombre_troncon,
    CONSTRAINT "V_AUDIT_RELATION_TRONCON_SOUS_TRONCON_PK" PRIMARY KEY ("OBJECTID") DISABLE
) 
AS
    WITH
        C_1 AS(-- Sélection des tronçons composés d'un seul sous-tronçon
            SELECT
                cnumtrc
            FROM
                SIREO_LEC.OUT_DOMANIALITE
            GROUP BY
                cnumtrc
            HAVING
                COUNT(objectid)=1
        ),
        
        C_2 AS(-- Sélection des tronçons composés de plusieurs sous-tronçons
            SELECT
                cnumtrc
            FROM
                SIREO_LEC.OUT_DOMANIALITE
            GROUP BY
                cnumtrc
            HAVING
                COUNT(objectid)>1
        ),
        
        C_3 AS(-- Décompte des tronçons composés de plusieurs sous-tronçons de domanialités différentes
            SELECT
                a.cnumtrc
            FROM
                C_2 a
                INNER JOIN SIREO_LEC.OUT_DOMANIALITE b ON b.cnumtrc = a.cnumtrc
            GROUP BY
                a.cnumtrc
            HAVING
                COUNT(DISTINCT b.domania) >1
        ),
        
        C_4 AS(-- Compilation de tous les décomptes ci-dessus
            SELECT
                'Tronçon composé d''un seul sous-tronçon' AS thematique,
                COUNT(cnumtrc) AS nbr
            FROM
                C_1
            GROUP BY
                'Tronçon composé d''un seul sous-tronçon'
            UNION ALL
            SELECT
                'Tronçon composé de plusieurs sous-tronçons' AS thematique,
                COUNT(cnumtrc) AS nbr
            FROM
                C_2
            GROUP BY
                'Tronçon composé de plusieurs sous-tronçons'
            UNION ALL
            SELECT
                'Tronçon composé de plusieurs sous-tronçons de domanialités différentes' AS thematique,
                COUNT(cnumtrc) AS nbr
            FROM
                C_3
            GROUP BY
                'Tronçon composé de plusieurs sous-tronçons de domanialités différentes'
        )
        
        SELECT
            rownum,
            thematique,
            nbr
        FROM
            C_4;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_AUDIT_RELATION_TRONCON_SOUS_TRONCON IS 'Vue faisant l''état des lieux des relations entre tronçon, sous-tronçons et domanialité dans la table SIREO_LEC.OUT_DOMANIALITE.' ;
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_RELATION_TRONCON_SOUS_TRONCON.objectid IS 'Clé primaire de la vue.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_RELATION_TRONCON_SOUS_TRONCON.thematique IS 'Thème d''étude de l''audit.';
COMMENT ON COLUMN G_BASE_VOIE.V_AUDIT_RELATION_TRONCON_SOUS_TRONCON.nombre_troncon IS 'Nombre de tronçons concernés par le thème d''étude.';

-- 3. Création des droits de lecture
GRANT SELECT ON G_BASE_VOIE.V_AUDIT_RELATION_TRONCON_SOUS_TRONCON TO G_ADMIN_SIG;

/

