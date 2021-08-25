CREATE OR REPLACE FUNCTION GET_CODE_INSEE_TRONCON(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
/*
Cette fonction a pour objectif de récupérer le code INSEE de chaque tronçon.
La variable v_table_name doit contenir le nom de la table dont on veut connaître le code INSEE des objets.
La variable v_geometry doit contenir le nom du champ géométrique de la table interrogée.
Pour cela elle traite différents cas via les fonctions ci-dessous :
- GET_CODE_INSEE_CONTAIN ;
- GET_CODE_INSEE_POURCENTAGE ;
- GET_CODE_INSEE_WITHIN_DISTANCE ;
*/
    DETERMINISTIC
    As
    v_code_insee CHAR(8);
    BEGIN
        IF GET_CODE_INSEE_CONTAIN_LINE(v_table_name, v_geometry) <> 'error' THEN
            v_code_insee := GET_CODE_INSEE_CONTAIN_LINE(v_table_name, v_geometry);
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
