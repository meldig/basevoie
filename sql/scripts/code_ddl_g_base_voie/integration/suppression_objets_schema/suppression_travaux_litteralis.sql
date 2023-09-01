-- Suppression des travaux
SET SERVEROUTPUT ON
BEGIN
  Dbms_Scheduler.Drop_Job (Job_Name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE');
  Dbms_Scheduler.Drop_Job (Job_Name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_TRONCON');
  Dbms_Scheduler.Drop_Job (Job_Name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ADRESSE');
  Dbms_Scheduler.Drop_Job (Job_Name => 'JOB_MAJ_VM_TERRITOIRE_VOIRIE');
  Dbms_Scheduler.Drop_Job (Job_Name => 'JOB_MAJ_VM_UNITE_TERRITORIALE_VOIRIE');
  Dbms_Scheduler.Drop_Job (Job_Name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION');
  Dbms_Scheduler.Drop_Job (Job_Name => 'JOB_MAJ_VM_INFORMATION_VOIE_LITTERALIS');
  Dbms_Scheduler.Drop_Job (Job_Name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO');
  Dbms_Scheduler.Drop_Job (Job_Name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO');
  Dbms_Scheduler.Drop_Job (Job_Name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO');
  Dbms_Scheduler.Drop_Job (Job_Name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO');
  Dbms_Scheduler.Drop_Job (Job_Name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_REGROUPEMENT');
END;













