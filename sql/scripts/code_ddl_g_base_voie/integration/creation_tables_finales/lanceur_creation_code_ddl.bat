@echo off
echo Bienvenu dans la creation des tables, vues, VM, fonctions, sequences et declencheurs du projet j de correction de la Base Voie !

:: 1. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 2. Déclaration et valorisation des variables
SET /p chemin_code_table="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des TABLES du schema : "
SET /p chemin_code_trigger="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des DECLENCHEURS du schema : "
SET /p chemin_code_sequence="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des SEQUENCES du schema : "
::SET /p chemin_code_fonction="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des FONCTIONS du schema : "
SET /p chemin_code_temp="Veuillez saisir le chemin d'acces du dossier integration\creation_tables_finales : "


:: 3. Compilation des fichiers
::%chemin_code_fonction%\creation_get_code_insee_contain_line.sql + ^
%chemin_code_fonction%\creation_get_code_insee_contain_point.sql + ^
%chemin_code_fonction%\creation_get_code_insee_contain_line.sql + ^
%chemin_code_fonction%\creation_get_code_insee_pourcentage.sql + ^
%chemin_code_fonction%\creation_get_code_insee_within_distance.sql + ^
%chemin_code_fonction%\creation_get_code_insee_troncon.sql + ^
%chemin_code_fonction%\creation_get_code_insee_97_communes_contain_line.sql + ^
%chemin_code_fonction%\creation_get_code_insee_97_communes_pourcentage.sql + ^
%chemin_code_fonction%\creation_get_code_insee_97_communes_within_distance.sql + ^
%chemin_code_fonction%\creation_get_code_insee_97_communes_troncon.sql + ^::

copy /b %chemin_code_sequence%\creation_seq_ta_troncon_objectid.sql + ^
%chemin_code_sequence%\creation_seq_ta_voie_physique_objectid.sql + ^
%chemin_code_table%\creation_ta_agent.sql + ^
%chemin_code_table%\creation_ta_famille.sql + ^
%chemin_code_table%\creation_ta_famille_libelle.sql + ^
%chemin_code_table%\creation_ta_libelle.sql + ^
%chemin_code_table%\creation_ta_type_voie.sql + ^
%chemin_code_table%\creation_ta_rivoli.sql + ^
%chemin_code_table%\creation_ta_voie_physique.sql + ^
%chemin_code_table%\creation_ta_voie_administrative.sql + ^
%chemin_code_table%\creation_ta_troncon.sql + ^
%chemin_code_table%\creation_ta_relation_voie_physique_administrative.sql + ^
%chemin_code_table%\creation_ta_hierarchisation_voie.sql + ^
%chemin_code_table%\creation_ta_seuil.sql + ^
%chemin_code_table%\creation_ta_infos_seuil.sql + ^
%chemin_code_table%\creation_ta_seuil_log.sql + ^
%chemin_code_table%\creation_ta_infos_seuil_log.sql + ^
%chemin_code_table%\creation_ta_troncon_log.sql + ^
%chemin_code_table%\creation_ta_voie_physique_log.sql + ^
%chemin_code_table%\creation_ta_voie_administrative_log.sql + ^
%chemin_code_table%\creation_ta_relation_voie_physique_administrative.sql + ^
%chemin_code_table%\creation_ta_hierarchisation_log.sql + ^
%chemin_code_trigger%\creation_a_ixx_ta_seuil.sql + ^
%chemin_code_trigger%\creation_a_ixx_ta_voie_administrative.sql + ^
%chemin_code_trigger%\creation_b_iud_ta_infos_seuil_log.sql + ^
%chemin_code_trigger%\creation_b_iud_ta_relation_voie_physique_administrative_log.sql + ^
%chemin_code_trigger%\creation_b_iud_ta_seuil_log.sql + ^
%chemin_code_trigger%\creation_b_iud_ta_troncon_log + ^
%chemin_code_trigger%\creation_b_iud_ta_voie_administrative_log.sql + ^
%chemin_code_trigger%\creation_b_iud_ta_voie_physique_log.sql + ^
%chemin_code_trigger%\creation_b_iux_ta_voie_supra_communale_date_pnom.sql + ^
%chemin_code_temp%\creation_droits_lecture_edition.sql + ^
%chemin_code_temp%\desactivation_contraintes_index_tables.sql ^
%chemin_code_temp%\temp_code_ddl_schema.sql

:: 4. lancement de SQL plus.
::CD C:/ora12c/R1/BIN

:: 5. Execution de sqlplus. pour lancer les requetes SQL.
::sqlplus.exe %USER%/%MDP%@%INSTANCE% @%chemin_code_temp%\temp_code_ddl_schema_transitoire_projet_j.sql

:: 6. MISE EN PAUSE
PAUSE