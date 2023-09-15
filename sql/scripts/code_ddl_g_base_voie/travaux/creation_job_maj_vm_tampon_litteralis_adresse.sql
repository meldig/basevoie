/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_ADRESSE rafraîchissant la VM VM_TAMPON_LITTERALIS_ADRESSE le premier dimanche du mois à 09h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ADRESSE',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_TAMPON_LITTERALIS_ADRESSE");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-10-01 09:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=MONTHLY;BYTIME=090000;BYDAY=SUN',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE le premier dimanche du mois à 09h00.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ADRESSE', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ADRESSE', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

