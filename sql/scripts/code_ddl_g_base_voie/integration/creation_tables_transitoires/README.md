# Creation des tables transitoires

Ce dossier contient tous les codes permettant de créer les tables, fonctions, séquences, triggers et procédures transitoires du schéma.
C'est dans ce dossier que sont compilés tous les codes DDL des objets dans un fichier temporaire qui sera ensuite executé dans le schéma de la base voie.
Ce code DDL est celui de la structure transitoire qui va permettre de corriger les données avant de les insérer dans les tables de production.