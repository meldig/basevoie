/*
Création du job JOB_MAJ_VM_CONSULTATION_VOIE_PHYSIQUE rafraîchissant la VM VM_CONSULTATION_VOIE_PHYSIQUE du lundi au samedi à 04h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_CONSULTATION_VOIE_PHYSIQUE',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_CONSULTATION_VOIE_PHYSIQUE"'');', 
   start_date        =>  '08/06/23 04:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=DAILY; INTERVAL=1; BYDAY=MON,TUE,WED,THU,FRI,SAT',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE du lundi au samedi à 04h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_CONSULTATION_VOIE_PHYSIQUE');
END;

/

