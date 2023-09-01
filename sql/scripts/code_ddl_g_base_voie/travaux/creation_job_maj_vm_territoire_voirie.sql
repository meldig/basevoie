/*
Création du job JOB_MAJ_VM_TERRITOIRE_VOIRIE rafraîchissant la VM VM_TERRITOIRE_VOIRIE le premier dimanche du mois à 10h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_TERRITOIRE_VOIRIE',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_TERRITOIRE_VOIRIE"'');', 
   start_date        =>  '02/09/23 10:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=MONTHLY; INTERVAL=1; BYDAY=SAT',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_TERRITOIRE_VOIRIE le premier dimanche du mois à 13h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_TERRITOIRE_VOIRIE');
END;

/

