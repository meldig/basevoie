# Règles de saisie de la Base Voie

## Objectif : homogénéiser les saisies des objets de la Base Voie.

## Les tronçons :
1. Un tronçon doit toujours soit se situer entre deux intersections soit, dans le cas des impasses, commencer ou finir à la première intersection. En d'autres termes, quand un tronçon se situe entre deux intersections, son point de départ doit se situer sur une intersection et son point d'arrivée sur une autre intersection, sans traverser une ou plusieurs autres intersections ;
2. Les tronçons doivent toujours être connectés entre eux, au niveau des point de départ ou d'arrivée ;
3. Un tronçon ne doit jamais couper un autre tronçon (cf. règle n°2), sauf s'il n'est pas situé à la même altitude (exemple : un pont) ;
4. Si une voie est coupée par une barrière filtrante (le plus souvent pour empêcher les voitures de passer), les tronçons doivent quand même être connectés entre eux puisque les deux roues et les piétons peuvent passer ;
5. Les tronçons des courées doivent être rattachés à ceux des voies ;
6. Peu importe le type de circulation (routier, cyclable ou piéton), les tronçons doivent être connectés entre eux (circulation fluviale et ferroviaire mises à part) ;
7. Dans le cas des carrefours, si les tronçons ne sont pas exactement dans le prolongement l'un de l'autre, alors il faut créer un tronçon entre ces deux tronçons et faire deux connexions sur les sommets du nouveau tronçon. Autrement dit, nous faisons comme l'IGN.
*Exemple : si les tronçons A et B coupe le tronçon C mais avec un décalage de 5m, alors la tronçon C doit être coupé à chaque connexion des tronçons A et B. Cela produira donc un tronçon C, un tronçon D de 5m, un tronçon E et les tronçons A et B* ; 
8. Un tronçon est toujours affecté à une et une seule voie physique ;
9. Un tronçon peut appartenir à une ou plusieurs voies administratives ;

## Les Voies physiques :
1. Une voie physique se compose d'un ou plusieurs tronçons ;
2. Une voie physique doit représenter la réalité physique de la voie, en opposition à sa réalité administrative. En d'autres termes, quand une voie se situe en limite de commune, que sa partie droite appartient à la commune A et que sa partie gauche appartient à la commune B, on ne doit construire qu'une et une seule voie physique car sur le terrain même si la voie appartient à deux communes différentes, il n'existe physiquement qu'une et une seule voie ;
3. Une ou plusieurs voies physiques peut composer une voie administrative ;

## Les Voie administratives :
1. Une voie administrative se compose d'une ou plusieurs voies physiques ;
2. Une voie administrative appartient soit aux deux côtés des voies physiques la composant quand elles se situent à l'intérieur d'une commune, soit à l'un de leur côté en limite de commune ;
3. Le code INSEE des voies administratives doit être inscrit en dur afin que l'on puisse déterminer sa latéralité (à gauche ou à droite de la voie physique) ;

## Nomenclature des *LIBELLES* des voies administratives :
1. Les accents seront mis sur les minuscules, comme sur les majuscules ;
2. Tous les mots auront leur première lettre en majuscule (accentuée au besoin), sauf les articles (le, la, les, de la, de l’) et les prépositions (de, du, des) ;
3. Les noms propres doivent avoir leur première lettre écrite en majuscule ;
4. Si l’article ou la préposition compose un nom propre, alors sa première lettre doit être en majuscule (Exemple : Le Vésinet) ; 
5. Il ne doit jamais y avoir d’espace derrière une apostrophe ;
6. Si une voie n’a pas de libellé, alors il faut laisser le libellé de la voie vide ;
7. Le type de voie ne doit jamais figurer dans le libellé de la voie ;
8. Aucun commentaire, ni aucune précision ne doit figurer dans le libellé de la voie ;
9. Les noms composés doivent comporter leur '-' quand ils en ont (Exemple : Jean-Baptiste, Marie-Thérèse, Saint-Hubert) ;
10. L'abbréviation "St" pour "Saint" ne doit jamais apparaître dans les libellés de voie. Le mot "Saint" doit toujours être écrit en toutes lettres ;
11. Le mot "Saint" doit toujours être suivi d'un tiret "-" sans espace avant ni après. Exemple : Saint-Hubert, Saint-Jacques, Saint-Jean-Baptiste, Sainte-Brigitte de Suède ;
12. Il ne doit jamais y avoir de guillemets dans le libellé ;
13. Les apostrophes ne doivent jamais encadrer un nom, qu'il soit celui d'un lieux-dit ou non ;
14. Le nom des autoroutes doit toujours suivre la nomenclature suivante : LIBELLE "numéro d'autoroute-numéro européen" ; COMPLEMENT_NOM_VOIE "Départ-Destination" (Exemple : A27-E42 ; Lille-Bruxelle) ;
15. Le libellé ne doit pas contenir "métropolitaine", veuillez utiliser le type de voie "ROUTE MÉTROPOLITAINE" ;
16. Le Complément de nom de voie ne doit pas contenir la modalité de déplacement (donc ne pas mettre piéton, cycliste, etc) ;
17. Dans les zones industrielles portuaires, veuillez mettre uniquement "Zone Industrielle Portuaire" dans le complément de nom ;
18. Un libellé ne peut pas être "d'Exploitation". Si son type de voie est aussi "CHEMIN", alors veuillez utiliser le type "CHEMIN D'EXPLOITATION" ;
19. le complément de nom de voie ne doit pas contenir le sens de la voie (Exemple : Lille-Hellemes), ni la rue de connexion (Exemple : TYPE : chemin d'exploitation; LIBELLE : ; COMPLEMENT_NOM_VOIE : 16 rue de la Liberté => il faut supprimer le complément) ;
