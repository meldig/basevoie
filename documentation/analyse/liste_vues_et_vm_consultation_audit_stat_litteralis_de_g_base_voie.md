# Liste des vues et vues matérialisées de consultation, audit, statistiques et pour Litteralis de G_BASE_VOIE

## Présentation
Liste des vues et vues matérialisées de consultation, audit, statistiques et pour Litteralis du schéma G_BASE_VOIE avec l'horaire et l'intervalle de mise à jour des VM.

## Consultation
du lundi au vendredi à 19h00 -> G_BASE_VOIE.VM_CONSULTATION_BASE_VOIE
du lundi au vendredi à 22h00 -> G_BASE_VOIE.VM_CONSULTATION_VOIE_ADMINISTRATIVE
du lundi au samedi à 04h00 -> G_BASE_VOIE.VM_CONSULTATION_VOIE_PHYSIQUE
du lundi au samedi à 05h00 -> G_BASE_VOIE.VM_CONSULTATION_SEUIL

## Litteralis
le dernier dimanche de chaque mois à 08h00 -> G_BASE_VOIE.VM_TAMPON_LITTERALIS_CORRESPONDANCE_DOMANIALITE_CLASSEMENT
le dernier dimanche de chaque mois à 12h00 -> G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE_ADMINISTRATIVE
le dernier dimanche de chaque mois à 15h00 -> G_BASE_VOIE.VM_TAMPON_LITTERALIS_TRONCON
le dernier dimanche de chaque mois à 18h00 -> G_BASE_VOIE.VM_TAMPON_LITTERALIS_VOIE
## A faire ## le dernier dimanche de chaque mois à 22h00 -> G_BASE_VOIE.VM_TAMPON_LITTERALIS_ADRESSE

## Audit
le samedi à 08h00 -> G_BASE_VOIE.VM_AUDIT_DISTANCE_SEUIL_TRONCON_1KM
le samedi à 12h00 -> G_BASE_VOIE.VM_AUDIT_TRONCON_NON_JOINTIFS
le samedi à 15h00 -> G_BASE_VOIE.VM_AUDIT_DOUBLON_NUMERO_SEUIL_PAR_VOIE_ADMINISTRATIVE
le samedi à 18h00 -> G_BASE_VOIE.VM_AUDIT_CODE_INSEE_SEUIL_EN_ERREUR
le samedi à 21h00 -> G_BASE_VOIE.VM_AUDIT_DOUBLON_NOM_VOIE_PAR_COMMUNE

## Statistiques
V_STAT_NOMBRE_OBJET
V_STAT_NOMBRE_OBJET_BASE_VOIE_ADRESSE
V_STAT_NOMBRE_SEUIL_PAR_GEOMETRIE
V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_COMMUNE
V_STAT_NOMBRE_VOIE_ADMINISTRATIVE_PAR_NOMBRE_VOIE_PHYSIQUE
V_STAT_NOMBRE_VOIE_PHYSIQUE_PAR_VOIE_ADMINISTRATIVE
V_STAT_RELATION_SEUIL_TRONCON_VOIE
V_STAT_RELATION_TRONCON_VOIE