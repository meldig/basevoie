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
- TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS ;
- TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS ;
- TEMP_ADRESSE_AUTRES_LITTERALIS ;
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
4. Création de trois tables de travail pour les **tronçons** et quatre pour les **adresses** ;
5. Remplissage des tables de travail ;
6. Création des deux vues matérialisées d'export des **tronçons** et des **adresses** ;
7. Correction des secteurs de voirie ;
8. Création des vues matérialisées regroupant les zones administratives des **regroupements** ;
9. Création de la vue matérialisée d'export des **regroupements** ;

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

## 4. Création de trois tables de travail pour les **tronçons** et quatre pour les **adresses**

### 4.1. TRONCON
#### 4.1.1. TEMP_TRONCON_CORRECT_LITTERALIS

**- Objectif :** Regrouper dans une table les associations tronçon/voie où tout va bien. La table des voies utilisée pour faire ces associations est : *TA_VOIE_LITTERALIS* ;  
**- Fichier :** ![creation_temp_troncon_correct_litteralis.sql](../../sql/scripts/code_ddl/tables/creation_temp_troncon_correct_litteralis.sql) ;

#### 4.1.2. TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS

**- Objectif :** Regrouper dans une table les associations tronçon/voie où un tronçon est affecté à plusieurs voies. La table des voies utilisée pour faire ces associations est : *TA_VOIE_LITTERALIS* ;  
**- Fichier :** ![creation_temp_troncon_doublon_voie_litteralis.sql](../../sql/scripts/code_ddl/tables/creation_temp_troncon_doublon_voie_litteralis.sql) ;

#### 4.1.3. TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS

**- Objectif :** Regrouper dans une table les associations tronçon/voie où un tronçon est affecté à des sous-tronçons disposant de domanialités différentes. La table des voies utilisée pour faire ces associations est : *TA_VOIE_LITTERALIS* ;  
**- Fichier :** ![creation_temp_troncon_doublon_domania_litteralis.sql](../../sql/scripts/code_ddl/tables/creation_temp_troncon_doublon_domania_litteralis.sql) ;

### 4.2. ADRESSE
#### 4.2.1. TEMP_ADRESSE_CORRECTE_LITTERALIS

**- Objectif :** Regrouper dans une table les associations tronçon/seuil où tout va bien ;  
**- Fichier :** ![creation_TEMP_ADRESSE_CORRECTE_LITTERALIS.sql](../../sql/scripts/code_ddl/tables/creation_TEMP_ADRESSE_CORRECTE_LITTERALIS.sql) ;

#### 4.2.2. TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS

**- Objectif :** Regrouper dans une table les associations tronçon/seuil où un tronçon est affecté à plusieurs voies. Dans ce cas la table des tronçons utilisée pour faire les associations est *TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS* ;  
**- Fichier :** ![creation_temp_adresse_doublon_voie_litteralis.sql](../../sql/scripts/code_ddl/tables/creation_temp_adresse_doublon_voie_litteralis.sql) ;

#### 4.2.3. TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS

**- Objectif :** Regrouper dans une table les associations tronçon/seuil où un tronçon est affecté à des sous-tronçons disposant de domanialités différentes. Dans ce cas la table des tronçons utilisée pour faire les associations est *TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS* ;  
**- Fichier :** ![creation_temp_adresse_doublon_domania_litteralis.sql](../../sql/scripts/code_ddl/tables/creation_temp_adresse_doublon_domania_litteralis.sql) ;

#### 4.2.3. TEMP_ADRESSE_DOUBLON_AUTRES_LITTERALIS

**- Objectif :** Regrouper dans une table les associations tronçon/seuil disposant de plusieurs erreurs mentionnées dans les trois tables ci-dessus, et/ou d'associations tronçon/seuil pas encore présentes dans les tables précédentes. Dans ce cas la table des tronçons utilisée pour faire les associations est *TEMP_TRONCON_DOUBLON_AUTRES_LITTERALIS* ;  
**- Fichier :** ![creation_temp_adresse_autres_litteralis.sql](../../sql/scripts/code_ddl/tables/creation_temp_adresse_autres_litteralis.sql) ;

## 5. Remplissage des tables de travail

Une fois les tables de travail créées, il faut les remplir, en utilisant le code du fichier ![creation_temp_adresse_autres_litteralis.sql](../../sql/scripts/code_dml/litteralis/remplissage_tables_travail.sql)

