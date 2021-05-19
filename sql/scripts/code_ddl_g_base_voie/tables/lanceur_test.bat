@echo off
echo Bienvenu dans la creation des tables de la Base Voie !

:: 1. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 2. Déclaration et valorisation des variables
SET /p chemin_code_table="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des TABLES du schema : "
SET /p chemin_code_trigger="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des TRIGGERS du schema : "
SET /p chemin_code_temp="Veuillez saisir le chemin d'acces du dossier qui contiendra la concaténation de vos codes (dossier fichiers temporaires) : "
type %chemin_code_table%\creation_ta_agent.sql > %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_table%\creation_ta_famille.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql ^
| type %chemin_code_trigger%\creation_b_iux_ta_voie_date_pnom.sql >> %chemin_code_temp%\code_ddl_schema_basevoie.sql | echo. >> code_ddl_schema_basevoie.sql

:: 3. Suppression du fichier temporaire
DEL %chemin_code_temp%\code_ddl_schema_basevoie.sql

:: 4. MISE EN PAUSE
PAUSE