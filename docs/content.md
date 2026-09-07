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

---

## 2. Classes Avancées

*(aucune implémentée)*

---

## 3. Compétences par Classe

*(aucune implémentée)*

---

## 4. Traits de Caractère

*(aucun implémenté)*

---

## 5. Mobs

### Rang F

- [x] **Slime** | Rang F | FM 0.1 | Vitesse 100 | STR 3 DEF 4 AGI 6 MAG 1 LCK 5 | PV 62
  - Drop : Gelée de slime ×1 (commun) | Cristal magique ×1 (rare 15%)
  - Coup Gluant : bondit sur l'ennemi. Puissance 4
  - Charge Instable *(spécial)* : zone légère. Puissance 3

---

## 6. Armes

### 6.1 Épées

- [x] Épée d'entraînement | Rang F | Atk 5 | Bois ×2

---

## 7. Armures

*(aucune implémentée)*

---

## 8. Accessoires

*(aucun implémenté)*

---

## 9. Potions et Consommables

*(aucune implémentée)*

---

## 10. Enchantements

*(aucun implémenté)*

---

## 11. Matériaux et Ressources

### 11.1 Ressources Naturelles

- [x] Bois | Valeur 2 | Récolte forêt, Achat

---

## 12. Plats et Fermentés

*(aucun implémenté)*

---

## 13. Cultures

*(aucune implémentée)*

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
