# Fiche méthodologique de création du jeu de données LITTERALIS

## Contexte :
Afin de créer des arrêtés automatiquement lors de travaux d'aménagement, le service voirie travaille avec le prestataire Sogelink sur l'application LITTERALIS.
Cette application doit notamment permettre d'affecter les bonnes adresses aux bons arrêtés et d'affecter ces arrêtés aux bonnes équipes sur le terrain.

## Objectif : 
Livrer un jeu de données respectant le cahier des charges de Sogelink. Pour plus d'informations, veuillez vous référer à la documentation.

## Livrables :
- TRONCON : table faisant le lien entre les tronçons, les voies auxquelles elles sont affectées et leur commune ;
- ADR : table regroupant les seuils et les voies auxquelles ils sont rattachés ;
- REGROUPEMENT : table des zones administratives permettant la répartition des arrêtés entre les différentes équipes gèrant le territoire de la MEL ;
- COMMUNE : table de toutes les communes de la MEL ;

## Sommaire :
1. Correction des données implémentée dans la migration de la base ;
2. Création de la table TA_VOIE_LITTERALIS respectant la règle "une voie unique par commune" ;
3. Création de trois vues matérialisées pour les **tronçons** et pour les **adresses** ;
4. Création des deux vues matérialisées d'export des **tronçons** et des **adresses** ;
5. Création des vues matérialisées regroupant les zones administratives des **regroupements** ;
6. Création de la vue matérialisée d'export des **regroupements** ;

## 1. Correction des données implémentée dans la migration de la base  

Ce projet nous a permis d'identifier de nombreuses erreurs dans la base voie et de mettre en place des correctifs qui ont été ajoutés au fur et à mesure dans le code de migration de la base voie d'oracle 11g vers oracle 12c. Ces correctifs se trouvent dans la première partie du fichier de migration des tables temporaires vers les tables finales de la base voie ![migration_tables_temporaires_vers_tables_finales.sql](../../sql/scripts/code_ddl_g_base_voie/integration/migration_tables_temporaires_vers_tables_finales.sql) (pour plus d'information sur cette étape, veuillez vous référer au fichier ![methodologie_migration_base_voie.md](../migration/methodologie_migration_base_voie.md)).

### 1.1. Suppression des seuils intersectant les tronçons qui leur sont affectés

Normalement les seuils sont placés géographiquement au niveau de la porte d'entrée des bâtiments. Les intersections des seuils et des tronçons résultent soit d'une erreur de saisie, soit d'un problème lors de la migration de la base dans oracle 11g.  
Dans tous les ces seuils ne respectent pas la règle de saisie, il faut donc les supprimer.

```SQL
-- 1.1. Suppression des seuils intersectant les tronçons
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

### 1.2. Suppression des seuils en doublons de numéro de seuils, complément de seuil, voie et commune dont la distance par rapport à leur tronçon est la plus grande au sein des doublons

La présence de ces doublons est due à un problème lors de la migration de la base dans oracle 11g. Leur date de création est *13/02/2013*, c'est-à-dire la date de migration de la base. L'objectif est de conserver les seuils, mais de supprimer les doublons. Or étant donné que toutes les données attributaires sont en doublons, nous avons choisi la distance par rapport à leur tronçon d'affectation comme élément discriminant. Ainsi le seuil étant le plus éloigné du tronçon lui étant affecté au sein des doublons est supprimé.  

**Cette manipulation se fait en trois temps :**
**1. Création de la vue matérialisée identifiant ces doublons**
```SQL
-- 1.2. Création du vue matérialisée permettant d'identifier tous les seuils dont le nuseui, nsseui et ccomvoi sont identiques

/*
DROP MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_DOUBLON_SEUIL_G_SIDU;
DELETE FROM USER_SDO_GEOM_METADATA WHERE TABLE_NAME = 'VM_TEMP_DOUBLON_SEUIL_G_SIDU';
COMMIT;
*/
-- 1.2.1. Création de la VM
EXECUTE IMMEDIATE 'CREATE MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_DOUBLON_SEUIL_G_SIDU(OBJECTID, ID_SEUIL, NUMERO_SEUIL, COMPLEMENT_SEUIL, ID_VOIE, DISTANCE)
REFRESH ON DEMAND
FORCE
DISABLE QUERY REWRITE AS
WITH
    C_1 AS(
        SELECT
            a.nuseui AS numero_seuil,
            CASE
                WHEN a.nsseui IS NOT NULL
                THEN a.nsseui
            ELSE
                ''pas de complément''
            END AS complement_seuil,
            e.ccomvoi AS id_voie
        FROM
            G_BASE_VOIE.TEMP_ILTASEU a
            INNER JOIN G_BASE_VOIE.TEMP_ILTASIT b ON b.idseui = a.idseui
            INNER JOIN G_BASE_VOIE.TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT d ON d.cnumtrc = c.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI e ON e.ccomvoi = d.ccomvoi
        WHERE
            c.cdvaltro = ''V''
            AND d.cvalide = ''V''
            AND e.cdvalvoi = ''V''
            AND a.idseui NOT IN(393545, 393540) -- Ces seuils sont affectés à plusieurs voies
        GROUP BY
            a.nuseui,
                CASE
                    WHEN a.nsseui IS NOT NULL
                    THEN a.nsseui
                ELSE
                    ''pas de complément''
                END,
                e.ccomvoi
        HAVING
            COUNT(a.nuseui) > 1
            AND COUNT(CASE
                WHEN a.nsseui IS NOT NULL
                THEN a.nsseui
            ELSE
                ''pas de complément''
            END) > 1
            AND COUNT(e.ccomvoi) > 1
    )
    
        SELECT DISTINCT
            ROWNUM AS objectid,
            a.idseui,
            f.*,
            ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                                    SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
                                        SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo),
                                        SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo), a.ora_geometry),
                                        0
                                    ),
                                    a.ora_geometry
                                    ), 2)AS distance
        FROM
            G_BASE_VOIE.TEMP_ILTASEU a
            INNER JOIN G_BASE_VOIE.TEMP_ILTASIT b ON b.idseui = a.idseui
            INNER JOIN G_BASE_VOIE.TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT d ON d.cnumtrc = c.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI e ON e.ccomvoi = d.ccomvoi
            INNER JOIN C_1 f ON f.numero_seuil = a.nuseui AND f.complement_seuil = CASE WHEN a.nsseui IS NULL THEN ''pas de complément'' ELSE a.nsseui END AND f.id_voie = e.ccomvoi,
            USER_SDO_GEOM_METADATA m
        WHERE
            m.table_name = ''TEMP_ILTATRC''
            AND c.cdvaltro = ''V''
            AND d.cvalide = ''V''
            AND e.cdvalvoi = ''V''
        ORDER BY
            f.numero_seuil,
            f.complement_seuil,
            f.id_voie';

