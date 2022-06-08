@echo off
echo Bienvenu dans la suppression des tables temporaires de la Base Voie ! Cette commande va permettre la suppression des tables issues du schema G_SIDU et ayant permis la transition vers le nouveau schema.

:: 1. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 2. Déclaration et valorisation des variables
SET /p chemin_suppression="Veuillez saisir le chemin d'acces du dossier suppression_objets_schema : "
SET /p USER="Veuillez saisir l'utilisateur Oracle : "    
SET /p MDP="Veuillez saisir le MDP : "    
SET /p INSTANCE="Veuillez saisir l'instance Oracle : " 

:: 3. lancement de SQL plus.
CD C:/ora12c/R1/BIN

:: 4. Execution de sqlplus. pour lancer la requete SQL.
sqlplus.exe %USER%/%MDP%@%INSTANCE% @%chemin_suppression%\suppression_tables_d_import_temporaires.sql

:: 5. MISE EN PAUSE
PAUSE