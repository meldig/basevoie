/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE rafraîchissant la VM VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE le premier dimanche du mois à 07h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE"'');', 
   start_date        =>  '02/07/23 07:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=MONTHLY; INTERVAL=1; BYDAY=SAT',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE le premier dimanche du mois à 07h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE');
END;

/

