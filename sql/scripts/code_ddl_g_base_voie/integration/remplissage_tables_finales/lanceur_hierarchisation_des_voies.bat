@echo off
echo Bienvenu dans la creation des VM de hierarchisation des voies de la Base Voie. ATTENTION : Ce programme cree un fichier a executer dans SQL/Developper !

:: 1. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 2. Déclaration et valorisation des variables
SET /p chemin_code_vue_materialise="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des VUES MATERIALISEES du schema : "
SET /p chemin_code_temp="Veuillez saisir le chemin d'acces du dossier integration : "

copy /b %chemin_code_vue_materialise%\creation_vm_voie_aggregee.sql + ^
%chemin_code_vue_materialise%\creation_vm_travail_voie_aggregee_code_insee.sql + ^
%chemin_code_vue_materialise%\creation_vm_travail_voie_code_insee_longueur.sql + ^
%chemin_code_vue_materialise%\creation_vm_travail_voie_principale_longueur.sql + ^
%chemin_code_vue_materialise%\creation_vm_travail_voie_secondaire_longueur.sql + ^
%chemin_code_vue_materialise%\creation_vm_hierarchie_voie_principale_secondaire_longueur.sql + ^
%chemin_code_temp%\remplissage_ta_hierarchisation_voie.sql + ^
%chemin_code_temp%\temp_hierarchie_voie.sql

:: 5. MISE EN PAUSE
PAUSE