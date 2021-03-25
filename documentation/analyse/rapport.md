# Les Problèmes de la base voie

## Sommaire :

1. un schéma sans contrainte d'intégrité
   1.1 Différences entre la documentation et la réalité en base
   1.2 Absences de clés primaires
2. Des données invalides dans les tables filles
   2.1 Les tronçons
   2.2 Les voies
   2.3 Les seuils
   2.4 Les noeuds
   2.5 Les rues et les fantoirs
   2.6 Les points d'intérêt
3. Des géométries sans restriction sur leurs types
   3.1 Présentation des index spatiaux
   3.2 Les erreurs de géométries
4. Les tablespaces

## 1. Un schéma sans contrainte d'intégrité

### 1.1 Différences entre la documentation et la réalité en base

Si on retrouve les 19 tables dans la ![documentation](/doc_i2g_dev_application_2013.pdf) et en base oracle, ce n'est pas le cas des contraintes d'intégrité.

Pour rappel, ces contraintes ont pour but de sécuriser les relations entre tables, en vérifiant que les valeurs présentes dans les clés étrangères des tables filles sont bien présentes dans les tables parentes. Or, comme on peut le voir dans le tableau ci-dessous, il devrait y avoir 12 clés étrangères.  

###### figure n°1 : les clés étrangères de la base voie issue de la documentation

| Nom_Table              | Nom_Colonne  | Type_Donnees  | Type_Contrainte |
|:---------------------- |:------------ |:------------- |:--------------- |
| ILTASEU                | CDCOTE       | varchar(5)    | FK              |
| ILTASIT                | IDSEUI       | decimal(22,7) | FK              |
| ILTASIT                | CNUMTRC      | decimal(22,5) | FK              |
| ILTADTN                | CNUMPTZ      | decimal(22,8) | FK              |
| ILTADTN                | CNUMTRC      | decimal(22,5) | FK              |
| VOIECVT                | CCOMVOI      | decimal(22,7) | FK              |
| VOIECVT                | CNUMTRC      | decimal(22,5) | FK              |
| VOIEVOI                | CCODTVO      | char(4)       | FK              |
| ILTALPU                | CDSFAMILLE   | varchar(5)    | FK              |
| ILTALPU                | CLEF_ORIGINE | varchar(5)    | FK              |
| ILTALPU                | SYMBOLE_LIEU | varchar(50)   | FK              |
| ADMIN_COL_TABLES_VOIES | TYPE_OBJET   | varchar(20)   | FK              |

L'absence de contrainte de clé étrangère en base signifie qu'il peut potentiellement y avoir des doublons ou des valeurs manquantes. Le fait qu'il n'y ait aucune contrainte d'intégrité signifie que *TOUT* dépend de la saisie et de la mise à jour de la donnée par les utilisateurs/gestionnaires et par les triggers. Or, les triggers peuvent être réécris sans avoir à les supprimer d'abord ce qui rend leur modification très facile.

Ensuite, même si les utilisateurs sont guidés par des formulaires lors de la saisie, il se peut (notamment en télétravail), que la connexion à la base soit perdue momentanément. Ainsi seule une partie des tables serait remplie et non *toutes* les tables concernées par la modification. Là où la clé étrangère invaliderait la saisie/modification, son absence permet la saisie/modification des données, mais sans aucune garantie que l'intégrité des données soit respectée. Il n'y a donc aucune sécurité de la donnée.  

Ainsi, on retrouve :  

* 7034 identifiants de seuil (*IDSEUI*) dans la table *G_SIDU.ILTASIT* qui sont pourtant absents de la table parente *G_SIDU.ILTASEU* ;
* 3 identifiants de tronçons (*CNUMTRC*) dans la table *G_SIDU.ILTASIT* qui sont pourtant absents de la table parente *G_SIDU.ILTATRC* ;

### 1.2 Absences de clés primaires

Sur les 19 tables de la base voie, seules 8 disposent de clés primaires (cf. figure n°2), ce qui pose trois problèmes :  

###### figure n°2 : Tables disposant de clés primaires en base

