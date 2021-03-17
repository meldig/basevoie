# Etat des lieux de la base voie.

## Type de table.

### Les tables des données.

* ILTASEU
* ILTASIT
* ILTATRC
* ILTAFILIA
* ILTADTN
* ILTAPTZ
* VOIEVOI
* TYPEVOIE
* VOIECVT
* TA_RUEVOIE
* TA_RUE
* TA_RUELPU
* ILTALPU
* ILTACOM
* REMARQUES_VOIES
* REMARQUES_THEMATIQUES_VOIES

La table G_SIDU.ITACOM n'est pas présente dans le schéma G_SIDU en PRODUCTION

### Les tables d'administration.

* ADMIN_TABLES_VOIES
* ADMIN_COL_TABLES_VOIES
* ADMIN-CONFIG_GESTION_VOIES
* ADMIN_USERS_GESTION_VOIES

### Les tables de référence.

* ADMIN_LISTE_COTE
* ADMIN_LISTE_FAMILLE_POI
* ADMIN_LISTE_ORIGINE_POI
* ADMIN_LISTE_SYMBOLE

## Analyse des tables.

Requêtes réalisées le 15/03/2021 sur la base G_SIDU@cudl. Cette analyse sert à vérifiée la cohérence des éléments entre les tables de relation et les tables des objets. Normalement un élément présent dans une table de relation doit également être présent dans la table des objets qui sont mise ne relation par la table de relation. L'absence de contraintes de clé étrangère nous oblige à vérifier si cela est réellement le cas.

### Verification de la relation entre les tables G_SIDU.ILTASIT et G_SIDU.ILTASEU.

```SQL
SELECT
    COUNT(idseui)
FROM
    G_SIDU.ILTASIT
WHERE
    idseui NOT IN (SELECT idseui FROM G_SIDU.ILTASEU WHERE idseui IS NOT NULL)
;
-- 7034
```

### Verification de la relation entre les tables G_SIDU.ILTASIT et G_SIDU.ILTATRC.

```SQL
SELECT
    COUNT(cnumtrc)
FROM
    G_SIDU.ILTASIT
WHERE
    cnumtrc NOT IN (SELECT cnumtrc FROM G_SIDU.ILTATRC WHERE cnumtrc IS NOT NULL)
;
-- 3

-- EN PRENANT EN COMPTE LA VALIDITE DES ELEMENTS

SELECT
    COUNT(cnumtrc)
FROM
    G_SIDU.ILTASIT
WHERE
    cnumtrc NOT IN (SELECT cnumtrc FROM G_SIDU.ILTATRC WHERE cnumtrc IS NOT NULL AND cdvaltro = 'V')
;
-- 187
```

### Verification de la relation entre les tables G_SIDU.ILTADTN et G_SIDU.ILTATRC.

```SQL
SELECT
    COUNT(cnumtrc)
FROM
    G_SIDU.ILTADTN
WHERE
    cnumtrc NOT IN (SELECT cnumtrc FROM G_SIDU.ILTATRC WHERE cnumtrc IS NOT NULL)
;
-- 0

-- EN PRENANT EN COMPTE LA VALIDITE DES ELEMENTS

SELECT
    COUNT(cnumtrc)
FROM
    G_SIDU.ILTADTN
WHERE
    cnumtrc NOT IN (SELECT cnumtrc FROM G_SIDU.ILTATRC WHERE cnumtrc IS NOT NULL AND cdvaltro = 'V')
;
-- 15042
```

### Verification de la relation entre les tables G_SIDU.ILTADTN et G_SIDU.ILTAPTZ.

```SQL
SELECT
    COUNT(cnumptz)
FROM
    G_SIDU.ILTADTN
WHERE
    cnumptz NOT IN (SELECT cnumptz FROM G_SIDU.ILTAPTZ WHERE cnumptz IS NOT NULL)
;
-- 0

-- EN PRENANT EN COMPTE LA VALIDITE DES ELEMENTS

SELECT
    COUNT(cnumptz)
FROM
    G_SIDU.ILTADTN
WHERE
    cnumptz NOT IN (SELECT cnumptz FROM G_SIDU.ILTAPTZ WHERE cnumptz IS NOT NULL AND cdvalptz = 'V')
;
-- 4645
```

### Verification de la relation entre les tables G_SIDU.VOIECVT et G_SIDU.ILTATRC.

