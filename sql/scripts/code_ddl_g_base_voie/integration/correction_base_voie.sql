/*
Correction des données de la table TEMP_VOIEVOI
*/

-- Création d'un duplicatat du champ CCODRVO afin d'en corriger les valeurs. Objectif : passer de l'identifiant de voie au sein de la commune sur 4 caractères au code fantoir sur 7 caractères, c-à-d préfixé par le code commune.
ALTER TABLE G_BASE_VOIE.TEMP_VOIEVOI
ADD CCODRVO_BIS CHAR(7);

-- Correction du champ CCODRVO : remplacement du code de la voie dans la commune par le code fantoir
UPDATE G_BASE_VOIE.TEMP_VOIEVOI a
SET a.CCODRVO = CASE 
                    WHEN LENGTH(a.cnumcom)=1 THEN CAST('00' || a.cnumcom AS CHAR(3))
                    WHEN LENGTH(a.cnumcom)=2 THEN CAST('0' || a.cnumcom AS CHAR(3))
                    WHEN LENGTH(a.cnumcom)=3 THEN CAST(a.cnumcom AS CHAR(3))
                END
                || TRIM(a.ccodrvo);


-- Remplissage du champ CCODRVO_BIS par le code fantoir sans les espaces qui ont été ajoutés (je ne sais pas pourquoi)
UPDATE G_BASE_VOIE.TEMP_VOIEVOI a
SET a.CCODRVO_BIS = SUBSTR(a.CCODRVO,0,7);

-- Suppression du champ CCODRVO disposant du mauvais code
ALTER TABLE G_BASE_VOIE.TEMP_VOIEVOI
DROP COLUMN CCODRVO;

-- Renommage du champ CCODRVO_BIS en CCODRVO
ALTER TABLE G_BASE_VOIE.TEMP_VOIEVOI
RENAME COLUMN CCODRVO_BIS TO CCODRVO;