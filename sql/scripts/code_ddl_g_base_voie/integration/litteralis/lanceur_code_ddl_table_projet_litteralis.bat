@echo off
echo Bienvenu dans la creation des tables du projet LITTERALIS de la Base Voie !

:: 1. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 2. Déclaration et valorisation des variables
SET /p chemin_code_table="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des TABLES du projet LITTERALIS : "
SET /p chemin_code_temp="Veuillez saisir le chemin d'acces du dossier litteralis : "

copy /b %chemin_code_table%\creation_ta_secteur_voirie.sql + ^
%chemin_code_temp%\desactivation_index_litteralis.sql ^
%chemin_code_temp%\temp_code_ddl_table_projet_litteralis.sql

:: 5. MISE EN PAUSE
PAUSE