| Nom_Table       | Nom_Colonne | Nom_Contrainte     | Type_Contrainte | Statut  | Validite  | Nom_Index          |
|:--------------- |:----------- |:------------------ |:--------------- |:------- |:--------- |:------------------ |
| ILTALPU         | CNUMLPU     | PK_ILTALPU         | PRIMARY KEY     | ENABLED | VALIDATED | PK_ILTALPU         |
| ILTAPTZ         | CNUMPTZ     | PK_ILTAPTZ         | PRIMARY KEY     | ENABLED | VALIDATED | PK_ILTAPTZ         |
| ILTASEU         | IDSEUI      | PK_ILTASEU         | PRIMARY KEY     | ENABLED | VALIDATED | PK_ILTASEU         |
| ILTASIT         | IDSEUI      | ILTASIT_PK         | PRIMARY KEY     | ENABLED | VALIDATED | ILTASIT_PK         |
| ILTASIT         | CNUMTRC     | ILTASIT_PK         | PRIMARY KEY     | ENABLED | VALIDATED | ILTASIT_PK         |
| ILTATRC         | CNUMTRC     | PK_ILTATRC         | PRIMARY KEY     | ENABLED | VALIDATED | PK_ILTATRC         |
| REMARQUES_VOIES | ID_REMARQUE | PK_REMARQUES_VOIES | PRIMARY KEY     | ENABLED | VALIDATED | PK_REMARQUES_VOIES |
| TYPEVOIE        | CCODTVO     | TYPEVOIE_PK        | PRIMARY KEY     | ENABLED | VALIDATED | TYPEVOIE_PK        |
| VOIEVOI         | CCOMVOI     | VOIEVOI_PK         | PRIMARY KEY     | ENABLED | VALIDATED | VOIEVOI_PK         |

1. 11 tables n'ont pas d'identifiant unique pour leurs données ;
2. Il peut y avoir des doublons dans les champs servant d'identifiant de la donnée ;
3. Les recherches sur ces tables sont allongées puisqu'il n'y a pas d'index de clé primaire. De plus, leur absence empêche l'affichage de ces tables dans certaines applications ;  

###### figure n°3 : Tables sans clé primaire en base

| Nom_Table_Sans_PK          |
|:-------------------------- |
| ADMIN_LISTE_COTE           |
| ILTAFILIA                  |
| ILTADTN                    |
| VOIECVT                    |
| ADMIN_LISTE_FAMILLE_POI    |
| ADMIN_LISTE_ORIGINE_POI    |
| ADMIN_LISTE_SYMBOLE        |
| ADMIN_TABLES_VOIES         |
| ADMIN_COL_TABLES_VOIES     |
| ADMIN_CONFIG_GESTION_VOIES |
| ADMIN_USERS_GESTION_VOIES  |

## 2. Des données invalides dans les tables filles

En vérifiant l'intégrité des données, nous nous sommes aperçus que de nombreuses données inexistantes dans les tables parentes étaient pourtant toujours présentes dans les tables filles.Cela s'explique par l'absence de suppression en cascade normalement induite par l'usage de contraintes de clés étrangères.

### 2.1 Les tronçons

#### Relation *ILTASIT* / *ILTATRC*

###### Figure n°4 : Relation entre *ILTASIT* et *ILTATRC*

![relation_ILTASIT_ILTATRC.PNG](/documentation/analyse/images_base_voie/relation_ILTASIT_ILTATRC.png)

Comme on peut le voir dans la figure ci-dessus, *ILTASIT* est la table fille de la table parente *ILTATRC*.  
Cependant, on note 112 tronçons présents dans la table fille, mais absents des tronçons valides de la table parente. Il se trouve que 109 tronçons présents dans *ILTASIT* sont invalides dans *ILTATRC* et 3 tronçons présents dans *ILTASIT* sont carrément absents de la table *ILTATRC*. L'intégrité des données n'est donc pas respectée entre les deux tables et il n'y a manifestement pas de mise à jour automatique des données de la table fille en fonction de la validité des données de la table parente.  
De plus, la table fille ne dispose d'aucun champ discriminant la validité de la donnée.

#### Relation *ILTADTN* / *ILTATRC*

###### Figure n°5 : Relation entre *ILTADTN* et *ILTATRC*

![relation_ILTASIT_ILTATRC.PNG](/documentation/analyse/images_base_voie/relation_ILTADTN_ILTATRC.png)

