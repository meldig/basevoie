CREATE OR REPLACE FUNCTION GET_CODE_INSEE_TRONCON(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
/*
Cette fonction a pour objectif de récupérer le code INSEE de chaque tronçon.
Pour cela elle traite différents cas via les fonctions ci-dessous :
- GET_CODE_INSEE_CONTAIN ;
- GET_CODE_INSEE_POURCENTAGE ;
- GET_CODE_INSEE_WITHIN_DISTANCE ;
*/
    DETERMINISTIC
    As
    v_code_insee CHAR(8);
    BEGIN
        IF GET_CODE_INSEE_CONTAIN(v_table_name, v_geometry) <> 'error' THEN
            v_code_insee := GET_CODE_INSEE_CONTAIN(v_table_name, v_geometry);
        ELSIF GET_CODE_INSEE_POURCENTAGE(v_table_name, v_geometry) <> 'error' THEN
            v_code_insee := GET_CODE_INSEE_POURCENTAGE(v_table_name, v_geometry);
        ELSIF GET_CODE_INSEE_WITHIN_DISTANCE(v_table_name, v_geometry) <> 'error' THEN
            v_code_insee := GET_CODE_INSEE_WITHIN_DISTANCE(v_table_name, v_geometry);
        END IF;
        RETURN v_code_insee;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'erreur';
    END GET_CODE_INSEE_TRONCON;
    
/
