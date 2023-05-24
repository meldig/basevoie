/*
Ce code permet, en cas d'erreur de découpage ou de mise à jour de tronçons, de supprimer les tronçons en erreur et de remettre les anciens tronçons.
*/

-- 1. Sélection des relations tronçon/voie à supprimer
SELECT
    objectid ||','
FROM
    TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE
WHERE
    fid_troncon IN(91017, 91016, 51189, 63006);

-- 2. Suppression des relations tronçon/voie sélectionnées à l'étape 1 
DELETE 
FROM
    TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE
WHERE
    objectid IN(16821,23011,50576,50577);

-- 3. Suppression des mauvais tronçons
DELETE
FROM
    TEMP_B_TRONCON
WHERE
    objectid IN(91017, 91016, 51189, 63006);
    
-- 4. Import des anciens tronçons
MERGE INTO G_BASE_VOIE.TEMP_B_TRONCON a
    USING(
        SELECT
            CAST(a.cnumtrc AS NUMBER(38,0)) AS objectid,
            a.ora_geometry AS geom,
            TO_DATE(sysdate, 'dd/mm/yyyy') AS date_saisie,
            b.numero_agent AS fid_pnom_saisie,
            TO_DATE(sysdate, 'dd/mm/yyyy') AS date_modification,
            b.numero_agent AS fid_pnom_modification,
            '' AS fid_etat
        FROM
            G_BASE_VOIE.TEMP_ILTATRC a,
            G_BASE_VOIE.TEMP_B_AGENT b
        WHERE
            a.cdvaltro = 'V'
            AND b.pnom = 'import_donnees'
            AND a.cnumtrc IN(63006, 51189)
    )t
ON(a.objectid = t.objectid)
WHEN NOT MATCHED THEN
INSERT(a.objectid, a.geom, a.date_saisie, a.date_modification, a.fid_pnom_saisie, a.fid_pnom_modification, a.fid_etat)
VALUES(t.objectid, t.geom, t.date_saisie, t.date_modification, t.fid_pnom_saisie, t.fid_pnom_modification, t.fid_etat);
    
-- 5. Insertion des relations tronçon/voie des anciens tronçons
MERGE INTO G_BASE_VOIE.TEMP_B_RELATION_TRONCON_VOIE_PHYSIQUE a
    USING(
        SELECT
            CAST(a.cnumtrc AS NUMBER(38,0)) AS fid_troncon,
            b.ccodstr AS sens,
            c.ccomvoi AS fid_voie_physique
        FROM
            G_BASE_VOIE.TEMP_ILTATRC a
            INNER JOIN G_BASE_VOIE.TEMP_VOIECVT b ON b.cnumtrc = a.cnumtrc
            INNER JOIN G_BASE_VOIE.TEMP_VOIEVOI c ON c.ccomvoi = b.ccomvoi
            INNER JOIN G_BASE_VOIE.TEMP_TYPEVOIE d ON d.ccodtvo = c.ccodtvo
        WHERE
            a.cdvaltro = 'V'
            AND b.cvalide = 'V'
            AND c.cdvalvoi = 'V'
            AND d.lityvoie IS NOT NULL
            AND a.cnumtrc IN(63006, 51189)
    )t
ON(a.fid_troncon = t.fid_troncon AND a.fid_voie_physique = t.fid_voie_physique)
WHEN NOT MATCHED THEN
INSERT(a.fid_troncon, a.fid_voie_physique, a.sens)
VALUES(t.fid_troncon, t.fid_voie_physique, t.sens);