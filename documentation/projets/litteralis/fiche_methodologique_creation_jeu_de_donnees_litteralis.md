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

## Outils :
### Logiciels :
- SqlDevelopper ;
- Ogr2ogr ;

### Tables de travail :
- TA_VOIE_LITTERALIS ;
- TEMP_TRONCON_CORRECT_LITTERALIS ;
- TEMP_TRONCON_AUTRES_LITTERALIS ;
- TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS ;
- TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS ;
- TEMP_ADRESSE_CORRECTE_LITTERALIS ;
- TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS ;
- TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS ;

### Vues matérialisées de travail :
- VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE ;
- VM_TEMP_DOUBLON_SEUIL_G_SIDU ;
- VM_ADRESSE_LITTERALIS ;
- VM_TRONCON_LITTERALIS ;

## Sommaire :
1. Correction des données implémentée dans la migration de la base ;
2. Création de la vue matérialisée VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE ;
3. Création de la table TA_VOIE_LITTERALIS respectant la règle "une voie unique par commune" ;
4. Création de trois tables de travail pour les **tronçons** et pour les **adresses** ;
5. Création des deux vues matérialisées d'export des **tronçons** et des **adresses** ;
6. Création des vues matérialisées regroupant les zones administratives des **regroupements** ;
7. Création de la vue matérialisée d'export des **regroupements** ;

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

####Cette manipulation se fait en quatre temps :
#####1. Création de la vue matérialisée identifiant ces doublons**
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

#####2. Suppression des doublons les plus éloignés de leur tronçon

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

#####3. Suppression des doublons lorsque les distances sont les mêmes

Nous avons des cas où les distances seuils/tronçons sont les mêmes au sein des doublons, ce qui enlève tout élément permettant de discriminer les seuils, **c'est donc arbitrairement** que j'ai décidé de supprimer les seuils dont l'identifiant est le plus petit au sein de ces doublons. Je précise que cette méthode n'est possible **que** parce qu'il n'y a **que** des valeurs en double pour chaque cas et non en triple, quadruple ou plus. Par ailleurs cette suppression ne concerne que très peu de seuils (moins de 10).

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

#####4. Suppression des seuils situés à 1km ou plus de leur tronçon d'affectation

Durant l'état des lieux de la base voie, nous avons trouvé des seuils affectés à un tronçon situé à l'autre bout de la commune, ce qui est indubitablement une erreur. Pour corriger cela, nous supprimons tous les seuils distants de 1km ou plus de leur tronçon d'affectation. Ce plafond du kilomètre est dû au fait que dans de très grandes parcelles les bâtiments sont situés relativement loin de la rue, c'est donc pour prendre en compte ce facteur que nous utilisons le kilomètre comme plafond de distanciation entre un seuil et son tronçon.

```SQL
-- 1.4. Suppression des seuils situés à 1km ou plus de leur tronçon d'affectation
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
```

#####5. Suppression des relations tronçons/seuils pointant sur un seuil supprimé

Une fois les seuils corrigés, il faut supprimer les relations avec les tronçons pointant vers des seuils qui ont été supprimés.

```SQL
-- 1.5. Suppression des relations seuils/tronçons invalides dues à la suppression des seuils ci-dessus
DELETE FROM G_BASE_VOIE.TEMP_ILTASIT
WHERE
    IDSEUI IN(
        SELECT
            idseui
        FROM
            G_BASE_VOIE.TEMP_ILTASIT
        WHERE
            idseui NOT IN(SELECT idseui FROM G_BASE_VOIE.TEMP_ILTASEU)
    );
COMMIT;
```

## 2. Création de la vue matérialisée VM_ETUDE_VOIE_PRINCIPALE_SECONDAIRE

Cette VM (dont le code se trouve dans le fichier ![creation_vm_etude_voie_principale_secondaire.sql](../../sql/scripts/code_ddl/vues_materialisees/creation_vm_etude_voie_principale_secondaire.sql)) est utilisée dans l'étape suivante pour distinguer les voies principales des voies secondaires.
En soit cette VM n'est pas nécessaire, mais permet de réduire de façon conséquente les temps de traitements.  Elle créé les voies géométriques en fusionnant les tronçons de chaque voie en les regroupant par identifant de voie, libelle de voie, complément de nom de voie et type de voie. 


## 3. Création de la table TA_VOIE_LITTERALIS respectant la règle "une voie unique par commune"

