# Jeu de Gestion de Guilde — Documentation Technique

> **Moteur** : Godot 4.4 | **Langage** : GDScript | **Style** : Pixel art 16-bit, top-down
> **Genre** : Gestion de guilde d'aventuriers (inspiré Dwarf Fortress / Guild of Dungeoneering)
> **Fichiers associés** : [`GDD.md`](GDD.md) — règles de jeu & formules | [`CONTENT.md`](CONTENT.md) — listes de contenu exhaustives

**Règles de code :**
- Typage explicite TOUJOURS : `var x : int = 0`, jamais `var x := 0`
- Le code doit respecter les principes SOLID
- Ces fichiers doivent être continuellement tenus à jour

---

## Table des matières

1. [Vision du Jeu](#1-vision-du-jeu)
2. [Architecture du Projet](#2-architecture-du-projet)
3. [Autoloads — Ordre et Rôles](#3-autoloads--ordre-et-rôles)
4. [Scène Principale — Navigation](#4-scène-principale--architecture-de-navigation)
5. [GuildScene — Structure](#5-guildscene--structure)
6. [Systèmes Principaux](#6-systèmes-principaux)
7. [HeroData — Champs Principaux](#7-herodata--champs-principaux)
8. [HeroPanel — Interface](#8-heropanel--interface)
9. [Caméra](#9-caméra-guild_cameragd)
10. [Options (SettingsManager)](#10-options-settingsmanager)
11. [Sauvegarde (SaveManager)](#11-sauvegarde-savemanager)
12. [Construction — Placeholders](#12-système-de-construction--placeholders)
13. [Traduction](#13-traduction)
14. [EventBus — Signaux](#14-eventbus--signaux-déclarés)
15. [TODO — État d'avancement](#15-todo--état-davancement)
16. [Points d'Attention](#16-points-dattention-pour-reprendre-le-projet)
17. [Dette Technique & SOLID](#17-dette-technique--violations-solid)

---

## 1. Vision du Jeu

Le joueur gère une guilde d'aventuriers dans un monde médiéval-fantastique (Astralia). Il recrute des héros, construit et aménage la guilde, planifie les journées des héros (sommeil, travail, entraînement, temps libre), et les envoie en mission. Les héros ont des besoins, un moral, des traits de caractère, et peuvent démissionner si mal traités.

**Boucle principale :**
1. Construire et améliorer la guilde (murs, sols, objets)
2. Recruter et gérer les héros (planning, besoins, moral)
3. Envoyer des héros en mission → or, ressources, réputation, XP
4. Réinvestir pour progresser → missions plus difficiles → retour au 1

**Univers** : Monde Astralia — médiéval-fantastique avec magie. Rangs héros : F → E → D → C → B → A → S. Voir [GDD.md](GDD.md) pour les règles, [CONTENT.md](CONTENT.md) pour tous les contenus.

---

## 2. Architecture du Projet

```
res://
├── Autoloads/
│   ├── GameConfig.gd              ← Constantes globales (source unique)
│   ├── EventBus.gd                ← Bus de signaux global
│   ├── GameData.gd                ← État runtime (or, réputation, murs...)
│   ├── UIState.gd                 ← État UI global (menu_open) — séparé de GameData (SRP)
│   ├── WorldContext.gd            ← Références aux conteneurs de la scène active
│   ├── ObjectFinder.gd            ← Service centralisé de recherche d'objets
│   ├── TimeManager.gd             ← Temps in-game (tick, heure, jour)
│   ├── Generator/
│   │   └── HeroGenerator.gd       ← Génération procédurale HeroData
│   ├── Manager/
│   │   ├── ConstructionManager.gd
│   │   ├── CraftManager.gd        ← File de craft par poste de travail
│   │   ├── GuildInventoryManager.gd
│   │   ├── HeroManager.gd
│   │   ├── MissionManager.gd      ← Génération + résolution des missions
│   │   ├── RecruitManager.gd
│   │   ├── ResearchManager.gd     ← Arbre de recherche (39 recherches, 10 niveaux)
│   │   ├── RoomManager.gd         ← Détection des pièces (flood-fill)
│   │   ├── SaveManager.gd
│   │   ├── SceneManager.gd
│   │   ├── AudioManager.gd
│   │   └── SettingsManager.gd
│   └── Registry/
│       ├── EquipmentLibrary.gd    ← équipements (armes, armures, accessoires, potions)
│       ├── HeroClassRegistry.gd   ← 6 classes de base + 12 avancées
│       ├── ItemRegistery.gd       ← ⚠ typo à corriger (ItemRegistry)
│       ├── MaterialLibrary.gd     ← matériaux (naturels, craftables, magiques, drops)
│       ├── MobLibrary.gd          ← 19 mobs (F→S) avec stats, drops, attaques
│       ├── ResearchLibrary.gd     ← 39 recherches réparties sur 10 niveaux
│       └── SkillLibrary.gd        ← 99 compétences pour les 6 classes de base
├── Entities/
│   ├── Hero/
│   │   ├── Hero.tscn / Hero.gd            ← CharacterBody2D (guilde)
│   │   └── Components/
│   │       ├── HeroActivity.gd            ← Exécute les tâches (navigate, travail, craft…)
│   │       ├── HeroRoutine.gd             ← Think tree, lit le planning
│   │       ├── HeroNeeds.gd               ← Décrémente besoins, moral, salaire, level up
│   │       ├── HeroNavigator.gd           ← Wrapper NavigationAgent2D
│   │       ├── HeroAnimator.gd            ← Anime le sprite
│   │       └── heroVisual.gd              ← ⚠ nommage incohérent (snake_case)
│   └── Mission/
│       ├── HeroCombatNode.gd              ← Héros en combat (jouable ou IA)
│       └── MobNode.gd                     ← Mob en combat
├── Ressources/
│   └── Heros/HeroData.gd                  ← Resource complète (stats, besoins, équipement…)
├── Scenes/
│   ├── Main/Main.tscn / main.gd           ← Racine permanente
│   ├── Guild/
│   │   ├── GuildScene.tscn / guild_scene.gd
│   │   └── UI/
│   │       ├── guild_hud.gd
│   │       ├── BuildMenu/
│   │       └── HeroPanel/
│   ├── Mission/
│   │   ├── mission_scene.gd               ← Orchestrateur mission (spawns héros + mobs)
│   │   ├── CombatHUD.tscn / CombatHUD.gd  ← HUD combat (barres HP, skills, log)
│   │   ├── HeroCard.tscn / HeroCard.gd    ← Carte héros dans le HUD
│   │   └── Environments/Wood1/            ← Environnement forêt (génération procédurale)
│   └── Menus/
├── Systems/
│   ├── Construction/
│   │   ├── ConstructionLayer.gd
│   │   ├── ConstructionInput.gd
│   │   ├── Grid/Grid.gd
│   │   ├── Preview/ConstructionPreview.gd
│   │   └── ObjectScene/GuildObject.gd     ← Classe de base data-driven
│   └── Notifications/notification.gd
├── Assets/
│   └── Sprites/Heroes/                    ← Sprites modulaires
└── Locales/
    └── translations.csv                   ← Traductions fr/en
```

---

## 3. Autoloads — Ordre et Rôles

L'ordre dans `project.godot` est critique. Les autoloads s'initialisent dans l'ordre déclaré.

| Ordre | Nom | Rôle |
|-------|-----|------|
| 1 | `GameConfig` | Constantes globales (TILE_SIZE, TIME_SPEEDS, NEED_DECAY, JOB_CRAFT_OBJECTS, CRAFT_SPEED_FACTOR=0.35…) |
| 2 | `EventBus` | Bus de signaux — zéro couplage entre systèmes |
| 3 | `GameData` | État runtime : or, réputation, inventaire, murs[], floors[] |
| 4 | `UIState` | État UI global : `menu_open` — séparé de GameData (SRP) |
| 5 | `WorldContext` | Références live aux conteneurs de scène (objects_container, heroes_container) |
| 6 | `ObjectFinder` | Service de recherche d'objets — `find_free_object()`, `find_free_object_in_list()` |
| 7 | `TimeManager` | Temps in-game, pause/unpause, vitesses x1/x2/x4, tick=5min |
| 8 | `SaveManager` | Sérialise/désérialise vers `user://save.json` |
| 9 | `SceneManager` | Navigation entre scènes via SceneContainer dans Main |
| 10 | `SettingsManager` | Préférences user → `user://preferences.json` |
| 11 | `AudioManager` | Buses Music + SFX, crossfade, pool SFX (8 players) |
| 12 | `HeroManager` | Spawn/fire/serialize héros |
| 13 | `ItemRegistry` | Données items construction (coût, atlas_id, taille…) |
| 14 | `EquipmentLibrary` | Équipements : armes (10 types), armures, accessoires, potions |
| 15 | `BetterTerrain` | Addon externe terrain auto |
| 16 | `ConstructionManager` | État construction, pending_tasks, finalize |
| 17 | `RoomManager` | Détection des pièces par flood-fill |
| 18 | `HeroClassRegistry` | 6 classes de base + 12 avancées (stat_range, weapon_types, armor_type…) |
| 19 | `SkillLibrary` | 99 compétences (6 classes de base, F→S) |
| 20 | `MobLibrary` | 19 mobs (F→S) avec stats, drops, attaques typées |
| 21 | `MaterialLibrary` | Matériaux (naturels, craftables, magiques, drops, culinaires) |
| 22 | `HeroGenerator` | Génération procédurale de HeroData (stateless) |
| 23 | `RecruitManager` | Pool recrutement, timer, pool_changed signal |
| 24 | `MissionManager` | 13 templates de missions, résolution succès/échec, effets moraux |
| 25 | `GuildInventoryManager` | Inventaire guilde (30 slots) |
| 26 | `ResearchManager` | Arbre de recherche (39 recherches sur 10 niveaux) |
| 27 | `CraftManager` | Files de craft par poste, progression par tick, consommation matériaux |

> **Important** : `SettingsManager` DOIT être avant `AudioManager` pour que `apply_audio()` fonctionne au démarrage.

---

## 4. Scène Principale — Architecture de Navigation

```
Main (Node — permanent, jamais détruit)
├── SceneContainer (Node — les scènes enfants sont chargées/déchargées ici)
│   └── [GuildScene | MissionScene | MainMenu | Options | ...] ← une seule à la fois
└── NotificationContainer (CanvasLayer — HUD global)
    └── [Notification nodes instanciés dynamiquement]
```

`SceneManager.go_to("guild")` détruit l'enfant courant de SceneContainer et instancie la nouvelle scène. **Ne jamais utiliser `change_scene_to_packed()`.**

**Navigation mission** : `MissionManager.start_playable_mission(mission_data, hero_ids)` → `SceneManager.go_to("mission", params)` → `mission_scene.gd` instancie héros + mobs + CombatHUD.

---

## 5. GuildScene — Structure

```
GuildScene (Node2D)
├── World (Node2D)
│   ├── Level (Node2D)
│   │   ├── Floor (TileMapLayer)       ← sols
│   │   ├── Wall (TileMapLayer)        ← murs
│   │   └── Preview (TileMapLayer)     ← preview construction (modulate 0.5α)
│   ├── Objects (Node2D)               ← objets placés
│   ├── Heroes (Node2D)                ← héros spawnés
│   ├── NavigationRegion2D
│   └── CanvasModulate                 ← cycle jour/nuit
├── Construction (instance ConstructionLayer.tscn)
├── GuildCamera (Camera2D + guild_camera.gd)
├── PauseMenu (CanvasLayer)
└── UILayer (CanvasLayer, layer=5)
    ├── HUD (guild_hud.gd)
    ├── HeroPanel (hero_panel.tscn)
    └── BuildMenu (build_menu.gd)
```

**MissionScene** :
```
MissionScene (Node2D)
├── World (Node2D)
│   ├── TileMap / NavigationRegion2D
│   ├── Heroes (Node2D)   ← HeroCombatNode instanciés
│   └── Mobs (Node2D)     ← MobNode instanciés
└── CombatHUD (CanvasLayer, layer=10)
    ├── TopLeft     ← Info mission (full-IA seulement)
    ├── TopRight    ← BtnPause / BtnPlay / BtnFast
    ├── BottomLeft  ← HeroCards (1-4, slots pré-alloués)
    ├── BottomCenter← Slots compétences (Comp.1-4 + Obj.1-2)
    ├── BottomRight ← Journal de combat (petite fenêtre)
    └── EndPanel    ← Écran de fin (Victoire / Défaite)
```

---

## 6. Systèmes Principaux

### 6.1 Temps (TimeManager)

- **1 tick = 5 minutes in-game**
- Vitesses : `TIME_SPEEDS = [0, 1, 2, 4]` (index 0 = pause)
- Signaux émis : `time_tick(hour, minute)`, `hour_changed(hour)`, `day_changed(day)`
- `TimeManager.current_hour` (0–23)
- `TimeManager.pause()` / `TimeManager.unpause()`

### 6.2 Héros — Composants (guilde)

Chaque héros (`CharacterBody2D`) a 5 composants enfants accessibles via `%` :

| Composant | Rôle |
|-----------|------|
| `HeroRoutine` | Lit le planning, génère les tâches par priorité via think tree |
| `HeroActivity` | Exécute la tâche (navigate, travail, craft, construction…) |
| `HeroNeeds` | Décrémente besoins, moral (TEMPORARY/CONSTANT/PROGRESSIVE), salaire, level up |
| `HeroNavigator` | Wrapper NavigationAgent2D, `set_destination()`, signaux `navigation_finished` |
| `HeroAnimator` | Anime le sprite selon la direction et l'activité |

**Pattern _exit_tree** : tous les composants qui se connectent à EventBus doivent déconnecter dans `_exit_tree()`.

### 6.3 Routine des Héros — Think Tree

`HeroRoutine._on_time_tick()` → `_evaluate_think_tree()` → `HeroActivity.perform(task)` (seulement si le type de tâche change).

| Niveau | Branche | Logique |
|--------|---------|---------|
| 1 | **Critique** | Énergie < 8, faim < 10, toilette < 8 → switch immédiat, interrompt **tout** |
| 2 | **Continuation** | Tâche en cours encore valide → pas d'interruption |
| 3 | **Planning** | Tâche assignée pour cette heure, si réalisable (objet disponible) |
| 4 | **Libre** | Besoins secondaires par ordre de priorité (faim < 35%, énergie < 20%, divertissement < 25%, toilette < 20%, hygiène < 25%), puis construction, puis divertissement |
| 5 | **Idle** | Fallback — erre aléatoirement |

> **Distinction seuils** : niveau 1 = seuil d'interruption absolue. Niveau 4 = seuil de recherche autonome (valeurs différentes, voir GDD.md §3).

**Seuils GameConfig** :

| Constante | Usage |
|-----------|-------|
| `NEED_CRITICAL_THRESHOLD` | Déclenche l'interruption absolue (niveau 1) |
| `NEED_URGENT_THRESHOLD` | Interrompt work/train/construct (continuation niveau 2) |
| `NEED_FREE_THRESHOLD` | Seuils pour la branche libre (niveau 4) |

### 6.4 Construction

**Flow complet** :
1. Joueur place objet/mur via BuildMenu → `ConstructionManager.request_*()` → débit or → `_make_task()` → `pending_tasks.append()` → `EventBus.construction_task_added.emit(task)`
2. `ConstructionLayer` crée un `ColorRect` bleu 50% transparent (placeholder)
3. Héros libre → `HeroRoutine` génère tâche `construct` → `HeroActivity._construct()` → navigate adjacence
4. Arrivée → `EventBus.construction_task_completed.emit(task)` → `ConstructionManager._finalize_task()` → objet/tuile posé, placeholder supprimé

### 6.5 Système de Craft (CraftManager)

**Clé de station** : `"%d,%d" % [origin.x, origin.y]` (position grille, stable entre sessions)

**Flow** :
1. UI appelle `CraftManager.add_to_queue(object, material_id, qty)` — vérifie compatibilité poste
2. Quand un héros s'assoit au poste : `CraftManager.register_worker(object, hero)`
3. Chaque `time_tick` : `increment = (skill / craft_time) × CRAFT_SPEED_FACTOR`
4. À 100% : `GameData.add_item(mat_id, 1)` + notification + passe à l'item suivant

**Formula** : `Progression_par_tic = (Compétence / Difficulté) × 0.35` (voir GDD.md §8.1)

**Objets par métier** (JOB_CRAFT_OBJECTS) :

| Job | ID | Objets |
|-----|-----|--------|
| 0 | Libre | — |
| 1 | Accueil | reception_desk |
| 2 | Forgeron | forge, workbench_craft, tanning_rack, loom |
| 3 | Alchimiste | alchemy_table, magic_cauldron |
| 4 | Chercheur | research_desk |
| 5 | Cuisinier | furnace |

### 6.6 Moral (HeroNeeds)

Trois types d'effets moraux, gérés dans `HeroNeeds.gd` :

| Type | Description | Durée |
|------|-------------|-------|
| `TEMPORARY` | Effet passager avec durée en ticks | 1–12h |
| `CONSTANT` | Actif tant que la condition dure | Illimité |
| `PROGRESSIVE` | Appliqué progressivement sur N ticks | Plusieurs jours |

API : `add_timed_effect(label, value, duration_ticks)`, `add_progressive_effect(label, total, duration_ticks)`

Voir GDD.md §4 pour les tables complètes d'effets moraux.

### 6.7 Planification des Héros

`HeroData.planning` = `Dictionary { int(heure 0-23) → String("sleep"|"work"|"train"|"free") }`

**Couleurs** :
- Bleu nuit `Color(0.20, 0.30, 0.70)` → sleep
- Orange `Color(0.80, 0.55, 0.10)` → work
- Vert `Color(0.15, 0.60, 0.25)` → train
- Gris `Color(0.40, 0.40, 0.45)` → free

### 6.8 Recrutement

**Formules** (voir GDD.md §6 pour le détail complet) :
- `T_recrutement (h) = 15 − min(Réputation / 5, 12)` → entre 3h et 15h
- `Max_héros_visibles = 1 + floor(Réputation / 10)`
- Coût recrutement = `salaire × 5`
- Niveau proposé : `Niveau_moyen_guilde + (Réputation / 2) + rand(−5, 0)`
- Rang proposé : `Score = (Niveau / 10) + (Réputation / 3)` → table conversion (voir GDD.md §6.3)
- Probabilité classe avancée : 20% (si le joueur a déjà un héros de cette classe avancée), 80% classe de base

### 6.9 Missions (MissionManager)

- 13 templates de missions (difficulté F→S)
- Génération selon réputation : rang max accessible, tirage parmi les disponibles
- Résolution : `P = (HP_finale_moy / HP_init_moy) × Ratio_objectifs` → succès/échec
- Effets moraux automatiques : succès → `add_timed_effect("+moral mission", +10, 24ticks)`, échec → −10
- Mise à jour du rang héros : `missions_last_20` + `_recalculate_rank()` après chaque mission
- Héros en mission : `on_mission=true`, `visible=false`, routines suspendues

### 6.10 Recherche (ResearchManager)

- 39 recherches réparties sur 10 niveaux (voir CONTENT.md §7)
- Avancement par `time_tick` si un héros Chercheur (job=4) est au `research_desk`
- Vitesse : `progress += (knowledge / RESEARCH_DIFFICULTY[level]) × 0.35`
- Déblocage : certains objets dans `ItemRegistry` sont gated par une recherche

### 6.11 Équipements (EquipmentLibrary)

**Structure** : `{ id, label, type, subtype, rank, stats, effects, recipe, craft_location, price, description }`

| Type | Sous-types | Rangs |
|------|-----------|-------|
| `weapon` | epee, hache, lance, dague, marteau, baton, arc, orbe, grimoire, shuriken | F→S (10 types, rangs variables) |
| `armor` | legere, moyenne, lourde | F→S (3 sous-types × tête/torse/jambes) |
| `accessory` | anneau, amulette | Divers rangs |
| `consumable` | potion_soin, potion_mana, potion_buff, potion_defense, potion_rare | Divers effets |

**Bonus stats disponibles** : `atk`, `matk`, `def`, `mdef`, `spd`, `crit`, `hp`, `mana`

**API HeroData** :
```gdscript
hero_data.equip("epee_acier")        # valide la compatibilité classe, retourne bool
hero_data.unequip("weapon")          # vide le slot
hero_data.get_equipment_bonus("atk") # somme des bonus de tous les slots
```

Voir CONTENT.md §3–5 pour les listes complètes d'armes, armures, accessoires, potions.

### 6.12 Audio

`AudioManager` crée en code 2 players musique (crossfade) et 8 players SFX. Les volumes sont pilotés par `SettingsManager.apply_audio()`.

`AudioManager._on_scene_loaded("guild")` → `play_music(guild_ambiance.ogg)` avec `stream.loop = true`.

**Buses à créer dans Godot** : `Project > Audio` → ajouter `Music` et `SFX` (output → Master).

### 6.13 Notifications

4 types : `success` (vert), `error` (rouge), `warning` (jaune), `info` (bleu).

`EventBus.ui_notification_requested.emit(message, type)` → filtre `SettingsManager.get_value("notifications")` → max 3 simultanées.

### 6.14 Combat (MissionScene)

**HeroCombatNode** : CharacterBody2D jouable ou IA. Gère attaques, compétences, potions auto, effets de statut, dégâts visuels (flash, nombres flottants), flèche de direction (joueur).

**MobNode** : IA simple — approche, attaque, séparation anti-overlap. `collision_mask = 6` (layer 2 héros + layer 3 mobs).

**CombatHUD** : CanvasLayer layer=10. 4 slots HeroCard pré-alloués (`set_empty()` grisé). Remplis par `add_hero_card()` au lancement.

Voir GDD.md §7 pour les formules de combat complètes.

---

## 7. HeroData — Champs Principaux

```gdscript
## Identité
var hero_id           : int
var hero_name         : String
var rank              : String    # "F" | "E" | "D" | "C" | "B" | "A" | "S"
var hero_class        : String
var level             : int
var xp                : float
var job               : int       # 0=libre, 1=accueil, 2=forgeron, 3=alchimiste, 4=chercheur, 5=cuisinier
var is_advanced_class : bool
var class_type        : String    # "physique" | "magique"
var weapon_types      : Array[String]  # catégories équipables (ex: ["epee", "hache"])
var armor_type        : String         # "legere" | "moyenne" | "lourde"

## Stats combat (principales)
var strength   : float
var defense    : float
var agility    : float
var magic      : float
var luck       : float

## Stats dérivées
var hp_max     : float     # 100 + Force×2 + Défense×1.5 + bonus équipement
var hp         : float
var mana_max   : float     # 50 + Magie×3 + bonus équipement
var mana       : float

## Stats métier
var social      : float
var manual_work : float
var occult_work : float
var cooking     : float
var knowledge   : float

## Besoins (100 = plein, 0 = vide)
var hunger        : float
var energy        : float
var entertainment : float
var toilet        : float
var hygiene       : float

## Moral & Économie
var moral       : float    # 0–100
var salary      : int      # or/jour
var days_unpaid : int

## Planning  { heure(int) → "sleep"|"work"|"train"|"free" }
var planning : Dictionary

## Traits [String]
var traits : Array[String]

## Priorités entraînement
var strength_priority : int
var defense_priority  : int
var agility_priority  : int
var mana_priority     : int

## Compétences  [{ "id": String, "rank": String, "level": int }]
var skills : Array

## Compétences équipées en combat (4 slots)
var equipped_skills : Array[String]

## Équipement  { "weapon", "armor", "accessory", "consumable" → item_id }
var equipment : Dictionary

## Apparence  { "body", "eyes", "hair", "top", "helm", "pant" }
var appearance : Dictionary

## Missions
var on_mission           : bool
var missions_last_20     : Array    # historique true/false pour calcul du rang
var mission_return_day   : int
var mission_return_hour  : int
```

**Getters calculés** :
```gdscript
get_hp_max()                    # inclut bonus équipement
get_mana_max()                  # inclut bonus équipement
get_speed()                     # V_base × (1 + Agilité / 100)
get_crit_chance()               # Chance × 0.5 + bonus équipement
get_equipment_bonus(stat_key)   # somme des bonus équipement pour un stat
equip(item_id) -> bool          # valide compatibilité classe
unequip(slot)                   # vide le slot
```

---

## 8. HeroPanel — Interface

3 onglets :

**Liste** : une `HeroListRow` par héros — rang, nom, classe, niveau, barre HP colorée, barre moral, bouton ⌖ (focus caméra), bouton ✕ (renvoyer avec `ConfirmationDialog`).

**Planning** : une `PlanningRow` par héros (nom cliquable + 24 ColorRect). Préréglages : Journée/Nuit/Entraînement/Congé. Le NameLabel passe en jaune si un preset est sélectionné.

**Recruter** : une `RecruitRow` par héros disponible — rang, nom, classe, niveau, coût, bouton ✓/✕. Bouton `[TEST]` pour générer un héros instantanément.

---

## 9. Caméra (guild_camera.gd)

- Zoom initial : `Vector2(2, 2)`
- Pan : ZQSD (physical keycodes)
- Vitesse : `SettingsManager.get_value("camera_speed")` (défaut 400 px/s, divisé par zoom)
- Zoom molette : lerp vers `_zoom_target`
- Focus : `EventBus.camera_focus_requested.emit(world_position)`
- Position sauvegardée dans `GameData.save_camera_state()` avant de quitter vers les options

---

## 10. Options (SettingsManager)

Persistées dans `user://preferences.json`. Appliquées au démarrage via `apply_all()`.

| Clé | Type | Défaut |
|-----|------|--------|
| `volume_master` | float | 0.8 |
| `volume_music` | float | 0.6 |
| `volume_sfx` | float | 1.0 |
| `window_mode` | String | "windowed" |
| `resolution` | String | "1920x1080" |
| `vsync` | bool | true |
| `camera_speed` | float | 400.0 |
| `default_game_speed` | int | 1 |
| `notifications` | bool | true |
| `language` | String | "fr" |

---

## 11. Sauvegarde (SaveManager)

Format : `user://save.json` — JSON structuré.

```json
{
  "version": 1,
  "timestamp": 1234567890,
  "game_data":        { "gold": 500, "reputation": 3, "walls": {}, "floors": {} },
  "time_manager":     { "day": 5, "hour": 10, "minute": 30, "speed_index": 1 },
  "construction":     { "placed_objects": {}, "pending_tasks": [] },
  "heroes":           [ { "hero_id": 0, "hero_name": "...", ... } ],
  "recruit":          { "pool": [], "hours_since_last_spawn": 4.0 },
  "missions":         { ... },
  "guild_inventory":  { ... },
  "research":         { ... },
  "craft":            { "0,0": { "queue": [], "active": null, "progress": 0.0 } }
}
```

Managers sérialisés : `GameData`, `TimeManager`, `ConstructionManager`, `HeroManager`, `RecruitManager`, `MissionManager`, `GuildInventoryManager`, `ResearchManager`, `CraftManager`.

---

## 12. Système de Construction — Placeholders

**Placeholders = `ColorRect`** créés dynamiquement dans `ConstructionLayer`, stockés dans `_placeholder_nodes : Dictionary = { Vector2i → ColorRect }`.

Couleur : `Color(0.3, 0.6, 1.0, 0.5)` (bleu, 50% transparent), z_index = 5.

---

## 13. Traduction

Format CSV Godot : `res://Locales/translations.csv`

**Convention de clés** : `UI_`, `NOTIF_`, `HERO_`, `ACTIVITY_`, `TRAIT_`, `ERR_`

Les IDs internes (classes, traits, matériaux) restent en anglais. Seul l'affichage utilise `tr("TRAIT_" + trait_id)`.

---

## 14. EventBus — Signaux Déclarés

```gdscript
## Navigation
signal scene_change_requested(scene_id: String, params: Dictionary)
signal scene_loaded(scene_id: String)

## Caméra
signal camera_focus_requested(world_position: Vector2)

## Temps
signal time_tick(hour: int, minute: int)
signal hour_changed(hour: int)
signal day_changed(day: int)
signal time_speed_changed(speed_index: int)
signal game_paused(is_paused: bool)
signal day_night_changed(is_day: bool)

## Héros
signal hero_hired(hero_data: Resource)
signal hero_fired(hero_id: int)
signal hero_inspect_requested(hero_data: HeroData, screen_pos: Vector2)
signal hero_died(hero_id: int)
signal hero_selected(hero_data: Resource)
signal hero_deselected()
signal hero_stat_changed(hero_id: int, stat_name: String, new_value: float)
signal hero_need_changed(hero_id: int, need_name: String, new_value: float)
signal hero_task_changed(hero_id: int, task_type: String)
signal hero_level_up(hero_id: int, stat_name: String, new_level: int)
signal hero_moral_effects_changed(hero_id: int, effects: Array)

## Construction / Objets
signal object_placed(object_type: String, grid_position: Vector2i)
signal object_removed(grid_position: Vector2i)
signal object_context_menu_requested(object_node: Node2D, screen_position: Vector2)
signal object_used(object_type: String, hero_id: int)
signal object_freed(object_type: String, hero_id: int)
signal wall_placed(grid_position: Vector2i, item_id: String)
signal wall_removed(grid_position: Vector2i)
signal floor_placed(grid_position: Vector2i, floor_type: String)
signal construction_mode_changed(construction_type: String, item_id: String)
signal construction_task_requested(hero_id: int)
signal construction_task_assigned(hero_id: int, task: Dictionary)
signal construction_task_added(task: Dictionary)
signal construction_task_completed(task: Dictionary)
signal construction_task_failed(task: Dictionary, hero_id: int)
signal reset_preview()
signal walls_destroyed(positions: Array[Vector2i], neighbors: Array[Vector2i])
signal rooms_updated(rooms: Array)
signal navigation_map_changed()

## Économie / Ressources
signal gold_changed(new_value: int, delta: int)
signal food_changed(new_value: int, delta: int)
signal reputation_changed(new_value: int, delta: int)
signal resource_changed(resource_name: String, new_value: float)
signal inventory_changed(item_name: String, new_quantity: int)

## Missions
signal mission_available(mission_data: Resource)
signal mission_started(mission_data: Resource)
signal mission_completed(mission_data: Resource, success: bool)
signal bounty_accepted(bounty_data: Resource)

## Recherche / Craft
signal research_completed(research_id: String)
signal recipe_unlocked(recipe_id: String)
signal item_crafted(item_name: String, quantity: int)
signal craft_queue_changed(station_key: String, queue: Array)
signal craft_progress_updated(station_key: String, material_id: String, progress: float)
signal craft_material_missing(station_key: String, material_id: String)

## UI
signal ui_panel_open_requested(panel_id: String, payload: Dictionary)
signal ui_panel_close_requested(panel_id: String)
signal ui_notification_requested(message: String, type: String)
signal ui_tooltip_show(text: String, position: Vector2)
signal ui_tooltip_hide()
```

---

## 15. TODO — État d'avancement

> Dernière vérification : 2026-09-07

### Ce qui fonctionne

| Système | État | Fichier clé |
|---------|------|-------------|
| Architecture core (GameData, EventBus, SaveManager) | ✅ Complet | `Autoloads/` |
| Temps (tick, heure, jour, vitesses) | ✅ Complet | `TimeManager.gd` |
| Construction (murs, sols, 50+ objets) | ✅ Complet | `Systems/Construction/` |
| Navigation + animation héros | ✅ Complet | `HeroNavigator.gd`, `HeroAnimator.gd` |
| Besoins héros (5 besoins + moral 3 types) | ✅ Complet | `HeroNeeds.gd` |
| Salaire + démission si impayé / moral trop bas | ✅ Complet | `HeroNeeds.gd` |
| Planning horaire + think tree (5 niveaux) | ✅ Complet | `HeroRoutine.gd`, `HeroActivity.gd` |
| Level up (XP + gain stats) | ✅ Complet | `HeroNeeds.gd` |
| Recrutement (pool, timer, coût) | ✅ Complet | `RecruitManager.gd`, `RecruitPanel.gd` |
| 6 classes de base + 12 avancées (data) | ✅ Complet | `HeroClassRegistry.gd` |
| 99 compétences (6 classes de base) | ✅ Complet | `SkillLibrary.gd` |
| 10 types d'armes, armures légère/moyenne/lourde | ✅ Complet | `EquipmentLibrary.gd` |
| 19 mobs avec stats, drops, attaques | ✅ Complet | `MobLibrary.gd` |
| Matériaux (naturels, craftables, magiques…) | ✅ Complet | `MaterialLibrary.gd` |
| Craft par poste (CraftManager) | ✅ Complet | `CraftManager.gd` |
| Missions (génération + résolution automatique) | ✅ Complet | `MissionManager.gd` |
| Combat jouable (IA héros + mobs, effets de statut) | ✅ Complet | `HeroCombatNode.gd`, `MobNode.gd` |
| Visuels combat (flash hits, nombres, flèche direction) | ✅ Complet | `HeroCombatNode.gd`, `MobNode.gd` |
| Attaque clic gauche (joueur → cible proche souris) | ✅ Complet | `HeroCombatNode.gd` |
| Scènes de mission (génération procédurale Wood1) | ✅ Complet | `wood1_scene.gd` |
| CombatHUD (4 slots héros, skills, log, fin) | ✅ Complet | `CombatHUD.gd`, `HeroCard.gd` |
| UI Équipement (paperdoll + drag&drop) | ✅ Complet | `HeroEquipmentView.gd` |
| Points de compétence (achat + équipement) | ✅ Complet | `HeroSkillsPanel.gd` |
| Potions en combat (auto-heal 30% HP, résurrection) | ✅ Complet | `HeroCombatNode.gd` |
| Enchantements (18 enchants C→S, coût + gating) | ✅ Complet | `EnchantmentPanel.gd`, `EnchantmentLibrary.gd` |
| Marché (achat/vente, filtre, gating recherche) | ✅ Complet | `MarketPanel.gd` |
| Quêtes (tableau lettres + préparation équipe) | ✅ Complet | `QuestPanel.gd`, `QuestPrepPanel.gd` |
| Jardin / Agriculture (8 cultures, croissance par jours) | ✅ Complet | `FarmingManager.gd`, `FarmingPanel.gd` |
| Recettes culinaires (11 plats + 2 fermentés, buffs) | ✅ Complet | `DishLibrary.gd`, `HeroNeeds._try_cook_dish()` |
| Recherche (39 recherches, 10 niveaux) | ✅ Complet | `ResearchManager.gd`, `ResearchPanel.gd` |
| Inventaire guilde (30 slots, drag&drop) | ✅ Complet | `GuildInventoryManager.gd`, `InventoryPanel.gd` |
| Sauvegarde / chargement | ✅ Complet | `SaveManager.gd` |
| Détection des pièces (flood-fill BFS) | ✅ Complet | `RoomManager.gd` |

### Non implémenté / Priorité

| Système | Priorité | Notes |
|---------|----------|-------|
| **Beauté / Température des pièces** | 🔴 Haute | `RoomManager` détecte les pièces mais ne calcule pas la beauté ni la température. Formules dans GDD.md §5. |
| **Compétences classes avancées** (12 classes) | 🔴 Haute | `SkillLibrary` ne couvre que les 6 classes de base. Section "À compléter" dans CONTENT.md. |
| **Factions / Diplomatie** | 🟡 Moyenne | 4 factions définies dans GDD.md §9. Aucun code. Marché actuel = prix fixes. |
| **Fermentation** (bière 3j, hydromel 5j) | 🟡 Moyenne | `FermentationBarrel` placé, logique = stub |
| **Classe avancée / Ascension** | 🟡 Moyenne | Flag `is_advanced_class` dans HeroData, `AscensionAltar` = stub |
| **Événements aléatoires** | 🟢 Basse | 9 positifs + 9 négatifs + 5 à choix définis dans GDD.md §10, aucun code |
| **Aggro / Menace** en combat | 🟢 Basse | Formule définie dans GDD.md §7.7, non implémentée (mobs ciblent le plus proche) |
| **Stats métier — progression par usage** | 🟢 Basse | Formule définie dans GDD.md §2.5, non implémentée |
| Support manette | 🟢 Basse | Non commencé |
| Menu options complet | 🟢 Basse | Audio OK, contrôles + résolution manquants |
| Autres environnements de mission | 🟢 Basse | Seul Wood1 existe |

### Nettoyage technique

| Tâche | Priorité |
|-------|---------|
| Renommer `ItemRegistery.gd` → `ItemRegistry.gd` (typo) | 🔴 Haute |
| Renommer `heroVisual.gd` → `HeroVisual.gd` (PascalCase) | 🟢 Basse |
| Supprimer signaux EventBus jamais consommés (`object_freed`, `object_used`) | 🟢 Basse |
| Ajouter plus d'environnements de mission (donjon, village, caverne…) | 🟡 Moyenne |

---

## 16. Points d'Attention pour Reprendre le Projet

### Bugs connus résolus (ne pas réintroduire)
- `get_parent()` retourne `Window` si un composant reste connecté à un signal global après `queue_free()` → toujours implémenter `_exit_tree()` avec disconnect
- Double déclaration de `_on_navigation_finished` → Godot utilise la première silencieusement
- `SettingsManager` doit être avant `AudioManager` dans les autoloads
- UIDs inventés dans les `.tscn` → ne jamais écrire `uid://xxx_001`, laisser Godot générer
- `HeroUI` doit être `Node2D`, pas `CanvasLayer` (sinon il ne suit pas le héros)
- `_exit_tree()` : écrire `disconnect`, pas `connect`
- `GameData.set_gold(delta)` supprimé — utiliser `add_gold()` ou `spend_gold()`
- `GameData.menu_open` déplacé dans `UIState.menu_open` (SRP)
- Chemins hardcodés vers les nodes → utiliser `WorldContext.objects_container`
- `navigator.nav.target_desired_distance` → utiliser `navigator.set_arrival_distance(x)`
- `is_instance_valid()` obligatoire sur tout node qui peut avoir été `queue_free()`'d
- Assigner une instance `queue_free()`'d à une variable **typée** déclenche l'erreur avant même `is_instance_valid()` → utiliser une variable non typée d'abord, puis caster
- `Color(r,g,b)` en 3 args dans les `.tscn` → Godot exige 4 args `Color(r,g,b,a)`
- Commentaires `##` dans les `.tscn` → cassent le parser de scène Godot, interdit
- `HeroClassRegistry.get_class()` → méthode built-in Godot (0 args), utiliser `get_class_by_id(id)`
- `is_crit ? 14 : 11` → ternaire C-style invalide en GDScript → `14 if is_crit else 11`
- `add_child(camera)` doit précéder `camera.global_position = pos` (node doit être dans l'arbre)

### Règles de code
- Typage explicite TOUJOURS : `var x : int = 0` jamais `var x := 0`
- Lambdas typées : `func(a: Dictionary, b: Dictionary) -> bool: return a["key"] > b["key"]`
- Pas de `class_name` sur les autoloads
- `_exit_tree()` sur tous les composants qui se connectent à EventBus
- Signaux globaux → EventBus, jamais de références directes entre scènes

### Buses audio à créer
`Project > Audio` → ajouter `Music` et `SFX` (output → Master)

---

## 17. Dette Technique & Violations SOLID

### 🔴 Priorité haute

#### [S] HeroActivity — trop de responsabilités
- Combine dispatch des tâches, gestion de `used_object`, navigation, construction adjacente, craft registration
- Extraction possible : `HeroConstructionHandler`, `HeroCraftHandler`

#### [S] ConstructionManager — classe God Object (~450 lignes)
- Validation + affectation + finalisation + sérialisation dans un fichier
- À faire : séparer en `ConstructionValidator` + `ConstructionTaskQueue`

### 🟡 Priorité moyenne

#### [O] Match statements non extensibles pour les tâches
- Ajouter une tâche = modifier `HeroActivity.gd` et `ConstructionInput.gd`
- À faire : `TaskFactory` + interface `ITask.execute(hero)`

#### Atlas coords hardcodés dans ConstructionLayer
- Tous les murs mappés à `Vector2i(0, 0)` — à déplacer dans ItemRegistry

### 🟢 Priorité basse

#### Cache de textures sans limite dans ConstructionPreview
- `_tex_cache` grandit indéfiniment — ajouter un clear au changement de scène

#### Signaux EventBus déclarés mais jamais consommés
- `object_freed`, `object_used` : émis par GuildObject, personne ne les écoute
