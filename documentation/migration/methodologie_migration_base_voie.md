# Migration de la Base Voie

## Contexte :
Dans le cadre de l'obsolescence de la technologie Flash utilisée par la plateforme DynMap permettant la saisie des tronçons, des voies et des seuils de la base voie, et de la migration des bases d'oracle 11g vers oracle 12c, il a été décidé d'utiliser QGIS pour la saisie et de profiter de la migration de la base pour en faire une refonte, afin d'en améliorer la qualité.

## Objectif de la migration :
- Améliorer la structure de la base en utilisant de noms de tables compréhensibles, en rajoutant des contraintes d'intégrité et de non-nullité et en supprimant les champs non-utilisés ;  
- Améliorer la qualité de la donnée en supprimant les voies et les tronçons n'étant plus utilisés tels que les rivières ou en supprimant les seuils qui intersectent les tronçons ou qui se situent à plus d'1km de leur tronçon d'affectation ;

## Etapes :
1. Import des données d'Oracle 11G vers Oracle 12C dans des tables temporaires ; [Lien](#Import-des-données-d'Oracle-11G-vers-Oracle-12C-dans-des-tables-temporaires)
	1.1. Import des données ;
	1.2. Vérification du bon déroulé de l'import ;
2. Création de la nouvelle structure de données dans Oracle 12C ;
3. Migration et correction des données des tables temporaires vers les tables finales ;
4. Création d'une hiérarchisation voies principales / voies secondaires ;
5. Vérification du bon déroulé de la migration ;
6. Suppression des tables temporaires ;

## Outils utilisés pour la migration

### Les fichiers bat
* ![import_donnees_tables_base_voie.bat](../../sql/scripts/code_ddl_g_base_voie/integration/import_des_donnees/import_donnees_tables_base_voie.bat) => fichier permettant d'importer toutes les tables nécessaires à la migration de la base voie ;

* ![lanceur_code_ddl_schema.bat](../../sql/scripts/code_ddl_g_base_voie/integration/creation_tables_finales/lanceur_code_ddl_schema.bat) => fichier permettant de créer la nouvelle structure de la base voie ;

* ![lanceur_creation_droits_lecture_reference.bat](../../sql/scripts/code_ddl_g_base_voie/integration/creation_tables_finales/lanceur_creation_droits_lecture_reference.bat) => fichier permettant de créer les droits de lecture et de références nécessaires à la création et à l'accès à la base voie ;

* ![lanceur_migration_base_voie_vers_tables_finales.bat](../../sql/scripts/code_ddl_g_base_voie/integration/remplissage_tables_finales/lanceur_migration_base_voie_vers_tables_finales.bat) => fichier permettant de lancer la migration et la correction les données des tables temporaires vers les tables finales ;

* ![lanceur_suppression_schema.bat](../../sql/scripts/code_ddl_g_base_voie/integration/suppression_objets_schema/lanceur_suppression_schema.bat) => fichier permettant de supprimer tous les objets de la base voie (tables, vues, vue matérialisées, déclencheurs, fonctions);

* ![lanceur_suppression_tables_d_import_temporaires.bat](../../sql/scripts/code_ddl_g_base_voie/integration/suppression_objets_schema/lanceur_suppression_tables_d_import_temporaires.bat) => fichier permettant de supprimer toutes les tables temporaires ayant servies à l'import des données d'Oracle 11G ;

### Les fichiers sql
* ![ajout_temp_code_fantoir_a_temp_voievoi.sql](../../sql/scripts/code_ddl_g_base_voie/integration/creation_tables_finales/ajout_temp_code_fantoir_a_temp_voievoi.sql) => fichier permettant de créer un champ temproaire dans la table TEMP_VOIEVOI, nécessaire à l'import dans la nouvelle structure de données ;

* ![insertion_famille_libelle_tables_finales.sql](../../sql/scripts/code_ddl_g_base_voie/integration/remplissage_tables_finales/insertion_famille_libelle_tables_finales.sql) => fichier permettant d'insérer les familles et libellés utilisés par la base voie dans les tables correspondantes du schéma G_GEO ;

