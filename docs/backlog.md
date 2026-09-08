# Backlog — Suivi d'avancement

> Suivi des tâches par système. `[x]` = fait, `[ ]` = à faire.
> Fichiers associés : [`../readme.md`](../readme.md) | [`bugs.md`](bugs.md) | [`content.md`](content.md)

---

## Table des matières

1. [Fondations techniques](#1-fondations-techniques)
2. [Héros & IA](#2-héros--ia)
3. [Construction & Guilde](#3-construction--guilde)
4. [Recherches & Déblocages](#4-recherches--déblocages)
5. [Économie & Craft](#5-économie--craft)
6. [Missions & Combat](#6-missions--combat)
7. [Progression des héros](#7-progression-des-héros)
8. [Systèmes secondaires](#8-systèmes-secondaires)
9. [Systèmes avancés](#9-systèmes-avancés)
10. [Contenu (data)](#10-contenu-data)
11. [UI & Options](#11-ui--options)
12. [Technique & Nettoyage](#12-technique--nettoyage)

---

## 1. Fondations techniques

- [x] Architecture core (GameData, EventBus, SaveManager)
- [x] Temps in-game (tick, heure, jour, vitesses x1/x2/x4)
- [x] Pause / unpause
- [x] Sauvegarde / chargement (user://save.json)
- [x] Autoloads ordonnés et architecturés (`Autoloads/Registry/`, `Manager/`, `Generator/`)
- [x] SceneManager — navigation sans `change_scene_to_packed()`
- [x] NotificationContainer — 4 types (success, error, warning, info), max 3 simultanées
- [x] Traduction (translations.csv, fr/en)
- [x] Audio — buses Music + SFX, crossfade, pool SFX 8 players
- [x] SettingsManager — préférences persistées (user://preferences.json)

---

## 2. Héros & IA

- [x] HeroData — Resource complète (stats, besoins, équipement, planning)
- [x] HeroGenerator — génération procédurale stateless
- [x] Hero.tscn — CharacterBody2D avec composants (Routine, Activity, Needs, Navigator, Animator)
- [x] HeroRoutine — think tree 5 niveaux de priorité
- [x] HeroActivity — exécution des tâches (navigate, travail, craft, construction)
- [x] HeroNeeds — décrémentation des 5 besoins (faim, énergie, hygiène, moral, vessie)
- [x] HeroNeeds — moral 3 types (TEMPORARY / CONSTANT / PROGRESSIVE)
- [x] HeroNeeds — salaire journalier + démission si impayé
- [x] HeroNeeds — démission si moral trop bas (P_démission)
- [x] HeroNeeds — level up (XP + gain stats)
- [x] HeroNavigator — wrapper NavigationAgent2D
- [x] HeroAnimator — animation selon direction et activité
- [x] Planning horaire — `HeroData.planning` dict heure→activité
- [x] Recrutement — pool, timer, coût (`Salaire × 5`), RecruitManager signal
- [ ] Traits — application effective des effets en jeu (TraitLibrary vide, HeroNeeds appelle des traits inexistants)
- [ ] Stats métier — progression par usage (formule GDD §2.4)
- [ ] Classe avancée / Ascension — logique complète (`AscensionAltar` = stub)

---

## 3. Construction & Guilde

- [x] ConstructionManager — placement murs, sols, objets
- [x] ConstructionLayer — rendu des objets placés
- [x] ConstructionInput — saisie joueur (placement, suppression)
- [x] ConstructionPreview — aperçu avant placement
- [x] Grid — grille de placement
- [x] GuildObject — classe de base data-driven
- [x] ItemRegistry — structure et accesseurs (stubs par salle prêts)
- [x] RoomManager — détection pièces par flood-fill BFS
- [x] NavigationRegion2D — mise à jour après construction
- [x] GuildCamera — zoom, pan ZQSD, focus, sauvegarde position
- [ ] 0/57 objets placables dans `ItemRegistry`
- [ ] Beauté des pièces — `Beauté_pièce = Σ(meubles) + Σ(sol × cases) + mur × périmètre` (GDD §5.1)
- [ ] Température des pièces — `T = T_biome + Σ(modificateurs)` (GDD §5.2)
- [ ] Beauté / température — impact effectif sur moral et besoins des héros

---

## 4. Recherches & Déblocages

- [x] ResearchManager — logique complète (progression, prérequis, coût en or)
- [x] ResearchPanel — interface arbre de recherche
- [ ] 0/39 recherches dans `ResearchLibrary` (stubs par niveau 1→10 prêts)
- [ ] Gating objets construisibles par recherche (lien `ItemRegistry.unlock_research` → `ResearchManager.is_unlocked()`)
- [ ] Gating équipements / recettes par recherche dans `MarketPanel` et `CraftManager`

---

## 5. Économie & Craft

- [x] GuildInventoryManager — 30 slots, drag&drop
- [x] MarketPanel — achat/vente avec filtre et gating recherche
- [x] CraftManager — files de craft par poste, progression par tick
- [ ] 1/33 matériaux dans `MaterialLibrary` — recettes craft non fonctionnelles sans contenu
- [ ] Recyclage 25% — logique dans `CraftManager` ou `ConstructionManager` (recherche Recyclage primaire)
- [ ] Recyclage 50% — recherche Recyclage avancé
- [ ] Recyclage 100% — recherche Recyclage Intégral

---

## 6. Missions & Combat

- [x] MissionManager — 13 templates de missions (F→S)
- [x] Génération missions selon réputation guilde
- [x] Résolution missions — `P = (HP_finale_moy / HP_init_moy) × Ratio_objectifs`
- [x] Effets moraux automatiques mission (succès +10, échec −10)
- [x] Mise à jour rang héros (`missions_last_20` + `_recalculate_rank()`)
- [x] QuestPanel — tableau des lettres de quête
- [x] QuestPrepPanel — préparation équipe avant mission
- [x] HeroCombatNode — héros jouable ou IA (CharacterBody2D)
- [x] MobNode — IA simple (approche, attaque, anti-overlap)
- [x] CombatHUD — 4 slots HeroCard, skills, log, EndPanel
- [x] Visuels combat — flash hits, nombres flottants, flèche direction joueur
- [x] Attaque clic gauche — cible la plus proche du curseur
- [x] Effets de statut (brûlure, poison, stun, saignement, silence, peur, ralentissement, constriction)
- [x] Potions auto — auto-heal 30% HP, résurrection
- [x] MissionScene + Environnement Wood1 — forêt générée procéduralement
- [ ] 1/19 mobs dans `MobLibrary` — seul le Slime génère en mission
- [ ] Intégration drops mobs → `GuildInventoryManager` (loot de fin de mission)
- [ ] Compétences en combat — effets réels (`SkillLibrary` vide, slots équipés mais sans effet)
- [ ] Équipements — bonus stats appliqués en combat (`EquipmentLibrary` quasi vide)
- [ ] Système aggro / menace — `F_menace = (D×0.3) + (Soin×0.3) + (Proximité×0.4) + (Santé×0.1) + Taunt` (GDD §7.9)
- [ ] Autres environnements de mission — donjon, village, caverne, etc.

---

## 7. Progression des héros

- [ ] 4/6 classes de base manquantes (Roublard, Chasseur, Guérisseur, Invocateur)
- [ ] 0/12 classes avancées dans `HeroClassRegistry`
- [ ] Ascension — logique complète : vérification prérequis, transformation HeroData, nouvelles stats

---

## 8. Systèmes secondaires

- [x] FarmingManager — logique croissance cultures par jours in-game
- [x] FarmingPanel — interface jardin
- [ ] 0/8 cultures dans `CropLibrary` — FarmingManager opérationnel mais sans données
- [ ] Fermentation — logique brassage bière (3j) / hydromel (5j) dans `FermentationBarrel`
- [ ] Cuisine — logique cuisson au fourneau (héros affecté → consomme ingrédients → produit plat)
- [ ] Plats consommés — application buff temporaire + satiété dans `HeroNeeds`

---

## 9. Systèmes avancés

- [ ] Factions / Diplomatie — 4 factions, relations −100→+100, prix marché ajustés (GDD §9)
- [ ] Événements aléatoires — 9 positifs + 9 négatifs + 5 à choix, déclenchement toutes les 5–10 jours (GDD §12)
- [ ] Beauté / température — calcul et impact effectif moral + besoins (GDD §5)

---

## 10. Contenu (data)

> Stubs prêts dans tous les registries — voir `content.md` pour le détail complet.

### Recherches & Objets
- [ ] 0/39 recherches dans `ResearchLibrary` (stubs niveaux 1→10 prêts)
- [ ] 0/57 objets de construction dans `ItemRegistry` (stubs 16 salles prêts)

### Héros
- [ ] Classes de base — 2/6 : Guerrier ✓, Mage ✓ · Roublard, Chasseur, Guérisseur, Invocateur à faire
- [ ] 0/12 classes avancées dans `HeroClassRegistry`
- [ ] 0/99 compétences dans `SkillLibrary`
- [ ] 0/42 traits dans `TraitLibrary`

### Combat
- [ ] Mobs — 1/19 : Slime ✓ · 18 restants dans `MobLibrary`

### Équipement
- [ ] Armes — 1/44 : Épée Rouillée ✓ · 43 restantes dans `EquipmentLibrary`
- [ ] 0/32 armures dans `EquipmentLibrary`
- [ ] 0/10 accessoires dans `EquipmentLibrary`
- [ ] 0/19 consommables dans `EquipmentLibrary`
- [ ] 0/18 enchantements dans `EnchantmentLibrary`

### Ressources & Cuisine
- [ ] Matériaux — 1/33 : Bois ✓ · 32 restants dans `MaterialLibrary`
- [ ] 0/11 plats dans `DishLibrary`
- [ ] 0/2 fermentés dans `DishLibrary`
- [ ] 0/8 cultures dans `CropLibrary`

---

## 11. UI & Options

- [x] HeroPanel — 3 onglets (Liste, Planning, Recruter)
- [x] HeroEquipmentView — paperdoll + drag&drop
- [x] HeroSkillsPanel — achat et équipement de compétences (contenu vide)
- [x] EnchantmentPanel — application d'enchantements (contenu vide)
- [x] BuildMenu — menu construction
- [x] CombatHUD — CanvasLayer layer=10
- [x] guild_hud — HUD principal guilde
- [x] PauseMenu
- [ ] CraftPanel — interface craft (liste recettes, file d'attente, progression)
- [ ] HeroInspectPanel — fiche détaillée héros (traits, stats complètes, historique missions)
- [ ] Menu options complet — contrôles remappables + résolution + mode fenêtre (audio OK)
- [ ] Support manette

---

## 12. Technique & Nettoyage

- [x] Renommer `ItemRegistery.gd` → `ItemRegistry.gd` (typo)
- [x] Déplacer `ResearchLibrary` → `Autoloads/Registry/`
- [x] Supprimer fichiers Resource orphelins (`Ressources/Items/`, `Recipes/`, `Objects/`)
- [ ] Renommer `heroVisual.gd` → `HeroVisual.gd` (PascalCase)
- [ ] Supprimer signaux EventBus jamais consommés (`object_freed`, `object_used`)
- [ ] Ajouter limite au cache `_tex_cache` de ConstructionPreview (clear au changement de scène)
- [ ] Déplacer atlas coords hardcodés de ConstructionLayer vers `ItemRegistry`
- [ ] Refactorer `HeroActivity` — extraire `HeroConstructionHandler`, `HeroCraftHandler` (SRP)
- [ ] Refactorer `ConstructionManager` — extraire `ConstructionValidator` + `ConstructionTaskQueue` (~450 lignes)
- [ ] Remplacer match statements tâches par `TaskFactory` + interface `ITask.execute(hero)` (OCP)
