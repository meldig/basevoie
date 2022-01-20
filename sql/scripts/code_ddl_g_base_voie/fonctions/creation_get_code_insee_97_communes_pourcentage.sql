
create or replace FUNCTION GET_CODE_INSEE_97_COMMUNES_POURCENTAGE(v_table_name VARCHAR2, v_geometry SDO_GEOMETRY) RETURN CHAR
/*
Cette fonction a pour objectif de récupérer le code INSEE de la commune dans laquelle se situe plus de 50% d'un objet linéaire.
La variable v_table_name doit contenir le nom de la table dont on veut connaître le code INSEE des objets.
La variable v_geometry doit contenir le nom du champ géométrique de la table interrogée.
Le référentiel utilisé pour récupérer le code INSEE est celui des 97 communes car avec les communes associées, nous pouvons avoir deux voies du même nom et complément à Lille par exemple, alors qu'une se situe à Lomme et l'autre à Lille.
ATTENTION : Cette fonction N'EST PAS A UTILISER pour des objets de types points.
*/
    DETERMINISTIC
    As
    v_code_insee CHAR(8);
    BEGIN
        SELECT
            TRIM(b.code_insee)
            INTO v_code_insee
        FROM
            G_REFERENTIEL.MEL_COMMUNE_LLH b,
            USER_SDO_GEOM_METADATA m
        WHERE
            m.table_name = v_table_name
            AND (SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(v_geometry, b.geom, 0.005))/ SDO_GEOM.SDO_LENGTH(v_geometry,m.diminfo))*100 > 50;
        RETURN v_code_insee;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'error';
    END GET_CODE_INSEE_97_COMMUNES_POURCENTAGE;

/

