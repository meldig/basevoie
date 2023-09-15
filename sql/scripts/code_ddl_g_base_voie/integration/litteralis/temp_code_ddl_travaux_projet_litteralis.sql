/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE rafraîchissant la VM VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE le premier samedi du mois à 07h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-10-01 07:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=MONTHLY;BYTIME=070000;BYDAY=SAT',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE le premier samedi du mois à 07h00.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_TRONCON rafraîchissant la VM VM_TAMPON_LITTERALIS_TRONCON le premier dimanche du mois à 08h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_TRONCON',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_TAMPON_LITTERALIS_TRONCON");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-10-01 08:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=MONTHLY;BYTIME=080000;BYDAY=SAT',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON le premier dimanche du mois à 08h00.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_TRONCON', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_TRONCON', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_ADRESSE rafraîchissant la VM VM_TAMPON_LITTERALIS_ADRESSE le premier dimanche du mois à 09h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ADRESSE',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_TAMPON_LITTERALIS_ADRESSE");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-10-01 09:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=MONTHLY;BYTIME=090000;BYDAY=SUN',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE le premier dimanche du mois à 09h00.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ADRESSE', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ADRESSE', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

/*
Création du job JOB_MAJ_VM_TERRITOIRE_VOIRIE rafraîchissant la VM VM_TERRITOIRE_VOIRIE le premier dimanche du mois à 10h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_TERRITOIRE_VOIRIE',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_TERRITOIRE_VOIRIE");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-10-01 10:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=MONTHLY;BYTIME=100000;BYDAY=SUN',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_TERRITOIRE_VOIRIE le premier dimanche du mois à 10h00.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TERRITOIRE_VOIRIE', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TERRITOIRE_VOIRIE', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

/*
Création du job JOB_MAJ_VM_UNITE_TERRITORIALE_VOIRIE rafraîchissant la VM VM_UNITE_TERRITORIALE_VOIRIE le premier dimanche du mois à 11h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_UNITE_TERRITORIALE_VOIRIE',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_UNITE_TERRITORIALE_VOIRIE");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-10-01 11:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=MONTHLY;BYTIME=110000;BYDAY=SUN',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_UNITE_TERRITORIALE_VOIRIE le premier dimanche du mois à 11h00.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_UNITE_TERRITORIALE_VOIRIE', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_UNITE_TERRITORIALE_VOIRIE', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION rafraîchissant la VM VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION le premier dimanche du mois à 12h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-10-01 12:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=MONTHLY;BYTIME=120000;BYDAY=SUN',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION le premier dimanche du mois à 12h00.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_AGGLOMERATION', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO rafraîchissant la VM VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO le premier dimanche du mois à 13h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-10-01 13:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=MONTHLY;BYTIME=130000;BYDAY=SUN',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO le premier dimanche du mois à 13h00.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_EN_AGGLO', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO rafraîchissant la VM VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO le premier dimanche du mois à 14h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-10-01 14:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=MONTHLY;BYTIME=140000;BYDAY=SUN',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO le premier dimanche du mois à 14h00.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_HORS_AGGLO', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO rafraîchissant la VM VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO le premier dimanche du mois à 15h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-10-01 15:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=MONTHLY;BYTIME=150000;BYDAY=SUN',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO le premier dimanche du mois à 15h00.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_AGGLO', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO rafraîchissant la VM VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO le premier samedi du mois à 16h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-10-01 16:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=MONTHLY;BYTIME=160000;BYDAY=SUN',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO le premier dimanche du mois à 16h00.');  
 e
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_ZONE_PARTICULIERE_INTERSECT_HORS_AGGLO', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

/*
Création du job JOB_MAJ_VM_TAMPON_LITTERALIS_REGROUPEMENT rafraîchissant la VM VM_TAMPON_LITTERALIS_REGROUPEMENT le premier dimanche du mois à 17h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_REGROUPEMENT',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_TAMPON_LITTERALIS_REGROUPEMENT");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-10-01 17:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=MONTHLY;BYTIME=170000;BYDAY=SUN',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_TAMPON_LITTERALIS_REGROUPEMENT le premier dimanche du mois à 17h00.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_REGROUPEMENT', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_TAMPON_LITTERALIS_REGROUPEMENT', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

/*
Création du job JOB_MAJ_VM_INFORMATION_VOIE_LITTERALIS rafraîchissant la VM VM_INFORMATION_VOIE_LITTERALIS le premier dimanche du mois à 17h00.
*/

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'JOB_MAJ_VM_INFORMATION_VOIE_LITTERALIS',
            job_type => 'PLSQL_BLOCK',
            job_action => 'DBMS_REFRESH.REFRESH("G_BASE_VOIE"."VM_INFORMATION_VOIE_LITTERALIS");',
            number_of_arguments => 0,
            start_date => TO_TIMESTAMP_TZ('2023-10-01 17:00:00.000000000 EUROPE/PARIS','YYYY-MM-DD HH24:MI:SS.FF TZR'),
            repeat_interval => 'FREQ=MONTHLY;BYTIME=170000;BYDAY=SUN',
            end_date => NULL,
            enabled => TRUE,
            auto_drop => FALSE,
            comments => 'Ce job rafraîchit la VM G_BASE_VOIE.VM_INFORMATION_VOIE_LITTERALIS le premier dimanche du mois à 17h00.');  
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_INFORMATION_VOIE_LITTERALIS', 
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'JOB_MAJ_VM_INFORMATION_VOIE_LITTERALIS', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
END;

/

