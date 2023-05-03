/*
Création du job JOB_LANCEMENT_GESTION_CONSULTATION_BASE_VOIE permettant de lancer la procédure GESTION_CONSULTATION_BASE_VOIE toutes les minutes de 07h00 à 20h00 du lundi au vendredi.
L'objectif est de mettre à jour la table TEMP_J_CONSULTATION_BASE_VOIE permettant de consulter les objets de la base voie.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
   job_name          =>  'JOB_LANCEMENT_GESTION_CONSULTATION_BASE_VOIE',
   job_type          =>  'STORED_PROCEDURE',
   job_action        =>  '"G_BASE_VOIE"."GESTION_CONSULTATION_BASE_VOIE"', 
   start_date        =>  '02/05/23 16:37:00 EUROPE/PARIS',
   repeat_interval   =>  'FREQ=MINUTELY; INTERVAL=5; BYDAY=MON,TUE,WED,THU,FRI; BYHOUR=7,20',
   comments          =>  'Ce job déclenche la procédure GESTION_CONSULTATION_BASE_VOIE toutes les minutes, de 07h00 à 20h00 du lundi au vendredi, afin de mettre à jour la table TEMP_J_CONSULTATION_BASE_VOIE permettant de consulter les objets de la base voie.');
END;
/

BEGIN
 DBMS_SCHEDULER.ENABLE ('JOB_LANCEMENT_GESTION_CONSULTATION_BASE_VOIE');
END;

/

