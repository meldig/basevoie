/*
la fonction ci-dessous a pour objectif de retouver le code insee de la commune dans laquelle se trouve un objet pouvant chevaucher plusieurs communes.
*/

create or replace FUNCTION GET_CODE_INSEE_CHEVAUCHEMENT(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
/*
Cette fonction a pour objectif de récupérer le code insse de la commune dans laquelle se situe un objet géométrique (contenu, chevauchant ou intersectant).
ATTENTION : Cette fonction N'EST PAS A UTILISER pour des objets de types points. Pour ce cas veuillez utiliser la fonction GET_CODE_INSEE_CONTENU.
*/
-- Fonction test servant à tester les fonctions basées sur des index
    DETERMINISTIC
    As
    v_code_insee CHAR(8);
    BEGIN
        -- Sélection du code insee de la commune dans laquelle l'objet est entièrement contenu
        SELECT
            b.code_insee INTO v_code_insee
        FROM
            G_REFERENTIEL.MEL_COMMUNE b,
            USER_SDO_GEOM_METADATA m
         WHERE
            m.table_name = v_table_name
            AND SDO_CONTAINS(
                    b.geom,
                    SDO_LRS.CONVERT_TO_STD_GEOM(
                        SDO_LRS.LOCATE_PT(
                                        SDO_LRS.CONVERT_TO_LRS_GEOM(v_geometry,m.diminfo),
                                        SDO_GEOM.SDO_LENGTH(v_geometry,m.diminfo)/2
                        )
                    )
                )='TRUE';

        RETURN v_code_insee;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
             RETURN 'error';
    END GET_CODE_INSEE_CHEVAUCHEMENT;

/
