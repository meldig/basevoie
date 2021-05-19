@echo off
echo Bienvenu dans la creation des tables et declencheurs de la Base Voie !

:: 1. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 2. Déclaration et valorisation des variables
SET /p chemin_code_table="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des TABLES du schema : "
SET /p chemin_code_trigger="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des DECLENCHEURS du schema : "
SET /p chemin_code_temp="Veuillez saisir le chemin d'acces du dossier integration : "
SET /p USER="Veuillez saisir l'utilisateur Oracle : "
SET /p MDP="Veuillez saisir le MDP : "
SET /p INSTANCE="Veuillez saisir l'instance Oracle : "
type %chemin_code_table%\creation_ta_agent.sql > %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_famille.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_fantoir.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_libelle.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_relation_famille_libelle.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_troncon.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_troncon_log.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_type_voie.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_voie.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_voie_log.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_relation_troncon_voie.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_relation_troncon_voie_log.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_rue.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_rue_log.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_relation_rue_voie.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_infos_seuil.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_infos_seuil_log.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_seuil.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_seuil_log.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_relation_troncon_seuil.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_trigger%\creation_a_iud_ta_infos_seuil_log.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_trigger%\creation_b_iud_ta_relation_troncon_voie_log.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_trigger%\creation_b_iud_ta_rue_log.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_trigger%\creation_b_iud_ta_seuil_log.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_trigger%\creation_b_iud_ta_troncon_log.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_trigger%\creation_b_iud_ta_voie_log.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_trigger%\creation_b_iux_ta_infos_seuil_date_pnom.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_trigger%\creation_b_iux_ta_rue_date_pnom.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_trigger%\creation_b_iux_ta_seuil_date_pnom.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_trigger%\creation_b_iux_ta_troncon_date_pnom.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_trigger%\creation_b_iux_ta_voie_date_pnom.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql

:: 3. lancement de SQL plus.
CD C:/ora12c/R1/BIN

:: 4. Execution de sqlplus. pour lancer les requetes SQL.
sqlplus.exe %USER%/%MDP%@%INSTANCE% @%chemin_code_temp%\code_ddl_schema_basevoie.sql

:: 5. On revient sur le disque C
CD c:

:: 6. Suppression du fichier temporaire code_ddl_schema_basevoie.sql
DEL %chemin_code_temp%\code_ddl_schema_basevoie.sql

:: 7. MISE EN PAUSE
PAUSE