@echo off
:: utilisation de ogr2ogr pour exporter des tables de CUDL vers MULTIT
echo Bienvenu dans l'import des donnees de la base voie du schema actuel vers le nouveau ! 
:: 1. gestion des identifiants Oracle
SET /p USER_D="Veuillez saisir l'utilisateur Oracle de destination : "
SET /p USER_P="Veuillez saisir l'utilisateur Oracle de provenance : "
SET /p USER_P_AGENT="Veuillez saisir l'utilisateur Oracle de provenance pour les AGENTS : "
SET /p MDP_D="Veuillez saisir le mot de passe de l'utilisateur Oracle de destination : "
SET /p MDP_P="Veuillez saisir le mot de passe de l'utilisateur Oracle de provenance : "
SET /p MDP_P_AGENT="Veuillez saisir le mot de passe de l'utilisateur Oracle de provenance pour les AGENTS : "
SET /p INSTANCE_D="Veuillez saisir l'instance Oracle de destination: "
SET /p INSTANCE_P="Veuillez saisir l'instance Oracle de provenance : "
SET /p INSTANCE_P_AGENT="Veuillez saisir l'instance Oracle de provenance pour les AGENTS : "

:: 2. se mettre dans l'environnement QGIS
cd C:\Program Files\QGIS 3.16\bin

:: 3. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 4. Rediriger la variable PROJ_LIB vers le bon fichier proj.db afin qu'ogr2ogr trouve le bon scr
setx PROJ_LIB "C:\Program Files\QGIS 3.16\share\proj"

:: 5. commande ogr2ogr pour exporter les couches du schéma X@X vers le schéma X@X
:: 5.1. table ILTATRC
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P% -sql "SELECT * FROM G_SIDU.ILTATRC" -nln TEMP_ILTATRC -nlt LINESTRING -lco SRID=2154 -dim 2

:: 5.2. table ILTAPTZ
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P% -sql "SELECT * FROM G_SIDU.ILTAPTZ" -nln TEMP_ILTAPTZ -nlt POINT -lco SRID=2154 -dim 2

:: 5.3. table ILTADTN
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P% -sql "SELECT * FROM G_SIDU.ILTADTN" -nln TEMP_ILTADTN

:: 5.4. table VOIEVOI
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P% -sql "SELECT * FROM G_SIDU.VOIEVOI" -nln TEMP_VOIEVOI

:: 5.5. table VOIECVT
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P% -sql "SELECT * FROM G_SIDU.VOIECVT" -nln TEMP_VOIECVT

:: 5.6. table VOIECVT
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P% -sql "SELECT * FROM G_SIDU.TYPEVOIE" -nln TEMP_TYPEVOIE

:: 5.7. table VOIECVT
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P% -sql "SELECT * FROM G_SIDU.ILTASEU" -nln TEMP_ILTASEU -nlt POINT -lco SRID=2154 -dim 2

:: 5.8. table VOIECVT
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P% -sql "SELECT * FROM G_SIDU.ILTASIT" -nln TEMP_ILTASIT

:: 5.9. table VOIECVT
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P% -sql "SELECT * FROM G_SIDU.ILTAFILIA" -nln TEMP_ILTAFILIA

:: 5.10. table VOIECVT
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P% -sql "SELECT * FROM G_SIDU.TA_RUE" -nln TEMP_TA_RUE

:: 5.11. table VOIECVT
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P% -sql "SELECT * FROM G_SIDU.TA_RUEVOIE" -nln TEMP_TA_RUEVOIE

:: 5.12. table VOIECVT
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P%/%MDP_P%@%INSTANCE_P% -sql "SELECT * FROM G_SIDU.ILTALPU" -nln TEMP_ILTALPU

:: 5.13. table TA_GG_SOURCE
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% OCI:%USER_P_AGENT%/%MDP_P_AGENT%@%INSTANCE_P_AGENT% -sql "SELECT * FROM G_GESTIONGEO.TA_GG_SOURCE" -nln TEMP_TA_GG_SOURCE

:: 6. MISE EN PAUSE
PAUSE