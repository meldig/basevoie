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

Requêtes réalisées le 15/03/2021 sur le schéma G_SIDU en PRODUCTION. Cette analyse sert à vérifiée la cohérence des éléments entre les tables de relation et les tables des objets. Normalement un élément présent dans une table de relation doit également être présent dans la table parente ou enfant. L'absence de contraintes de clé étrangère nous oblige à vérifier si cela est réellement le cas.

### Vérification de la relation entre les tables G_SIDU.ILTASIT (table fille) et G_SIDU.ILTASEU (table parente)

```SQL
SELECT
    COUNT(DISTINCT a.idseui)
FROM
    G_SIDU.ILTASIT a
WHERE
    a.idseui NOT IN (SELECT b.idseui FROM G_SIDU.ILTASEU b WHERE b.idseui IS NOT NULL);
-- 7244 seuils présents dans ILTASIT, mais absents de ILTASEU.
```

### Vérification de la relation entre les tables G_SIDU.ILTASIT (table fille) et G_SIDU.ILTATRC (table parente)

```SQL
-- Tronçons présents dans ILTASIT mais absents de ILTATRC
SELECT
    COUNT(DISTINCT cnumtrc)
FROM
    G_SIDU.ILTASIT
WHERE
    cnumtrc NOT IN (SELECT cnumtrc FROM G_SIDU.ILTATRC WHERE cnumtrc IS NOT NULL);
-- 7

-- Tronçons présents dans ILTASIT mais invalides dans ILTATRC
SELECT 
    COUNT(DISTINCT a.cnumtrc)
FROM
    G_SIDU.ILTASIT a
WHERE
    a.cnumtrc IN (SELECT b.cnumtrc FROM G_SIDU.ILTATRC b WHERE b.cnumtrc IS NOT NULL AND b.cdvaltro = 'F');
-- 155
```

### Vérification de la relation entre les tables G_SIDU.ILTADTN (table fille) et G_SIDU.ILTATRC (table parente)

```SQL
-- Tronçons présents dans ILTADTN mais absents de ILTATRC
SELECT
    COUNT(DISTINCT cnumtrc)
FROM
    G_SIDU.ILTADTN
WHERE
    cnumtrc NOT IN (SELECT cnumtrc FROM G_SIDU.ILTATRC WHERE cnumtrc IS NOT NULL);
-- 0

-- Tronçons présents dans ILTADTN mais invalides dans ILTATRC
SELECT 
    COUNT(DISTINCT a.cnumtrc)
FROM
    G_SIDU.ILTADTN a
WHERE
    a.cnumtrc IN (SELECT b.cnumtrc FROM G_SIDU.ILTATRC b WHERE b.cnumtrc IS NOT NULL AND b.cdvaltro = 'F');
-- 7898
```

### Vérification de la relation entre les tables G_SIDU.ILTADTN (table fille) et G_SIDU.ILTAPTZ (table parente)

```SQL
-- Noeuds présents dans ILTADTN mais absents de ILTAPTZ
SELECT
    COUNT(DISTINCT cnumptz)
FROM
    G_SIDU.ILTADTN
WHERE
    cnumptz NOT IN (SELECT cnumptz FROM G_SIDU.ILTAPTZ WHERE cnumptz IS NOT NULL);
-- 0

-- Noeuds présents dans ILTADTN mais invalides dans ILTAPTZ
SELECT 
    COUNT(DISTINCT a.cnumptz)
FROM
    G_SIDU.ILTADTN a
WHERE
    a.cnumptz IN (SELECT b.cnumptz FROM G_SIDU.ILTAPTZ b WHERE b.cnumptz IS NOT NULL AND b.cdvalptz = 'F');
-- 1988
```

### Vérification de la relation entre les tables G_SIDU.VOIECVT (table fille) et G_SIDU.ILTATRC (table parente)

```SQL
-- Tronçons présents dans VOIECVT mais absents de ILTATRC
SELECT
    COUNT(DISTINCT cnumtrc)
FROM
    G_SIDU.VOIECVT
WHERE
    cnumtrc NOT IN (SELECT cnumtrc FROM G_SIDU.ILTATRC WHERE cnumtrc IS NOT NULL);
-- 1

-- Tronçons présents dans VOIECVT mais invalides dans ILTATRC
SELECT 
    COUNT(DISTINCT a.cnumtrc)
FROM
    G_SIDU.VOIECVT a
WHERE
    a.cnumtrc IN (SELECT b.cnumtrc FROM G_SIDU.ILTATRC b WHERE b.cnumtrc IS NOT NULL AND b.cdvaltro = 'F');
-- 7882
```

### Vérification de la relation entre les tables G_SIDU.ILTAFILIA (table fille) et G_SIDU.ILTATRC (table parente)

```SQL
-- Tronçons présents dans VOIECVT mais absents de ILTATRC
SELECT
    COUNT(DISTINCT cnumtrc)
FROM
    G_SIDU.ILTAFILIA
WHERE
    cnumtrc NOT IN (SELECT cnumtrc FROM G_SIDU.ILTATRC WHERE cnumtrc IS NOT NULL);
-- 1

-- Tronçons présents dans ILTAFILIA mais invalides dans ILTATRC
SELECT 
    COUNT(DISTINCT a.cnumtrc)
FROM
    G_SIDU.ILTAFILIA a
WHERE
    a.cnumtrc IN (SELECT b.cnumtrc FROM G_SIDU.ILTATRC b WHERE b.cnumtrc IS NOT NULL AND b.cdvaltro = 'F');
-- 721
```

