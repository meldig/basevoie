@echo off

:: 1. gestion des identifiants Oracle
SET /p USER_D="Veuillez saisir l'utilisateur Oracle de destination : "
SET /p USER_P_AGENT="Veuillez saisir l'utilisateur Oracle de provenance pour les AGENTS : "
SET /p MDP_D="Veuillez saisir le mot de passe de l'utilisateur Oracle de destination : "
SET /p MDP_P_AGENT="Veuillez saisir le mot de passe de l'utilisateur Oracle de provenance pour les AGENTS : "
SET /p INSTANCE_D="Veuillez saisir l'instance Oracle de destination: "
SET /p INSTANCE_P_AGENT="Veuillez saisir l'instance Oracle de provenance pour les AGENTS : "

:: 2. se mettre dans l'environnement QGIS
cd C:\Program Files\QGIS 3.16\bin

:: 3. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 5.13. table TA_GG_SOURCE
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P_AGENT%/%MDP_P_AGENT%@%INSTANCE_P_AGENT% -sql "SELECT * FROM G_GESTIONGEO.TA_GG_SOURCE" -nln TEMP_TA_GG_SOURCE

:: 6. MISE EN PAUSE
PAUSE