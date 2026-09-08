# Tilesets — Référence visuelle

> Taille de tile : **16 × 16 px** (`GameConfig.TILE_SIZE = 16`)
> Format : PNG, fond transparent pour les murs/props.
> `[x]` = texture existante dans `Assets/` · `[ ]` = à créer

---

## Convention d'organisation (Godot TileSet)

Chaque **TileSetAtlasSource** correspond à un `atlas_id` dans `ItemRegistry`.
Les floors et murs utilisent des atlas séparés (un PNG = une source).

```
Floor TileSet (floor_layer) :   atlas_id → source_id
Wall  TileSet (wall_layer)  :   atlas_id → source_id
```

Les props sont des **scènes/sprites indépendants** (pas dans le TileSet),
placés via `ConstructionLayer` avec leur propre PNG dans `Assets/Objects/`.

---

## Thème : Guilde (intérieur)

### Sols — Floor TileSet

| atlas_id | id ItemRegistry   | Fichier PNG                        | Statut |
|----------|-------------------|------------------------------------|--------|
| 0        | `dirt_floor`      | `Assets/Tiles/dirt_floor.png`      | [x]    |
| 1        | `wood_floor`      | `Assets/Tiles/wood_floor.png`      | [x]    |
| 2        | `stone_floor`     | `Assets/Tiles/stone_floor.png`     | [x]    |
| 3        | `carpet_red`      | `Assets/Tiles/carpet_red.png`      | [ ]    |
| 4        | `carpet_blue`     | `Assets/Tiles/carpet_blue.png`     | [ ]    |
| 5        | `wood_floor_dark` | `Assets/Tiles/wood_floor_dark.png` | [ ]    |
| 6        | `stone_tile`      | `Assets/Tiles/stone_tile.png`      | [ ]    |

> **Variantes par sol** : prévoir au moins 2–4 variantes (rotation/flip) dans l'atlas
> pour éviter la répétition visuelle. Organiser en grille 4×1 ou 2×2 dans le PNG.

---

### Murs — Wall TileSet

Chaque type de mur doit couvrir **les 12 variantes directionnelles** listées
ci-dessous, organisées en grille dans un seul PNG (4 colonnes × 3 lignes = 48 px × 48 px minimum, ou grille libre).

#### Variantes requises par type de mur

```
Grille de lecture (atlas) :
  Col 0      Col 1      Col 2      Col 3
  ┌───┐      ┌───┐      ┌───┐      ┌───┐
  │ N │      │ S │      │ E │      │ W │   Ligne 0 — faces droites
  └───┘      └───┘      └───┘      └───┘
  ┌───┐      ┌───┐      ┌───┐      ┌───┐
  │NW │      │NE │      │SW │      │SE │   Ligne 1 — coins extérieurs
  └───┘      └───┘      └───┘      └───┘
  ┌───┐      ┌───┐      ┌───┐      ┌───┐
  │cNW│      │cNE│      │cSW│      │cSE│   Ligne 2 — coins intérieurs
  └───┘      └───┘      └───┘      └───┘
  ┌───┐      ┌───┐      ┌───┐      ┌───┐
  │ T │  (optionnel : T-junction N/S/E/W, croix)
  └───┘
```

| atlas_id | id ItemRegistry  | Fichier PNG                          | Statut |
|----------|------------------|--------------------------------------|--------|
| 0        | `stone_wall`     | `Assets/Tiles/stone_wall.png`        | [x] ¹  |
| 1        | `wooden_wall`    | `Assets/Tiles/wooden_wall.png`       | [x] ¹  |
| 2        | `brick_wall`     | `Assets/Tiles/brick_wall.png`        | [ ]    |
| 3        | `wooden_door`    | `Assets/Tiles/wooden_door.png`       | [x]    |
| 4        | `reinforced_door`| `Assets/Tiles/reinforced_door.png`   | [x]    |
| 5        | `stone_arch`     | `Assets/Tiles/stone_arch.png`        | [ ]    |
| 6        | `iron_door`      | `Assets/Tiles/iron_door.png`         | [ ]    |

> ¹ Textures existantes à vérifier : contiennent-elles les 12 variantes
> directionnelles ou une seule tuile ? À compléter si nécessaire.

---

