/*
Import des Familles et libellés utilisés pour la base voie.
*/

SET SERVEROUTPUT ON
DECLARE
    v_nbr_objectid NUMBER(38,0);
    v_contrainte VARCHAR2(100);
BEGIN

    SAVEPOINT POINT_SAUVEGARDE_REMPLISSAGE;

     -- 1. Import des libellés dans TA_FAMILLE
    MERGE INTO G_GEO.TA_FAMILLE a
        USING G_GEO.TEMP_FAMILLE t
    ON (UPPER(a.valeur) = UPPER(t.valeur))
    WHEN NOT MATCHED THEN
        INSERT(a.valeur)
        VALUES(t.valeur);

    -- 2. Import des libellés dans TA_LIBELLE_LONG
    MERGE INTO G_GEO.TA_LIBELLE_LONG a
        USING G_GEO.TEMP_LIBELLE t
    ON (UPPER(a.valeur) = UPPER(t.valeur))
    WHEN NOT MATCHED THEN
        INSERT(a.valeur)
        VALUES(t.valeur);

    -- 3. Import des relations dans TA_FAMILLE_LIBELLE
    -- 3.1. Pour les types d'actions
    MERGE INTO G_GEO.TA_FAMILLE_LIBELLE a
        USING (
            SELECT
                a.objectid AS fid_famille,
                b.objectid AS fid_libelle_long
            FROM
                G_GEO.TA_FAMILLE a,
                G_GEO.TA_LIBELLE_LONG b
            WHERE
                UPPER(a.valeur) = UPPER('action')
                AND UPPER(b.valeur) IN(UPPER('insertion'), UPPER('édition'), UPPER('suppression'))
            ) t
    ON (UPPER(a.fid_famille) = UPPER(t.fid_famille) AND UPPER(a.fid_libelle_long) = UPPER(t.fid_libelle_long))
    WHEN NOT MATCHED THEN
        INSERT(a.fid_famille, a.fid_libelle_long)
        VALUES(t.fid_famille, t.fid_libelle_long);

    -- 3.2. Pour les genres de voie
    MERGE INTO G_GEO.TA_FAMILLE_LIBELLE a
        USING (
            SELECT
                a.objectid AS fid_famille,
                b.objectid AS fid_libelle_long
            FROM
                G_GEO.TA_FAMILLE a,
                G_GEO.TA_LIBELLE_LONG b
            WHERE
                UPPER(a.valeur) = UPPER('genre du nom des voies')
                AND UPPER(b.valeur) IN(UPPER('masculin'), UPPER( 'féminin'), UPPER( 'neutre'), UPPER( 'couple'), UPPER( 'non-identifié'), UPPER( 'non-renseigné'))
            ) t
    ON (UPPER(a.fid_famille) = UPPER(t.fid_famille) AND UPPER(a.fid_libelle_long) = UPPER(t.fid_libelle_long))
    WHEN NOT MATCHED THEN
        INSERT(a.fid_famille, a.fid_libelle_long)
        VALUES(t.fid_famille, t.fid_libelle_long);

    -- 3.3. Pour les familles des points d'intérêts
    MERGE INTO G_GEO.TA_FAMILLE_LIBELLE a
        USING (
            SELECT
                a.objectid AS fid_famille,
                b.objectid AS fid_libelle_long
            FROM
                G_GEO.TA_FAMILLE a,
                G_GEO.TA_LIBELLE_LONG b
            WHERE
                UPPER(a.valeur) = UPPER('administration: mairies, lmcu, prefecture, cg, cr,cite a,justice, tresor public')
                AND UPPER(b.valeur) IN(UPPER('mairie'), UPPER( 'mairie annexe'), UPPER( 'mairie quartier'))
        ) t
    ON (UPPER(a.fid_famille) = UPPER(t.fid_famille) AND UPPER(a.fid_libelle_long) = UPPER(t.fid_libelle_long))
    WHEN NOT MATCHED THEN
        INSERT(a.fid_famille, a.fid_libelle_long)
        VALUES(t.fid_famille, t.fid_libelle_long);


    -- Insertion des métadonnées pour les entités créées par la MEL et l'IGN
    -- 4. Insertion dans TA_ORGANISME de la MEL
    MERGE INTO G_GEO.TA_ORGANISME a
        USING(
            SELECT 
                'MEL' AS acronyme, 
                'Métropole Européenne de Lille' AS nom_organisme 
            FROM DUAL
        ) t
    ON (UPPER(a.acronyme) = UPPER(t.acronyme) AND UPPER(a.nom_organisme) = UPPER(t.nom_organisme))
    WHEN NOT MATCHED THEN
        INSERT(a.acronyme, a.nom_organisme)
        VALUES(t.acronyme, t.nom_organisme);

    -- 5. Insertion de la source dans TA_SOURCE
    MERGE INTO G_GEO.TA_SOURCE a
        USING(
            SELECT 
                'Base Voie' AS nom_source, 
                'La Base Voie contient toutes les données utilisées pour traiter et qualifier la partie géométrique des voies présentes dans la MEL.' AS description 
            FROM DUAL
        ) t
    ON (UPPER(a.nom_source) = UPPER(t.nom_source) AND UPPER(a.description) = UPPER(t.description))
    WHEN NOT MATCHED THEN
        INSERT(a.nom_source, a.description)
        VALUES(t.nom_source, t.description);

    -- 6. Insertion de la méthode d'acquisition des données de la base voie dans la table TA_PROVENANCE 
    -- 6.1. Insertion de la méthode d'acquisition des tronçons/voies de la base voie de la MEL
    MERGE INTO G_GEO.TA_PROVENANCE a
        USING(
            SELECT 
                'Les tronçons et les voies ont été tracées par photo-interprétation via la plateforme DynMap jusqu''en 2021, date à partir de laquelle les données ont été sasies via qgis en raison de l''obsolescence de flash utilisé par DynaMap. Dans les deux cas le travail était majoritairement bureautique avec peu d''intervention sur le terrain.' AS methode_acquisition 
            FROM DUAL
        ) t
    ON (UPPER(a.methode_acquisition) = UPPER(t.methode_acquisition))
    WHEN NOT MATCHED THEN
        INSERT(a.methode_acquisition)
        VALUES(t.methode_acquisition);

    -- 6.2. Insertion de la méthode d'acquisition des tronçons/voies de l'IGN
    MERGE INTO G_GEO.TA_PROVENANCE a
        USING(
            SELECT 
                'Import des tronçons/voies présents dans la BdTopo de l''IGN, mais absents de la base voie MEL, via ogr2ogr depuis des shapes, suite à un travail d''appariement des deux bases.' AS methode_acquisition 
            FROM DUAL
        ) t
    ON (UPPER(a.methode_acquisition) = UPPER(t.methode_acquisition))
    WHEN NOT MATCHED THEN
        INSERT(a.methode_acquisition)
        VALUES(t.methode_acquisition);  

    -- 7. Insertion de la date d''acquisition des tronçons/voies de l'IGN
    MERGE INTO G_GEO.TA_DATE_ACQUISITION a
        USING(
            SELECT 
                TO_DATE(sysdate, 'dd/mm/yy') AS date_acquisition, 
                TO_DATE('01/01/2020', 'dd/mm/yy') AS millesime, 
                sys_context('USERENV','OS_USER') AS nom_obtenteur 
            FROM DUAL
        ) t
    ON (a.date_acquisition = t.date_acquisition AND a.millesime = t.millesime AND UPPER(a.nom_obtenteur) = UPPER(t.nom_obtenteur))
    WHEN NOT MATCHED THEN
        INSERT(a.date_acquisition, a.millesime, a.nom_obtenteur)
        VALUES(t.date_acquisition, t.millesime, t.nom_obtenteur);

    -- 8. Insertion des données dans la table TA_METADONNEE 
    -- 8.1. Pour la MEL
    MERGE INTO G_GEO.TA_METADONNEE a
        USING(
            SELECT 
                a.objectid AS fid_source,
                b.objectid AS fid_provenance 
            FROM 
                G_GEO.TA_SOURCE a, 
                G_GEO.TA_PROVENANCE b
            WHERE
                UPPER(a.nom_source) = UPPER('Base Voie')
                AND UPPER(b.methode_acquisition) = UPPER('Les tronçons et les voies ont été tracées par photo-interprétation via la plateforme DynMap jusqu''en 2021, date à partir de laquelle les données ont été sasies via qgis en raison de l''obsolescence de flash utilisé par DynaMap. Dans les deux cas le travail était majoritairement bureautique avec peu d''intervention sur le terrain.')
        )t
    ON (a.fid_source = t.fid_source AND a.fid_provenance = t.fid_provenance)
    WHEN NOT MATCHED THEN
        INSERT(a.fid_source, a.fid_provenance)
        VALUES(t.fid_source, t.fid_provenance);

    -- 8.2. Pour l'IGN
    MERGE INTO G_GEO.TA_METADONNEE a
        USING(
            SELECT 
                a.objectid AS fid_source, 
                b.objectid AS fid_acquisition, 
                c.objectid AS fid_provenance 
            FROM 
                G_GEO.TA_SOURCE a, 
                G_GEO.TA_DATE_ACQUISITION b,
                G_GEO.TA_PROVENANCE c
            WHERE
                UPPER(a.nom_source) = UPPER('BDTOPO')
                AND b.date_acquisition = TO_DATE(sysdate, 'dd/mm/yy')
                AND b.millesime = TO_DATE('01/01/2020', 'dd/mm/yy')
                AND UPPER(c.methode_acquisition) = UPPER('Import des tronçons/voies présents dans la BdTopo de l''IGN, mais absents de la base voie MEL, via ogr2ogr depuis des shapes, suite à un travail d''appariement des deux bases en 2021.')
        )t
    ON (a.fid_source = t.fid_source AND a.fid_provenance = t.fid_provenance)
    WHEN NOT MATCHED THEN
        INSERT(a.fid_source, a.fid_acquisition, a.fid_provenance)
        VALUES(t.fid_source, t.fid_acquisition, t.fid_provenance);

    -- 9. Insertion des relations entre métadonnées et Organismes
    -- 9.1. Pour l'IGN
    MERGE INTO G_GEO.TA_METADONNEE_RELATION_ORGANISME a
        USING(
            SELECT 
                a.objectid AS fid_metadonnee,
                e.objectid AS fid_organisme
            FROM 
                G_GEO.TA_METADONNEE a
                INNER JOIN G_GEO.TA_SOURCE b ON b.objectid = a.fid_source 
                INNER JOIN G_GEO.TA_DATE_ACQUISITION c ON c.objectid = a.fid_acquisition
                INNER JOIN G_GEO.TA_PROVENANCE d ON d.objectid = a.fid_provenance,
                G_GEO.TA_ORGANISME e
            WHERE
                UPPER(b.nom_source) = UPPER('BDTOPO')
                AND c.date_acquisition = TO_DATE(sysdate, 'dd/mm/yy')
                AND c.millesime = TO_DATE('01/01/2020', 'dd/mm/yy')
                AND UPPER(d.methode_acquisition) = UPPER('Import des tronçons/voies présents dans la BdTopo de l''IGN, mais absents de la base voie MEL, via ogr2ogr depuis des shapes, suite à un travail d''appariement des deux bases en 2021.')
                AND UPPER(e.nom_organisme) = UPPER('Institut National de l''Information Geographie et Forestiere')
        )t
    ON (a.fid_metadonnee = t.fid_metadonnee AND a.fid_organisme = t.fid_organisme)
    WHEN NOT MATCHED THEN
        INSERT(a.fid_metadonnee, a.fid_organisme)
        VALUES(t.fid_metadonnee, t.fid_organisme);

    -- 9.2. Pour la MEL
    MERGE INTO G_GEO.TA_METADONNEE_RELATION_ORGANISME a
        USING(
            SELECT 
                a.objectid AS fid_metadonnee 
            FROM 
                G_GEO.TA_METADONNEE a
                INNER JOIN G_GEO.TA_SOURCE b ON b.objectid = a.fid_source
                INNER JOIN G_GEO.TA_PROVENANCE c ON c.objectid = a.fid_provenance
                G_GEO.TA_ORGANISME d
            WHERE
                UPPER(b.nom_source) = UPPER('Base Voie')
                AND UPPER(c.methode_acquisition) = UPPER('Les tronçons et les voies ont été tracées par photo-interprétation via la plateforme DynMap jusqu''en 2021, date à partir de laquelle les données ont été sasies via qgis en raison de l''obsolescence de flash utilisé par DynaMap. Dans les deux cas le travail était majoritairement bureautique avec peu d''intervention sur le terrain.')
                AND UPPER(d.nom_organisme) = UPPER('Métropole Européenne de Lille')
        )t
    ON (a.fid_metadonnee = t.fid_metadonnee)
    WHEN NOT MATCHED THEN
        INSERT(a.fid_metadonnee)
        VALUES(t.fid_metadonnee);

    -- 10. Insertion dans TA_LIBELLE
    MERGE INTO G_GEO.TA_LIBELLE a
        USING(
            SELECT
                a.objectid
            FROM
                G_GEO.TA_LIBELLE_LONG a
            WHERE
                UPPER(a.valeur) IN(UPPER('insertion'), UPPER('édition'), UPPER('suppression'), UPPER('masculin'), UPPER( 'féminin'), UPPER( 'neutre'), UPPER( 'couple'), UPPER( 'non-identifié'), UPPER( 'non-renseigné'), UPPER('mairie'), UPPER( 'mairie annexe'), UPPER( 'mairie quartier'))
        )t
    ON (a.fid_libelle_long = t.objectid)
    WHEN NOT MATCHED THEN
        INSERT(a.fid_libelle_long)
        VALUES(t.objectid);

    -- En cas d'erreur une exception est levée et un rollback effectué, empêchant ainsi toute insertion de se faire et de retourner à l'état des tables précédent l'insertion.
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO POINT_SAUVEGARDE_REMPLISSAGE;
            DBMS_OUTPUT.PUT_LINE('L''erreur ' || SQLCODE || 'est survenue. Un rollback a été effectué : ' || SQLERRM(SQLCODE));
END