```SQL
SELECT
    COUNT(cnumtrc)
FROM
    G_SIDU.VOIECVT
WHERE
    cnumtrc NOT IN (SELECT cnumtrc FROM G_SIDU.ILTATRC WHERE cnumtrc IS NOT NULL)
;
-- 1

-- EN PRENANT EN COMPTE LA VALIDITE DES ELEMENTS

SELECT
    COUNT(cnumtrc)
FROM
    G_SIDU.VOIECVT
WHERE
    cnumtrc NOT IN (SELECT cnumtrc FROM G_SIDU.ILTATRC WHERE cnumtrc IS NOT NULL AND cdvaltro = 'V')
;
-- 8211
```

### Verification de la relation entre les tables G_SIDU.ILTAFILIA et G_SIDU.ILTATRC.

```SQL
SELECT
    COUNT(cnumtrc)
FROM
    G_SIDU.ILTAFILIA
WHERE
    cnumtrc NOT IN (SELECT cnumtrc FROM G_SIDU.ILTATRC WHERE cnumtrc IS NOT NULL)
;
-- 1

-- EN PRENANT EN COMPTE LA VALIDITE DES ELEMENTS

SELECT
    COUNT(cnumtrc)
FROM
    G_SIDU.ILTAFILIA
WHERE
    cnumtrc NOT IN (SELECT cnumtrc FROM G_SIDU.ILTATRC WHERE cnumtrc IS NOT NULL AND cdvaltro = 'V')
;
-- 641
```

### Verification de la relation entre les tables G_SIDU.VOIEVOI et G_SIDU.TYPEVOIE

```SQL
SELECT
    COUNT(ccodtvo)
FROM
    G_SIDU.VOIEVOI
WHERE
    ccodtvo NOT IN (SELECT ccodtvo FROM G_SIDU.TYPEVOIE WHERE ccodtvo IS NOT NULL)
;
-- 153
```

### Verification de la relation entre les tables G_SIDU.VOIECVT et G_SIDU.VOIEVOI.

```SQL
SELECT
    COUNT(ccomvoi)
FROM
    G_SIDU.VOIECVT
WHERE
    ccomvoi NOT IN (SELECT ccomvoi FROM G_SIDU.VOIEVOI WHERE ccomvoi IS NOT NULL)
;
-- 0

-- EN PRENANT EN COMPTE LA VALIDITE DES ELEMENTS

SELECT
    COUNT(ccomvoi)
FROM
    G_SIDU.VOIECVT
WHERE
    ccomvoi NOT IN (SELECT ccomvoi FROM G_SIDU.VOIEVOI WHERE ccomvoi IS NOT NULL AND CDVALVOI = 'V')
;
-- 1670
```

### Verification de la relation entre les tables G_SIDU.TA_RUEVOIE et G_SIDU.VOIEVOI.

```SQL
SELECT
    COUNT(ccomvoie)
FROM
    G_SIDU.TA_RUEVOIE
WHERE
    ccomvoie NOT IN (SELECT ccomvoi FROM G_SIDU.VOIEVOI WHERE ccomvoi IS NOT NULL)
;
-- 7

-- EN PRENANT EN COMPTE LA VALIDITE DES ELEMENTS

SELECT
    COUNT(ccomvoie)
FROM
    G_SIDU.TA_RUEVOIE
WHERE
    ccomvoie NOT IN (SELECT ccomvoi FROM G_SIDU.VOIEVOI WHERE ccomvoi IS NOT NULL AND CDVALVOI = 'V')
-- 495
```

### Verification de la relation entre les tables G_SIDU.TA_RUEVOIE et G_SIDU.TA_RUE.

```SQL
SELECT
    COUNT(fantoir)
FROM
    G_SIDU.TA_RUEVOIE
WHERE
    fantoir NOT IN (SELECT fantoir FROM G_SIDU.TA_RUE WHERE fantoir IS NOT NULL)
;
-- 20
```

### Verification de la relation entre les tables G_SIDU.TA_RUELPU et G_SIDU.TA_RUE.

```SQL
SELECT
    COUNT(ccomrue)
FROM
    G_SIDU.TA_RUELPU
WHERE
    ccomrue NOT IN (SELECT fantoir FROM G_SIDU.TA_RUE WHERE fantoir IS NOT NULL)
;
-- 30
```

### Verification de la relation entre les tables G_SIDU.TA_RUELPU et G_SIDU.ILTALPU.