/

-- 1.2.2. Création des commentaires de VM
EXECUTE IMMEDIATE 'COMMENT ON MATERIALIZED VIEW G_BASE_VOIE.VM_TEMP_DOUBLON_SEUIL_G_SIDU IS ''VM temporaire servant à supprimer les seuils en doublons. Ces seuils disposent des mêmes numéros, compléments de seuil et voie, mais d''un identifiant et parfois d''un numéro de parcelle différent. Cependant, cela causant problème pour le "projet" LITTERALIS il fut décidé de ne garder que les seuils les plus proches de leur tronçon au sein des doublons.''';

/

-- 1.2.3. Création de la clé primaire
EXECUTE IMMEDIATE 'ALTER MATERIALIZED VIEW VM_TEMP_DOUBLON_SEUIL_G_SIDU 
ADD CONSTRAINT VM_TEMP_DOUBLON_SEUIL_G_SIDU_PK 
PRIMARY KEY (OBJECTID)';
```

**2. Suppression des doublons les plus éloignés de leur tronçon**

```SQL
-- 1.2.4 Suppression des seuils en doublons dont la distance par rapport à leur tronçon est la plus grande au sein des doublons (même numéro, complément de seuil NULL, même numéro de voie)
DELETE FROM G_BASE_VOIE.TEMP_ILTASEU
WHERE
    IDSEUI IN(
        WITH
            C_1 AS(
                SELECT
                    numero_seuil,
                    complement_seuil,
                    id_voie,
                    MIN(distance) AS min_distance
                FROM
                    G_BASE_VOIE.VM_TEMP_DOUBLON_SEUIL_G_SIDU
                GROUP BY
                    numero_seuil,
                    complement_seuil,
                    id_voie
            )
            SELECT
                a.id_seuil
            FROM
                G_BASE_VOIE.VM_TEMP_DOUBLON_SEUIL_G_SIDU a
                INNER JOIN C_1 b ON b.numero_seuil = a.numero_seuil AND b.complement_seuil = a.complement_seuil AND b.id_voie = a.id_voie
            WHERE
                a.distance > b.min_distance
    );