### 5.1. Insertion des tronçons affectés à une et une seule voie et disposant d'une d'une seule domanialité dans TEMP_TRONCON_CORRECT_LITTERALIS

#### Table concernée : TEMP_TRONCON_CORRECT_LITTERALIS  

#### Objectif :
Mettre au format LITTERALIS les tronçons corrects affectés à une et une seule voie, disposant d'une seule domanialité et d'un seul sous-tronçon.  
Pas de commentaire particulier sur cette partie.

### 5.2. Insertion des tronçons affectés à plusieurs voies et disposant d'une seule domanialité

#### Table concernée : TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS  

#### Objectif : 
Créer un identifant de tronçon virtuel pour chaque doublon. Ainsi, au lieu d'avoir un tronçon affectés à deux voies, on aura deux tronçons affectés, chacun, à une voie différente, mais disposant de la même géométrie.

**Dans un premier temps**, on sélectionne tous les tronçons affectés à plusieurs voies et disposant d'une seule domanialité :
```SQL
WITH
    C_1 AS(-- Sélection des tronçons affectés à plusieurs voies  au sein d'une même commune mais disposant d'une seule domanialité
        SELECT
            a.objectid AS code_tronc
        FROM
            G_BASE_VOIE.TA_TRONCON a
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
            INNER JOIN G_BASE_VOIE.TA_VOIE_LITTERALIS c ON c.id_voie = b.fid_voie
            INNER JOIN SIREO_LEC.OUT_DOMANIALITE d ON d.cnumtrc = a.objectid
        WHERE
            c.insee IS NOT NULL
        GROUP BY
            a.objectid
        HAVING
            COUNT(a.objectid) > 1
            AND COUNT(DISTINCT d.objectid) = 1
            AND COUNT(c.insee) > 1
            AND COUNT(DISTINCT c.id_voie) > 1
    ),
```

**Dans un second temps**, on sélectionne le code tronçon maximum qui nous servira à créer les futurs identifiants virtuels de nos tronçons. Le fait d'utiliser le code tronçon maximum pour cela s'explique par la nécessité d'éviter de créer un doublon avec un tronçon réél existant.
```SQL
C_2 AS(-- Sélection de l'objectid max de TA_TRONCON afin de ne pas créer de doublons d'id
    SELECT
        MAX(objectid) AS code_troncon_max
    FROM
        G_BASE_VOIE.TA_TRONCON
)
```

**Dans un troisième temps,** créé les identifiants virtuels et on met les données au format LITTERALIS.  
Pour cela, on additionne le code tronçon maximum et le nombre de lignes des tronçons identifiés en *C_1* (afin de simuler une incrémentation de 1).  
Par ailleurs, la domanialité des tronçons doit respecter une forme propre à LITTERALIS, c'est pourquoi on utilise un CASE WHEN (cette forme est décrite dans la documentation des livrables).

```SQL
-- Sélection des autes infos + création des id de tronçon virtuels : on part du code_tronçon max+1 et on incrémente de 1 par tronçon repéré dans C_1
SELECT
    a.code_troncon_max + 1 + rownum AS code_tronc,
    f.objectid AS id_troncon,
    CASE 
        WHEN e.domania = 'AUTOROUTE OU VOIE A CARACTERE AUTOROUTIER'
        THEN 'A'
        WHEN e.domania = 'ROUTE NATIONALE'
        THEN 'RN' -- Route Nationale
        WHEN e.domania IN ('VOIE PRIVEE ENTRETENUE PAR LA CUDL','VOIE PRIVEE FERMEE','VOIE PRIVEE OUVERTE','AUTRE VOIE PRIVEE','DECLASSEMENT EN COURS')
        THEN 'VP' -- Voie Privée
        WHEN e.domania = 'CHEMIN RURAL'
        THEN 'CR' -- Chemin Rural
        WHEN e.domania IN ('VOIE METROPOLITAINE','GESTION COMMUNAUTAIRE','AUTRE VOIE PUBLIQUE')
        THEN 'VC' -- Voie Communale
    END AS CLASSEMENT,
    d.id_voie AS CODE_RUE_G,
    d.libelle_voie AS NOM_RUE_G,
    d.insee AS INSEE_G,
    d.id_voie AS CODE_RUE_D,
    d.libelle_voie AS NOM_RUE_D,
    d.insee AS INSEE_D,
    CAST('' AS NUMBER(8,0)) AS LARGEUR,
    f.geom AS geometry
FROM
    C_2 a,
    C_1 b
    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE c ON c.fid_troncon = b.code_tronc
    INNER JOIN G_BASE_VOIE.TA_VOIE_LITTERALIS d ON d.id_voie = c.fid_voie
    INNER JOIN SIREO_LEC.OUT_DOMANIALITE e ON e.cnumtrc = b.code_tronc
    INNER JOIN G_BASE_VOIE.TA_TRONCON f ON f.objectid = b.code_tronc
```

