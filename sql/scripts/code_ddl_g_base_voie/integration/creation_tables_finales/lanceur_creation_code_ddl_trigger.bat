@echo off
echo Bienvenu dans la creation des tables et triggers de la Base Voie !

:: 1. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 2. Déclaration et valorisation des variables
SET /p chemin_code_trigger="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des DECLENCHEURS du schema : "
SET /p chemin_code_temp="Veuillez saisir le chemin d'acces du dossier integration\creation_tables_finales : "

copy /b %chemin_code_trigger%\creation_a_ixx_ta_seuil.sql + ^
%chemin_code_trigger%\creation_b_iud_ta_voie_administrative_log.sql + ^
%chemin_code_trigger%\creation_a_ixx_ta_voie_administrative.sql + ^
%chemin_code_trigger%\creation_b_iud_ta_infos_seuil_log.sql + ^
%chemin_code_trigger%\creation_b_iud_ta_relation_voie_physique_administrative_log.sql + ^
%chemin_code_trigger%\creation_b_iud_ta_seuil_log.sql + ^
%chemin_code_trigger%\creation_b_iud_ta_troncon_log.sql + ^
%chemin_code_trigger%\creation_b_iud_ta_voie_physique_log.sql + ^
%chemin_code_trigger%\creation_b_iud_ta_voie_supra_communale_log.sql + ^
%chemin_code_trigger%\creation_b_iux_ta_voie_supra_communale_date_pnom.sql ^
%chemin_code_temp%\temp_code_ddl_trigger.sql

:: 4. lancement de SQL plus.
::CD C:/ora12c/R1/BIN

:: 5. Execution de sqlplus. pour lancer les requetes SQL.
::sqlplus.exe %USER%/%MDP%@%INSTANCE% @%chemin_code_temp%\temp_code_ddl_schema_transitoire_projet_j.sql

:: 6. MISE EN PAUSE
PAUSE