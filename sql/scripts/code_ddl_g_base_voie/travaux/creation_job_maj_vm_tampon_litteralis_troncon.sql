/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_TRONCON rafraîchissant la VM VM_TAMPON_LITTERALIS_TRONCON le dernier dimanche de chaque mois à 15h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_TAMPON_LITTERALIS_TRONCON',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_TAMPON_LITTERALIS_TRONCON"'');', 
   start_date        =>  '25/06/23 15:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=MONTHLY; INTERVAL=1; BYDAY=SUN',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON le dernier dimanche de chaque mois à 15h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_TAMPON_LITTERALIS_TRONCON');
END;

/