### 5.3. Insertion des tronçons affectés à une seule voie, mais disposant de sous-tronçons de domanialités différentes

#### Table concernée : TEMP_TRONCON_DOUBLON_DOMANIA_LITTERALIS  

#### Problème :
Certains tronçons se composent de sous-tronçons de domanialités différentes, hors comme l'application LITTERALIS a besoin de cette domanialité, cela créé plusieurs tronçons avec le même identifiant mais des domanialités différentes.

#### Objectif :
Créer des tronçons avec une et une seule domanialité.

#### Solution :
Pour résoudre ce problème et étant donné que chaque tronçon dans ce cas dispose de deux domanialités dont une de type "privé", nous utilisons la règle de priorité des domanialités mise en place par le service voirie dans la table *TYPOVOIE.COD_DOMANIALITE*. Cette règle stipule que les voies privées sont en dernier dans l'ordre des priorités. Il nous suffit donc de conserver la seconde domanialité du tronçon, ce qui nous évite d'avoir à créer des identifiants de tronçons virtuels. Cette méthode a été établie en concertation avec le service voirie et l'équipe de Sogelink.  
  
**Dans un premier temps**, on sélectionne tous les tronçons affectés à une et une seule voie, mais disposant de plusieurs domanialités différentes :
```SQL
WITH
    C_1 AS(-- Sélection des tronçons disposant de plusieurs domanialités, mais affectés à une seule voie
        SELECT
            a.objectid AS code_tronc
        FROM
            G_BASE_VOIE.TA_TRONCON a
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE b ON b.fid_troncon = a.objectid
            INNER JOIN G_BASE_VOIE.TA_VOIE_LITTERALIS c ON c.id_voie = b.fid_voie
            INNER JOIN SIREO_LEC.OUT_DOMANIALITE d ON d.cnumtrc = a.objectid
        WHERE
            c.insee IS NOT NULL
        GROUP BY
            a.objectid
        HAVING
            COUNT(a.objectid) > 1
            AND COUNT(DISTINCT b.fid_voie) = 1
            AND COUNT(DISTINCT d.domania) > 1
```

**Dans un second temps**, on sélectionne parmis les tronçons récupérés en *C_1* la domanialité qui est différente de "privé" et on met les données au format LITTERALIS :
```SQL
SELECT
    b.code_tronc,
    b.code_tronc AS id_troncon,
    CASE 
        WHEN e.domania = 'AUTOROUTE OU VOIE A CARACTERE AUTOROUTIER'
        THEN 'A'
        WHEN e.domania = 'ROUTE NATIONALE'
        THEN 'RN' -- Route Nationale
        WHEN e.domania = 'CHEMIN RURAL'
        THEN 'CR' -- Chemin Rural
        WHEN e.domania IN ('VOIE METROPOLITAINE','GESTION COMMUNAUTAIRE','AUTRE VOIE PUBLIQUE')
        THEN 'VC' -- Voie Communale
    END AS CLASSEMENT,
    d.id_voie AS CODE_RUE_G,
    d.libelle_voie AS NOM_RUE_G,
    d.insee AS INSEE_G,
    d.id_voie AS CODE_RUE_D,
    d.libelle_voie AS NOM_RUE_D,
    d.insee AS INSEE_D,
    CAST('' AS NUMBER(8,0)) AS LARGEUR,
    f.geom AS geometry,
    e.objectid AS CODE_SOUS_TRONCON
FROM
    C_1 b
    INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE c ON c.fid_troncon = b.code_tronc
    INNER JOIN G_BASE_VOIE.TA_VOIE_LITTERALIS d ON d.id_voie = c.fid_voie
    INNER JOIN SIREO_LEC.OUT_DOMANIALITE e ON e.cnumtrc = b.code_tronc
    INNER JOIN G_BASE_VOIE.TA_TRONCON f ON f.objectid = b.code_tronc
WHERE
    e.domania NOT IN ('VOIE PRIVEE ENTRETENUE PAR LA CUDL','VOIE PRIVEE FERMEE','VOIE PRIVEE OUVERTE','AUTRE VOIE PRIVEE','DECLASSEMENT EN COURS')
    AND e.objectid <> 889 -- Cette condition est nécessaire pour éviter d'avoir un doublon du troncon 54215 avec la même domanialité, ce qu ne devrait normalement pas être, mais bon...
```

