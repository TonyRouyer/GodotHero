# Contenu du Jeu — Listes Exhaustives

> Suivi de l'implémentation du contenu. Chaque item est ajouté au fur et à mesure de son implémentation.
> Fichiers associés : [`../readme.md`](../readme.md) | [`gamedesign.md`](gamedesign.md) | [`backlog.md`](backlog.md)

**Légende** : `- [x]` = implémenté | `- [ ]` = non implémenté

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
- [x] **Guerrier** — Armes : épée, hache | Armure : lourde | `HeroClassRegistry`

| Stat | Intervalle | Gain/niveau |
|------|-----------|-------------|
| Force | 10 – 14 | +3 |
| Défense | 10 – 14 | +2 |
| Agilité | 5 – 9 | +1 |
| Magie | 3 – 7 | +0 |
| Chance | 5 – 10 | +1 |

### 1.2 Mage (Magique)
- [x] **Mage** — Armes : bâton, grimoire | Armure : légère | `HeroClassRegistry`

| Stat | Intervalle | Gain/niveau |
|------|-----------|-------------|
| Force | 3 – 7 | +0 |
| Défense | 4 – 8 | +1 |
| Agilité | 6 – 10 | +1 |
| Magie | 12 – 16 | +4 |
| Chance | 8 – 12 | +1 |

### 1.3 Roublard (Physique)
- [ ] **Roublard** — Armes : dague | Armure : moyenne | `HeroClassRegistry`

| Stat | Intervalle | Gain/niveau |
|------|-----------|-------------|
| Force | 6 – 10 | +1 |
| Défense | 3 – 7 | +1 |
| Agilité | 12 – 16 | +3 |
| Magie | 5 – 9 | +0 |
| Chance | 10 – 14 | +2 |

### 1.4 Chasseur (Physique)
- [ ] **Chasseur** — Armes : arc | Armure : moyenne | `HeroClassRegistry`

| Stat | Intervalle | Gain/niveau |
|------|-----------|-------------|
| Force | 7 – 11 | +1 |
| Défense | 7 – 11 | +1 |
| Agilité | 11 – 15 | +2 |
| Magie | 4 – 8 | +0 |
| Chance | 8 – 12 | +2 |

### 1.5 Guérisseur (Magique)
- [ ] **Guérisseur** — Armes : bâton | Armure : légère | `HeroClassRegistry`

| Stat | Intervalle | Gain/niveau |
|------|-----------|-------------|
| Force | 4 – 8 | +0 |
| Défense | 6 – 10 | +1 |
| Agilité | 6 – 10 | +1 |
| Magie | 11 – 15 | +3 |
| Chance | 10 – 14 | +1 |

### 1.6 Invocateur (Magique)
- [ ] **Invocateur** — Armes : bâton, grimoire | Armure : légère | `HeroClassRegistry`

| Stat | Intervalle | Gain/niveau |
|------|-----------|-------------|
| Force | 3 – 7 | +0 |
| Défense | 5 – 9 | +1 |
| Agilité | 6 – 10 | +1 |
| Magie | 11 – 15 | +3 |
| Chance | 10 – 14 | +1 |

---

## 2. Classes Avancées

