# Game Design Document — Guilde d'Aventuriers

> Règles de jeu, mécaniques, formules et équilibrage.
> Fichiers associés : [`readme.md`](readme.md) — doc technique | [`CONTENT.md`](CONTENT.md) — listes de contenu

---

## Table des matières

1. [Concept et Boucle de Jeu](#1-concept-et-boucle-de-jeu)
2. [Héros — Stats et Progression](#2-héros--stats-et-progression)
3. [Besoins Primaires](#3-besoins-primaires)
4. [Moral](#4-moral)
5. [Pièces — Beauté et Température](#5-pièces--beauté-et-température)
6. [Recrutement](#6-recrutement)
7. [Combat — Formules Complètes](#7-combat--formules-complètes)
8. [Missions et Récompenses](#8-missions-et-récompenses)
9. [Diplomatie et Factions](#9-diplomatie-et-factions)
10. [Économie](#10-économie)
11. [Craft et Recherche](#11-craft-et-recherche)
12. [Évènements Aléatoires](#12-évènements-aléatoires)

---

## 1. Concept et Boucle de Jeu

Le joueur est maître d'une guilde d'aventuriers dans le monde d'Astralia (médiéval-fantastique). Il construit et aménage sa guilde, recrute des héros avec des personnalités propres, les envoie en mission, et fait grandir sa réputation dans le royaume.

**Boucle principale :**
1. Construire et améliorer la guilde (murs, sols, objets)
2. Recruter et gérer les héros (planning, besoins, moral)
3. Envoyer des héros en mission → or, ressources, réputation, XP
4. Réinvestir pour progresser → missions plus difficiles → retour au 1

**Mode combat** : le joueur peut contrôler un héros personnellement ou laisser l'IA gérer tous les héros. Il peut passer en full-IA à tout moment.

---

## 2. Héros — Stats et Progression

### 2.1 Stats de combat principales

| Stat | Rôle |
|------|------|
| **Force** | Dégâts physiques |
| **Défense** | Réduction des dégâts reçus |
| **Agilité** | Esquive, vitesse de déplacement |
| **Magie** | Puissance des sorts |
| **Chance** | Coups critiques, qualité du butin |

### 2.2 PV Max et Mana Max

```
PV_max   = 100 + (Force × 2) + (Défense × 1.5) + bonus_équipement
Mana_max = 50  + (Magie × 3) + bonus_équipement
Mana_regen = 1 + (Magie × 0.05) par seconde hors combat
           = 0.5 par seconde en combat
```

### 2.3 Stats de métier (hors combat)

| Stat | Usage |
|------|-------|
| **Social** | Accueil — attire quêtes et candidats |
| **Travaux Manuels** | Forge, artisanat d'armes et armures |
| **Travaux Occultes** | Potions, enchantements |
| **Cuisine** | Préparation des repas de la guilde |
| **Savoir** | Vitesse de déblocage des recherches |

**À la génération** : `Valeur = rand(1, 10) + (Niveau × 0.3)`

### 2.4 Progression des stats métier par usage

```
XP_metier[competence] += Difficulté × 0.05 × facteur_trait
Quand XP_metier[competence] >= seuil_prochain_palier :
    stat_metier[competence] += 1
    XP_metier[competence]    = 0
    seuil_prochain_palier    = stat_actuelle × 20  (ajustable)
```

### 2.5 Entraînement dans la guilde

```
Gain_stat_par_tic = 1 / (1 + stat × 0.05)
```
À stat=100, un point prend ~35× plus longtemps qu'à stat=0. Évite les stats infinies.

### 2.6 XP et niveau

**XP requise pour monter de niveau :**
```
XP_n = 100 × 1.7^(n−1)
```

| Passage | XP requise (approx.) |
|---------|----------------------|
| 1 → 2 | 100 |
| 2 → 3 | 170 |
| 3 → 4 | 289 |
| 5 → 6 | 835 |
| 10 → 11 | ~8 900 |

**Au niveau up :** +15 points de compétence, +1 à 5 points aléatoires sur chaque stat principale.

**XP gagnée par monstre tué en combat :**
```
XP = 50 × FM_mob × M_rang
```

| Rang de mission | M_rang |
|-----------------|--------|
| F | × 1.0 |
| E | × 1.2 |
| D | × 1.4 |
| C | × 1.6 |
| B | × 1.8 |
| A | × 2.0 |
| S | × 2.5 |

FM_mob = Facteur de Menace du mob (voir §7.8).

### 2.7 Rang d'aventurier

F → E → D → C → B → A → S. Progresse après **10 missions réussies sur les 20 dernières**.

### 2.8 Classe avancée

Accessible à **niveau 50**, rang **B minimum**, dans la **Salle d'Ascension** (recherche obligatoire). Voir CONTENT.md §1.2 pour les 12 classes avancées et leurs armes.

### 2.9 Compétences à la génération

```
N_compétences = floor(Niveau / 5)
```
Tirées aléatoirement dans le pool de la classe. Rang max = rang du héros.

### 2.10 Salaire journalier

```
Salaire = Base_rang × (1 + 0.03 × Niveau) × (1 + Bonus_classe)
```

| Rang | Base (or/jour) |
|------|---------------|
| F | 10 |
| E | 20 |
| D | 40 |
| C | 60 |
| B | 100 |
| A | 150 |
| S | 200 |

| Classe | Bonus |
|--------|-------|
| Classe de base | +0% |
| Classe avancée | +30% |

> ⚠ Héros Rang S, niveau 100, classe avancée → 200 × 4.0 × 1.3 = **1 040 or/jour**. À calibrer.

### 2.11 Équipements — Compatibilité par classe

Voir CONTENT.md §1.1 pour les tableaux complets. Résumé :

| Classe de base | Armes | Armure |
|---------------|-------|--------|
| Guerrier | épée, hache | lourde |
| Mage | bâton, grimoire | légère |
| Roublard | dague | moyenne |
| Chasseur | arc | moyenne |
| Guérisseur | bâton | légère |
| Invocateur | bâton, grimoire | légère |

Les classes avancées peuvent avoir des armes supplémentaires (lance, marteau, orbe, shuriken — voir CONTENT.md §1.2).

---

## 3. Besoins Primaires

> **Deux niveaux de seuil :**
> - **Seuil critique** (niveau 1 think tree) : interrompt TOUTE activité immédiatement.
> - **Seuil de recherche autonome** (niveau 4 think tree) : le héros cherche à satisfaire le besoin en temps libre.

### 3.1 Sommeil (Énergie)

| Situation | Variation / heure |
|-----------|------------------|
| Normal (éveillé) | −2.5% |
| Travail ou entraînement | −3.75% |
| Repos au lit | +12.5% |
| Repos au sol (pas de lit dispo) | +8.3% |

- **Seuil critique** : Énergie < 8% → interruption absolue
- **Seuil recherche autonome** : Énergie < 20% → cherche un lit en temps libre

### 3.2 Faim

| Situation | Variation / heure |
|-----------|------------------|
| Normal | −2% |
| Travail ou entraînement | −3% |

| Seuil | Comportement |
|-------|-------------|
| ≤ 35% | Cherche automatiquement le premier repas disponible (niveau 4 think tree) |
| < 10% | Seuil critique — interruption absolue (niveau 1 think tree) |
| = 0% | Santé −1%/h jusqu'à la mort (sauf démission avant) |

### 3.3 Divertissement

| Situation | Variation / heure |
|-----------|------------------|
| Normal (sans loisir) | −1.5% |
| Travail ou entraînement | −2% |
| Utilise objet de loisir | +8% à +15% (selon objet) |

| Niveau | Impact moral |
|--------|-------------|
| < 25% (seuil de recherche autonome) | −5 moral constant |
| 40% – 70% | Neutre |
| > 70% | +3 moral constant |

### 3.4 Toilette

| Situation | Variation |
|-----------|----------|
| Normal | −3% / heure |
| Après chaque repas | −15% (fixe) |
| Utilise WC | Hygiène −20% (fixe) |

- **Seuil critique** : Toilette < 8% → interruption absolue
- **Seuil de recherche autonome** : Toilette < 20% → se dirige vers les WC

### 3.5 Hygiène

| Situation | Variation / heure |
|-----------|------------------|
| Normal | −2% |
| Travail / entraînement | −4% |

- **Seuil de recherche autonome** : Hygiène < 25% → va à la douche/lavabo
- (Pas de seuil critique — n'interrompt pas les tâches)

---

## 4. Moral

### 4.1 Démission

```
P_démission (%) = 5 + (H_moral_nul × 1)
```

| Param | Description |
|-------|-------------|
| 5% | Chance de base lorsque moral = 0 |
| H_moral_nul | Nombre d'heures consécutives à moral = 0 |
| Reset | Si moral remonte > 5 → P_démission revient à 5% |

Plafonné à **80%** pour toujours laisser une chance au joueur.
→ Moral = 0 pendant **3+ jours** → démission garantie (sauf trait Dévoué).

### 4.2 Modificateur moral sur les dégâts (M_moral)

```
D_moral = D_base × M_moral
```

| Moral (%) | M_moral |
|-----------|---------|
| 81 – 100 | × 1.00 (aucun malus) |
| 61 – 80 | × 0.90 (−10%) |
| 41 – 60 | × 0.85 (−15%) |
| 21 – 40 | × 0.80 (−20%) |
| 0 – 20 | × 0.75 (−25%) |

### 4.3 Effets TEMPORARY (durée 1–12h)

| Événement | Moral ± | Durée (h) |
|-----------|---------|-----------|
| A mangé un bon repas chaud | +5 | 6 |
| A eu une altercation verbale | −8 | 4 |
| A gagné une mission | +10 | 12 |
| A échoué une mission | −10 | 10 |
| S'est blessé au combat | −8 | 8 |
| A reçu un cadeau / remerciement | +6 | 6 |
| A été puni ou réprimandé | −6 | 6 |

### 4.4 Effets CONSTANT (actifs tant que la condition dure)

| Condition | Moral ± |
|-----------|---------|
| Vit dans une chambre propre et meublée (beauté ≥ 25) | +5 |
| Dort sur le sol / dortoir surpeuplé | −7 |
| Est bien nourri chaque jour | +3 |
| Est affamé ou sous-alimenté (faim < 20%) | −10 |
| Est en présence d'un ami proche | +4 |
| Est ignoré ou isolé socialement | −6 |
| A une tâche adaptée à ses préférences | +3 |
| Non payé | −10 |
| Se sent sous-utilisé / corvée détestée | −5 |
| Divertissement < 25% | −5 |
| Divertissement > 70% | +3 |

### 4.5 Effets PROGRESSIVE (sur plusieurs jours)

| Événement | Moral ± | Durée |
|-----------|---------|-------|
| A perdu un camarade proche | −20 (−10 au jour 5) | 10 jours |
| A assisté à une cérémonie de guilde | +10 | 3 jours |
| A reçu une promotion / titre | +15 | 5 jours |
| A été trahi ou exclu d'un groupe | −15 | 7 jours |
| A été humilié en public | −12 | 4 jours |
| A participé à un entraînement intense | +8 | 3 jours |
| Blessure grave | −15 | 3 jours |
| A échoué une quête personnelle | −10 | 5 jours |

---

## 5. Pièces — Beauté et Température

> **Non implémenté** — formules définies, code à écrire.

### 5.1 Beauté

```
Beauté_pièce = Σ(Beauté_meuble) + Σ(Beauté_sol × nb_cases) + Beauté_mur × périmètre
```

Impact moral (effet CONSTANT, actif tant que le héros est dans la pièce ou en est sorti depuis moins d'1h in-game) :

| Beauté | État | Effet moral |
|--------|------|-------------|
| < 0 | Repoussante | −5 constant |
| 0 – 9 | Austère | −2 constant |
| 10 – 24 | Neutre | 0 |
| 25 – 49 | Agréable | +2 constant |
| 50 – 99 | Belle | +4 constant |
| ≥ 100 | Remarquable | +6 constant |

### 5.2 Température

```
Température_pièce = Température_base_biome + Σ(Modificateur_thermique_objet)
```

| Biome / Zone | T° de base |
|-------------|-----------|
| Intérieur standard | 15°C |
| Zone nordique / montagne | 2°C |
| Zone désertique / volcanique | 30°C |
| Zone tempérée | 12°C |

**Exemples de modificateurs thermiques :**

| Objet | Modificateur |
|-------|-------------|
| Cheminée (active) | +12°C |
| Cheminée (inactive) | 0°C |
| Fourneau (actif) | +8°C |
| Forge (active) | +15°C |
| Fenêtre | −3°C |
| Tapis épais | +1°C |

**Impact sur le moral / besoins :**

| Température | État | Effet |
|------------|------|-------|
| < 0°C | Glacial | −8 moral constant + fatigue ×1.5 |
| 0 – 8°C | Froid | −4 moral constant |
| 9 – 14°C | Frais | −1 moral constant |
| 15 – 22°C | Confortable ✓ | 0 (neutre) |
| 23 – 28°C | Chaud | −1 moral constant |
| 29 – 35°C | Très chaud | −4 moral constant + fatigue ×1.2 |
| > 35°C | Étouffant | −8 moral constant + fatigue ×1.5 |

---

## 6. Recrutement

### 6.1 Fréquence et pool

```
T_recrutement (h) = 15 − min(Réputation / 5, 12)
Max_héros_visibles = 1 + floor(Réputation / 10)
Coût_recrutement   = Salaire × 5
```

| Réputation | Temps recrutement | Pool visible |
|-----------|------------------|-------------|
| 0 | 15h | 1 |
| 10 | 13h | 2 |
| 30 | 9h | 4 |
| 60+ | 3h (minimum) | 7+ |

### 6.2 Niveau et rang du héros proposé

```
Niveau_proposé = Niveau_moyen_guilde + (Réputation / 2) + rand(−5, 0)
Score_rang     = (Niveau / 10) + (Réputation / 3)
```

| Score | Rang attribué |
|-------|--------------|
| ≤ 1 | F |
| 1 – 2 | E |
| 2 – 3 | D |
| 3 – 4 | C |
| 4 – 5 | B |
| 5 – 6 | A |
| > 6 | S |

### 6.3 Probabilité de classe avancée

| Type | Probabilité | Condition |
|------|------------|-----------|
| Classe de base | 80% | Toujours |
| Classe avancée | 20% | Seulement si le joueur possède déjà un héros de cette classe avancée |

---

## 7. Combat — Formules Complètes

### 7.1 Dégâts de base (Héros)

```
D_base = √Stat_adaptée + Attaque_arme
```

- `Stat_adaptée` = Force pour les attaques physiques, Magie pour les sorts
- `Attaque_arme` = valeur de l'arme équipée (0 si mains nues)

Exemple : Force=70, arme=10 → √70 + 10 = 8.37 + 10 ≈ **18 dégâts**

### 7.2 Dégâts finaux (Héros → Cible)

```
D_final = max(1, (D_base × M_moral × M_type) − √Défense_cible)
```

### 7.3 Coups critiques

```
P_crit (%) = Chance × 0.5 + bonus_équipement
D_crit     = D_base × 2.0
```

Exemple : Chance=20 → 10% de critique. Sur 18 dmg de base → 36 dégâts.

### 7.4 Modificateur de type de dégâts (M_type)

| Situation | M_type |
|-----------|--------|
| Normal | × 1.0 |
| Résistance | × 0.5 |
| Faiblesse | × 2.0 |
| Critique seul | × 2.0 |
| **Faiblesse + Critique** | **× 2.5** (plafonné — évite ×4.0) |

### 7.5 Dégâts des Mobs

```
D_mob   = √Force_mob + Puissance_attaque
D_final = max(1, D_mob − √Défense_héros)
```

Exemple : Slime Force=3, Coup Gluant puissance=4 → √3 + 4 = 5.73 ≈ **6 dégâts bruts**

### 7.6 PV des Mobs

```
PV_mob = 50 + (Force × 2) + (Défense × 1.5)
```
Base 50 (vs 100 héros) pour que les mobs de bas rang restent fragiles.

### 7.7 Vitesse de déplacement

```
V_deplacement = V_base × (1 + Agilité / 100)
V_base = 100 unités/s (héros), variable selon mob
```

### 7.8 Vitesse d'esquive (cooldown)

```
T_esquive = T_base × (1 − min(Agilité, 160) / 200)
T_base    = 1.0 seconde
```
Agilité plafonnée à 160 → réduction max 80% → temps minimum = **0.2s**.

Exemple : Agilité=40 → 1 × (1 − 40/200) = **0.8s** entre esquives.

### 7.9 Facteur de menace / Aggro

> Non implémenté — les mobs ciblent actuellement le héros le plus proche.

```
F_menace = (D_infligés × 0.3) + (Soin × 0.3) + (Proximité × 0.4) + (Santé × 0.1) + Taunt
```

| Composant | Valeur |
|-----------|--------|
| Proximité Contact (0–5px) | +20 |
| Proximité Proche (5–20px) | +15 |
| Proximité Moyenne (20–50px) | +10 |
| Proximité Éloignée (>50px) | +5 |
| Santé < 50% | +10 |
| Santé 50–75% | +5 |
| Santé > 75% | +0 |
| Taunt (compétence tank) | +100 |

### 7.10 Logique IA des héros en combat

1. Si stun ou silence → ne fait rien
2. Si effets critiques (poison/brûlure graves) → utilise antidote si disponible
3. Si PV < 30% → utilise potion de soin si disponible
4. Cible l'ennemi avec la menace la plus haute (ou le plus proche si aggro non impl.)
5. Utilise une compétence disponible (hors cooldown), priorité par rang
6. Attaque de base

### 7.11 Effets de statut

| Statut | Effet |
|--------|-------|
| Brûlure | Dégâts feu sur la durée |
| Poison | Dégâts poison sur la durée |
| Stun | Impossibilité d'agir |
| Saignement | Dégâts physiques sur la durée |
| Affaiblissement | Réduction stats |
| Silence | Impossibilité d'utiliser des compétences magiques |
| Peur | Fuite / incapacité |
| Ralentissement | −% vitesse déplacement |
| Constriction / Paralysie | Immobilisation |

---

## 8. Missions et Récompenses

### 8.1 Difficulté totale d'une mission

```
D_totale = Σ(FM_i × N_i)
```
FM_i = Facteur de Menace du type de monstre i, N_i = nombre de monstres de ce type.

Exemple : 3 gobelins (FM=0.15) + 1 orque (FM=0.4) → D = (3×0.15) + (1×0.4) = **0.85**

### 8.2 Probabilité monstre Alpha

| Rang de mission | Probabilité |
|----------------|-------------|
| F, E, D | 5% |
| C, B | 10% |
| A, S | 15% |

Un Alpha remplace un monstre normal (stats améliorées + attaques uniques).

### 8.3 Récompense en or

```
CR = 1 + (Réputation / 100)
Or = D_totale × 100 × CR
```

Exemple : D=0.85, Réputation=50 → CR=1.5 → Or = 0.85 × 100 × 1.5 = **127.5 or**

### 8.4 Performance des héros

```
P = (HP_finale_moy / HP_init_moy) × Ratio_objectifs
```

| Param | Description |
|-------|-------------|
| HP_finale_moy | Moyenne des PV restants des héros en vie à la fin |
| HP_init_moy | Moyenne des PV initiaux des héros envoyés |
| Ratio_objectifs | 1.0 = tous atteints, 0.75 = 75% atteints, etc. |

Si un héros meurt, ses PV finaux = 0 (tire fortement P vers le bas).

### 8.5 Gain de réputation (mission réussie)

```
Gain_Rep = (D × P) × (100 / (100 + R))
```

| Param | Description |
|-------|-------------|
| D | Difficulté totale |
| P | Performance des héros |
| R | Réputation actuelle de la guilde |

Plus la guilde est réputée, moins elle gagne sur des missions simples.

### 8.6 Paliers de déblocage des rangs de missions

| Rang | Réputation requise |
|------|-------------------|
| F | 0+ |
| E | 2+ |
| D | 4+ |
| C | 6+ |
| B | 8+ |
| A | 10+ |
| S | 12+ |

### 8.7 Drop de ressources rares

```
P_rare = 15%
```
Les ressources communes sont garanties. La ressource rare est un tirage indépendant.
La chance du héros peut modifier ce taux (à calibrer).

---

## 9. Diplomatie et Factions

> **Non implémenté** — données de design définitives.

### 9.1 Les 4 factions

| Faction | Spécialité |
|---------|-----------|
| **Empire de Valoria** | Ordre et loi, contrats militaires et défense |
| **Ligue Marchande** | Commerce, protection de caravanes, économie |
| **Ordre des Magi** | Magie, artefacts, recherches arcanes |
| **Garde du Nord** | Terres froides, chasse aux créatures glacées |

Relations : de −100 (Hostile) à +100 (Alliée). Commence à 0.

### 9.2 Gain de relation (mission réussie)

```
Gain_Rel = (D × P) × ((100 − R) / 100)
```
Plus on est proche d'une faction, plus les gains supplémentaires sont faibles. À R=100 → gain = 0.

### 9.3 Perte de relation (mission échouée)

```
Perte_Rel = D × (1 − P) × (0.2 + (100 + R) / 200)
```

| Valeur de R | Facteur multiplicateur |
|------------|----------------------|
| −100 (Hostile) | 0.2 (perte minimale) |
| 0 (Neutre) | ≈ 0.7 |
| +100 (Alliée) | 1.2 (plus à perdre) |

### 9.4 Prix ajusté selon la relation

```
Prix = Prix_base × (1 − R / 100)
```
Plafonné : réduction max −50% (à R=+100 → ×0.5, pas ×0.0).
À R=−100 → prix ×2.0.

### 9.5 Dons / Tributs (rendement décroissant)

```
Gain_don = Gain_base × (1 − R_actuelle / 200)
```
À R=0 → gain plein. À R=100 → gain réduit de 50%.

| Action | Gain relation | Coût | Cooldown |
|--------|--------------|------|---------|
| Don modeste | +1 | 200 or | 3 jours in-game |
| Don généreux | +3 | 800 or | 7 jours in-game |
| Don de ressources rares | +5 | Ressource rare × 5 | 14 jours in-game |

---

## 10. Économie

### 10.1 Sources de revenus

- Récompenses de missions (or + ressources + drops mobs)
- Vente de matériaux / équipements craftés au marché
- Recyclage d'équipements obsolètes (25% / 50% / 100% selon recherche)
- Récolte de plantes (jardin)
- Événements positifs (don anonyme, marchand rare…)

### 10.2 Sources de dépenses

- **Salaires journaliers** des héros (voir §2.10)
- Construction (murs, sols, objets)
- Achat de ressources aux factions (prix ajusté selon relation)
- Coûts de recrutement : `Salaire × 5`
- Remboursement prêts (si implémenté)

### 10.3 Cuisine

Stock de repas maintenu par les Cuisiniers (job=5) au Fourneau. Chaque héros consomme 1 repas/repas. Stock vide → moral baisse progressivement → démissions possibles.

**Fermentation** (stub) :
- Bière : 3× houblon, 3 jours in-game de fermentation
- Hydromel : 3× miel, 5 jours in-game de fermentation

---

## 11. Craft et Recherche

### 11.1 Vitesse de craft / Progression

```
Progression_par_tic = (Compétence_métier / Difficulté) × 0.35
```
Tâche complète quand progression cumulée atteint **100**. 1 tic = 5 min in-game.

Exemple : Forgeron Compétence=20, épée Rang D (difficulté=6) → 20/6 × 0.35 ≈ 1.17/tic → ~85 tics ≈ **7h in-game**.

### 11.2 Difficultés de référence par type de tâche

| Tâche | Difficulté |
|-------|-----------|
| Accueil candidat | 3 |
| Réception de quête | 4 |
| Cuisine (repas standard) | 3 |
| Forge / cuir — Rang F | 2 |
| Forge / cuir — Rang E | 4 |
| Forge / cuir — Rang D | 6 |
| Forge / cuir — Rang C | 8 |
| Forge / cuir — Rang B | 10 |
| Forge / cuir — Rang A | 12 |
| Forge / cuir — Rang S | 15 |
| Craft de potion | 5 |
| Enchantement d'équipement | 8 |
| Recherche d'enchantement | 10 |
| Recherche Niveau 1 | 3 |
| Recherche Niveau 2 | 4 |
| Recherche Niveau 3 | 5 |
| Recherche Niveau 4 | 6 |
| Recherche Niveau 5 | 7 |
| Recherche Niveau 6 | 8 |
| Recherche Niveau 7 | 9 |
| Recherche Niveau 8 | 10 |
| Recherche Niveau 9 | 12 |
| Recherche Niveau 10 | 14 |

### 11.3 Coûts des compétences par rang

| Rang | Coût (points de compétence) |
|------|----------------------------|
| F | 15 |
| E | 30 |
| D | 60 |
| C | 90 |
| B | 120 |
| A | 150 |
| S | 180 |

---

## 12. Évènements Aléatoires

Fréquence : **1 événement toutes les 5 à 10 jours in-game** (aléatoire).
Probabilité pondérée selon la réputation et l'état de la guilde.

> **Non implémenté** — données de design définitives.

### 12.1 Événements Positifs (9)

| Nom | Condition | Effet |
|-----|-----------|-------|
| Visite d'un marchand rare | Réputation ≥ 10 | Ressources rares à −20% pendant 1 jour |
| Inspiration soudaine | Bibliothèque présente | Recherche en cours +30% vitesse |
| Bon bruit sur la guilde | Réputation ≥ 20 | +2 héros dans le pool 3 jours |
| Don anonyme | Aléatoire | +500 à +1 500 or selon réputation |
| Apprenti talentueux | Salle d'accueil présente | Héros rang supérieur à la normale |
| Festival du royaume | 1 fois / saison | +15 moral à tous les héros, 2 jours |
| Découverte archéologique | Bibliothèque + rép. ≥ 15 | Déblocage gratuit recherche niv. 1 ou 2 |
| Récolte exceptionnelle | Jardin présent | Production de plantes ×2, 3 jours |
| *(à définir)* | | |

### 12.2 Événements Négatifs (9)

| Nom | Condition | Effet | Réponse |
|-----|-----------|-------|---------|
| Vol dans la guilde | Héros Voleur OU moral < 20 | −200 à −500 or | / |
| Maladie contagieuse | / | 1–3 héros : −30% efficacité 3 jours | Soins |
| Conflit interne | 2 héros traits incompatibles | −10 moral toute la guilde 2 jours | / |
| Accident à la forge | Travaux Manuels < 15 | Héros −40% PV max 2j + forge off 1j | Réparer (100 or) |
| Fuite d'un héros | Moral = 0 pendant 3+ jours | Démission garantie | Faire remonter moral |
| Infestation | / | Stock nourriture −50% | / |
| Panne d'équipement | / | Objet inutilisable | Réparer (50–200 or) |
| Mauvaise récolte | Jardin présent | Production nulle 5 jours | Aucune |
| *(à définir)* | | | |

### 12.3 Événements Neutres / à Choix (5)

| Nom | Description | Option A | Option B |
|-----|-------------|----------|----------|
| Héros blessé à la porte | Héros blessé (−50% PV max) propose ses services gratuitement | Accepter (héros gratuit, 5j récupération) | Refuser |
| Offre de rachat | Marchand achète tout un type d'équipement à +30% | Vendre | Refuser |
| Héros mécontent | Héros moral < 40 exige une prime | Payer (1× salaire, +20 moral) | Refuser (−15 moral, risque démission) |
| Mission secrète | Faction anonyme propose mission récompense ×2 | Accepter (risque inconnu) | Refuser |
| Défi d'un héros rival | Héros d'une autre guilde défie l'un des vôtres | Accepter (victoire : +15 moral +1 rép. / défaite : −10 moral) | Refuser (−5 moral au héros défié) |