### 5.4. Insertion des associations tronçon/seuil où un seuil est affecté à un tronçon disposant d'une domanialité et affecté à une seule voie

#### Table concernée : TEMP_ADRESSE_CORRECTE_LITTERALIS  

#### Objectif :
Mettre au format LITTERALIS les seuils associés à un tronçon sans erreur.  
  
Le code ne nécessite pas de description particulière, hormis le fait que la table des tronçons utilisée ici est *TEMP_TRONCON_CORRECT_LITTERALIS*. Pour plus d'informations concernant le format LITTERALIS, veuillez vous reporter à la documentation des livrables.

### 5.5. Insertion des seuils affectés à des tronçons affectés à plusieurs voies

#### Table concernée : TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS  

### Problème :
Si un tronçon est affecté à plusieurs voies, alors le seuil affecté à ce tronçon se retrouve affecté à deux voies, ce qui est impossible.  

### Objectif :
Avoir un seuil affecté à une et une seule voie.  

### Solution :
Etant donné que nous n'avons aucun moyen de déterminer pour tous les seuils concernés à quelle voie ils appartiennent, nous avons décidé de les associer à la voie ayant l'identifiant le plus petit au sein des doublons. Précisons que la table des tronçons utilisée ici est *TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS*.
  
**Dans un premier temps**, on sélectionne pour chaque seuil affecté à un tronçon lui-même affecté à deux voies, les codes voies et le code seuil, en plus des autres données au format LITTERALIS :

```SQL
WITH
    C_1 AS(
        SELECT DISTINCT
            d.code_rue_g AS CODE_VOIE,
            a.objectid AS CODE_POINT,
            'ADR' AS NATURE,
            CASE
                WHEN a.complement_numero_seuil IS NULL
                    THEN CAST(a.numero_seuil AS VARCHAR2(254))
                WHEN a.complement_numero_seuil IS NOT NULL
                    THEN CAST(a.numero_seuil || ' ' || a.complement_numero_seuil AS VARCHAR2(254))
                END AS libelle,
            a.numero_seuil AS NUMERO,
            a.complement_numero_seuil AS REPETITION,
            'LesDeuxCotes' AS COTE,
            a.fid_seuil,
            d.insee_g
        FROM
            G_BASE_VOIE.TA_INFOS_SEUIL a
            INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = b.objectid
            INNER JOIN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS d ON CAST(d.ID_TRONCON AS NUMBER(38,0)) = c.fid_troncon,
            USER_SDO_GEOM_METADATA m            
    )
```

**Dans un second temps**, on sélectionne pour chaque association voie**s**/seuil le **code voie minimum** et le reste des données :

```SQL
C_2 AS(
    SELECT DISTINCT
        MIN(CAST(a.CODE_VOIE AS NUMBER(38,0))) AS CODE_VOIE,
        CAST(a.CODE_POINT AS VARCHAR2(254)) AS CODE_POINT,
        a.fid_seuil,
        CAST(a.NATURE AS VARCHAR2(254)) AS NATURE,
        CAST(a.LIBELLE AS VARCHAR2(254)) LIBELLE,
        CAST(a.NUMERO AS NUMBER(8,0)) AS NUMERO,
        CAST(a.REPETITION AS VARCHAR2(10)) AS REPETITION,
        CAST(a.COTE AS VARCHAR2(254)) AS COTE
    FROM
        C_1 a
        INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
    WHERE
        GET_CODE_INSEE_CONTAIN_POINT('TA_SEUIL', b.geom) = a.insee_g
    GROUP BY
        CAST(a.CODE_POINT AS VARCHAR2(254)),
        a.fid_seuil,
        CAST(a.NATURE AS VARCHAR2(254)),
        CAST(a.LIBELLE AS VARCHAR2(254)),
        CAST(a.NUMERO AS NUMBER(8,0)),
        CAST(a.REPETITION AS VARCHAR2(10)),
        CAST(a.COTE AS VARCHAR2(254))
    )        
    SELECT 
        CAST(a.CODE_VOIE AS VARCHAR(254)),
        a.CODE_POINT,
        a.NATURE,
        a.LIBELLE,
        a.NUMERO,
        a.REPETITION,
        a.COTE,       
        b.geom AS GEOMETRY
    FROM
        C_2 a
        INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil;
```