*(Débloquées : Salle d'Ascension)*

### Branches du Guerrier
- [ ] **Chevalier** — épée, hache, lance | lourde | `HeroClassRegistry`
- [ ] **Berserker** — épée, hache, marteaux | moyenne + lourde | `HeroClassRegistry`

### Branches du Mage
- [ ] **Sage Arcanique** — bâton, grimoire, orbe | légère | `HeroClassRegistry`
- [ ] **Maître des Éléments** — bâton, grimoire, orbe | légère | `HeroClassRegistry`

### Branches du Roublard
- [ ] **Assassin** — dague, arc | légère + moyenne | `HeroClassRegistry`
- [ ] **Ombre** — dagues, shuriken | légère + moyenne | `HeroClassRegistry`

### Branches du Chasseur
- [ ] **Ranger** — arc | moyenne | `HeroClassRegistry`
- [ ] **Archer Mystique** — arc | moyenne | `HeroClassRegistry`

### Branches du Guérisseur
- [ ] **Prêtre** — bâton, grimoire | légère | `HeroClassRegistry`
- [ ] **Druide** — bâton | légère | `HeroClassRegistry`

### Branches de l'Invocateur
- [ ] **Maître des Esprits** — bâton, grimoire | légère | `HeroClassRegistry`
- [ ] **Conjurateur Élémentaire** — bâton, grimoire, orbe | légère | `HeroClassRegistry`

---

## 3. Compétences par Classe

*Format : `- [ ] Nom | Active/Passive | Rang | Effet | CD | Mana`*

### 3.1 Guerrier (20)
- [ ] **Coup Direct** | A | F | Coups unique (degat de base +10%)  | CD 3s
- [ ] **Endurance** | P | F | +5% résistance dégâts physiques
- [ ] **Taillade** | A | E | coups unique (degat de base +20% dégâts si ennemi < 50% PV) | CD 6s
- [ ] **Entraînement au Bouclier** | P | E | −10% dégâts reçus (bouclier)
- [ ] **Rage** | A | D | +15% Force pendant 15s | CD 30s
- [ ] **Durcissement** | P | D | +10% Défense permanente
- [ ] **Coup de Bouclier** | A | C | 50% dégâts arme + stun 2s | CD 12s
- [ ] **Résilience** | P | C | −5% tous les dégâts entrants
- [ ] **Attaque Frénétique** | A | C | 5 coups rapides à 75% dégâts chacun | CD 15s
- [ ] **Cri de Guerre** | A | B | +10% Force & Défense alliés proches 30s | CD 45s
- [ ] **Maîtrise de l'Épée** | P | B | +15% dégâts épée
- [ ] **Briseur d'Armure** | A | B | −20% Défense ennemi 10s | CD 30s
- [ ] **Implacable** | P | B | +2% PV max récupérés par kill
- [ ] **Maîtrise du Bouclier** | P | A | −15% dégâts toutes attaques
- [ ] **Frappe du Jugement** | A | A | 200% dégâts + −25% DEF ennemi 10s | CD 30s
- [ ] **Fureur de Bataille** | A | A | +30% dégâts, −50% durée effets négatifs 20s | CD 45s
- [ ] **Invincible** | A | S | Invulnérable 10s | CD 60s
- [ ] **Maître d'Armes** | P | S | +20% dégâts toutes armes
- [ ] **Défenseur du Roi** | A | S | −10% dégâts alliés proches, transfère 5% à soi 30s | CD 60s
- [ ] **Coup de Grâce** | A | S | Tue instantanément un ennemi < 20% PV | CD 90s

### 3.2 Mage (19)
- [ ] **Projectiles Magiques** | A | F | Projectiles légers | CD 3s | 10 mana
- [ ] **Protection Mineure** | A | F | −5% dégâts subis 15s | CD 20s | 8 mana
- [ ] **Boule de Feu** | A | E | Dégâts de feu cible unique | CD 5s | 15 mana
- [ ] **Maîtrise du Mana** | P | E | +10% régénération mana
- [ ] **Éclair** | A | E | Dégâts foudre + 2s stun (chance) | CD 5s | 14 mana
- [ ] **Bouclier Magique** | A | D | Absorbe 50% des dégâts 10s | CD 25s | 20 mana
- [ ] **Explosion Arcanique** | A | C | Dégâts magiques zone 50px | CD 30s | 30 mana
- [ ] **Canalisation** | A | C | +15% dégâts sorts 20s | CD 35s | 25 mana
- [ ] **Flammes Infernales** | A | C | Colonne de feu continue zone 10s | CD 30s | 35 mana
- [ ] **Gelure** | A | B | Dégâts glace + immobilise 5s | CD 45s | 28 mana
- [ ] **Nova de Glace** | A | B | Dégâts glace zone + −50% vitesse 5s | CD 45s | 32 mana
- [ ] **Volonté de Fer** | P | B | −25% durée effets négatifs sur soi
- [ ] **Tempête de Foudre** | A | A | Dégâts multi-cibles large zone | CD 45s | 40 mana
- [ ] **Drain de Vie** | A | A | Draine 10% PV cible 5s, soigne mage | CD 45s | 35 mana
- [ ] **Explosion Magique** | A | A | Explosion massive zone 75px | CD 45s | 45 mana
- [ ] **Maîtrise des Arcanes** | P | S | +25% dégâts de tous les sorts
- [ ] **Inversion des Sorts** | A | S | Renvoie sorts ciblés 5s | CD 30s | 30 mana
- [ ] **Flamme Éternelle** | A | S | Flamme continue large zone 15s | CD 60s | 50 mana
- [ ] **Métamorphose** | A | S | Entité magique 20s : +50% dégâts magie, −30% dégâts subis | CD 90s | 60 mana

### 3.3 Roublard (17)
- [ ] **Coup Rapide** | A | F | +10% dommage rapide | CD 3s
- [ ] **Esquive** | A | F | +5% esquive 10s | CD 20s
- [ ] **Lancer de Dague** | A | E | 20% dommage à distance | CD 5s
- [ ] **Camouflage** | A | E | Invisible 5s, −100 aggro | CD 15s
- [ ] **Coup Bas** | A | D | 20% dommage + −10% DEF ennemi 5s | CD 12s
- [ ] **Maître des Poisons** | P | D | +15% dégâts des poisons
- [ ] **Pas de l'Ombre** | A | C | Téléportation derrière ennemi + coup critique | CD 15s
- [ ] **Piège** | A | C | Immobilise ennemi 3s | CD 20s
- [ ] **Attaque Furtive** | P | C | +30% dégâts si en mode furtif
- [ ] **Coup Critique** | A | B | +20% chance critique 10s | CD 20s
- [ ] **Maître des Ombres** | P | B | +30% durée compétences furtivité
- [ ] **Paralysie** | A | B | Paralyse ennemi 5s | CD 25s
- [ ] **Saignée** | A | A | 30% dommage + saignement | CD 25s
- [ ] **Danse des Lames** | A | A | Série attaques rapides 30% dommage zone 30px | CD 25s
- [ ] **Évasion** | A | A | 50% esquive toutes attaques 10s | CD 30s
- [ ] **Assassinat** | A | S | 50% dommage + 25% chance kill instant si < 30% PV | CD 60s
- [ ] **Toxines Mortelles** | A | S | Toutes attaques empoisonnées 15s | CD 60s

### 3.4 Chasseur (14)
- [ ] **Tir Précis** | A | F | 20% dommage précision accrue | CD 3s
- [ ] **Flèche Empoisonnée** | A | F | 10% dommage + empoisonne la cible | CD 5s
- [ ] **Tir Rapide** | A | E | 2 flèches à 15% dommage chacune | CD 10s
- [ ] **Œil de Faucon** | P | E | +10% portée, +10% dégâts arc
- [ ] **Tir Explosif** | A | D | 20% dommage zone autour de la cible | CD 10s
- [ ] **Flèche Enflammée** | A | C | Dégâts de feu sur la durée | CD 12s
- [ ] **Piège à Loups** | A | C | Immobilise ennemi 5s | CD 20s
- [ ] **Flèche Perforante** | A | B | 20% dommage, ignore 20% DEF cible | CD 18s
- [ ] **Tir en Cascade** | A | B | 5 flèches multi-cibles à 15% dommage chacune | CD 20s
- [ ] **Concentration** | P | A | +5% chance de coup critique
- [ ] **Flèche Mortelle** | A | A | 50% dommage + 50% chance crit accrue | CD 30s
- [ ] **Piqûre de Scorpion** | A | A | Paralyse et empoisonne cible 3s | CD 25s
- [ ] **Tir Légendaire** | A | S | 300% dégâts + kill instant si < 20% PV (chance) | CD 60s
- [ ] **Pluie de Flèches** | A | S | Salve large zone, dégâts massifs tous ennemis | CD 45s

### 3.5 Guérisseur (14)
- [ ] **Soin Mineur** | A | F | Soigne 15% PV allié | CD 3s | 10 mana
- [ ] **Lumière Purificatrice** | A | F | Dissipe 1 effet négatif allié | CD 5s | 8 mana
- [ ] **Bouclier de Lumière** | A | E | Bouclier absorbant 15% dommages 10s | CD 5s | 15 mana
- [ ] **Régénération** | A | E | +2% PV/s allié pendant 10s | CD 20s | 20 mana
- [ ] **Prière** | A | D | +10% DEF alliés zone 50px 15s | CD 20s | 18 mana
- [ ] **Soin de Groupe** | A | C | Soigne 20% PV tous alliés zone 50px | CD 20s | 25 mana
- [ ] **Barrière Protectrice** | A | C | −15% dégâts tous alliés 10s | CD 25s | 30 mana
- [ ] **Lumière Divine** | A | B | Soigne 40% PV allié + dissipe tous effets négatifs | CD 25s | 35 mana
- [ ] **Main de Lumière** | A | B | Soigne 50% PV allié instantanément | CD 20s | 30 mana
- [ ] **Purification de Masse** | A | A | Dissipe tous effets négatifs alliés zone 50px | CD 30s | 35 mana
- [ ] **Bouclier Sacré** | A | A | Absorbe tous dégâts pour 1 allié 10s | CD 35s | 40 mana
- [ ] **Soin Suprême** | A | S | Soigne 75% PV tous alliés zone 75px | CD 45s | 60 mana
- [ ] **Résurrection** | A | S | Ressuscite tous alliés tombés à 30% PV | CD 90s | 70 mana
- [ ] **Bénédiction Divine** | A | S | +20% toutes stats alliés zone 75px 15s | CD 60s | 50 mana

### 3.6 Invocateur (15)
- [ ] **Invocation Mineure** | A | F | Invoque familier mineur 10s | CD 30s | 10 mana
- [ ] **Maîtrise des Esprits** | P | F | +5% durée des invocations
- [ ] **Lien Spirituel** | A | E | +10% PV & dégâts invocations | CD 15s | 15 mana
- [ ] **Invocation de Loup Fantôme** | A | E | Loup spectral attaque ennemis 15s | CD 30s | 20 mana
- [ ] **Invocation de Golem** | A | D | Golem absorbe dégâts 15s | CD 30s | 25 mana
- [ ] **Réanimation** | A | D | Ennemi tombé combat pour soi 10s | CD — | 30 mana
- [ ] **Invocation de Feu Follet** | A | C | Feu follet explose zone 15px dégâts feu | CD 25s | 22 mana
- [ ] **Canalisation Spirituelle** | A | C | +15% puissance invocations 20s | CD 25s | 25 mana
- [ ] **Invocation d'Élémentaire** | A | C | Élémentaire aléatoire (feu/eau/terre) 30s | CD 30s | 35 mana
- [ ] **Maître des Invocations** | P | B | +20% durée des invocations
- [ ] **Invocation de Dragonnet** | A | A | Dragonnet crache flammes 15s | CD 45s | 40 mana
- [ ] **Siphon de Vie** | A | A | Draine 10% PV invocation active, soigne invocateur | CD 30s | 20 mana
- [ ] **Invocation de Phénix** | A | S | Phénix lourds dégâts feu, ressuscite 1 fois, 30s | CD 60s | 50 mana
- [ ] **Armée des Ombres** | A | S | Invoque 5 ombres attaquantes | CD 60s | 45 mana
- [ ] **Gardien Céleste** | A | S | Gardien −20% dégâts alliés zone 75px | CD 60s | 50 mana

---

## 4. Traits de Caractère

### 4.1 Traits Positifs (21)
- [ ] **Courageux** — moral ≥ 30 même sous peur
- [ ] **Altruiste** — +5 moral aux héros proches après soin/aide
- [ ] **Curieux** — +20% vitesse de recherche
- [ ] **Dévoué** — jamais de démission (moral = 0 résiste +3 jours)
- [ ] **Ambitieux** — +15% XP gagnée
- [ ] **Vigilant** — aggro réduite de 20%
- [ ] **Empathique** — détecte les besoins critiques des autres héros
- [ ] **Honnête** — +3 moral constant à la guilde
- [ ] **Optimiste** — récupère 5 moral/heure si moral < 40
- [ ] **Ingénieux** — réduit temps de craft de 10%
- [ ] **Tenace** — PV ne tombent pas en dessous de 1 (1 fois/combat)
- [ ] **Charismatique** — +1 héros supplémentaire dans le pool de recrutement
- [ ] **Loyal** — +10% dégâts si un allié est mort dans le même combat
- [ ] **Prudent** — prend 15% moins de dégâts critiques
- [ ] **Passionné** — +10% vitesse entraînement
- [ ] **Méthodique** — +10% qualité des objets craftés
- [ ] **Spirituel** — régénère 0.5 mana/s supplémentaire
- [ ] **Généreux** — partage 10% de ses drops avec un allié aléatoire
- [ ] **Intrépide** — immunisé à la Peur
- [ ] **Stoïque** — réduit les effets de statut de 25%
- [ ] **Adaptable** — bonus +5% à toutes les stats selon l'ennemi dominant

### 4.2 Traits Négatifs (21)
- [ ] **Peureux** — −10 moral si un allié meurt ; risque de fuite
- [ ] **Avare** — réclame une prime de 1× salaire tous les 5 jours
- [ ] **Paresseux** — −20% vitesse de travail/entraînement
- [ ] **Impulsif** — attaque toujours le mob le plus proche (ignore l'IA aggro)
- [ ] **Arrogant** — −5 moral aux héros proches
- [ ] **Méfiant** — ne peut pas partager la même chambre (+moral réduit)
- [ ] **Pessimiste** — moral descend 20% plus vite
- [ ] **Maladroit** — 10% de chance de rater un craft (perd les ressources)
- [ ] **Lunatique** — moral varie aléatoirement ±5/heure
- [ ] **Susceptible** — −10 moral lors d'un événement négatif (×2 effet)
- [ ] **Indiscipliné** — ignore le planning 20% du temps
- [ ] **Rancunier** — −8 moral si un autre héros est promu à sa place
- [ ] **Manipulateur** — vol discret d'or (−5 or/jour, difficile à détecter)
- [ ] **Hypocondriaque** — considère tout soin comme "insuffisant" (−5 moral constant)
- [ ] **Kleptomane** — vole occasionnellement des ressources de l'inventaire
- [ ] **Jaloux** — −5 moral si un allié porte un équipement de rang supérieur
- [ ] **Colérique** — déclenche parfois un "Conflit interne" aléatoirement
- [ ] **Mégalomane** — réclame le lit/objet le mieux équipé sinon −10 moral
- [ ] **Procrastinateur** — démarre les tâches avec 30s de délai
- [ ] **Désorganisé** — perd 5% du gain XP de craft
- [ ] **Insomniaque** — énergie se régénère 30% moins vite au lit

---

## 5. Mobs

### Rang F
- [x] **Slime** | FM 0.10 | Vitesse 100 | STR 3 DEF 4 AGI 6 MAG 1 LCK 5
  - Coup gluant : puissance 4 | Charge instable (zone) : puissance 3
  - Drop : Gelée de slime ×1 | Cristal magique ×1 (rare)
- [ ] **Araignée sylvestre** | FM 0.15 | Vitesse 90 | STR 4 DEF 3 AGI 8 MAG 1 LCK 5
  - Morsure rapide : puissance 5 | Jet de toile : −30% vitesse 3s, puissance 2
  - Drop : Résine collante ×1 | Baie noire ×1 (rare) | Venin ×1–2

### Rang E
- [ ] **Loup** | FM 0.20 | Vitesse 250 | STR 8 DEF 6 AGI 12 MAG 2 LCK 5
  - Morsure sauvage : puissance 10 | Hurlement de meute : +10% AGI alliés 10s
  - Drop : Peau brute ×1–2 | Viande de loup ×1–2 | Cristal magique ×1 (rare) | Graisse animale ×1–2
- [ ] **Sanglier** | FM 0.25 | Vitesse 90 | STR 9 DEF 7 AGI 6 MAG 1 LCK 4
  - Charge bestiale : puissance 3, chance de repoussement | Grognement furieux : +10% DEF 6s
  - Drop : Viande de sanglier ×1–2 | Cuir ×1 | Graisse animale ×1–3 | Peau brute ×1–2
- [ ] **Soldat squelette** | FM 0.20 | Vitesse 100 | STR 7 DEF 6 AGI 5 MAG 2 LCK 3
  - Coup d'épée rouillée : puissance 8 | Cri spectral : −5 DEF 5s
  - Drop : Métal brut ×1 | Cristaux magiques ×1 | Os de berserker ×1 (rare)

### Rang D
- [ ] **Gobelin** | FM 0.15 | Vitesse 120 | STR 5 DEF 4 AGI 8 MAG 3 LCK 8
  - Coup de poignard : puissance 7 | Jet de pierre : 10% stun 3s, puissance 5
  - Drop : Dents de gobelin ×2–3 | Viande de gobelin ×1 | Métal ×1–4 | Cristal magique ×1 (rare)
- [ ] **Vipère** | FM 0.25 | Vitesse 150 | STR 6 DEF 5 AGI 14 MAG 4 LCK 8
  - Morsure venimeuse : poison 2 dégâts/s 5s, puissance 6 | Constriction : immobilise 2s, puissance 4
  - Drop : Venin ×1–2 | Viande de vipère ×1 | Cristal magique ×1 (rare)
- [ ] **Esprit des ruines** | FM 0.35 | Vitesse 110 | STR 2 DEF 5 AGI 10 MAG 12 LCK 6
  - Toucher spectral : dégâts magiques purs, puissance 9 | Hurlement du passé : peur 3s + −5% intelligence
  - Drop : Essence d'ombre ×1 | Étoffe fantomatique ×1 | Cristaux magiques ×1

### Rang C
- [ ] **Orque Berserker** | FM 0.40 | Vitesse 100 | STR 14 DEF 10 AGI 7 MAG 2 LCK 4
  - Coup de massue : puissance 3 | Frénésie sanglante : +5 STR, −5 DEF 15s
  - Drop : Os de berserker ×1 | Cristal magique ×1 (rare)
- [ ] **Spectre Hanté** | FM 0.40 | Vitesse 100 | STR 3 DEF 7 AGI 12 MAG 15 LCK 6
  - Drain vital : soigne 50% des dégâts, puissance 8 | Hurlement surnaturel : peur 3s
  - Drop : Étoffe fantomatique ×1–2 | Essence d'ombre ×1 (rare) | Cristal magique ×1
- [ ] **Chasseur elfe noir** | FM 0.45 | Vitesse 130 | STR 10 DEF 8 AGI 14 MAG 6 LCK 10
  - Tir empoisonné : poison 3 dégâts/s, puissance 8 | Flèche runique : silence 4s, puissance 10
  - Drop : Baie noire ×1–2 | Ambre ×1 | Rune magique ×1 (rare)

### Rang B
- [ ] **Cyclope** | FM 0.50 | Vitesse 80 | STR 18 DEF 16 AGI 4 MAG 3 LCK 5
  - Coup massif : puissance 18 | Piétinement : −15% AGI zone 10s, puissance 8
  - Drop : Peau brute ×2–4 | Œil de cyclope ×1 (rare) | Cristal magique ×1 (rare)
- [ ] **Chaman Corrompu** | FM 0.35 | Vitesse 100 | STR 5 DEF 6 AGI 8 MAG 18 LCK 7
  - Flamme noire : brûle 5 dégâts/s 5s | Malédiction des ombres : −5% STR & DEF 15s
  - Drop : Essence d'ombre ×1–2 | Totem corrompu ×1 (rare) | Cristal magique ×1
- [ ] **Gardien de lave** | FM 0.50 | Vitesse 80 | STR 14 DEF 14 AGI 3 MAG 10 LCK 4
  - Poing brûlant : brûlure 5s, puissance 16 | Explosion de lave : AoE feu, 15 dégâts + lenteur 2s
  - Drop : Charbon ×2 | Cœur de flamme ×1 | Lingot d'acier ×1 (rare)
- [ ] **Basilic caverneux** | FM 0.55 | Vitesse 100 | STR 12 DEF 12 AGI 8 MAG 3 LCK 5
  - Morsure paralysante : stun 2s, puissance 12 | Regard pétrifiant : 10% gel 1 cible 3s
  - Drop : Venin ×1 | Écaille de dragon ×1–2 | Graisse animale ×1–2

### Rang A
- [ ] **Dragonnet de Feu** | FM 0.50 | Vitesse 150 | STR 12 DEF 10 AGI 9 MAG 14 LCK 8
  - Griffure : puissance 14 | Souffle enflammé : brûlure 10 dégâts/s 3s
  - Drop : Écaille de dragon ×2–3 | Viande de dragonnet ×1 | Cœur de flamme ×1 (rare) | Cristal magique ×1 | Graisse animale ×1–3
- [ ] **Ent ancien** | FM 0.65 | Vitesse 70 | STR 16 DEF 18 AGI 4 MAG 10 LCK 7
  - Écrasement racinaire : AoE physique, puissance 16 | Renaissance sylvestre : soigne alliés végétaux 10%
  - Drop : Ambre ×2 | Résine collante ×2 | Bois renforcé ×1

### Rang S
- [ ] **Seigneur Démoniaque** | FM 1.00 | Vitesse 110 | STR 20 DEF 18 AGI 12 MAG 22 LCK 15
  - Frappe du chaos : puissance 20 | Souffle infernal : zone, brûlure 15 dégâts/s 4s
  - Drop : Corne démoniaque ×1–2 | Cœur des ténèbres ×1 (rare) | Éclat du chaos ×2–3 | Cristal magique ×1 | Fragment d'esprit ×1 (rare)
- [ ] **Spectre d'oubli** | FM 1.00 | Vitesse 150 | STR 8 DEF 10 AGI 16 MAG 20 LCK 12
  - Drain mental : −10% mana + dégâts magiques, puissance 12 | Brume de l'oubli : silence zone 3s, puissance 6
  - Drop : Fragment d'esprit ×1 | Essence d'ombre ×1 | Cristal magique ×1

---

## 6. Armes

### 6.1 Épées *(Guerrier, Chevalier, Berserker)*

- [x] **Épée d'Entraînement** | F | Atk +5 | Bois ×2 | 5 or
- [x] **Épée du Soldat** | E | Atk +10 | Lingot de fer ×3, Cuir ×1 | 80 or
- [ ] **Épée Longue** | D | Atk +15 | Lingot de fer ×4, Bois renforcé ×2 | 200 or
- [ ] **Lame de Chevalier** | C | Atk +20 | Lingot d'acier ×2, Ambre ×2, Cuir souple ×1 | 450 or
- [ ] **Épée Draconique** | A | Atk +25 | Lingot d'acier trempé ×2, Écailles de dragon ×2, Cœur de flamme ×1 | 2 000 or

### 6.2 Haches *(Guerrier, Chevalier, Berserker)*

- [ ] **Hachette de Bûcheron** | F | Atk +8 | Bois ×2, Lingot de fer ×1 | 20 or
- [ ] **Hache de Guerre** | E | Atk +14 | Lingot de fer ×2, Bois ×1, Cuir ×1 | 90 or
- [ ] **Hache Double** | D | Atk +18 | Lingot de fer ×4, Cuir tanné ×1 | 210 or
- [ ] **Hache Viking** | C | Atk +22 | Lingot d'acier ×3, Ambre ×1, Cuir souple ×1 | 500 or

### 6.3 Lances *(Chevalier, Ranger)*

- [ ] **Lance de Chasse** | F | Atk +7 | Bois ×2, Lingot de fer ×1 | 10 or
- [ ] **Pique du Soldat** | E | Atk +12 | Lingot de fer ×3, Cuir ×1 | 85 or
- [ ] **Lance Royale** | D | Atk +17 | Lingot d'acier ×2, Ambre ×2, Cuir tanné ×1 | 205 or
- [ ] **Trident de Bataille** | C | Atk +20 | Lingot d'acier ×3, Essence d'ombre ×1 | 470 or
- [ ] **Lance des Tempêtes** | A | Atk +25 | Essence de vent ×2, Rune magique ×1, Lingot d'acier ×3 | 2 100 or

### 6.4 Dagues *(Roublard, Assassin, Ombre)*

- [ ] **Dague de Voleur** | F | Atk +5 | Lingot de fer ×1, Cuir ×1 | 12 or
- [ ] **Lame de Serpent** | D | Atk +10 | Lingot de fer ×2, Venin ×1 | 180 or
- [ ] **Karambit** | C | Atk +12 | Lingot d'acier ×2, Cuir souple ×1 | 420 or

### 6.5 Marteaux *(Berserker)*

- [ ] **Marteau de Forgeron** | F | Atk +9 | Bois brut ×2, Métal brut ×1 | 22 or
- [ ] **Masse d'Armes** | E | Atk +15 | Lingot de fer ×3, Cuir tanné ×1 | 95 or
- [ ] **Marteau du Titan** | C | Atk +20 | Lingot d'acier ×3, Os de berserker ×1 | 520 or
- [ ] **Marteau des Tempêtes** | B | Atk +25 | Lingot d'acier ×3, Cristaux magiques ×2 | 1 050 or
- [ ] **Marteau du Chaos** | A | Atk +27 | Lingot d'acier trempé ×2, Éclat du chaos ×1, Cristaux magiques ×1 | 2 300 or

### 6.6 Bâtons *(Mage, Guérisseur, Invocateur, Prêtre, Druide, Sage Arcanique, Maître des Éléments, Maître des Esprits, Conjurateur Élémentaire)*

- [ ] **Bâton de Novice** | F | MAtk +6 | Bois ×2, Cristaux magiques ×1 | 10 or
- [ ] **Bâton de Chêne** | E | MAtk +10 | Bois ×2, Rune magique ×1 | 80 or
- [ ] **Bâton Magique** | D | MAtk +14 | Bois renforcé ×2, Cristaux magiques ×2 | 200 or
- [ ] **Bâton du Sage** | B | MAtk +18 | Bois renforcé ×3, Rune magique ×1 | 1 000 or

### 6.7 Arcs *(Chasseur, Ranger, Archer Mystique, Assassin)*

- [ ] **Arc Court** | F | Atk +7 | Bois ×2, Corde ×1 | 15 or
- [ ] **Arc de Chasseur** | E | Atk +12 | Bois ×3, Cuir tanné ×1, Corde ×1 | 75 or
- [ ] **Arc Long** | D | Atk +17 | Bois renforcé ×3, Corde ×1 | 190 or
- [ ] **Arc Elfique** | B | Atk +22 | Bois renforcé ×2, Ambre ×1, Rune magique ×1, Corde ×1 | 920 or

### 6.8 Orbes *(Sage Arcanique, Maître des Éléments, Conjurateur Élémentaire)*

- [ ] **Orbe de Cristal** | F | MAtk +6 | Verre ×1, Cristaux magiques ×1 | 18 or
- [ ] **Orbe des Éléments** | E | MAtk +10 | Verre ×2, Rune magique ×1 | 85 or
- [ ] **Orbe de Mana** | D | MAtk +14 | Verre ×2, Cristaux magiques ×2, Ambre ×1 | 210 or
- [ ] **Orbe Runique** | B | MAtk +18 | Verre ×2, Rune magique ×2 | 1 050 or

### 6.9 Grimoires *(Mage, Invocateur, Sage Arcanique, Prêtre, Maître des Esprits, Conjurateur Élémentaire)*

- [ ] **Grimoire de Novice** | F | MAtk +5 | Cuir ×2, Baie noire ×1 | 12 or
- [ ] **Grimoire des Ombres** | E | MAtk +9 | Cuir ×2, Cristaux magiques ×1, Baie noire ×1 | 80 or
- [ ] **Grimoire des Arcanes** | D | MAtk +13 | Cuir tanné ×3, Rune magique ×2 | 195 or
- [ ] **Grimoire de l'Archimage** | A | MAtk +17 | Cuir souple ×3, Baie noire ×2, Cristaux magiques ×2 | 2 050 or

### 6.10 Shurikens *(Ombre)*

- [ ] **Shuriken Simple** | F | Atk +4 | Lingot de fer ×1 | 10 or
- [ ] **Shuriken Tranchant** | E | Atk +6 | Lingot de fer ×2 | 65 or
- [ ] **Étoile de Lancer** | D | Atk +8 | Lingot d'acier ×3 | 170 or
- [ ] **Shuriken Empoisonné** | C | Atk +10 | Lingot d'acier ×2, Venin ×1 | 400 or

---

## 7. Armures

### 7.1 Armures Lourdes *(Guerrier, Chevalier, Berserker)*

#### Torse
- [ ] **Cuirasse de Soldat** | E | Def +15 | Lingot de fer ×3, Cuir ×2, Rivets en acier ×2 | 150 or
- [ ] **Armure de Chevalier** | D | Def +18 | Lingot d'acier ×3, Rivets en acier ×2, Cuir ×1 | 320 or
- [ ] **Armure de Guerre** | B | Def +20 | Lingot d'acier trempé ×3, Rivets en acier ×2, Os de berserker ×1 | 1 400 or
- [ ] **Plastron Volcan** | A | Def +20 | Lingot d'acier trempé ×3, Charbon ×2, Cœur de flamme ×1 | 2 800 or
- [ ] **Armure de Bataille** | S | Def +22 | Lingot d'acier trempé ×2, Rivets en acier ×3, Cuir souple ×1, Cœur de flamme ×1 (rare) | 6 500 or

#### Tête
- [ ] **Heaume de Soldat** | E | Def +12 | Lingot de fer ×3, Rivets en acier ×2 | 100 or
- [ ] **Casque de Chevalier** | D | Def +15 | Lingot d'acier ×2, Cuir tanné ×1, Rivets en acier ×2 | 220 or
- [ ] **Casque des Highlands** | A | Def +16 | Lingot d'acier ×3, Cuir souple ×1, Essence de vent ×1 | 1 950 or
- [ ] **Heaume du Conquérant** | S | Def +18 | Lingot d'acier trempé ×2, Rivets en acier ×3, Œil de cyclope ×1 | 4 800 or

#### Jambes
- [ ] **Grèves de Soldat** | E | Def +12 | Lingot de fer ×2, Cuir tanné ×1, Rivets en acier ×1 | 100 or
- [ ] **Jambières de Chevalier** | D | Def +15 | Lingot d'acier ×2, Cuir tanné ×1, Rivets en acier ×2 | 220 or
- [ ] **Jambières de Bataille** | B | Def +18 | Lingot d'acier ×2, Lingot d'acier trempé ×1, Os de berserker ×1 | 960 or

### 7.2 Armures Légères *(Mage, Guérisseur, Invocateur, Prêtre, Druide, Sage Arcanique, Maître des Éléments, Maître des Esprits, Conjurateur Élémentaire)*

#### Torse
- [ ] **Robe de l'Apprenti** | F | Def +3 | Tissu ×3 | 20 or
- [ ] **Robe de Magicien** | E | Def +5 | Tissu ×3, Cristaux magiques ×1 | 90 or
- [ ] **Robe des Éléments** | D | Def +6 | Tissu renforcé ×2, Essence de vent ×1, Cristaux magiques ×1 | 200 or
- [ ] **Robe des Arcanes** | C | Def +7 | Tissu renforcé ×3, Rune magique ×1, Cristaux magiques ×2 | 430 or
- [ ] **Tunique d'Ombre** | B | Def +8 | Tissu renforcé ×2, Essence d'ombre ×1, Baie noire ×1 | 870 or

#### Tête
- [ ] **Chapeau de Paille** | F | Def +1 | Tissu ×1 | 12 or
- [ ] **Capuche en Lin** | F | Def +2 | Tissu ×2 | 15 or
- [ ] **Capuche Matelassée** | E | Def +4 | Tissu ×2 | 55 or
- [ ] **Chapeau d'Acolyte** | E | Def +3 | Tissu ×2, Cristaux magiques ×1 | 55 or
- [ ] **Chapeau de Druide** | E | Def +4 | Tissu ×2, Essence de vent ×1 | 60 or
- [ ] **Chapeau Mystique** | D | Def +5 | Tissu ×2, Cristaux magiques ×1, Rune magique ×1 | 130 or

#### Jambes
- [ ] **Pantalon de Lin** | F | Def +2 | Tissu ×2 | 12 or
- [ ] **Pantalon Enchanté** | E | Def +4 | Tissu ×2, Cristaux magiques ×1 | 55 or
- [ ] **Jambières de Mage** | D | Def +5 | Tissu ×2, Cristaux magiques ×1 | 130 or

### 7.3 Armures Moyennes *(Roublard, Chasseur, Ranger, Archer Mystique, Assassin, Ombre)*

#### Torse
- [ ] **Armure de Rôdeur** | E | Def +8 | Cuir tanné ×3, Rivets en acier ×2 | 120 or
- [ ] **Armure de Mercenaire** | D | Def +10 | Cuir tanné ×3, Lingot de fer ×2 | 260 or
- [ ] **Armure de l'Éclaireur** | C | Def +12 | Cuir ×2, Lingot d'acier ×2, Essence de vent ×1 | 560 or
- [ ] **Armure des Ombres** | C | Def +11 | Cuir ×2, Essence d'ombre ×1, Tissu renforcé ×1 | 560 or

#### Tête
- [ ] **Casque de Patrouilleur** | E | Def +6 | Cuir tanné ×2, Rivets en acier ×1 | 75 or
- [ ] **Casque de Chasseur** | D | Def +8 | Cuir tanné ×2, Lingot de fer ×1 | 170 or
- [ ] **Casque d'Éclaireur** | C | Def +10 | Cuir souple ×1, Lingot d'acier ×1, Essence de vent ×1 | 370 or

#### Jambes
- [ ] **Jambières du Rôdeur** | E | Def +6 | Cuir tanné ×2, Rivets en acier ×1, Baie noire ×1 | 75 or
- [ ] **Jambières de Mercenaire** | D | Def +8 | Cuir tanné ×3, Lingot de fer ×1 | 170 or
- [ ] **Jambières de l'Éclaireur** | C | Def +10 | Cuir souple ×2, Lingot d'acier ×1, Essence de vent ×1 | 370 or

---

## 8. Accessoires

### 8.1 Anneaux

- [ ] **Anneau de Fer** | F | — | Lingot de fer ×1 | 15 or
- [ ] **Anneau de Force** | D | +5 Force | Lingot d'acier ×1, Ambre ×1 | 200 or
- [ ] **Anneau du Mage** | C | +8 Intelligence | Lingot d'acier ×1, Cristaux magiques ×1 | 500 or
- [ ] **Anneau de Vivacité** | C | +5 Agilité | Lingot d'acier ×1, Ambre ×1 | 500 or
- [ ] **Anneau de Vitalité** | C | +25 HP | Lingot d'acier ×1, Plante médicinale ×1, Cristaux magiques ×1 | 500 or

### 8.2 Amulettes

- [ ] **Amulette en Bois** | F | — | Bois ×1 | 15 or
- [ ] **Amulette de Soin** | D | Régénération lente PV | Lingot d'acier ×1, Plante médicinale ×1 | 210 or
- [ ] **Amulette de Feu** | C | Résistance au feu | Lingot d'acier ×1, Cristal magique ×1 | 520 or
- [ ] **Amulette des Anciens** | B | +10% mana | Lingot d'acier ×1, Rune magique ×1 | 1 100 or
- [ ] **Amulette Runique** | B | +25 mana | Lingot d'acier ×1, Rune magique ×2 | 1 100 or

---

## 9. Potions et Consommables

### 9.1 Potions de Soin

- [ ] **Potion de Soin Mineur** | +50 PV instantanément | Eau ×1, Plante médicinale ×1 | Alchimie basique
- [ ] **Potion de Soin** | +100 PV instantanément | Eau ×1, Plante médicinale ×2 | Alchimie basique
- [ ] **Potion de Soin Majeure** | +200 PV instantanément | Eau ×2, Plante médicinale ×3, Cristal magique ×1 | Alchimie avancée

### 9.2 Potions Magiques

- [ ] **Potion de Mana Mineur** | +50 Mana | Eau ×1, Cristal magique ×1 | Alchimie basique
- [ ] **Potion de Mana** | +100 Mana | Eau ×1, Cristal magique ×2 | Alchimie basique
- [ ] **Potion de Mana Supérieure** | +200 Mana | Eau ×1, Cristal magique ×3 | Alchimie avancée

### 9.3 Potions Défensives

- [ ] **Potion de Pierre** | +20 END pendant 20s | Eau ×1, Essence d'ombre ×1 | Alchimiste expérimenté
- [ ] **Potion de Résistance au Feu** | −50% dégâts de feu 30s | Eau ×1, Cœur de flamme ×1, Cristal magique ×1 | Alchimiste expérimenté
- [ ] **Potion d'Ombre Protectrice** | −30% dégâts magiques 30s | Eau ×1, Essence d'ombre ×1, Rune magique ×1 | Alchimiste expérimenté

### 9.4 Potions Offensives

- [ ] **Potion de Force Brute** | +10 FOR pendant 30s | Eau pure ×1, Os de berserker ×1 | Alchimiste expérimenté
- [ ] **Potion de Précision** | +15% crit 30s | Eau pure ×1, Dent de gobelin ×2 | Alchimiste expérimenté
- [ ] **Potion de Vitesse** | +30% AGI 15s | Eau pure ×1, Essence de vent ×1, Cristal magique ×1 | Alchimiste expérimenté
- [ ] **Potion de Poison** | Arme empoisonnée (3 coups) | Venin ×1, Baies noires ×1, Eau ×1 | Alchimiste expérimenté
- [ ] **Potion de Canalisation** | +20% dégâts magiques 20s | Eau ×1, Essence de vent ×1, Rune magique ×1 | Alchimiste expérimenté

### 9.5 Potions Spéciales / Rares

- [ ] **Potion d'Invisibilité** | Invisibilité 10s | Eau ×1, Essence d'ombre ×1, Cristaux magiques ×1 | Alchimiste expert
- [ ] **Potion de Rage Berserk** | +25 FOR, −20% DEF 15s | Huile de bœuf ×1, Os de berserker ×1, Baies noires ×1 | Alchimiste expert
- [ ] **Potion du Chaos** | Effet aléatoire : buffs ou debuffs extrêmes | Éclat du chaos ×1, Rune magique ×1, Cristal magique ×2 | Alchimiste expert
- [ ] **Potion de Purification** | Supprime poison, brûlure, saignement, malus | Eau ×2, Plante médicinale ×2, Essence d'ombre ×1 | Alchimiste expert

---

## 10. Enchantements

*(Débloqués par les recherches Enchantement → Enchantement avancé → Enchantement expert. Irréversible, 1 max par objet. Coût en cristaux magiques.)*

### Rang C *(Recherche : Enchantement)*
- [ ] **Igni** | Arme | +6 dégâts de feu, 20% brûlure 3s | 3 jours | 5 Cristaux Magiques
- [ ] **Bouclier de Givre** | Armure | −10% dégâts reçus, +5% résistance feu | 4 jours | 7 Cristaux Magiques
- [ ] **Cape de l'Ombre** | Armure | +10% agilité, +5% esquive | 3 jours | 7 Cristaux Magiques
- [ ] **Aura de Célérité** | Armure | +10% vitesse déplacement, −5% temps attaque | 3 jours | 5 Cristaux Magiques
- [ ] **Tranchant Raffiné** | Arme | +5% chance de critique | 2.5 jours | 4 Cristaux Magiques

### Rang B *(Recherche : Enchantement avancé)*
- [ ] **Lame de Foudre** | Arme | +8 dégâts foudre, 10% paralysie 1.5s | 4 jours | 6 Cristaux Magiques
- [ ] **Lumière Purifiante** | Armure | Immunité poison/saignement, +2 PV/s regen | 4 jours | 8 Cristaux Magiques
- [ ] **Griffes Spectrales** | Arme | +5 dégâts d'ombre, 10% ignore armure | 3 jours | 6 Cristaux Magiques
- [ ] **Rune du Titan** | Armure | +15% défense physique, +10% poids max | 5 jours | 9 Cristaux Magiques
- [ ] **Sceau des Arcanes** | Bijou | +10% puissance magique, +10 mana max | 4 jours | 8 Cristaux Magiques

### Rang A *(Recherche : Enchantement expert)*
- [ ] **Bénédiction du Gardien** | Armure | 10% dégâts redirigés vers porteur, +3% armure magique | 5 jours | 9 Cristaux Magiques
- [ ] **Toucher Vampirique** | Arme | Vol de vie +3% des dégâts infligés rendus en PV | 5 jours | 10 Cristaux Magiques
- [ ] **Aura de Vaillance** | Bijou | +8% force, immunité à la peur | 5 jours | 9 Cristaux Magiques
- [ ] **Réflexe Surnaturel** | Armure | 15% chance d'esquive automatique (CD 2 tours) | 5 jours | 9 Cristaux Magiques

### Rang S *(Recherche : Maîtrise de l'Enchantement Bijoux)*
- [ ] **Voile du Néant** | Armure | 20% chance d'éviter toute attaque | 6 jours | 10 Cristaux + 1 Essence d'Ombre
- [ ] **Lame du Chaos** | Arme | +10 dégâts aléatoires (type aléatoire), 5% confusion | 6 jours | 12 Cristaux + 1 Éclat du Chaos
- [ ] **Aura d'Ascension** | Bijou | +10% toutes stats principales, bonus moral constant | 7 jours | 12 Cristaux + 1 Fragment d'Esprit
- [ ] **Égide Totale** | Armure | −25% dégâts, +10% résistance magie, −10% vitesse | 6 jours | 11 Cristaux + 1 Écaille de Dragon

---

## 11. Matériaux et Ressources

### 11.1 Ressources Naturelles
- [x] **Bois** | Valeur 2 or | Forêt, Achat | `MaterialLibrary`
- [ ] **Pierre** | Valeur 3 or | Montagne, Achat
- [ ] **Lin** | Valeur 2 or | Culture, Achat
- [ ] **Eau** | Valeur 1 or | Puits, Achat
- [ ] **Sel** | Valeur 1 or | Récolte, Achat
- [ ] **Baie noire** | Valeur 1 or | Culture, Achat
- [ ] **Plante médicinale** | Valeur 3 or | Culture, Achat
- [ ] **Ambre** | Valeur 11 or | Récolte, Achat
- [ ] **Résine collante** | Valeur 5 or | Récolte, Achat
- [ ] **Métal brut** | Valeur 3 or | Récolte, Achat
- [ ] **Graisse animale** | Valeur 3 or | Loot : loup, vipère, cyclope
- [ ] **Peau brute** | Valeur 3 or | Loot : loup, sanglier, cyclope
- [ ] **Sable** | Valeur 2 or | Plage, désert, Achat

### 11.2 Matériaux Craftables
- [ ] **Corde** | Atelier | Lin ×3 | 1h | Valeur 3 or
- [ ] **Fil résistant** | Atelier | Lin ×2, Résine collante ×1 | 2h | Valeur 4 or
- [ ] **Tissu** | Métier à tisser | Lin ×2 | 1h | Valeur 3 or
- [ ] **Tissu renforcé** | Métier à tisser | Tissu ×1, Fil résistant ×1 | 2h | Valeur 3 or
- [ ] **Cuir** | Atelier de tannage | Peau brute ×1, Eau ×1 | 1h | Valeur 3 or
- [ ] **Cuir tanné** | Atelier de tannage | Cuir ×2, Sel ×1, Eau ×1 | 2h | Valeur 5 or
- [ ] **Cuir souple** | Atelier de tannage | Cuir tanné ×2, Huile de bœuf ×1 | 3h | Valeur 8 or
- [ ] **Lingot de fer** | Forge | Métal brut ×2 | 2h | Valeur 4 or
- [ ] **Lingot d'acier** | Forge | Métal brut ×3, Charbon ×1 | 3h | Valeur 6 or
- [ ] **Lingot d'acier trempé** | Forge | Lingot d'acier ×2, Huile de trempe ×1, Résine collante ×1, Eau ×1 | 4h | Valeur 9 or
- [ ] **Rivets en acier** | Forge | Métal brut ×1 | 1h | Valeur 3 or
- [ ] **Huile de bœuf** | Table d'alchimie | Graisse animale ×2, Plante médicinale ×1 | 2h | Valeur 4 or
- [ ] **Huile de trempe** | Table d'alchimie | Huile de bœuf ×1, Résine collante ×1, Eau ×1 | 3h | Valeur 7 or
- [ ] **Bois renforcé** | Atelier | Bois ×2, Résine collante ×1 | 2h | Valeur 15 or
- [ ] **Essence de vent** | Table d'alchimie | Cristaux magiques ×2, Gelée de slime ×1 | 4h | Valeur 12 or
- [ ] **Rune magique** | Table d'alchimie | Cristal magique ×1, Baie noire ×1, Étoffe fantomatique ×1 | 5h | Valeur 15 or
- [ ] **Charbon** | Forge | Bois ×2 | 1h | Valeur 3 or
- [ ] **Verre** | Forge | Sable ×2, Charbon ×1 | 2h | Valeur 3 or

### 11.3 Matériaux Magiques & Rares
- [ ] **Cristaux magiques** | Valeur 8 or | Loot : tous les mobs
- [ ] **Essence d'ombre** | Valeur 15 or | Drop : Spectre (rare)
- [ ] **Étoffe fantomatique** | Valeur 9 or | Drop : Spectre
- [ ] **Fragment d'esprit** | Valeur 25 or | Drop : Seigneur Démoniaque, Spectre d'oubli (rare)

### 11.4 Composants de Monstres
- [x] **Gelée de slime** | Valeur 2 or | Drop : Slime
- [ ] **Dent de gobelin** | Valeur 3 or | Drop : Gobelin
- [ ] **Os de berserker** | Valeur 6 or | Drop : Orque Berserker
- [ ] **Venin** | Valeur 5 or | Drop : Vipère, Basilic caverneux
- [ ] **Écailles de dragon** | Valeur 10 or | Drop : Dragonnet de Feu, Basilic caverneux
- [ ] **Cœur de flamme** | Valeur 15 or | Drop : Dragonnet de Feu (rare), Gardien de lave
- [ ] **Corne démoniaque** | Valeur 18 or | Drop : Seigneur Démoniaque (trophée à vendre)
- [ ] **Éclat du chaos** | Valeur 20 or | Drop : Seigneur Démoniaque
- [ ] **Œil de cyclope** | Valeur — | Drop : Cyclope (rare)
- [ ] **Totem corrompu** | Valeur — | Drop : Chaman Corrompu (rare)
- [ ] **Cœur des ténèbres** | Valeur — | Drop : Seigneur Démoniaque (rare)

### 11.5 Ingrédients Culinaires
- [ ] **Œuf** | Valeur 3 or | Ferme, Marchand
- [ ] **Viande de loup** | Valeur 6 or | Loot : Loup
- [ ] **Carotte** | Valeur 4 or | Jardin, Ferme
- [ ] **Champignons** | Valeur 5 or | Forêt sombre, Caverne
- [ ] **Piment noir** | Valeur 8 or | Zone volcanique, Achat
- [ ] **Herbes sauvages** | Valeur 4 or | Forêt claire, Plaine
- [ ] **Viande de gobelin** | Valeur 5 or | Loot : Gobelin
- [ ] **Viande de vipère** | Valeur 6 or | Loot : Vipère
- [ ] **Viande de dragon** | Valeur 15 or | Loot rare : Dragonnet de Feu
- [ ] **Viande de sanglier** | Valeur 15 or | Loot : Sanglier
- [ ] **Herbes rares** | Valeur 10 or | Jardin magique, Chaman Corrompu
- [ ] **Farine de lin** | Valeur 3 or | Lin ×2 (Four)
- [ ] **Miel** | Valeur 2 or | Ruche
- [ ] **Houblon** | Valeur 1 or | Culture

---

## 12. Plats et Fermentés

### 12.1 Plats Simples
- [ ] **Pain de Lin** | Satiété 20 | Aucun effet | Farine de lin ×2, Eau pure ×1
- [ ] **Soupe Claire** | Satiété 15 | +5 PV | Eau pure ×1, Champignon ×1
- [ ] **Omelette aux Herbes** | Satiété 25 | +5 énergie | Œuf ×2, Herbes sauvages ×1

### 12.2 Plats Nourrissants
- [ ] **Ragoût de Loup** | Satiété 40 | +10 défense 60s | Viande de loup ×2, Carotte ×1, Eau pure ×1
- [ ] **Brochette Forestière** | Satiété 35 | +5 agilité 30s | Viande ×1, Champignons ×2, Sel ×1
- [ ] **Curry de Gobelin** | Satiété 45 | +10 force 30s | Viande de gobelin ×1, Piment noir ×1, Eau pure ×1
- [ ] **Tartine aux Baies Noires** | Satiété 30 | +5 moral, soigne stress | Pain ×1, Baies noires ×3

### 12.3 Plats Exotiques
- [ ] **Soupe Spectrale** | Satiété 35 | +10 magie 60s | Étoffe fantomatique ×1, Eau pure ×2, Champignons ×2
- [ ] **Tartare de Vipère** | Satiété 40 | Immunité poison 60s | Viande de vipère ×1, Herbes ×1, Sel ×1, Huile de bœuf ×1
- [ ] **Filet de Dragon Grillé** | Satiété 50 | +25% dégâts 60s | Viande de dragon ×1, Cœur de flamme ×1, Herbes rares ×1
- [ ] **Tourte de Mana** | Satiété 30 | +30 mana instant, +10 mana/30s | Farine de lin ×2, Œuf ×1, Cristal magique ×1, Sel ×1

### 12.4 Fermentés *(Brassage)*
- [ ] **Bière** | Houblon ×3 | 3 jours fermentation
- [ ] **Hydromel** | Miel ×3 | 5 jours fermentation

---

## 13. Cultures *(Jardin Botanique)*

- [ ] **Lin** | 2.5 jours | Artisanat textile
- [ ] **Carotte** | 3 jours | Cuisine
- [ ] **Champignons** | 2 jours | Cuisine + Alchimie
- [ ] **Baies noires** | 3 jours | Teinture / Cuisine
- [ ] **Piment noir** | 4 jours | Cuisine
- [ ] **Herbes sauvages** | 2 jours | Cuisine / Potions mineures
- [ ] **Herbes rares** | 5 jours | Alchimie avancée / Potions puissantes
- [ ] **Plante médicinale** | 3 jours | Potions de soin

---

## 14. Recherches (39)

### Niveau 1

- [x] **Forge basique** | Salle forge, forge, enclume, plans F+E, plan charbon, verre | 200 or
- [x] **Couture rudimentaire** | Salle couture, métier à tisser, chevalet de tannage, plans F+E, plan tissu | 150 or
- [x] **Artisanat général** | Atelier de craft pour matériaux simples | 150 or
- [x] **Recyclage primaire** | Recyclage partiel 25% | 100 or

### Niveau 2

- [x] **Entraînement Martial** *(prérequis : Forge basique)* | Salle d'entraînement + objets physiques | 600 or
- [x] **Entraînement Magique** *(prérequis : Couture rudimentaire)* | Salle Arcanum, bureau enchanté, lutrin | 600 or
- [x] **Alchimie basique** *(prérequis : Artisanat général)* | Établi d'alchimie, potions T1 | 300 or
- [x] **Menuiserie** *(prérequis : Artisanat général)* | Table en bois, placard, étagère | 400 or

### Niveau 3

- [x] **Forge avancée D** *(prérequis : Entraînement Martial)* | Plans D, soufflet, plan lingot de fer | 400 or
- [x] **Tissage renforcé D** *(prérequis : Entraînement Magique)* | Plans D, rouet, plan tissu renforcé | 350 or
- [x] **Ameublement** *(prérequis : Menuiserie)* | Cloche réception, coffre à outils, globe runique, lutrin, plan de travail, évier rustique | 400 or
- [x] **Médecine** *(prérequis : Alchimie basique)* | Salle infirmerie + objets | 500 or
- [x] **Esthétique** *(prérequis : Ameublement)* | Statue héros, fontaine décorative, tapis | 50 or

### Niveau 4

- [x] **Forge de maître C** *(prérequis : Forge avancée)* | Plans C, râtelier d'outils, plan lingot d'acier, huile de bœuf | 800 or
- [x] **Armurier agile C** *(prérequis : Tissage renforcé)* | Plans C, chevalet de tannage, plan cuir | 800 or
- [x] **Joaillerie** *(prérequis : Forge avancée + Tissage renforcé)* | Craft anneaux et amulettes | 1 200 or
- [x] **Jardin Botanique** *(prérequis : Médecine)* | Plates-bandes, compost, arrosoir magique, accès graines | 700 or
- [x] **Divertissement** *(prérequis : Ameublement)* | Plateau d'échecs, table de jeu | 800 or

### Niveau 5

- [x] **Enchantement** *(prérequis : Forge de maître + Armurier agile)* | Autel enchantement, enchantements C | 1 000 or
- [x] **Alchimie avancée** *(prérequis : Jardin Botanique)* | Potions T2, chaudron magique | 1 000 or
- [x] **Recyclage avancé 50%** *(prérequis : Économie commerciale)* | Recyclage 50% | 800 or
- [x] **Économie commerciale** *(prérequis : Médecine)* | Accès marché | 650 or
- [x] **Brassage** *(prérequis : Jardin Botanique)* | Atelier de fermentation, bière + hydromel | 950 or

### Niveau 6

- [x] **Forge haute qualité B** *(prérequis : Enchantement)* | Plans B, bibliothèque de schémas, lingot d'acier trempé, rivets d'acier | 2 000 or
- [x] **Tannage avancé B** *(prérequis : Enchantement)* | Plans B, armoire à tissus, cuir tanné + souple | 2 000 or
- [x] **Enchantement avancé** *(prérequis : Enchantement)* | Enchantements B | 1 500 or
- [x] **Alchimiste expérimenté** *(prérequis : Alchimie avancée)* | Potions offensives / défensives | 1 500 or
- [x] **Agriculture avancée** *(prérequis : Alchimie avancée)* | Arrosoir magique, bac de compost | 1 500 or

### Niveau 7

- [x] **Enchantement expert** *(prérequis : Enchantement avancé)* | Enchantements A | 2 000 or
- [x] **Salle d'Ascension** *(prérequis : Forge haute qualité + Tannage avancé)* | Évolution des héros, autel d'évolution | 1 800 or
- [x] **Systèmes de Soins Innovants** *(prérequis : Alchimiste expérimenté)* | Soins infirmerie +25% | 2 100 or

### Niveau 8

- [x] **Forge d'Armes Légendaires A** *(prérequis : Salle d'Ascension)* | Plans A métal | 2 500 or
- [x] **Confection d'Armures Élites A** *(prérequis : Salle d'Ascension)* | Plans A cuir/tissu | 2 500 or
- [x] **Alchimiste expert** *(prérequis : Systèmes de Soins Innovants)* | Potions rares | 2 000 or