* ![migration_tables_temporaires_vers_tables_finales.sql](../../sql/scripts/code_ddl_g_base_voie/integration/remplissage_tables_finales/migration_tables_temporaires_vers_tables_finales.sql) => fichier permettant de migrer et de corriger les données des tables temporaires d'import vers les tables finales de la base voie ;

* ![verification_nombre_de_donnees_base_originelle.sql](../../sql/scripts/code_ddl_g_base_voie/integration/verification_des_donnees/verification_nombre_de_donnees_base_originelle.sql) => fichier décomptant le nombre d'entités par table dans la base voie d'oracle 11g ;

* ![verification_nombre_de_donnees_importees.sql](../../sql/scripts/code_ddl_g_base_voie/integration/verification_des_donnees/verification_nombre_de_donnees_importees.sql) => fichier décomptant le nombre d'entités importées par table temporaires dans oracle 12c ;

* ![verification_nombre_de_donnees_base_finale.sql](../../sql/scripts/code_ddl_g_base_voie/integration/verification_des_donnees/verification_nombre_de_donnees_base_finale.sql) => fichier décomptant le nombre d'entités importées dans les tables finales d'oracle 12c ;

* ![suppression_tables_d_import_temporaires.sql](../../sql/scripts/code_ddl_g_base_voie/integration/suppression_objets_schema/suppression_tables_d_import_temporaires.sql) => fichier permettant de supprimer les tables temporaires d'import de la base voie ;

* ![suppression_tables_declencheurs_fonctions_MTD_index_contraintes.sql](../../sql/scripts/code_ddl_g_base_voie/integration/suppression_objets_schema/suppression_tables_declencheurs_fonctions_MTD_index_contraintes.sql) => fichier permettant de supprimer tous les objets de la base voie finale sur oracle 12c ;

