# Explication fichier "migration_tables_temporaires_vers_tables_finales.sql"

## Objectif du fichier :
Migrer les données des tables temporaires d'import vers les tables finales de la Base Voie dans Oracle 12c.

### 1. Correction des seuils  

cette partie supprime les seuils erronés dans les tables temporaires pour 3 cas de figures :

#### 1.1. Suppression des seuils intersectant les tronçons  
```SQL
DELETE FROM G_BASE_VOIE.TEMP_ILTASEU
WHERE
    idseui IN(
        SELECT
            a.idseui
        FROM
            G_BASE_VOIE.TEMP_ILTASEU a
            INNER JOIN G_BASE_VOIE.TEMP_ILTASIT b ON b.idseui = a.idseui
            INNER JOIN G_BASE_VOIE.TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT d ON d.cnumtrc = c.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI e ON e.ccomvoi = d.ccomvoi
        WHERE
            c.cdvaltro = 'V'
            AND d.cvalide = 'V'
            AND e.cdvalvoi = 'V'
            AND a.nsseui IS NULL
            AND SDO_OVERLAPBDYINTERSECT(a.ora_geometry, c.ora_geometry) = 'TRUE'
    );
COMMIT;
```
#### 1.2. Suppression des seuils en doublons dont la distance par rapport à leur tronçon d'affectation n'est pas la plus petite au sein des doublons. En d'autres termes pour chaque doublon, on ne garde que celui qui est situé le plus près de son tronçon  
```SQL
DELETE FROM G_BASE_VOIE.TEMP_ILTASEU
WHERE
    idseui IN(
        WITH
            C_1 AS(-- Sélection des doublons de numéros et compléments de seuil, côté de la voie et numéro de voie
                SELECT
                    a.nuseui,
                    COUNT(a.idseui),
                    a.cdcote,
                    a.nsseui,
                    e.ccomvoi,
                    MIN(ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                                    SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
                                        SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo),
                                        SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo), a.ora_geometry),
                                        0
                                    ),
                                    a.ora_geometry
                                    ), 2)
                    ) AS distance
                FROM
                    G_BASE_VOIE.TEMP_ILTASEU a
                    INNER JOIN G_BASE_VOIE.TEMP_ILTASIT b ON b.idseui = a.idseui
                    INNER JOIN G_BASE_VOIE.TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc
                    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT d ON d.cnumtrc = c.cnumtrc
                    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI e ON e.ccomvoi = d.ccomvoi,
                    USER_SDO_GEOM_METADATA m
                WHERE
                    c.cdvaltro = 'V'
                    AND d.cvalide = 'V'
                    AND e.cdvalvoi = 'V'
                    AND a.nsseui IS NULL
                    AND m.TABLE_NAME = 'TEMP_ILTATRC'
                GROUP BY
                    a.nuseui,
                    a.cdcote,
                    a.nsseui,
                    e.ccomvoi
                HAVING
                    COUNT(a.nuseui) > 1
                    AND COUNT(e.ccomvoi) > 1
                ORDER BY
                    a.nuseui,
                    a.cdcote,
                    a.nsseui,
                    e.ccomvoi
            )
            
                -- Sélection des identifiants des seuils à supprimer
                SELECT
                    a.idseui
                FROM
                    G_BASE_VOIE.TEMP_ILTASEU a
                    INNER JOIN G_BASE_VOIE.TEMP_ILTASIT b ON b.idseui = a.idseui
                    INNER JOIN G_BASE_VOIE.TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc
                    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT d ON d.cnumtrc = c.cnumtrc
                    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI e ON e.ccomvoi = d.ccomvoi
                    INNER JOIN C_1 f ON f.nuseui = a.nuseui AND f.cdcote = a.cdcote AND f.ccomvoi = e.ccomvoi,
                    USER_SDO_GEOM_METADATA m
                WHERE
                    c.cdvaltro = 'V'
                    AND d.cvalide = 'V'
                    AND e.cdvalvoi = 'V'
                    AND a.nsseui IS NULL
                    AND m.TABLE_NAME = 'TEMP_ILTATRC'
                    AND ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                                    SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
                                        SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo),
                                        SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo), a.ora_geometry),
                                        0
                                    ),
                                    a.ora_geometry
                                ), 2) > f.distance
    );
COMMIT;
```

#### 1.3. Suppression des seuils situés à 1km ou plus de son tronçon d'affectation ;  
```SQL
DELETE FROM G_BASE_VOIE.TEMP_ILTASEU
WHERE
    idseui IN(
        SELECT
            a.idseui
        FROM
            G_BASE_VOIE.TEMP_ILTASEU a
            INNER JOIN G_BASE_VOIE.TEMP_ILTASIT b ON b.idseui = a.idseui
            INNER JOIN G_BASE_VOIE.TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT d ON d.cnumtrc = c.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI e ON e.ccomvoi = d.ccomvoi,
            USER_SDO_GEOM_METADATA m
        WHERE
            c.cdvaltro = 'V'
            AND d.cvalide = 'V'
            AND e.cdvalvoi = 'V'
            AND m.TABLE_NAME = 'TEMP_ILTATRC'
            AND ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                            SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
                                SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo),
                                SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo), a.ora_geometry),
                                0
                            ),
                            a.ora_geometry
                        ), 2) >= 1000
    );
COMMIT;
```
Les seuils en erreurs qui ont été supprimés avaient parfois la même date de création, ce qui correspond à la date d'un import qui aurait créé des doublons.  

#### 1.4. Suppression des relations seuils/tronçons invalides dues à la suppression des seuils ci-dessus
Cette partie permet de supprimer toutes les relations entre les seuils qui ont été supprimés et les tronçons auxquels ils étaient affectés.

### 2. Sélection des métadonnées de la base voie de la MEL afin de créer une valeur par défaut pour le champ fid_metadonnee de TA_TRONCON et TA_VOIE  

Dans le cadre de la coopération avec l'IGN pour mettre à jour notre Base Voie, il faut que nous puissions distinguer les tronçons et les voies issus de nos bases, de ceux issus des bases de l'IGN. Pour ce faire, nous utilisons la table G_GEO.TA_METADONNEE, TA_ORGANISME, TA_SOURCE et TA_PROVENANCE pour y stocker le nom de l'organisme créateur de la donnée, sa source, sa date de création et d'insertion/mise à jour en base (côté MEL), ainsi que la méthode d'acquisition.  
Etant donné que nous ne connaissons pas par avance l'identifiant correspondant à la source "base voie" en production, nous devons récupérer sa valeur, la stocker dans une variable et mettre à jour la valeur par défaut du champ *FID_METADONNEE* des tables *G_BASE_VOIE.TA_TRONCON* et *G_BASE_VOIE.TA_VOIE*.

```SQL
SELECT
        a.objectid
        INTO v_mtd
    FROM
        G_GEO.TA_METADONNEE a
        INNER JOIN G_GEO.TA_SOURCE b ON b.objectid = a.fid_source
        INNER JOIN G_GEO.TA_METADONNEE_RELATION_ORGANISME c ON c.fid_metadonnee = a.objectid
        INNER JOIN G_GEO.TA_ORGANISME d ON d.objectid = c.fid_organisme
    WHERE
        UPPER(d.acronyme) = UPPER('mel')
        AND UPPER(b.nom_source) = UPPER('base voie');

    -- 0.2. Modification des codes DDL de TA_TRONCON et TA_VOIE
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_TRONCON MODIFY FID_METADONNEE NUMBER(38,0) DEFAULT ' || v_mtd;
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_VOIE MODIFY FID_METADONNEE NUMBER(38,0) DEFAULT ' || v_mtd;

```