Comme on peut le voir dans la figure ci-dessus, *ILTADTN* est la table fille de la table parente *ILTATRC*.  
Cependant, 7521 tronçons présents dans la table fille (*ILTADTN*) sont invalides dans la table parente (*ILTATRC*). Il n'y a manifestement pas de mise à jour automatique des données de la table fille en fonction de la validité des données de la table parente.  
De plus, la table fille ne dispose d'aucun champ discriminant la validité de la donnée.

#### Relation *VOIECVT* / *ILTATRC*

###### Figure n°6 : Relation entre *VOIECVT* et *ILTATRC*

![relation_VOIECVT_ILTATRC.PNG](/documentation/analyse/images_base_voie/relation_VOIECVT_ILTATRC.png)

Comme on peut le voir dans la figure ci-dessus, *VOIECVT* est la table fille de la table parente *ILTATRC*.  
Cependant, 7507 tronçons présents dans la table fille (*VOIECVT*) sont invalides dans la table parente (*ILTATRC*). Il n'y a manifestement pas de mise à jour automatique des données de la table fille en fonction de la validité des données de la table parente.  
De plus, la table fille ne dispose d'aucun champ discriminant la validité de la donnée.

#### Relation *ILTAFILIA* / *ILTATRC*

###### Figure n°7 : Relation entre *ILTAFILIA* et *ILTATRC*

![relation_ILTAFILIA_ILTATRC.PNG](/documentation/analyse/images_base_voie/relation_ILTAFILIA_ILTATRC.png)

Comme on peut le voir dans la figure ci-dessus, *ILTAFILIA* est la table fille de la table parente *ILTATRC*. 
Cependant, on note que 641 tronçons présents dans *ILTAFILIA* sont invalides dans la table parente *ILTATRC*. Il n'y a manifestement pas de mise à jour automatique des données de la table fille en fonction de la validité des données de la table parente.  
De plus, la table fille ne dispose d'aucun champ discriminant la validité de la donnée.

### 2.2 Les voies

#### Relation *VOIEVOI* / *TYPEVOIE*

###### Figure n°8 : Relation entre *VOIEVOI* et *TYPEVOIE*

![relation_VOIEVOI_TYPEVOIE.PNG](/documentation/analyse/images_base_voie/relation_VOIEVOI_TYPEVOIE.png)

Comme on peut le voir dans la figure ci-dessus, *VOIEVOI* est la table fille de la table parente *TYPEVOIE*.  
Cependant, 3 voies présentes dans la table fille *VOIEVOI* sont absentes dans la table parente *TYPEVOIE*, ce qui est rendu possible par l'absence de contrainte d'intégrité.

#### Relation *VOIECVT* / *VOIEVOI*

###### Figure n°9 : Relation entre *VOIECVT* et *VOIEVOI*

![relation_VOIECVT_VOIEVOI.PNG](/documentation/analyse/images_base_voie/relation_VOIECVT_VOIEVOI.png)

Comme on peut le voir dans la figure ci-dessus, *VOIECVT* est la table fille de la table parente *VOIEVOI*.
Cependant, 1021 voies présentes dans la table fille *VOIECVT* sont invalides dans la table parente *VOIEVOI*, il n'y a donc aucune mise à jour de la table fille en fonction de la validité de la donnée de la table parente.  
De plus, la table fille ne dispose d'aucun champ discriminant la validité de la donnée.

#### Relation *TA_RUEVOIE* / *VOIEVOI*

###### Figure n°10 : Relation entre *TA_RUEVOIE* et *VOIEVOI*

![relation_TA_RUEVOIE_VOIEVOI.PNG](/documentation/analyse/images_base_voie/relation_TA_RUEVOIE_VOIEVOI.png)

Comme on peut le voir dans la figure ci-dessus, *TA_RUEVOIE* est la table fille de la table parente *VOIEVOI*.
Cependant, 486 voies présentes dans la table fille *TA_RUEVOIE* sont invalides dans la table parente *VOIEVOI*, il n'y a donc aucune mise à jour de la table fille en fonction de la validité de la donnée de la table parente.  
De plus, la table fille ne dispose d'aucun champ discriminant la validité de la donnée.

### 2.3 Les seuils

#### Relation *ILTASIT* / *ILTASEU*

###### Figure n°11 : Relation entre *ILTASIT* et *ILTASEU*

