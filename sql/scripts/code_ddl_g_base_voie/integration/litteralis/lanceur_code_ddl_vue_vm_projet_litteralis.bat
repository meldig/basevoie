@echo off
echo Bienvenu dans la creation des vues et vues matérialisées du projet LITTERALIS de la Base Voie !

:: 1. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 2. Déclaration et valorisation des variables
SET /p chemin_code_vue_materialisee="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des VUES MATERIALISEES du projet LITTERALIS : "
SET /p chemin_code_vue="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des VUES du projet LITTERALIS : "
SET /p chemin_droits="Veuillez saisir le chemin d'acces du dossier contenant le code des droits de lecture, insertion, édition et suppression des vues et VM du projet LITTERALIS : "
SET /p chemin_code_temp="Veuillez saisir le chemin d'acces du dossier integration : "

:: 3. Concaténation des codes des VM et vues
copy /b %chemin_code_vue_materialisee%\creation_vm_tampon_litteralis_correspondance_domanialite_classement.sql + ^
%chemin_code_vue_materialisee%\creation_vm_tampon_litteralis_voie_administrative.sql + ^
%chemin_code_vue_materialisee%\creation_vm_tampon_litteralis_troncon.sql + ^
%chemin_code_vue_materialisee%\creation_vm_tampon_litteralis_adresse.sql + ^
%chemin_code_vue_materialisee%\creation_vm_territoire_voirie.sql + ^
%chemin_code_vue_materialisee%\creation_vm_unite_territoriale_voirie.sql + ^
%chemin_code_vue_materialisee%\creation_vm_tampon_litteralis_regroupement.sql + ^
%chemin_code_vue_materialisee%\creation_vm_tampon_litteralis_zone_agglomeration.sql + ^
%chemin_code_vue_materialisee%\creation_vm_tampon_litteralis_zone_particuliere_en_agglo.sql + ^
%chemin_code_vue_materialisee%\creation_vm_tampon_litteralis_zone_particuliere_hors_agglo.sql + ^
%chemin_code_vue_materialisee%\creation_vm_tampon_litteralis_zone_particuliere_intersect_agglo.sql + ^
%chemin_code_vue_materialisee%\creation_vm_tampon_litteralis_zone_particuliere_intersect_hors_agglo.sql + ^
%chemin_code_vue_materialisee%\creation_vm_information_voie_litteralis.sql + ^
%chemin_code_vue%\creation_v_litteralis_troncon.sql + ^
%chemin_code_vue%\creation_v_litteralis_adresse.sql + ^
%chemin_code_vue%\creation_v_litteralis_regroupement.sql + ^
%chemin_code_vue%\creation_v_litteralis_zone_particuliere.sql + ^
%chemin_code_vue%\creation_v_litteralis_audit_troncon.sql + ^
%chemin_code_vue%\creation_v_litteralis_audit_adresse.sql + ^
%chemin_code_vue%\creation_v_litteralis_audit_zone_particuliere.sql + ^
%chemin_droits%\creation_droits_lecture_ecriture_suppression_litteralis.sql ^
%chemin_code_temp%\temp_code_ddl_vue_vm_projet_litteralis.sql

:: 5. MISE EN PAUSE
PAUSE