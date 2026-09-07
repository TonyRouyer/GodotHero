# Contenu du Jeu — Listes Exhaustives

> Données de contenu : classes, compétences, mobs, équipements, ressources, recherches, constructions.
> Fichiers associés : [`../readme.md`](../readme.md) — doc technique | [`gamedesign.md`](gamedesign.md) — formules de jeu

**Légende** : `- [x]` = implémenté | `- [ ]` = non implémenté

---

## Table des matières

1. [Classes de Base (6)](#1-classes-de-base)
2. [Classes Avancées (12)](#2-classes-avancées)
3. [Compétences des Classes Avancées](#3-compétences-des-classes-avancées)
4. [Mobs](#4-mobs)
5. [Armes](#5-armes)
6. [Matériaux et Ressources](#6-matériaux-et-ressources)
7. [Recherches (39)](#7-recherches-39)
8. [Constructions par Salle](#8-constructions-par-salle)

---

## 1. Classes de Base

Selon la classe, le héros ne peut équiper que certains types d'arme et d'armure.

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

---

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

---

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

---

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

---

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

---

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

Accessible niveau 50, rang B minimum, Salle d'Ascension requise. Débloquent de nouvelles armes et compétences.

### 2.1 Chevalier (Évolution du Guerrier)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.1)

**Armes** : Épée, Hache, Lance | **Armure** : Lourde
Spécialité : Tank défensif, leader sur le champ de bataille, résistance extrême, coups dévastateurs.

---

### 2.2 Berserker (Évolution du Guerrier)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.2)

**Armes** : Épée, Hache, Marteau | **Armure** : Moyenne, Lourde
Spécialité : Attaque offensive dévastatrice, sacrifie la défense pour des dégâts massifs.

---

### 2.3 Sage Arcanique (Évolution du Mage)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.3)

**Armes** : Bâton, Grimoire, Orbe | **Armure** : Légère
Spécialité : Sorts arcaniques extrêmement puissants et complexes, précision redoutable.

---

### 2.4 Maître des Éléments (Évolution du Mage)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.4)

**Armes** : Bâton, Grimoire, Orbe | **Armure** : Légère
Spécialité : Contrôle du feu, eau, terre, air — dégâts massifs ou contrôle du terrain.

---

### 2.5 Assassin (Évolution du Roublard)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.5)

**Armes** : Dague, Arc | **Armure** : Légère, Moyenne
Spécialité : Attaques furtives mortelles, élimination rapide avant réaction.

---

### 2.6 Ombre (Évolution du Roublard)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.6)

**Armes** : Dague, Shuriken | **Armure** : Légère, Moyenne
Spécialité : Maîtrise de l'obscurité, quasi-indétectable, coups dans le dos.

---

### 2.7 Ranger (Évolution du Chasseur)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.7)

**Armes** : Arc | **Armure** : Moyenne
Spécialité : Pistage, tir longue distance, survie, fusion avec la nature.

---

### 2.8 Archer Mystique (Évolution du Chasseur)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.8)

**Armes** : Arc | **Armure** : Moyenne
Spécialité : Flèches enchantées avec effets magiques ou spéciaux variés.

---

### 2.9 Prêtre (Évolution du Guérisseur)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.9)

**Armes** : Bâton, Grimoire | **Armure** : Légère
Spécialité : Soins sacrés, protection divine, repoussement des ténèbres.

---

### 2.10 Druide (Évolution du Guérisseur)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.10)

**Armes** : Bâton | **Armure** : Légère
Spécialité : Puissance de la nature, soins et attaques naturelles, invocations végétales.

---

### 2.11 Maître des Esprits (Évolution de l'Invocateur)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.11)

**Armes** : Bâton, Grimoire | **Armure** : Légère
Spécialité : Convocation et contrôle d'esprits puissants du monde spirituel.

---

### 2.12 Conjurateur Élémentaire (Évolution de l'Invocateur)

- [x] Données présentes dans `HeroClassRegistry`
- [ ] Compétences (voir §3.12)

**Armes** : Bâton, Grimoire, Orbe | **Armure** : Légère
Spécialité : Invocation de créatures élémentaires (feu, eau, terre) pour écraser les ennemis.

---

## 3. Compétences des Classes Avancées

> Aucune compétence n'est encore définie pour les classes avancées. Chaque classe devra recevoir ses propres compétences dans `SkillLibrary`. Les entrées ci-dessous sont des emplacements à remplir lors de la conception.

Coûts par rang (référence) : F=15 pts | E=30 pts | D=60 pts | C=90 pts | B=120 pts | A=150 pts | S=180 pts

---

### 3.1 Chevalier

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.2 Berserker

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.3 Sage Arcanique

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.4 Maître des Éléments

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.5 Assassin

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.6 Ombre

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.7 Ranger

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.8 Archer Mystique

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.9 Prêtre

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.10 Druide

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.11 Maître des Esprits

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

### 3.12 Conjurateur Élémentaire

- [ ] Compétence 1 (à concevoir)
- [ ] Compétence 2 (à concevoir)
- [ ] Compétence 3 (à concevoir)

---

## 4. Mobs

> Seul le Slime est conservé comme référence (implémenté). Les autres mobs sont dans `MobLibrary` et considérés terminés.

### Rang F

#### Slime

- [x] Implémenté dans `MobLibrary`

**Rang** : F | **FM** : 0.1 | **Vitesse** : 100

| Stat | Valeur |
|------|--------|
| Force | 3 |
| Défense | 4 |
| Agilité | 6 |
| Magie | 1 |
| Chance | 5 |

**PV** : 50 + (3×2) + (4×1.5) = **62**

**Drops** :
- [x] Gelée de slime ×1 (commun)
- [x] Cristal magique ×1 (rare 15%)

**Attaques** :
- [x] Coup Gluant — bondit sur l'ennemi. Puissance 4
- [x] Charge Instable *(spécial)* — zone légère. Puissance 3

---

## 5. Armes

> Seules les deux armes de départ sont conservées comme référence. Les autres armes sont dans `EquipmentLibrary` et considérées terminées.

### 5.1 Épées

- [x] Épée d'entraînement | Rang F | Atk 5 | Bois ×2

### 5.4 Dagues

- [x] Dague de voleur | Rang F | Atk 5 | Lingot de fer ×1, Cuir ×1

---

## 6. Matériaux et Ressources

> Seuls les matériaux liés aux deux armes de départ et au Slime sont conservés comme référence. Les autres matériaux sont dans `MaterialLibrary` et considérés terminés.

### Ressources Naturelles

- [x] Bois | Valeur : 2 | Récolte forêt, Achat
- [x] Métal brut | Valeur : 3 | Récolte, Achat

### Matériaux Artisanaux

- [x] Lingot de fer | Valeur : 4 | Métal brut ×2 | Forge | 2h
- [x] Cuir | Valeur : 3 | Peau brute ×1, Eau ×1 | Atelier de tannage | 1h

### Composants de Monstres

- [x] Gelée de slime | Valeur : 2 | Drop : Slime

---

## 7. Recherches (39)

> Toutes dans `ResearchLibrary`. Durée en heures in-game, coût en or.

### Niveau 1

- [x] Forge basique — Salle forge, forge, enclume, plans F+E, plan charbon, verre — 200 or
- [x] Couture rudimentaire — Salle couture, métier à tisser, chevalet de tannage, plans F+E, plan tissu — 150 or
- [x] Artisanat général — Atelier de craft pour matériaux simples — 150 or
- [x] Recyclage primaire — Recyclage partiel 25% — 100 or

### Niveau 2

- [x] Entraînement Martial (prérequis : Forge basique) — Salle d'entraînement + tous objets physiques — 600 or
- [x] Entraînement Magique (prérequis : Couture rudimentaire) — Salle Arcanum, bureau enchanté, lutrin — 600 or
- [x] Alchimie basique (prérequis : Artisanat général) — Établi d'alchimie, objets liés, potions T1 — 300 or
- [x] Menuiserie (prérequis : Artisanat général) — Table en bois avec chaise, placard personnel, étagère — 400 or

### Niveau 3

- [x] Forge avancée D (prérequis : Entraînement Martial) — Plans rang D, soufflet, plan lingot de fer — 400 or
- [x] Tissage renforcé D (prérequis : Entraînement Magique) — Plans rang D, rouet, plan tissu renforcé — 350 or
- [x] Ameublement (prérequis : Menuiserie) — Cloche réception, coffre à outils, globe runique, lutrin, plan de travail, évier rustique — 400 or
- [x] Médecine (prérequis : Alchimie basique) — Salle infirmerie + objets liés — 500 or
- [x] Esthétique (prérequis : Ameublement) — Statue de héros, fontaine décorative, tapis royal rouge, tapis décoratif — 50 or

### Niveau 4

- [x] Forge de maître C (prérequis : Forge avancée) — Plans rang C, râtelier d'outils, plan lingot d'acier, huile de bœuf — 800 or
- [x] Armurier agile C (prérequis : Tissage renforcé) — Plans rang C, chevalet de tannage, plan cuir — 800 or
- [x] Joaillerie (prérequis : Forge avancée + Tissage renforcé) — Craft anneaux et amulettes — 1 200 or
- [x] Jardin Botanique (prérequis : Médecine) — Plates-bandes, compost, arrosoir magique, accès graines à l'achat — 700 or
- [x] Divertissement (prérequis : Ameublement) — Plateau d'échecs, table de jeu — 800 or

### Niveau 5

- [x] Enchantement (prérequis : Forge de maître + Armurier agile) — Fonctionnalité enchantement, autel d'enchantement, enchantements rang C — 1 000 or
- [x] Alchimie avancée (prérequis : Jardin Botanique) — Potions T2 + chaudron magique — 1 000 or
- [x] Recyclage avancé 50% (prérequis : Économie commerciale) — Recyclage 50% des équipements — 800 or
- [x] Économie commerciale (prérequis : Médecine) — Accès au marché (achat / vente) — 650 or
- [x] Brassage (prérequis : Jardin Botanique) — Baril de fermentation, recettes bière + hydromel — 950 or

### Niveau 6

- [x] Forge haute qualité B (prérequis : Enchantement) — Plans rang B, bibliothèque de schémas, lingot d'acier trempé, rivets en acier — 2 000 or
- [x] Tannage avancé B (prérequis : Enchantement) — Plans rang B, armoire à tissus, plan cuir tanné + cuir souple — 2 000 or
- [x] Enchantement avancé (prérequis : Enchantement) — Débloque enchantements rang B — 1 500 or
- [x] Alchimiste expérimenté (prérequis : Alchimie avancée) — Potions offensives / défensives — 1 500 or
- [x] Agriculture avancée (prérequis : Alchimie avancée) — Arrosoir magique, bac de compost — 1 500 or

### Niveau 7

- [x] Enchantement expert (prérequis : Enchantement avancé) — Enchantements rang A — 2 000 or
- [x] Salle d'Ascension (prérequis : Forge haute qualité + Tannage avancé) — Évolution des héros, autel d'évolution, reliques anciennes, tapis de cérémonie — 1 800 or
- [x] Systèmes de Soins Innovants (prérequis : Alchimiste expérimenté) — Améliore soins infirmerie +25% efficacité — 2 100 or

### Niveau 8

- [x] Forge d'Armes Légendaires A (prérequis : Salle d'Ascension) — Plans rang A (armes et armures métal) — 2 500 or
- [x] Confection d'Armures Élites A (prérequis : Salle d'Ascension) — Plans rang A (armures cuir/tissu) — 2 500 or
- [x] Alchimiste expert (prérequis : Systèmes de Soins Innovants) — Accès potions rares — 2 000 or

### Niveau 9

- [x] Maîtrise de l'Enchantement Bijoux (prérequis : Forge légendaire + Confection élite) — Enchantement sur anneaux et amulettes — 3 000 or
- [x] Stratégie de Guerre Avancée (prérequis : Forge légendaire + Confection élite) — +10% dégâts passif pour tous les héros en combat — 2 800 or
- [x] Recyclage Intégral 100% (prérequis : Alchimiste expert) — Récupération totale des ressources d'un équipement recyclé — 3 000 or

### Niveau 10

- [x] Forgeron Légendaire S (prérequis : Stratégie de Guerre Avancée) — Plans rang S (armes et armures métal) — 3 500 or
- [x] Couturier Légendaire S (prérequis : Stratégie de Guerre Avancée) — Plans rang S (armures cuir/tissu) — 3 500 or

---

## 8. Constructions par Salle

> Tous dans `ItemRegistry`.

### Murs / Sols / Portes

- [x] Mur de bois | 10 or/case
- [x] Mur de pierre | 15 or/case
- [x] Sol de bois | 10 or/case
- [x] Sol de pierre | 15 or/case
- [x] Gravier | 8 or/case
- [x] Porte en bois | 20 or/u
- [x] Porte renforcée | 25 or/u

---

### Hall

- [x] Tableau des quêtes — Affiche les quêtes disponibles | 150 or | De base
- [x] Comptoir de réception — Accueil et recrutement | 200 or | De base
- [x] Self — Contient les repas préparés | 50 or | De base
- [x] Instrument de musique — Détente musicale (harpe, lyre…) | 60 or | De base
- [x] Chandelier / torche — Lumière nocturne | 30 or | De base
- [x] Table en bois avec chaise — Grande table repas / réunion | 75 or | Menuiserie
- [x] Baril de boisson — +moral à la consommation | 50 or | Brassage
- [x] Cloche de réception — Signale les visiteurs | 20 or | Ameublement

---

### Chambre

- [x] Lit simple — Repos profond | 120 or | De base
- [x] Placard personnel — Stockage objets personnels | 60 or | Menuiserie
- [x] Étagère — Stockage grimoires, souvenirs | 40 or | Menuiserie

---

### Forge

- [x] Forge — Chauffe les métaux, craft | 300 or | Forge basique
- [x] Enclume — Forge les équipements, craft | 180 or | Forge basique
- [x] Soufflet — Accélère le chauffage, amélioration | 100 or | Forge avancée
- [x] Râtelier à outils — Décoration | 80 or | Forge de maître
- [x] Bibliothèque de schémas — Décoration | 60 or | Forge haute qualité

---

### Salle de Couture

- [x] Métier à tisser — Produit du tissu, craft | 120 or | Couture rudimentaire
- [x] Table de travail — Confection vêtements/armures tissu, craft | 75 or | Couture rudimentaire
- [x] Chevalet de tannage — Tanne le cuir, craft | 90 or | Armurier agile
- [x] Armoire à tissus — Stockage tissus, décoration | 60 or | Tannage avancé
- [x] Rouet — Améliore le métier à tisser | 100 or | Tissage renforcé
- [x] Mannequin — Décoration | — | Armurier agile

---

### Atelier

- [x] Établi de craft — Craft polyvalent | 140 or | Artisanat général
- [x] Atelier de recyclage — Recycle armes et armures | 100 or | Recyclage primaire
- [x] Coffre à outils — Décoration | 65 or | Ameublement

---

### Infirmerie

- [x] Lit médical — Repos des blessés | 130 or | Médecine
- [x] Bureau médical — Diagnostics, décoration | 80 or | Médecine
- [x] Table d'examen — Traitement des blessures | 90 or | Systèmes de Soins Innovants

---

### Salle d'Entraînement

- [x] Mannequin de combat — +FOR +DEF | 120 or | Entraînement martial
- [x] Poids / haltères — +FOR | 70 or | Entraînement martial
- [x] Cible en bois — +AGI | 60 or | Entraînement martial
- [x] Sacs de sable — +DEF | 50 or | Entraînement martial

---

### Atelier d'Alchimie

- [x] Établi d'alchimie — Préparations magiques, craft | 160 or | Alchimie basique
- [x] Chaudron magique — Potions complexes + accélère craft, amélioration | 120 or | Alchimie avancée

---

### Arcanum

- [x] Bureau enchanté — Entraînement magique +MAG | 120 or | Entraînement magique
- [x] Autel d'enchantement — Recherche et application enchantements, craft | 50 or | Enchantement
- [x] Globe runique — Décoration | 80 or | Ameublement
- [x] Lutrin — Décoration | 25 or | Ameublement

---

### Jardin

- [x] Plates-bandes — Zones de culture | 50 or | Jardin Botanique
- [x] Bac de compost — Améliore productivité | 60 or | Agriculture avancée
- [x] Arrosoir magique — Réduit le temps de pousse, amélioration | 80 or | Agriculture avancée

---

### Salle d'Ascension

- [x] Autel d'évolution — Déclenche l'ascension des classes | 200 or | Salle d'Ascension
- [x] Reliques anciennes — Éveil de classe, décoration | 120 or | Salle d'Ascension
- [x] Tapis de cérémonie — Atmosphère mystique, décoration | 50 or | Salle d'Ascension

---

### Salle de Loisirs

- [x] Plateau d'échecs — Divertissement stratégique | 70 or | Divertissement
- [x] Table de jeu — Cartes, dés… | 50 or | Divertissement
- [x] Instrument de musique — Harpe, lyre, tambour | 60 or | De base

---

### Sanitaires

- [x] Latrines — Hygiène de base | 40 or | De base
- [x] Lave-mains — Lavage des mains | 25 or | De base

---

### Cuisine

- [x] Fourneau — Cuisson de tous les plats, craft | 150 or | De base
- [x] Plan de travail — Découpe et assemblage, décoration | 80 or | Ameublement
- [x] Évier rustique — Lavage aliments, bonus hygiène | 90 or | Ameublement
- [x] Baril de fermentation — Hydromel et bière, interface dédiée | 120 or | Brassage

---

### Salle Décorative

- [x] Statue de héros — Décoration | 150 or | Esthétique
- [x] Fontaine décorative — Décoration centrale | 120 or | Esthétique
- [x] Tapis rouge royal — Prestige | 80 or | Esthétique
- [x] Tapis décoratif — Confort | 35 or | Esthétique
- [x] Chandelier / torche — Lumière nocturne | 30 or | De base