### 5.6. Insertion des seuils affectés à des tronçons disposant de sous-tronçons de domanialités différentes

#### Table concernée : TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS  

#### Problème :
Si un seuil est affecté à un tronçon disposant de plusieurs domanialités différentes, il faut s'assurer que le tronçon en question dispose de la bonne domanialité, cest-à-dire tout sauf "privé". Pour plus de détails, référez-vous au point 5.3.  

#### Objectif :
Un seuil doit être affecté à une et une seule voie.

#### Solution :
Le problème des tronçons disposant de plusieurs domanialités ayant été réglé au point 5.3 sans avoir à utilise d'identifiant virtuel, il suffit de mettre au format LITTERALIS les données des seuils affectés aux tronçons présents dans la table TEMP_TRONCON_DOUBLON_DOMANIA.  
Hormis l'explication ci-dessus, le code n'a pas de spécificité particulière.

### 5.7. Insertion des seuils restants

#### Table concernée : TEMP_ADRESSE_AUTRES_LITTERALIS  

#### Problème : 
Si on s'arrête au point 5.6, alors il manque environ 51 000 adresses. Cette tables sert donc à récupérer toutes les adresses qui n'ont pas encore été traitées.  

**Dans un premier temps**, on sélectionne tous les seuils absents des tables TEMP_ADRESSE_CORRECTE_LITTERALIS, TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS et TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS affectés à une et une seule voie :

```SQL
WITH
    C_1 AS(
        SELECT
            CAST(code_point AS NUMBER(38,0)) AS code_point
        FROM
            G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS
        UNION ALL
        SELECT
            CAST(code_point AS NUMBER(38,0)) AS code_point
        FROM
            G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS
        UNION ALL
        SELECT
            CAST(code_point AS NUMBER(38,0)) AS code_point
        FROM
            G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS
    ),
    
    C_2 AS(
        SELECT DISTINCT
            a.objectid
        FROM
            G_BASE_VOIE.TA_INFOS_SEUIL a
            INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = b.objectid
            INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = c.fid_troncon
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE e ON e.fid_troncon = d.objectid
            INNER JOIN G_BASE_VOIE.TA_VOIE_LITTERALIS f ON f.id_voie = e.fid_voie
       WHERE
            a.objectid NOT IN(SELECT code_point FROM C_1) 
        GROUP BY
            a.objectid
        HAVING
            COUNT(f.id_voie) = 1
    ),
```

**Dans un second temps**, on met au format LITTERALIS les données issues de *C_2* :

```SQL
C_3 AS(
    SELECT DISTINCT
        d.code_rue_g AS CODE_VOIE,
        a.objectid AS CODE_POINT,
        'ADR' AS NATURE,
        CASE
            WHEN a.complement_numero_seuil IS NULL
                THEN CAST(a.numero_seuil AS VARCHAR2(254))
            WHEN a.complement_numero_seuil IS NOT NULL
                THEN CAST(a.numero_seuil || ' ' || a.complement_numero_seuil AS VARCHAR2(254))
            END AS libelle,
        a.numero_seuil AS NUMERO,
        a.complement_numero_seuil AS REPETITION,
        'LesDeuxCotes' AS COTE,
        a.fid_seuil
    FROM
        G_BASE_VOIE.TA_INFOS_SEUIL a
        INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = b.objectid
        INNER JOIN G_BASE_VOIE.TEMP_TRONCON_CORRECT_LITTERALIS d ON d.id_troncon = c.fid_troncon
        INNER JOIN C_2 e ON e.objectid = a.objectid
)

SELECT
    a.*,
    b.geom AS geometry
FROM
    C_3 a
    INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
```

