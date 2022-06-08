@echo off
echo Bienvenu dans la migration des donnees des tables temporaires vers les tables finales de la base voie !

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
sqlplus.exe %USER%/%MDP%@%INSTANCE% @%chemin_integration%\migration_tables_temporaires_vers_tables_finales.sql

:: 5. MISE EN PAUSE
PAUSE