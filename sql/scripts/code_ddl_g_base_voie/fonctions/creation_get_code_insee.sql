/*
la fonction ci-dessus a pour objectif de retouver le code insee de la commune dans laquelle est contenu le nouvel objet géographique d'une table. L'utilisation de cette fonction est nécessaire dans le champ virtuel code_insee de la base voie car les expressions des champs virtuels ne peuvent utiliser que des champs de la table.
*/

create or replace FUNCTION GET_CODE_INSEE(v_geometry SDO_GEOMETRY) RETURN CHAR
-- Cette fonction a pour objectid de récupérer le code insse de la commune dans laquelle est contenu un objet géométrique
    DETERMINISTIC
    As
    v_code_insee CHAR(5);
    BEGIN      
        Begin
            SELECT
                b.code_insee INTO v_code_insee
            FROM
                G_REFERENTIEL.A_COMMUNE b
            WHERE
                SDO_CONTAINS(b.geom, v_geometry) = 'TRUE';
            return v_code_insee;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
             RETURN 'error';
        END;        
    END GET_CODE_INSEE;