### Vérification de la relation entre les tables G_SIDU.VOIEVOI (table fille) et G_SIDU.TYPEVOIE (table parente)

```SQL
-- Voies présentes dans VOIEVOI mais absentes de TYPEVOIE
SELECT
    COUNT(DISTINCT ccodtvo)
FROM
    G_SIDU.VOIEVOI
WHERE
    ccodtvo NOT IN (SELECT ccodtvo FROM G_SIDU.TYPEVOIE WHERE ccodtvo IS NOT NULL);
-- 3
```

### Vérification de la relation entre les tables G_SIDU.VOIECVT (table fille) et G_SIDU.VOIEVOI (table parente)

```SQL
-- Voies présentes dans VOIECVT mais absentes de VOIEVOI
SELECT
    COUNT(DISTINCT ccomvoi)
FROM
    G_SIDU.VOIECVT
WHERE
    ccomvoi NOT IN (SELECT ccomvoi FROM G_SIDU.VOIEVOI WHERE ccomvoi IS NOT NULL);
-- 0

-- Voies présentes dans VOIECVT mais invalides dans VOIEVOI
SELECT 
    COUNT(DISTINCT a.ccomvoi)
FROM
    G_SIDU.VOIECVT a
WHERE
    a.ccomvoi IN (SELECT b.ccomvoi FROM G_SIDU.VOIEVOI b WHERE b.ccomvoi IS NOT NULL AND b.CDVALVOI = 'I');
-- 1053
```

### Vérification de la relation entre les tables G_SIDU.TA_RUEVOIE (table fille) et G_SIDU.VOIEVOI (table parente)

```SQL
-- Voies présentes dans TA_RUEVOIE mais absentes de VOIEVOI
SELECT
    COUNT(DISTINCT ccomvoie)
FROM
    G_SIDU.TA_RUEVOIE
WHERE
    ccomvoie NOT IN (SELECT ccomvoi FROM G_SIDU.VOIEVOI WHERE ccomvoi IS NOT NULL);
-- 7

-- Voies présentes dans TA_RUEVOIE mais invalides dans VOIEVOI
SELECT 
    COUNT(DISTINCT a.ccomvoie)
FROM
    G_SIDU.TA_RUEVOIE a
WHERE
    a.ccomvoie IN (SELECT b.ccomvoi FROM G_SIDU.VOIEVOI b WHERE b.ccomvoi IS NOT NULL AND b.CDVALVOI = 'I');
-- 520
```

### Vérification de la relation entre les tables G_SIDU.TA_RUEVOIE (table fille) et G_SIDU.TA_RUE (table parente)

```SQL
-- Fantoirs présents dans TA_RUEVOIE mais absents de TA_RUE
SELECT
    COUNT(DISTINCT fantoir)
FROM
    G_SIDU.TA_RUEVOIE
WHERE
    fantoir NOT IN (SELECT fantoir FROM G_SIDU.TA_RUE WHERE fantoir IS NOT NULL);
-- 21
```

### Vérification de la relation entre les tables G_SIDU.TA_RUELPU (table fille) et G_SIDU.TA_RUE (table parente)

```SQL
SELECT
    COUNT(DISTINCT ccomrue)
FROM
    G_SIDU.TA_RUELPU
WHERE
    ccomrue NOT IN (SELECT fantoir FROM G_SIDU.TA_RUE WHERE fantoir IS NOT NULL);
-- 28
```

### Vérification de la relation entre les tables G_SIDU.TA_RUELPU (table fille) et G_SIDU.ILTALPU (table parente)

```SQL
SELECT
    COUNT(DISTINCT cnumlpu)
FROM
    G_SIDU.TA_RUELPU
WHERE
    cnumlpu NOT IN (SELECT cnumlpu FROM G_SIDU.ILTALPU WHERE cnumlpu IS NOT NULL);
-- 0

-- Points d'intérêts présents dans TA_RUELPU mais invalides dans ILTALPU
SELECT 
    COUNT(DISTINCT a.cnumlpu)
FROM
    G_SIDU.TA_RUELPU a
WHERE
    a.cnumlpu IN (SELECT b.cnumlpu FROM G_SIDU.ILTALPU b WHERE b.cnumlpu IS NOT NULL AND b.CDVALLPU = 'I');
-- 7
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
|NULL			  |1	         |ILTALPU|
|2001	 		  |10799		 |ILTALPU|

#### Analyse du type de géométrie présente dans la table ILTASEU.

|TYPE DE GEOMETRIE|NOMBRE D'OBJET|TABLE|
|:----------------|:-------------|:----|
|2001			  |354887		 |ILTASEU

#### Analyse du type de géométrie présente dans la table ILTATRC.

|TYPE DE GEOMETRIE|NOMBRE D'OBJET|TABLE|
|:----------------|:-------------|:----|
|2002			  |57620		 |ILTATRC

#### Analyse du type de géométrie présente dans la table ILTAPTZ.

|TYPE DE GEOMETRIE|NOMBRE D'OBJET|TABLE|
|:----------------|:-------------|:----|
|2001			  |41003		 |ILTAPTZ

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
|13356			  |10			 |ILTATRC|

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