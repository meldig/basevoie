@echo off
echo Bienvenu dans la creation des tables de la Base Voie !

:: 1. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 2. Déclaration et valorisation des variables
SET /p chemin_code_ddl="Veuillez saisir le chemin d'acces du dossier contenant le code DDL du schema : "  
SET /p USER="Veuillez saisir l'utilisateur Oracle : "    
SET /p MDP="Veuillez saisir le MDP : "    
SET /p INSTANCE="Veuillez saisir l'instance Oracle : " 
type %chemin_code_ddl%\creation_ta_agent.sql > code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_famille.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_fantoir.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_libelle.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_relation_famille_libelle.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_troncon.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_troncon_log.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_type_voie.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_voie.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_voie_log.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_relation_troncon_voie.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_relation_troncon_voie_log.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_rue.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_rue_log.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_relation_rue_voie.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_infos_seuil.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_infos_seuil_log.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_seuil.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_seuil_log.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql ^
| type %chemin_code_ddl%\creation_ta_relation_troncon_seuil.sql >> code_ddl_tables.sql | echo. >> code_ddl_tables.sql

:: 3. lancement de SQL plus.
CD C:/ora12c/R1/BIN

:: 4. Execution de sqlplus. pour lancer les requetes SQL.
sqlplus.exe %USER%/%MDP%@%INSTANCE% @%chemin_code_ddl%\code_ddl_tables.sql

:: 5. MISE EN PAUSE
PAUSE