# Méthode de migration des données de la Base Voie d'Oracle 11g vers Oracle 12g

## 1. Supprimez les objets d'import d'Oracle 12c
Dans SqlDevelopper veuillez lancer le code du fichier ![suppression_tables_d_import_temporaires.sql](../suppression_objets_schema/suppression_tables_d_import_temporaires.sql).

## 2. Importez les données d'Oracle 11g vers Oracle 12c
Veuillez double_cliquer sur le fichier ![import_donnees_tables_base_voie.bat](../import_des_donnees/import_donnees_tables_base_voie.bat) **après vous être assuré de disposer du fichier TEMP_AGENT.csv en local**.

## 3. Créez les index et les déclenceurs de protection des tables d'import
Dans SqlDevelopper veuillez lancer le code du fichier ![creation_index_triggers_tables_d_import.sql](/creation_index_triggers_tables_d_import.sql).

## 4. Matérialisez les voies à partir des tables d'import
Dans SqlDevelopper veuillez lancer le code du fichier ![creation_vm_temp_import_voie_agregee.sql](../../vues_materialisees/creation_vm_temp_import_voie_agregee.sql).