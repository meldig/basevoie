/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION rafraîchissant la VM VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION le premier dimanche du mois à 12h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION"'');', 
   start_date        =>  '02/09/23 12:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=MONTHLY; INTERVAL=1; BYDAY=SUN',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION le premier dimanche du mois à 12h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION');
END;

/

