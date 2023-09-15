@echo off
echo Bienvenu dans la creation des VM de la Base Voie !

:: 1. Configurer le système d'encodage des caractères en UTF-8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8

:: 2. Déclaration et valorisation des variables
SET /p chemin_code_vue_materialisees="Veuillez saisir le chemin d'acces du dossier contenant le code DDL des VUES MATERIALISEES du schema : "
SET /p chemin_code_droits="Veuillez saisir le chemin d'acces du dossier contenant le droits de lecture, écriture, suppression : "
SET /p chemin_code_temp="Veuillez saisir le chemin d'acces du dossier integration\creation_tables_finales : "

copy /b %chemin_code_temp%\selection_pour_faire_fonctionner_les_vues_et_vm.sql + ^
%chemin_code_vue_materialisees%\creation_vm_consultation_seuil.sql + ^
%chemin_code_vue_materialisees%\creation_vm_consultation_base_voie.sql + ^
%chemin_code_vue_materialisees%\creation_vm_consultation_voie_administrative.sql + ^
%chemin_code_vue_materialisees%\creation_vm_consultation_voie_physique.sql + ^
%chemin_code_vue_materialisees%\creation_vm_consultation_voie_supra_communale.sql + ^
%chemin_code_vue_materialisees%\creation_vm_audit_distance_seuil_troncon_1km.sql + ^
%chemin_code_vue_materialisees%\creation_vm_audit_doublon_numero_seuil_par_voie_administrative.sql + ^
%chemin_code_vue_materialisees%\creation_vm_audit_code_insee_seuil_en_erreur.sql + ^
%chemin_code_vue_materialisees%\creation_vm_audit_troncon_non_jointifs.sql + ^
%chemin_code_droits%\creation_droits_lecture_edition_vue_materialisee.sql ^
%chemin_code_temp%\temp_code_ddl_vue_materialisee.sql

:: 4. lancement de SQL plus.
::CD C:/ora12c/R1/BIN

:: 5. Execution de sqlplus. pour lancer les requetes SQL.
::sqlplus.exe %USER%/%MDP%@%INSTANCE% @%chemin_code_temp%\temp_code_ddl_schema_transitoire_projet_j.sql

:: 6. MISE EN PAUSE
PAUSE