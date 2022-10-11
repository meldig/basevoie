# Corrections de la Base Voie réalisées au 10/10/2022 et à venir

## Pour Literalis

Ces modifications ont été réalisées pour cette application utilisée par la DEPV et n'ont pas pu être reversé dans la base de production :

- Suppression des seuils intersectant les tronçons ;
- Suppression des seuils en doublon dont la distance par rapport à leur tronçon est la plus grande au sein des doublons ;
- Suppression des seuils situés à 1km ou plus de leur tronçon d'affectation ;
- Suppression des relations tronçons/seuils invalides dues à la suppression des seuils ci-dessus ;
- Suppression des voies physiques en doublons de géométrie : on ne garde que celles ayant l'identifiant minimum au sein des doublons ;
- Identification des voies secondaires auxquelles on a affecté le même nom de voie que leur voie principale d'affectation ;
- Correction des noms de voies situées dans les communes de Lomme et Lille-Hellemmes en mettant le nom de la commune associée entre parenthèses en suffixe du nom afin d'éviter d'avoir deux rue du Général de Gaulle situées à Lille, mais localisées à deux endroits différents ;
- Suppression des relations de tronçons invalides à certaines voies valides et inversement ;
- Mise à jour du code INSEE des tronçons situés en-dehors des limites de la MEL (celui de la commune la plus proche lui est affecté) ;
- Suppression des voies de type ruisseau, rivière, canal, car absents de la table G_SIDU.TYPEVOIE dû à un changement de méthode de saisie non finalisé ;
- Suppression des types de voies dont libellé est null ;
- Quand un tronçon est affecté à plusieurs voies, on créée un identifiant de tronçon virtuel pour celui dont l'identifiant est le plus grand au sein des doublons ;
- Pour les tronçons disposant de plusieurs domanialités, on priorise la domanialité qui n'est pas dans la liste suivante : 'VOIE PRIVEE ENTRETENUE PAR LA CUDL','VOIE PRIVEE FERMEE','VOIE PRIVEE OUVERTE','AUTRE VOIE PRIVEE','DECLASSEMENT EN COURS' ;
- Pour les doublons de seuils géométriques on n'en garde qu'un seul dans la table des géométries des seuils, que l'on associe à deux numéros de seuils dans une autre table ;
- Exclusion des tronçons sans domanialité quand c'est le cas (fait en concertation avec le service Voirie) ;

## Pour la Base Voie/Adresse

### Corrections réalisées

- Suppression des relations de tronçons invalides à certaines voies valides et inversement ;
- Suppression des types de voies dont le libellé est null ;
- Pour les voies physiques en doublon de géométrie situées en limite de commune, on garde une seule voie physique que l'on rattache à deux voies administratives dont on a corrigé le code INSEE ;
- Corrections topologiques des tronçons :
  - Tronçon qui se croisent en-dehors des ouvrages d'art et en-dehors de leur point de départ et d'arrivée => l'un des tronçons est divisé en deux et leur point de connexion permet de rattacher le second ;
  - Tronçons mal connectés (tous les types de tronçons sont connectés, peu importe leur type de circulation) ;
- Passage d'un tronçon affecté à plusieurs voies physiques affectées à une et une seule voie administrative à un tronçon affecté à une et une seule voie physique affectée à une ou plusieurs voies administratives (en cours de finalisation) ;

### Corrections prévues :

- Affectation de leur latéralité aux voies administratives situées en limite de commune (en cours de préparation);
- Suppression des voies de type ruisseau, rivière, canal, car absents de la table G_SIDU.TYPEVOIE dû à un changement de méthode de saisie non finalisé ;
- Homogénéisation de la nomenclature des noms de voie en suivant la règle de la BAL ;
- Tronçons affectés à une voie administrative située à plusieurs centaines de mètres ;
- Voies secondaires affectées à deux voies principales (12 voies) ;
- Voies en doubles filaires à l'intérieur des communes pour des voies de type AVENUE et BOULEVARD ;
- Création d'une hiérarchie voies secondaires/principales (le code est déjà prêt car la manipulation a été faite pour Literalis) ;
- Correction des seuils situés à plus d'1km de leur tronçon d'affectation (correction déjà faite par Marie-Hélène apparemment) ;
- Correction des doublons de numéro, complément et voie de certains seuils ;
- Correction des voies administratives ne s'arrêtant pas aux limites de communes, car leur tronçon d'affectation n'a pas été dcoupé à la limite de commune ;
