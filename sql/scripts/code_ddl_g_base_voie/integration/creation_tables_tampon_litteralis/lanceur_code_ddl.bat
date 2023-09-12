@echo off
echo Bienvenu dans la creation des tables, vues et vues materialisees tampon du projet LITTERALIS (Base Voie) !

:: 1. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 2. Déclaration et valorisation des variables
SET /p chemin_code_table="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des TABLES du schema : "
SET /p chemin_code_temp="Veuillez saisir le chemin d'acces du dossier integration/creation_tables_finales : "
::SET /p USER="Veuillez saisir l'utilisateur Oracle : "
::SET /p MDP="Veuillez saisir le MDP : "
::SET /p INSTANCE="Veuillez saisir l'instance Oracle : "

copy /b %chemin_code_table%\creation_ta_tampon_litteralis_troncon.sql + ^
%chemin_code_table%\creation_ta_tampon_litteralis_adresse.sql + ^
%chemin_code_table%\creation_ta_tampon_litteralis_zone_particuliere.sql ^
%chemin_code_temp%\temp_code_ddl_litteralis.sql

:: 3. lancement de SQL plus.
::CD C:/ora12c/R1/BIN

:: 4. Execution de sqlplus. pour lancer les requetes SQL.
::sqlplus.exe %USER%/%MDP%@%INSTANCE% @%chemin_code_temp%\temp_code_ddl_litteralis.sql

:: 5. MISE EN PAUSE
PAUSE