/*
la fonction ci-dessous a pour objectif de retouver le code insee de la commune dans laquelle se trouve un objet linéaire.
Cette fonction retourne le code insee de la commune dans laquelle plus de 50% de l'objet se trouve.
*/

create or replace FUNCTION GET_CODE_INSEE(v_geometry SDO_GEOMETRY, v_nom_table VARCHAR2) RETURN CHAR
-- Cette fonction a pour objectid de récupérer le code insse de la commune dans laquelle est contenu un linéaire géométrique
-- ATTENTION : cette fonction n'est valable que pour du linéaire, pas pour du surfacique ou du point
    DETERMINISTIC
    As
    v_code_insee CHAR(5);
    BEGIN      
        Begin
            SELECT
                b.code_insee INTO v_code_insee
            FROM
                G_REFERENTIEL.A_COMMUNE b,
                USER_SDO_GEOM_METADATA m
            WHERE
                SDO_ANYINTERACT(v_geometry, b.geom) = 'TRUE'
                AND m.TABLE_NAME = v_nom_table
                AND (SDO_LRS.MEASURE_RANGE(SDO_LRS.CONVERT_TO_LRS_GEOM(SDO_GEOM.SDO_INTERSECTION(b.geom, v_geometry, 0.001)))/SDO_LRS.MEASURE_RANGE(SDO_LRS.CONVERT_TO_LRS_GEOM(v_geometry)) * 100) > 50;
            return v_code_insee;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
             RETURN 'error';
        END;        
    END GET_CODE_INSEE;

/
