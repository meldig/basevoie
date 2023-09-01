/*
Création du job JOB_MAJ_VM_INFORMATION_VOIE_LITTERALIS rafraîchissant la VM VM_INFORMATION_VOIE_LITTERALIS le premier dimanche du mois à 17h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_INFORMATION_VOIE_LITTERALIS',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_INFORMATION_VOIE_LITTERALIS"'');', 
   start_date        =>  '02/09/23 17:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=MONTHLY; INTERVAL=1; BYDAY=SAT',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS le premier dimanche du mois à 17h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_INFORMATION_VOIE_LITTERALIS');
END;

/

