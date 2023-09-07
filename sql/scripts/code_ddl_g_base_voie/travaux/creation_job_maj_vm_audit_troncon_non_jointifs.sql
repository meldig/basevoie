/*
Création du job JOB_MAJ_VM_AUDIT_TRONCON_NON_JOINTIFS rafraîchissant la VM VM_AUDIT_TRONCON_NON_JOINTIFS chaque dimanche à 14h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_AUDIT_TRONCON_NON_JOINTIFS',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_AUDIT_TRONCON_NON_JOINTIFS");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-09-09 14:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
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

