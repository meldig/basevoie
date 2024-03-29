## Les déclencheurs

### 1. Généralités
Il existe en tout 15 triggers dans le schéma G_SIDU, portant sur les tables de la base voie.
|Nom_Table	|Nom_trigger	|Type_Trigger	|Evenement_de_Declenchement	|Schema	|Statut|
|:----------|:--------------|:--------------|:--------------------------|:------|:-----|
|ILTADTN	|TRG_ILTADTN_MAJ_CDVALDTN	|BEFORE EACH ROW	|INSERT OR UPDATE	|G_SIDU	|ENABLED|
|ILTALPU	|TRG_ILTALPU	|AFTER EACH ROW	|INSERT OR UPDATE OR DELETE	|G_SIDU	|ENABLED|
|ILTALPU	|TRG_ILTALPU_INS_CNUMLPU	|BEFORE EACH ROW	|INSERT	|G_SIDU	|ENABLED|
|ILTALPU	|TRG_ILTALPU_MAJ_CDVALLPU	|BEFORE EACH ROW	|INSERT OR UPDATE	|G_SIDU	|ENABLED|
|ILTAPTZ	|TRG_ILTAPTZ_INS_CNUMPTZ	|BEFORE EACH ROW	|INSERT	|G_SIDU	|ENABLED|
|ILTAPTZ	|TRG_ILTAPTZ_MAJ_CDVALPTZ	|BEFORE EACH ROW	|INSERT OR UPDATE	|G_SIDU	|ENABLED|
|ILTASEU	|TRG_ILTASEU	|AFTER EACH ROW	|INSERT OR UPDATE OR DELETE	|G_SIDU	|ENABLED|
|ILTASEU	|TRG_ILTASEU_INS_IDSEUI	|BEFORE EACH ROW	|INSERT	|G_SIDU	|ENABLED|
|ILTASIT	|TRG_ILTASIT	|AFTER EACH ROW	|INSERT OR UPDATE OR DELETE	|G_SIDU	|ENABLED|
|ILTATRC	|TRG_ILTATRC_INS_CNUMTRC	|BEFORE EACH ROW	|INSERT	|G_SIDU	|DISABLED|
|ILTATRC	|TRG_ILTATRC_MAJ_CDVALTRO	|BEFORE EACH ROW	|INSERT OR UPDATE	|G_SIDU	|ENABLED|
|ILTATRC	|TRG_ILTATRC_SENS_TRC	|AFTER EACH ROW	|INSERT OR UPDATE OR DELETE	|G_SIDU	|ENABLED|
|REMARQUES_VOIES	|TRG_REMARQUES_VOIES_INS_ID	|BEFORE EACH ROW	|INSERT	|G_SIDU	|ENABLED|
|VOIECVT	|TRG_VOIECVT_MAJ_CVALIDE	|BEFORE EACH ROW	|INSERT OR UPDATE	|G_SIDU	|ENABLED|
|VOIEVOI	|TRG_VOIEVOI_MAJ_CDVALVOI	|BEFORE EACH ROW	|INSERT OR UPDATE	|G_SIDU	|ENABLED|

### 2. Trigger de la table *VOIEVOI*
La table *VOIEVOI* dispose d'un seul trigger nommé *TRG_VOIEVOI_MAJ_CDVALVOI*, déclenché par une insertion ou une édition. Le trigger est actif. 

#### Actions :
* Mise à jour du champ *CDTMVOI* (date de mise à jour) pour une insertion et une édition ;
* Mise à jour du champ *CDVALVOI* (validation de la voie) en fonction du champ *CDTFVOI* (date de fin de la voie) : si CDTFVOI>=sysdate alors la voie est valide, sinon non ;

### 3. Trigger de la table *VOIECVT*
La table *VOIECVT* dispose d'un seul trigger nommé *TRG_VOIECVT_MAJ_CVALIDE*, déclenché par une insertion ou une édition. Le trigger est actif.

#### Actions :
* Mise à jour du champ *CDTMCVT* (date de mise à jour) pour une insertion et une édition ;
* Mise à jour du champ *CVALIDE* (validité (V: valide ou I:invalide)) en fonction du champ *CDTFCVT* (date fin de validité) : si CDTFCVT>=sysdate alors la voie est valide, sinon non ;

### 4. Trigger de la table *REMARQUES_VOIES*
La table *REMARQUES_VOIES* dispose d'un seul trigger nommé *TRG_REMARQUES_VOIES_INS_ID*, déclenché par une insertion. Le trigger est actif.

