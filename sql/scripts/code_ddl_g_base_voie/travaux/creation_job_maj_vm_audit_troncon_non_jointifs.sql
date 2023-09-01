/*
Création du job JOB_MAJ_VM_AUDIT_TRONCON_NON_JOINTIFS rafraîchissant la VM VM_AUDIT_TRONCON_NON_JOINTIFS chaque dimanche à 14h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_AUDIT_TRONCON_NON_JOINTIFS',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_AUDIT_TRONCON_NON_JOINTIFS"'');', 
   start_date        =>  '03/09/23 14:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=WEEKLY; INTERVAL=1; BYDAY=SUN',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_AUDIT_TRONCON_NON_JOINTIFS chaque dimanche à 14h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_AUDIT_TRONCON_NON_JOINTIFS');
END;

/

