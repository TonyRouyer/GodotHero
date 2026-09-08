## Contenu du Jeu — Listes Exhaustives

> Suivi de l'implémentation du contenu. Chaque item est ajouté au fur et à mesure de son implémentation.
> Fichiers associés : [`../readme.md`](../readme.md) | [`gamedesign.md`](gamedesign.md) | [`backlog.md`](backlog.md)

**Légende** : `- [x]` = implémenté | `- [ ]` = prévu, non implémenté

---

## Table des matières

1. [Classes de Base](#1-classes-de-base)
2. [Classes Avancées](#2-classes-avancées)
3. [Compétences par Classe](#3-compétences-par-classe)
4. [Traits de Caractère](#4-traits-de-caractère)
5. [Mobs](#5-mobs)
6. [Armes](#6-armes)
7. [Armures](#7-armures)
8. [Accessoires](#8-accessoires)
9. [Potions et Consommables](#9-potions-et-consommables)
10. [Enchantements](#10-enchantements)
11. [Matériaux et Ressources](#11-matériaux-et-ressources)
12. [Plats et Fermentés](#12-plats-et-fermentés)
13. [Cultures](#13-cultures)
14. [Recherches (39)](#14-recherches-39)
15. [Constructions par Salle](#15-constructions-par-salle)

---

## 1. Classes de Base

### 1.1 Guerrier (Physique)

- [x] Guerrier — `HeroClassRegistry`

**Armes** : Épée, Hache | **Armure** : Lourde

| Stat | Intervalle génération |
|------|----------------------|
| Force | 10 – 14 |
| Défense | 10 – 14 |
| Agilité | 5 – 9 |
| Magie | 3 – 7 |
| Chance | 5 – 10 |

### 1.2 Mage (Magique)

- [x] Mage — `HeroClassRegistry`

**Armes** : Bâton, Grimoire | **Armure** : Légère

| Stat | Intervalle génération |
|------|----------------------|
| Force | 3 – 7 |
| Défense | 4 – 8 |
| Agilité | 6 – 10 |
| Magie | 12 – 16 |
| Chance | 8 – 12 |

### 1.3 Roublard (Physique)

- [ ] Roublard — `HeroClassRegistry`

**Armes** : Dague | **Armure** : Moyenne

| Stat | Intervalle génération |
|------|----------------------|
| Force | 6 – 10 |
| Défense | 3 – 7 |
| Agilité | 12 – 16 |
| Magie | 5 – 9 |
| Chance | 10 – 14 |

### 1.4 Chasseur (Physique)

- [ ] Chasseur — `HeroClassRegistry`

**Armes** : Arc | **Armure** : Moyenne

| Stat | Intervalle génération |
|------|----------------------|
| Force | 7 – 11 |
| Défense | 7 – 11 |
| Agilité | 11 – 15 |
| Magie | 4 – 8 |
| Chance | 8 – 12 |

### 1.5 Guérisseur (Magique)

- [ ] Guérisseur — `HeroClassRegistry`

**Armes** : Bâton | **Armure** : Légère

| Stat | Intervalle génération |
|------|----------------------|
| Force | 4 – 8 |
| Défense | 6 – 10 |
| Agilité | 6 – 10 |
| Magie | 11 – 15 |
| Chance | 10 – 14 |

### 1.6 Invocateur (Magique)

- [ ] Invocateur — `HeroClassRegistry`

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

> Accessibles niveau 50+, rang B minimum, via la Salle d'Ascension.

### Depuis Guerrier
- [ ] Chevalier | Armes : Épée, Hache, Lance | Armure : Lourde
- [ ] Berserker | Armes : Épée, Hache, Marteau | Armure : Moyenne + Lourde

### Depuis Mage
- [ ] Sage Arcanique | Armes : Bâton, Grimoire, Orbe | Armure : Légère
- [ ] Maître des Éléments | Armes : Bâton, Grimoire, Orbe | Armure : Légère

### Depuis Roublard
- [ ] Assassin | Armes : Dague, Arc | Armure : Légère + Moyenne
- [ ] Ombre | Armes : Dague, Shuriken | Armure : Légère + Moyenne

### Depuis Chasseur
- [ ] Ranger | Armes : Arc | Armure : Moyenne
- [ ] Archer Mystique | Armes : Arc | Armure : Moyenne

### Depuis Guérisseur
- [ ] Paladin
- [ ] Chaman

### Depuis Invocateur
- [ ] Maître des Ombres
- [ ] Archiviste

---

## 3. Compétences par Classe

> Chaque héros équipe 4 compétences en combat. Coût en points de compétence (15 pts/niveau).
> Compétences acquises à la génération : floor(Niveau / 5).

| Rang | Coût |
|------|------|
| F | 15 pts |
| E | 30 pts |
| D | 60 pts |
| C | 90 pts |
| B | 120 pts |
| A | 150 pts |
| S | 180 pts |

### 3.1 Guerrier *(20 compétences)*

- [ ] **Coup Direct** | Rang F | Active | 3s cd | Inflige un coup +10% dégâts
- [ ] **Endurance** | Rang F | Passive | Résistance dégâts physiques +5%
- [ ] **Taillade** | Rang E | Active | 6s cd | +20% dégâts si ennemi < 50% PV
- [ ] **Entraînement au Bouclier** | Rang E | Passive | Réduit dégâts reçus de 10%
- [ ] **Rage** | Rang D | Active | 30s cd | +15% Force pendant 15s
- [ ] **Durcissement** | Rang D | Passive | +10% défense permanent
- [ ] **Coup de Bouclier** | Rang C | Active | 12s cd | 50% dégâts arme + stun 2s
- [ ] **Résilience** | Rang C | Passive | Réduit tous les dégâts entrants de 5%
- [ ] **Attaque Frénétique** | Rang C | Active | 15s cd | 5 coups rapides à 75% dégâts chacun
- [ ] **Cri de Guerre** | Rang B | Active | 45s cd | +10% Force & Défense alliés proches 30s
- [ ] **Maîtrise de l'Épée** | Rang B | Passive | +15% dégâts avec épée
- [ ] **Briseur d'Armure** | Rang B | Active | 30s cd | −20% défense ennemi 10s
- [ ] **Implacable** | Rang B | Passive | Récupère 2% PV max à chaque kill
- [ ] **Maîtrise du Bouclier** | Rang A | Passive | Réduit dégâts de toutes attaques de 15%
- [ ] **Frappe du Jugement** | Rang A | Active | 30s cd | 200% dégâts + −25% défense ennemi 10s
- [ ] **Fureur de Bataille** | Rang A | Active | 45s cd | +30% dégâts, effets négatifs −50% durée 20s
- [ ] **Invincible** | Rang S | Active | 60s cd | Invulnérable 10s
- [ ] **Maître d'Armes** | Rang S | Passive | +20% dégâts toutes armes
- [ ] **Défenseur du Roi** | Rang S | Active | 60s cd | −10% dégâts alliés proches, transfert 5% dégâts sur soi 30s
- [ ] **Coup de Grâce** | Rang S | Active | 90s cd | Kill instantané sur ennemi < 20% PV

### 3.2 Mage *(19 compétences)*

- [ ] **Projectiles Magiques** | Rang F | Active | 3s cd | 10 mana | Projectiles légers
- [ ] **Protection Mineure** | Rang F | Active | 20s cd | 8 mana | −5% dégâts subis 15s
- [ ] **Boule de Feu** | Rang E | Active | 5s cd | 15 mana | Dégâts de feu modérés monocible
- [ ] **Maîtrise du Mana** | Rang E | Passive | Régénération mana +10%
- [ ] **Éclair** | Rang E | Active | 5s cd | 14 mana | Dégâts foudre + stun 2s (chance)
- [ ] **Bouclier Magique** | Rang D | Active | 25s cd | 20 mana | Absorbe 50% dégâts 10s
- [ ] **Explosion Arcanique** | Rang C | Active | 30s cd | 30 mana | AoE 50px dégâts magiques
- [ ] **Canalisation** | Rang C | Active | 35s cd | 25 mana | +15% dégâts sorts 20s
- [ ] **Flammes Infernales** | Rang C | Active | 30s cd | 35 mana | Colonne feu, zone, 10s
- [ ] **Gelure** | Rang B | Active | 45s cd | 28 mana | Dégâts glace + immobilise 5s
- [ ] **Nova de Glace** | Rang B | Active | 45s cd | 32 mana | AoE glace + −50% vitesse 5s
- [ ] **Volonté de Fer** | Rang B | Passive | Durée effets négatifs −25%
- [ ] **Tempête de Foudre** | Rang A | Active | 45s cd | 40 mana | AoE foudre multi-cibles
- [ ] **Drain de Vie** | Rang A | Active | 45s cd | 35 mana | Draine 10% PV cible sur 5s, soigne mage
- [ ] **Explosion Magique** | Rang A | Active | 45s cd | 45 mana | AoE 75px massive
- [ ] **Maîtrise des Arcanes** | Rang S | Passive | +25% dégâts tous sorts
- [ ] **Inversion des Sorts** | Rang S | Active | 30s cd | 30 mana | Renvoie sorts adverses 5s
- [ ] **Flamme Éternelle** | Rang S | Active | 60s cd | 50 mana | Flamme zone constante 15s
- [ ] **Métamorphose** | Rang S | Active | 90s cd | 60 mana | Forme magique : +50% dégâts mage, −30% dégâts reçus 20s

### 3.3 Roublard *(17 compétences)*

- [ ] **Coup Rapide** | Rang F | Active | 3s cd | Attaque rapide +10% dégâts
- [ ] **Esquive** | Rang F | Active | 20s cd | +5% esquive 10s
- [ ] **Lancer de Dague** | Rang E | Active | 5s cd | 20% dégâts à distance
- [ ] **Camouflage** | Rang E | Active | 15s cd | Invisibilité 5s, −100 aggro
- [ ] **Coup Bas** | Rang D | Active | 12s cd | +20% dégâts + −10% défense ennemi 5s
- [ ] **Maître des Poisons** | Rang D | Passive | Dégâts poisons +15%
- [ ] **Pas de l'Ombre** | Rang C | Active | 15s cd | Téléport derrière ennemi + dégâts critiques
- [ ] **Piège** | Rang C | Active | 20s cd | Immobilise ennemi 3s
- [ ] **Attaque Furtive** | Rang C | Passive | +30% dégâts si en furtivité
- [ ] **Coup Critique** | Rang B | Active | 20s cd | +20% chance de critique 10s
- [ ] **Maître des Ombres** | Rang B | Passive | Durée furtivité +30%
- [ ] **Paralysie** | Rang B | Active | 25s cd | Paralyse ennemi 5s
- [ ] **Saignée** | Rang A | Active | 25s cd | 30% dégâts + saignement
- [ ] **Danse des Lames** | Rang A | Active | 25s cd | Série d'attaques rapides AoE 30px
- [ ] **Évasion** | Rang A | Active | 30s cd | 50% esquive toutes attaques 10s
- [ ] **Assassinat** | Rang S | Active | 60s cd | 50% dégâts + 25% kill instantané si < 30% PV
- [ ] **Toxines Mortelles** | Rang S | Active | 60s cd | Toutes attaques empoisonnées 15s

### 3.4 Chasseur *(14 compétences)*

- [ ] **Tir Précis** | Rang F | Active | 3s cd | 20% dégâts, précision accrue
- [ ] **Flèche Empoisonnée** | Rang F | Active | 5s cd | 10% dégâts + poison
- [ ] **Tir Rapide** | Rang E | Active | 10s cd | 2 flèches à 15% dégâts chacune
- [ ] **Œil de Faucon** | Rang E | Passive | Portée +10%, dégâts arc +10%
- [ ] **Tir Explosif** | Rang D | Active | 10s cd | AoE autour de la cible, 20% dégâts
- [ ] **Flèche Enflammée** | Rang C | Active | 12s cd | Dégâts de feu sur la durée
- [ ] **Piège à Loups** | Rang C | Active | 20s cd | Immobilise ennemi 5s
- [ ] **Flèche Perforante** | Rang B | Active | 18s cd | 20% dégâts, ignore 20% défense
- [ ] **Tir en Cascade** | Rang B | Active | 20s cd | 5 flèches multi-cibles à 15% chacune
- [ ] **Concentration** | Rang A | Passive | +5% chance de coup critique
- [ ] **Flèche Mortelle** | Rang A | Active | 30s cd | 50% dégâts + 50% chance critique
- [ ] **Piqûre de Scorpion** | Rang A | Active | 25s cd | Paralyse + empoisonne 3s
- [ ] **Tir Légendaire** | Rang S | Active | 60s cd | 300% dégâts + kill instantané si < 20% PV
- [ ] **Pluie de Flèches** | Rang S | Active | 45s cd | Salve AoE massive

### 3.5 Guérisseur *(14 compétences)*

- [ ] **Soin Mineur** | Rang F | Active | 3s cd | 10 mana | Soigne 15% PV d'un allié
- [ ] **Lumière Purificatrice** | Rang F | Active | 5s cd | 8 mana | Dissipe 1 effet négatif
- [ ] **Bouclier de Lumière** | Rang E | Active | 5s cd | 15 mana | Bouclier allié, absorbe 15% dégâts 10s
- [ ] **Régénération** | Rang E | Active | 20s cd | 20 mana | +2% PV/s allié pendant 10s
- [ ] **Prière** | Rang D | Active | 20s cd | 18 mana | +10% défense alliés zone 50px, 15s
- [ ] **Soin de Groupe** | Rang C | Active | 20s cd | 25 mana | +20% PV tous alliés zone 50px
- [ ] **Barrière Protectrice** | Rang C | Active | 25s cd | 30 mana | −15% dégâts reçus tous alliés 10s
- [ ] **Lumière Divine** | Rang B | Active | 25s cd | 35 mana | +40% PV allié + dissipe tous effets négatifs
- [ ] **Main de Lumière** | Rang B | Active | 20s cd | 30 mana | +50% PV allié instantané
- [ ] **Purification de Masse** | Rang A | Active | 30s cd | 35 mana | Dissipe tous effets négatifs alliés zone 50px
- [ ] **Bouclier Sacré** | Rang A | Active | 35s cd | 40 mana | Absorbe tous dégâts allié 10s
- [ ] **Soin Suprême** | Rang S | Active | 45s cd | 60 mana | +75% PV tous alliés zone 75px
- [ ] **Résurrection** | Rang S | Active | 90s cd | 70 mana | Ressuscite tous alliés tombés à 30% PV
- [ ] **Bénédiction Divine** | Rang S | Active | 60s cd | 50 mana | +20% toutes stats alliés zone 75px, 15s

### 3.6 Invocateur *(15 compétences)*

- [ ] **Invocation Mineure** | Rang F | Active | 30s cd | 10 mana | Familier mineur 10s
- [ ] **Maîtrise des Esprits** | Rang F | Passive | Durée invocations +5%
- [ ] **Lien Spirituel** | Rang E | Active | 15s cd | 15 mana | PV & dégâts invocations +10%
- [ ] **Invocation de Loup Fantôme** | Rang E | Active | 30s cd | 20 mana | Loup spectral 15s
- [ ] **Invocation de Golem** | Rang D | Active | 30s cd | 25 mana | Golem tank 15s
- [ ] **Réanimation** | Rang D | Active | — | 30 mana | Réanime un ennemi tombé (alié 10s)
- [ ] **Invocation de Feu Follet** | Rang C | Active | 25s cd | 22 mana | Feu follet explosif AoE 15px
- [ ] **Canalisation Spirituelle** | Rang C | Active | 25s cd | 25 mana | +15% puissance invocations 20s
- [ ] **Invocation d'Élémentaire** | Rang C | Active | 30s cd | 35 mana | Élémentaire aléatoire 30s
- [ ] **Maître des Invocations** | Rang B | Passive | Durée invocations +20%
- [ ] **Invocation de Dragonnet** | Rang A | Active | 45s cd | 40 mana | Dragonnet souffle de feu 15s
- [ ] **Siphon de Vie** | Rang A | Active | 30s cd | 20 mana | Draine 10% PV invocation pour soigner
- [ ] **Invocation de Phénix** | Rang S | Active | 60s cd | 50 mana | Phénix (ressuscite 1 fois) 30s
- [ ] **Armée des Ombres** | Rang S | Active | 60s cd | 45 mana | 5 ombres combattantes
- [ ] **Gardien Céleste** | Rang S | Active | 60s cd | 50 mana | Gardien −20% dégâts alliés zone 75px

### 3.7 Classes Avancées

*(Compétences à définir — section marquée "à compléter" dans le document de design)*

---

## 4. Traits de Caractère

> 1 à 3 traits par héros, maximum 2 négatifs. Les héros de rang élevé ont plus de chances d'avoir des traits positifs.

### Traits Positifs

- [ ] **Charismatique** — +10% efficacité tâches sociales, +3 moral aux héros proches
- [ ] **Travailleur** — +15% vitesse toutes tâches non-combattantes
- [ ] **Stoïque** — malus moraux sur événements négatifs réduits de 50%
- [ ] **Inspiration Divine** — 10% de chance/tâche de terminer instantanément ou +10 moral à un allié
- [ ] **Ami des Animaux** — +20% sur missions impliquant des créatures
- [ ] **Résilient** — guérit 2× plus vite, malus blessure réduit de 10%
- [ ] **Leader Naturel** — +5 moral à tous les héros du même groupe de mission
- [ ] **Dévoué à la Guilde** — ne démissionne jamais sauf moral = 0 pendant 10+ jours consécutifs
- [ ] **Bonne Constitution** — besoins Sommeil et Faim descendent 20% moins vite
- [ ] **Compagnon Loyal** — malus "perte d'un camarade" réduit de 50%
- [ ] **Apprend Vite** — +25% XP combat et métier
- [ ] **Cuistot Passionné** — +15% vitesse cuisine, +3 moral aux héros qui mangent ses plats
- [ ] **Forgeur d'Élite** — +20% qualité forge (équipements produits : +1 rang effectif de stats)
- [ ] **Enthousiaste** — +15 moral au début de chaque journée in-game (durée 12h)
- [ ] **Mémoire Visuelle** — +10% efficacité tâches liées au Savoir
- [ ] **Combatif** — +10% vitesse d'attaque, initiative +1 en combat
- [ ] **Esprit d'Équipe** — réduit la probabilité de conflit interne de 70%
- [ ] **Artisan Inspiré** — 5% de chance par craft de produire un objet de qualité supérieure (+1 rang)
- [ ] **Sang-froid** — durée des effets Stun et Peur réduite de 50%
- [ ] **Robuste** — PV Max +15%
- [ ] **Infatigable** — besoins Hygiène et Toilette descendent 25% moins vite

### Traits Négatifs

- [ ] **Colérique** — 20% de chance/jour de déclencher un conflit (−8 moral pour les deux)
- [ ] **Fainéant** — −20% vitesse toutes tâches
- [ ] **Instable Émotionnellement** — tous les effets moraux (+ et −) amplifiés ×1.5
- [ ] **Cynique** — ne bénéficie pas des bonus moraux collectifs (cérémonies, festivals)
- [ ] **Solitaire** — −5 moral constant si 3+ héros dans la même pièce
- [ ] **Gourmand** — besoin Faim descend 2× plus vite
- [ ] **Somnoleur** — besoin Sommeil descend 1.5× plus vite, récupère 20% moins vite au sol
- [ ] **Maladroit** — 10% de chance d'échec partiel sur un craft (qualité inférieure)
- [ ] **Hypocondriaque** — se met en arrêt maladie si PV ≤ 80% (refus de travailler 1 jour)
- [ ] **Orgueilleux** — 15% de chance d'ignorer une affectation
- [ ] **Mauvais Perdant** — −20 moral immédiat après chaque mission échouée
- [ ] **Tête en l'Air** — 10% de chance par heure de changer d'activité sans raison
- [ ] **Addict au Combat** — −5 moral constant si aucune mission dans les 5 derniers jours
- [ ] **Insomnie** — récupère le besoin Sommeil 40% moins vite
- [ ] **Apathique** — aucun bonus moral positif supérieur à +5 (plafond dur)
- [ ] **Voleur** — si moral < 30 pendant 3+ jours, déclenche l'événement vol
- [ ] **Superstitieux** — −10 moral lors d'événements "maudits"
- [ ] **Dépressif** — moral −1/heure passivement sans interaction positive dans la journée
- [ ] **Allergique aux Animaux** — −5 moral constant + −10% santé max dans pièce avec objets liés aux animaux
- [ ] **Indiscret** — 20% de chance lors d'un accueil de révéler des infos (−2 relation faction aléatoire)
- [ ] **Claustrophobe** — −5 moral constant dans les pièces de superficie < 6 cases

---

## 5. Mobs

### Rang F

- [x] **Slime** | FM 0.1 | Vitesse 100 | STR 3 DEF 4 AGI 6 MAG 1 LCK 5 | PV 62
  - Drop : Gelée de slime ×1 (commun) | Cristal magique ×1 (rare)
  - Coup Gluant : bondit sur l'ennemi — Puissance 4
  - Charge Instable *(spécial)* : dégâts de zone légers — Puissance 3
- [ ] **Araignée sylvestre** | FM 0.15 | Vitesse 90 | STR 4 DEF 3 AGI 8 MAG 1 LCK 5
  - Drop : Résine collante ×1 | Venin ×1–2 | Baie noire ×1 (rare)
  - Morsure rapide : Puissance 5
  - Jet de toile *(spécial)* : ralentit −30% vitesse pendant 3s — Puissance 2

### Rang E

- [ ] **Loup** | FM 0.2 | Vitesse 250 | STR 8 DEF 6 AGI 12 MAG 2 LCK 5
  - Drop : Peau brute ×1–2 | Viande de loup ×1–2 | Graisse animale ×1–2 | Cristal magique (rare)
  - Morsure sauvage : Puissance 10
  - Hurlement de meute *(spécial)* : +10% agilité alliés loups pendant 10s
- [ ] **Sanglier** | FM 0.25 | Vitesse 90 | STR 9 DEF 7 AGI 6 MAG 1 LCK 4
  - Drop : Viande de sanglier ×1–2 | Cuir ×1 | Graisse animale ×1–3 | Peau brute ×1–2
  - Charge bestiale : frontale, chance de repoussement — Puissance 3
  - Grognement furieux *(spécial)* : +10% défense propre pendant 6s
- [ ] **Soldat Squelette** | FM 0.2 | Vitesse 100 | STR 7 DEF 6 AGI 5 MAG 2 LCK 3
  - Drop : Métal brut ×1 | Cristaux magiques ×1 | Os de berserker (rare)
  - Coup d'épée rouillée : Puissance 8
  - Cri spectral *(spécial)* : −5 Défense pendant 5s

### Rang D

- [ ] **Gobelin** | FM 0.15 | Vitesse 120 | STR 5 DEF 4 AGI 8 MAG 3 LCK 8
  - Drop : Dents de gobelin ×2–3 | Viande de gobelin ×1 | Métal ×1–4 | Cristal magique (rare)
  - Coup de poignard : Puissance 7
  - Jet de pierre *(spécial)* : 10% chance d'étourdir 3s — Puissance 5
- [ ] **Vipère** | FM 0.25 | Vitesse 150 | STR 6 DEF 5 AGI 14 MAG 4 LCK 8
  - Drop : Venin ×1–2 | Viande de vipère ×1 | Cristal magique (rare)
  - Morsure venimeuse : poison 2 dégâts/s pendant 5s — Puissance 6
  - Constriction *(spécial)* : immobilise 2s — Puissance 4
- [ ] **Esprit des Ruines** | FM 0.35 | Vitesse 110 | STR 2 DEF 5 AGI 10 MAG 12 LCK 6
  - Drop : Essence d'ombre ×1 | Étoffe fantomatique ×1 | Cristaux magiques ×1
  - Toucher spectral : dégâts magiques purs — Puissance 9
  - Hurlement du passé *(spécial)* : peur 3s + −5% intelligence

### Rang C

- [ ] **Orque Berserker** | FM 0.4 | Vitesse 100 | STR 14 DEF 10 AGI 7 MAG 2 LCK 4
  - Drop : Os de berserker ×1 | Cristal magique (rare)
  - Coup de massue : Puissance 3
  - Frénésie sanglante *(spécial)* : +5 Force, −5 Défense pendant 15s
- [ ] **Spectre Hanté** | FM 0.4 | Vitesse 100 | STR 3 DEF 7 AGI 12 MAG 15 LCK 6
  - Drop : Étoffe fantomatique ×1–2 | Essence d'ombre (rare) | Cristal magique ×1
  - Drain vital : soigne 50% des dégâts infligés — Puissance 8
  - Hurlement surnaturel *(spécial)* : peur 3s
- [ ] **Chasseur Elfe Noir** | FM 0.45 | Vitesse 130 | STR 10 DEF 8 AGI 14 MAG 6 LCK 10
  - Drop : Baie noire ×1–2 | Ambre ×1 | Rune magique (rare)
  - Tir empoisonné : poison 3 dégâts/s — Puissance 8
  - Flèche runique *(spécial)* : silence 4s — Puissance 10

### Rang B

- [ ] **Cyclope** | FM 0.5 | Vitesse 80 | STR 18 DEF 16 AGI 4 MAG 3 LCK 5
  - Drop : Peau brute ×2–4 | Œil de cyclope (rare) | Cristal magique (rare)
  - Coup massif : Puissance 18
  - Piétinement *(spécial)* : −15% agilité zone pendant 10s — Puissance 8
- [ ] **Chaman Corrompu** | FM 0.35 | Vitesse 100 | STR 5 DEF 6 AGI 8 MAG 18 LCK 7
  - Drop : Essence d'ombre ×1–2 | Totem corrompu (rare) | Cristal magique ×1
  - Flamme noire : brûlure 5 dégâts/s pendant 5s
  - Malédiction des ombres *(spécial)* : −5% Force & Défense pendant 15s
- [ ] **Gardien de Lave** | FM 0.5 | Vitesse 80 | STR 14 DEF 14 AGI 3 MAG 10 LCK 4
  - Drop : Charbon ×2 | Cœur de flamme ×1 | Lingot d'acier (rare)
  - Poing brûlant : dégâts + brûlure 5s — Puissance 16
  - Explosion de lave *(spécial)* : AoE feu 15 dégâts + lenteur 2s
- [ ] **Basilic Caverneux** | FM 0.55 | Vitesse 100 | STR 12 DEF 12 AGI 8 MAG 3 LCK 5
  - Drop : Venin ×1 | Écaille de dragon ×1–2 | Graisse animale ×1–2
  - Morsure paralysante : chance de stun 2s — Puissance 12
  - Regard pétrifiant *(spécial)* : 10% chance de geler 1 cible 3s

### Rang A

- [ ] **Dragonnet de Feu** | FM 0.5 | Vitesse 150 | STR 12 DEF 10 AGI 9 MAG 14 LCK 8
  - Drop : Écaille de dragon ×2–3 | Viande de dragonnet ×1 | Cœur de flamme (rare) | Cristal magique ×1 | Graisse animale ×1–3
  - Griffure : Puissance 14
  - Souffle enflammé *(spécial)* : brûlure 10 dégâts/s pendant 3s
- [ ] **Ent Ancien** | FM 0.65 | Vitesse 70 | STR 16 DEF 18 AGI 4 MAG 10 LCK 7
  - Drop : Ambre ×2 | Résine collante ×2 | Bois renforcé ×1
  - Écrasement racinaire : AoE physique — Puissance 16
  - Renaissance sylvestre *(spécial)* : soigne les alliés végétaux de 10%

### Rang S

- [ ] **Seigneur Démoniaque** | FM 1.0 | Vitesse 110 | STR 20 DEF 18 AGI 12 MAG 22 LCK 15
  - Drop : Corne démoniaque ×1–2 | Cœur des ténèbres (rare) | Éclat du chaos ×2–3 | Cristal magique ×1 | Fragment d'esprit (rare)
  - Frappe du chaos : Puissance 20
  - Souffle infernal *(spécial)* : zone, brûlure 15 dégâts/s pendant 4s
- [ ] **Spectre d'Oubli** | FM 1.0 | Vitesse 150 | STR 8 DEF 10 AGI 16 MAG 20 LCK 12
  - Drop : Fragment d'esprit ×1 | Essence d'ombre ×1 | Cristal magique ×1
  - Drain mental : −10% mana + dégâts magiques — Puissance 12
  - Brume de l'oubli *(spécial)* : silence de zone 3s, chance de perte de compétence temporaire — Puissance 6

---

## 6. Armes

### 6.1 Épées

- [x] **Épée Rouillée** | Rang F | Atk 5 | Métal brut ×2
- [ ] **Épée du Soldat** | Rang E | Atk 10 | Lingot de fer ×3, Cuir ×1
- [ ] **Épée Longue** | Rang D | Atk 15 | Lingot de fer ×4, Bois renforcé ×2
- [ ] **Lame de Chevalier** | Rang C | Atk 20 | Lingot d'acier ×2, Ambre ×2, Cuir souple ×1
- [ ] **Épée Draconique** | Rang A | Atk 25 | Lingot d'acier trempé ×2, Écaille de dragon ×2, Cœur de flamme ×1

### 6.2 Haches

- [ ] **Hachette de Bûcheron** | Rang F | Atk 8 | Bois ×2, Lingot de fer ×1
- [ ] **Hache de Guerre** | Rang E | Atk 14 | Lingot de fer ×2, Bois ×1, Cuir ×1
- [ ] **Hache Double** | Rang D | Atk 18 | Lingot de fer ×4, Cuir tanné ×1
- [ ] **Hache Viking** | Rang C | Atk 22 | Lingot d'acier ×3, Ambre ×1, Cuir souple ×1

### 6.3 Lances

- [ ] **Lance de Chasse** | Rang F | Atk 7 | Bois ×2, Lingot de fer ×1
- [ ] **Pique du Soldat** | Rang E | Atk 12 | Lingot de fer ×3, Cuir ×1
- [ ] **Lance Royale** | Rang D | Atk 17 | Lingot d'acier ×2, Ambre ×2, Cuir tanné ×1
- [ ] **Trident de Bataille** | Rang C | Atk 20 | Lingot d'acier ×3, Essence d'ombre ×1
- [ ] **Lance des Tempêtes** | Rang A | Atk 25 | Essence de vent ×2, Rune magique ×1, Lingot d'acier ×3

### 6.4 Dagues

- [ ] **Dague de Voleur** | Rang F | Atk 5 | Lingot de fer ×1, Cuir ×1
- [ ] **Lame de Serpent** | Rang D | Atk 10 | Lingot de fer ×2, Venin ×1
- [ ] **Karambit** | Rang C | Atk 12 | Lingot d'acier ×2, Cuir souple ×1

### 6.5 Marteaux

- [ ] **Marteau de Forgeron** | Rang F | Atk 9 | Bois brut ×2, Fer brut ×1
- [ ] **Masse d'Armes** | Rang E | Atk 15 | Lingot de fer ×3, Cuir tanné ×1
- [ ] **Marteau du Titan** | Rang C | Atk 20 | Lingot d'acier ×3, Os de berserker ×1
- [ ] **Marteau des Tempêtes** | Rang B | Atk 25 | Lingot d'acier ×3, Cristaux magiques ×2
- [ ] **Marteau du Chaos** | Rang A | Atk 27 | Lingot d'acier trempé ×2, Éclat du chaos ×1, Cristaux magiques ×1

### 6.6 Bâtons

- [ ] **Bâton de Novice** | Rang F | Atk 6 | Bois ×2, Cristaux magiques ×1
- [ ] **Bâton de Chêne** | Rang E | Atk 10 | Bois ×2, Rune magique ×1
- [ ] **Bâton Magique** | Rang D | Atk 14 | Bois renforcé ×2, Cristaux magiques ×2
- [ ] **Bâton du Sage** | Rang B | Atk 18 | Bois renforcé ×3, Rune magique ×1

### 6.7 Arcs

- [ ] **Arc Court** | Rang F | Atk 7 | Bois ×2, Corde ×1
- [ ] **Arc de Chasseur** | Rang E | Atk 12 | Bois ×3, Cuir tanné ×1, Corde ×1
- [ ] **Arc Long** | Rang D | Atk 17 | Bois renforcé ×3, Corde ×1
- [ ] **Arc Elfique** | Rang B | Atk 22 | Bois renforcé ×2, Ambre ×1, Rune magique ×1, Corde ×1

### 6.8 Orbes

- [ ] **Orbe de Cristal** | Rang F | Atk 6 | Verre ×1, Cristaux magiques ×1
- [ ] **Orbe des Éléments** | Rang E | Atk 10 | Verre ×2, Rune magique ×1
- [ ] **Orbe de Mana** | Rang D | Atk 14 | Verre ×2, Cristaux magiques ×2, Ambre ×1
- [ ] **Orbe Runique** | Rang B | Atk 18 | Verre ×2, Rune magique ×2

### 6.9 Grimoires

- [ ] **Grimoire de Novice** | Rang F | Atk 5 | Cuir ×2, Baie noire ×1
- [ ] **Grimoire des Ombres** | Rang E | Atk 9 | Cuir ×2, Cristaux magiques ×1, Baie noire ×1
- [ ] **Grimoire des Arcanes** | Rang D | Atk 13 | Cuir tanné ×3, Rune magique ×2
- [ ] **Grimoire de l'Archimage** | Rang A | Atk 17 | Cuir souple ×3, Baie noire ×2, Cristaux magiques ×2

### 6.10 Shurikens

- [ ] **Shuriken Simple** | Rang F | Atk 4 | Lingot de fer ×1
- [ ] **Shuriken Tranchant** | Rang E | Atk 6 | Lingot de fer ×2
- [ ] **Étoile de Lancer** | Rang D | Atk 8 | Lingot d'acier ×3
- [ ] **Shuriken Empoisonné** | Rang C | Atk 10 | Lingot d'acier ×2, Venin ×1

---

## 7. Armures

### 7.1 Armures Légères (tissu/lin)

**Têtes**
- [ ] **Chapeau de Paille** | Rang F | Def 1 | Tissu ×1
- [ ] **Capuche en Lin** | Rang F | Def 2 | Tissu ×2
- [ ] **Chapeau d'Acolyte** | Rang E | Def 3 | Tissu ×2, Cristaux magiques ×1
- [ ] **Capuche Matelassée** | Rang E | Def 4 | Tissu ×2
- [ ] **Chapeau de Druide** | Rang E | Def 4 | Tissu ×2, Essence de vent ×1
- [ ] **Chapeau Mystique** | Rang D | Def 5 | Tissu ×2, Cristaux magiques ×1, Rune magique ×1

**Torses**
- [ ] **Robe de l'Apprenti** | Rang F | Def 3 | Tissu ×3
- [ ] **Robe de Magicien** | Rang E | Def 5 | Tissu ×3, Cristaux magiques ×1
- [ ] **Robe des Éléments** | Rang D | Def 6 | Tissu renforcé ×2, Essence de vent ×1, Cristaux magiques ×1
- [ ] **Robe des Arcanes** | Rang C | Def 7 | Tissu renforcé ×3, Rune magique ×1, Cristaux magiques ×2
- [ ] **Tunique d'Ombre** | Rang B | Def 8 | Tissu renforcé ×2, Essence d'ombre ×1, Baie noire ×1

**Jambes**
- [ ] **Pantalon de Lin** | Rang F | Def 2 | Tissu ×2
- [ ] **Pantalon Enchanté** | Rang E | Def 4 | Tissu ×2, Cristaux magiques ×1
- [ ] **Jambières de Mage** | Rang D | Def 5 | Tissu ×2, Cristaux magiques ×1

### 7.2 Armures Moyennes (cuir)

**Têtes**
- [ ] **Casque de Patrouilleur** | Rang E | Def 6 | Cuir tanné ×2, Rivets en acier ×1
- [ ] **Casque de Chasseur** | Rang D | Def 8 | Cuir tanné ×2, Lingot de fer ×1
- [ ] **Casque d'Éclaireur** | Rang C | Def 10 | Cuir souple ×1, Lingot d'acier ×1, Essence de vent ×1

**Torses**
- [ ] **Armure de Rôdeur** | Rang E | Def 8 | Cuir tanné ×3, Rivets en acier ×2
- [ ] **Armure de Mercenaire** | Rang D | Def 10 | Cuir tanné ×3, Lingot de fer ×2
- [ ] **Armure de l'Éclaireur** | Rang C | Def 12 | Cuir ×2, Lingot d'acier ×2, Essence de vent ×1
- [ ] **Armure des Ombres** | Rang C | Def 11 | Cuir ×2, Essence d'ombre ×1, Tissu renforcé ×1

**Jambes**
- [ ] **Jambières du Rôdeur** | Rang E | Def 6 | Cuir tanné ×2, Rivets en acier ×1, Baie noire ×1
- [ ] **Jambières de Mercenaire** | Rang D | Def 8 | Cuir tanné ×3, Lingot de fer ×1
- [ ] **Jambières de l'Éclaireur** | Rang C | Def 10 | Cuir souple ×2, Lingot d'acier ×1, Essence de vent ×1

### 7.3 Armures Lourdes (métal)

**Têtes**
- [ ] **Heaume de Soldat** | Rang E | Def 12 | Lingot de fer ×3, Rivets en acier ×2
- [ ] **Casque de Chevalier** | Rang D | Def 15 | Lingot d'acier ×2, Cuir tanné ×1, Rivets en acier ×2
- [ ] **Casque des Highlands** | Rang A | Def 16 | Lingot d'acier ×3, Cuir souple ×1, Essence de vent ×1
- [ ] **Heaume du Conquérant** | Rang S | Def 18 | Lingot d'acier trempé ×2, Rivets en acier ×3, Œil de cyclope ×1

**Torses**
- [ ] **Cuirasse de Soldat** | Rang E | Def 15 | Lingot de fer ×3, Cuir ×2, Rivets en acier ×2
- [ ] **Armure de Chevalier** | Rang D | Def 18 | Lingot d'acier ×3, Rivets en acier ×2, Cuir ×1
- [ ] **Armure de Guerre** | Rang B | Def 20 | Lingot d'acier trempé ×3, Rivets en acier ×2, Os de berserker ×1
- [ ] **Plastron Volcan** | Rang A | Def 20 | Lingot d'acier trempé ×3, Charbon ×2, Cœur de flamme ×1
- [ ] **Armure de Bataille** | Rang S | Def 22 | Lingot d'acier trempé ×2, Rivets en acier ×3, Cuir souple ×1, Cœur de flamme ×1

**Jambes**
- [ ] **Grèves de Soldat** | Rang E | Def 12 | Lingot de fer ×2, Cuir tanné ×1, Rivets en acier ×1
- [ ] **Jambières de Chevalier** | Rang D | Def 15 | Lingot d'acier ×2, Cuir tanné ×1, Rivets en acier ×2
- [ ] **Jambières de Bataille** | Rang B | Def 18 | Lingot d'acier ×2, Lingot d'acier trempé ×1, Os de berserker ×1

---

## 8. Accessoires

### Anneaux

- [ ] **Anneau de Fer** | Rang F | (décoratif) | Lingot de fer ×1
- [ ] **Anneau de Force** | Rang D | +5 Force | Lingot d'acier ×1, Ambre ×1
- [ ] **Anneau du Mage** | Rang C | +8 Magie | Lingot d'acier ×1, Cristaux magiques ×1
- [ ] **Anneau de Vivacité** | Rang C | +5 Agilité | Lingot d'acier ×1, Ambre ×1
- [ ] **Anneau de Vitalité** | Rang C | +25 PV | Lingot d'acier ×1, Plante médicinale ×1, Cristaux magiques ×1

### Amulettes

- [ ] **Amulette en Bois** | Rang F | (décorative) | Bois ×1
- [ ] **Amulette de Soin** | Rang D | Régénération lente PV | Lingot d'acier ×1, Plante médicinale ×1
- [ ] **Amulette de Feu** | Rang C | Résistance au feu | Lingot d'acier ×1, Cristal magique ×1
- [ ] **Amulette des Anciens** | Rang B | +10% mana max | Lingot d'acier ×1, Rune magique ×1
- [ ] **Amulette Runique** | Rang B | +25 mana | Lingot d'acier ×1, Rune magique ×2

---

## 9. Potions et Consommables

### Soins & Régénération

- [ ] **Potion de Soin Mineur** | +50 PV | Eau ×1, Plante médicinale ×1
- [ ] **Potion de Soin** | +100 PV | Eau ×1, Plante médicinale ×2
- [ ] **Potion de Soin Majeure** | +200 PV | Eau ×2, Plante médicinale ×3, Cristal magique ×1

### Magiques

- [ ] **Potion de Mana Mineur** | +50 Mana | Eau ×1, Cristal magique ×1
- [ ] **Potion de Mana** | +100 Mana | Eau ×1, Cristal magique ×2
- [ ] **Potion de Mana Supérieure** | +200 Mana | Eau ×1, Cristal magique ×3

### Défensives & Résistance

- [ ] **Potion de Pierre** | +20 END pendant 20s | Eau ×1, Essence d'ombre ×1
- [ ] **Potion de Résistance au Feu** | −50% dégâts feu pendant 30s | Eau ×1, Cœur de flamme ×1, Cristal magique ×1
- [ ] **Potion d'Ombre Protectrice** | −30% dégâts magiques pendant 30s | Eau ×1, Essence d'ombre ×1, Rune magique ×1

### Offensives & Buffs

- [ ] **Potion de Force Brute** | +10 Force pendant 30s | Eau pure ×1, Os de berserker ×1
- [ ] **Potion de Précision** | +15% critique pendant 30s | Eau pure ×1, Dent de gobelin ×2
- [ ] **Potion de Vitesse** | +30% Agilité pendant 15s | Eau pure ×1, Essence de vent ×1, Cristal magique ×1
- [ ] **Potion de Poison** | Arme empoisonnée (3 coups) | Venin ×1, Baies noires ×1, Eau ×1
- [ ] **Potion de Canalisation** | +20% dégâts magiques pendant 20s | Eau ×1, Essence de vent ×1, Rune magique ×1

### Spéciales / Rares

- [ ] **Potion d'Invisibilité** | Invisibilité 10s | Eau ×1, Essence d'ombre ×1, Cristaux magiques ×1
- [ ] **Potion de Rage Berserk** | +25 Force, −20% Défense pendant 15s | Huile de bœuf ×1, Os de berserker ×1, Baies noires ×1
- [ ] **Potion du Chaos** | Effet aléatoire (buffs ou debuffs extrêmes) | Éclat du chaos ×1, Rune magique ×1, Cristal magique ×2
- [ ] **Potion de Purification** | Supprime poison, brûlure, saignement, malus | Eau ×2, Plante médicinale ×2, Essence d'ombre ×1

---

## 10. Enchantements

> Irréversible, 1 max par équipement. Nécessite la recherche correspondante avant application.

### Rang C *(prérequis : recherche "Enchantement")*

- [ ] **Igni** | Arme | +6 dégâts de feu, 20% brûlure 3s | 5× Cristaux Magiques
- [ ] **Bouclier de Givre** | Armure | −10% dégâts reçus, +5% résistance au feu | 7× Cristaux Magiques
- [ ] **Cape de l'Ombre** | Armure | +10% agilité, +5% esquive | 7× Cristaux Magiques
- [ ] **Aura de Célérité** | Armure | +10% vitesse déplacement, −5% temps attaque | 5× Cristaux Magiques
- [ ] **Tranchant Raffiné** | Arme | +5% chance de critique | 4× Cristaux Magiques

### Rang B *(prérequis : recherche "Enchantement Avancé")*

- [ ] **Lame de Foudre** | Arme | +8 dégâts foudre, 10% paralysie 1.5s | 6× Cristaux Magiques
- [ ] **Lumière Purifiante** | Armure | Immunité poison/saignement, +2 PV/s regen | 8× Cristaux Magiques
- [ ] **Griffes Spectrales** | Arme | +5 dégâts d'ombre, 10% ignore armure | 6× Cristaux Magiques
- [ ] **Rune du Titan** | Armure | +15% défense physique, +10% poids max | 9× Cristaux Magiques
- [ ] **Sceau des Arcanes** | Bijou | +10% puissance magique, +10 mana max | 8× Cristaux Magiques

### Rang A *(prérequis : recherche "Enchantement Expert")*

- [ ] **Bénédiction du Gardien** | Armure | 10% dégâts redirigés, +3% armure magique | 9× Cristaux Magiques
- [ ] **Toucher Vampirique** | Arme | Vol de vie : +3% des dégâts infligés rendus en PV | 10× Cristaux Magiques
- [ ] **Aura de Vaillance** | Bijou | +8% force, immunité à la peur | 9× Cristaux Magiques
- [ ] **Réflexe Surnaturel** | Armure | 15% chance d'esquive automatique (CD 2 tours) | 9× Cristaux Magiques

### Rang S *(prérequis : recherche "Enchantement Expert")*

- [ ] **Voile du Néant** | Armure | 20% chance d'éviter toute attaque | 10× Cristaux Magiques + Essence d'ombre ×1
- [ ] **Lame du Chaos** | Arme | +10 dégâts aléatoires, 5% confusion | 12× Cristaux Magiques + Éclat du chaos ×1
- [ ] **Aura d'Ascension** | Bijou | +10% toutes stats principales, bonus moral constant | 12× Cristaux Magiques + Fragment d'esprit ×1
- [ ] **Égide Totale** | Armure | −25% dégâts, +10% résistance magie, −10% vitesse | 11× Cristaux Magiques + Écaille de dragon ×1

---

## 11. Matériaux et Ressources

### 11.1 Ressources Naturelles

- [x] **Bois** | Valeur 2 | Récolte forêt, Achat
- [ ] **Pierre** | Valeur 3 | Récolte montagne, Achat
- [ ] **Lin** | Valeur 2 | Récolte (culture), Achat
- [ ] **Eau** | Valeur 1 | Récolte (puits), Achat
- [ ] **Sel** | Valeur 1 | Récolte, Achat
- [ ] **Baie Noire** | Valeur 1 | Récolte (culture), Achat
- [ ] **Plante Médicinale** | Valeur 3 | Récolte (culture), Achat
- [ ] **Ambre** | Valeur 11 | Récolte, Achat
- [ ] **Résine Collante** | Valeur 5 | Récolte, Achat
- [ ] **Métal Brut** | Valeur 3 | Récolte, Achat
- [ ] **Graisse Animale** | Valeur 3 | Drop : Loup, Sanglier, Cyclope
- [ ] **Peau Brute** | Valeur 3 | Drop : Loup, Sanglier, Cyclope
- [ ] **Sable** | Valeur 2 | Récolte, Achat
- [ ] **Miel** | Valeur 2 | Ruche
- [ ] **Houblon** | Valeur 1 | Culture

### 11.2 Matériaux Artisanaux (Craftables)

- [ ] **Corde** | Valeur 3 | Lin ×3 | Atelier | 1h
- [ ] **Fil Résistant** | Valeur 4 | Lin ×2, Résine collante ×1 | Atelier | 2h
- [ ] **Tissu** | Valeur 3 | Lin ×2 | Métier à tisser | 1h
- [ ] **Tissu Renforcé** | Valeur 3 | Tissu ×1, Fil résistant ×1 | Métier à tisser | 2h
- [ ] **Cuir** | Valeur 3 | Peau brute ×1, Eau ×1 | Atelier de tannage | 1h
- [ ] **Cuir Tanné** | Valeur 5 | Cuir ×2, Sel ×1, Eau ×1 | Atelier de tannage | 2h
- [ ] **Cuir Souple** | Valeur 8 | Cuir tanné ×2, Huile de bœuf ×1 | Atelier de tannage | 3h
- [ ] **Lingot de Fer** | Valeur 4 | Métal brut ×2 | Forge | 2h
- [ ] **Lingot d'Acier** | Valeur 6 | Métal brut ×3, Charbon ×1 | Forge | 3h
- [ ] **Lingot d'Acier Trempé** | Valeur 9 | Lingot d'acier ×2, Huile de trempe ×1, Résine collante ×1, Eau ×1 | Forge | 4h
- [ ] **Rivets en Acier** | Valeur 3 | Métal brut ×1 | Forge | 1h
- [ ] **Charbon** | Valeur 3 | Bois ×2 | Forge | 1h
- [ ] **Verre** | Valeur 3 | Sable ×2, Charbon ×1 | Forge | 2h
- [ ] **Bois Renforcé** | Valeur 15 | Bois ×2, Résine collante ×1 | Atelier | 2h
- [ ] **Huile de Bœuf** | Valeur 4 | Graisse animale ×2, Plante médicinale ×1 | Table d'alchimie | 2h
- [ ] **Huile de Trempe** | Valeur 7 | Huile de bœuf ×1, Résine collante ×1, Eau ×1 | Table d'alchimie | 3h
- [ ] **Essence de Vent** | Valeur 12 | Cristaux magiques ×2, Gelée de slime ×1 | Table d'alchimie | 4h
- [ ] **Rune Magique** | Valeur 15 | Cristal magique ×1, Baie noire ×1, Étoffe fantomatique ×1 | Table d'alchimie | 5h
- [ ] **Farine de Lin** | Valeur 3 | Lin ×2 | Four | —

### 11.3 Matériaux Magiques & Rares

- [ ] **Cristaux Magiques** | Valeur 8 | Drop : tous les mobs
- [ ] **Essence d'Ombre** | Valeur 15 | Drop : Spectre (rare)
- [ ] **Étoffe Fantomatique** | Valeur 9 | Drop : Spectre
- [ ] **Fragment d'Esprit** | Valeur 25 | Drop : Seigneur Démoniaque, Spectre d'oubli

### 11.4 Composants de Monstres (Mob Drops)

- [ ] **Gelée de Slime** | Valeur 2 | Drop : Slime
- [ ] **Dent de Gobelin** | Valeur 3 | Drop : Gobelin
- [ ] **Os de Berserker** | Valeur 6 | Drop : Orque Berserker
- [ ] **Venin** | Valeur 5 | Drop : Vipère, Basilic caverneux
- [ ] **Écaille de Dragon** | Valeur 10 | Drop : Dragonnet de Feu
- [ ] **Cœur de Flamme** | Valeur 15 | Drop : Dragonnet de Feu (rare)
- [ ] **Corne Démoniaque** | Valeur 18 | Drop : Seigneur Démoniaque
- [ ] **Éclat du Chaos** | Valeur 20 | Drop : Seigneur Démoniaque
- [ ] **Œil de Cyclope** | — | Drop : Cyclope (rare)
- [ ] **Totem Corrompu** | — | Drop : Chaman Corrompu (rare)
- [ ] **Cœur des Ténèbres** | — | Drop : Seigneur Démoniaque (rare)

### 11.5 Ingrédients Culinaires

- [ ] **Œuf** | Valeur 3 | Ferme (poules), Marchand
- [ ] **Viande de Loup** | Valeur 6 | Drop : Loup
- [ ] **Carotte** | Valeur 4 | Jardin, Ferme
- [ ] **Champignons** | Valeur 5 | Récolte forêt, caverne
- [ ] **Piment Noir** | Valeur 8 | Zone volcanique, Achat
- [ ] **Herbes Sauvages** | Valeur 4 | Récolte forêt, plaine
- [ ] **Viande de Gobelin** | Valeur 5 | Drop : Gobelin
- [ ] **Viande de Vipère** | Valeur 6 | Drop : Vipère
- [ ] **Viande de Dragon** | Valeur 15 | Drop : Dragonnet de Feu (rare)
- [ ] **Viande de Sanglier** | Valeur 15 | Drop : Sanglier
- [ ] **Herbes Rares** | Valeur 10 | Jardin magique, Drop : Chaman corrompu
- [ ] **Farine de Lin** | Valeur 3 | Lin ×2 (Four)

---

## 12. Plats et Fermentés

### Plats Simples

- [ ] **Pain de Lin** | Satiété 20 | Farine de lin ×2, Eau ×1 | Aucun effet
- [ ] **Soupe Claire** | Satiété 15 | Eau ×1, Champignon ×1 | +5 PV
- [ ] **Omelette aux Herbes** | Satiété 25 | Œuf ×2, Herbes sauvages ×1 | +5 énergie

### Plats Nourrissants

- [ ] **Ragoût de Loup** | Satiété 40 | Viande de loup ×2, Carotte ×1, Eau ×1 | +10 défense pendant 60s
- [ ] **Brochette Forestière** | Satiété 35 | Viande ×1, Champignons ×2, Sel ×1 | +5 agilité pendant 30s
- [ ] **Curry de Gobelin** | Satiété 45 | Viande de gobelin ×1, Piment noir ×1, Eau ×1 | +10 force pendant 30s
- [ ] **Tartine aux Baies Noires** | Satiété 30 | Pain ×1, Baies noires ×3 | +5 moral, soigne stress

### Plats Exotiques

- [ ] **Soupe Spectrale** | Satiété 35 | Étoffe fantomatique ×1, Eau ×2, Champignons ×2 | +10 magie pendant 60s
- [ ] **Tartare de Vipère** | Satiété 40 | Viande de vipère ×1, Herbes ×1, Sel ×1, Huile de bœuf ×1 | Immunité poison 60s
- [ ] **Filet de Dragon Grillé** | Satiété 50 | Viande de dragon ×1, Cœur de flamme ×1, Herbes rares ×1 | +25% dégâts pendant 60s
- [ ] **Tourte de Mana** | Satiété 30 | Farine ×2, Œuf ×1, Cristal magique ×1, Sel ×1 | +30 mana instant, +10 mana/30s

### Boissons Fermentées

- [ ] **Bière** | Houblon ×3 | Fermentation 3 jours in-game
- [ ] **Hydromel** | Miel ×3 | Fermentation 5 jours in-game

---

## 13. Cultures

- [ ] **Lin** | Pousse 2.5 jours | Artisanat textile
- [ ] **Carotte** | Pousse 3 jours | Cuisine
- [ ] **Champignons** | Pousse 2 jours | Cuisine + Alchimie
- [ ] **Baie Noire** | Pousse 3 jours | Cuisine, teinture
- [ ] **Piment Noir** | Pousse 4 jours | Cuisine
- [ ] **Herbes Sauvages** | Pousse 2 jours | Cuisine de base, potions mineures
- [ ] **Herbes Rares** | Pousse 5 jours | Alchimie avancée, potions puissantes
- [ ] **Plante Médicinale** | Pousse 3 jours | Base pour potions de soin

---

## 14. Recherches (39)

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