COMMIT;
```

**3. Suppression des doublons lorsque les distances sont les mêmes**

Nous avons des cas où les distances seuils/tronçons sont les mêmes au sein des doublons, ce enlève tout élément permettant de discriminer les seuils, **c'est donc arbitrairement** que j'ai décidé de supprimer les seuils dont l'identifiant est le plus petit au sein de ces doublons. Je précise que cette méthode n'est possible **que** parce qu'il n'y a **que** des valeurs en double pour chaque cas et non en triple, quadruple ou plus. Par ailleurs cette suppression ne concerne que très peu de seuils (moins de 10).

```SQL
-- 1.3. Suppression des seuils en doublons de numéro et complément de seuil, voie et distance par raport au tronçon, dont l'idseui est le plus petit.
DELETE FROM G_BASE_VOIE.TEMP_ILTASEU
WHERE
    idseui IN(
        WITH
            C_1 AS(
                SELECT
                    a.nuseui AS numero_seuil,
                    CASE
                        WHEN a.nsseui IS NOT NULL
                        THEN a.nsseui
                    ELSE
                        'pas de complément'
                    END AS complement_seuil,
                    e.ccomvoi AS id_voie
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
                    AND a.idseui NOT IN(393545, 393540) 
                GROUP BY
                    a.nuseui,
                        CASE
                            WHEN a.nsseui IS NOT NULL
                            THEN a.nsseui
                        ELSE
                            'pas de complément'
                        END,
                        e.ccomvoi
                HAVING
                    COUNT(a.nuseui) > 1
                    AND COUNT(CASE
                        WHEN a.nsseui IS NOT NULL
                        THEN a.nsseui
                    ELSE
                        'pas de complément'
                    END) > 1
                    AND COUNT(e.ccomvoi) > 1
            ),
            
            C_2 AS(
                SELECT DISTINCT
                    MIN(a.idseui) AS idseui,
                    f.*,
                    ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                                            SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
                                                SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo),
                                                SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo), a.ora_geometry),
                                                0
                                            ),
                                            a.ora_geometry
                                            ), 2)AS distance
                FROM
                    G_BASE_VOIE.TEMP_ILTASEU a
                    INNER JOIN G_BASE_VOIE.TEMP_ILTASIT b ON b.idseui = a.idseui
                    INNER JOIN G_BASE_VOIE.TEMP_ILTATRC c ON c.cnumtrc = b.cnumtrc
                    INNER JOIN G_BASE_VOIE.TEMP_VOIECVT d ON d.cnumtrc = c.cnumtrc
                    INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI e ON e.ccomvoi = d.ccomvoi
                    INNER JOIN C_1 f ON f.numero_seuil = a.nuseui AND f.complement_seuil = CASE WHEN a.nsseui IS NULL THEN 'pas de complément' ELSE a.nsseui END AND f.id_voie = e.ccomvoi,
                    USER_SDO_GEOM_METADATA m
                WHERE
                    m.table_name = 'TEMP_ILTATRC'
                    AND c.cdvaltro = 'V'
                    AND d.cvalide = 'V'
                    AND e.cdvalvoi = 'V'
                GROUP BY
                    f.numero_seuil,
                    f.complement_seuil,
                    f.id_voie,
                    ROUND(SDO_GEOM.SDO_DISTANCE(-- Sélection de la distance entre le seuil et le point le plus proche du tronçon qui lui est affecté
                                            SDO_LRS.LOCATE_PT(-- Création du point situé le plus près du seuil sur le tronçon
                                                SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo),
                                                SDO_LRS.FIND_MEASURE(SDO_LRS.CONVERT_TO_LRS_GEOM(c.ora_geometry, m.diminfo), a.ora_geometry),
                                                0
                                            ),
                                            a.ora_geometry
                                            ), 2)
            )
            
            SELECT
                idseui
            FROM
                C_2
    );
COMMIT;
```

