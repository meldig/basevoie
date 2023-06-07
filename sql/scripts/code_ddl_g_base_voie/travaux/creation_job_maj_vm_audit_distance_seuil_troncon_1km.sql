/*
Création du job JOB_MAJ_VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM rafraîchissant la VM VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM tous les samedis à 08h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM"'');', 
   start_date        =>  '10/06/23 08:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=DAILY; INTERVAL=7; BYDAY=SAT',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM tous les samedis à 08h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM');
END;

/

