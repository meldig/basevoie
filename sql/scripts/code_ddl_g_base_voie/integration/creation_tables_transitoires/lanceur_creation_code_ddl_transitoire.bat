@echo off
echo Bienvenu dans la creation des tables, vues, VM, fonctions, sequences et declencheurs transitoires de la Base Voie !

:: 1. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 2. Déclaration et valorisation des variables
SET /p chemin_code_table="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des TABLES du schema : "
SET /p chemin_code_trigger="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des DECLENCHEURS du schema : "
SET /p chemin_code_sequence="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des SEQUENCES du schema : "
SET /p chemin_code_fonction="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des FONCTIONS du schema : "
SET /p chemin_code_vue="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des VUES du schema : "
SET /p chemin_code_vue_materialisees="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des VUES MATERIALISEES du schema : "
SET /p chemin_code_temp="Veuillez saisir le chemin d'acces du dossier integration/creation_tables_transitoires : "
::SET /p USER="Veuillez saisir l'utilisateur Oracle : "
::SET /p MDP="Veuillez saisir le MDP : "
::SET /p INSTANCE="Veuillez saisir l'instance Oracle : "

copy /b %chemin_code_fonction%\creation_get_temp_code_insee_97_communes_contain_line.sql + ^
%chemin_code_fonction%\creation_get_temp_code_insee_97_communes_pourcentage.sql + ^
%chemin_code_fonction%\creation_get_temp_code_insee_97_communes_within_distance.sql + ^
%chemin_code_fonction%\creation_get_temp_code_insee_97_communes_troncon.sql + ^
%chemin_code_sequence%\creation_seq_temp_correction_projet_a_troncon_objectid.sql + ^
%chemin_code_table%\creation_temp_type_voie.sql + ^
%chemin_code_table%\creation_temp_correction_projet_a_voie.sql + ^
%chemin_code_table%\creation_temp_correction_projet_a_troncon.sql + ^
%chemin_code_table%\creation_temp_correction_projet_a_relation_troncon_voie.sql + ^
%chemin_code_trigger%\creation_b_iux_temp_correction_projet_a_troncon_date_pnom.sql + ^
%chemin_code_trigger%\creation_b_iux_temp_correction_projet_a_voie_date_pnom.sql + ^
%chemin_code_trigger%\creation_b_iux_temp_correction_projet_a_relation_troncon_voie_date_pnom.sql + ^
%chemin_code_vue%\creation_v_temp_correction_projet_a_relation_troncon_voie_doublon.sql + ^
%chemin_code_vue_materialisees%\creation_vm_temp_correction_projet_a_voie_aggregee.sql + ^
%chemin_code_vue%\creation_v_temp_correction_projet_a_voie_doublon.sql + ^
%chemin_code_vue_materialisees%\creation_vm_temp_correction_projet_a_troncon_doublon_voie_inside_commune.sql + ^
%chemin_code_vue_materialisees%\creation_vm_temp_correction_projet_a_troncon_doublon_voie_overlapbdydisjoint_commune.sql ^
%chemin_code_temp%\temp_code_ddl_schema.sql

:: 3. lancement de SQL plus.
::CD C:/ora12c/R1/BIN

:: 4. Execution de sqlplus. pour lancer les requetes SQL.
::sqlplus.exe %USER%/%MDP%@%INSTANCE% @%chemin_code_temp%\temp_code_ddl_schema.sql

:: 5. MISE EN PAUSE
PAUSE