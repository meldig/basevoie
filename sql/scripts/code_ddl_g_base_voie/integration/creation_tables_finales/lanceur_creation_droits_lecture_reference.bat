@echo off
echo Bienvenu dans la creation des droits de lecture et de reference vers des tables des MTD, libellés et familles !

:: 1. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 2. Déclaration et valorisation des variables
SET /p chemin_droits_lecture_ecriture="Veuillez saisir le chemin d'acces du dossier 'droits_lecture_ecriture' : "
SET /p USER="Veuillez saisir l'utilisateur Oracle contenant les métadonnées, libellés et familles : "
SET /p MDP="Veuillez saisir le MDP : "
SET /p INSTANCE="Veuillez saisir l'instance Oracle : "

:: 3. lancement de SQL plus.
CD C:/ora12c/R1/BIN

:: 4. Execution de sqlplus. pour lancer les requetes SQL.
sqlplus.exe %USER%/%MDP%@%INSTANCE% @%chemin_droits_lecture_ecriture%\creation_droits_lecture_reference_mtd_libelle_famille.sql

:: 5. MISE EN PAUSE
PAUSE