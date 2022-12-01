# Règles de saisie des tronçons de l'IGN

## Source : 
BD TOPO® Version 3.0 - Descriptif de contenu - Avril 2021 

## Règles de saisie géométriques :
1. Numérisation de chaque portion de voie destinée aux automobiles, piétons, vélos ou animaux, revêtues ou non. Les voies publiques comme privées sont numérisées ;
2. La numérisation d'un tronçon se fait à l'axe de la chaussée ;
3. Si un séparateur ou un zébra augmente la largeur totale de la route de plus de 50% ou si le zébra est strictement supérieur à la largeur de la voie, alors chaque chaussée est représentée séparément ;
4. Si un séparateur ou un zébra ne modifie pas la largeur totale de la route, mais s'étale sur une distance supérieure à 400m environ, à les chaussées sont dédoublées ;
5. Si le dédoublement des chaussées facilite la lecture de la logique de circulation, les chaussées
sont dédoublées, même si la longueur du séparateur est inférieure à 400 m ;
6. Un grand carrefour est numérisé en respectant les intersections. Chaque tronçon numérisant le carrefour sera donc situé entre chaque voie d'accès au carrefour ;
7. Pour numériser un carrefour circulaire avec un îlot directionnel, si celui-ci est inférieur à 10m d'axe à axe, alors un tronçon supplémentaire est créé pour connecter le tronçon du carrefour à celui de la voie d'accès quand ceux-ci sont espacés de plus de 25m ;
8. Pour numériser un carrefour non-circulaire avec un îlot directionnel, si celui-ci est inférieur à 10m, alors les chaussées ne sont pas doublées, sinon elles le sont ;
9. Lorsqu'un parking peut servir de liaison entre différentes routes, mais sans posséder un réseau d'allées matérialisées au sol et dont aucune allée ne prédomine, une liaison entre les routes est numérisée ;
10. Lorsqu'un parking est traversé par une route matérialisée ou sol ou par une allée principale, celle-ci est numérisée et raccordée aux voies d'accès du parking ;
11. Un rond-point est toujours numérisé dans le sens antihoraire, en respectant les intersections des voies d'accès. Un rond-point ne doit donc jamais être numérisé avec un seul tronçon, mais par plusieurs ;
12. Lorsqu'un rond-point est connecté, en un point, à deux chaussées séparées par un terre-plein ou un zébra, le sens de saisie des tronçons au niveau de ce terre-plein ou zébra doit être cohérent avec celui des tronçons du rond-point (c'est-à-dire dans le même sens) ;
13. Lorsqu'une voie passe sur un pont, un tronçon spécifique au pont doit être tracé. Si deux voies séparées par un séparateur, terre-plein ou zébra passe sur le pont alors deux tronçons seront tracés (cf. règles n°3 à 5) ;
14. Si un pont est traversé par une limite de commune, alors le tronçon qui le représente est découpé à la limite de commune, car le code INSEE droite / gauche des tronçons change ;
15. Les pistes cyclables sont numérisées si leur longueur est supérieure à 200m, si elles longent une route en site propre, si elles sont séparées de la chaussée principale par une séparation physique de 5m minimum par rapport à l'axe (central) de la route ;
16. L'écart entre deux voies cyclables parallèles et longeant une route doit être de 10m minimum ;
17. Ne sont pas numérisées les pistes cyclables dont la longueur est inférieure à 200m, les pistes cyclables situées sur le même revêtement que la route (même protégées par des barrières), les pistes cyclables situées sur les trottoirs ou non séparées de la chaussée principale par une séparation physique, ou si l'axe de la piste est situé à moins de 5m de l'axe de la route ;
18. Lorsque le réseau routier croise le réseau ferroviaire ou hydrographique, les tronçons ne sont pas découpés aux points de jonctions, mais ils prennent la longueur des ouvrages sur lesquels ils passent (pont, viaduc, tunnel, etc) ;
19. Le passage d'une route sous un bâtiment n'est pas considéré comme souterrain, il ne faut donc pas découper le tronçon selon la longueur du bâtiment mais faire un seul et même tronçon ;

## Attributs des tronçons :
En dehors de la géométrie, chaque tronçon dispose de champ attributaire permettant de le catégoriser :
- son importance ;
- le sens de circulation dans lequel le sens direct ou inverse est a prioriser et le double-sens à éviter ;
- l'accès aux véhicules légers ;
- le nombre de voies ;
- la largeur des chausées ;
- le nom de voie à droite ou à gauche. Le sens de numérisation du tronçon est utilisé pour déterminer la latéralité du tronçon ;
- l'itinéraire vert ;
- la présence de bande cyclable ;
- les bornes si elles ont des noms ;
- le type d'adressage ;
- le code INSEE ;
- le champ fictif permettant de savoir si un tronçon existe réellement ou s'il a été numériser pour rendre cohérent le réseau routier ;
- la date de mise en service ;
