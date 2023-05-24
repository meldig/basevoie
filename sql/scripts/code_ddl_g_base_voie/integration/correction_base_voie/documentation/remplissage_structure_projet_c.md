# Remplissage de la structure du projet C de correction de la Base Voie

## Objectif : affecter une latéralité aux voies physiques en limite de commune

## Méthode 1 :
1. Tous les tronçons disposant d'une relation tronçon/voie physique dont le sens est '-' dispose aussi d'une relation tronçon/voie physique dont le sens est '+' . Dans ce cas il faut toujours choisir la voie dont le sens de la relation tronçon/voie est '+' en tant que voie physique, car cela permettra d'avoir tous les tronçons dans le même ordre géométrique par voie physique ;

**WARNING :**
Les tronçons 90795, 90105, 90793, 90107 disposent tous d'un sens '-' dans leurs relations, ce qui est normalement impossible, il faut donc changer leur sens pour une relation tronçon/voie physique.

2. Pour les tronçons affectés à plusieurs voies physiques, dont le sens est toujours '+', on prend celle dont l'identifiant est le plus petit en tant que voie physique ;

3. On insère les autres tronçons et leurs relations telles quelles ;

## Méthode 2 :
1. Création de la table temporaire G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE ;
2. Création de la vue matérialisée G_BASE_VOIE.VM_TEMP_C_TRONCON_AFFECTE_PLUSIEURS_VOIES ;
3. Insertion dans la table G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE des relations tronçons voies dans lesquelles le tronçon est affecté à plusieurs voies et pour lesquelles on ne conserve que la relation tronçon/MIN(id_voie) ;
4. Création de nouveau identifiant de voie dans le champ NEW_ID_VOIE_PHYSIQUE de la table G_BASE_VOIE.TEMP_C_TRANSIT_TRONCON_VOIE_PHYSIQUE;
5. Insertion des nouveaux identifiants de voie physique dans la table G_BASE_VOIE.TEMP_C_VOIE_PHYSIQUE ;
