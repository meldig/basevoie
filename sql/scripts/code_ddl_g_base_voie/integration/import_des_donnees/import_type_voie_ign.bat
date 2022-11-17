@echo off
:: utilisation de ogr2ogr pour exporter des tables de oracle 11g vers oracle 12c
SET /p CHEMIN_INTEGRATION="Veuillez saisir le chemin d'acces au dossier import des donnees : "
SET /p USER_D="Veuillez saisir l'utilisateur Oracle de destination : "
SET /p MDP_D="Veuillez saisir le mot de passe de l'utilisateur Oracle de destination : "
SET /p INSTANCE_D="Veuillez saisir l'instance Oracle de destination: "

:: 2. se mettre dans l'environnement QGIS
cd C:\Program Files\QGIS 3.20.3\bin

:: 3. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 4. Rediriger la variable PROJ_LIB vers le bon fichier proj.db afin qu'ogr2ogr trouve le bon scr
setx PROJ_LIB "C:\Program Files\QGIS 3.20.3\share\proj"

:: 5. commande ogr2ogr pour exporter les couches du schéma X@X vers le schéma X@X
:: 5.15. table type_voie_ign
ogr2ogr.exe -f OCI OCI:%USER_D%/%MDP_D%@%INSTANCE_D% %CHEMIN_INTEGRATION%/type_voie_ign.csv

:: 6. MISE EN PAUSE
PAUSE