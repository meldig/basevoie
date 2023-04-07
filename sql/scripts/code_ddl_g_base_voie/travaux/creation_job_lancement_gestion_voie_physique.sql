/*
Création du job JOB_LANCEMENT_GESTION_VOIE_PHYSIQUE permettant de lancer la procédure GESTION_VOIE_PHYSIQUE toutes les cinq minutes de 07h00 à 20h00 du lundi au vendredi.
L'objectif est de supprimer régulièrement toutes les voies physiques rattachées à aucun tronçon et aucune voie administrative.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_LANCEMENT_GESTION_VOIE_PHYSIQUE',
   job_type          =>  'STORED_PROCEDURE',
   job_action        =>  '"G_BASE_VOIE"."GESTION_VOIE_PHYSIQUE"', 
   start_date        =>  '06/04/23 16:00:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=MINUTELY; INTERVAL=5; BYDAY=MON,TUE,WED,THU,FRI; BYHOUR=7,20',
   comments          =>  'Ce job déclenche la procédure GESTION_VOIE_PHYSIQUE toutes les 5 minutes afin de supprimer les voies physiques rattachées à aucun tronçon et aucune voie administrative.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_LANCEMENT_GESTION_VOIE_PHYSIQUE');
END;

/

