/*
Création du job JOB_MAJ_VM_CONSULTATION_SEUIL rafraîchissant la VM VM_CONSULTATION_SEUIL du lundi au samedi à 05h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_CONSULTATION_SEUIL',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_CONSULTATION_SEUIL"'');', 
   start_date        =>  '08/06/23 05:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=DAILY; INTERVAL=1; BYDAY=MON,TUE,WED,THU,FRI,SAT',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_CONSULTATION_SEUIL du lundi au samedi à 05h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_CONSULTATION_SEUIL');
END;

/

