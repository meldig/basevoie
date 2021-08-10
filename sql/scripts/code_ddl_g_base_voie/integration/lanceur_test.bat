@echo off
:: utilisation de ogr2ogr pour exporter des tables de CUDL vers MULTIT
echo Bienvenu dans l'import des donnees de la base voie du schema actuel vers le nouveau ! 
:: 1. gestion des identifiants Oracle
SET /p USER_D="Veuillez saisir l'utilisateur Oracle de destination : "
::SET /p USER_P="Veuillez saisir l'utilisateur Oracle de provenance : "
SET /p MDP_D="Veuillez saisir le mot de passe de l'utilisateur Oracle de destination : "
::SET /p MDP_P="Veuillez saisir le mot de passe de l'utilisateur Oracle de provenance : "
SET /p INSTANCE_D="Veuillez saisir l'instance Oracle de destination: "
::SET /p INSTANCE_P="Veuillez saisir l'instance Oracle de provenance : "
::SET /p USER_FUSION_SEUIL_P="Fusion des seuils : Veuillez saisir l'utilisateur Oracle de provenance : "
::SET /p MDP_FUSION_SEUIL_P="Fusion des seuils : Veuillez saisir le mot de passe de l'utilisateur Oracle de provenance : "
::SET /p INSTANCE_FUSION_SEUIL_P="Fusion des seuils : Veuillez saisir l'instance Oracle de provenance : "
SET /p CHEMIN_AGENT="Veuillez saisir le chemin d'acces au fichier temp_agent : "
SET /p CHEMIN_INTEGRATION="Veuillez saisir le chemin d'acces au dossier integration : "

:: 2. se mettre dans l'environnement QGIS
cd C:\Program Files\QGIS 3.16.9\bin

:: 3. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 4. Rediriger la variable PROJ_LIB vers le bon fichier proj.db afin qu'ogr2ogr trouve le bon scr
setx PROJ_LIB "C:\Program Files\QGIS 3.16\share\proj"

:: 5. commande ogr2ogr pour exporter les couches du schéma X@X vers le schéma X@X

:: 5.12. table TEMP_AGENT
ogr2ogr.exe -f OCI -lco SCHEMA=G_BASE_VOIE OCI:%USER_D%/%MDP_D%@%INSTANCE_D% %CHEMIN_AGENT%/TEMP_AGENT.csv

:: 5.13. table TEMP_FAMILLE
ogr2ogr.exe -f OCI -lco SCHEMA=G_BASE_VOIE OCI:%USER_D%/%MDP_D%@%INSTANCE_D% %CHEMIN_INTEGRATION%/TEMP_FAMILLE.csv

:: 5.14. table TEMP_FAMILLE
ogr2ogr.exe -f OCI -lco SCHEMA=G_BASE_VOIE OCI:%USER_D%/%MDP_D%@%INSTANCE_D% %CHEMIN_INTEGRATION%/TEMP_LIBELLE.csv

:: 5.15. table TEMP_CODE_FANTOIR
ogr2ogr.exe -f OCI -lco SCHEMA=G_BASE_VOIE OCI:%USER_D%/%MDP_D%@%INSTANCE_D% %CHEMIN_INTEGRATION%/TEMP_CODE_FANTOIR.csv

:: 6. MISE EN PAUSE
PAUSE