@echo off
echo Bienvenu dans la suppression des objets de la Base Voie ! Cette commande va permettre la suppression des tables, MTD spatiales, contraintes, index, declencheurs et fonctions personnalisees.

:: 1. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 2. Déclaration et valorisation des variables
SET /p chemin_integration="Veuillez saisir le chemin d'acces du dossier integration : "
SET /p USER="Veuillez saisir l'utilisateur Oracle : "    
SET /p MDP="Veuillez saisir le MDP : "    
SET /p INSTANCE="Veuillez saisir l'instance Oracle : " 

:: 3. lancement de SQL plus.
CD C:/ora12c/R1/BIN

:: 4. Execution de sqlplus. pour lancer la requete SQL.
sqlplus.exe %USER%/%MDP%@%INSTANCE% @%chemin_integration%\suppression_tables_declencheurs_fonctions_MTD_index_contraintes.sql

:: 5. MISE EN PAUSE
PAUSE