## Thème : Plaine (extérieur)

### Sols / Terrain

| atlas_id | id ItemRegistry   | Fichier PNG                        | Description                        | Statut |
|----------|-------------------|------------------------------------|------------------------------------|--------|
| 0        | `grass`           | `Assets/Tiles/grass_floor.png`     | Herbe standard                     | [x] ¹  |
| 1        | `grass_dark`      | `Assets/Tiles/grass_dark.png`      | Herbe dense / ombre                | [ ]    |
| 2        | `grass_dry`       | `Assets/Tiles/grass_dry.png`       | Herbe sèche / estivale             | [ ]    |
| 3        | `dirt_path`       | `Assets/Tiles/dirt_path.png`       | Chemin en terre battue             | [ ]    |
| 4        | `dirt_floor`      | `Assets/Tiles/dirt_floor.png`      | Sol nu (réutilisé)                 | [x]    |
| 5        | `mud`             | `Assets/Tiles/mud.png`             | Boue / zone humide                 | [ ]    |
| 6        | `sand`            | `Assets/Tiles/sand.png`            | Sable / rive                       | [ ]    |
| 7        | `water_shallow`   | `Assets/Tiles/water_shallow.png`   | Eau peu profonde (animée 2–4 fr.)  | [ ]    |
| 8        | `water_deep`      | `Assets/Tiles/water_deep.png`      | Eau profonde (animée 2–4 fr.)      | [ ]    |
| 9        | `rock_floor`      | `Assets/Tiles/rock_floor.png`      | Sol rocheux / falaise              | [ ]    |
| 10       | `snow`            | `Assets/Tiles/snow.png`            | Neige (biome hivernal)             | [ ]    |

> ¹ `grass_floor.png` à vérifier : inclut-il des variantes de remplissage ?

### Transitions (bords automatiques)

Ces tiles permettent de raccorder deux terrains sans coupure brutale.
Organiser sous forme de **terrain set Wang 3×3** dans Godot
(47 tiles par combinaison).

| Transition              | Terrain A     | Terrain B    | Statut |
|-------------------------|---------------|--------------|--------|
| Herbe → Terre           | `grass`       | `dirt_path`  | [ ]    |
| Herbe → Eau             | `grass`       | `water`      | [ ]    |
| Herbe → Roche           | `grass`       | `rock_floor` | [ ]    |
| Herbe → Sable           | `grass`       | `sand`       | [ ]    |
| Sable → Eau             | `sand`        | `water`      | [ ]    |
| Herbe sèche → Herbe std | `grass_dry`   | `grass`      | [ ]    |

> **Conseil** : commencer par Herbe → Terre (chemin de guilde) et
> Herbe → Eau (rivière) — les deux plus visibles en jeu.

### Éléments de terrain (non-navigables)

Ces tiles bloquent le pathfinding (physics layer) et servent de décor.

| id                | Description                     | Taille   | Statut |
|-------------------|---------------------------------|----------|--------|
| `cliff_top`       | Face supérieure de falaise      | 1×1      | [ ]    |
| `cliff_side`      | Face latérale de falaise        | 1×1      | [ ]    |
| `cliff_corner_*`  | Coins de falaise (4 variantes)  | 1×1 ×4   | [ ]    |
| `cliff_base`      | Pied de falaise                 | 1×1      | [ ]    |

---

## Props — Guilde (intérieur)

Props placés via `ItemRegistry` / `ConstructionLayer`.
Chaque prop est un PNG dans `Assets/Objects/`.