```SQL
SELECT
    COUNT(cnumlpu)
FROM
    G_SIDU.TA_RUELPU
WHERE
    cnumlpu NOT IN (SELECT cnumlpu FROM G_SIDU.ILTALPU WHERE cnumlpu IS NOT NULL)
;
-- 0

-- EN PRENANT EN COMPTE LA VALIDITE DES ELEMENTS

SELECT
    COUNT(cnumlpu)
FROM
    G_SIDU.TA_RUELPU
WHERE
    cnumlpu NOT IN (SELECT cnumlpu FROM G_SIDU.ILTALPU WHERE cnumlpu IS NOT NULL AND CDVALLPU = 'V')
;
-- 8
```

## Analyse de la géométrie des tables.

### Analyse des indexes géométrique des tables.

Toutes les tables de la base voie avec une colonne géométrique ont des métadonnées dans la table __USER_SDO_GEOM_METADATA__

```SQL
SELECT
    *
FROM
    USER_SDO_GEOM_METADATA
WHERE
    TABLE_NAME IN(
        'ILTALPU',
        'ILTAPTZ',
        'ILTASEU',
        'ILTATRC',
        'REMARQUES_THEMATIQUES_VOIES',
        'REMARQUES_VOIES'
    );
```

|TABLE 								|COLONNE| DIMINFO 																	| SRID 	|
|:----------------------------------|:------|:--------------------------------------------------------------------------|:------|
|ILTALPU							| GEOM	| MDSYS.SDO_DIM_ARRAY([MDSYS.SDO_DIM_ELEMENT], [MDSYS.SDO_DIM_ELEMENT])		| 2154	|
|ILTAPTZ							| GEOM	| MDSYS.SDO_DIM_ARRAY([MDSYS.SDO_DIM_ELEMENT], [MDSYS.SDO_DIM_ELEMENT])		| 2154	|
|ILTASEU							| GEOM	| MDSYS.SDO_DIM_ARRAY([MDSYS.SDO_DIM_ELEMENT], [MDSYS.SDO_DIM_ELEMENT])		| 2154	|
|ILTATRC							| GEOM	| MDSYS.SDO_DIM_ARRAY([MDSYS.SDO_DIM_ELEMENT], [MDSYS.SDO_DIM_ELEMENT])		| 2154	|
|REMARQUES_THEMATIQUES_VOIES		| GEOM	| MDSYS.SDO_DIM_ARRAY([MDSYS.SDO_DIM_ELEMENT], [MDSYS.SDO_DIM_ELEMENT])		| 2154	|
|REMARQUES_VOIES					| GEOM	| MDSYS.SDO_DIM_ARRAY([MDSYS.SDO_DIM_ELEMENT], [MDSYS.SDO_DIM_ELEMENT])		| 2154	|


```SQL
SELECT
    b.TABLE_NAME,
    b.INDEX_NAME,
    a.UNIQUENESS,
    a.STATUS,
    a.INDEX_TYPE,
    a.PARAMETERS
FROM
    USER_INDEXES a
    INNER JOIN USER_IND_COLUMNS b ON b.INDEX_NAME = a.INDEX_NAME
WHERE
    b.TABLE_NAME IN(
        'ILTALPU',
        'ILTAPTZ',
        'ILTASEU',
        'ILTATRC',
        'REMARQUES_THEMATIQUES_VOIES',
        'REMARQUES_VOIES'
    )
AND a.INDEX_TYPE = 'DOMAIN';
```

|TABLE 							|INDEX 								|UNIQUENESS 	|STATUS|INDEX_TYPE 		|PARAMETERS|
|:------------------------------|:----------------------------------|:--------------|:-----|:---------------|:---------|
|ILTALPU 						| ILTALPU_SIDX						| NONUNIQUE		| VALID 	| DOMAIN	| sdo_indx_dims=2|
|ILTAPTZ						| ILTAPTZ_SIDX						| NONUNIQUE		| VALID 	| DOMAIN	| NULL|
|ILTASEU						| ILTASEU_SIDX						| NONUNIQUE		| VALID 	| DOMAIN	| NULL|
|ILTATRC						| ILTATRC_SIDX						| NONUNIQUE		| VALID 	| DOMAIN	| NULL|
|REMARQUES_THEMATIQUES_VOIES	| REMARQUES_THEMATIQUES_VOI_SIDX	| NONUNIQUE		| VALID 	| DOMAIN	| LAYER_GTYPE = MULTIPOLYGON WORK_TABLESPACE=DATA_TEMP TABLESPACE=ISPA_g_SIDU|
|REMARQUES_VOIES				| REMARQUES_VOIES_SIDX				| NONUNIQUE		| VALID 	| DOMAIN	| sdo_indx_dims=2, layer_gtype=COLLECTION|

