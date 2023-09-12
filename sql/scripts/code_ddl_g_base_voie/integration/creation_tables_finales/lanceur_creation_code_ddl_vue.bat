@echo off
echo Bienvenu dans la creation des vues de la Base Voie !

:: 1. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 2. Déclaration et valorisation des variables
SET /p chemin_code_vue="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des VUES du schema : "
SET /p chemin_code_droits="Veuillez saisir le chemin d'acces du dossier contenant le droits de lecture, écriture, suppression : "
SET /p chemin_code_temp="Veuillez saisir le chemin d'acces du dossier integration\creation_tables_finales : "

copy /b %chemin_code_vue%\creation_v_stat_nombre_objet.sql + ^
%chemin_code_vue%\creation_v_stat_nombre_voie_administrative_par_commune.sql + ^
%chemin_code_vue%\creation_v_stat_nombre_voie_administrative_par_nombre_voie_physique.sql + ^
%chemin_code_vue%\creation_v_stat_nombre_voie_physique_par_voie_administrative.sql + ^
%chemin_code_vue%\creation_v_stat_nombre_seuil_par_geometrie.sql + ^
%chemin_code_vue%\creation_v_stat_creation_objet_par_annee_mois.sql + ^
%chemin_code_droits%\creation_droits_lecture_edition_vue.sql ^
%chemin_code_temp%\temp_code_ddl_vue.sql

:: 4. lancement de SQL plus.
::CD C:/ora12c/R1/BIN

:: 5. Execution de sqlplus. pour lancer les requetes SQL.
::sqlplus.exe %USER%/%MDP%@%INSTANCE% @%chemin_code_temp%\temp_code_ddl_schema_transitoire_projet_j.sql

:: 6. MISE EN PAUSE
PAUSE