| id ItemRegistry       | Fichier PNG                         | Taille tiles | Salle             | Statut |
|-----------------------|-------------------------------------|--------------|-------------------|--------|
| `forge`               | `forge.png`                         | 2×2          | Forge             | [x]    |
| `anvil`               | `anvil.png`                         | 1×1          | Forge             | [x]    |
| `workbench_craft`     | `workbench.png`                     | 2×1          | Atelier           | [x]    |
| `grind_wheel`         | `grind_wheel.png`                   | 1×1          | Forge             | [x]    |
| `tanning_rack`        | `tanning_rack.png`                  | 2×1          | Atelier           | [x]    |
| `loom`                | `loom.png`                          | 2×1          | Couture           | [x]    |
| `furnace`             | `furnace.png`                       | 1×2          | Cuisine           | [x]    |
| `serving_table`       | `serving_table.png`                 | 2×1          | Cuisine           | [x]    |
| `bed_single`          | `bed_full.png`                      | 1×2          | Chambre           | [x]    |
| `reception_desk`      | `reception_desk.png`                | 2×1          | Hall              | [x]    |
| `bounty_board`        | `bounty_board.png`                  | 1×2          | Hall              | [x]    |
| `torch_wall`          | `torch.png`                         | 1×1          | Décor             | [x]    |
| `training_dummy`      | `training_dummy.png`                | 1×2          | Entraînement      | [x]    |
| `recycling_workshop`  | `recycling_workshop.png`            | 2×2          | Atelier           | [x]    |
| `sink`                | `sink.png`                          | 1×1          | Sanitaires        | [x]    |
| `toilet`              | `toilet.png`                        | 1×1          | Sanitaires        | [x]    |
| `luth`                | `luth.png`                          | 1×1          | Loisirs           | [x]    |
| `table_dining`        | `table.png`                         | 2×1          | Cuisine / Hall    | [x]    |
| `alchemy_table`       | `Assets/Objects/alchemy_table.png`  | 2×2          | Alchimie          | [ ]    |
| `magic_cauldron`      | `Assets/Objects/magic_cauldron.png` | 1×2          | Alchimie          | [ ]    |
| `bookshelf`           | `Assets/Objects/bookshelf.png`      | 2×1          | Arcanum           | [ ]    |
| `arcane_desk`         | `Assets/Objects/arcane_desk.png`    | 2×1          | Arcanum           | [ ]    |
| `crystal_ball`        | `Assets/Objects/crystal_ball.png`   | 1×1          | Arcanum           | [ ]    |
| `ascension_altar`     | `Assets/Objects/ascension_altar.png`| 3×3          | Ascension         | [ ]    |
| `meditation_mat`      | `Assets/Objects/meditation_mat.png` | 1×1          | Entraînement      | [ ]    |
| `weight_rack`         | `Assets/Objects/weight_rack.png`    | 2×1          | Entraînement      | [ ]    |
| `chest_wood`          | `Assets/Objects/chest_wood.png`     | 1×1          | Hall / Déco       | [ ]    |
| `chest_iron`          | `Assets/Objects/chest_iron.png`     | 1×1          | Hall / Déco       | [ ]    |
| `chair`               | `Assets/Objects/chair.png`          | 1×1          | Hall / Cuisine    | [ ]    |
| `chandelier`          | `Assets/Objects/chandelier.png`     | 1×1          | Décor (plafond)   | [ ]    |
| `herb_rack`           | `Assets/Objects/herb_rack.png`      | 1×1          | Infirmerie        | [ ]    |
| `infirmary_bed`       | `Assets/Objects/infirmary_bed.png`  | 1×2          | Infirmerie        | [ ]    |
| `plant_pot`           | `Assets/Objects/plant_pot.png`      | 1×1          | Déco              | [ ]    |
| `farming_plot`        | `Assets/Objects/farming_plot.png`   | 2×2          | Jardin            | [ ]    |
| `fermentation_barrel` | `Assets/Objects/barrel.png`         | 1×1          | Cuisine           | [ ]    |
| `weapon_rack`         | `Assets/Objects/weapon_rack.png`    | 1×2          | Entraînement      | [ ]    |
| `banner_guild`        | `Assets/Objects/banner_guild.png`   | 1×2          | Hall / Décor      | [ ]    |
| `trophy_case`         | `Assets/Objects/trophy_case.png`    | 2×1          | Hall              | [ ]    |

---

## Props — Plaine (extérieur)

Ces éléments aparaissent dans les scènes de mission (MissionScene) et
en décor autour de la guilde si une zone extérieure est ajoutée.