### Niveau 9

- [x] **Maîtrise de l'Enchantement Bijoux** *(prérequis : Forge lég. + Confection élite)* | Enchantement anneaux/amulettes | 3 000 or
- [x] **Stratégie de Guerre Avancée** *(prérequis : Forge lég. + Confection élite)* | +10% dégâts global passif | 2 800 or
- [x] **Recyclage Intégral 100%** *(prérequis : Alchimiste expert)* | Récupération totale équipement | 3 000 or

### Niveau 10

- [x] **Forgeron Légendaire S** *(prérequis : Stratégie de Guerre)* | Plans S métal | 3 500 or
- [x] **Couturier Légendaire S** *(prérequis : Stratégie de Guerre)* | Plans S cuir/tissu | 3 500 or

---

## 15. Constructions par Salle

### Murs / Sols / Portes

- [x] **Mur de Pierre** | 15 or/case | `ItemRegistry`
- [x] **Mur de Bois** | 10 or/case | `ItemRegistry`
- [x] **Sol de Bois** | 10 or/case | `ItemRegistry`
- [x] **Sol de Pierre** | 15 or/case | `ItemRegistry`
- [ ] **Gravier** | 8 or/case
- [x] **Terre Battue** | 2 or/case | `ItemRegistry`
- [x] **Sol d'Herbe** | 0 or/case | `ItemRegistry`
- [x] **Porte en Bois** | 20 or/u | `ItemRegistry`
- [ ] **Porte Renforcée** | 25 or/u