La base voie contient actuellement des voies dites *principales* et de voies dites *secondaires*. Ces voies ont le même nom, mais pas la même distance, ainsi la *voie principale* est toujours la plus longue et correspond, par exemple, à un boulevard, tandis que les *voies secondaires* sont toujours plus petites et correspondent à des voies perpendiculaires à la *voie principale*.  
On retrouve beaucoup ce cas dans les lotissements complexes.  
**Le problème** c'est que le format LITTERALIS n'accepte pas les voies avec le même nom, mais pas le même identifiant.  
Nous avons donc décidé affecter le suffixe *ANNEXE 1, 2, 3, etc* au nom des *voies secondaires* en fonction de leur taille et par ordre décroissant (Annexe 1 étant le plus grand).

### 3.1. Création de la table TA_VOIE_LITTERALIS
Dans un premier temps il faut créer la table *TA_VOIE_LITTERALIS* qui accueillera les valeurs des voies du projet LITTERALIS.  
Pour cela, veuillez utiliser le fichier ![creation_ta_voie_litteralis.sql](../../sql/scripts/code_ddl/tables/creation_ta_voie_litteralis.sql).

### 3.2. Remplissage de la table TA_VOIE_LITTERALIS
Dans un second temps on rempli la table avec les nouvelles valeurs en utilisant la procédure ![creation_procedure_remplissage_ta_voie_litteralis.sql](../../sql/scripts/code_ddl/procedure/creation_procedure_remplissage_ta_voie_litteralis.sql).

### 3.3. Vérification des valeurs de TA_VOIE_LITTERALIS

#### 3.3.1. Comparaison du nombre de voies dans TA_VOIE et dans TA_VOIE_LITTERALIS

**Objectif :** s'assurer d'avoir le même nombre d'entités dans les deux tables ;

```SQL
-- Vérification du nombre de voies dans TA_VOIE_LITTERALIS
WITH
	C_1 AS(
		SELECT
		    COUNT(a.objectid) AS NBR_ENTITE
		FROM
		    G_BASE_VOIE.TA_VOIE a
		    INNER JOIN G_BASE_VOIE.TA_TYPE_VOIE b ON b.objectid = a.fid_typevoie
		WHERE
		    UPPER(b.libelle) <> 'TYPE DE VOIE PRÉSENT DANS VOIEVOI MAIS PAS DANS TYPEVOIE LORS DE LA MIGRATION'
	),

	C_2 AS(
		SELECT
			COUNT(objectid) AS NBR_ENTITE
		FROM
		    G_BASE_VOIE.TA_VOIE_LITTERALIS
	)

	SELECT
		CASE
			WHEN (a.nbr_entite - b.nbr_entite) > 0
				THEN (a.nbr_entite - b.nbr_entite)
			WHEN (a.nbr_entite = b.nbr_entite)
				THEN 0
			WHEN (b.nbr_entite - a.nbr_entite) > 0
				THEN (b.nbr_entite - a.nbr_entite)
		END AS NBR_VOIE,
		CASE
			WHEN (a.nbr_entite - b.nbr_entite) > 0
				THEN ' voies en moins dans TA_VOIE_LITTERALIS.'
			WHEN (a.nbr_entite = b.nbr_entite)
				THEN 'Autant de voie dans TA_VOIE que dans TA_VOIE_LITTERALIS'
			WHEN (b.nbr_entite - a.nbr_entite) > 0
				THEN ' voies en trop dans TA_VOIE_LITTERALIS.'
		END AS STATUT
	FROM
		C_1 a,
		C_2 b;
```

#### 3.3.2. S'assurer de la présence du suffixe 'ANNEXE' pour les doublons de nom de voie

## 4. Création de trois tables de travail pour les **tronçons** et pour les **adresses**

### 4.1. TRONCON
#### 4.1.1. TEMP_TRONCON_CORRECT_LITTERALIS

**- Objectif :** Regrouper dans une table les associations tronçon/voie où tout va bien ;  
**- Fichier :** ![creation_temp_troncon_correct_litteralis.sql](../../sql/scripts/code_ddl/tables/creation_temp_troncon_correct_litteralis.sql) ;

#### 4.1.2. TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS

**- Objectif :** Regrouper dans une table les associations tronçon/voie où un tronçon est affecté à plusieurs voies ;  
**- Fichier :** ![creation_temp_troncon_correct_litteralis.sql](../../sql/scripts/code_ddl/tables/creation_temp_troncon_correct_litteralis.sql) ;