| id                  | Fichier PNG                           | Taille tiles | Description                       | Statut |
|---------------------|---------------------------------------|--------------|-----------------------------------|--------|
| `tree_oak`          | `Assets/Objects/tree.png`             | 2×3          | Chêne (sprite existant)           | [x]    |
| `tree_pine`         | `Assets/Objects/tree_pine.png`        | 2×3          | Pin                               | [ ]    |
| `tree_dead`         | `Assets/Objects/tree_dead.png`        | 2×2          | Arbre mort / hivernal             | [ ]    |
| `tree_stump`        | `Assets/Objects/tree_stump.png`       | 1×1          | Souche                            | [ ]    |
| `rock_small`        | `Assets/Objects/rock_small.png`       | 1×1          | Rocher petit                      | [ ]    |
| `rock_large`        | `Assets/Objects/rock_large.png`       | 2×2          | Rocher large                      | [ ]    |
| `rock_cluster`      | `Assets/Objects/rock_cluster.png`     | 2×1          | Groupe de pierres                 | [ ]    |
| `bush`              | `Assets/Objects/bush.png`             | 1×1          | Buisson                           | [ ]    |
| `bush_berry`        | `Assets/Objects/bush_berry.png`       | 1×1          | Buisson à baies (farmable)        | [ ]    |
| `flowers_wild`      | `Assets/Objects/flowers_wild.png`     | 1×1          | Fleurs sauvages (déco)            | [ ]    |
| `tall_grass`        | `Assets/Objects/tall_grass.png`       | 1×1          | Herbes hautes (déco / cache)      | [ ]    |
| `mushroom_cluster`  | `Assets/Objects/mushrooms.png`        | 1×1          | Champignons                       | [ ]    |
| `hay_bale`          | `Assets/Objects/hay_bale.png`         | 1×1          | Botte de foin                     | [ ]    |
| `fence_h`           | `Assets/Objects/fence_h.png`          | 1×1          | Clôture bois horizontal           | [ ]    |
| `fence_v`           | `Assets/Objects/fence_v.png`          | 1×1          | Clôture bois vertical             | [ ]    |
| `fence_post`        | `Assets/Objects/fence_post.png`       | 1×1          | Poteau de clôture                 | [ ]    |
| `well`              | `Assets/Objects/well.png`             | 2×2          | Puits                             | [ ]    |
| `campfire`          | `Assets/Objects/campfire.png`         | 1×1          | Feu de camp (animé 2–4 fr.)       | [ ]    |
| `tent`              | `Assets/Objects/tent.png`             | 3×2          | Tente de camp                     | [ ]    |
| `signpost`          | `Assets/Objects/signpost.png`         | 1×1          | Panneau indicateur                | [ ]    |
| `ruins_wall`        | `Assets/Objects/ruins_wall.png`       | 1×2          | Pan de mur en ruine               | [ ]    |
| `ruins_pillar`      | `Assets/Objects/ruins_pillar.png`     | 1×2          | Pilier ruiné                      | [ ]    |
| `crate_wood`        | `Assets/Objects/crate_wood.png`       | 1×1          | Caisse en bois (loot)             | [ ]    |
| `cart`              | `Assets/Objects/cart.png`             | 2×2          | Charette                          | [ ]    |
| `bridge_h`          | `Assets/Objects/bridge_h.png`         | 3×1          | Pont horizontal (sur eau)         | [ ]    |
| `pond_lily`         | `Assets/Objects/pond_lily.png`        | 1×1          | Nénuphar (déco eau)               | [ ]    |

---

## Résumé

| Catégorie              | Existant | À créer | Total |
|------------------------|----------|---------|-------|
| Sols Guilde            | 3        | 4       | 7     |
| Murs Guilde            | 4        | 3       | 7     |
| Sols Plaine            | 2        | 9       | 11    |
| Transitions Plaine     | 0        | 6       | 6     |
| Terrain bloquant       | 0        | 6       | 6     |
| Props Guilde           | 18       | 20      | 38    |
| Props Plaine           | 1        | 25      | 26    |
| **Total**              | **28**   | **73**  | **101**|

### Priorités suggérées

1. **Alchemy table + Magic cauldron** — débloqueront le craft d'alchimie
2. **Bookshelf + Arcane desk** — salle Arcanum (recherche)
3. **Farming plot** — salle Jardin (FarmingManager opérationnel)
4. **Barrel + Herb rack + Infirmary bed** — cuisine et infirmerie
5. **Transitions Herbe→Terre et Herbe→Eau** — qualité visuelle des missions
6. **Rocks + Bush + Tree pine/dead** — variété des environnements de mission
