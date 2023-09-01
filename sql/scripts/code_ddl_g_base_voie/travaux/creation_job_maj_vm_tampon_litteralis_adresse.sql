/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_ADRESSE rafraîchissant la VM VM_TAMPON_LITTERALIS_ADRESSE le premier dimanche du mois à 09h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_TAMPON_LITTERALIS_ADRESSE',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_TAMPON_LITTERALIS_ADRESSE"'');', 
   start_date        =>  '02/09/23 09:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=MONTHLY; INTERVAL=1; BYDAY=SAT',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE le premier dimanche du mois à 09h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_TAMPON_LITTERALIS_ADRESSE');
END;

/