![relation_ILTASIT_ILTASEU.PNG](/documentation/analyse/images_base_voie/relation_ILTASIT_ILTASEU.PNG)

Comme on peut le voir dans la figure ci-dessus, *ILTASIT* est la table fille de la table parente *ILTASEU*.
Cependant, 7029 seuils présents dans la table fille *ILTASIT* sont absents dans la table parente *ILTASEU*.  
De plus, ni la table fille ni la table parente ne disposent de champ discriminant la validité de la donnée.

### 2.4 Les noeuds

#### Relation *ILTADTN* / *ILTAPTZ*

###### Figure n°12 : Relation entre *ILTADTN* et *ILTAPTZ*

![relation_ILTADTN_ILTATRC.PNG](/documentation/analyse/images_base_voie/relation_ILTADTN_ILTAPTZ.png)

Comme on peut le voir dans la figure ci-dessus, *ILTADTN* est la table fille de la table parente *ILTAPTZ*.
Cependant, 1927 noeuds présents dans la table fille *ILTADTN* sont invalides dans la table parente *ILTAPTZ*, il n'y a donc aucune mise à jour de la table fille en fonction de la validité de la donnée de la table parente.  
De plus, la table fille ne dispose d'aucun champ discriminant la validité de la donnée.  

### 2.5 Les rues et les fantoirs

#### Relation *TA_RUEVOIE* / *TA_RUE*

###### Figure n°13 : Relation entre *TA_RUEVOIE* et *TA_RUE*

![relation_TA_RUEVOIE_TA_RUE.PNG](/documentation/analyse/images_base_voie/relation_TA_RUEVOIE_TA_RUE.PNG)

Comme on peut le voir dans la figure ci-dessus, *TA_RUEVOIE* est la table fille de la table parente *TA_RUE*.
Cependant, 19 fantoirs présents dans la table fille *TA_RUEVOIE* sont absents dans la table parente *TA_RUE*, ce qui résulte de l'absence de contrainte d'intégrité.  

#### Relation *TA_RUELPU* / *TA_RUE*

###### Figure n°14 : Relation entre *TA_RUELPU* et *TA_RUE*

![relation_TA_RUELPU_TA_RUE.PNG](/documentation/analyse/images_base_voie/relation_TA_RUELPU_TA_RUE.PNG)

Comme on peut le voir dans la figure ci-dessus, *TA_RUELPU* est la table fille de la table parente *TA_RUE*.
Cependant, 28 fantoirs présents dans la table fille *TA_RUELPU* sont absents dans la table parente *TA_RUE*, ce qui résulte de l'absence de contrainte d'intégrité.  

### 2.6 Les points d'intérêt

#### Relation *TA_RUELPU* / *ILTALPU*

###### Figure n°15 : Relation entre *TA_RUELPU* et *ILTALPU*

![relation_TA_RUELPU_ILTALPU.PNG](/documentation/analyse/images_base_voie/relation_TA_RUELPU_ILTALPU.PNG)

Comme on peut le voir dans la figure ci-dessus, *TA_RUELPU* est la table fille de la table parente *ILTALPU*.
Cependant, 7 points d'intérêt présents dans la table fille *TA_RUELPU* sont inexistantes dans la table parente *ILTALPU*, il n'y a donc aucune mise à jour de la table fille en fonction de la validité de la donnée de la table parente.  
De plus, la table fille ne dispose d'aucun champ discriminant la validité de la donnée.  

## 3. Des géométries sans restriction sur leurs types

### 3.1 Présentation des index spatiaux

Les index spatiaux dans oracle permettent de limiter les types de géométries enregistrés dans la table, de spécifier le tablespace et le worktablespace utilisés pour traiter les géométries. La présence d'index spatiaux permet aussi d'accélérer les traitements géométriques.

Cependant comme on peut le voir dans la figure n°4, certaines tables disposant d'un champ géométrique n'ont pas d'index spatial. Cela est d'autant plus problématique qu'il s'agit des tables de lignes, de noeuds et de seuils de la base voie, qui sont fréquemment mis à jour. Les utilisateurs et les applications peuvent donc en théorie enregistrer n'importe quelle type de géométrie dans ces bases. En outre, puisqu'aucun tablespace ni worktablespace n'est spécifié, nous supposons que tablespaces et workspaces par défaut sont utilisés, ce qui ne correspond pas aux tables normalement utilisées pour les index spatiaux.

