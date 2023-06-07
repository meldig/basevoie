/*
Création du job JOB_MAJ_VM_CONSULTATION_BASE_VOIE rafraîchissant la VM VM_CONSULTATION_BASE_VOIE du lundi au vendredi à 19h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_CONSULTATION_BASE_VOIE',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_CONSULTATION_BASE_VOIE"'');', 
   start_date        =>  '07/06/23 19:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=DAILY; INTERVAL=1; BYDAY=MON,TUE,WED,THU,FRI',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE du lundi au vendredi à 19h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_CONSULTATION_BASE_VOIE');
END;

/

