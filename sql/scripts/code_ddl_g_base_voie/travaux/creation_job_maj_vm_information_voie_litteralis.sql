/*
Création du job JOB_MAJ_VM_INFORMATION_VOIE_LITTERALIS rafraîchissant la VM VM_INFORMATION_VOIE_LITTERALIS le premier dimanche du mois à 17h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_INFORMATION_VOIE_LITTERALIS',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_INFORMATION_VOIE_LITTERALIS");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-10-01 17:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=MONTHLY;BYTIME=170000;BYDAY=SUN',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS le premier dimanche du mois à 17h00.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_INFORMATION_VOIE_LITTERALIS', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_INFORMATION_VOIE_LITTERALIS', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

