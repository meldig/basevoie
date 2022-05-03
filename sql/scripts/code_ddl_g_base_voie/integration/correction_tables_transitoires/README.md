# Correction des tables transitoires

Ce dossier contient les codes de correction des données présentes dans les tables transitoires.
L'intérêt de ce code est qu'il permet de corriger les données sans toucher aux tables d'import, permettant ainsi une migration en 3 étapes :
1. Migration des données sur le nouveau schéma dans des tables d'import ;;
**2. Correction des données dans des tables transitoires ;**
3. Migration des données corrigées des tables transitoires vers les tables de production ;
