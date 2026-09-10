# CLAUDE.md — Contexte de session pour Claude Code

> Ce fichier est chargé automatiquement à chaque nouvelle session Claude Code.
> Il permet de reprendre le développement sans perdre le contexte, même sur un autre PC.
> **Source de vérité** : `readme.md` (architecture) + `docs/content.md` (contenu du jeu).

---

## Projet

**Godot 4.4 — GDScript — Pixel art 16-bit top-down**
Jeu de gestion de guilde d'aventuriers (inspiré Dwarf Fortress / Guild of Dungeoneering).
Monde : Astralia. Rangs : F → E → D → C → B → A → S.

**Boucle principale** : Construire guilde → Recruter héros → Planifier journées → Missions → Ressources → Recommencer.

---

## Règles de code ABSOLUES

- Typage explicite TOUJOURS : `var x : int = 0` — **jamais** `var x := 0`
- Sur les Dictionary non typés, toujours forcer le type : `var d : Dictionary = my_array[i]`
- Pas de `class_name` sur les autoloads
- `_exit_tree()` sur tous les composants connectés à EventBus
- Signaux globaux → EventBus uniquement
- `is_instance_valid()` obligatoire sur tout node pouvant être `queue_free()`'d
- Signal `.bind(i)` : les args bound arrivent **après** les args du signal (pas avant)
- Principes SOLID

---

## Architecture rapide

```
Autoloads/
  GameConfig.gd       ← Constantes globales
  EventBus.gd         ← Bus de signaux global
  GameData.gd         ← État runtime (or, réputation…)
  UIState.gd          ← État UI (séparé GameData)
  WorldContext.gd     ← Refs conteneurs scène active
  TimeManager.gd      ← Tick=5min, heure, jour, vitesses ×1/×2/×4
  Registry/
    HeroClassRegistry.gd   ← 6 classes base + 12 avancées
    EquipmentLibrary.gd    ← Armes, armures, accessoires, consommables
    MaterialLibrary.gd     ← Ressources et matériaux
    MobLibrary.gd          ← 19 mobs avec stats/drops/attaques
    SkillLibrary.gd        ← Compétences par classe (stubs à remplir)
    EnchantmentLibrary.gd  ← 18 enchantements C→S
    CropLibrary.gd         ← 8 cultures
    DishLibrary.gd         ← 11 plats avec buffs
  Manager/
    ConstructionManager.gd
    CraftManager.gd
    GuildInventoryManager.gd
    HeroManager.gd
    MissionManager.gd
    RecruitManager.gd
    ResearchManager.gd    ← 39 recherches, 10 niveaux
    RoomManager.gd        ← Flood-fill détection pièces
    FarmingManager.gd

Scenes/
  Tests/
    test_combat.tscn + test_combat.gd   ← Arène de test combat avec config héros
  Heroes/HeroLogique/
    HeroCombatNode.gd   ← Combat joueur (4 skills, passives, potions auto)
    MobNode.gd          ← FSM IDLE/CHASE/ATTACK/DEAD
```

---

## Systèmes implémentés ✅

- Architecture core complète (GameData, EventBus, UIState, WorldContext, SaveManager, SceneManager)
- Temps in-game (tick, heure, jour, vitesses)
- Construction (murs, sols, 50+ objets, placeholder bleu, task héros)
- Navigation + animation héros (HeroNavigator, HeroAnimator)
- Besoins héros (5 besoins + moral TEMPORARY/CONSTANT/PROGRESSIVE)
- Salaire + démission (traits intégrés)
- Planning horaire (grille 24h) + think tree 5 niveaux
- Level up (XP → stats aléatoires + 15 pts compétence)
- Recrutement (pool, timer, coût = salaire×5)
- Craft par poste (CraftManager)
- Missions résolution auto + jouable (13 templates)
- **Combat jouable** : MobNode.gd + HeroCombatNode.gd
- **Scène mission bois** : wood1_scene.gd (génération procédurale)
- **UI Équipement** : paperdoll 3×3, drag&drop, vérif compatibilité classe
- **Points de compétence** : achat + 4 slots équipés
- **Enchantements** : EnchantmentPanel + EnchantmentLibrary (18 enchants C→S)
- **Marché** : achat/vente, filtres, gating recherche
- **Quêtes** : QuestPanel + QuestPrepPanel (4 héros, toggle AI/Joueur)
- **Agriculture** : FarmingManager + CropLibrary (8 cultures) + FarmingPanel
- **Cuisine** : DishLibrary (11 plats) intégrés dans HeroNeeds
- **CombatHUD** : barres HP/mana, log, compétences avec cooldowns visuels
- **Recherches** : 39 recherches, 10 niveaux
- **Inventaire guilde** : 30 slots, drag&drop
- **Save/Load** : JSON complet
- **RoomManager** : BFS flood-fill, O(1) lookup
- **Test combat** : `Scenes/Tests/test_combat.tscn` — arène 1 héros vs 3 slimes avec panneau de config (classe, niveau, stats, équipement, compétences), caméra qui suit le héros