### les fichiers csv
* ![TEMP_CODE_FANTOIR.csv](../../sql/scripts/code_ddl_g_base_voie/integration/import_des_donnees/TEMP_CODE_FANTOIR.csv) => fichier contenant les codes fantoir de toutes les voies de la MEL, récupérés auprès de ![collectivites-locales.gouv.fr.csv](https://www.collectivites-locales.gouv.fr), permettant de télécharger les codes au niveau régional et non pas uniquement au niveau national. Le fichier est ensuite mis en forme en local par le gestionnaire de données : fantoir (3 caractères pour la direction départementale + 3 caractères du code commune + les 4 caractères du code rivoli) ; rivoli (sur 4 caractères maximum) ; clé de contrôle (1 lettre(la dernière du code fantoir));

* ![TEMP_FAMILLE.csv](../../sql/scripts/code_ddl_g_base_voie/integration/import_des_donnees/TEMP_FAMILLE.csv) => fichier contenant toutes les familles nécessaires à la base voie ;

* ![TEMP_LIBELLE.sql](../../sql/scripts/code_ddl_g_base_voie/integration/import_des_donnees/TEMP_LIBELLE.sql) => fichier contenant tous les libelles nécessaires à la base voie ;

* TEMP_AGENT => fichier contenant les pnoms des agents chargés de mettre à jour et de gérer la base voie. Afin de préserver la confidentialité de ces informations, ces données sont stockées en local ;


## 1. Import des données d'Oracle 11G vers Oracle 12C dans des tables temporaires [Lien](#Import-des-données-d'Oracle-11G-vers-Oracle-12C-dans-des-tables-temporaires-;)

### 1.1. Import des données

* **Objectif :** importer dans oracle 12c les données de prod d'oracle 11g telles qu'elles, ainsi que les codes fantoirs, les pnoms des agents, les familles et les libellés nécessaires à la base voie. Cette méthode permet d'effectuer des modifications uniquement dans des tables temporaires, sans toucher aux tables de prod ;

* **Méthode :**
1. Assurez-vous que vous disposez en local du fichier *TEMP_AGENT* ;
2. Double-cliquez sur le fichier ![import_donnees_tables_base_voie.bat](../../sql/scripts/code_ddl_g_base_voie/integration/import_des_donnees/import_donnees_tables_base_voie.bat) et renseignez les informations demandées ;
3. Si certaines données sont déjà en base, telles que les familles et libellés (utilisées dans d'autres projets), il vous suffit de modifier le code du fichier en mettant '::' devans la ligne d'import de la table afin de la mettre en commentaire ;

### 1.2. Vérification du bon déroulé de l'import

* **Objectif :** Vérifier que toutes les données ont bien été importées dans oracle 12c ;

* **Méthode :** Dans SqlDevelopper, faites fonctionner les codes présents dans les fichiers ![verification_nombre_de_donnees_base_originelle.sql](../../sql/scripts/code_ddl_g_base_voie/integration/verification_des_donnees/verification_nombre_de_donnees_base_originelle.sql) et ![verification_nombre_de_donnees_importees.sql](../../sql/scripts/code_ddl_g_base_voie/integration/verification_des_donnees/verification_nombre_de_donnees_importees.sql) insérer les résultats dans un tableur excel afin de les comparer. Si vous avez les mêmes nombres d'entités c'est que tout va bien, sinon c'est qu'il y a un problème.

* **En cas de problème :**
1. Supprimez toutes les tables d'import via le fichier ![lanceur_suppression_tables_d_import_temporaires.bat](../../sql/scripts/code_ddl_g_base_voie/integration/suppression_objets_schema/lanceur_suppression_tables_d_import_temporaires.bat) et de réimportez les tables une par une en mettant les autres en commentaires (parfois cela peut régler le problème) ;
2. Si le problème concerne des tables géométriques, décomptez le nombre de géométries valides dans la table de prod d'oracle 11g et  vérifiez sil correspond au nombre d'entités importées. Si c'est le cas, cela signifie que vous avez des erreurs de géométrie dans les tables de prod originelles qu'Ogr2ogr n'arrive pas à importer. Pour ce cas, il faut créer une table temporaire dans oracle 11g (TEMP_ + nom de la table) dans laquelle importer toutes les données de la table en question, corriger les erreurs, supprimer les tables temporaires dans oracle 12c et retenter l'import. **N'oubliez pas de mettre un commentaire pour la table temporaire dans Oracle 11g.**

## 2. Création de la nouvelle structure de données dans Oracle 12C

* **Objectif :** Créer la structure de tables, vues, déclencheurs et fonctions de la future base voie dans Oracle 12c.

* **Méthode :** 
1. Vérifier que le fichier *temp_code_ddl_schema.sql* ne se trouve pas dans le dossier integration, sinon supprimez-le ;
2. Double-cliquez sur le fichier ![lanceur_code_ddl_schema.bat](../../sql/scripts/code_ddl_g_base_voie/integration/creation_tables_finales/lanceur_code_ddl_schema.bat) et renseignez les informations demandées ;
3. Dans Sql/Developper, lancez le code du fichier ![creation_vm_temp_doublon_seuil_g_sidu.sql](../../sql/scripts/code_ddl_g_base_voie/vues_materialisees/creation_vm_temp_doublon_seuil_g_sidu.sql). Ce fichier peut pas être lancé via SqlPlus en raison de la présence de CTE qui provoquent des erreurs ;

* **Information complémentaire :**
Le fichier *lanceur_code_ddl_schema.bat* fait la compilation de tous les codes DDL des tables, vues, déclencheurs et fonctions présents dans le dossier *code_ddl_g_base_voie* dans le fichier *temp_code_ddl_schema.sql* qu'il lance ensuite dans oracle pour créer la structure du schéma en base.  
Il est conseillé de toujours supprimer le fichier *temp_code_ddl_schema.sql* avant de relancer l'import. Sa suppression juste après l'import **ne l'est pas, par contre**, car en cas d'erreur cela permet de vérifier rapidement le code qui a été chargé en base.

## 3. Migration et correction des données des tables temporaires vers les tables finales

* **Objectif :** Migrer les données des tables temporaires vers les tables finales dans Oracle 12c tout en la corrigeant.

* **Description du fichier :** Pour comprendre le fichier de migration, veuillez lire la ![documentation y afférent](migration_tables_temporaires_vers_tables_finales.md).

* **Méthode :** Double-cliquez sur le fichier ![lanceur_migration_base_voie_vers_tables_finales.bat](../../sql/scripts/code_ddl_g_base_voie/integration/remplissage_tables_finales/lanceur_migration_base_voie_vers_tables_finales.bat) qui exécutera le code du fichier ![migration_tables_temporaires_vers_tables_finales.sql](../../sql/scripts/code_ddl_g_base_voie/integration/remplissage_tables_finales/migration_tables_temporaires_vers_tables_finales.sql).

* **En cas de problème :** 
Il peut arriver que le point de sauvegarde de la proccédure du fichier *migration_tables_temporaires_vers_tables_finales.sql* pose problème. Dans ce cas, veuillez exécuter le code du fichier *migration_tables_temporaires_vers_tables_finales.sql* dans SqlDevelopper.  
Si le problème persiste, exécutez les codes de la proccédure un par un afin de localiser celui qui pose problème afin de le corriger.
Une fois le problème réglé, veuillez supprimer la structure via le fichier ![lanceur_code_ddl_schema.bat](../../sql/scripts/code_ddl_g_base_voie/integration/lanceur_code_ddl_schema.bat), puis la recréer via le fichier ![lanceur_code_ddl_schema.bat](../../sql/scripts/code_ddl_g_base_voie/integration/lanceur_code_ddl_schema.bat) et enfin, relancer la proccédure du fichier ![migration_tables_temporaires_vers_tables_finales.sql](../../sql/scripts/code_ddl_g_base_voie/integration/remplissage_tables_finales/migration_tables_temporaires_vers_tables_finales.sql) directement dans SqlDevelopper.  
Cette procédure permet d'avoir toujours un code correct après chaque recréation de la base dans oracle 12c.

## 4. Création d'une hiérarchisation voies principales / voies secondaires
* **Objectif :** Remplir la table *TA_HIERARCHISATION_VOIE* permettant d'associer les voies secondaires à leur voie principale et de conserver cette notion de hiérarchie entre les voies.

* **Méthode :**  
1. Double-cliquez sur le fichier ![lanceur_hierarchisation_des_voies.bat](../../sql/scripts/code_ddl_g_base_voie/integration/remplissage_tables_finales/lanceur_hierarchisation_des_voies.bat) permettant de compiler le code de toutes les VM nécessaires à la hiérarchisation des voies. Cela produira le fichier *temp_hierarchie_voie.sql*, dans le dossier *integration*, qui devra être lancé à l'étape suivante ;
2. Lancez le code du fichier ![temp_hierarchie_voie.sql](../../sql/scripts/code_ddl_g_base_voie/integration/remplissage_tables_finales/temp_hierarchie_voie.sql) dans Sql/Developper sur le schéma de la base voie ;

## 5. Vérification du bon déroulé de la migration

* **Objectif :** Vérifier que le nombre d'entités présentes dans les tables finales correspond au nombre d'entités importées dans les tables temporaires depuis Oracle 11g. Attention, les nombres doivent **correspondre**, mais pas être rigoureusement identiques, puisque la migration des tables temporaires vers les tables finales fait une correction de la données (Exemple : suppression des seuils situés à 1km ou plus de leur tronçon d'affectation).

* **Méthode :** Dans SqlDevelopper, exécutez le code du fichier ![verification_nombre_de_donnees_base_finale.sql](../../sql/scripts/code_ddl_g_base_voie/integration/verification_des_donnees/verification_nombre_de_donnees_base_finale.sql) et insérez le résultat dans le tableur créé à l'étape 1.2. Si le nombre d'entités est similaire au nombre d'entités des données importées dans les tables temporaires, alors on considère que la migration s'est faite correctement.  
Si vérification de cette partie,pour le moment encore sommaire, mais en cours de développement.

## 6. Suppression des tables temporaires

* **Objectif :** Supprimer les tables temporaires ayant servie à importer les données dans oracle 12c.

* **Méthode :** Double-cliquez sur le fichier ![lanceur_suppression_tables_d_import_temporaires.bat](../../sql/scripts/code_ddl_g_base_voie/integration/suppression_objets_schema/lanceur_suppression_tables_d_import_temporaires.bat) et renseignez les informations demandées.