### Hall

- [x] **Self** | Long meuble contenant les repas préparés | 50 or | De base | `ItemRegistry`
- [ ] **Tableau des Quêtes** | Affiche les quêtes disponibles | 150 or | De base
- [ ] **Comptoir de Réception** | Accueil et recrutement | 200 or | De base
- [ ] **Table en Bois avec Chaise** | Repas / réunion | 75 or | Menuiserie
- [ ] **Baril de Boisson** | +moral à la consommation | 50 or | Brassage
- [ ] **Cloche de Réception** | Signale les visiteurs | 20 or | Ameublement

### Chambre

- [x] **Lit Simple** | Repos profond | 120 or | De base | `ItemRegistry`
- [ ] **Placard Personnel** | Stockage objets | 60 or | Menuiserie
- [ ] **Étagère** | Stockage grimoires, souvenirs | 40 or | Menuiserie

### Forge

- [x] **Forge** | Craft métal | 300 or | Forge basique | `ItemRegistry`
- [ ] **Enclume** | Forge équipements | 180 or | Forge basique
- [ ] **Soufflet** | Accélère chauffage | 100 or | Forge avancée
- [ ] **Râtelier à Outils** | Décoration | 80 or | Forge de maître
- [ ] **Bibliothèque de Schémas** | Décoration | 60 or | Forge haute qualité

