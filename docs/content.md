# Contenu du Jeu — Listes Exhaustives

> Toutes les données de contenu : classes, compétences, mobs, équipements, ressources, recherches, etc.
> Fichiers associés : [`../readme.md`](../readme.md) — doc technique | [`gamedesign.md`](gamedesign.md) — formules de jeu

**Légende** : `- [x]` = implémenté | `- [ ]` = non implémenté

---

## Table des matières

1. [Classes de Base (6)](#1-classes-de-base)
2. [Classes Avancées (12)](#2-classes-avancées)
3. [Compétences par Classe (99 total)](#3-compétences-par-classe)
4. [Traits de Caractère (42)](#4-traits-de-caractère)
5. [Mobs (19)](#5-mobs)
6. [Armes (10 types)](#6-armes)
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

> **Compétences des classes avancées** : À compléter (voir [backlog.md](backlog.md)).

### 2.1 Chevalier (Évolution du Guerrier)

- [x] Données présentes | - [ ] Compétences non implémentées

**Armes** : Épée, Hache, **Lance** | **Armure** : Lourde

Spécialité : Tank défensif, leader sur le champ de bataille, résistance extrême, coups dévastateurs.

### 2.2 Berserker (Évolution du Guerrier)

- [x] Données présentes | - [ ] Compétences non implémentées

**Armes** : Épée, Hache, **Marteau** | **Armure** : Moyenne, Lourde

Spécialité : Attaque offensive dévastatrice, sacrifie la défense pour des dégâts massifs.

### 2.3 Sage Arcanique (Évolution du Mage)

- [x] Données présentes | - [ ] Compétences non implémentées

**Armes** : Bâton, Grimoire, **Orbe** | **Armure** : Légère

Spécialité : Sorts arcaniques extrêmement puissants et complexes, précision redoutable.

### 2.4 Maître des Éléments (Évolution du Mage)

- [x] Données présentes | - [ ] Compétences non implémentées

**Armes** : Bâton, Grimoire, **Orbe** | **Armure** : Légère

Spécialité : Contrôle du feu, eau, terre, air — dégâts massifs ou contrôle du terrain.

### 2.5 Assassin (Évolution du Roublard)

- [x] Données présentes | - [ ] Compétences non implémentées

**Armes** : Dague, **Arc** | **Armure** : Légère, Moyenne

Spécialité : Attaques furtives mortelles, élimination rapide avant réaction.

### 2.6 Ombre (Évolution du Roublard)

- [x] Données présentes | - [ ] Compétences non implémentées

**Armes** : Dague, **Shuriken** | **Armure** : Légère, Moyenne

Spécialité : Maîtrise de l'obscurité, quasi-indétectable, coups dans le dos.

### 2.7 Ranger (Évolution du Chasseur)

- [x] Données présentes | - [ ] Compétences non implémentées

**Armes** : Arc | **Armure** : Moyenne

Spécialité : Pistage, tir longue distance, survie, fusion avec la nature.

### 2.8 Archer Mystique (Évolution du Chasseur)

- [x] Données présentes | - [ ] Compétences non implémentées

**Armes** : Arc | **Armure** : Moyenne

Spécialité : Flèches enchantées avec effets magiques ou spéciaux variés.

### 2.9 Prêtre (Évolution du Guérisseur)

- [x] Données présentes | - [ ] Compétences non implémentées

**Armes** : Bâton, **Grimoire** | **Armure** : Légère

Spécialité : Soins sacrés, protection divine, repoussement des ténèbres.

### 2.10 Druide (Évolution du Guérisseur)

- [x] Données présentes | - [ ] Compétences non implémentées

**Armes** : Bâton | **Armure** : Légère

Spécialité : Puissance de la nature, soins et attaques naturelles, invocations végétales.

### 2.11 Maître des Esprits (Évolution de l'Invocateur)

- [x] Données présentes | - [ ] Compétences non implémentées

**Armes** : Bâton, Grimoire | **Armure** : Légère

Spécialité : Convocation et contrôle d'esprits puissants du monde spirituel.

### 2.12 Conjurateur Élémentaire (Évolution de l'Invocateur)

- [x] Données présentes | - [ ] Compétences non implémentées

**Armes** : Bâton, Grimoire, **Orbe** | **Armure** : Légère

Spécialité : Invocation de créatures élémentaires (feu, eau, terre) pour écraser les ennemis.

---

## 3. Compétences par Classe

**Total : 99 compétences** (6 classes de base uniquement — classes avancées à compléter).

Coûts par rang : F=15 pts | E=30 pts | D=60 pts | C=90 pts | B=120 pts | A=150 pts | S=180 pts

---

### 3.1 Guerrier — 20 compétences

- [x] Toutes dans `SkillLibrary`

| Rang | Nom | Type | Cooldown | Mana | Effet |
|------|-----|------|----------|------|-------|
| F | Coup Direct | Active | 3s | — | +10% dégâts arme |
| F | Endurance | Passive | — | — | +5% résistance dégâts physiques |
| E | Taillade | Active | 6s | — | +20% dégâts si ennemi < 50% HP |
| E | Entraînement au Bouclier | Passive | — | — | Réduit les dégâts reçus de 10% |
| D | Rage | Active | 30s | — | +15% Force pendant 15s |
| D | Durcissement | Passive | — | — | +10% Défense permanent |
| C | Coup de Bouclier | Active | 12s | — | 50% dégâts arme + stun 2s |
| C | Résilience | Passive | — | — | −5% tous les dégâts entrants |
| C | Attaque Frénétique | Active | 15s | — | 5 coups × 75% dégâts normaux |
| B | Cri de Guerre | Active | 45s | — | +10% Force+Défense alliés proches 30s |
| B | Maîtrise de l'Épée | Passive | — | — | +15% dégâts avec épée |
| B | Briseur d'Armure | Active | 30s | — | −20% Défense ennemi pendant 10s |
| B | Implacable | Passive | — | — | Récupère 2% HP max par kill |
| A | Maîtrise du Bouclier | Passive | — | — | −15% tous les dégâts reçus |
| A | Frappe du Jugement | Active | 30s | — | 200% dégâts, −25% Défense ennemi 10s |
| A | Fureur de Bataille | Active | 45s | — | +30% dégâts, −50% durée effets négatifs, 20s |
| S | Invincible | Active | 60s | — | Invulnérable aux dégâts pendant 10s |
| S | Maître d'Armes | Passive | — | — | +20% dégâts toutes armes |
| S | Défenseur du Roi | Active | 60s | — | −10% dégâts alliés proches + 5% redirect vers soi, 30s |
| S | Coup de Grâce | Active | 90s | — | Tue instantanément si ennemi < 20% HP |

---

### 3.2 Mage — 19 compétences

- [x] Toutes dans `SkillLibrary`

| Rang | Nom | Type | Cooldown | Mana | Effet |
|------|-----|------|----------|------|-------|
| F | Projectiles Magiques | Active | 3s | 10 | Projectiles magiques, dégâts légers |
| F | Protection Mineure | Active | 20s | 8 | −5% dégâts reçus pendant 15s |
| E | Boule de Feu | Active | 5s | 15 | Feu modéré sur cible unique |
| E | Maîtrise du Mana | Passive | — | — | +10% régénération mana |
| E | Éclair | Active | 5s | 14 | Foudre + 10% chance stun 2s |
| D | Bouclier Magique | Active | 25s | 20 | Absorbe 50% des dégâts pendant 10s |
| C | Explosion Arcanique | Active | 30s | 30 | Dégâts magiques AoE rayon 50px |
| C | Canalisation | Active | 35s | 25 | +15% dégâts sorts pendant 20s |
| C | Flammes Infernales | Active | 30s | 35 | Colonne de flammes zone, dégâts feu continus 10s |
| B | Gelure | Active | 45s | 28 | Dégâts glace + immobilise 5s |
| B | Nova de Glace | Active | 45s | 32 | AoE glace autour du mage, −50% vitesse 5s |
| B | Volonté de Fer | Passive | — | — | −25% durée effets négatifs sur le mage |
| A | Tempête de Foudre | Active | 45s | 40 | Foudre multi-cibles large zone |
| A | Drain de Vie | Active | 45s | 35 | Draine 10% vie cible sur 5s, soigne mage |
| A | Explosion Magique | Active | 45s | 45 | Massive AoE rayon 75px, dégâts élevés |
| S | Maîtrise des Arcanes | Passive | — | — | +25% dégâts de tous les sorts |
| S | Inversion des Sorts | Active | 30s | 30 | Renvoie tous les sorts reçus pendant 5s |
| S | Flamme Éternelle | Active | 60s | 50 | Large AoE feu persistante 15s |
| S | Métamorphose | Active | 90s | 60 | Forme magique : +50% dmg magiques, −30% dmg reçus, 20s |

---

### 3.3 Roublard — 17 compétences

- [x] Toutes dans `SkillLibrary`

| Rang | Nom | Type | Cooldown | Mana | Effet |
|------|-----|------|----------|------|-------|
| F | Coup Rapide | Active | 3s | — | +10% dégâts, attaque rapide |
| F | Esquive | Active | 20s | — | +5% chance esquive pendant 10s |
| E | Lancer de Dague | Active | 5s | — | 20% dégâts à distance |
| E | Camouflage | Active | 15s | — | Invisible 5s, aggro −100 |
| D | Coup Bas | Active | 12s | — | 20% dégâts + −10% Défense ennemi 5s |
| D | Maître des Poisons | Passive | — | — | +15% dégâts des poisons |
| C | Pas de l'Ombre | Active | 15s | — | Téléporte derrière l'ennemi + frappe critique |
| C | Piège | Active | 20s | — | Piège au sol, immobilise 3s |
| C | Attaque Furtive | Passive | — | — | +30% dégâts si en mode furtif |
| B | Coup Critique | Active | 20s | — | +20% chance critique pendant 10s |
| B | Maître des Ombres | Passive | — | — | +30% durée compétences de furtivité |
| B | Paralysie | Active | 25s | — | Paralyse l'ennemi 5s |
| A | Saignée | Active | 25s | — | 30% dégâts + saignement |
| A | Danse des Lames | Active | 25s | — | Série de frappes AoE rayon 30px, 30% dégâts |
| A | Évasion | Active | 30s | — | 50% chance esquive toutes attaques pendant 10s |
| S | Assassinat | Active | 60s | — | 50% dégâts + 25% kill instant si < 30% HP |
| S | Toxines Mortelles | Active | 60s | — | Toutes les attaques infligent poison pendant 15s |

---

### 3.4 Chasseur — 14 compétences

- [x] Toutes dans `SkillLibrary`

| Rang | Nom | Type | Cooldown | Mana | Effet |
|------|-----|------|----------|------|-------|
| F | Tir Précis | Active | 3s | — | 20% dégâts, précision accrue |
| F | Flèche Empoisonnée | Active | 5s | — | 10% dégâts + poison |
| E | Tir Rapide | Active | 10s | — | 2 flèches × 15% dégâts |
| E | Œil de Faucon | Passive | — | — | +10% portée, +10% dégâts arc |
| D | Tir Explosif | Active | 10s | — | Flèche explosive, 20% dégâts AoE |
| C | Flèche Enflammée | Active | 12s | — | Feu + dégâts sur la durée |
| C | Piège à Loups | Active | 20s | — | Immobilise ennemi 5s |
| B | Flèche Perforante | Active | 18s | — | 20% dégâts, ignore 20% Défense |
| B | Tir en Cascade | Active | 20s | — | 5 flèches multi-cibles × 15% dégâts |
| A | Concentration | Passive | — | — | +5% chance de coup critique |
| A | Flèche Mortelle | Active | 30s | — | 50% dégâts + 50% chance critique |
| A | Piqûre de Scorpion | Active | 25s | — | Paralyse + poison 3s |
| S | Tir Légendaire | Active | 60s | — | 300% dégâts + kill instant si < 20% HP |
| S | Pluie de Flèches | Active | 45s | — | Salve large zone, dégâts massifs |

---

### 3.5 Guérisseur — 14 compétences

- [x] Toutes dans `SkillLibrary`

| Rang | Nom | Type | Cooldown | Mana | Effet |
|------|-----|------|----------|------|-------|
| F | Soin Mineur | Active | 3s | 10 | +15% HP d'un allié |
| F | Lumière Purificatrice | Active | 5s | 8 | Dissipe 1 effet négatif d'un allié |
| E | Bouclier de Lumière | Active | 5s | 15 | Absorbe 15% dégâts pour 1 allié pendant 10s |
| E | Régénération | Active | 20s | 20 | +2% HP/s pendant 10s sur 1 allié |
| D | Prière | Active | 20s | 18 | +10% Défense tous alliés rayon 50px pendant 15s |
| C | Soin de Groupe | Active | 20s | 25 | +20% HP tous alliés rayon 50px |
| C | Barrière Protectrice | Active | 25s | 30 | −15% dégâts tous alliés pendant 10s |
| B | Lumière Divine | Active | 25s | 35 | +40% HP + dissipe tous effets négatifs d'un allié |
| B | Main de Lumière | Active | 20s | 30 | +50% HP instantané sur 1 allié |
| A | Purification de Masse | Active | 30s | 35 | Dissipe tous effets négatifs alliés rayon 50px |
| A | Bouclier Sacré | Active | 35s | 40 | Absorbe TOUS les dégâts pour 1 allié pendant 10s |
| S | Soin Suprême | Active | 45s | 60 | +75% HP tous alliés rayon 75px |
| S | Résurrection | Active | 90s | 70 | Ressuscite tous les alliés tombés à 30% HP |
| S | Bénédiction Divine | Active | 60s | 50 | +20% toutes stats alliés rayon 75px pendant 15s |

---

### 3.6 Invocateur — 15 compétences

- [x] Toutes dans `SkillLibrary`

| Rang | Nom | Type | Cooldown | Mana | Effet |
|------|-----|------|----------|------|-------|
| F | Invocation Mineure | Active | 30s | 10 | Familier mineur combat 10s |
| F | Maîtrise des Esprits | Passive | — | — | +5% durée de toutes les invocations |
| E | Lien Spirituel | Active | 15s | 15 | +10% HP et dégâts invocations actives |
| E | Invocation de Loup Fantôme | Active | 30s | 20 | Loup spectral attaque 15s |
| D | Invocation de Golem | Active | 30s | 25 | Golem absorbe les dégâts à la place 15s |
| D | Réanimation | Active | — | 30 | Ressuscite un ennemi tombé pour combattre à vos côtés 10s |
| C | Invocation de Feu Follet | Active | 25s | 22 | Feu follet explose en AoE rayon 15px |
| C | Canalisation Spirituelle | Active | 25s | 25 | +15% puissance invocations pendant 20s |
| C | Invocation d'Élémentaire | Active | 30s | 35 | Élémentaire aléatoire (feu/eau/terre) pendant 30s |
| B | Maître des Invocations | Passive | — | — | +20% durée de toutes les invocations |
| A | Invocation de Dragonnet | Active | 45s | 40 | Dragonnet crache flammes sur ennemis 15s |
| A | Siphon de Vie | Active | 30s | 20 | Draine 10% vie invocation active → soigne soi |
| S | Invocation de Phénix | Active | 60s | 50 | Phénix feu + se ressuscite 1 fois, 30s |
| S | Armée des Ombres | Active | 60s | 45 | Invoque 5 ombres attaquantes |
| S | Gardien Céleste | Active | 60s | 50 | Gardien −20% dégâts tous alliés rayon 75px |

---

## 4. Traits de Caractère

Chaque héros a **1 à 3 traits** (max 2 négatifs). Tirés à la génération.

- [x] Tous les 42 traits dans `TraitLibrary`

**Traits incompatibles** : Stoïque ↔ Instable Émotionnellement | Travailleur ↔ Fainéant | Sang-froid ↔ Colérique

### 4.1 Traits Positifs (21)

| Trait | Effet |
|-------|-------|
| Charismatique | +10% efficacité tâches sociales, +3 moral aux héros proches |
| Travailleur | +15% vitesse toutes tâches non-combattantes |
| Stoïque | Malus moraux sur événements négatifs réduits de 50% |
| Inspiration Divine | 10% chance/tâche de terminer instantanément ou +10 moral à un allié |
| Ami des Animaux | +20% missions impliquant des créatures |
| Résilient | Guérit 2× plus vite, malus blessure −10% |
| Leader Naturel | +5 moral à tous les héros du même groupe de mission |
| Dévoué à la Guilde | Ne démissionne jamais sauf moral = 0 pendant 10+ jours consécutifs |
| Bonne Constitution | Besoins Sommeil et Faim descendent 20% moins vite |
| Compagnon Loyal | Malus "perte d'un camarade" réduit de 50% |
| Apprend Vite | +25% XP combat et métier |
| Cuistot Passionné | +15% vitesse cuisine, +3 moral bonus aux héros qui mangent ses plats |
| Forgeur d'Élite | +20% qualité forge (équipements produits : +1 rang effectif de stats) |
| Enthousiaste | +15 moral au début de chaque journée in-game (durée 12h) |
| Mémoire Visuelle | +10% efficacité tâches liées au Savoir |
| Combatif | +10% vitesse d'attaque, initiative +1 en combat |
| Esprit d'Équipe | −70% probabilité de conflit interne |
| Artisan Inspiré | 5% chance par craft de produire +1 rang |
| Sang-froid | Durée Stun et Peur réduite de 50% |
| Robuste | PV Max +15% |
| Infatigable | Besoins Hygiène et Toilette descendent 25% moins vite |

### 4.2 Traits Négatifs (21)

| Trait | Effet |
|-------|-------|
| Colérique | 20% chance/jour de déclencher un conflit (−8 moral pour les deux) |
| Fainéant | −20% vitesse toutes tâches |
| Instable Émotionnellement | Tous les effets moraux (+ et −) amplifiés ×1.5 |
| Cynique | Ne bénéficie pas des bonus moraux collectifs (cérémonies, festivals) |
| Arrogant | −15% moral en groupe si rang inférieur aux alliés |
| Maladroit | 10% chance d'accident en forge (−20% dégâts objet) |
| Solitaire | −5 moral si dans un groupe de 3+ héros |
| Avide | Demande une augmentation de salaire tous les 10 jours |
| Peureux | −10% stats en combat si PV < 40% |
| Bavard | 20% chance de révéler infos mission → −10% récompense |
| Rancunier | Garde en mémoire 1 conflit : −5 moral constant jusqu'à résolution |
| Impulsif | 15% chance d'attaquer sans ordre → aggro inutile |
| Hypocondriaque | Double temps de récupération blessures |
| Cleptomane | 5% chance/jour de voler un item dans l'inventaire guilde |
| Perfectionniste | +50% temps de craft mais +1 qualité garantie |
| Alarmiste | Propage les effets de peur à 1 allié adjacent |
| Misanthrope | Ne coopère pas avec les héros d'une autre race/classe (−10% stats) |
| Volatile | 25% chance que tout effet positif soit annulé |
| Noctambule | −20% efficacité si travaille le jour, +20% la nuit |
| Vorace | Besoin Faim diminue 30% plus vite |
| Incompétent | −10% à toutes les stats métier |

---

## 5. Mobs

**19 mobs** répartis sur les rangs F à S.

- [x] Tous dans `MobLibrary`

### Rang F

#### Slime
- [x] Implémenté
- **Rang** : F | **FM** : 0.1 | **Vitesse** : 100
- **Stats** : Force 3 | Défense 4 | Agilité 6 | Magie 1 | Chance 5
- **PV** : 50 + (3×2) + (4×1.5) = **62**
- **Drops** : 1× Gelée de slime | 1× Cristal magique (rare 15%)
- **Attaques** :
  - Coup Gluant : bondit sur l'ennemi. Puissance 4
  - Charge Instable *(spécial)* : zone légère. Puissance 3

#### Araignée Sylvestre
- [x] Implémenté
- **Rang** : F | **FM** : 0.15 | **Vitesse** : 90
- **Stats** : Force 4 | Défense 3 | Agilité 8 | Magie 1 | Chance 5
- **PV** : 50 + (4×2) + (3×1.5) = **66.5**
- **Drops** : 1× Résine collante | 1× Baie noire (rare) | 1–2× Venin
- **Attaques** :
  - Morsure Rapide : dégâts faibles et rapides. Puissance 5
  - Jet de Toile *(spécial)* : ralentit la cible −30% vitesse, 3s. Puissance 2

---

### Rang E

#### Loup
- [x] Implémenté
- **Rang** : E | **FM** : 0.2 | **Vitesse** : 250
- **Stats** : Force 8 | Défense 6 | Agilité 12 | Magie 2 | Chance 5
- **PV** : 50 + (8×2) + (6×1.5) = **75**
- **Drops** : 1–2× Peau brute | 1–2× Viande de loup | 1× Cristal magique (rare) | 1–2× Graisse animale
- **Attaques** :
  - Morsure Sauvage : mord violemment. Puissance 10
  - Hurlement de Meute *(spécial)* : +10% Agilité alliés loups pendant 10s

#### Sanglier
- [x] Implémenté
- **Rang** : E | **FM** : 0.25 | **Vitesse** : 90
- **Stats** : Force 9 | Défense 7 | Agilité 6 | Magie 1 | Chance 4
- **PV** : 50 + (9×2) + (7×1.5) = **78.5**
- **Drops** : 1–2× Viande de sanglier | 1× Cuir | 1–3× Graisse animale | 1–2× Peau brute
- **Attaques** :
  - Charge Bestiale : frontale puissante, chance repoussement 1 case. Puissance 3
  - Grognement Furieux *(spécial)* : +10% Défense soi pendant 6s

#### Soldat Squelette
- [x] Implémenté
- **Rang** : E | **FM** : 0.2 | **Vitesse** : 100
- **Stats** : Force 7 | Défense 6 | Agilité 5 | Magie 2 | Chance 3
- **PV** : 50 + (7×2) + (6×1.5) = **73**
- **Drops** : 1× Métal brut | 1× Cristaux magiques | 1× Os de berserker (rare)
- **Attaques** :
  - Coup d'Épée Rouillée. Puissance 8
  - Cri Spectral *(spécial)* : −5 Défense ennemi pendant 5s

---

### Rang D

#### Gobelin
- [x] Implémenté
- **Rang** : D | **FM** : 0.15 | **Vitesse** : 120
- **Stats** : Force 5 | Défense 4 | Agilité 8 | Magie 3 | Chance 8
- **PV** : 50 + (5×2) + (4×1.5) = **66**
- **Drops** : 2–3× Dents de gobelin | 1× Viande de gobelin | 1–4× Métal brut | 1× Cristal magique (rare)
- **Attaques** :
  - Coup de Poignard. Puissance 7
  - Jet de Pierre *(spécial)* : 10% chance d'étourdir 3s. Puissance 5

#### Vipère
- [x] Implémenté
- **Rang** : D | **FM** : 0.25 | **Vitesse** : 150
- **Stats** : Force 6 | Défense 5 | Agilité 14 | Magie 4 | Chance 8
- **PV** : 50 + (6×2) + (5×1.5) = **69.5**
- **Drops** : 1–2× Venin | 1× Viande de vipère | 1× Cristal magique (rare)
- **Attaques** :
  - Morsure Venimeuse : Poison 2 dégâts/s pendant 5s. Puissance 6
  - Constriction *(spécial)* : immobilise la cible 2s. Puissance 4

#### Esprit des Ruines
- [x] Implémenté
- **Rang** : D | **FM** : 0.35 | **Vitesse** : 110
- **Stats** : Force 2 | Défense 5 | Agilité 10 | Magie 12 | Chance 6
- **PV** : 50 + (2×2) + (5×1.5) = **61.5**
- **Drops** : 1× Essence d'ombre | 1× Étoffe fantomatique | 1× Cristaux magiques
- **Attaques** :
  - Toucher Spectral : dégâts magiques purs. Puissance 9
  - Hurlement du Passé *(spécial)* : peur 3s + −5% stats

---

### Rang C

#### Orque Berserker
- [x] Implémenté
- **Rang** : C | **FM** : 0.4 | **Vitesse** : 100
- **Stats** : Force 14 | Défense 10 | Agilité 7 | Magie 2 | Chance 4
- **PV** : 50 + (14×2) + (10×1.5) = **93**
- **Drops** : 1× Os de berserker | 1× Cristal magique (rare)
- **Attaques** :
  - Coup de Massue. Puissance 3
  - Frénésie Sanglante *(spécial)* : +5 Force, −5 Défense pendant 15s

#### Spectre Hanté
- [x] Implémenté
- **Rang** : C | **FM** : 0.4 | **Vitesse** : 100
- **Stats** : Force 3 | Défense 7 | Agilité 12 | Magie 15 | Chance 6
- **PV** : 50 + (3×2) + (7×1.5) = **66.5**
- **Drops** : 1–2× Étoffe fantomatique | 1× Essence d'ombre (rare) | 1× Cristal magique
- **Attaques** :
  - Drain Vital : soigne 50% des dégâts infligés. Puissance 8
  - Hurlement Surnaturel *(spécial)* : peur 3s

#### Chasseur Elfe Noir
- [x] Implémenté
- **Rang** : C | **FM** : 0.45 | **Vitesse** : 130
- **Stats** : Force 10 | Défense 8 | Agilité 14 | Magie 6 | Chance 10
- **PV** : 50 + (10×2) + (8×1.5) = **82**
- **Drops** : 1–2× Baie noire | 1× Ambre | 1× Rune magique (rare)
- **Attaques** :
  - Tir Empoisonné : poison 3 dégâts/s. Puissance 8
  - Flèche Runique *(spécial)* : silence 4s. Puissance 10

---

### Rang B

#### Cyclope
- [x] Implémenté
- **Rang** : B | **FM** : 0.5 | **Vitesse** : 80
- **Stats** : Force 18 | Défense 16 | Agilité 4 | Magie 3 | Chance 5
- **PV** : 50 + (18×2) + (16×1.5) = **110**
- **Drops** : 2–4× Peau brute | 1× Œil de cyclope (rare) | 1× Cristal magique (rare)
- **Attaques** :
  - Coup Massif. Puissance 18
  - Piétinement *(spécial)* : −15% Agilité zone pendant 10s. Puissance 8

#### Chaman Corrompu
- [x] Implémenté
- **Rang** : B | **FM** : 0.35 | **Vitesse** : 100
- **Stats** : Force 5 | Défense 6 | Agilité 8 | Magie 18 | Chance 7
- **PV** : 50 + (5×2) + (6×1.5) = **69**
- **Drops** : 1–2× Essence d'ombre | 1× Totem corrompu (rare) | 1× Cristal magique
- **Attaques** :
  - Flamme Noire : brûle 5 dégâts/s pendant 5s
  - Malédiction des Ombres *(spécial)* : −5% Force & Défense pendant 15s

#### Gardien de Lave
- [x] Implémenté
- **Rang** : B | **FM** : 0.5 | **Vitesse** : 80
- **Stats** : Force 14 | Défense 14 | Agilité 3 | Magie 10 | Chance 4
- **PV** : 50 + (14×2) + (14×1.5) = **99**
- **Drops** : 2× Charbon | 1× Cœur de flamme | 1× Lingot d'acier (rare)
- **Attaques** :
  - Poing Brûlant : dégâts + brûlure 5s. Puissance 16
  - Explosion de Lave *(spécial)* : AoE feu zone, 15 dégâts + lenteur 2s

#### Basilic Caverneux
- [x] Implémenté
- **Rang** : B | **FM** : 0.55 | **Vitesse** : 100
- **Stats** : Force 12 | Défense 12 | Agilité 8 | Magie 3 | Chance 5
- **PV** : 50 + (12×2) + (12×1.5) = **92**
- **Drops** : 1× Venin | 1–2× Écaille de dragon | 1–2× Graisse animale
- **Attaques** :
  - Morsure Paralysante : chance stun 2s. Puissance 12
  - Regard Pétrifiant *(spécial)* : 10% chance geler cible 3s

---

### Rang A

#### Dragonnet de Feu
- [x] Implémenté
- **Rang** : A | **FM** : 0.5 | **Vitesse** : 150
- **Stats** : Force 12 | Défense 10 | Agilité 9 | Magie 14 | Chance 8
- **PV** : 50 + (12×2) + (10×1.5) = **89**
- **Drops** : 2–3× Écaille de dragon | 1× Viande de dragonnet | 1× Cœur de flamme (rare) | 1× Cristal magique | 1–3× Graisse animale
- **Attaques** :
  - Griffure. Puissance 14
  - Souffle Enflammé *(spécial)* : brûle 10 dégâts/s pendant 3s

#### Ent Ancien
- [x] Implémenté
- **Rang** : A | **FM** : 0.65 | **Vitesse** : 70
- **Stats** : Force 16 | Défense 18 | Agilité 4 | Magie 10 | Chance 7
- **PV** : 50 + (16×2) + (18×1.5) = **109**
- **Drops** : 2× Ambre | 2× Résine collante | 1× Bois renforcé
- **Attaques** :
  - Écrasement Racinaire : AoE physique. Puissance 16
  - Renaissance Sylvestre *(spécial)* : soigne alliés végétaux de 10%

---

### Rang S

#### Seigneur Démoniaque
- [x] Implémenté
- **Rang** : S | **FM** : 1.0 | **Vitesse** : 110
- **Stats** : Force 20 | Défense 18 | Agilité 12 | Magie 22 | Chance 15
- **PV** : 50 + (20×2) + (18×1.5) = **117**
- **Drops** : 1–2× Corne démoniaque | 1× Cœur des ténèbres (rare) | 2–3× Éclat du chaos | 1× Cristal magique | 1× Fragment d'esprit (rare)
- **Attaques** :
  - Frappe du Chaos. Puissance 20
  - Souffle Infernal *(spécial)* : zone, brûlure 15 dégâts/s pendant 4s

#### Spectre d'Oubli
- [x] Implémenté
- **Rang** : S | **FM** : 1.0 | **Vitesse** : 150
- **Stats** : Force 8 | Défense 10 | Agilité 16 | Magie 20 | Chance 12
- **PV** : 50 + (8×2) + (10×1.5) = **81**
- **Drops** : 1× Fragment d'esprit | 1× Essence d'ombre | 1× Cristal magique
- **Attaques** :
  - Drain Mental : −10% mana + dégâts magiques. Puissance 12
  - Brume de l'Oubli *(spécial)* : silence de zone 3s, chance de perte compétence temporaire. Puissance 6

---

## 6. Armes

**10 types** d'armes. Compatibilité par classe : voir §1 et §2.

- [x] Toutes dans `EquipmentLibrary`

### 6.1 Épées (Guerrier, Physique, Corps à corps)

| Nom | Rang | Attaque | Recette |
|-----|------|---------|---------|
| Épée d'entraînement | F | 5 | Bois ×2 |
| Épée du soldat | E | 10 | Lingot de fer ×3, Cuir ×1 |
| Épée longue | D | 15 | Lingot de fer ×4, Bois renforcé ×2 |
| Lame de chevalier | C | 20 | Lingot d'acier ×2, Ambre ×2, Cuir souple ×1 |
| Épée draconique | A | 25 | Lingot d'acier trempé ×2, Écailles de dragon ×2, Cœur de flamme ×1 |

### 6.2 Haches (Guerrier, Physique, Corps à corps)

| Nom | Rang | Attaque | Recette |
|-----|------|---------|---------|
| Hachette de bûcheron | F | 8 | Bois ×2, Lingot de fer ×1 |
| Hache de guerre | E | 14 | Lingot de fer ×2, Bois ×1, Cuir ×1 |
| Hache double | D | 18 | Lingot de fer ×4, Cuir tanné ×1 |
| Hache viking | C | 22 | Lingot d'acier ×3, Ambre ×1, Cuir souple ×1 |

### 6.3 Lances (Chevalier, Physique, Corps à corps)

*Débloquées uniquement par la classe avancée Chevalier.*

| Nom | Rang | Attaque | Recette |
|-----|------|---------|---------|
| Lance de chasse | F | 7 | Bois ×2, Lingot de fer ×1 |
| Pique du soldat | E | 12 | Lingot de fer ×3, Cuir ×1 |
| Lance royale | D | 17 | Lingot d'acier ×2, Ambre ×2, Cuir tanné ×1 |
| Trident de bataille | C | 20 | Lingot d'acier ×3, Essence d'ombre ×1 |
| Lance des tempêtes | A | 25 | Essence de vent ×2, Rune magique ×1, Lingot d'acier ×3 |

### 6.4 Dagues (Roublard / Assassin, Physique, Corps à corps)

| Nom | Rang | Attaque | Recette |
|-----|------|---------|---------|
| Dague de voleur | F | 5 | Lingot de fer ×1, Cuir ×1 |
| Lame de serpent | D | 10 | Lingot de fer ×2, Venin ×1 |
| Karambit | C | 12 | Lingot d'acier ×2, Cuir souple ×1 |

### 6.5 Marteaux (Berserker, Physique, Corps à corps)

*Débloqués uniquement par la classe avancée Berserker.*

| Nom | Rang | Attaque | Recette |
|-----|------|---------|---------|
| Marteau de forgeron | F | 9 | Bois brut ×2, Métal brut ×1 |
| Masse d'armes | E | 15 | Lingot de fer ×3, Cuir tanné ×1 |
| Marteau du titan | C | 20 | Lingot d'acier ×3, Os de berserker ×1 |
| Marteau des tempêtes | B | 25 | Lingot d'acier ×3, Cristaux magiques ×2 |
| Marteau du chaos | A | 27 | Lingot d'acier trempé ×2, Éclat du chaos ×1, Cristaux magiques ×1 |

### 6.6 Bâtons (Mage / Guérisseur / Invocateur, Magique, Corps à corps)

| Nom | Rang | Attaque | Recette |
|-----|------|---------|---------|
| Bâton de novice | F | 6 | Bois ×2, Cristaux magiques ×1 |
| Bâton de chêne | E | 10 | Bois ×2, Rune magique ×1 |
| Bâton magique | D | 14 | Bois renforcé ×2, Cristaux magiques ×2 |
| Bâton du sage | B | 18 | Bois renforcé ×3, Rune magique ×1 |

### 6.7 Arcs (Chasseur / Assassin / Archer Mystique, Physique, Distance)

| Nom | Rang | Attaque | Recette |
|-----|------|---------|---------|
| Arc court | F | 7 | Bois ×2, Corde ×1 |
| Arc de chasseur | E | 12 | Bois ×3, Cuir tanné ×1, Corde ×1 |
| Arc long | D | 17 | Bois renforcé ×3, Corde ×1 |
| Arc elfique | B | 22 | Bois renforcé ×2, Ambre ×1, Rune magique ×1, Corde ×1 |

### 6.8 Orbes (Sage Arcanique / Maître des Éléments / Conjurateur, Magique, Distance)

*Débloqués uniquement par certaines classes avancées.*

| Nom | Rang | Attaque | Recette |
|-----|------|---------|---------|
| Orbe de cristal | F | 6 | Verre ×1, Cristaux magiques ×1 |
| Orbe des éléments | E | 10 | Verre ×2, Rune magique ×1 |
| Orbe de mana | D | 14 | Verre ×2, Cristaux magiques ×2, Ambre ×1 |
| Orbe runique | B | 18 | Verre ×2, Rune magique ×2 |

### 6.9 Grimoires (Mage / Invocateur / Prêtre, Magique, Distance)

| Nom | Rang | Attaque | Recette |
|-----|------|---------|---------|
| Grimoire de novice | F | 5 | Cuir ×2, Baie noire ×1 |
| Grimoire des ombres | E | 9 | Cuir ×2, Cristaux magiques ×1, Baie noire ×1 |
| Grimoire des arcanes | D | 13 | Cuir tanné ×3, Rune magique ×2 |
| Grimoire de l'archimage | A | 17 | Cuir souple ×3, Baie noire ×2, Cristaux magiques ×2 |

### 6.10 Shurikens (Ombre, Physique, Distance)

*Débloqués uniquement par la classe avancée Ombre.*

| Nom | Rang | Attaque | Recette |
|-----|------|---------|---------|
| Shuriken simple | F | 4 | Lingot de fer ×1 |
| Shuriken tranchant | E | 6 | Lingot de fer ×2 |
| Étoile de lancer | D | 8 | Lingot d'acier ×3 |
| Shuriken empoisonné | C | 10 | Lingot d'acier ×2, Venin ×1 |

---

## 7. Armures

- [x] Toutes dans `EquipmentLibrary`

### 7.1 Armures Légères (Mage, Guérisseur, Invocateur + classes avancées légères)

**Tête**

| Nom | Rang | Défense | Recette |
|-----|------|---------|---------|
| Capuche en lin | F | 2 | Tissu ×2 |
| Chapeau de paille | F | 1 | Tissu ×1 |
| Capuche matelassée | E | 4 | Tissu ×2 |
| Chapeau d'acolyte | E | 3 | Tissu ×2, Cristaux magiques ×1 |
| Chapeau de druide | E | 4 | Tissu ×2, Essence de vent ×1 |
| Chapeau mystique | D | 5 | Tissu ×2, Cristaux magiques ×1, Rune magique ×1 |

**Torse**

| Nom | Rang | Défense | Recette |
|-----|------|---------|---------|
| Robe de l'apprenti | F | 3 | Tissu ×3 |
| Robe de magicien | E | 5 | Tissu ×3, Cristaux magiques ×1 |
| Robe des éléments | D | 6 | Tissu renforcé ×2, Essence de vent ×1, Cristaux magiques ×1 |
| Robe des arcanes | C | 7 | Tissu renforcé ×3, Rune magique ×1, Cristaux magiques ×2 |
| Tunique d'ombre | B | 8 | Tissu renforcé ×2, Essence d'ombre ×1, Baie noire ×1 |

**Jambes**

| Nom | Rang | Défense | Recette |
|-----|------|---------|---------|
| Pantalon de lin | F | 2 | Tissu ×2 |
| Pantalon enchanté | E | 4 | Tissu ×2, Cristaux magiques ×1 |
| Jambières de mage | D | 5 | Tissu ×2, Cristaux magiques ×1 |

---

### 7.2 Armures Moyennes (Roublard, Chasseur + classes avancées moyennes)

**Tête**

| Nom | Rang | Défense | Recette |
|-----|------|---------|---------|
| Casque de patrouilleur | E | 6 | Cuir tanné ×2, Rivets en acier ×1 |
| Casque de chasseur | D | 8 | Cuir tanné ×2, Lingot de fer ×1 |
| Casque d'éclaireur | C | 10 | Cuir souple ×1, Lingot d'acier ×1, Essence de vent ×1 |

**Torse**

| Nom | Rang | Défense | Recette |
|-----|------|---------|---------|
| Armure de rôdeur | E | 8 | Cuir tanné ×3, Rivets en acier ×2 |
| Armure de mercenaire | D | 10 | Cuir tanné ×3, Lingot de fer ×2 |
| Armure de l'éclaireur | C | 12 | Cuir ×2, Lingot d'acier ×2, Essence de vent ×1 |
| Armure des ombres | C | 11 | Cuir ×2, Essence d'ombre ×1, Tissu renforcé ×1 |

**Jambes**

| Nom | Rang | Défense | Recette |
|-----|------|---------|---------|
| Jambières du rôdeur | E | 6 | Cuir tanné ×2, Rivets en acier ×1, Baie noire ×1 |
| Jambières de mercenaire | D | 8 | Cuir tanné ×3, Lingot de fer ×1 |
| Jambières de l'éclaireur | C | 10 | Cuir souple ×2, Lingot d'acier ×1, Essence de vent ×1 |

---

### 7.3 Armures Lourdes (Guerrier + classes avancées lourdes)

**Tête**

| Nom | Rang | Défense | Recette |
|-----|------|---------|---------|
| Heaume de soldat | E | 12 | Lingot de fer ×3, Rivets en acier ×2 |
| Casque de chevalier | D | 15 | Lingot d'acier ×2, Cuir tanné ×1, Rivets en acier ×2 |
| Casque des Highlands | A | 16 | Lingot d'acier ×3, Cuir souple ×1, Essence de vent ×1 |
| Heaume du conquérant | S | 18 | Lingot d'acier trempé ×2, Rivets en acier ×3, Œil de cyclope ×1 |

**Torse**

| Nom | Rang | Défense | Recette |
|-----|------|---------|---------|
| Cuirasse de soldat | E | 15 | Lingot de fer ×3, Cuir ×2, Rivets en acier ×2 |
| Armure de chevalier | D | 18 | Lingot d'acier ×3, Rivets en acier ×2, Cuir ×1 |
| Armure de guerre | B | 20 | Lingot d'acier trempé ×3, Rivets en acier ×2, Os de berserker ×1 |
| Plastron volcan | A | 20 | Lingot d'acier trempé ×3, Charbon ×2, Cœur de flamme ×1 |
| Armure de bataille | S | 22 | Lingot d'acier trempé ×2, Rivets en acier ×3, Cuir souple ×1, Cœur de flamme ×1 |

**Jambes**

| Nom | Rang | Défense | Recette |
|-----|------|---------|---------|
| Grèves de soldat | E | 12 | Lingot de fer ×2, Cuir tanné ×1, Rivets en acier ×1 |
| Jambières de chevalier | D | 15 | Lingot d'acier ×2, Cuir tanné ×1, Rivets en acier ×2 |
| Jambières de bataille | B | 18 | Lingot d'acier ×2, Lingot d'acier trempé ×1, Os de berserker ×1 |

---

## 8. Accessoires

- [x] Tous dans `EquipmentLibrary`

### 8.1 Anneaux

| Nom | Rang | Effet | Recette |
|-----|------|-------|---------|
| Anneau de fer | F | — | Lingot de fer ×1 |
| Anneau de force | D | +5 Force | Lingot d'acier ×1, Ambre ×1 |
| Anneau de vivacité | C | +5 Agilité | Lingot d'acier ×1, Ambre ×1 |
| Anneau du mage | C | +8 Magie | Lingot d'acier ×1, Cristaux magiques ×1 |
| Anneau de vitalité | C | +25 HP | Lingot d'acier ×1, Plante médicinale ×1, Cristaux magiques ×1 |

### 8.2 Amulettes

| Nom | Rang | Effet | Recette |
|-----|------|-------|---------|
| Amulette en bois | F | — | Bois ×1 |
| Amulette de soin | D | Régénération lente PV | Lingot d'acier ×1, Plante médicinale ×1 |
| Amulette de feu | C | Résistance au feu | Lingot d'acier ×1, Cristaux magiques ×1 |
| Amulette des anciens | B | +10% mana | Lingot d'acier ×1, Rune magique ×1 |
| Amulette runique | B | +25 mana | Lingot d'acier ×1, Rune magique ×2 |

---

## 9. Potions et Consommables

- [x] Toutes dans `EquipmentLibrary`

### 9.1 Potions de Soins

| Nom | Effet | Recette |
|-----|-------|---------|
| Potion de soin mineur | +50 PV instantanément | Eau ×1, Plante médicinale ×1 |
| Potion de soin | +100 PV instantanément | Eau ×1, Plante médicinale ×2 |
| Potion de soin majeure | +200 PV instantanément | Eau ×2, Plante médicinale ×3, Cristaux magiques ×1 |

### 9.2 Potions Magiques

| Nom | Effet | Recette |
|-----|-------|---------|
| Potion de mana mineur | +50 Mana | Eau ×1, Cristaux magiques ×1 |
| Potion de mana | +100 Mana | Eau ×1, Cristaux magiques ×2 |
| Potion de mana supérieure | +200 Mana | Eau ×1, Cristaux magiques ×3 |

### 9.3 Potions Défensives

| Nom | Effet | Recette |
|-----|-------|---------|
| Potion de pierre | +20 END pendant 20s | Eau ×1, Essence d'ombre ×1 |
| Potion de résistance au feu | −50% dégâts feu pendant 30s | Eau ×1, Cœur de flamme ×1, Cristaux magiques ×1 |
| Potion d'ombre protectrice | −30% dégâts magiques pendant 30s | Eau ×1, Essence d'ombre ×1, Rune magique ×1 |

### 9.4 Potions Offensives / Buffs

| Nom | Effet | Recette |
|-----|-------|---------|
| Potion de force brute | +10 Force pendant 30s | Eau ×1, Os de berserker ×1 |
| Potion de précision | +15% critique pendant 30s | Eau ×1, Dent de gobelin ×2 |
| Potion de vitesse | +30% Agilité pendant 15s | Eau ×1, Essence de vent ×1, Cristaux magiques ×1 |
| Potion de poison | Arme empoisonnée (3 coups) | Venin ×1, Baies noires ×1, Eau ×1 |
| Potion de canalisation | +20% dégâts magiques pendant 20s | Eau ×1, Essence de vent ×1, Rune magique ×1 |

### 9.5 Potions Spéciales / Rares

| Nom | Effet | Recette |
|-----|-------|---------|
| Potion d'invisibilité | Invisibilité 10s | Eau ×1, Essence d'ombre ×1, Cristaux magiques ×1 |
| Potion de rage berserk | +25 Force, −20% Défense pendant 15s | Huile de bœuf ×1, Os de berserker ×1, Baies noires ×1 |
| Potion du chaos | Effet aléatoire buffs ou debuffs extrêmes | Éclat du chaos ×1, Rune magique ×1, Cristaux magiques ×2 |
| Potion de purification | Supprime poison, brûlure, saignement, malus | Eau ×2, Plante médicinale ×2, Essence d'ombre ×1 |

---

## 10. Enchantements

**18 enchantements** (C→S). Irréversibles, 1 max par arme/armure. Doivent être recherchés avant utilisation.

- [x] Tous dans `EnchantmentLibrary`

### Rang C (5 enchantements)

| Nom | Type | Effet | Recherche | Coût |
|-----|------|-------|-----------|------|
| Igni | Arme | +6 dégâts feu, 20% brûlure sur 3s | 3 jours | 5 Cristaux Magiques |
| Bouclier de Givre | Armure | −10% dégâts reçus, +5% résistance feu | 4 jours | 7 Cristaux Magiques |
| Cape de l'Ombre | Armure | +10% Agilité, +5% esquive | 3 jours | 7 Cristaux Magiques |
| Aura de Célérité | Armure | +10% vitesse, −5% temps attaque | 3 jours | 5 Cristaux Magiques |
| Tranchant Raffiné | Arme | +5% chance critique | 2.5 jours | 4 Cristaux Magiques |

### Rang B (5 enchantements)

| Nom | Type | Effet | Recherche | Coût |
|-----|------|-------|-----------|------|
| Lame de Foudre | Arme | +8 dégâts foudre, 10% paralysie 1.5s | 4 jours | 6 Cristaux Magiques |
| Lumière Purifiante | Armure | Immunité poison/saignement, +2 PV/s | 4 jours | 8 Cristaux Magiques |
| Griffes Spectrales | Arme | +5 dégâts ombre, 10% ignore armure | 3 jours | 6 Cristaux Magiques |
| Rune du Titan | Armure | +15% défense physique, +10% poids max | 5 jours | 9 Cristaux Magiques |
| Sceau des Arcanes | Bijou | +10% puissance magique, +10 mana max | 4 jours | 8 Cristaux Magiques |

### Rang A (4 enchantements)

| Nom | Type | Effet | Recherche | Coût |
|-----|------|-------|-----------|------|
| Bénédiction du Gardien | Armure | 10% dégâts redirigés vers soi, +3% armure magique | 5 jours | 9 Cristaux Magiques |
| Toucher Vampirique | Arme | Vol de vie : +3% dégâts infligés → PV | 5 jours | 10 Cristaux Magiques |
| Aura de Vaillance | Bijou | +8% Force, immunité peur | 5 jours | 9 Cristaux Magiques |
| Réflexe Surnaturel | Armure | 15% chance esquive automatique (CD 2 tours) | 5 jours | 9 Cristaux Magiques |

### Rang S (4 enchantements)

| Nom | Type | Effet | Recherche | Coût |
|-----|------|-------|-----------|------|
| Voile du Néant | Armure | 20% chance d'éviter toute attaque | 6 jours | 10 Cristaux + 1 Essence d'Ombre |
| Lame du Chaos | Arme | +10 dégâts aléatoires (type aléatoire), 5% confusion | 6 jours | 12 Cristaux + 1 Éclat du Chaos |
| Aura d'Ascension | Bijou | +10% toutes stats principales, bonus moral constant | 7 jours | 12 Cristaux + 1 Fragment d'Esprit |
| Égide Totale | Armure | −25% dégâts, +10% résistance magie, −10% vitesse | 6 jours | 11 Cristaux + 1 Écaille de Dragon |

---

## 11. Matériaux et Ressources

- [x] Tous dans `MaterialLibrary`

### 11.1 Ressources Naturelles

| Ressource | Valeur | Obtention |
|-----------|--------|-----------|
| Bois | 2 | Récolte forêt, Achat |
| Pierre | 3 | Récolte montagne, Achat |
| Lin | 2 | Culture, Achat |
| Eau | 1 | Puits, Achat |
| Sel | 1 | Récolte, Achat |
| Baie noire | 1 | Culture, Achat |
| Plante médicinale | 3 | Culture, Achat |
| Ambre | 11 | Récolte, Achat |
| Résine collante | 5 | Récolte, Achat |
| Métal brut | 3 | Récolte, Achat |
| Graisse animale | 3 | Loot (loup, vipère, cyclope…) |
| Peau brute | 3 | Loot (loup, sanglier, cyclope) |
| Sable | 2 | Récolte, Achat |

### 11.2 Matériaux Artisanaux (Craftables)

| Ressource | Valeur | Recette | Lieu | Durée |
|-----------|--------|---------|------|-------|
| Corde | 3 | Lin ×3 | Atelier | 1h |
| Fil résistant | 4 | Lin ×2, Résine ×1 | Atelier | 2h |
| Tissu | 3 | Lin ×2 | Métier à tisser | 1h |
| Tissu renforcé | 3 | Tissu ×1, Fil résistant ×1 | Métier à tisser | 2h |
| Cuir | 3 | Peau brute ×1, Eau ×1 | Atelier de tannage | 1h |
| Cuir tanné | 5 | Cuir ×2, Sel ×1, Eau ×1 | Atelier de tannage | 2h |
| Cuir souple | 8 | Cuir tanné ×2, Huile de bœuf ×1 | Atelier de tannage | 3h |
| Lingot de fer | 4 | Métal brut ×2 | Forge | 2h |
| Lingot d'acier | 6 | Métal brut ×3, Charbon ×1 | Forge | 3h |
| Lingot d'acier trempé | 9 | Lingot d'acier ×2, Huile de trempe ×1, Résine ×1, Eau ×1 | Forge | 4h |
| Rivets en acier | 3 | Métal brut ×1 | Forge | 1h |
| Charbon | 3 | Bois ×2 | Forge | 1h |
| Verre | 3 | Sable ×2, Charbon ×1 | Forge | 2h |
| Bois renforcé | 15 | Bois ×2, Résine ×1 | Atelier | 2h |
| Huile de bœuf | 4 | Graisse animale ×2, Plante médicinale ×1 | Table d'alchimie | 2h |
| Huile de trempe | 7 | Huile de bœuf ×1, Résine ×1, Eau ×1 | Table d'alchimie | 3h |
| Essence de vent | 12 | Cristaux magiques ×2, Gelée de slime ×1 | Table d'alchimie | 4h |
| Rune magique | 15 | Cristaux magiques ×1, Baie noire ×1, Étoffe fantomatique ×1 | Table d'alchimie | 5h |
| Farine de lin | 3 | Lin ×2 | Fourneau | — |

### 11.3 Matériaux Magiques & Rares

| Ressource | Valeur | Source |
|-----------|--------|--------|
| Cristaux magiques | 8 | Loot tous les mobs (commun) |
| Essence d'ombre | 15 | Drop Spectre (rare), Esprit des ruines, Chaman corrompu |
| Étoffe fantomatique | 9 | Drop Spectre Hanté, Esprit des ruines |
| Fragment d'esprit | 25 | Drop Seigneur démoniaque (rare), Spectre d'oubli |

### 11.4 Composants de Monstres

| Ressource | Valeur | Source |
|-----------|--------|--------|
| Gelée de slime | 2 | Slime |
| Dent de gobelin | 3 | Gobelin |
| Os de berserker | 6 | Orque Berserker |
| Venin | 5 | Vipère, Basilic caverneux, Araignée sylvestre |
| Écaille de dragon | 10 | Dragonnet, Basilic caverneux |
| Cœur de flamme | 15 | Dragonnet (rare), Gardien de lave |
| Corne démoniaque | 18 | Seigneur démoniaque (trophée, à vendre) |
| Éclat du chaos | 20 | Seigneur démoniaque |
| Œil de cyclope | — | Cyclope (rare) |
| Totem corrompu | — | Chaman corrompu (rare) |
| Cœur des ténèbres | — | Seigneur démoniaque (rare) |

### 11.5 Ingrédients Culinaires

| Ressource | Valeur | Obtention |
|-----------|--------|-----------|
| Œuf | 3 | Ferme (poules) / Marchand |
| Viande de loup | 6 | Loot Loup |
| Viande de gobelin | 5 | Loot Gobelin |
| Viande de vipère | 6 | Loot Vipère |
| Viande de sanglier | 15 | Loot Sanglier |
| Viande de dragon | 15 | Loot Dragonnet (rare) |
| Carotte | 4 | Jardin / Ferme |
| Champignons | 5 | Récolte forêt / caverne |
| Piment noir | 8 | Zone volcanique / Achat |
| Herbes sauvages | 4 | Récolte forêt / plaine |
| Herbes rares | 10 | Jardin magique / Chaman corrompu |
| Farine de lin | 3 | Lin ×2 (Four) |
| Miel | 2 | Ruche |
| Houblon | 1 | Culture |

---

## 12. Plats et Fermentés

### 12.1 Plats Simples

- [x] Dans `DishLibrary`

| Nom | Recette | Satiété | Effet |
|-----|---------|---------|-------|
| Pain de lin | Farine de lin ×2, Eau ×1 | 20 | Aucun |
| Soupe claire | Eau ×1, Champignon ×1 | 15 | +5 PV |
| Omelette aux herbes | Œuf ×2, Herbes sauvages ×1 | 25 | +5 énergie |

### 12.2 Plats Nourrissants

- [x] Dans `DishLibrary`

| Nom | Recette | Satiété | Effet |
|-----|---------|---------|-------|
| Ragoût de loup | Viande de loup ×2, Carotte ×1, Eau ×1 | 40 | +10 Défense pendant 60s |
| Brochette forestière | Viande ×1, Champignons ×2, Sel ×1 | 35 | +5 Agilité pendant 30s |
| Curry de gobelin | Viande de gobelin ×1, Piment noir ×1, Eau ×1 | 45 | +10 Force pendant 30s |
| Tartine aux baies noires | Pain ×1, Baies noires ×3 | 30 | +5 moral, soigne stress |

### 12.3 Plats Exotiques

- [x] Dans `DishLibrary`

| Nom | Recette | Satiété | Effet |
|-----|---------|---------|-------|
| Soupe spectrale | Étoffe fantomatique ×1, Eau ×2, Champignons ×2 | 35 | +10 Magie pendant 60s |
| Tartare de vipère | Viande de vipère ×1, Herbes ×1, Sel ×1, Huile de bœuf ×1 | 40 | Immunité poison 60s |
| Filet de dragon grillé | Viande de dragon ×1, Cœur de flamme ×1, Herbes rares ×1 | 50 | +25% dégâts pendant 60s |
| Tourte de mana | Farine ×2, Œuf ×1, Cristaux magiques ×1, Sel ×1 | 30 | +30 mana instant, +10 mana/30s |

### 12.4 Préparations Fermentées

- [ ] Non implémenté (stub — logique de fermentation à écrire)

| Nom | Recette | Durée fermentation |
|-----|---------|-------------------|
| Bière | Houblon ×3 | 3 jours in-game |
| Hydromel | Miel ×3 | 5 jours in-game |

---

## 13. Cultures

**8 plantes** cultivables dans le Jardin (recherche "Jardin Botanique" requise).

- [x] Toutes dans `FarmingManager`

| Plante | Utilité principale | Temps de pousse |
|--------|-------------------|-----------------|
| Lin | Artisanat textile (tissu, corde, farine) | 2.5 jours |
| Carotte | Cuisine (plats simples, ragoûts) | 3 jours |
| Champignons | Cuisine + Alchimie | 2 jours |
| Baies noires | Teinture noire, cuisine, potions | 3 jours |
| Piment noir | Cuisine | 4 jours |
| Herbes sauvages | Cuisine de base, potions mineures | 2 jours |
| Herbes rares | Alchimie avancée, potions puissantes | 5 jours |
| Plante médicinale | Base des potions de soin | 3 jours |

---

## 14. Recherches

**39 recherches** sur 10 niveaux. Durée en heures in-game, coût en or.

- [x] Toutes dans `ResearchLibrary`

### Niveau 1

| Recherche | Description | Débloque | Coût |
|-----------|-------------|----------|------|
| Forge basique | Permet la forge des objets de rang F | Salle forge, forge, enclume, plan F+E, plan charbon, verre | 200 or |
| Couture rudimentaire | Création d'équipements tissu/cuir rang F | Salle couture, métier à tisser, chevalet de tannage, plan F+E, plan tissu | 150 or |
| Artisanat général | Atelier de craft pour matériaux simples | Salle atelier (sauf recyclage), plan matériaux craftables via atelier | 150 or |
| Recyclage primaire | Recyclage partiel 25% | Atelier de recyclage, fonction recyclage 25% | 100 or |

### Niveau 2

| Recherche | Prérequis | Débloque | Coût |
|-----------|-----------|----------|------|
| Entraînement Martial | Forge basique | Salle d'entraînement + tous objets physiques | 600 or |
| Entraînement Magique | Couture rudimentaire | Salle Arcanum, bureau enchanté, lutrin | 600 or |
| Alchimie basique | Artisanat général | Établi d'alchimie, objets liés, potions T1 (mineur) | 300 or |
| Menuiserie | Artisanat général | Table en bois avec chaise, placard personnel, étagère | 400 or |

### Niveau 3

| Recherche | Prérequis | Débloque | Coût |
|-----------|-----------|----------|------|
| Forge avancée (D) | Entraînement martial | Plan rang D, soufflet, plan lingot de fer | 400 or |
| Tissage renforcé (D) | Entraînement magique | Plan rang D, rouet, plan tissu renforcé | 350 or |
| Ameublement | Menuiserie | Cloche réception, coffre à outils, globe runique, lutrin, plan de travail, évier rustique | 400 or |
| Médecine | Alchimie basique | Salle infirmerie + objets liés | 500 or |
| Esthétique | Ameublement | Statue de héros, fontaine décorative, tapis royal rouge, tapis décoratif | 50 or |

### Niveau 4

| Recherche | Prérequis | Débloque | Coût |
|-----------|-----------|----------|------|
| Forge de maître (C) | Forge avancée | Plan rang C, râtelier d'outils, plan lingot d'acier, huile de bœuf | 800 or |
| Armurier agile (C) | Tissage renforcé | Plan rang C, chevalet de tannage, plan cuir | 800 or |
| Joaillerie | Forge avancée + Tissage renforcé | Craft anneaux et amulettes | 1 200 or |
| Jardin Botanique | Médecine | Plates-bandes, compost, arrosoir magique, accès graines à l'achat | 700 or |
| Divertissement | Ameublement | Plateau d'échecs, table de jeu | 800 or |

### Niveau 5

| Recherche | Prérequis | Débloque | Coût |
|-----------|-----------|----------|------|
| Enchantement | Forge de maître + Armurier agile | Fonctionnalité enchantement (recherche + application), autel d'enchantement, enchantements rang C | 1 000 or |
| Alchimie avancée | Jardin Botanique | Potions T2 + chaudron magique | 1 000 or |
| Recyclage avancé (50%) | Économie commerciale | Recyclage 50% des équipements | 800 or |
| Économie commerciale | Médecine | Accès au marché (achat / vente) | 650 or |
| Brassage | Jardin Botanique | Baril de fermentation, recettes bière + hydromel | 950 or |

### Niveau 6

| Recherche | Prérequis | Débloque | Coût |
|-----------|-----------|----------|------|
| Forge haute qualité (B) | Enchantement | Plan rang B, bibliothèque de schémas, lingot d'acier trempé, rivets en acier | 2 000 or |
| Tannage avancé (B) | Enchantement | Plan rang B, armoire à tissus, plan cuir tanné + cuir souple | 2 000 or |
| Enchantement avancé | Enchantement | Débloque enchantements rang B | 1 500 or |
| Alchimiste expérimenté | Alchimie avancée | Potions offensives / défensives | 1 500 or |
| Agriculture avancée | Alchimie avancée | Arrosoir magique, bac de compost | 1 500 or |

### Niveau 7

| Recherche | Prérequis | Débloque | Coût |
|-----------|-----------|----------|------|
| Enchantement expert | Enchantement avancé | Enchantements rang A | 2 000 or |
| Salle d'Ascension | Forge haute qualité + Tannage avancé | Fonction évolution des héros, autel d'évolution, reliques anciennes, tapis de cérémonie | 1 800 or |
| Systèmes de Soins Innovants | Alchimiste expérimenté | Améliore soins infirmerie +25% efficacité | 2 100 or |

### Niveau 8

| Recherche | Prérequis | Débloque | Coût |
|-----------|-----------|----------|------|
| Forge d'Armes Légendaires (A) | Salle d'Ascension | Plans rang A (armes et armures métal) | 2 500 or |
| Confection d'Armures Élites (A) | Salle d'Ascension | Plans rang A (armures cuir/tissu) | 2 500 or |
| Alchimiste expert | Systèmes de Soins Innovants | Accès potions rares | 2 000 or |

### Niveau 9

| Recherche | Prérequis | Débloque | Coût |
|-----------|-----------|----------|------|
| Maîtrise de l'Enchantement (Bijoux) | Forge légendaire + Confection élite | Enchantement sur anneaux et amulettes | 3 000 or |
| Stratégie de Guerre Avancée | Forge légendaire + Confection élite | +10% dégâts passif pour tous les héros en combat | 2 800 or |
| Recyclage Intégral (100%) | Alchimiste expert | Récupération totale des ressources d'un équipement recyclé | 3 000 or |

### Niveau 10

| Recherche | Prérequis | Débloque | Coût |
|-----------|-----------|----------|------|
| Forgeron Légendaire (S) | Stratégie de Guerre Avancée | Plans rang S (armes et armures métal) | 3 500 or |
| Couturier Légendaire (S) | Stratégie de Guerre Avancée | Plans rang S (armures cuir/tissu) | 3 500 or |

---

## 15. Constructions par Salle

- [x] Toutes dans `ItemRegistry`

### Murs / Sols / Portes

| Type | Coût |
|------|------|
| Mur de bois | 10 or/case |
| Mur de pierre | 15 or/case |
| Sol de bois | 10 or/case |
| Sol de pierre | 15 or/case |
| Gravier | 8 or/case |
| Porte en bois | 20 or/u |
| Porte renforcée | 25 or/u |

---

### Hall

| Nom | Description | Prix | Débloquer |
|-----|-------------|------|-----------|
| Tableau des quêtes | Affiche les quêtes disponibles | 150 or | De base |
| Comptoir de réception | Accueil et recrutement | 200 or | De base |
| Self | Contient les repas préparés | 50 or | De base |
| Instrument de musique | Détente musicale (harpe, lyre…) | 60 or | De base |
| Chandelier / torche | Lumière nocturne | 30 or | De base |
| Table en bois avec chaise | Grande table repas / réunion | 75 or | Menuiserie |
| Baril de boisson | +moral à la consommation | 50 or | Brassage |
| Cloche de réception | Signale les visiteurs | 20 or | Ameublement |

### Chambre

| Nom | Description | Prix | Débloquer |
|-----|-------------|------|-----------|
| Lit simple | Repos profond | 120 or | De base |
| Placard personnel | Stockage objets personnels | 60 or | Menuiserie |
| Étagère | Stockage grimoires, souvenirs | 40 or | Menuiserie |

### Forge

| Nom | Description | Prix | Débloquer |
|-----|-------------|------|-----------|
| Forge | Chauffe les métaux, craft | 300 or | Forge basique |
| Enclume | Forge les équipements, craft | 180 or | Forge basique |
| Soufflet | Accélère le chauffage, amélioration | 100 or | Forge avancée |
| Râtelier à outils | Décoration | 80 or | Forge de maître |
| Bibliothèque de schémas | Décoration | 60 or | Forge haute qualité |

### Salle de Couture

| Nom | Description | Prix | Débloquer |
|-----|-------------|------|-----------|
| Métier à tisser | Produit du tissu, craft | 120 or | Couture rudimentaire |
| Table de travail | Confection vêtements/armures tissu, craft | 75 or | Couture rudimentaire |
| Chevalet de tannage | Tanne le cuir, craft | 90 or | Armurier agile |
| Armoire à tissus | Stockage tissus, décoration | 60 or | Tannage avancé |
| Rouet | Améliore le métier à tisser | 100 or | Tissage renforcé |
| Mannequin | Décoration | — | Armurier agile |

### Atelier

| Nom | Description | Prix | Débloquer |
|-----|-------------|------|-----------|
| Établi de craft | Craft polyvalent | 140 or | Artisanat général |
| Atelier de recyclage | Recycle armes et armures | 100 or | Recyclage primaire |
| Coffre à outils | Décoration | 65 or | Ameublement |

### Infirmerie

| Nom | Description | Prix | Débloquer |
|-----|-------------|------|-----------|
| Lit médical | Repos des blessés | 130 or | Médecine |
| Bureau médical | Diagnostics, décoration | 80 or | Médecine |
| Table d'examen | Traitement des blessures | 90 or | Systèmes de Soins Innovants |

### Salle d'Entraînement

| Nom | Description | Prix | Débloquer |
|-----|-------------|------|-----------|
| Mannequin de combat | +FOR +DEF | 120 or | Entraînement martial |
| Poids / haltères | +FOR | 70 or | Entraînement martial |
| Cible en bois | +AGI | 60 or | Entraînement martial |
| Sacs de sable | +DEF | 50 or | Entraînement martial |

### Atelier d'Alchimie

| Nom | Description | Prix | Débloquer |
|-----|-------------|------|-----------|
| Établi d'alchimie | Préparations magiques, craft | 160 or | Alchimie basique |
| Chaudron magique | Potions complexes + accélère craft, amélioration | 120 or | Alchimie avancée |

### Arcanum

| Nom | Description | Prix | Débloquer |
|-----|-------------|------|-----------|
| Bureau enchanté | Entraînement magique +MAG | 120 or | Entraînement magique |
| Autel d'enchantement | Recherche et application enchantements, craft | 50 or | Enchantement |
| Globe runique | Décoration | 80 or | Ameublement |
| Lutrin | Décoration | 25 or | Ameublement |

### Jardin

| Nom | Description | Prix | Débloquer |
|-----|-------------|------|-----------|
| Plates-bandes | Zones de culture | 50 or | Jardin Botanique |
| Bac de compost | Améliore productivité | 60 or | Agriculture avancée |
| Arrosoir magique | Réduit le temps de pousse, amélioration | 80 or | Agriculture avancée |

### Salle d'Ascension

| Nom | Description | Prix | Débloquer |
|-----|-------------|------|-----------|
| Autel d'évolution | Déclenche l'ascension des classes | 200 or | Salle d'Ascension |
| Reliques anciennes | Éveil de classe, décoration | 120 or | Salle d'Ascension |
| Tapis de cérémonie | Atmosphère mystique, décoration | 50 or | Salle d'Ascension |

### Salle de Loisirs

| Nom | Description | Prix | Débloquer |
|-----|-------------|------|-----------|
| Plateau d'échecs | Divertissement stratégique | 70 or | Divertissement |
| Table de jeu | Cartes, dés… | 50 or | Divertissement |
| Instrument de musique | Harpe, lyre, tambour | 60 or | De base |

### Sanitaires

| Nom | Description | Prix | Débloquer |
|-----|-------------|------|-----------|
| Latrines | Hygiène de base | 40 or | De base |
| Lave-mains | Lavage des mains | 25 or | De base |

### Cuisine

| Nom | Description | Prix | Débloquer |
|-----|-------------|------|-----------|
| Fourneau | Cuisson de tous les plats, craft | 150 or | De base |
| Plan de travail | Découpe et assemblage, décoration | 80 or | Ameublement |
| Évier rustique | Lavage aliments, bonus hygiène | 90 or | Ameublement |
| Baril de fermentation | Hydromel et bière, interface dédiée | 120 or | Brassage |

### Salle Décorative

| Nom | Description | Prix | Débloquer |
|-----|-------------|------|-----------|
| Statue de héros | Décoration | 150 or | Esthétique |
| Fontaine décorative | Décoration centrale | 120 or | Esthétique |
| Tapis rouge royal | Prestige | 80 or | Esthétique |
| Tapis décoratif | Confort | 35 or | Esthétique |
| Chandelier / torche | Lumière nocturne | 30 or | De base |
