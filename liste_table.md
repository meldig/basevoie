# Liste des tables de la base voie.

## Les tables des données.

### ILTASEU

Table contenant les seuils (numéro de voiri) de la MEL.

### ILTASIT

Table des relations entre la table ILTASEU (seuils) et ILTATRC (tronçons). Afin d'associer un seuil à un tronçon d'une rue.

### ILTATRC

Table contenant les tronçons de la MEL. Un troçon est un linéaire entre deux carrefours.

### ILTAFILIA

Peut-être table de sauvegarde. Garde une trace du tronçon père si celui-ci est coupé, détruit ou M.

### ILTAPTZ

Table contenant les noeuds (point calva) chaque tronçon a deux noeuds. Un noeud de début et de fin. Un noeud peut être un carrefour ou une fin de voie ou une impasse.

### ILTADTN

Table des relations entre ILTAPTZ (noeuds) et ITLATRC (tronçons).

### VOIECVT

Table des relations entre VOIEVOI (voies) et ILTATRC (tronçons). Une voie est composée d'un groupe de tronçon.

### VOIEVOI

Table contenant les voies de la MEL. La voie est un sous-element de la rue. Une voie est composée d'un groupe de tronçon.

### TYPEVOIE

Table contenant les types de voie possible: rue, avenue, route...

### TA_RUE

Table contenant les rues de la MEL. La rue c'est la notion

### TA_RUEVOIE

Table des relations entre TA_RUE (rues) et VOIEVOI (voies). Afin d'associer une rue à ses voies.

### ILTALPU

Table qui contient les points d'intérêts de la MEL. Cette couche est mise à jour pas Marie-Hélène Suzanne et Marie-Christine Louis.

### TA_RUELPU

Table des relations entre ILTALPU (points d'intérêts) et TA_RUE (rue).

### ILTACOM

Table des communes de la MEL.

### REMARQUES_VOIES

Peu utilisée.

### REMARQUES_THEMATIQUES_VOIES

Voir avec le service voirie.

## Les tables d'administration.

### ADMIN_TABLES_VOIES
### ADMIN_COL_TABLES_VOIES
### ADMIN-CONFIG_GESTION_VOIES

Table contenant les paramètres configurables de l’application.

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