### Salle de Couture

- [ ] **Métier à Tisser** | Produit tissu | 120 or | Couture rudimentaire
- [ ] **Table de Travail** | Confection vêtements/armures tissu | 75 or | Couture rudimentaire
- [ ] **Armoire à Tissus** | Stockage | 60 or | Tannage avancé
- [ ] **Mannequin** | Décoration | — | Armurier agile
- [ ] **Rouet** | Améliore métier à tisser | 100 or | Tissage renforcé
- [ ] **Chevalet de Tannage** | Tanne le cuir | 90 or | Armurier agile

### Atelier

- [ ] **Établi de Craft** | Craft polyvalent | 140 or | Artisanat général
- [ ] **Atelier de Recyclage** | Recycle armes/armures | 100 or | Recyclage primaire
- [ ] **Coffre à Outils** | Décoration | 65 or | Ameublement

### Infirmerie

- [ ] **Lit Médical** | Repos des blessés | 130 or | Médecine
- [ ] **Bureau Médical** | Diagnostics, décoration | 80 or | Médecine
- [ ] **Table d'Examen** | Traitement blessures | 90 or | Systèmes de Soins Innovants

### Salle d'Entraînement

- [ ] **Mannequin de Combat** | +FOR +DEF | 120 or | Entraînement Martial
- [ ] **Poids / Haltères** | +FOR | 70 or | Entraînement Martial
- [ ] **Cible en Bois** | +AGI | 60 or | Entraînement Martial
- [ ] **Sacs de Sable** | +DEF | 50 or | Entraînement Martial

