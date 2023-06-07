/*
Création du job JOB_MAJ_VM_AUDIT_TRONCON_NON_JOINTIFS rafraîchissant la VM VM_AUDIT_TRONCON_NON_JOINTIFS tous les samedis à 12h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_AUDIT_TRONCON_NON_JOINTIFS',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_AUDIT_TRONCON_NON_JOINTIFS"'');', 
   start_date        =>  '10/06/23 12:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=DAILY; INTERVAL=7; BYDAY=SAT',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_AUDIT_TRONCON_NON_JOINTIFS tous les samedis à 12h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_AUDIT_TRONCON_NON_JOINTIFS');
END;

/

