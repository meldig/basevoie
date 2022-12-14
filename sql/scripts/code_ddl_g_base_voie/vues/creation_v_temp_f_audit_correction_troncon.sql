/*
Vue V_TEMP_F_AUDIT_CORRECTION_TRONCON - du projet F de correction des giratoires, ronds-points et raquettes uni-tronçon -  permettant de 
suivre la correction des giratoires, ronds-points et raquettes uni-tronçon en faisant le décompte des tronçons à corriger, corrigés ou nouvellement créés dû à la correction.
*/
-- 1. Création de la vue
CREATE OR REPLACE FORCE VIEW G_BASE_VOIE.V_TEMP_F_AUDIT_CORRECTION_TRONCON(
    OBJECTID,
    ETAT,
    NOMBRE,
    CONSTRAINT "V_TEMP_F_AUDIT_CORRECTION_TRONCON_PK" PRIMARY KEY ("OBJECTID") DISABLE
) 
AS
    WITH
        C_1 AS(-- Sélection des tronçons qu'il reste à corriger
            SELECT
                'entité en erreur' AS etat,
                COUNT(objectid) AS nombre
            FROM
                G_BASE_VOIE.TEMP_F_TRONCON
            WHERE
                fid_etat IS NULL
                AND objectid IN (12530, 1561, 33593, 33571, 7009, 60129, 29690, 74119, 6147, 3955, 71955, 2631, 488, 28946, 79848, 17911, 681, 56174, 66059, 59806, 3922, 41634, 24253, 78418, 41468, 54538, 5079, 58391, 3158, 1466, 60143, 65226, 68861, 48375, 71223, 1640, 6268, 68965, 25622, 73888, 1674, 29384, 60136, 3927, 54150, 29654, 29745, 3963, 57259, 29430, 9836, 8203, 6439, 59880, 3473, 523, 1667, 28276, 29389, 29588, 29357, 55210, 9754, 80713, 7398, 29730, 76915, 7557, 73965, 8915, 6747, 41347, 2836, 37334, 59037, 11492, 8867, 49404, 4154, 11526, 25014, 5354, 5783, 5078, 4581, 70422, 51668, 4073, 60110, 1680, 56716, 55974, 7570, 8355, 56804, 18319, 59894, 57341, 59434, 60176, 7342, 77103, 1095, 8153, 59744, 7445, 7878, 8560, 59917, 4266, 57032, 57329, 415, 4072, 53432, 29132, 5076, 35736, 6791, 1555, 1636, 60066, 8488, 57648, 2829, 8484, 5206, 56637, 56701, 65220, 12058, 6151, 6629, 7440, 55082, 6272, 43658, 57765, 4555, 60023, 4268, 6889, 4071, 4267, 1672, 54492, 11206, 56943, 56078, 44450, 44358, 12550, 12552, 28944, 33522, 54054, 1040, 32015, 57578, 52362, 59929, 59936, 54143, 8869, 8866, 55339, 85915, 64413, 42378, 465, 52761, 7572, 609, 9422, 54081, 7340, 1634, 1609, 7363, 7346, 5984, 56229, 5659, 25593, 53449, 56211, 56236, 55128, 76068, 56412, 53957, 56551, 58393, 58395, 58397, 57488, 57224, 7574, 20531, 56586, 57265, 7974, 42369, 56959, 7239, 54124, 56758, 76664, 34034, 29042, 58800, 55657, 34035, 58416, 33949, 22052, 48706, 6499, 29954, 24248, 2683, 81754, 4903, 6302, 15965, 113, 66063, 18746, 49720, 79857, 79855, 55525, 25534, 58960, 59027, 53739, 49392, 13105, 65826, 14573, 1692, 1690, 69797, 5834, 1564, 56774, 4070, 81897, 7561, 1468, 33809, 80762, 862, 58685, 58738, 1932, 1342, 49271, 125, 8158, 60148, 16997, 68538, 50484, 6392, 36357, 1568, 82829, 33916, 54123, 54095, 7536, 7538, 7565, 672, 70476, 1684, 755, 37332, 49003, 60140, 56964, 5913, 65044, 43489, 59515, 293, 296, 187, 209, 58953, 44456, 1678, 1682, 22862, 81899, 4595, 8353, 12079, 28983, 4695, 29104, 44484, 41266, 54871, 67818, 56080, 28986, 29340, 38621, 29631, 12532, 70450, 70492, 14367, 1793, 59737, 59815, 5080, 24304, 57906, 54065, 33798, 67812, 1187, 57283, 5077, 66810, 25582, 76913, 4594, 33432, 1676, 54498, 65156, 1372, 59819, 60173, 1809, 353, 60122, 60161, 81181, 49011, 73, 105, 57347, 5868, 7757, 66805, 53344, 59883, 4269, 43445)
            GROUP BY
                'entité en erreur'
            UNION ALL
            SELECT
                TRIM(b.libelle_court) AS etat,
                COUNT(a.objectid) AS nombre
            FROM
                G_BASE_VOIE.TEMP_F_TRONCON a
                INNER JOIN G_BASE_VOIE.TEMP_F_LIBELLE b ON b.objectid = a.fid_etat
            WHERE
                a.fid_etat IS NOT NULL
            GROUP BY
                TRIM(b.libelle_court)
        )
        
        SELECT
            rownum AS objectid,
            etat,
            nombre
        FROM
            C_1;

-- 2. Création des commentaires
COMMENT ON TABLE G_BASE_VOIE.V_TEMP_F_AUDIT_CORRECTION_TRONCON IS 'Vue - du projet F de correction des giratoires, ronds-points et raquettes uni-tronçon - permettant de suivre la correction en faisant le décompte des tronçons à corriger, corrigés ou nouvellement créés dû à la correction.' ;
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_F_AUDIT_CORRECTION_TRONCON.objectid IS 'Clé primaire de la vue';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_F_AUDIT_CORRECTION_TRONCON.etat IS 'Etat des tronçons : entité en erreur, entité corrigée, nouvelle entité.';
COMMENT ON COLUMN G_BASE_VOIE.V_TEMP_F_AUDIT_CORRECTION_TRONCON.nombre IS 'Nombre de tronçon par état.';

/

