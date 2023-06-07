/*
Création du job JOB_MAJ_VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR rafraîchissant la VM VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR tous les samedis à 18h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR"'');', 
   start_date        =>  '10/06/23 18:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=DAILY; INTERVAL=7; BYDAY=SAT',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR tous les samedis à 18h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR');
END;

/