#### Actions :
* Incrémentation de la clé primaire *ID_REMARQUE* via la séquence *SQ_REMARQUES_VOIES_ID* ;

### 5. Trigger de la table *ILTATRC*
La table *ILTATRC* dispose de trois triggers :  

**Le trigger *TRG_ILTATRC_SENS_TRC* :** actif, ce trigger est déclenché par une insertion, une édition ou une suppression  

#### Actions :
* Si un tronçon est supprimé dans la table *ILTATRC*, alors il est aussi supprimé dans la table *GEO.SENS_DES_TRONCONS* ;
* Si le champ *cdvaltro* (validité du tronçon) est mis à jour avec la valeur 'F' (faux), alors le tronçon correspondant est supprimé de la table *GEO.SENS_DES_TRONCONS* ;
* Si le champ *cdvaltro* (validité du tronçon) est mis à jour avec la valeur 'V' (vrai), alors les champs *GEOM* et *ANGLE* de la table *GEO.SENS_DES_TRONCONS* sont mis à jour à partir du champ *GEOM* de la table *G_SIDU.ILTATRC* ;
* En cas d'insertion dans la table *G_SIDU.ILTATRC*, les valeurs sont insérées dans les champs *OBJECTID*, *CNUMTRC*, *GEOM*, *ANGLE* de la table *GEO.SENS_DES_TRONCONS*. Le champ *SENS_DES_TRONCONS.OBJECTID* est égal au champ *ILTATRC.CNUMTRC* et le champ *SENS_DES_TRONCONS.ANGLE* est calculé à partir du champ *ILTATRC.GEOM*;

**Le trigger *TRG_ILTATRC_MAJ_CDVALTRO* :** actif, ce trigger est déclenché par une insertion ou une édition.

#### Actions :
* Mise à jour du champ *CDTMTRC* (date de mise à jour) pour une insertion et une édition ;
* Mise à jour du champ *CDVALTRO* (validité (V: valide ou I:invalide)) en fonction du champ *CDTFTRC* (date fin de validité) : si CDTFTRC>=sysdate alors la voie est valide, sinon non ;

**Le trigger *TRG_ILTATRC_INS_CNUMTRC* :** désactivé, ce trigger est déclenché par une insertion.

#### Actions :
* Incrémentation de la clé primaire *CNUMTRC* via la séquence *SQ_ILTATRC_CNUMTRC* ;

### 6. Trigger de la table *ILTASIT*
La table *ILTASIT* dispose d'un seul trigger nommé *TRG_ILTASIT*, déclenché par une insertion ou une édition. Le trigger est actif.

#### Actions :
* En cas de suppression dans la table *G_SIDU.ILTASIT*, l'entité correspondante est supprimée de la table *SIDU.ILTASIT* ;

* En cas de mise à jour d'une entité, les champs *CNUMTRC*, *NBABSCIS* et *CDCOTE* de l'entité correspondante dans la table *SIDU.ILTASIT* seront mis à jour. *Cependant, il faut regarder à quoi correspondent les objets geocodeurs et dist_tron_seuil car il ne s'agit ni de package, ni de proccédure, ni de fonction ni de trigger. Or ils sont utilisés pour remplir le champ NBABSCIS.*

### 7. Trigger de la table *ILTASEU*
La table ILTASEU dispose de deux triggers :  

**Le trigger *TRG_ILTASEU_INS_IDSEUI* :** actif, ce trigger est déclenché par une insertion.

#### Actions :
* Incrémentation de la clé primaire *IDSEUI* via la séquence *SQ_ILTASEU_IDSEUI* ;

**Le trigger *TRG_ILTASEU* :** actif, ce trigger est déclenché par une insertion, une modification ou une suppression.

#### Actions :
* En cas de suppression de la table *ILTASEU*, les entités correspondantes sont supprimées des tables *SIDU.ILTASIT* et *SIDU.ILTASEU*. L'égalité se fait sur le champ *IDSEUI* ;

* En cas de mise à jour, tous les champs de l'entité sont mis à jour dans les tables *SIDU.ILTASEU* et *GEO.TA_POINT_SEUIL*, sauf leur PK. L'égalité se fait sur le champ *IDSEUI* pour la table *SIDU.ILTASEUI* et *OBJECTID* pour la table *GEO.TA_POINT_SEUIL*;

* En cas de mise à jour et si le champ *CNUMTRC* n'est pas null, alors les champs *CNUMTRC*, *NBABSCIS* et *CDCOTE* de la table *G_SIDU.ILTASIT* sont mis à jour. L'égalité se fait sur le champ *IDSEUI*. *Cependant, il faut regarder à quoi correspondent les objets geocodeurs et dist_tron_seuil car il ne s'agit ni de package, ni de proccédure, ni de fonction ni de trigger. Or ils utilisés pour remplir le champ NBABSCIS.*

