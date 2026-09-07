# Contenu du Jeu — Listes Exhaustives

> Toutes les données de contenu : classes, compétences, mobs, équipements, ressources, recherches, etc.
> Fichiers associés : [`../readme.md`](../readme.md) — doc technique | [`gamedesign.md`](gamedesign.md) — formules de jeu

**Légende** : `- [x]` = implémenté | `- [ ]` = non implémenté

---

## Table des matières

1. [Classes de Base (6)](#1-classes-de-base)
2. [Classes Avancées (12)](#2-classes-avancées)
3. [Compétences par Classe](#3-compétences-par-classe)
4. [Traits de Caractère (42)](#4-traits-de-caractère)
5. [Mobs (19)](#5-mobs)
6. [Armes](#6-armes)
7. [Armures](#7-armures)
8. [Accessoires](#8-accessoires)
9. [Potions et Consommables](#9-potions-et-consommables)
10. [Enchantements (18)](#10-enchantements)
11. [Matériaux et Ressources](#11-matériaux-et-ressources)
12. [Plats et Fermentés](#12-plats-et-fermentés)
13. [Cultures (8)](#13-cultures)
14. [Recherches (39)](#14-recherches)
15. [Constructions par Salle](#15-constructions-par-salle)

---

## 1. Classes de Base

Selon la classe, le héros ne peut équiper que certains types d'arme et d'armure. Les stats à la génération sont tirées dans un intervalle défini par la classe.

### 1.1 Guerrier (Physique)

- [x] Guerrier — données en place dans `HeroClassRegistry`

**Armes** : Épée, Hache | **Armure** : Lourde

| Stat | Intervalle génération |
|------|----------------------|
| Force | 10 – 14 |
| Défense | 10 – 14 |
| Agilité | 5 – 9 |
| Magie | 3 – 7 |
| Chance | 5 – 10 |

### 1.2 Mage (Magique)

- [x] Mage — données en place dans `HeroClassRegistry`

**Armes** : Bâton, Grimoire | **Armure** : Légère

| Stat | Intervalle génération |
|------|----------------------|
| Force | 3 – 7 |
| Défense | 4 – 8 |
| Agilité | 6 – 10 |
| Magie | 12 – 16 |
| Chance | 8 – 12 |

### 1.3 Roublard (Physique)

- [x] Roublard — données en place dans `HeroClassRegistry`

**Armes** : Dague | **Armure** : Moyenne

| Stat | Intervalle génération |
|------|----------------------|
| Force | 6 – 10 |
| Défense | 3 – 7 |
| Agilité | 12 – 16 |
| Magie | 5 – 9 |
| Chance | 10 – 14 |

### 1.4 Chasseur (Physique)

- [x] Chasseur — données en place dans `HeroClassRegistry`

**Armes** : Arc | **Armure** : Moyenne

| Stat | Intervalle génération |
|------|----------------------|
| Force | 7 – 11 |
| Défense | 7 – 11 |
| Agilité | 11 – 15 |
| Magie | 4 – 8 |
| Chance | 8 – 12 |

### 1.5 Guérisseur (Magique)

- [x] Guérisseur — données en place dans `HeroClassRegistry`

**Armes** : Bâton | **Armure** : Légère

| Stat | Intervalle génération |
|------|----------------------|
| Force | 4 – 8 |
| Défense | 6 – 10 |
| Agilité | 6 – 10 |
| Magie | 11 – 15 |
| Chance | 10 – 14 |

### 1.6 Invocateur (Magique)

- [x] Invocateur — données en place dans `HeroClassRegistry`

**Armes** : Bâton, Grimoire | **Armure** : Légère

| Stat | Intervalle génération |
|------|----------------------|
| Force | 3 – 7 |
| Défense | 5 – 9 |
| Agilité | 6 – 10 |
| Magie | 11 – 15 |
| Chance | 10 – 14 |

---

## 2. Classes Avancées

Accessible niveau 50, rang B minimum, Salle d'Ascension requise. Les classes avancées débloquent de nouvelles armes équipables et de nouvelles compétences.

### 2.1 Chevalier (Évolution du Guerrier)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.7)

**Armes** : Épée, Hache, Lance | **Armure** : Lourde
Spécialité : Tank défensif, leader sur le champ de bataille, résistance extrême, coups dévastateurs.

### 2.2 Berserker (Évolution du Guerrier)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.8)

**Armes** : Épée, Hache, Marteau | **Armure** : Moyenne, Lourde
Spécialité : Attaque offensive dévastatrice, sacrifie la défense pour des dégâts massifs.

### 2.3 Sage Arcanique (Évolution du Mage)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.9)

**Armes** : Bâton, Grimoire, Orbe | **Armure** : Légère
Spécialité : Sorts arcaniques extrêmement puissants et complexes, précision redoutable.

### 2.4 Maître des Éléments (Évolution du Mage)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.10)

**Armes** : Bâton, Grimoire, Orbe | **Armure** : Légère
Spécialité : Contrôle du feu, eau, terre, air — dégâts massifs ou contrôle du terrain.

### 2.5 Assassin (Évolution du Roublard)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.11)

**Armes** : Dague, Arc | **Armure** : Légère, Moyenne
Spécialité : Attaques furtives mortelles, élimination rapide avant réaction.

### 2.6 Ombre (Évolution du Roublard)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.12)

**Armes** : Dague, Shuriken | **Armure** : Légère, Moyenne
Spécialité : Maîtrise de l'obscurité, quasi-indétectable, coups dans le dos.

### 2.7 Ranger (Évolution du Chasseur)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.13)

**Armes** : Arc | **Armure** : Moyenne
Spécialité : Pistage, tir longue distance, survie, fusion avec la nature.

### 2.8 Archer Mystique (Évolution du Chasseur)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.14)

**Armes** : Arc | **Armure** : Moyenne
Spécialité : Flèches enchantées avec effets magiques ou spéciaux variés.

### 2.9 Prêtre (Évolution du Guérisseur)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.15)

**Armes** : Bâton, Grimoire | **Armure** : Légère
Spécialité : Soins sacrés, protection divine, repoussement des ténèbres.

### 2.10 Druide (Évolution du Guérisseur)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.16)

**Armes** : Bâton | **Armure** : Légère
Spécialité : Puissance de la nature, soins et attaques naturelles, invocations végétales.

### 2.11 Maître des Esprits (Évolution de l'Invocateur)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.17)

**Armes** : Bâton, Grimoire | **Armure** : Légère
Spécialité : Convocation et contrôle d'esprits puissants du monde spirituel.

### 2.12 Conjurateur Élémentaire (Évolution de l'Invocateur)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.18)

**Armes** : Bâton, Grimoire, Orbe | **Armure** : Légère
Spécialité : Invocation de créatures élémentaires (feu, eau, terre) pour écraser les ennemis.

---

## 3. Compétences par Classe

**Total classes de base : 99 compétences** | Classes avancées : à définir

Coûts par rang : F=15 pts | E=30 pts | D=60 pts | C=90 pts | B=120 pts | A=150 pts | S=180 pts

---

### 3.1 Guerrier — 20 compétences

- [x] Coup Direct | Active | CD 3s | — | +10% dégâts arme
- [x] Endurance | Passive | — | — | +5% résistance dégâts physiques
- [x] Taillade | Active | CD 6s | — | +20% dégâts si ennemi < 50% HP
- [x] Entraînement au Bouclier | Passive | — | — | Réduit les dégâts reçus de 10%
- [x] Rage | Active | CD 30s | — | +15% Force pendant 15s
- [x] Durcissement | Passive | — | — | +10% Défense permanent
- [x] Coup de Bouclier | Active | CD 12s | — | 50% dégâts arme + stun 2s
- [x] Résilience | Passive | — | — | −5% tous les dégâts entrants
- [x] Attaque Frénétique | Active | CD 15s | — | 5 coups × 75% dégâts normaux
- [x] Cri de Guerre | Active | CD 45s | — | +10% Force+Défense alliés proches 30s
- [x] Maîtrise de l'Épée | Passive | — | — | +15% dégâts avec épée
- [x] Briseur d'Armure | Active | CD 30s | — | −20% Défense ennemi pendant 10s
- [x] Implacable | Passive | — | — | Récupère 2% HP max par kill
- [x] Maîtrise du Bouclier | Passive | — | — | −15% tous les dégâts reçus
- [x] Frappe du Jugement | Active | CD 30s | — | 200% dégâts, −25% Défense ennemi 10s
- [x] Fureur de Bataille | Active | CD 45s | — | +30% dégâts, −50% durée effets négatifs, 20s
- [x] Invincible | Active | CD 60s | — | Invulnérable aux dégâts pendant 10s
- [x] Maître d'Armes | Passive | — | — | +20% dégâts toutes armes
- [x] Défenseur du Roi | Active | CD 60s | — | −10% dégâts alliés proches + 5% redirect vers soi, 30s
- [x] Coup de Grâce | Active | CD 90s | — | Tue instantanément si ennemi < 20% HP

---

### 3.2 Mage — 19 compétences

- [x] Projectiles Magiques | Active | CD 3s | 10 mana | Projectiles magiques, dégâts légers
- [x] Protection Mineure | Active | CD 20s | 8 mana | −5% dégâts reçus pendant 15s
- [x] Boule de Feu | Active | CD 5s | 15 mana | Feu modéré sur cible unique
- [x] Maîtrise du Mana | Passive | — | — | +10% régénération mana
- [x] Éclair | Active | CD 5s | 14 mana | Foudre + 10% chance stun 2s
- [x] Bouclier Magique | Active | CD 25s | 20 mana | Absorbe 50% des dégâts pendant 10s
- [x] Explosion Arcanique | Active | CD 30s | 30 mana | Dégâts magiques AoE rayon 50px
- [x] Canalisation | Active | CD 35s | 25 mana | +15% dégâts sorts pendant 20s
- [x] Flammes Infernales | Active | CD 30s | 35 mana | Colonne de flammes zone, dégâts feu continus 10s
- [x] Gelure | Active | CD 45s | 28 mana | Dégâts glace + immobilise 5s
- [x] Nova de Glace | Active | CD 45s | 32 mana | AoE glace autour du mage, −50% vitesse 5s
- [x] Volonté de Fer | Passive | — | — | −25% durée effets négatifs sur le mage
- [x] Tempête de Foudre | Active | CD 45s | 40 mana | Foudre multi-cibles large zone
- [x] Drain de Vie | Active | CD 45s | 35 mana | Draine 10% vie cible sur 5s, soigne mage
- [x] Explosion Magique | Active | CD 45s | 45 mana | Massive AoE rayon 75px, dégâts élevés
- [x] Maîtrise des Arcanes | Passive | — | — | +25% dégâts de tous les sorts
- [x] Inversion des Sorts | Active | CD 30s | 30 mana | Renvoie tous les sorts reçus pendant 5s
- [x] Flamme Éternelle | Active | CD 60s | 50 mana | Large AoE feu persistante 15s
- [x] Métamorphose | Active | CD 90s | 60 mana | Forme magique : +50% dmg magiques, −30% dmg reçus, 20s

---

### 3.3 Roublard — 17 compétences

- [x] Coup Rapide | Active | CD 3s | — | +10% dégâts, attaque rapide
- [x] Esquive | Active | CD 20s | — | +5% chance esquive pendant 10s
- [x] Lancer de Dague | Active | CD 5s | — | 20% dégâts à distance
- [x] Camouflage | Active | CD 15s | — | Invisible 5s, aggro −100
- [x] Coup Bas | Active | CD 12s | — | 20% dégâts + −10% Défense ennemi 5s
- [x] Maître des Poisons | Passive | — | — | +15% dégâts des poisons
- [x] Pas de l'Ombre | Active | CD 15s | — | Téléporte derrière l'ennemi + frappe critique
- [x] Piège | Active | CD 20s | — | Piège au sol, immobilise 3s
- [x] Attaque Furtive | Passive | — | — | +30% dégâts si en mode furtif
- [x] Coup Critique | Active | CD 20s | — | +20% chance critique pendant 10s
- [x] Maître des Ombres | Passive | — | — | +30% durée compétences de furtivité
- [x] Paralysie | Active | CD 25s | — | Paralyse l'ennemi 5s
- [x] Saignée | Active | CD 25s | — | 30% dégâts + saignement
- [x] Danse des Lames | Active | CD 25s | — | Série de frappes AoE rayon 30px, 30% dégâts
- [x] Évasion | Active | CD 30s | — | 50% chance esquive toutes attaques pendant 10s
- [x] Assassinat | Active | CD 60s | — | 50% dégâts + 25% kill instant si < 30% HP
- [x] Toxines Mortelles | Active | CD 60s | — | Toutes les attaques infligent poison pendant 15s

---

### 3.4 Chasseur — 14 compétences

- [x] Tir Précis | Active | CD 3s | — | 20% dégâts, précision accrue
- [x] Flèche Empoisonnée | Active | CD 5s | — | 10% dégâts + poison
- [x] Tir Rapide | Active | CD 10s | — | 2 flèches × 15% dégâts
- [x] Œil de Faucon | Passive | — | — | +10% portée, +10% dégâts arc
- [x] Tir Explosif | Active | CD 10s | — | Flèche explosive, 20% dégâts AoE
- [x] Flèche Enflammée | Active | CD 12s | — | Feu + dégâts sur la durée
- [x] Piège à Loups | Active | CD 20s | — | Immobilise ennemi 5s
- [x] Flèche Perforante | Active | CD 18s | — | 20% dégâts, ignore 20% Défense
- [x] Tir en Cascade | Active | CD 20s | — | 5 flèches multi-cibles × 15% dégâts
- [x] Concentration | Passive | — | — | +5% chance de coup critique
- [x] Flèche Mortelle | Active | CD 30s | — | 50% dégâts + 50% chance critique
- [x] Piqûre de Scorpion | Active | CD 25s | — | Paralyse + poison 3s
- [x] Tir Légendaire | Active | CD 60s | — | 300% dégâts + kill instant si < 20% HP
- [x] Pluie de Flèches | Active | CD 45s | — | Salve large zone, dégâts massifs

---

### 3.5 Guérisseur — 14 compétences

- [x] Soin Mineur | Active | CD 3s | 10 mana | +15% HP d'un allié
- [x] Lumière Purificatrice | Active | CD 5s | 8 mana | Dissipe 1 effet négatif d'un allié
- [x] Bouclier de Lumière | Active | CD 5s | 15 mana | Absorbe 15% dégâts pour 1 allié pendant 10s
- [x] Régénération | Active | CD 20s | 20 mana | +2% HP/s pendant 10s sur 1 allié
- [x] Prière | Active | CD 20s | 18 mana | +10% Défense tous alliés rayon 50px pendant 15s
- [x] Soin de Groupe | Active | CD 20s | 25 mana | +20% HP tous alliés rayon 50px
- [x] Barrière Protectrice | Active | CD 25s | 30 mana | −15% dégâts tous alliés pendant 10s
- [x] Lumière Divine | Active | CD 25s | 35 mana | +40% HP + dissipe tous effets négatifs d'un allié
- [x] Main de Lumière | Active | CD 20s | 30 mana | +50% HP instantané sur 1 allié
- [x] Purification de Masse | Active | CD 30s | 35 mana | Dissipe tous effets négatifs alliés rayon 50px
- [x] Bouclier Sacré | Active | CD 35s | 40 mana | Absorbe TOUS les dégâts pour 1 allié pendant 10s
- [x] Soin Suprême | Active | CD 45s | 60 mana | +75% HP tous alliés rayon 75px
- [x] Résurrection | Active | CD 90s | 70 mana | Ressuscite tous les alliés tombés à 30% HP
- [x] Bénédiction Divine | Active | CD 60s | 50 mana | +20% toutes stats alliés rayon 75px pendant 15s

---

### 3.6 Invocateur — 15 compétences

- [x] Invocation Mineure | Active | CD 30s | 10 mana | Familier mineur combat 10s
- [x] Maîtrise des Esprits | Passive | — | — | +5% durée de toutes les invocations
- [x] Lien Spirituel | Active | CD 15s | 15 mana | +10% HP et dégâts invocations actives
- [x] Invocation de Loup Fantôme | Active | CD 30s | 20 mana | Loup spectral attaque 15s
- [x] Invocation de Golem | Active | CD 30s | 25 mana | Golem absorbe les dégâts à la place 15s
- [x] Réanimation | Active | — | 30 mana | Ressuscite un ennemi tombé pour combattre à vos côtés 10s
- [x] Invocation de Feu Follet | Active | CD 25s | 22 mana | Feu follet explose en AoE rayon 15px
- [x] Canalisation Spirituelle | Active | CD 25s | 25 mana | +15% puissance invocations pendant 20s
- [x] Invocation d'Élémentaire | Active | CD 30s | 35 mana | Élémentaire aléatoire (feu/eau/terre) pendant 30s
- [x] Maître des Invocations | Passive | — | — | +20% durée de toutes les invocations
- [x] Invocation de Dragonnet | Active | CD 45s | 40 mana | Dragonnet crache flammes sur ennemis 15s
- [x] Siphon de Vie | Active | CD 30s | 20 mana | Draine 10% vie invocation active → soigne soi
- [x] Invocation de Phénix | Active | CD 60s | 50 mana | Phénix feu + se ressuscite 1 fois, 30s
- [x] Armée des Ombres | Active | CD 60s | 45 mana | Invoque 5 ombres attaquantes
- [x] Gardien Céleste | Active | CD 60s | 50 mana | Gardien −20% dégâts tous alliés rayon 75px

---

### 3.7 Chevalier — compétences à définir

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.8 Berserker — compétences à définir

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.9 Sage Arcanique — compétences à définir

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.10 Maître des Éléments — compétences à définir

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.11 Assassin — compétences à définir

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.12 Ombre — compétences à définir

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.13 Ranger — compétences à définir

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.14 Archer Mystique — compétences à définir

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.15 Prêtre — compétences à définir

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.16 Druide — compétences à définir

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.17 Maître des Esprits — compétences à définir

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.18 Conjurateur Élémentaire — compétences à définir

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

---

## 4. Traits de Caractère

Chaque héros a **1 à 3 traits** (max 2 négatifs). Tirés à la génération.

**Traits incompatibles** : Stoïque ↔ Instable Émotionnellement | Travailleur ↔ Fainéant | Sang-froid ↔ Colérique

### 4.1 Traits Positifs (21)

- [x] Charismatique | +10% efficacité tâches sociales, +3 moral aux héros proches
- [x] Travailleur | +15% vitesse toutes tâches non-combattantes
- [x] Stoïque | Malus moraux sur événements négatifs réduits de 50%
- [x] Inspiration Divine | 10% chance/tâche de terminer instantanément ou +10 moral à un allié
- [x] Ami des Animaux | +20% missions impliquant des créatures
- [x] Résilient | Guérit 2× plus vite, malus blessure −10%
- [x] Leader Naturel | +5 moral à tous les héros du même groupe de mission
- [x] Dévoué à la Guilde | Ne démissionne jamais sauf moral = 0 pendant 10+ jours consécutifs
- [x] Bonne Constitution | Besoins Sommeil et Faim descendent 20% moins vite
- [x] Compagnon Loyal | Malus "perte d'un camarade" réduit de 50%
- [x] Apprend Vite | +25% XP combat et métier
- [x] Cuistot Passionné | +15% vitesse cuisine, +3 moral bonus aux héros qui mangent ses plats
- [x] Forgeur d'Élite | +20% qualité forge (équipements produits : +1 rang effectif de stats)
- [x] Enthousiaste | +15 moral au début de chaque journée in-game (durée 12h)
- [x] Mémoire Visuelle | +10% efficacité tâches liées au Savoir
- [x] Combatif | +10% vitesse d'attaque, initiative +1 en combat
- [x] Esprit d'Équipe | −70% probabilité de conflit interne
- [x] Artisan Inspiré | 5% chance par craft de produire +1 rang
- [x] Sang-froid | Durée Stun et Peur réduite de 50%
- [x] Robuste | PV Max +15%
- [x] Infatigable | Besoins Hygiène et Toilette descendent 25% moins vite

### 4.2 Traits Négatifs (21)

- [x] Colérique | 20% chance/jour de déclencher un conflit (−8 moral pour les deux)
- [x] Fainéant | −20% vitesse toutes tâches
- [x] Instable Émotionnellement | Tous les effets moraux (+ et −) amplifiés ×1.5
- [x] Cynique | Ne bénéficie pas des bonus moraux collectifs (cérémonies, festivals)
- [x] Arrogant | −15% moral en groupe si rang inférieur aux alliés
- [x] Maladroit | 10% chance d'accident en forge (−20% dégâts objet)
- [x] Solitaire | −5 moral si dans un groupe de 3+ héros
- [x] Avide | Demande une augmentation de salaire tous les 10 jours
- [x] Peureux | −10% stats en combat si PV < 40%
- [x] Bavard | 20% chance de révéler infos mission → −10% récompense
- [x] Rancunier | Garde en mémoire 1 conflit : −5 moral constant jusqu'à résolution
- [x] Impulsif | 15% chance d'attaquer sans ordre → aggro inutile
- [x] Hypocondriaque | Double temps de récupération blessures
- [x] Cleptomane | 5% chance/jour de voler un item dans l'inventaire guilde
- [x] Perfectionniste | +50% temps de craft mais +1 qualité garantie
- [x] Alarmiste | Propage les effets de peur à 1 allié adjacent
- [x] Misanthrope | Ne coopère pas avec les héros d'une autre race/classe (−10% stats)
- [x] Volatile | 25% chance que tout effet positif soit annulé
- [x] Noctambule | −20% efficacité si travaille le jour, +20% la nuit
- [x] Vorace | Besoin Faim diminue 30% plus vite
- [x] Incompétent | −10% à toutes les stats métier

---

## 5. Mobs

**19 mobs** répartis sur les rangs F à S.

### Rang F

- [x] **Slime** | Rang F | FM 0.1 | Vitesse 100 | STR 3 DEF 4 AGI 6 MAG 1 LCK 5 | PV 62 | Drops : Gelée de slime, Cristal magique (rare 15%)
- [x] **Araignée Sylvestre** | Rang F | FM 0.15 | Vitesse 90 | STR 4 DEF 3 AGI 8 MAG 1 LCK 5 | PV 66.5 | Drops : Résine collante, Baie noire (rare), Venin

### Rang E

- [x] **Loup** | Rang E | FM 0.2 | Vitesse 250 | STR 8 DEF 6 AGI 12 MAG 2 LCK 5 | PV 75 | Drops : Peau brute, Viande de loup, Cristal magique (rare), Graisse animale
- [x] **Sanglier** | Rang E | FM 0.25 | Vitesse 90 | STR 9 DEF 7 AGI 6 MAG 1 LCK 4 | PV 78.5 | Drops : Viande de sanglier, Cuir, Graisse animale, Peau brute
- [x] **Soldat Squelette** | Rang E | FM 0.2 | Vitesse 100 | STR 7 DEF 6 AGI 5 MAG 2 LCK 3 | PV 73 | Drops : Métal brut, Cristaux magiques, Os de berserker (rare)

### Rang D

- [x] **Gobelin** | Rang D | FM 0.15 | Vitesse 120 | STR 5 DEF 4 AGI 8 MAG 3 LCK 8 | PV 66 | Drops : Dents de gobelin, Viande de gobelin, Métal brut, Cristal magique (rare)
- [x] **Vipère** | Rang D | FM 0.25 | Vitesse 150 | STR 6 DEF 5 AGI 14 MAG 4 LCK 8 | PV 69.5 | Drops : Venin, Viande de vipère, Cristal magique (rare)
- [x] **Esprit des Ruines** | Rang D | FM 0.35 | Vitesse 110 | STR 2 DEF 5 AGI 10 MAG 12 LCK 6 | PV 61.5 | Drops : Essence d'ombre, Étoffe fantomatique, Cristaux magiques

### Rang C

- [x] **Orque Berserker** | Rang C | FM 0.4 | Vitesse 100 | STR 14 DEF 10 AGI 7 MAG 2 LCK 4 | PV 93 | Drops : Os de berserker, Cristal magique (rare)
- [x] **Spectre Hanté** | Rang C | FM 0.4 | Vitesse 100 | STR 3 DEF 7 AGI 12 MAG 15 LCK 6 | PV 66.5 | Drops : Étoffe fantomatique, Essence d'ombre (rare), Cristal magique
- [x] **Chasseur Elfe Noir** | Rang C | FM 0.45 | Vitesse 130 | STR 10 DEF 8 AGI 14 MAG 6 LCK 10 | PV 82 | Drops : Baie noire, Ambre, Rune magique (rare)

### Rang B

- [x] **Cyclope** | Rang B | FM 0.5 | Vitesse 80 | STR 18 DEF 16 AGI 4 MAG 3 LCK 5 | PV 110 | Drops : Peau brute, Œil de cyclope (rare), Cristal magique (rare)
- [x] **Chaman Corrompu** | Rang B | FM 0.35 | Vitesse 100 | STR 5 DEF 6 AGI 8 MAG 18 LCK 7 | PV 69 | Drops : Essence d'ombre, Totem corrompu (rare), Cristal magique
- [x] **Gardien de Lave** | Rang B | FM 0.5 | Vitesse 80 | STR 14 DEF 14 AGI 3 MAG 10 LCK 4 | PV 99 | Drops : Charbon, Cœur de flamme, Lingot d'acier (rare)
- [x] **Basilic Caverneux** | Rang B | FM 0.55 | Vitesse 100 | STR 12 DEF 12 AGI 8 MAG 3 LCK 5 | PV 92 | Drops : Venin, Écaille de dragon, Graisse animale

### Rang A

- [x] **Dragonnet de Feu** | Rang A | FM 0.5 | Vitesse 150 | STR 12 DEF 10 AGI 9 MAG 14 LCK 8 | PV 89 | Drops : Écaille de dragon, Viande de dragonnet, Cœur de flamme (rare), Cristal magique, Graisse animale
- [x] **Ent Ancien** | Rang A | FM 0.65 | Vitesse 70 | STR 16 DEF 18 AGI 4 MAG 10 LCK 7 | PV 109 | Drops : Ambre, Résine collante, Bois renforcé

### Rang S

- [x] **Seigneur Démoniaque** | Rang S | FM 1.0 | Vitesse 110 | STR 20 DEF 18 AGI 12 MAG 22 LCK 15 | PV 117 | Drops : Corne démoniaque, Cœur des ténèbres (rare), Éclat du chaos, Cristal magique, Fragment d'esprit (rare)
- [x] **Spectre d'Oubli** | Rang S | FM 1.0 | Vitesse 150 | STR 8 DEF 10 AGI 16 MAG 20 LCK 12 | PV 81 | Drops : Fragment d'esprit, Essence d'ombre, Cristal magique

---

## 6. Armes

**10 types** d'armes. Compatibilité par classe : voir §1 et §2.

### 6.1 Épées (Guerrier — corps à corps)

- [x] Épée d'entraînement | Rang F | Atk 5 | Bois ×2
- [x] Épée du soldat | Rang E | Atk 10 | Lingot de fer ×3, Cuir ×1
- [x] Épée longue | Rang D | Atk 15 | Lingot de fer ×4, Bois renforcé ×2
- [x] Lame de chevalier | Rang C | Atk 20 | Lingot d'acier ×2, Ambre ×2, Cuir souple ×1
- [x] Épée draconique | Rang A | Atk 25 | Lingot d'acier trempé ×2, Écailles de dragon ×2, Cœur de flamme ×1

### 6.2 Haches (Guerrier — corps à corps)

- [x] Hachette de bûcheron | Rang F | Atk 8 | Bois ×2, Lingot de fer ×1
- [x] Hache de guerre | Rang E | Atk 14 | Lingot de fer ×2, Bois ×1, Cuir ×1
- [x] Hache double | Rang D | Atk 18 | Lingot de fer ×4, Cuir tanné ×1
- [x] Hache viking | Rang C | Atk 22 | Lingot d'acier ×3, Ambre ×1, Cuir souple ×1

### 6.3 Lances (Chevalier — corps à corps)

*Débloquées uniquement par la classe avancée Chevalier.*

- [x] Lance de chasse | Rang F | Atk 7 | Bois ×2, Lingot de fer ×1
- [x] Pique du soldat | Rang E | Atk 12 | Lingot de fer ×3, Cuir ×1
- [x] Lance royale | Rang D | Atk 17 | Lingot d'acier ×2, Ambre ×2, Cuir tanné ×1
- [x] Trident de bataille | Rang C | Atk 20 | Lingot d'acier ×3, Essence d'ombre ×1
- [x] Lance des tempêtes | Rang A | Atk 25 | Essence de vent ×2, Rune magique ×1, Lingot d'acier ×3

### 6.4 Dagues (Roublard / Assassin — corps à corps)

- [x] Dague de voleur | Rang F | Atk 5 | Lingot de fer ×1, Cuir ×1
- [x] Lame de serpent | Rang D | Atk 10 | Lingot de fer ×2, Venin ×1
- [x] Karambit | Rang C | Atk 12 | Lingot d'acier ×2, Cuir souple ×1

### 6.5 Marteaux (Berserker — corps à corps)

*Débloqués uniquement par la classe avancée Berserker.*

- [x] Marteau de forgeron | Rang F | Atk 9 | Bois brut ×2, Métal brut ×1
- [x] Masse d'armes | Rang E | Atk 15 | Lingot de fer ×3, Cuir tanné ×1
- [x] Marteau du titan | Rang C | Atk 20 | Lingot d'acier ×3, Os de berserker ×1
- [x] Marteau des tempêtes | Rang B | Atk 25 | Lingot d'acier ×3, Cristaux magiques ×2
- [x] Marteau du chaos | Rang A | Atk 27 | Lingot d'acier trempé ×2, Éclat du chaos ×1, Cristaux magiques ×1

### 6.6 Bâtons (Mage / Guérisseur / Invocateur — corps à corps magique)

- [x] Bâton de novice | Rang F | Atk 6 | Bois ×2, Cristaux magiques ×1
- [x] Bâton de chêne | Rang E | Atk 10 | Bois ×2, Rune magique ×1
- [x] Bâton magique | Rang D | Atk 14 | Bois renforcé ×2, Cristaux magiques ×2
- [x] Bâton du sage | Rang B | Atk 18 | Bois renforcé ×3, Rune magique ×1

### 6.7 Arcs (Chasseur / Assassin / Archer Mystique — distance)

- [x] Arc court | Rang F | Atk 7 | Bois ×2, Corde ×1
- [x] Arc de chasseur | Rang E | Atk 12 | Bois ×3, Cuir tanné ×1, Corde ×1
- [x] Arc long | Rang D | Atk 17 | Bois renforcé ×3, Corde ×1
- [x] Arc elfique | Rang B | Atk 22 | Bois renforcé ×2, Ambre ×1, Rune magique ×1, Corde ×1

### 6.8 Orbes (Sage Arcanique / Maître des Éléments / Conjurateur — distance magique)

*Débloqués uniquement par certaines classes avancées.*

- [x] Orbe de cristal | Rang F | Atk 6 | Verre ×1, Cristaux magiques ×1
- [x] Orbe des éléments | Rang E | Atk 10 | Verre ×2, Rune magique ×1
- [x] Orbe de mana | Rang D | Atk 14 | Verre ��2, Cristaux magiques ×2, Ambre ×1
- [x] Orbe runique | Rang B | Atk 18 | Verre ×2, Rune magique ×2

### 6.9 Grimoires (Mage / Invocateur / Prêtre — distance magique)

- [x] Grimoire de novice | Rang F | Atk 5 | Cuir ×2, Baie noire ×1
- [x] Grimoire des ombres | Rang E | Atk 9 | Cuir ×2, Cristaux magiques ×1, Baie noire ×1
- [x] Grimoire des arcanes | Rang D | Atk 13 | Cuir tanné ×3, Rune magique ×2
- [x] Grimoire de l'archimage | Rang A | Atk 17 | Cuir souple ×3, Baie noire ×2, Cristaux magiques ×2

### 6.10 Shurikens (Ombre — distance)

*Débloqués uniquement par la classe avancée Ombre.*

- [x] Shuriken simple | Rang F | Atk 4 | Lingot de fer ×1
- [x] Shuriken tranchant | Rang E | Atk 6 | Lingot de fer ×2
- [x] Étoile de lancer | Rang D | Atk 8 | Lingot d'acier ×3
- [x] Shuriken empoisonné | Rang C | Atk 10 | Lingot d'acier ×2, Venin ×1

---

## 7. Armures

### 7.1 Armures Légères (Mage, Guérisseur, Invocateur)

**Tête**

- [x] Capuche en lin | Rang F | Déf 2 | Tissu ×2
- [x] Chapeau de paille | Rang F | Déf 1 | Tissu ×1
- [x] Capuche matelassée | Rang E | Déf 4 | Tissu ×2
- [x] Chapeau d'acolyte | Rang E | Déf 3 | Tissu ×2, Cristaux magiques ×1
- [x] Chapeau de druide | Rang E | Déf 4 | Tissu ×2, Essence de vent ×1
- [x] Chapeau mystique | Rang D | Déf 5 | Tissu ×2, Cristaux magiques ×1, Rune magique ×1

**Torse**

- [x] Robe de l'apprenti | Rang F | Déf 3 | Tissu ×3
- [x] Robe de magicien | Rang E | Déf 5 | Tissu ×3, Cristaux magiques ×1
- [x] Robe des éléments | Rang D | Déf 6 | Tissu renforcé ×2, Essence de vent ×1, Cristaux magiques ×1
- [x] Robe des arcanes | Rang C | Déf 7 | Tissu renforcé ×3, Rune magique ×1, Cristaux magiques ×2
- [x] Tunique d'ombre | Rang B | Déf 8 | Tissu renforcé ×2, Essence d'ombre ×1, Baie noire ×1

**Jambes**

- [x] Pantalon de lin | Rang F | Déf 2 | Tissu ×2
- [x] Pantalon enchanté | Rang E | Déf 4 | Tissu ×2, Cristaux magiques ×1
- [x] Jambières de mage | Rang D | Déf 5 | Tissu ×2, Cristaux magiques ×1

### 7.2 Armures Moyennes (Roublard, Chasseur)

**Tête**

- [x] Casque de patrouilleur | Rang E | Déf 6 | Cuir tanné ×2, Rivets en acier ×1
- [x] Casque de chasseur | Rang D | Déf 8 | Cuir tanné ×2, Lingot de fer ×1
- [x] Casque d'éclaireur | Rang C | Déf 10 | Cuir souple ×1, Lingot d'acier ×1, Essence de vent ×1

**Torse**

- [x] Armure de rôdeur | Rang E | Déf 8 | Cuir tanné ×3, Rivets en acier ×2
- [x] Armure de mercenaire | Rang D | Déf 10 | Cuir tanné ×3, Lingot de fer ×2
- [x] Armure de l'éclaireur | Rang C | Déf 12 | Cuir ×2, Lingot d'acier ×2, Essence de vent ×1
- [x] Armure des ombres | Rang C | Déf 11 | Cuir ×2, Essence d'ombre ×1, Tissu renforcé ×1

**Jambes**

- [x] Jambières du rôdeur | Rang E | Déf 6 | Cuir tanné ×2, Rivets en acier ×1, Baie noire ×1
- [x] Jambières de mercenaire | Rang D | Déf 8 | Cuir tanné ×3, Lingot de fer ×1
- [x] Jambières de l'éclaireur | Rang C | Déf 10 | Cuir souple ×2, Lingot d'acier ×1, Essence de vent ×1

### 7.3 Armures Lourdes (Guerrier)

**Tête**

- [x] Heaume de soldat | Rang E | Déf 12 | Lingot de fer ×3, Rivets en acier ×2
- [x] Casque de chevalier | Rang D | Déf 15 | Lingot d'acier ×2, Cuir tanné ×1, Rivets en acier ×2
- [x] Casque des Highlands | Rang A | Déf 16 | Lingot d'acier ×3, Cuir souple ×1, Essence de vent ×1
- [x] Heaume du conquérant | Rang S | Déf 18 | Lingot d'acier trempé ×2, Rivets en acier ×3, Œil de cyclope ×1

**Torse**

- [x] Cuirasse de soldat | Rang E | Déf 15 | Lingot de fer ×3, Cuir ×2, Rivets en acier ×2
- [x] Armure de chevalier | Rang D | Déf 18 | Lingot d'acier ×3, Rivets en acier ×2, Cuir ×1
- [x] Armure de guerre | Rang B | Déf 20 | Lingot d'acier trempé ×3, Rivets en acier ×2, Os de berserker ×1
- [x] Plastron volcan | Rang A | Déf 20 | Lingot d'acier trempé ×3, Charbon ×2, Cœur de flamme ×1
- [x] Armure de bataille | Rang S | Déf 22 | Lingot d'acier trempé ×2, Rivets en acier ×3, Cuir souple ×1, Cœur de flamme ×1

**Jambes**

- [x] Grèves de soldat | Rang E | Déf 12 | Lingot de fer ×2, Cuir tanné ×1, Rivets en acier ×1
- [x] Jambières de chevalier | Rang D | Déf 15 | Lingot d'acier ×2, Cuir tanné ×1, Rivets en acier ×2
- [x] Jambières de bataille | Rang B | Déf 18 | Lingot d'acier ×2, Lingot d'acier trempé ×1, Os de berserker ×1

---

## 8. Accessoires

### 8.1 Anneaux

- [x] Anneau de fer | Rang F | — | Lingot de fer ×1
- [x] Anneau de force | Rang D | +5 Force | Lingot d'acier ×1, Ambre ×1
- [x] Anneau de vivacité | Rang C | +5 Agilité | Lingot d'acier ×1, Ambre ×1
- [x] Anneau du mage | Rang C | +8 Magie | Lingot d'acier ×1, Cristaux magiques ×1
- [x] Anneau de vitalité | Rang C | +25 HP | Lingot d'acier ×1, Plante médicinale ×1, Cristaux magiques ×1

### 8.2 Amulettes

- [x] Amulette en bois | Rang F | — | Bois ×1
- [x] Amulette de soin | Rang D | Régénération lente PV | Lingot d'acier ×1, Plante médicinale ×1
- [x] Amulette de feu | Rang C | Résistance au feu | Lingot d'acier ×1, Cristaux magiques ×1
- [x] Amulette des anciens | Rang B | +10% mana | Lingot d'acier ×1, Rune magique ×1
- [x] Amulette runique | Rang B | +25 mana | Lingot d'acier ×1, Rune magique ×2

---

## 9. Potions et Consommables

### 9.1 Potions de Soins

- [x] Potion de soin mineur | +50 PV instantanément | Eau ×1, Plante médicinale ×1
- [x] Potion de soin | +100 PV instantanément | Eau ×1, Plante médicinale ×2
- [x] Potion de soin majeure | +200 PV instantanément | Eau ×2, Plante médicinale ×3, Cristaux magiques ×1

### 9.2 Potions Magiques

- [x] Potion de mana mineur | +50 Mana | Eau ×1, Cristaux magiques ×1
- [x] Potion de mana | +100 Mana | Eau ×1, Cristaux magiques ×2
- [x] Potion de mana supérieure | +200 Mana | Eau ×1, Cristaux magiques ×3

### 9.3 Potions Défensives

- [x] Potion de pierre | +20 END pendant 20s | Eau ×1, Essence d'ombre ×1
- [x] Potion de résistance au feu | −50% dégâts feu pendant 30s | Eau ×1, Cœur de flamme ×1, Cristaux magiques ×1
- [x] Potion d'ombre protectrice | −30% dégâts magiques pendant 30s | Eau ×1, Essence d'ombre ×1, Rune magique ×1

### 9.4 Potions Offensives / Buffs

- [x] Potion de force brute | +10 Force pendant 30s | Eau ×1, Os de berserker ×1
- [x] Potion de précision | +15% critique pendant 30s | Eau ×1, Dent de gobelin ×2
- [x] Potion de vitesse | +30% Agilité pendant 15s | Eau ×1, Essence de vent ��1, Cristaux magiques ×1
- [x] Potion de poison | Arme empoisonnée (3 coups) | Venin ×1, Baies noires ×1, Eau ×1
- [x] Potion de canalisation | +20% dégâts magiques pendant 20s | Eau ×1, Essence de vent ×1, Rune magique ×1

### 9.5 Potions Spéciales / Rares

- [x] Potion d'invisibilité | Invisibilité 10s | Eau ×1, Essence d'ombre ×1, Cristaux magiques ×1
- [x] Potion de rage berserk | +25 Force, −20% Défense pendant 15s | Huile de bœuf ×1, Os de berserker ×1, Baies noires ×1
- [x] Potion du chaos | Effet aléatoire buffs ou debuffs extrêmes | Éclat du chaos ×1, Rune magique ×1, Cristaux magiques ×2
- [x] Potion de purification | Supprime poison, brûlure, saignement, malus | Eau ×2, Plante médicinale ×2, Essence d'ombre ×1

---

## 10. Enchantements

**18 enchantements** (C→S). Irréversibles, 1 max par arme/armure. Doivent être recherchés avant utilisation.

### Rang C

- [x] Igni | Arme | +6 dégâts feu, 20% brûlure sur 3s | 3 jours | 5 Cristaux Magiques
- [x] Bouclier de Givre | Armure | −10% dégâts reçus, +5% résistance feu | 4 jours | 7 Cristaux Magiques
- [x] Cape de l'Ombre | Armure | +10% Agilité, +5% esquive | 3 jours | 7 Cristaux Magiques
- [x] Aura de Célérité | Armure | +10% vitesse, −5% temps attaque | 3 jours | 5 Cristaux Magiques
- [x] Tranchant Raffiné | Arme | +5% chance critique | 2.5 jours | 4 Cristaux Magiques

### Rang B

- [x] Lame de Foudre | Arme | +8 dégâts foudre, 10% paralysie 1.5s | 4 jours | 6 Cristaux Magiques
- [x] Lumière Purifiante | Armure | Immunité poison/saignement, +2 PV/s | 4 jours | 8 Cristaux Magiques
- [x] Griffes Spectrales | Arme | +5 dégâts ombre, 10% ignore armure | 3 jours | 6 Cristaux Magiques
- [x] Rune du Titan | Armure | +15% défense physique, +10% poids max | 5 jours | 9 Cristaux Magiques
- [x] Sceau des Arcanes | Bijou | +10% puissance magique, +10 mana max | 4 jours | 8 Cristaux Magiques

### Rang A

- [x] Bénédiction du Gardien | Armure | 10% dégâts redirigés vers soi, +3% armure magique | 5 jours | 9 Cristaux Magiques
- [x] Toucher Vampirique | Arme | Vol de vie : +3% dégâts infligés → PV | 5 jours | 10 Cristaux Magiques
- [x] Aura de Vaillance | Bijou | +8% Force, immunité peur | 5 jours | 9 Cristaux Magiques
- [x] Réflexe Surnaturel | Armure | 15% chance esquive automatique (CD 2 tours) | 5 jours | 9 Cristaux Magiques

### Rang S

- [x] Voile du Néant | Armure | 20% chance d'éviter toute attaque | 6 jours | 10 Cristaux + 1 Essence d'Ombre
- [x] Lame du Chaos | Arme | +10 dégâts aléatoires (type aléatoire), 5% confusion | 6 jours | 12 Cristaux + 1 Éclat du Chaos
- [x] Aura d'Ascension | Bijou | +10% toutes stats principales, bonus moral constant | 7 jours | 12 Cristaux + 1 Fragment d'Esprit
- [x] Égide Totale | Armure | −25% dégâts, +10% résistance magie, −10% vitesse | 6 jours | 11 Cristaux + 1 Écaille de Dragon

---

## 11. Matériaux et Ressources

### 11.1 Ressources Naturelles

- [x] Bois | Valeur 2 | Récolte forêt, Achat
- [x] Pierre | Valeur 3 | Récolte montagne, Achat
- [x] Lin | Valeur 2 | Culture, Achat
- [x] Eau | Valeur 1 | Puits, Achat
- [x] Sel | Valeur 1 | Récolte, Achat
- [x] Baie noire | Valeur 1 | Culture, Achat
- [x] Plante médicinale | Valeur 3 | Culture, Achat
- [x] Ambre | Valeur 11 | Récolte, Achat
- [x] Résine collante | Valeur 5 | Récolte, Achat
- [x] Métal brut | Valeur 3 | Récolte, Achat
- [x] Graisse animale | Valeur 3 | Loot (loup, vipère, cyclope…)
- [x] Peau brute | Valeur 3 | Loot (loup, sanglier, cyclope)
- [x] Sable | Valeur 2 | Récolte, Achat

### 11.2 Matériaux Artisanaux (Craftables)

- [x] Corde | Valeur 3 | Lin ×3 | Atelier | 1h
- [x] Fil résistant | Valeur 4 | Lin ×2, Résine ×1 | Atelier | 2h
- [x] Tissu | Valeur 3 | Lin ×2 | Métier à tisser | 1h
- [x] Tissu renforcé | Valeur 3 | Tissu ×1, Fil résistant ×1 | Métier à tisser | 2h
- [x] Cuir | Valeur 3 | Peau brute ×1, Eau ×1 | Atelier de tannage | 1h
- [x] Cuir tanné | Valeur 5 | Cuir ×2, Sel ×1, Eau ×1 | Atelier de tannage | 2h
- [x] Cuir souple | Valeur 8 | Cuir tanné ×2, Huile de bœuf ×1 | Atelier de tannage | 3h
- [x] Lingot de fer | Valeur 4 | Métal brut ×2 | Forge | 2h
- [x] Lingot d'acier | Valeur 6 | Métal brut ×3, Charbon ×1 | Forge | 3h
- [x] Lingot d'acier trempé | Valeur 9 | Lingot d'acier ×2, Huile de trempe ×1, Résine ×1, Eau ×1 | Forge | 4h
- [x] Rivets en acier | Valeur 3 | Métal brut ×1 | Forge | 1h
- [x] Charbon | Valeur 3 | Bois ×2 | Forge | 1h
- [x] Verre | Valeur 3 | Sable ×2, Charbon ×1 | Forge | 2h
- [x] Bois renforcé | Valeur 15 | Bois ×2, Résine ×1 | Atelier | 2h
- [x] Huile de bœuf | Valeur 4 | Graisse animale ×2, Plante médicinale ×1 | Table d'alchimie | 2h
- [x] Huile de trempe | Valeur 7 | Huile de bœuf ×1, Résine ×1, Eau ×1 | Table d'alchimie | 3h
- [x] Essence de vent | Valeur 12 | Cristaux magiques ×2, Gelée de slime ×1 | Table d'alchimie | 4h
- [x] Rune magique | Valeur 15 | Cristaux magiques ×1, Baie noire ×1, Étoffe fantomatique ×1 | Table d'alchimie | 5h
- [x] Farine de lin | Valeur 3 | Lin ×2 | Fourneau

### 11.3 Matériaux Magiques & Rares

- [x] Cristaux magiques | Valeur 8 | Loot tous les mobs (commun)
- [x] Essence d'ombre | Valeur 15 | Drop Spectre (rare), Esprit des ruines, Chaman corrompu
- [x] Étoffe fantomatique | Valeur 9 | Drop Spectre Hanté, Esprit des ruines
- [x] Fragment d'esprit | Valeur 25 | Drop Seigneur démoniaque (rare), Spectre d'oubli

### 11.4 Composants de Monstres

- [x] Gelée de slime | Valeur 2 | Slime
- [x] Dent de gobelin | Valeur 3 | Gobelin
- [x] Os de berserker | Valeur 6 | Orque Berserker
- [x] Venin | Valeur 5 | Vipère, Basilic caverneux, Araignée sylvestre
- [x] Écaille de dragon | Valeur 10 | Dragonnet, Basilic caverneux
- [x] Cœur de flamme | Valeur 15 | Dragonnet (rare), Gardien de lave
- [x] Corne démoniaque | Valeur 18 | Seigneur démoniaque (trophée, à vendre)
- [x] Éclat du chaos | Valeur 20 | Seigneur démoniaque
- [x] Œil de cyclope | — | Cyclope (rare)
- [x] Totem corrompu | — | Chaman corrompu (rare)
- [x] Cœur des ténèbres | — | Seigneur démoniaque (rare)

### 11.5 Ingrédients Culinaires

- [x] Œuf | Valeur 3 | Ferme (poules) / Marchand
- [x] Viande de loup | Valeur 6 | Loot Loup
- [x] Viande de gobelin | Valeur 5 | Loot Gobelin
- [x] Viande de vipère | Valeur 6 | Loot Vipère
- [x] Viande de sanglier | Valeur 15 | Loot Sanglier
- [x] Viande de dragon | Valeur 15 | Loot Dragonnet (rare)
- [x] Carotte | Valeur 4 | Jardin / Ferme
- [x] Champignons | Valeur 5 | Récolte forêt / caverne
- [x] Piment noir | Valeur 8 | Zone volcanique / Achat
- [x] Herbes sauvages | Valeur 4 | Récolte forêt / plaine
- [x] Herbes rares | Valeur 10 | Jardin magique / Chaman corrompu
- [x] Miel | Valeur 2 | Ruche
- [x] Houblon | Valeur 1 | Culture

---

## 12. Plats et Fermentés

### 12.1 Plats Simples

- [x] Pain de lin | Farine de lin ×2, Eau ×1 | Satiété 20 | Aucun effet
- [x] Soupe claire | Eau ×1, Champignon ×1 | Satiété 15 | +5 PV
- [x] Omelette aux herbes | Œuf ×2, Herbes sauvages ×1 | Satiété 25 | +5 énergie

### 12.2 Plats Nourrissants

- [x] Ragoût de loup | Viande de loup ×2, Carotte ×1, Eau ×1 | Satiété 40 | +10 Défense pendant 60s
- [x] Brochette forestière | Viande ×1, Champignons ×2, Sel ×1 | Satiété 35 | +5 Agilité pendant 30s
- [x] Curry de gobelin | Viande de gobelin ×1, Piment noir ×1, Eau ×1 | Satiété 45 | +10 Force pendant 30s
- [x] Tartine aux baies noires | Pain ×1, Baies noires ×3 | Satiété 30 | +5 moral, soigne stress

### 12.3 Plats Exotiques

- [x] Soupe spectrale | Étoffe fantomatique ×1, Eau ×2, Champignons ×2 | Satiété 35 | +10 Magie pendant 60s
- [x] Tartare de vipère | Viande de vipère ×1, Herbes ×1, Sel ×1, Huile de bœuf ×1 | Satiété 40 | Immunité poison 60s
- [x] Filet de dragon grillé | Viande de dragon ×1, Cœur de flamme ×1, Herbes rares ×1 | Satiété 50 | +25% dégâts pendant 60s
- [x] Tourte de mana | Farine ×2, Œuf ×1, Cristaux magiques ×1, Sel ×1 | Satiété 30 | +30 mana instant, +10 mana/30s

### 12.4 Préparations Fermentées

- [ ] Bière | Houblon ×3 | Durée fermentation : 3 jours in-game
- [ ] Hydromel | Miel ×3 | Durée fermentation : 5 jours in-game

---

## 13. Cultures

**8 plantes** cultivables dans le Jardin (recherche "Jardin Botanique" requise).

- [x] Lin | Artisanat textile (tissu, corde, farine) | 2.5 jours de pousse
- [x] Carotte | Cuisine (plats simples, ragoûts) | 3 jours de pousse
- [x] Champignons | Cuisine + Alchimie | 2 jours de pousse
- [x] Baies noires | Teinture noire, cuisine, potions | 3 jours de pousse
- [x] Piment noir | Cuisine | 4 jours de pousse
- [x] Herbes sauvages | Cuisine de base, potions mineures | 2 jours de pousse
- [x] Herbes rares | Alchimie avancée, potions puissantes | 5 jours de pousse
- [x] Plante médicinale | Base des potions de soin | 3 jours de pousse

---

## 14. Recherches (39)

**39 recherches** sur 10 niveaux. Durée en heures in-game, coût en or.

### Niveau 1

- [x] Forge basique | Salle forge, forge, enclume, plans F+E, plan charbon, verre | 200 or
- [x] Couture rudimentaire | Salle couture, métier à tisser, chevalet de tannage, plans F+E, plan tissu | 150 or
- [x] Artisanat général | Atelier de craft pour matériaux simples | 150 or
- [x] Recyclage primaire | Recyclage partiel 25% | 100 or

### Niveau 2

- [x] Entraînement Martial (prérequis : Forge basique) | Salle d'entraînement + tous objets physiques | 600 or
- [x] Entraînement Magique (prérequis : Couture rudimentaire) | Salle Arcanum, bureau enchanté, lutrin | 600 or
- [x] Alchimie basique (prérequis : Artisanat général) | Établi d'alchimie, objets liés, potions T1 | 300 or
- [x] Menuiserie (prérequis : Artisanat général) | Table en bois avec chaise, placard personnel, étagère | 400 or

### Niveau 3

- [x] Forge avancée D (prérequis : Entraînement Martial) | Plans rang D, soufflet, plan lingot de fer | 400 or
- [x] Tissage renforcé D (prérequis : Entraînement Magique) | Plans rang D, rouet, plan tissu renforcé | 350 or
- [x] Ameublement (prérequis : Menuiserie) | Cloche réception, coffre à outils, globe runique, lutrin, plan de travail, évier rustique | 400 or
- [x] Médecine (prérequis : Alchimie basique) | Salle infirmerie + objets liés | 500 or
- [x] Esthétique (prérequis : Ameublement) | Statue de héros, fontaine décorative, tapis royal rouge, tapis décoratif | 50 or

### Niveau 4

- [x] Forge de maître C (prérequis : Forge avancée) | Plans rang C, râtelier d'outils, plan lingot d'acier, huile de bœuf | 800 or
- [x] Armurier agile C (prérequis : Tissage renforcé) | Plans rang C, chevalet de tannage, plan cuir | 800 or
- [x] Joaillerie (prérequis : Forge avancée + Tissage renforcé) | Craft anneaux et amulettes | 1 200 or
- [x] Jardin Botanique (prérequis : Médecine) | Plates-bandes, compost, arrosoir magique, accès graines | 700 or
- [x] Divertissement (prérequis : Ameublement) | Plateau d'échecs, table de jeu | 800 or

### Niveau 5

- [x] Enchantement (prérequis : Forge de maître + Armurier agile) | Fonctionnalité enchantement, autel d'enchantement, enchantements rang C | 1 000 or
- [x] Alchimie avancée (prérequis : Jardin Botanique) | Potions T2 + chaudron magique | 1 000 or
- [x] Recyclage avancé 50% (prérequis : Économie commerciale) | Recyclage 50% des équipements | 800 or
- [x] Économie commerciale (prérequis : Médecine) | Accès au marché (achat / vente) | 650 or
- [x] Brassage (prérequis : Jardin Botanique) | Baril de fermentation, recettes bière + hydromel | 950 or

### Niveau 6

- [x] Forge haute qualité B (prérequis : Enchantement) | Plans rang B, bibliothèque de schémas, lingot d'acier trempé, rivets en acier | 2 000 or
- [x] Tannage avancé B (prérequis : Enchantement) | Plans rang B, armoire à tissus, plan cuir tanné + cuir souple | 2 000 or
- [x] Enchantement avancé (prérequis : Enchantement) | Débloque enchantements rang B | 1 500 or
- [x] Alchimiste expérimenté (prérequis : Alchimie avancée) | Potions offensives / défensives | 1 500 or
- [x] Agriculture avancée (prérequis : Alchimie avancée) | Arrosoir magique, bac de compost | 1 500 or

### Niveau 7

- [x] Enchantement expert (prérequis : Enchantement avancé) | Enchantements rang A | 2 000 or
- [x] Salle d'Ascension (prérequis : Forge haute qualité + Tannage avancé) | Évolution des héros, autel d'évolution, reliques anciennes, tapis de cérémonie | 1 800 or
- [x] Systèmes de Soins Innovants (prérequis : Alchimiste expérimenté) | Améliore soins infirmerie +25% efficacité | 2 100 or

### Niveau 8

- [x] Forge d'Armes Légendaires A (prérequis : Salle d'Ascension) | Plans rang A (armes et armures métal) | 2 500 or
- [x] Confection d'Armures Élites A (prérequis : Salle d'Ascension) | Plans rang A (armures cuir/tissu) | 2 500 or
- [x] Alchimiste expert (prérequis : Systèmes de Soins Innovants) | Accès potions rares | 2 000 or

### Niveau 9

- [x] Maîtrise de l'Enchantement Bijoux (prérequis : Forge légendaire + Confection élite) | Enchantement sur anneaux et amulettes | 3 000 or
- [x] Stratégie de Guerre Avancée (prérequis : Forge légendaire + Confection élite) | +10% dégâts passif pour tous les héros en combat | 2 800 or
- [x] Recyclage Intégral 100% (prérequis : Alchimiste expert) | Récupération totale des ressources d'un équipement recyclé | 3 000 or

### Niveau 10

- [x] Forgeron Légendaire S (prérequis : Stratégie de Guerre Avancée) | Plans rang S (armes et armures métal) | 3 500 or
- [x] Couturier Légendaire S (prérequis : Stratégie de Guerre Avancée) | Plans rang S (armures cuir/tissu) | 3 500 or

---

## 15. Constructions par Salle

### Murs / Sols / Portes

- [x] Mur de bois | 10 or/case
- [x] Mur de pierre | 15 or/case
- [x] Sol de bois | 10 or/case
- [x] Sol de pierre | 15 or/case
- [x] Gravier | 8 or/case
- [x] Porte en bois | 20 or/u
- [x] Porte renforcée | 25 or/u

### Hall

- [x] Tableau des quêtes | Affiche les quêtes disponibles | 150 or | De base
- [x] Comptoir de réception | Accueil et recrutement | 200 or | De base
- [x] Self | Contient les repas préparés | 50 or | De base
- [x] Instrument de musique | Détente musicale (harpe, lyre…) | 60 or | De base
- [x] Chandelier / torche | Lumière nocturne | 30 or | De base
- [x] Table en bois avec chaise | Grande table repas / réunion | 75 or | Menuiserie
- [x] Baril de boisson | +moral à la consommation | 50 or | Brassage
- [x] Cloche de réception | Signale les visiteurs | 20 or | Ameublement

### Chambre

- [x] Lit simple | Repos profond | 120 or | De base
- [x] Placard personnel | Stockage objets personnels | 60 or | Menuiserie
- [x] Étagère | Stockage grimoires, souvenirs | 40 or | Menuiserie

### Forge

- [x] Forge | Chauffe les métaux, craft | 300 or | Forge basique
- [x] Enclume | Forge les équipements, craft | 180 or | Forge basique
- [x] Soufflet | Accélère le chauffage, amélioration | 100 or | Forge avancée
- [x] Râtelier à outils | Décoration | 80 or | Forge de maître
- [x] Bibliothèque de schémas | Décoration | 60 or | Forge haute qualité

### Salle de Couture

- [x] Métier à tisser | Produit du tissu, craft | 120 or | Couture rudimentaire
- [x] Table de travail | Confection vêtements/armures tissu, craft | 75 or | Couture rudimentaire
- [x] Chevalet de tannage | Tanne le cuir, craft | 90 or | Armurier agile
- [x] Armoire à tissus | Stockage tissus, décoration | 60 or | Tannage avancé
- [x] Rouet | Améliore le métier à tisser | 100 or | Tissage renforcé
- [x] Mannequin | Décoration | — | Armurier agile

### Atelier

- [x] Établi de craft | Craft polyvalent | 140 or | Artisanat général
- [x] Atelier de recyclage | Recycle armes et armures | 100 or | Recyclage primaire
- [x] Coffre à outils | Décoration | 65 or | Ameublement

### Infirmerie

- [x] Lit médical | Repos des blessés | 130 or | Médecine
- [x] Bureau médical | Diagnostics, décoration | 80 or | Médecine
- [x] Table d'examen | Traitement des blessures | 90 or | Systèmes de Soins Innovants

### Salle d'Entraînement

- [x] Mannequin de combat | +FOR +DEF | 120 or | Entraînement martial
- [x] Poids / haltères | +FOR | 70 or | Entraînement martial
- [x] Cible en bois | +AGI | 60 or | Entraînement martial
- [x] Sacs de sable | +DEF | 50 or | Entraînement martial

### Atelier d'Alchimie

- [x] Établi d'alchimie | Préparations magiques, craft | 160 or | Alchimie basique
- [x] Chaudron magique | Potions complexes + accélère craft, amélioration | 120 or | Alchimie avancée

### Arcanum

- [x] Bureau enchanté | Entraînement magique +MAG | 120 or | Entraînement magique
- [x] Autel d'enchantement | Recherche et application enchantements, craft | 50 or | Enchantement
- [x] Globe runique | Décoration | 80 or | Ameublement
- [x] Lutrin | Décoration | 25 or | Ameublement

### Jardin

- [x] Plates-bandes | Zones de culture | 50 or | Jardin Botanique
- [x] Bac de compost | Améliore productivité | 60 or | Agriculture avancée
- [x] Arrosoir magique | Réduit le temps de pousse, amélioration | 80 or | Agriculture avancée

### Salle d'Ascension

- [x] Autel d'évolution | Déclenche l'ascension des classes | 200 or | Salle d'Ascension
- [x] Reliques anciennes | Éveil de classe, décoration | 120 or | Salle d'Ascension
- [x] Tapis de cérémonie | Atmosphère mystique, décoration | 50 or | Salle d'Ascension

### Salle de Loisirs

- [x] Plateau d'échecs | Divertissement stratégique | 70 or | Divertissement
- [x] Table de jeu | Cartes, dés… | 50 or | Divertissement
- [x] Instrument de musique | Harpe, lyre, tambour | 60 or | De base

### Sanitaires

- [x] Latrines | Hygiène de base | 40 or | De base
- [x] Lave-mains | Lavage des mains | 25 or | De base

### Cuisine

- [x] Fourneau | Cuisson de tous les plats, craft | 150 or | De base
- [x] Plan de travail | Découpe et assemblage, décoration | 80 or | Ameublement
- [x] Évier rustique | Lavage aliments, bonus hygiène | 90 or | Ameublement
- [x] Baril de fermentation | Hydromel et bière, interface dédiée | 120 or | Brassage

### Salle Décorative

- [x] Statue de héros | Décoration | 150 or | Esthétique
- [x] Fontaine décorative | Décoration centrale | 120 or | Esthétique
- [x] Tapis rouge royal | Prestige | 80 or | Esthétique
- [x] Tapis décoratif | Confort | 35 or | Esthétique
- [x] Chandelier / torche | Lumière nocturne | 30 or | De base
