/*
Création du job JOB_GESTION_VOIE_PHYSIQUE qui, déclenché toutes les heures du lunid au vendredi, supprime les voies physiques rattachées à aucun tronçon et aucune voie administrative.
*/
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_GESTION_VOIE_PHYSIQUE',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DELETE FROM G_BASE_VOIE.TA_VOIE_PHYSIQUE WHERE objectid NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TA_TRONCON) AND objectid NOT IN(SELECT fid_voie_physique FROM G_BASE_VOIE.TA_RELATION_VOIE_PHYSIQUE_ADMINISTRATIVE);',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-09-15 18:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=HOURLY;BYDAY=MON,TUE,WED,THU,FRI',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Le job - JOB_GESTION_VOIE_PHYSIQUE - déclenché toutes les heures supprime les voies physiques rattachées à aucun tronçon et aucune voie administrative.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_GESTION_VOIE_PHYSIQUE', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_GESTION_VOIE_PHYSIQUE', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