### Atelier d'Alchimie

- [ ] **Établi d'Alchimie** | Craft potions | 160 or | Alchimie basique
- [ ] **Chaudron Magique** | Potions complexes, accélère craft | 120 or | Alchimie avancée

### Arcanum

- [ ] **Bureau Enchanté** | Entraînement +MAG | 120 or | Entraînement Magique
- [ ] **Globe Runique** | Décoration | 80 or | Ameublement
- [ ] **Autel d'Enchantement** | Recherche + application enchantements | 50 or | Enchantement
- [ ] **Lutrin** | Décoration | 25 or | Ameublement

### Jardin

- [ ] **Plates-Bandes** | Zones de culture | 50 or | Jardin Botanique
- [ ] **Bac de Compost** | Améliore productivité cultures | 60 or | Agriculture avancée
- [ ] **Arrosoir Magique** | Réduit temps de pousse | 80 or | Agriculture avancée

### Salle d'Ascension

- [ ] **Autel d'Évolution** | Déclenche l'ascension de classe | 200 or | Salle d'Ascension
- [ ] **Reliques Anciennes** | Éveil de classe, décoration | 120 or | Salle d'Ascension
- [ ] **Tapis de Cérémonie** | Décoration | 50 or | Salle d'Ascension

### Salle de Loisirs