### 3. Import des données des agents de la base voie + gestionnaires de données  

Il s'agit d'importer les pnoms des agents gestionnaires de la base voie et autres pnoms utiles (entre autre pour la migration) dans la table TA_AGENT depuis la table TEMP_AGENT.

```SQL
INSERT INTO G_BASE_VOIE.TA_AGENT(numero_agent, pnom, validite)
    SELECT numero_agent, pnom, validite FROM TEMP_AGENT;
```

### 4. Insertion du code fantoir dans TEMP_VOIEVOI  
Cette étape est nécessaire pour ensuite pouvoir remplir correctement la table *G_BASE_VOIE.TA_RIVOLI*. On insère dans le champ temporaire *temp_code_fantoir* le code fantoir avec sa clé de contrôle ;

```SQL
EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TEMP_VOIEVOI ADD temp_code_fantoir CHAR(11)';

COMMENT ON COLUMN G_BASE_VOIE.TEMP_VOIEVOI.temp_code_fantoir IS 'Champ temporaire contenant le VRAI code fantoir des voies.';


MERGE INTO G_BASE_VOIE.TEMP_VOIEVOI a
    USING(
        SELECT
            b.ccomvoi,
            CASE
                WHEN LENGTH(b.cnumcom) = 2 THEN '0' || b.cnumcom || b.ccodrvo || c.cle_controle
                WHEN LENGTH(b.cnumcom) = 1 THEN '00' || b.cnumcom || b.ccodrvo || c.cle_controle
            ELSE
                b.cnumcom || b.ccodrvo || c.cle_controle
            END AS code_fantoir_et_cle_ctrl
        FROM
            G_BASE_VOIE.TEMP_VOIEVOI b
            INNER JOIN G_BASE_VOIE.TEMP_CODE_FANTOIR c ON SUBSTR(c.code_fantoir, 4, 7) = (CASE 
                                                                                                WHEN LENGTH(b.cnumcom) = 2 THEN '0' || b.cnumcom || b.ccodrvo
                                                                                                WHEN LENGTH(b.cnumcom) = 1 THEN '00' || b.cnumcom || b.ccodrvo
                                                                                                WHEN LENGTH(b.cnumcom) = 3 THEN b.cnumcom || b.ccodrvo
                                                                                            END
                                                                                            )
            
    )t
    ON (a.ccomvoi = t.ccomvoi)
    WHEN MATCHED THEN
        UPDATE SET a.temp_code_fantoir = t.code_fantoir_et_cle_ctrl;
```

