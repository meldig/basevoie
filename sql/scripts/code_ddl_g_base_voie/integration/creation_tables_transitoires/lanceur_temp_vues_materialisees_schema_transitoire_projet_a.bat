@echo off
echo Bienvenu dans la creation des vues materialisees de la Base Voie !

:: 1. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 2. Déclaration et valorisation des variables
SET /p chemin_code_vue_materialisees="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des VUES MATERIALISEES du schema : "
SET /p USER="Veuillez saisir l'utilisateur Oracle : "
SET /p MDP="Veuillez saisir le MDP : "
SET /p INSTANCE="Veuillez saisir l'instance Oracle : "

copy /b %chemin_code_vue_materialisees%\creation_vm_temp_correction_projet_a_troncon_doublon_voie_inside_commune.sql + ^
%chemin_code_vue_materialisees%\creation_vm_temp_correction_projet_a_troncon_doublon_voie_intersect_commune.sql ^
%chemin_code_temp%\temp_vues_materialisees_schema_transitoire_projet_a.sql

:: 3. lancement de SQL plus.
CD C:/ora12c/R1/BIN

:: 4. Execution de sqlplus. pour lancer les requetes SQL.
sqlplus.exe %USER%/%MDP%@%INSTANCE% @%chemin_code_temp%\temp_vues_materialisees_schema_transitoire_projet_a.sql

:: 5. MISE EN PAUSE
PAUSE
