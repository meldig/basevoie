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

/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_TRONCON rafraîchissant la VM VM_TAMPON_LITTERALIS_TRONCON le premier dimanche du mois à 08h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_TAMPON_LITTERALIS_TRONCON',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_TAMPON_LITTERALIS_TRONCON"'');', 
   start_date        =>  '02/09/23 08:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=MONTHLY; INTERVAL=1; BYDAY=SAT',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON le premier dimanche du mois à 08h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_TAMPON_LITTERALIS_TRONCON');
END;

/

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

/*
Création du job JOB_MAJ_VM_UNITE_TERRITORIALE_VOIRIE rafraîchissant la VM VM_UNITE_TERRITORIALE_VOIRIE le premier dimanche du mois à 11h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_UNITE_TERRITORIALE_VOIRIE',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_UNITE_TERRITORIALE_VOIRIE"'');', 
   start_date        =>  '02/09/23 11:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=MONTHLY; INTERVAL=1; BYDAY=SAT',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE le premier dimanche du mois à 11h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_UNITE_TERRITORIALE_VOIRIE');
END;

/

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

/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO rafraîchissant la VM VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO le premier dimanche du mois à 13h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO"'');', 
   start_date        =>  '02/09/23 13:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=MONTHLY; INTERVAL=1; BYDAY=SAT',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO le premier dimanche du mois à 13h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO');
END;

/

/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO rafraîchissant la VM VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO le premier dimanche du mois à 14h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO"'');', 
   start_date        =>  '02/09/23 13:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=MONTHLY; INTERVAL=1; BYDAY=SAT',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO le premier dimanche du mois à 13h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO');
END;

/

/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO rafraîchissant la VM VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO le premier dimanche du mois à 15h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO"'');', 
   start_date        =>  '02/09/23 15:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=MONTHLY; INTERVAL=1; BYDAY=SAT',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO le premier dimanche du mois à 15h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO');
END;

/

/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO rafraîchissant la VM VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO le premier dimanche du mois à 16h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO"'');', 
   start_date        =>  '02/09/23 16:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=MONTHLY; INTERVAL=1; BYDAY=SAT',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO le premier dimanche du mois à 16h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO');
END;

/

/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_REGROUPEMENT rafraîchissant la VM VM_TAMPON_LITTERALIS_REGROUPEMENT le premier dimanche du mois à 10h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_TAMPON_LITTERALIS_REGROUPEMENT',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_TAMPON_LITTERALIS_REGROUPEMENT"'');', 
   start_date        =>  '02/09/23 16:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=MONTHLY; INTERVAL=1; BYDAY=SAT',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT le premier dimanche du mois à 16h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_TAMPON_LITTERALIS_REGROUPEMENT');
END;

/

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

