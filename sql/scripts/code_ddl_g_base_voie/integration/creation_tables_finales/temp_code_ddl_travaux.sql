/*
Création du job JOB_MAJ_VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR rafraîchissant la VM VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR chaque dimanche à 08h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-09-30 08:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=WEEKLY;BYTIME=080000;BYDAY=SAT',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR chaque samedi à 08h00.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

/*
Création du job JOB_MAJ_VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM rafraîchissant la VM VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM chaque dimanche à 10h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-09-30 10:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=WEEKLY;BYTIME=100000;BYDAY=SAT',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM chaque samedi à 10h00.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

/*
Création du job JOB_MAJ_VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE rafraîchissant la VM VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE chaque dimanche à 12h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-09-30 12:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=WEEKLY;BYTIME=120000;BYDAY=SAT',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE chaque samedi à 12h00.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

/*
Création du job JOB_MAJ_VM_AUDIT_TRONCON_NON_JOINTIFS rafraîchissant la VM VM_AUDIT_TRONCON_NON_JOINTIFS chaque dimanche à 14h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_AUDIT_TRONCON_NON_JOINTIFS',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_AUDIT_TRONCON_NON_JOINTIFS");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-09-30 14:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=WEEKLY;BYTIME=140000;BYDAY=SAT',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_AUDIT_TRONCON_NON_JOINTIFS chaque samedi à 14h00.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_AUDIT_TRONCON_NON_JOINTIFS', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_AUDIT_TRONCON_NON_JOINTIFS', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

/*
Création du job JOB_GESTION_VOIE_PHYSIQUE qui, déclenché toutes les heures du lunid au vendredi, supprime les voies physiques rattachées à aucun tronçon et aucune voie administrative.
*/
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_GESTION_VOIE_PHYSIQUE',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DELETE FROM G_BASE_VOIE.TA_VOIE_PHYSIQUE WHERE objectid NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TA_TRONCON) AND objectid NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE);',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-09-15 18:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=HOURLY;BYDAY=MON,TUE,WED,THU,FRI',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Le job - JOB_GESTION_VOIE_PHYSIQUE - déclenché toutes les heures supprime les voies physiques rattachées à aucun tronçon et aucune voie administrative.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_GESTION_VOIE_PHYSIQUE', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_GESTION_VOIE_PHYSIQUE', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

