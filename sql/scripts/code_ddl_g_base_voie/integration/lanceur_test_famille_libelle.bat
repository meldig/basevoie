@echo off
:: utilisation de ogr2ogr pour exporter des tables de CUDL vers MULTIT
echo Bienvenu dans l'import des donnees de la base voie du schema actuel vers le nouveau ! 
:: 1. gestion des identifiants Oracle
SET /p USER_FAM_LIB_D="Famille - Libelle : Veuillez saisir l'utilisateur Oracle de destination : "
SET /p MDP_FAM_LIB_D="Famille - Libelle : Veuillez saisir le mot de passe de l'utilisateur Oracle de destination : "
SET /p INSTANCE_FAM_LIB_D="Famille - Libelle : Veuillez saisir l'instance Oracle de destination : "
SET /p CHEMIN_INTEGRATION="Veuillez saisir le chemin d'acces au dossier integration : "

:: 2. se mettre dans l'environnement QGIS
cd C:\Program Files\QGIS 3.16.9\bin

:: 3. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 4. Rediriger la variable PROJ_LIB vers le bon fichier proj.db afin qu'ogr2ogr trouve le bon scr
setx PROJ_LIB "C:\Program Files\QGIS 3.16\share\proj"

:: 5. commande ogr2ogr pour exporter les couches du schéma X@X vers le schéma X@X

:: 5.13. table TEMP_FAMILLE
ogr2ogr.exe -f OCI OCI:%USER_FAM_LIB_D%/%MDP_FAM_LIB_D%@%INSTANCE_FAM_LIB_D% %CHEMIN_INTEGRATION%/TEMP_FAMILLE.csv

:: 5.14. table TEMP_FAMILLE
ogr2ogr.exe -f OCI OCI:%USER_FAM_LIB_D%/%MDP_FAM_LIB_D%@%INSTANCE_FAM_LIB_D% %CHEMIN_INTEGRATION%/TEMP_LIBELLE.csv

:: 6. MISE EN PAUSE
PAUSE