### Analyse du type de géométrie des tables.

#### Analyse du type de géométrie présente dans la table ILTALPU.

|TYPE DE GEOMETRIE|NOMBRE D'OBJET|TABLE|
|:----------------|:-------------|:----|
|NULL			  |0	         |ILTALPU|
|2001	 		  |10696		 |ILTALPU|

#### Analyse du type de géométrie présente dans la table ILTASEU.

|TYPE DE GEOMETRIE|NOMBRE D'OBJET|TABLE|
|:----------------|:-------------|:----|
|2001			  |350429		 |ILTASEU

#### Analyse du type de géométrie présente dans la table ILTATRC.

|TYPE DE GEOMETRIE|NOMBRE D'OBJET|TABLE|
|:----------------|:-------------|:----|
|2002			  |56436		 |ILTATRC

#### Analyse du type de géométrie présente dans la table ILTAPTZ.

|TYPE DE GEOMETRIE|NOMBRE D'OBJET|TABLE|
|:----------------|:-------------|:----|
|2001			  |40205		 |ILTAPTZ

#### Analyse du type de géométrie présente dans la table REMARQUES_THEMATIQUES_VOIES.

|TYPE DE GEOMETRIE|NOMBRE D'OBJET|TABLE|
|:----------------|:-------------|:----|
|2007			  |2			 |REMARQUES_THEMATIQUES_VOIES|
|2003			  |11			 |REMARQUES_THEMATIQUES_VOIES|

#### Analyse du type de géométrie présente dans la table REMARQUES_VOIES.

|TYPE DE GEOMETRIE|NOMBRE D'OBJET|TABLE|
|:----------------|:-------------|:----|
|2003			  |15			 |REMARQUES_VOIES|

### Analyse des erreurs de géométrie des tables.

#### Analyse des erreurs de géométrie de la table ILTALPU.

|ERREUR|NOMBRE D'OBJET|TABLE|
|:-----|:-------------|:----|
|NULL  |1	          |ILTALPU|

#### Analyse des erreurs de géométrie de la table ILTASEU.

Pas d'erreur présente dans la table

#### Analyse des erreurs de géométrie de la table ILTATRC.

|ERREUR|NOMBRE D'OBJET|TABLE|
|:-----|:-------------|:----|
|13356			  |6			 |ILTATRC|

Les géométries de la tables peuvent être corrigées avec la fonction __SDO_UTIL.RECTIFY_GEOMETRY__

```SQL
SELECT
    SUBSTR(SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(SDO_UTIL.RECTIFY_GEOMETRY(a.GEOM, 0.005), 0.005), 0, 5) AS ERREUR,
    COUNT(a.CNUMTRC) AS Nombre
FROM
    G_SIDU.ILTATRC a
WHERE
    SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(SDO_UTIL.RECTIFY_GEOMETRY(a.GEOM, 0.005), 0.005)<>'TRUE'
GROUP BY
	SUBSTR(SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(SDO_UTIL.RECTIFY_GEOMETRY(a.GEOM, 0.005), 0.005), 0, 5)
;
```

#### Analyse des erreurs de géométrie de la table ILTAPTZ.

Pas d'erreur présente dans la table

#### Analyse des erreurs de géométrie de la table REMARQUES_THEMATIQUES_VOIES.

Pas d'erreur présente dans la table

#### Analyse des erreurs de géométrie de la table REMARQUES_VOIES.

|ERREUR|NOMBRE D'OBJET|TABLE|
|:----------------|:-------------|:----|
|13356			  |1			 |REMARQUES_VOIES|
|13367			  |11			 |REMARQUES_VOIES|
|13349			  |2			 |REMARQUES_VOIES|

Les géométries de la tables peuvent être corrigées avec la fonction __SDO_UTIL.RECTIFY_GEOMETRY__

```SQL
SELECT
    SUBSTR(SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(SDO_UTIL.RECTIFY_GEOMETRY(a.GEOM, 0.005), 0.005), 0, 5) AS ERREUR,
    COUNT(a.ID_REMARQUE) AS Nombre
FROM
    G_SIDU.REMARQUES_VOIES a
WHERE
    SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(SDO_UTIL.RECTIFY_GEOMETRY(a.GEOM, 0.005), 0.005)<>'TRUE'
GROUP BY
    SUBSTR(SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(SDO_UTIL.RECTIFY_GEOMETRY(a.GEOM, 0.005), 0.005), 0, 5)
;
```