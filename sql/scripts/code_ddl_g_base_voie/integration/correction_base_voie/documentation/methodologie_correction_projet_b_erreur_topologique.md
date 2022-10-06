# Méthode de correction des tronçons mal connectés

## Dans Oracle (SqlDevelopper)
1. Création de la table *TEMP_B_TEST_CORRECTION_TOPO_TRONCON* qui est un duplicata de *TEMP_B_TRONCON*, servant à enregistrer les données corrigées ;

2. Création de la VM *VM_AUDIT_TEMP_B_TRONCON_NON_JOINTIF* qui identifie les tronçons non-jointifs (tolérance 1m) au sein de la table *TEMP_B_TRONCON*. cette VM est mise à jour tous les jours à 07h00 ;

## Dans QGIS
3. Extraction de tous les tronçons de la VM *VM_AUDIT_TEMP_B_TRONCON_NON_JOINTIF* disjoints des entités de la table *TEMP_B_OUVRAGE_ART* (extraire par localisation => *Tronçons non-jointifs* / est disjoint / *Ouvrages d'art*);

4. Raccordement des tronçons entre eux via la fonction v.clean de GRASS ;

