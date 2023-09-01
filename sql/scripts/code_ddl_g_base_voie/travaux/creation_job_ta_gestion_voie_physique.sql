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

