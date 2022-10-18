CREATE OR REPLACE FUNCTION GET_TYPE_VOIE(v_fid_type_voie NUMBER) RETURN CHAR
/*
Cette fonction a pour objectif de récupérer le type de voie de chaque voie administrative
*/
    DETERMINISTIC
    As
    v_type_voie CHAR(18);
    BEGIN
        SELECT
            TRIM(libelle)
            INTO v_type_voie
        FROM
            G_BASE_VOIE.TEMP_C_TYPE_VOIE
        WHERE
            objectid = v_fid_type_voie;
        RETURN v_type_voie;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'erreur';
    END GET_TYPE_VOIE;

/

