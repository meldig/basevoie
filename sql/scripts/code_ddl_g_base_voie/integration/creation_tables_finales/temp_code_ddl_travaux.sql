/*
Création du job JOB_MAJ_VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR rafraîchissant la VM VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR chaque dimanche à 08h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR"'');', 
   start_date        =>  '03/09/23 08:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=WEEKLY; INTERVAL=1; BYDAY=SUN',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR chaque dimanche à 08h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR');
END;

/

/*
Création du job JOB_MAJ_VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM rafraîchissant la VM VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM chaque dimanche à 10h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM"'');', 
   start_date        =>  '03/09/23 10:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=WEEKLY; INTERVAL=1; BYDAY=SUN',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM chaque dimanche à 10h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM');
END;

/

/*
Création du job JOB_MAJ_VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE rafraîchissant la VM VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE chaque dimanche à 12h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE"'');', 
   start_date        =>  '03/09/23 12:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=WEEKLY; INTERVAL=1; BYDAY=SUN',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE chaque dimanche à 12h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE');
END;

/

/*
Création du job JOB_MAJ_VM_AUDIT_TRONCON_NON_JOINTIFS rafraîchissant la VM VM_AUDIT_TRONCON_NON_JOINTIFS chaque dimanche à 14h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_MAJ_VM_AUDIT_TRONCON_NON_JOINTIFS',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DBMS_REFRESH.REFRESH(''"G_BASE_VOIE"."VM_AUDIT_TRONCON_NON_JOINTIFS"'');', 
   start_date        =>  '03/09/23 14:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=WEEKLY; INTERVAL=1; BYDAY=SUN',
   comments          =>  'Ce job rafraîchit la VM G_BASE_VOIE.VM_AUDIT_TRONCON_NON_JOINTIFS chaque dimanche à 14h00.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_MAJ_VM_AUDIT_TRONCON_NON_JOINTIFS');
END;

/

/*
Création du job JOB_GESTION_VOIE_PHYSIQUE qui, déclenché toutes les heures du lunid au vendredi, supprime les voies physiques rattachées à aucun tronçon et aucune voie administrative.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_GESTION_VOIE_PHYSIQUE',
   job_type          =>  'PLSQL_BLOCK',
   job_action        =>  'DELETE FROM G_BASE_VOIE.TA_VOIE_PHYSIQUE WHERE objectid NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TA_TRONCON) AND objectid NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE);', 
   start_date        =>  '01/09/23 10:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=HOURLY; INTERVAL=1; BYDAY=MON,TUE,WED,THU,FRI',
   comments          =>  'Le job - JOB_GESTION_VOIE_PHYSIQUE - déclenché toutes les heures supprime les voies physiques rattachées à aucun tronçon et aucune voie administrative.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_GESTION_VOIE_PHYSIQUE');
END;

/

