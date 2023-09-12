@echo off
echo Bienvenu dans la creation des travaux du projet LITTERALIS de la Base Voie !

:: 1. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 2. Déclaration et valorisation des variables
SET /p chemin_code_tavaux="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des TRAVAUX du projet LITTERALIS : "
SET /p chemin_code_temp="Veuillez saisir le chemin d'acces du dossier litteralis : "

copy /b %chemin_code_tavaux%\creation_job_maj_vm_tampon_litteralis_voie_administrative.sql + ^
%chemin_code_tavaux%\creation_job_maj_vm_tampon_litteralis_troncon.sql + ^
%chemin_code_tavaux%\creation_job_maj_vm_tampon_litteralis_adresse.sql + ^
%chemin_code_tavaux%\creation_job_maj_vm_territoire_voirie.sql + ^
%chemin_code_tavaux%\creation_job_maj_vm_unite_territoriale_voirie.sql + ^
%chemin_code_tavaux%\creation_job_maj_vm_tampon_litteralis_zone_agglomeration.sql + ^
%chemin_code_tavaux%\creation_job_maj_vm_tampon_litteralis_zone_particuliere_en_agglo.sql + ^
%chemin_code_tavaux%\creation_job_maj_vm_tampon_litteralis_zone_particuliere_hors_agglo.sql + ^
%chemin_code_tavaux%\creation_job_maj_vm_tampon_litteralis_zone_particuliere_intersect_agglo.sql + ^
%chemin_code_tavaux%\creation_job_maj_vm_tampon_litteralis_zone_particuliere_intersect_hors_agglo.sql + ^
%chemin_code_tavaux%\creation_job_maj_vm_tampon_litteralis_regroupement.sql + ^
%chemin_code_tavaux%\creation_job_maj_vm_information_voie_litteralis.sql ^
%chemin_code_temp%\temp_code_ddl_travaux_projet_litteralis.sql

:: 5. MISE EN PAUSE
PAUSE