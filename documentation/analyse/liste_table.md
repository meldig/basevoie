# Liste des tables de la base voie.

## Les tables des données.

### ILTASEU

Table contenant les seuils (numéro de voirie) de la MEL.

### ILTASIT

Table des relations entre la table ILTASEU (seuils) et ILTATRC (tronçons). Afin d'associer un seuil à un tronçon d'une voie.

### ILTATRC

Table contenant les tronçons de la MEL. Un tronçon est un linéaire entre deux carrefours.

### ILTAFILIA

Table de sauvegarde gardant une trace du tronçon père si celui-ci est coupé ou détruit.

### ILTAPTZ

Table contenant les noeuds de chaque tronçon. Chaque tronçon a deux noeuds. Un noeud de début et de fin. Un noeud peut être un carrefour entre deux voies, une fin de voie ou une impasse.

### ILTADTN

Table des relations entre ILTAPTZ (noeuds) et ITLATRC (tronçons).

### VOIECVT

Table des relations entre VOIEVOI (voies) et ILTATRC (tronçons). Une voie est composée d'un ou plusieurs tronçons.

### VOIEVOI

Table contenant les voies de la MEL. La voie est un sous-élément de la rue. Une voie est composée d'un ou plusieurs de tronçons.

### TYPEVOIE

Table contenant les types de voie possibles: rue, avenue, route...

### TA_RUE

Table contenant les rues de la MEL. La rue c'est la notion. Cette table avait été faite afin de comparer les voies de la mairie de de Lille et celles de la MEL.

### TA_RUEVOIE

Table des relations entre TA_RUE (rues) et VOIEVOI (voies). Afin d'associer une rue à ses voies.

### ILTALPU

Table qui contient les points d'intérêts de la MEL. Cette couche est mise à jour pas Marie-Hélène Suzanne et Marie-Christine Louis. Cette table se nomme ILTALPU car initialement les points contenus dans la table étaient appelés *Lieux Publics*

### TA_RUELPU

Table des relations entre ILTALPU (points d'intérêts) et TA_RUE (rue).

### ILTACOM

Table des communes de la MEL. Cette table est située dans le schéma __SIDU__.

### REMARQUES_VOIES

Peu utilisée.

### REMARQUES_THEMATIQUES_VOIES

Voir avec le service voirie.

## Les tables d'administration.

### ADMIN_TABLES_VOIES

Table indiquant les informations générales des tables de la base voie, c'est-à-dire son id dans DynMap, son schéma d'appartenance, la séquence d'incrémentation de sa PK, les colonnes de PK, de géométrie, de validité, de date de validité etc. Cette table propose un résumé rapide de chaque table (sans pour autant les commenter).

### ADMIN_COL_TABLES_VOIES

Cette table propose un résumé succint des champs des tables de la base voie. Elle donne aussi des informations sur les tables jointes, leur schéma d'appartenance, leur type de donnée et leur nom, mais sans leur commentaire ainsi que des informations sur les champs de jointure entre les tables de la base voie. Néanmoins il faut préciser qu'il n'y a pas de contrainte de jointure entre les tables.

### ADMIN_CONFIG_GESTION_VOIES

Table contenant les paramètres configurables de l’application. Plus précisément le rayon de recherche en mètre permettant l'accrochage d'un noeud dans DynMap, lors de la saisie/modification de tronçons. **Mais la fonction d'accrochage dans DynMap n'a jamais marché !!!**

### ADMIN_USERS_GESTION_VOIES

Liste des utilisateurs DynMap avec leurs droits d’utilisation de l’application. Cette table est mise à jour via la fonction d’administration de l’application.

## Les tables de référence.

### ADMIN_LISTE_COTE

Table de référence contenant les données de la liste « côté » de la voie.

### ADMIN_LISTE_FAMILLE_POI

Table de référence contenant les données de la liste « Famille de POI ».

### ADMIN_LISTE_ORIGINE_POI

Table de référence contenant les données de la liste « Origine POI ».

### ADMIN_LISTE_SYMBOLE

Table de référence contenant les données de la liste « Symbole » du POI.