- [x] **Instrument de Musique** | Détente musicale (harpe, lyre, tambour) | 60 or | De base | `ItemRegistry`
- [ ] **Plateau d'Échecs** | Divertissement stratégique | 70 or | Divertissement
- [ ] **Table de Jeu** | Cartes, dés… | 50 or | Divertissement

### Sanitaires

- [x] **Latrines** | Hygiène de base | 40 or | De base | `ItemRegistry`
- [x] **Lave-Mains** | Lavage des mains | 25 or | De base | `ItemRegistry`

### Cuisine

- [ ] **Fourneau** | Cuisson de tous les plats | 150 or | De base
- [ ] **Plan de Travail** | Découpe et assemblage | 80 or | Ameublement
- [ ] **Évier Rustique** | Lavage aliments | 90 or | Ameublement
- [ ] **Baril de Fermentation** | Hydromel et bière | 120 or | Brassage

### Salle Décorative

- [ ] **Statue de Héros** | Décoration | 150 or | Esthétique
- [ ] **Fontaine Décorative** | Élément décoratif central | 120 or | Esthétique
- [ ] **Tapis Rouge Royal** | Prestige | 80 or | Esthétique
- [ ] **Tapis Décoratif** | Confort | 35 or | Esthétique
- [ ] **Chandelier / Torche** | Lumière nocturne | 30 or | De base