### 5. Insertion des rivolis dans TA_RIVOLI  
Cette étape permet d'insérer le RIVOLI et la clef de contrôle pour tous les codes fantoirs corrects dans la table *TA_RIVOLI* à partir de la table *TEMP_VOIE_VOI* pour le périmètre de la MEL.
Cette insertion se fait en deux temps :  
- 1.Insertion des rivolis et de leur clef de contrôle pour les voies ayant un code fantoir présent dans la liste des codes fantoirs exportée de data.gouv.fr ;
- 2. Insertion des autres rivolis sans leur clef de contrôle. Il s'agit des rivolis pour lesquels nous ne trouvons pas de correspondance dans la liste des codes fantoirs de data.gouv.fr. Cela peut-être dû à la création de rivolis virtuels à la demande d'utilisateur qui ont absolument besoin d'une voie qui n'existe pas (je sais c'est tarabiscoté...) ;

```SQL
    INSERT INTO G_BASE_VOIE.TA_RIVOLI(code_rivoli, cle_controle)
    SELECT DISTINCT
        SUBSTR(temp_code_fantoir, 4, 4) AS rivoli,
        SUBSTR(temp_code_fantoir, 8, 1) AS cle_f
    FROM
        G_BASE_VOIE.TEMP_VOIEVOI
    WHERE
        temp_code_fantoir IS NOT NULL;
        
    -- 6.2. Insertion de tous les autres codes rivoli (sans clé)
    INSERT INTO G_BASE_VOIE.TA_RIVOLI(code_rivoli)
    SELECT DISTINCT
        ccodrvo
    FROM
        G_BASE_VOIE.TEMP_VOIEVOI
    WHERE
        temp_code_fantoir IS NULL;
```

### 7. Import des tronçons dans TA_TRONCON  

En préambule de cet import les triggers *B_IUD_TA_TRONCON_LOG* et *B_IUX_TA_TRONCON_DATE_PNOM* sont désactivés à l'étape 6 (qui ne mérite pas qu'on s'y attarde).

#### 7.1. Les Tronçons Valides  
##### 7.1.1. Import des tronçons valides dans *TA_TRONCON*  
Cette étape est nécessaire pour importer tous les tronçons valides dans leur table en base, mais aussi pour avoir les bons identifiants dans les champs de clé étrangère *fid_pnom_saisie*,*fid_pnom_modification* et *fid_metadonnee*.

```SQL
INSERT INTO G_BASE_VOIE.TA_TRONCON(objectid, geom, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification, fid_metadonnee)
    SELECT
        a.cnumtrc,
        a.ora_geometry,
        a.cdtstrc,
        a.cdtmtrc,
        b.numero_agent AS fid_pnom_saisie,
        b.numero_agent AS fid_pnom_modification,
        c.objectid AS fid_metadonnee
    FROM
        G_BASE_VOIE.TEMP_ILTATRC a,
        G_BASE_VOIE.TA_AGENT b,
        G_GEO.TA_METADONNEE c
        INNER JOIN G_GEO.TA_SOURCE d ON d.objectid = c.fid_source
        INNER JOIN G_GEO.TA_METADONNEE_RELATION_ORGANISME e ON e.fid_metadonnee = c.objectid
        INNER JOIN G_GEO.TA_ORGANISME f ON f.objectid = e.fid_organisme
    WHERE
        a.cdvaltro = 'V'
        AND b.pnom = 'import_donnees'
        AND UPPER(f.acronyme) = UPPER('MEL')
        AND UPPER(d.nom_source) = UPPER('base voie');

```

##### 7.1.2. Import des tronçons valides dans *TA_TRONCON_LOG*  
Cette étape permet d'enregistrer les dates de création et de modification des tronçons non pas dans la table de production, ce qui la surchargerait d'informations, mais dans sa table de log.
```SQL
-- Pour la création
INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(geom, fid_troncon, date_action, fid_type_action, fid_pnom, fid_metadonnee)
    SELECT
        a.geom,
        a.objectid,
        b.cdtstrc,
        e.objectid,
        c.numero_agent,
        a.fid_metadonnee
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid,
        G_BASE_VOIE.TA_AGENT c,
        G_GEO.TA_LIBELLE_LONG d
        INNER JOIN G_GEO.TA_LIBELLE e ON e.fid_libelle_long = d.objectid
    WHERE
        b.cdvaltro = 'V'
        AND c.pnom = 'import_donnees'
        AND UPPER(d.valeur) = UPPER('insertion');

-- Pour l'édition
    INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(geom, fid_troncon, date_action, fid_type_action, fid_pnom, fid_metadonnee)
    SELECT
        a.geom,
        a.objectid,
        b.cdtmtrc,
        e.objectid,
        c.numero_agent,
        a.fid_metadonnee
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid,
        G_BASE_VOIE.TA_AGENT c,
        G_GEO.TA_LIBELLE_LONG d
        INNER JOIN G_GEO.TA_LIBELLE e ON e.fid_libelle_long = d.objectid
    WHERE
        b.cdvaltro = 'V'
        AND c.pnom = 'import_donnees'
        AND UPPER(d.valeur) = UPPER('édition');
```

#### 7.2. Les Tronçons Invalides  
##### 7.2.1. Import des tronçons invalides dans *TA_TRONCON*  
Cette étape est nécessaire pour avoir les bons identifiants dans les champs de clé étrangère *fid_pnom_saisie*,*fid_pnom_modification* et *fid_metadonnee*.

```SQL
INSERT INTO G_BASE_VOIE.TA_TRONCON(objectid, geom, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification, fid_metadonnee)
    SELECT
        a.cnumtrc,
        a.ora_geometry,
        a.cdtstrc,
        a.cdtmtrc,
        b.numero_agent AS fid_pnom_saisie,
        b.numero_agent AS fid_pnom_modification,
        c.objectid AS fid_metadonnee
    FROM
        G_BASE_VOIE.TEMP_ILTATRC a,
        G_BASE_VOIE.TA_AGENT b,
        G_GEO.TA_METADONNEE c
        INNER JOIN G_GEO.TA_SOURCE d ON d.objectid = c.fid_source
        INNER JOIN G_GEO.TA_METADONNEE_RELATION_ORGANISME e ON e.fid_metadonnee = c.objectid
        INNER JOIN G_GEO.TA_ORGANISME f ON f.objectid = e.fid_organisme
    WHERE
        a.cdvaltro = 'F'
        AND b.pnom = 'import_donnees'
        AND UPPER(f.acronyme) = UPPER('MEL')
        AND UPPER(d.nom_source) = UPPER('base voie');
```
##### 7.2.2. Import des tronçons invalides dans *TA_TRONCON_LOG*  
Cette étape permet de conserver l'historique des tronçons de la base (création/édition des tronçons invalides) et de pouvoir, au besoin, remmetre un tronçon en circulation. L'objectif est d'avoir uniquement les tronçons valides dans *TA_TRONCON* (cf.étape 7.2.3) et d'avoir les invalidations uniquement dans la table *TA_TRONCON_LOG*, avec les modifications des tronçons valides.

```SQL
-- Pour la création
INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(geom, fid_troncon, date_action, fid_type_action, fid_pnom, fid_metadonnee)
    SELECT
        a.geom,
        a.objectid,
        b.cdtstrc,
        e.objectid,
        c.numero_agent,
        a.fid_metadonnee
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid,
        G_BASE_VOIE.TA_AGENT c,
        G_GEO.TA_LIBELLE_LONG d
        INNER JOIN G_GEO.TA_LIBELLE e ON e.fid_libelle_long = d.objectid
    WHERE
        b.cdvaltro = 'F'
        AND c.pnom = 'import_donnees'
        AND UPPER(d.valeur) = UPPER('insertion');

-- Pour l'édition
    INSERT INTO G_BASE_VOIE.TA_TRONCON_LOG(geom, fid_troncon, date_action, fid_type_action, fid_pnom, fid_metadonnee)
    SELECT
        a.geom,
        a.objectid,
        b.cdtmtrc,
        e.objectid,
        c.numero_agent,
        a.fid_metadonnee
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_ILTATRC b ON b.cnumtrc = a.objectid,
        G_BASE_VOIE.TA_AGENT c,
        G_GEO.TA_LIBELLE_LONG d
        INNER JOIN G_GEO.TA_LIBELLE e ON e.fid_libelle_long = d.objectid
    WHERE
        b.cdvaltro = 'F'
        AND c.pnom = 'import_donnees'
        AND UPPER(d.valeur) = UPPER('suppression');
```

##### 7.2.3. Suppression des tronçons invalides de la table *TA_TRONCON*  
Afin que la table *TA_TRONCON* ne contienne que les tronçons valides il faut supprimer les tronçons invalides (qui on été transférés dans *TA_TRONCON_LOG* à l'étape précédente).

```SQL
DELETE 
    FROM G_BASE_VOIE.TA_TRONCON a 
    WHERE
        a.objectid IN(
            SELECT
                cnumtrc
            FROM
                G_BASE_VOIE.TEMP_ILTATRC
            WHERE
                cdvaltro = 'F'
        );
```

#### 7.3. Modification du numéro de départ de l'incrémentation du champ TA_TRONCON.objectid
*Objectif :* Faire en sorte que l'incrémentation reparte à partir du MAX(OBJECTID) + 1 afin de ne pas provoquer d'erreur, ni de nécessiter d'intervention manuelle de modification de la clé primaire.  

```SQL
SELECT
        MAX(objectid)+1
        INTO v_nbr_objectid
    FROM
        G_BASE_VOIE.TA_TRONCON;
    
    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_TRONCON MODIFY objectid GENERATED BY DEFAULT AS IDENTITY (START WITH ' || v_nbr_objectid  || ' INCREMENT BY 1)';
```

#### 7.4. Réactivation des triggers pour les tronçons
Réactivation des triggers une fois les imports terminés.

```SQL
EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_TRONCON_LOG ENABLE';
EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_TRONCON_DATE_PNOM ENABLE';
```

### 8. Import des données dans TA_TYPE_VOIE
#### 8.1. Import des types de *TEMP_TYPEVOIE*
On insère dans cette table les types de voie présents dans *TEMP_TYPEVOIE*.

```SQL
INSERT INTO G_BASE_VOIE.TA_TYPE_VOIE(code_type_voie, libelle)
    SELECT
        CCODTVO,
        LITYVOIE
    FROM
        G_BASE_VOIE.TEMP_TYPEVOIE
    WHERE
        LITYVOIE IS NOT NULL;

    INSERT INTO G_BASE_VOIE.TA_TYPE_VOIE(code_type_voie, libelle)
    SELECT
        CCODTVO,
        'Libellé non-renseigné avant la migration'
    FROM
        G_BASE_VOIE.TEMP_TYPEVOIE
    WHERE
        LITYVOIE IS NULL;
```

#### 8.2. Import des types de *TEMP_VOIEVOI* absents de *TEMP_TYPEVOIE*
Il existe des types de voie présents dans *TEMP_VOIEVOI*, mais absents de *TEMP_TYPEVOIE*. Cette absence est due à un changement de méthode de saisie : jusqu'à une certaine date on saisissait les cours d'eau, les ruisseau, rivières, canaux et lignes de voies ferrées, ce qui n'est plus le cas. Suite à ce changement, les types en question ont bien été supprimés de *TYPEVOIE*, mais les voies qu'elles catégorisent n'ont pas été invalidées.
**Jusqu'à nouvel ordre, ces types sont toujours insérés dans TA_TYPE_VOIE**, mais leur suppression est en discussion.

```SQL
INSERT INTO G_BASE_VOIE.TA_TYPE_VOIE(code_type_voie, libelle)
    SELECT DISTINCT
        a.ccodtvo,
        'type de voie présent dans VOIEVOI mais pas dans TYPEVOIE lors de la migration'
    FROM
        TEMP_VOIEVOI a
    WHERE
        a.ccodtvo NOT IN(SELECT code_type_voie FROM TA_TYPE_VOIE);
```

### 9. Import des voies dans TA_VOIE
Avant cet import les triggers *B_IUD_TA_VOIE_LOG* et *B_IUX_TA_VOIE_DATE_PNOM* sont désactivés.

#### 9.1. Correction des champs NULL de la table *TEMP_VOIEVOI*
- 1. Si le champ *GENRE* est NULL, alors la valeur 'NI' (pour non-identifié) est insérée ;
- 2. Si le champ *CNOMINUS* est NULL, alors la valeur 'aucun nom lors de la migration en base' est insérée ;

#### 9.2. Import des voies valides et invalides
Cet import ne distingue pas les voies valides des voies invalides car c'est inutile. En revanche l'import se fait sans le *FID_RIVOLI*.

```SQL
INSERT INTO G_BASE_VOIE.TA_VOIE(FID_TYPEVOIE, OBJECTID, COMPLEMENT_NOM_VOIE, LIBELLE_VOIE, FID_GENRE_VOIE, DATE_SAISIE, DATE_MODIFICATION, FID_PNOM_SAISIE, FID_PNOM_MODIFICATION, FID_METADONNEE)
            WITH C_1 AS(
                SELECT DISTINCT
                    b.objectid AS FID_TYPE_VOIE,
                    a.CCOMVOI AS NUMERO_VOIE,
                    a.CINFOS AS COMPLEMENT_NOM_VOIE,
                    a.CNOMINUS AS LIBELLE,
                    CASE
                        WHEN a.genre = 'M' AND UPPER(d.valeur) = UPPER('masculin') THEN e.objectid
                        WHEN a.genre = 'F' AND UPPER(d.valeur) = UPPER('féminin') THEN e.objectid
                        WHEN a.genre = 'N' AND UPPER(d.valeur) = UPPER('neutre') THEN e.objectid
                        WHEN a.genre = 'C' AND UPPER(d.valeur) = UPPER('couple') THEN e.objectid
                        WHEN a.genre = 'NI' AND UPPER(d.valeur) = UPPER('non-identifié') THEN e.objectid
                        WHEN a.genre IS NULL AND UPPER(d.valeur) = UPPER('non-renseigné') THEN e.objectid
                    END AS GENRE,
                    a.CDTSVOI AS DATE_SAISIE,
                    a.CDTMVOI AS DATE_MODIFICATION,
                    f.numero_agent AS fid_pnom_saisie,
                    f.numero_agent AS fid_pnom_modification,
                    g.objectid AS fid_metadonnee
                FROM
                    G_BASE_VOIE.TEMP_VOIEVOI a
                    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.code_type_voie = a.ccodtvo,
                    G_GEO.TA_LIBELLE_LONG d
                    INNER JOIN G_GEO.TA_LIBELLE e ON e.fid_libelle_long = d.objectid,
                    G_BASE_VOIE.TA_AGENT f,
                    G_GEO.TA_METADONNEE g
                    INNER JOIN G_GEO.TA_SOURCE h ON h.objectid = g.fid_source
                    INNER JOIN G_GEO.TA_METADONNEE_RELATION_ORGANISME i ON i.fid_metadonnee = g.objectid
                    INNER JOIN G_GEO.TA_ORGANISME j ON j.objectid = i.fid_organisme
                WHERE
                    a.ccomvoi IS NOT NULL 
                    AND f.pnom = 'import_donnees'
                    AND UPPER(j.acronyme) = UPPER('MEL')
                    AND UPPER(h.nom_source) = UPPER('base voie')
                )
            SELECT *
            FROM
                C_1
            WHERE
                GENRE IS NOT NULL;
```

#### 9.3. Mise à jour de la clé étrangère TA_VOIE.FID_RIVOLI pour les voies  

Cette étape est nécessaire puisque les codes fantoirs ne sont pas enregistrés dans *TA_VOIE*, mais dans *TA_RIVOLI*.

##### 9.3.1. Pour les voies dont le code fantoir ne dispose pas de clé de contrôle
Nous conservons les voies dont le code fantoir n'est pas complet puisqu'elles peuvent être utilisées malgré tout.

```SQL
MERGE INTO G_BASE_VOIE.TA_VOIE a
    USING(
        SELECT
            b.ccomvoi,
            a.objectid
        FROM
            G_BASE_VOIE.TA_RIVOLI a
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccodrvo = a.code_rivoli
        WHERE
            a.cle_controle IS NULL
            AND b.temp_code_fantoir IS NULL
    )t
    ON (a.objectid = t.ccomvoi)
    WHEN MATCHED THEN
    UPDATE SET a.fid_rivoli = t.objectid;
```

##### 9.3.2. Pour les voies disposant d'un code fantoir complet

```SQL
MERGE INTO G_BASE_VOIE.TA_VOIE a
    USING(
        SELECT
            b.ccomvoi,
            a.objectid
        FROM
            G_BASE_VOIE.TA_RIVOLI a
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON SUBSTR(b.temp_code_fantoir, 4, 5) = a.code_rivoli || a.cle_controle
        WHERE
            a.cle_controle IS NOT NULL
            AND b.temp_code_fantoir IS NOT NULL
    )t
    ON (a.objectid = t.ccomvoi)
    WHEN MATCHED THEN
    UPDATE SET a.fid_rivoli = t.objectid;
```

#### 9.4. Import dans la table TA_VOIE_LOG des données de TA_VOIE
##### 9.4.1. Pour la création des voies valides ET invalides
Cela nous permet de savoir quand les voies ont été créées.

```SQL
MERGE INTO G_BASE_VOIE.TA_VOIE_LOG a
    USING(
        SELECT DISTINCT
            a.objectid,
            a.libelle_voie,
            a.complement_nom_voie,
            a.fid_typevoie,
            a.fid_genre_voie,
            a.fid_rivoli,
            a.date_saisie AS DATE_ACTION,
            d.objectid AS fid_type_action,
            e.numero_agent AS fid_pnom,
            a.fid_metadonnee
        FROM
            G_BASE_VOIE.TA_VOIE a
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccomvoi = a.objectid,
            G_GEO.TA_LIBELLE_LONG c
            INNER JOIN G_GEO.TA_LIBELLE d ON d.fid_libelle_long = c.objectid,
            G_BASE_VOIE.TA_AGENT e                  
        WHERE
            UPPER(c.valeur) = UPPER('insertion')
            AND e.pnom = 'import_donnees'
    )t
    ON (a.fid_voie = t.objectid)
    WHEN NOT MATCHED THEN
        INSERT(a.libelle_voie, a.complement_nom_voie, a.date_action, a.fid_typevoie, a.fid_genre_voie, a.fid_rivoli, a.fid_voie, a.fid_type_action, a.fid_pnom, a.fid_metadonnee)
        VALUES(t.libelle_voie, t.complement_nom_voie, t.date_action, t.fid_typevoie, t.fid_genre_voie, t.fid_rivoli, t.objectid, t.fid_type_action, t.fid_pnom, t.fid_metadonnee);
```

##### 9.4.2. Pour la modification des voies valides

Cela nous permet de savoir quand les voies valides ont été modifiées.

```SQL
MERGE INTO G_BASE_VOIE.TA_VOIE_LOG a
    USING(
        SELECT DISTINCT
            a.objectid,
            a.libelle_voie,
            a.complement_nom_voie,
            a.fid_typevoie,
            a.fid_genre_voie,
            a.fid_rivoli,
            a.date_modification AS DATE_ACTION,
            d.objectid AS fid_type_action,
            e.numero_agent AS fid_pnom,
            a.fid_metadonnee
        FROM
            G_BASE_VOIE.TA_VOIE a
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccomvoi = a.objectid,
            G_GEO.TA_LIBELLE_LONG c
            INNER JOIN G_GEO.TA_LIBELLE d ON d.fid_libelle_long = c.objectid,
            G_BASE_VOIE.TA_AGENT e                 
        WHERE
            UPPER(c.valeur) = UPPER('édition')
            AND e.pnom = 'import_donnees'
            AND b.cdvalvoi = 'V'
            AND TRIM(b.ccodtvo) NOT IN('LIG', 'CAN', 'RUS')
    )t
    ON (t.fid_type_action <> (SELECT a.objectid FROM G_GEO.TA_LIBELLE a INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long WHERE UPPER(b.valeur) = UPPER('édition')))
    WHEN NOT MATCHED THEN
        INSERT(a.libelle_voie, a.complement_nom_voie, a.date_action, a.fid_typevoie, a.fid_genre_voie, a.fid_rivoli, a.fid_voie, a.fid_type_action, a.fid_pnom, a.fid_metadonnee)
        VALUES(t.libelle_voie, t.complement_nom_voie, t.date_action, t.fid_typevoie, t.fid_genre_voie, t.fid_rivoli, t.objectid, t.fid_type_action, t.fid_pnom, t.fid_metadonnee);
```

##### 9.4.3. Pour la suppression des voies invalides
cela nous permet de savoir quand les voies ont été invalidées, sans parasiter la table de production.

```SQL
MERGE INTO G_BASE_VOIE.TA_VOIE_LOG a
    USING(
        SELECT DISTINCT
            a.objectid,
            a.libelle_voie,
            a.complement_nom_voie,
            a.fid_typevoie,
            a.fid_genre_voie,
            a.fid_rivoli,
            a.date_modification AS DATE_ACTION,
            d.objectid AS fid_type_action,
            e.numero_agent AS fid_pnom,
            a.fid_metadonnee
        FROM
            G_BASE_VOIE.TA_VOIE a
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccomvoi = a.objectid,
            G_GEO.TA_LIBELLE_LONG c
            INNER JOIN G_GEO.TA_LIBELLE d ON d.fid_libelle_long = c.objectid,
            G_BASE_VOIE.TA_AGENT e                  
        WHERE
            UPPER(c.valeur) = UPPER('suppression')
            AND e.pnom = 'import_donnees'
            AND b.cdvalvoi = 'I'
    )t
    ON (t.fid_type_action <> (SELECT a.objectid FROM G_GEO.TA_LIBELLE a INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long WHERE UPPER(b.valeur) = UPPER('suppression')))
    WHEN NOT MATCHED THEN
        INSERT(a.libelle_voie, a.complement_nom_voie, a.date_action, a.fid_typevoie, a.fid_genre_voie, a.fid_rivoli, a.fid_voie, a.fid_type_action, a.fid_pnom, a.fid_metadonnee)
        VALUES(t.libelle_voie, t.complement_nom_voie, t.date_action, t.fid_typevoie, t.fid_genre_voie, t.fid_rivoli, t.objectid, t.fid_type_action, t.fid_pnom, t.fid_metadonnee);

```

##### 9.4.4. Pour la suppression des voies de type foie ferrée, canal et ruisseau
Ces types de voies ne sont plus saisis. Nous les conservons dans la table de log, mais les supprimons de la table de production.

```SQL
MERGE INTO G_BASE_VOIE.TA_VOIE_LOG a
    USING(
        SELECT DISTINCT
            a.objectid,
            a.libelle_voie,
            a.complement_nom_voie,
            a.fid_typevoie,
            a.fid_genre_voie,
            a.fid_rivoli,
            sysdate AS DATE_ACTION,
            d.objectid AS fid_type_action,
            e.numero_agent AS fid_pnom,
            a.fid_metadonnee
        FROM
            G_BASE_VOIE.TA_VOIE a
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI b ON b.ccomvoi = a.objectid,
            G_GEO.TA_LIBELLE_LONG c
            INNER JOIN G_GEO.TA_LIBELLE d ON d.fid_libelle_long = c.objectid,
            G_BASE_VOIE.TA_AGENT e                  
        WHERE
            UPPER(c.valeur) = UPPER('suppression')
            AND e.pnom = 'import_donnees'
            AND TRIM(b.ccodtvo) IN('LIG', 'CAN', 'RUS')
    )t
    ON (t.fid_type_action <> (SELECT a.objectid FROM G_GEO.TA_LIBELLE a INNER JOIN G_GEO.TA_LIBELLE_LONG b ON b.objectid = a.fid_libelle_long WHERE UPPER(b.valeur) = UPPER('suppression')))
    WHEN NOT MATCHED THEN
        INSERT(a.libelle_voie, a.complement_nom_voie, a.date_action, a.fid_typevoie, a.fid_genre_voie, a.fid_rivoli, a.fid_voie, a.fid_type_action, a.fid_pnom, a.fid_metadonnee)
        VALUES(t.libelle_voie, t.complement_nom_voie, t.date_action, t.fid_typevoie, t.fid_genre_voie, t.fid_rivoli, t.objectid, t.fid_type_action, t.fid_pnom, t.fid_metadonnee);
```

A la fin du traitement des voies, les triggers *B_IUD_TA_VOIE_LOG* et *B_IUX_TA_VOIE_DATE_PNOM* sont réactivés.

### 10. Import des relations tronçon/voie dans *TA_RELATION_TRONCON_VOIE*
En préambule, le trigger *B_IUD_TA_RELATION_TRONCON_VOIE_LOG* est désactivé et les contraintes de clé étrangère des champs FID_TRONCON et FID_VOIE sont désactivées.

#### 10.1. Import des relations tronçon/voie invalides dans TA_RELATION_TRONCON_VOIE
Etant donné que nous avons conservé les tronçons et voies invalides, nous conservons également leur relation.
```SQL
INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE(FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON, DATE_SAISIE, DATE_MODIFICATION, FID_PNOM_SAISIE, FID_PNOM_MODIFICATION) 
        SELECT
            a.cnumtrc,
            a.ccomvoi,
            a.ccodstr,
            a.cnumtrv,
            a.cdtscvt,
            a.cdtmcvt,
            h.numero_agent AS fid_pnom_saisie,
            h.numero_agent AS fid_pnom_modification
        FROM
            G_BASE_VOIE.TEMP_VOIECVT a,       
            G_BASE_VOIE.TA_AGENT h
        WHERE
            a.CVALIDE = 'I'
            AND h.pnom = 'import_donnees';
```

#### 10.2. Import des relations tronçons/voies invalides dans *TA_RELATION_TRONCON_VOIE_LOG* pour la création et la modification  
Le fait d'insérer directement les voies invalides dans la table de log permet une requête plus simple quand il s'agit de les enlever de la table de production (il suffit de vider la table complètement).

```SQL
-- Pour la création
INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG(FID_RELATION_TRONCON_VOIE, FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON, DATE_ACTION, FID_TYPE_ACTION, FID_PNOM) 
        SELECT
            a.objectid,
            a.fid_troncon,
            a.fid_voie,
            a.sens,
            a.ordre_troncon,
            a.date_saisie AS date_action,
            e.objectid AS fid_type_action,
            f.numero_agent AS fid_pnom
        FROM
            G_BASE_VOIE.TA_RELATION_TRONCON_VOIE a,
            G_GEO.TA_LIBELLE_LONG d
            INNER JOIN G_GEO.TA_LIBELLE e ON e.fid_libelle_long = d.objectid,
            G_BASE_VOIE.TA_AGENT f
        WHERE
            UPPER(d.valeur) = UPPER('insertion')
            AND f.pnom = 'import_donnees';
            
-- Pour la modification
    INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG(FID_RELATION_TRONCON_VOIE, FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON, DATE_ACTION, FID_TYPE_ACTION, FID_PNOM) 
        SELECT DISTINCT
            a.objectid,
            a.fid_troncon,
            a.fid_voie,
            a.sens,
            a.ordre_troncon,
            a.date_modification AS date_action,
            e.objectid AS fid_type_action,
            f.numero_agent AS fid_pnom
        FROM
            G_BASE_VOIE.TA_RELATION_TRONCON_VOIE a,
            G_GEO.TA_LIBELLE_LONG d
            INNER JOIN G_GEO.TA_LIBELLE e ON e.fid_libelle_long = d.objectid,
            G_BASE_VOIE.TA_AGENT f
        WHERE
            UPPER(d.valeur) = UPPER('suppression')
            AND f.pnom = 'import_donnees';
```

Suppression des relations tronçons/voies invalides de la table *TA_RELATION_TRONCON_VOIE*

#### 10.3. Import des relations tronçons/voies valides dans la table *TA_RELATION_TRONCON_VOIE*
Cette table fait le lien entre les tronçons et la voie qui leur est affectée. En théorie, un tronçon est toujours affecté à une et une seule voie, mais pas toujours... Nous avons des tronçons affectés à plusieurs voies et comme aucune solution de correction n'a été trouvée pour le moment, nous remplissons cette table pivot.

```SQL
INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE(FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON, DATE_SAISIE, DATE_MODIFICATION, FID_PNOM_SAISIE, FID_PNOM_MODIFICATION)
    SELECT
        a.objectid AS fid_troncon,
        c.objectid AS fid_voie,
        b.CCODSTR AS sens,
        b.CNUMTRV AS ordre_troncon,
        b.cdtscvt AS date_saisie,
        b.cdtmcvt AS date_modification,
        d.numero_agent AS fid_pnom_saisie,
        d.numero_agent AS fid_pnom_modification
    FROM
        G_BASE_VOIE.TA_TRONCON a
        INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.objectid
        INNER JOIN G_BASE_VOIE.TA_VOIE c ON c.objectid = b.ccomvoi,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        b.CVALIDE = 'V'
        AND d.pnom = 'import_donnees';
```

#### 10.4. Import des relations tronçons/voies valides dans *TA_RELATION_TRONCON_VOIE_LOG* pour la création et la modification
Cette table de log nous permet de séparer les voies de leur date de création/modification, afin de ne pas perturber les utilisateurs avec cette information dans la table de production qui est traitée automatiquement dans la table de log.

```SQL
-- Pour la création
INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG(FID_RELATION_TRONCON_VOIE, FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON, DATE_ACTION, FID_TYPE_ACTION, FID_PNOM)
    SELECT
        a.objectid AS fid_relation_troncon_voie,
        a.fid_troncon,
        a.fid_voie,
        a.sens,
        a.ordre_troncon,
        a.date_saisie,
        f.objectid AS fid_type_action,
        g.numero_agent AS fid_pnom
    FROM
        G_BASE_VOIE.TA_RELATION_TRONCON_VOIE a,
        G_GEO.TA_LIBELLE_LONG e
        INNER JOIN G_GEO.TA_LIBELLE f ON f.fid_libelle_long = e.objectid,
        G_BASE_VOIE.TA_AGENT g
    WHERE
        g.pnom = 'import_donnees'
        AND UPPER(e.valeur) = UPPER('insertion');

-- Pour la modification
    INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_VOIE_LOG(FID_RELATION_TRONCON_VOIE, FID_TRONCON, FID_VOIE, SENS, ORDRE_TRONCON, DATE_ACTION, FID_TYPE_ACTION, FID_PNOM)
    SELECT
        a.objectid AS fid_relation_troncon_voie,
        a.fid_troncon,
        a.fid_voie,
        a.sens,
        a.ordre_troncon,
        a.date_modification,
        c.objectid AS fid_type_action,
        d.numero_agent AS fid_pnom
    FROM
        G_BASE_VOIE.TA_RELATION_TRONCON_VOIE a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('édition');
``` 

Réactivation du trigger *B_IUD_TA_RELATION_TRONCON_VOIE_LOG* est désactivé et des contraintes de clé étrangère des champs FID_TRONCON et FID_VOIE.

### 11. Insertion des seuils  
En préambule, les triggers *B_IUD_TA_SEUIL_LOG*, *B_IUD_TA_INFOS_SEUIL_LOG*, *B_IUX_TA_INFOS_SEUIL_DATE_PNOM* sont désactivés. En effet, même si dans un premier temps, nous faison la fusion des seuils situés à 50 cm les uns des autres, on ne créé pas de nouvelles données. On se contente de modifier l'existante.

#### 11.1. Insertion des seuils partageant le même point géométrique
La séparation des informations des seuils et de leur point géométrique est nécessaire, car plusieurs seuils peuvent se situer dans le même bâtiment et donc avoir le même point géométrique. Cependant, comme cette distinction n'est pas faite dans la base originelle, nous devons faire des requêtes spécifiques à ces seuils. En conséquence, le trigger *B_IUX_TA_SEUIL_DATE_PNOM* n'est pas désactivé, car cela nous indique à partir de quel moment certains seuils ont commencé à partager le même point géométrique.

##### 11.1.1 Insertion des géométries des seuils dans la table *TA_SEUIL*

```SQL
INSERT INTO G_BASE_VOIE.TA_SEUIL(geom)
SELECT
    a.ora_geometry
FROM
    G_BASE_VOIE.TEMP_FUSION_SEUIL a;
```

##### 11.1.2. Insertion des informations des seuils
Il doit toujours y avoir plus d'entités insérées dans la table *TA_INFOS_SEUIL* que dans *TA_SEUIL*.

```SQL
INSERT INTO G_BASE_VOIE.TA_INFOS_SEUIL(objectid, numero_seuil, numero_parcelle, complement_numero_seuil, fid_seuil, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification)
    SELECT
        a.idseui,
        a.nuseui,
        CASE
            WHEN a.nparcelle IS NOT NULL THEN a.nparcelle
            WHEN a.nparcelle IS NULL THEN 'NR'
        END AS numero_parcelle,
        a.nsseui,
        b.objectid,
        a.cdtsseuil,
        a.cdtmseuil,
        c.numero_agent AS fid_pnom_saisie,
        c.numero_agent AS fid_pnom_modification
    FROM
        G_BASE_VOIE.TEMP_ILTASEU a,
        G_BASE_VOIE.TA_SEUIL b,
        G_BASE_VOIE.TA_AGENT c
    WHERE
        SDO_WITHIN_DISTANCE(b.geom, a.ora_geometry, 'DISTANCE=0.50') = 'TRUE'
        AND c.pnom = 'import_donnees';
```

#### 11.2. Insertion des seuils non concernés par la fusion précédente
En préambule, le trigger *B_IUX_TA_SEUIL_DATE_PNOM* est désactivé.

##### 11.2.1. Insertion des géométries des seuils

```SQL
MERGE INTO G_BASE_VOIE.TA_SEUIL a
    USING(
        SELECT
            a.ora_geometry,
            a.cdtsseuil,
            a.cdtmseuil,
            b.numero_agent AS fid_pnom_saisie,
            b.numero_agent AS fid_pnom_modification,
            a.idseui
        FROM
            G_BASE_VOIE.TEMP_ILTASEU a,
            G_BASE_VOIE.TA_AGENT b
        WHERE
            a.idseui NOT IN(SELECT objectid FROM G_BASE_VOIE.TA_INFOS_SEUIL)
            AND b.pnom = 'import_donnees'                
    )t
    ON (a.temp_idseui = t.idseui)
    WHEN NOT MATCHED THEN
        INSERT(a.geom, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.temp_idseui)
        VALUES(t.ora_geometry, t.cdtsseuil, t.cdtmseuil, t.fid_pnom_saisie, t.fid_pnom_modification, t.idseui);
```

##### 11.2.2. Insertion des informations des seuils

```SQL
INSERT INTO G_BASE_VOIE.TA_INFOS_SEUIL(objectid, numero_seuil, numero_parcelle, complement_numero_seuil, fid_seuil, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification)
        SELECT DISTINCT
            a.idseui,
            a.nuseui,
            CASE
                WHEN a.nparcelle IS NOT NULL THEN a.nparcelle
                WHEN a.nparcelle IS NULL THEN 'NR'
            END AS numero_parcelle,
            a.nsseui,
            b.objectid,
            a.cdtsseuil,
            a.cdtmseuil,
            c.numero_agent AS fid_pnom_saisie,
            c.numero_agent AS fid_pnom_modification
        FROM
            G_BASE_VOIE.TEMP_ILTASEU a
            INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.temp_idseui = a.idseui,
            G_BASE_VOIE.TA_AGENT c
        WHERE
            c.pnom = 'import_donnees';
```

### 12. Import des relation tronçons - seuils dans TA_RELATION_TRONCON_SEUIL

```SQL
INSERT INTO G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL(fid_seuil, fid_troncon)
    SELECT DISTINCT
        a.objectid AS fid_seuil,
        d.objectid AS fid_troncon
    FROM
        G_BASE_VOIE.TA_SEUIL a
        INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL b ON b.fid_seuil = a.objectid
        INNER JOIN G_BASE_VOIE.TEMP_ILTASIT c ON c.idseui = b.objectid
        INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = c.cnumtrc;
```

Suppression du champ temporaire *TEMP_IDSEUI* de la table *TA_SEUIL*.

### 13. Insertion des points d'intérêt
En préambule, les triggers *B_IUD_TA_POINT_INTERET_LOG*, *B_IUX_TA_POINT_INTERET_DATE_PNOM*, *B_IUD_TA_INFOS_POINT_INTERET_LOG*, *B_IUX_TA_INFOS_POINT_INTERET_DATE_PNOM* sont désactivés.  
Par ailleurs, il est à noter que nous n'insérons que les mairies, mairies annexes et mairies de quartier.

#### 13.1. Import des données invalides dans les tables *TA_POINT_INTERET*, *TA_INFOS_POINT_INTERET* et leur tables de log
Nous conservons toujours l'historiques des points d'intérêt.

```SQL
INSERT INTO G_BASE_VOIE.TA_POINT_INTERET(geom, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification, temp_idpoi)
    SELECT
        a.ora_geometry,
        a.cdtslpu,
        a.cdtmlpu,
        c.numero_agent AS fid_pnom_saisie,
        c.numero_agent AS fid_pnom_modification,
        a.cnumlpu
    FROM
        G_BASE_VOIE.TEMP_ILTALPU a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON UPPER(b.valeur) = UPPER(a.libelle_court),
        G_BASE_VOIE.TA_AGENT c
    WHERE
        UPPER(b.valeur) IN(UPPER('mairie'), UPPER('mairie annexe'), UPPER('mairie quartier'))
        AND c.numero_agent = 99999
        AND a.cdvallpu = 'I';
```

#### 13.2. Import des POI invalides dans TA_POINT_INTERET_LOG pour la création et la modification
*Objectif :* ne pas perturber les utilisateurs avec des informations qui ne les intéressent pas (mais qui intéressent beaucoup les gestionnaires de données).

```SQL
INSERT INTO G_BASE_VOIE.TA_POINT_INTERET_LOG(GEOM, CODE_INSEE, DATE_ACTION, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.geom,
        GET_CODE_INSEE_CONTAIN_POINT('TA_POINT_INTERET', a.geom) AS code_insee,
        a.date_saisie,
        a.objectid AS fid_point_interet,
        c.objectid AS fid_type_action,
        d.numero_agent
    FROM
        G_BASE_VOIE.TA_POINT_INTERET a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('insertion');

    -- Import des POI invalides dans TA_POINT_INTERET_LOG pour la suppression
    INSERT INTO G_BASE_VOIE.TA_POINT_INTERET_LOG(GEOM, CODE_INSEE, DATE_ACTION, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.geom,
        GET_CODE_INSEE_CONTAIN_POINT('TA_POINT_INTERET', a.geom) AS code_insee,
        a.date_modification,
        a.objectid AS fid_point_interet,
        c.objectid AS fid_type_action,
        d.numero_agent
    FROM
        G_BASE_VOIE.TA_POINT_INTERET a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('suppression');

     -- Insertion des informations des point d'intérêts invalides   
    INSERT INTO G_BASE_VOIE.TA_INFOS_POINT_INTERET(objectid, nom, complement_infos, date_saisie, date_modification, fid_libelle, fid_point_interet, fid_pnom_saisie, fid_pnom_modification)
        SELECT
            a.cnumlpu,
            a.cliblpu,
            a.cinfos,
            a.cdtslpu,
            a.cdtmlpu,
            d.objectid AS fid_libelle,
            b.objectid AS fid_point_interet,
            e.numero_agent AS fid_pnom_saisie,
            e.numero_agent AS fid_pnom_modification
        FROM
            G_BASE_VOIE.TEMP_ILTALPU a
            INNER JOIN G_BASE_VOIE.TA_POINT_INTERET b ON b.temp_idpoi = a.cnumlpu
            INNER JOIN G_GEO.TA_LIBELLE_LONG c ON UPPER(c.valeur) = UPPER(a.libelle_court)
            INNER JOIN G_GEO.TA_LIBELLE d ON d.fid_libelle_long = c.objectid,
            G_BASE_VOIE.TA_AGENT e
        WHERE
            UPPER(c.valeur) IN(UPPER('mairie'), UPPER('mairie annexe'), UPPER('mairie quartier'))
            AND e.numero_agent = 99999
            AND a.cdvallpu = 'I';
        
    -- Import des POI invalides dans TA_INFOS_POINT_INTERET_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG(NOM, COMPLEMENT_INFOS, DATE_ACTION, FID_INFOS_POINT_INTERET, FID_LIBELLE, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.nom,
        a.complement_infos,
        a.date_saisie,
        a.objectid AS fid_infos_point_interet,
        a.fid_libelle,
        a.fid_point_interet,
        c.objectid AS fid_type_action,
        d.numero_agent
    FROM
        G_BASE_VOIE.TA_INFOS_POINT_INTERET a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('insertion');

    -- Import des POI invalides dans TA_INFOS_POINT_INTERET_LOG pour la suppression
    INSERT INTO G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG(NOM, COMPLEMENT_INFOS, DATE_ACTION, FID_INFOS_POINT_INTERET, FID_LIBELLE, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.nom,
        a.complement_infos,
        a.date_modification,
        a.objectid AS fid_infos_point_interet,
        a.fid_libelle,
        a.fid_point_interet,
        c.objectid AS fid_type_action,
        d.numero_agent
    FROM
        G_BASE_VOIE.TA_INFOS_POINT_INTERET a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('suppression');
```

#### 13.3. Import des données valides dans les tables *TA_POINT_INTERET*, *TA_INFOS_POINT_INTERET* et leur tables de log

```SQL
INSERT INTO G_BASE_VOIE.TA_POINT_INTERET(geom, date_saisie, date_modification, fid_pnom_saisie, fid_pnom_modification, temp_idpoi)
    SELECT
        a.ora_geometry,
        a.cdtslpu,
        a.cdtmlpu,
        c.numero_agent AS fid_pnom_saisie,
        c.numero_agent AS fid_pnom_modification,
        a.cnumlpu
    FROM
        G_BASE_VOIE.TEMP_ILTALPU a
        INNER JOIN G_GEO.TA_LIBELLE_LONG b ON UPPER(b.valeur) = UPPER(a.libelle_court),
        G_BASE_VOIE.TA_AGENT c
    WHERE
        UPPER(b.valeur) IN(UPPER('mairie'), UPPER('mairie annexe'), UPPER('mairie quartier'))
        AND c.numero_agent = 99999
        AND a.cdvallpu = 'V';

    -- Import des POI valides dans TA_POINT_INTERET_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_POINT_INTERET_LOG(GEOM, CODE_INSEE, DATE_ACTION, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.geom,
        GET_CODE_INSEE_CONTAIN_POINT('TA_POINT_INTERET', a.geom) AS code_insee,
        a.date_saisie,
        a.objectid AS fid_point_interet,
        c.objectid AS fid_type_action,
        d.numero_agent
    FROM
        G_BASE_VOIE.TA_POINT_INTERET a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('insertion');

    -- Import des POI valides dans TA_POINT_INTERET_LOG pour la modification
    INSERT INTO G_BASE_VOIE.TA_POINT_INTERET_LOG(GEOM, CODE_INSEE, DATE_ACTION, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)    
    SELECT
        a.geom,
        GET_CODE_INSEE_CONTAIN_POINT('TA_POINT_INTERET', a.geom) AS code_insee,
        a.date_modification,
        a.objectid AS fid_point_interet,
        c.objectid AS fid_type_action,
        d.numero_agent
    FROM
        G_BASE_VOIE.TA_POINT_INTERET a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('édition');
              
    -- Insertion des informations des point d'intérêts valides   
    INSERT INTO G_BASE_VOIE.TA_INFOS_POINT_INTERET(objectid, nom, complement_infos, date_saisie, date_modification, fid_libelle, fid_point_interet, fid_pnom_saisie, fid_pnom_modification)
        SELECT
            a.cnumlpu,
            a.cliblpu,
            a.cinfos,
            a.cdtslpu,
            a.cdtmlpu,
            d.objectid AS fid_libelle,
            b.objectid AS fid_point_interet,
            e.numero_agent AS fid_pnom_saisie,
            e.numero_agent AS fid_pnom_modification
        FROM
            G_BASE_VOIE.TEMP_ILTALPU a
            INNER JOIN G_BASE_VOIE.TA_POINT_INTERET b ON b.temp_idpoi = a.cnumlpu
            INNER JOIN G_GEO.TA_LIBELLE_LONG c ON UPPER(c.valeur) = UPPER(a.libelle_court)
            INNER JOIN G_GEO.TA_LIBELLE d ON d.fid_libelle_long = c.objectid,
            G_BASE_VOIE.TA_AGENT e
        WHERE
            UPPER(c.valeur) IN(UPPER('mairie'), UPPER('mairie annexe'), UPPER('mairie quartier'))
            AND e.numero_agent = 99999
            AND a.cdvallpu = 'V';
            
    -- Import des POI valides dans TA_INFOS_POINT_INTERET_LOG pour la création
    INSERT INTO G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG(NOM, COMPLEMENT_INFOS, DATE_ACTION, FID_INFOS_POINT_INTERET, FID_LIBELLE, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.nom,
        a.complement_infos,
        a.date_saisie,
        a.objectid AS fid_infos_point_interet,
        a.fid_libelle,
        a.fid_point_interet,
        c.objectid AS fid_type_action,
        d.numero_agent
    FROM
        G_BASE_VOIE.TA_INFOS_POINT_INTERET a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('insertion');

    -- Import des POI invalides dans TA_INFOS_POINT_INTERET_LOG pour la modification
    INSERT INTO G_BASE_VOIE.TA_INFOS_POINT_INTERET_LOG(NOM, COMPLEMENT_INFOS, DATE_ACTION, FID_INFOS_POINT_INTERET, FID_LIBELLE, FID_POINT_INTERET, FID_TYPE_ACTION, FID_PNOM)       
    SELECT
        a.nom,
        a.complement_infos,
        a.date_modification,
        a.objectid AS fid_infos_point_interet,
        a.fid_libelle,
        a.fid_point_interet,
        c.objectid AS fid_type_action,
        d.numero_agent
    FROM
        G_BASE_VOIE.TA_INFOS_POINT_INTERET a,
        G_GEO.TA_LIBELLE_LONG b
        INNER JOIN G_GEO.TA_LIBELLE c ON c.fid_libelle_long = b.objectid,
        G_BASE_VOIE.TA_AGENT d
    WHERE
        d.pnom = 'import_donnees'
        AND UPPER(b.valeur) = UPPER('édition');
```

### 14. Réactivation de tous les triggers et des contraintes

```SQL
EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_POINT_INTERET_LOG ENABLE';
EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_TRONCON_LOG ENABLE';
EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_SEUIL_LOG ENABLE';
EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_SEUIL_DATE_PNOM ENABLE';
EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_INFOS_SEUIL_LOG ENABLE';
EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_INFOS_SEUIL_DATE_PNOM ENABLE';
EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_POINT_INTERET_DATE_PNOM ENABLE';
EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUD_TA_INFOS_POINT_INTERET_LOG ENABLE';
EXECUTE IMMEDIATE 'ALTER TRIGGER B_IUX_TA_INFOS_POINT_INTERET_DATE_PNOM ENABLE';
EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_POINT_INTERET DROP COLUMN TEMP_IDPOI'

SELECT
        CONSTRAINT_NAME
        INTO v_contrainte
    FROM
        USER_CONSTRAINTS
    WHERE
        TABLE_NAME = 'TA_TYPE_VOIE'
        AND CONSTRAINT_TYPE = 'C'
        AND SEARCH_CONDITION_VC LIKE '%LIBELLE%';

    EXECUTE IMMEDIATE 'ALTER TABLE G_BASE_VOIE.TA_TYPE_VOIE ENABLE CONSTRAINT ' || v_contrainte;
    
```