---

## Non implémenté ❌ (priorité haute)

- Beauté / Température des pièces (RoomManager détecte pièces mais pas calcul)
- Compétences classes avancées (12 classes) — SkillLibrary = stubs
- Factions / Diplomatie
- Fermentation (barrel placé, logique = stub)
- Ascension / Classe avancée (flag dans HeroData, AscensionAltar = stub)
- Autres environnements de mission (seul Wood1 existe)

---

## Contenu du jeu — vue d'ensemble

Fichier détaillé : `docs/content.md` (mise à jour 2026-09-10, données réelles du GDD).

| Catégorie | Total | Implémentés |
|-----------|-------|-------------|
| Classes de base | 6 | 2 (Guerrier, Mage) |
| Classes avancées | 12 | 0 |
| Compétences | 99 | 0 (stubs) |
| Mobs | 19 | 1 (Slime) |
| Armes | ~42 | 2 (Épée d'entraînement, Épée du soldat) |
| Armures | ~30 | 0 |
| Accessoires | 10 | 0 |
| Potions | 16 | 0 |
| Enchantements | 18 | 0 |
| Matériaux | ~50 | 1 (Bois) |
| Plats | 11 + 2 fermentés | 0 |
| Cultures | 8 | 0 |
| Recherches | 39 | 39 ✅ |
| Constructions | ~50 | ~15 |

---

## Registres clés — ce qui est déclaré dans EquipmentLibrary

- `epee_entrainement` (F, atk 3, recette: bois×2, 5 or) — **implémenté**
- `epee_rouille` (F, atk 5, recette: minerai×2, 15 or) — **implémenté** (nommé "Épée Rouillée" mais le GDD l'appelle "Épée du Soldat")

---

## Test combat — fonctionnement

`Scenes/Tests/test_combat.tscn` → `test_combat.gd`

1. Panneau de config (CanvasLayer) s'affiche au démarrage
2. Choisir classe, niveau, stats, équipement, compétences
3. Clic "Lancer le combat" → spawn héros + 3 slimes
4. Caméra = Camera2D enfant direct de `_hero_node` (suit automatiquement)
5. Inputs : `camera_move_*` pour déplacer le héros

**Bug corrigé** : `.bind(i)` place l'arg bound EN DERNIER → signatures :
```gdscript
func _on_mob_hp_changed(_node: Node, hp: float, hp_max: float, i: int)
func _on_mob_died(_node: Node, i: int)
```

---

## Dette technique (ne pas aggraver)

- `HeroActivity.gd` : trop de responsabilités → extraire HeroConstructionHandler, HeroCraftHandler
- `ConstructionManager.gd` ~450 lignes → séparer Validator + TaskQueue
- `ItemRegistery.gd` → typo à corriger en `ItemRegistry.gd`
- `heroVisual.gd` → renommer en `HeroVisual.gd` (PascalCase)

---

## Conventions de nommage

- Fichiers/classes : PascalCase (`HeroData.gd`)
- Variables/fonctions : snake_case
- Constantes : UPPER_SNAKE_CASE
- Signaux : snake_case (`hp_changed`)
- IDs items : snake_case (`epee_entrainement`)

---

## Pour continuer le dev

1. Lire `readme.md` (architecture complète)
2. Lire `docs/content.md` (contenu du jeu avec checkboxes)
3. Lire `docs/backlog.md` (priorités)
4. Lire `docs/bugs.md` (ne pas réintroduire)
