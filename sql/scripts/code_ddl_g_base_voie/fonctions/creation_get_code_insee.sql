/*
la fonction ci-dessous a pour objectif de retouver le code insee de la commune dans laquelle se trouve un objet linéaire.
Cette fonction retourne le code insee de la commune dans laquelle plus de 50% de l'objet se trouve.
*/

create or replace FUNCTION GET_CODE_INSEE(v_geometry SDO_GEOMETRY) RETURN CHAR
-- Cette fonction a pour objectif de récupérer le code insse de la commune dans laquelle se situe un objet géométrique.
-- ATTENTION : Cette fonction est à utiliser principalement pour des objets de types points ou pour des objets dont vous savez à l'avance qu'ils sont totalement contenus dans les communes, sinon le "code INSEE" retourné sera 'error'...
    DETERMINISTIC
    As
    v_code_insee CHAR(8);
    BEGIN         
        -- Sélection du code insee de la commune dans laquelle l'objet est entièrement contenu
        SELECT
            b.code_insee INTO v_code_insee
        FROM
            G_REFERENTIEL.A_COMMUNE b
         WHERE
            SDO_CONTAINS(b.geom, v_geometry) = 'TRUE';

        RETURN v_code_insee;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
             RETURN 'error';
    END GET_CODE_INSEE;

/