###### figure n°16 : Les index spatiaux en base

| TABLE                       | INDEX                          | UNIQUENESS | STATUS | INDEX_TYPE | PARAMETERS                                                                  |
|:--------------------------- |:------------------------------ |:---------- |:------ |:---------- |:--------------------------------------------------------------------------- |
| ILTALPU                     | ILTALPU_SIDX                   | NONUNIQUE  | VALID  | DOMAIN     | sdo_indx_dims=2                                                             |
| ILTAPTZ                     | ILTAPTZ_SIDX                   | NONUNIQUE  | VALID  | DOMAIN     | NULL                                                                        |
| ILTASEU                     | ILTASEU_SIDX                   | NONUNIQUE  | VALID  | DOMAIN     | NULL                                                                        |
| ILTATRC                     | ILTATRC_SIDX                   | NONUNIQUE  | VALID  | DOMAIN     | NULL                                                                        |
| REMARQUES_THEMATIQUES_VOIES | REMARQUES_THEMATIQUES_VOI_SIDX | NONUNIQUE  | VALID  | DOMAIN     | LAYER_GTYPE = MULTIPOLYGON WORK_TABLESPACE=DATA_TEMP TABLESPACE=ISPA_g_SIDU |
| REMARQUES_VOIES             | REMARQUES_VOIES_SIDX           | NONUNIQUE  | VALID  | DOMAIN     | sdo_indx_dims=2, layer_gtype=COLLECTION                                     |

De plus, pour les tables disposant d'un index spatial nous remarquons les problèmes suivants :

* **ILTALPU :** seul le paramètre SDO_INDX_DIMS (autrement dit la dimension) est renseigné. Il n'y a aucune contrainte sur les types de géométries et aucun tablespace n'est spécifié ;
* **REMARQUES_THEMATIQUES_VOIES :** le tablespace utilisé est *ISPA_G_SIDU* qui était anciennement utilisé pour les index spatiaux. Il faudrait le rediriger vers le tablespace *INDX_G_SIDU* utilisé actuellement ;
* **REMARQUES_VOIES :** le type de géométrie est *COLLECTION*, la table accepte donc tous les types de géométries. Or cela va poser problème si on passe sur qgis car ce dernier différencie les types de géométries par table. En outre, d'un point de vue de gestionnaire de base de données une table dispose d'un et d'un seul type de géométrie, cela permet de gérer efficacement la donnée et répond aux normes INSPIRE. Par ailleurs, aucun tablespace ni worktablespace n'est spécifié ;  

Pour rappel certaines applications, comme QGIS, ne reconnaissent une table en tant que table géométrique *QUE* si elle dispose d'un index spatial.

### 3.2 Les erreurs de géométries

On dénombre en tout 21 erreurs de géométrie dans les tables de la base voie sur des objets tagués en *valides*, ce qui est certes peu, mais indique qu'il n'y a pas de vérification de la validité des géométries et que dans les applications utilisées ces objets peuvent ne pas apparaître. Il serait donc bon de faire des triggers de vérification et de correction des géométries pour tables spatiales de la base.

À titre d'exemple, nous avons rencontré ce problème lors de la création de dossiers dans *GEO.TA_GG_GEO* : parfois la saisie du périmètre d'un dossier de récolement dans DynMap provoque l'erreur 13028, ce qui l'empêche d'apparaître dans qgis alors que la donnée apparaît en base. Le problème a été réglé par un trigger qui corrige l'erreur 13028 avant l'insertion de la géométrie en base.

## 4. Les tablespaces

Toutes les tables de la base voie utilisent encore le tablespace *DATA_G_SIDU*, comme au moment où l'on distinguait les tablespaces utilisés soit pour les index spatiaux, soit pour les autres index. Or nous sommes passés, depuis un certain temps déjà, sur un tablespace préfixé par "INDX_" pour TOUS les index.

Le souci est que cette utilisation des tablespace ne suit pas la méthode actuelle, donc si certains tablespaces sont supprimés car non utilisé en théorie, certaines se retrouveront sans index, ce qui posera un problème. A voir également l'impact que cela aura sur la donnée même.