### 5.8. Insertion des adresses restantes liées aux tronçons affectés à plusieurs voies

#### Table concernée : TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS

#### Objectif :
traiter les seuils restants affectés aux tronçons eux-mêmes affectés à plusieurs voies.

#### Précision :
Cette partie est nécessaire, même si je ne comprends pas (pour l'instant) pourquoi la totalité des seuils n'a pas été traité au point 5.5.  
 
**Dans un premier temps**, on sélectionne tous les seuils absents des autres tables (points 5.4, 5.5, 5.6, 5.7) :

```SQL
WITH
    C_0 AS(
        SELECT
            code_point
        FROM
            G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS
        UNION ALL
        SELECT
            code_point
        FROM
            G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS
        UNION ALL
        SELECT
            code_point
        FROM
            G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS
        UNION ALL
        SELECT
            code_point
        FROM
            G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS      
    ),
    
    C_1 AS(
        SELECT DISTINCT
            d.code_rue_g AS CODE_VOIE,
            a.objectid AS CODE_POINT,
            'ADR' AS NATURE,
            CASE
                WHEN a.complement_numero_seuil IS NULL
                    THEN CAST(a.numero_seuil AS VARCHAR2(254))
                WHEN a.complement_numero_seuil IS NOT NULL
                    THEN CAST(a.numero_seuil || ' ' || a.complement_numero_seuil AS VARCHAR2(254))
                END AS libelle,
            a.numero_seuil AS NUMERO,
            a.complement_numero_seuil AS REPETITION,
            'LesDeuxCotes' AS COTE,
            a.fid_seuil,
            d.insee_g
        FROM
            G_BASE_VOIE.TA_INFOS_SEUIL a
            INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = b.objectid
            INNER JOIN G_BASE_VOIE.TEMP_TRONCON_DOUBLON_VOIE_LITTERALIS d ON CAST(d.ID_TRONCON AS NUMBER(38,0)) = c.fid_troncon,
            USER_SDO_GEOM_METADATA m 
        WHERE
            a.objectid NOT IN(SELECT CAST(code_point AS NUMBER(38,0)) FROM C_0)
    ),
```

**Dans un second temps**, on met les données au format LITTERALIS :
```SQL
C_2 AS(
    SELECT DISTINCT
        MIN(CAST(a.CODE_VOIE AS NUMBER(38,0))) AS CODE_VOIE,
        CAST(a.CODE_POINT AS VARCHAR2(254)) AS CODE_POINT,
        a.fid_seuil,
        CAST(a.NATURE AS VARCHAR2(254)) AS NATURE,
        CAST(a.LIBELLE AS VARCHAR2(254)) LIBELLE,
        CAST(a.NUMERO AS NUMBER(8,0)) AS NUMERO,
        CAST(a.REPETITION AS VARCHAR2(10)) AS REPETITION,
        CAST(a.COTE AS VARCHAR2(254)) AS COTE
    FROM
        C_1 a
        INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
    GROUP BY
        CAST(a.CODE_POINT AS VARCHAR2(254)),
        a.fid_seuil,
        CAST(a.NATURE AS VARCHAR2(254)),
        CAST(a.LIBELLE AS VARCHAR2(254)),
        CAST(a.NUMERO AS NUMBER(8,0)),
        CAST(a.REPETITION AS VARCHAR2(10)),
        CAST(a.COTE AS VARCHAR2(254))
)

SELECT 
    CAST(a.CODE_VOIE AS VARCHAR(254)) AS CODE_VOIE,
    a.CODE_POINT,
    a.NATURE,
    a.LIBELLE,
    a.NUMERO,
    a.REPETITION,
    a.COTE,       
    b.geom AS GEOMETRY
FROM
    C_2 a
    INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
```

#### 5.9. Insertion des adresses restantes

#### Table concernée : TEMP_ADRESSE_AUTRES_LITTERALIS

#### Objectif : 
Traiter les derniers seuils restants.

#### Précision :
Tout comme l'étape 5.8, cette étape est nécessaire jusqu'à ce que j'arrive à condenser le code.

**Dans un premier temps**, on sélection les seuils qui n'ont pas encore été traités :

```SQL
WITH
    C_0 AS(
        SELECT
            code_point
        FROM
            G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_VOIE_LITTERALIS
        UNION ALL
        SELECT
            code_point
        FROM
            G_BASE_VOIE.TEMP_ADRESSE_DOUBLON_DOMANIA_LITTERALIS
        UNION ALL
        SELECT
            code_point
        FROM
            G_BASE_VOIE.TEMP_ADRESSE_AUTRES_LITTERALIS
        UNION ALL
        SELECT
            code_point
        FROM
            G_BASE_VOIE.TEMP_ADRESSE_CORRECTE_LITTERALIS      
    ),
        
    C_1 AS( -- Sélection des seuils restants
        SELECT
            a.objectid
        FROM
            G_BASE_VOIE.TA_INFOS_SEUIL a
            INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = b.objectid
            INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = c.fid_troncon
            INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE e ON e.fid_troncon = d.objectid
            INNER JOIN G_BASE_VOIE.TA_VOIE_LITTERALIS f ON f.id_voie = e.fid_voie                       
        WHERE
            a.objectid NOT IN(331519,299591,332914,181776)
            AND a.objectid NOT IN(SELECT CAST(code_point AS NUMBER(38,0)) FROM C_0)
        GROUP BY
            a.objectid
        HAVING
            COUNT(a.objectid) = 1
    ),
```

**Dans un second temps**, on met les données au format LITTERALIS :

```SQL
C_2 AS(
    SELECT DISTINCT
        f.code_rue_g AS CODE_VOIE,
        a.objectid AS CODE_POINT,
        'ADR' AS NATURE,
        CASE
            WHEN g.complement_numero_seuil IS NULL
                THEN CAST(g.numero_seuil AS VARCHAR2(254))
            WHEN g.complement_numero_seuil IS NOT NULL
                THEN CAST(g.numero_seuil || ' ' || g.complement_numero_seuil AS VARCHAR2(254))
            END AS libelle,
        g.numero_seuil AS NUMERO,
        g.complement_numero_seuil AS REPETITION,
        'LesDeuxCotes' AS COTE,
        g.fid_seuil
    FROM
        C_1 a
        INNER JOIN G_BASE_VOIE.TA_INFOS_SEUIL g ON g.objectid = a.objectid
        INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = g.fid_seuil
        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_SEUIL c ON c.fid_seuil = b.objectid
        INNER JOIN G_BASE_VOIE.TA_TRONCON d ON d.objectid = c.fid_troncon
        INNER JOIN G_BASE_VOIE.TA_RELATION_TRONCON_VOIE e ON e.fid_troncon = d.objectid
        INNER JOIN G_BASE_VOIE.VM_TRONCON_LITTERALIS_2 f ON CAST(f.code_rue_g AS NUMBER(38,0))= e.fid_voie
    WHERE
        g.objectid NOT IN(331519,299591,332914,181776)
)
SELECT
    a.*,
    b.geom AS GEOMETRY
FROM
    C_2 a
    INNER JOIN G_BASE_VOIE.TA_SEUIL b ON b.objectid = a.fid_seuil
```

## 6. Création des deux vues matérialisées d'export des tronçons et des adresses

Ces vues matérialisées rassemblent les tronçons et les adresses mis au format litteralis dans l'étape 5.
Leur code DDL se situe ici :
    - ![creation_vm_troncon_litteralis.sql](../../sql/scripts/code_ddl/vues_materialisees/creation_vm_troncon_litteralis.sql) ;
    - ![creation_vm_adresse_litteralis.sql](../../sql/scripts/code_ddl/vues_materialisees/creation_vm_adresse_litteralis.sql) ;

## 7. Correction des secteurs de voirie

Les secteurs de voirie est l'échelle de gestion de territoire de base du service voirie. C'est à partir de ce découpage que le service répartis ses équipes sur le territoire de la MEL. Ainsi, une équipe est affecté à un secteur.

### Problème :
Les secteurs de voirie créés par le service voirie dans G_VOIRIE.SECTEUR_UT_VOIRIE utilisaient l'ancien référentiel des communes. Etant donné que nous en avons changé début 2020, les secteurs ne sont plus topologiques avec notre référentiel actuel. Il faut donc mettre à jour l'emprise des secteurs.

### Solution :
1. Import 