* En cas d'insertion, les données sont dupliquées dans la table *SIDU.ILTASEU* et dans la table *GEO.TA_POINT_SEUIL* (pour les champs *OBJECTID*, *NUSEUI*, *NSSEUI*, *CNUMCOM*, *GEOM*, *CDCOTE*, *NPARCELLE* seulement) ;

* En cas d'insertion et si le champ *SIDU.ILTATRC.CDVALTRO* n'est pas null, alors les champs *IDSEUI*, *CNUMTRC*, *NBABSCIS*, *CDCOTE* de la table *SIDU.ILTASIT* sont remplis avec les données insérées ;

* En cas d'insertion et si le champ *CNUMTRC* n'est pas null, alors les champs *CNUMTRC*, *NBABSCIS* et *CDCOTE* de la table *G_SIDU.ILTASIT* sont remplis avec les données insérées. L'égalité se fait sur le champ *IDSEUI* ; 

### 8. Trigger de la table *ILTAPTZ*
La table ILTAPTZ dispose de deux triggers :

**Le trigger *TRG_ILTAPTZ_MAJ_CDVALPTZ* :** actif, ce trigger est déclenché par une insertion ou une édition.  

#### Actions :
* Mise à jour du champ *CDTMPTZ* (date de mise à jour) pour une insertion et une édition ;
* Mise à jour du champ *CDVALPTZ* (validation du noeud) en fonction du champ *CDTFPTZ* (date de fin du noeud) : si CDTFPTZ>=sysdate alors le noeud est valide, sinon non ;

**Le trigger *TRG_ILTAPTZ_INS_CNUMPTZ* :** actif, ce trigger est déclenché par une insertion.  

#### Actions :
* Incrémentation de la clé primaire *CNUMPTZ* via la séquence *SQ_ILTAPTZ_CNUMPTZ* ;

### 9. Trigger de la table ILTALPU
La table *ILTALPU* dispose de trois triggers :  

**Le trigger *TRG_ILTALPU_MAJ_CDVALLPU* :** actif, ce trigger est déclenché par une insertion ou une édition.  

#### Actions :
* Mise à jour du champ *CDVALLPU* (validation du Point d'intérêt (LES POI sont les anciens LPU (Lieux Publics))) en fonction du champ *CDTFLPU* (date de fin du POI) : si CDTFLPU>=sysdate alors le POI est valide, sinon non ;

**Le trigger *TRG_ILTALPU_INS_CNUMLPU* :** actif, ce trigger est déclenché par une insertion.

#### Actions :
* Incrémentation de la clé primaire *CNUMLPU* via la séquence SQ_ILTALPU_CNUMLPU ;

**Le trigger *TRG_ILTALPU* :** actif, ce trigger est déclenché par une insertion, une édition ou une suppression.  

#### Actions :
* En cas de mise à jour, la table *SIDU.ILTALPU* est mise à jour avec les mêmes données (seuls les champs *URL* et *HTML* ne sont pas dupliqués). Les champs CXLALPU et CYLALPU sont mis à jour avec les coordonnées dans le système de projet Lambert Nord (EPSG : 27561) ;

* En cas de mise à jour, la table *GEO.LM_LPU* est mise à jour avec les mêmes données (cela concerne les 26 champs) ;

* En cas d'insertion, les données des champs *CNUMLPU*, *CDTMLPU*, *CDTSLPU* de la table *SIDU.ILTALPU* sont duppliquées et les champs *CXLALPU* et *CYLALPU* sont remplis avec les coordonnées dans le système de projection Lambert Nord (EPSG : 27561). Les autres champs ont la valeur 'null'. Le même principe s'applique pour la table *GEO.LM_LPU* (sans la transformation des coordonnées en 27561) ;  

*Erreur à partir de la ligne 231. En effet de la ligne 231 à la ligne 282 se trouve un code de mise à jour inutile car déjà fait. Il serait bon de corriger cette erreur.*  

### 10. Trigger de la table *ILTADTN*
La table *ILTADTN* ne dispose que d'un seul trigger appelé *TRG_ILTADTN_MAJ_CDVALDTN*, déclenché par une insertion ou une édition. Le trigger est actif.

#### Actions :
* En cas d'insertion ou d'édition, les champs suivants de la table G_SIDU sont mis à jour : *CDTFDTN*, *CDVALDTN*, *CCODDFT*, *CANGTRC*.