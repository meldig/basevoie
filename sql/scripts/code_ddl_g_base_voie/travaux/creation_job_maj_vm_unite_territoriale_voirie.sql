/*
Création du job JOB_MAJ_VM_UNITE_TERRITORIALE_VOIRIE rafraîchissant la VM VM_UNITE_TERRITORIALE_VOIRIE le premier dimanche du mois à 11h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_UNITE_TERRITORIALE_VOIRIE',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_UNITE_TERRITORIALE_VOIRIE"'');', 
   start_date        =>  '02/09/23 11:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=MONTHLY; INTERVAL=1; BYDAY=SAT',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE le premier dimanche du mois à 11h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_UNITE_TERRITORIALE_VOIRIE');
END;

/

