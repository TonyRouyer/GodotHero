# Backlog — Suivi d'avancement

> Suivi des tâches par système. `[x]` = fait, `[ ]` = à faire.
> Fichiers associés : [`../readme.md`](../readme.md) | [`bugs.md`](bugs.md) | [`content.md`](content.md)

---

## Table des matières

1. [Systèmes Core](#1-systèmes-core)
2. [Héros & IA](#2-héros--ia)
3. [Construction & Guilde](#3-construction--guilde)
4. [Combat](#4-combat)
5. [Économie & Missions](#5-économie--missions)
6. [UI & Panels](#6-ui--panels)
7. [Contenu (data)](#7-contenu-data)
8. [Technique & Nettoyage](#8-technique--nettoyage)
9. [Non commencé / Futur](#9-non-commencé--futur)

---

## 1. Systèmes Core

- [x] Architecture core (GameData, EventBus, SaveManager)
- [x] Temps in-game (tick, heure, jour, vitesses x1/x2/x4)
- [x] Pause / unpause
- [x] Sauvegarde / chargement (user://save.json)
- [x] Autoloads dans le bon ordre (SettingsManager avant AudioManager)
- [x] SceneManager — navigation sans `change_scene_to_packed()`
- [x] NotificationContainer (CanvasLayer global)
- [x] Traduction (translations.csv, fr/en)
- [x] Audio — buses Music + SFX, crossfade, pool SFX 8 players
- [x] SettingsManager — préférences persistées (user://preferences.json)

---

## 2. Héros & IA

- [x] HeroData — Resource complète (stats, besoins, équipement, planning)
- [x] HeroGenerator — génération procédurale stateless
- [x] Hero.tscn — CharacterBody2D avec 5 composants
- [x] HeroRoutine — think tree 5 niveaux
- [x] HeroActivity — exécution des tâches (navigate, travail, craft, construction)
- [x] HeroNeeds — décrémentation des 5 besoins
- [x] HeroNeeds — moral 3 types (TEMPORARY / CONSTANT / PROGRESSIVE)
- [x] HeroNeeds — salaire journalier + démission si impayé
- [x] HeroNeeds — démission si moral trop bas (P_démission)
- [x] HeroNeeds — level up (XP + gain stats)
- [x] HeroNavigator — wrapper NavigationAgent2D
- [x] HeroAnimator — animation selon direction et activité
- [x] Planning horaire — `HeroData.planning` dict heure→activité
- [x] Recrutement — pool, timer, coût (`Salaire × 5`)
- [x] RecruitManager — pool_changed signal
- [ ] Stats métier — progression par usage (formule GDD §2.4 non implémentée)
- [ ] Classe avancée / Ascension — logique complète (`AscensionAltar` = stub, flag `is_advanced_class` présent)

---

## 3. Construction & Guilde

- [x] ConstructionManager — placement murs, sols, objets
- [x] ConstructionLayer — placeholders ColorRect bleu 50%
- [x] ConstructionInput — saisie joueur
- [x] Grid — grille de placement
- [x] ConstructionPreview — aperçu avant placement
- [x] GuildObject — classe de base data-driven
- [x] ItemRegistry — données items (coût, atlas_id, taille…)
- [x] RoomManager — détection pièces par flood-fill BFS
- [x] NavigationRegion2D — mise à jour après construction
- [x] 50+ objets placables
- [ ] Beauté des pièces — `Beauté_pièce = Σ(meubles) + Σ(sol × cases) + mur × périmètre` (GDD §5.1)
- [ ] Température des pièces — `T = T_biome + Σ(modificateurs)` (GDD §5.2)
- [ ] Atlas coords hardcodés dans ConstructionLayer → déplacer dans ItemRegistry

---

## 4. Combat

- [x] HeroCombatNode — héros jouable ou IA (CharacterBody2D)
- [x] MobNode — IA simple (approche, attaque, anti-overlap)
- [x] CombatHUD — 4 slots HeroCard, skills, log, EndPanel
- [x] HeroCard — barre HP, portrait
- [x] Visuels combat — flash hits, nombres flottants, flèche direction joueur
- [x] Attaque clic gauche — cible la plus proche du curseur
- [x] Compétences en combat — 4 slots équipés, cooldowns
- [x] Potions auto — auto-heal 30% HP, résurrection
- [x] Effets de statut (brûlure, poison, stun, saignement, silence, peur, ralentissement, constriction)
- [x] MissionScene — génération procédurale Wood1
- [x] Environnement Wood1 — forêt générée procéduralement
- [ ] Système aggro / menace — `F_menace = (D×0.3) + (Soin×0.3) + (Proximité×0.4) + (Santé×0.1) + Taunt` (GDD §7.9)
- [ ] Autres environnements de mission — donjon, village, caverne, etc.

---

## 5. Économie & Missions

- [x] MissionManager — 13 templates de missions (F→S)
- [x] Génération missions selon réputation
- [x] Résolution missions — `P = (HP_finale_moy / HP_init_moy) × Ratio_objectifs`
- [x] Effets moraux automatiques mission (succès +10, échec −10)
- [x] Mise à jour rang héros (`missions_last_20` + `_recalculate_rank()`)
- [x] QuestPanel — tableau des lettres de quête
- [x] QuestPrepPanel — préparation équipe
- [x] MarketPanel — achat/vente avec filtre et gating recherche
- [x] GuildInventoryManager — 30 slots, drag&drop
- [x] FarmingManager — 8 cultures, croissance par jours
- [x] FarmingPanel — interface jardin
- [x] ResearchManager — 39 recherches sur 10 niveaux
- [x] ResearchPanel — interface de recherche
- [x] CraftManager — files de craft par poste, progression par tick
- [ ] Factions / Diplomatie — 4 factions définies, aucun code (GDD §9)
- [ ] Fermentation — bière 3j, hydromel 5j (`FermentationBarrel` = stub)
- [ ] Événements aléatoires — 9 positifs + 9 négatifs + 5 à choix (GDD §12, aucun code)
- [ ] Recyclage 50% (recherche Recyclage avancé)
- [ ] Recyclage 100% (recherche Recyclage Intégral)

---

## 6. UI & Panels

- [x] HeroPanel — 3 onglets (Liste, Planning, Recruter)
- [x] HeroListRow — rang, nom, classe, niveau, HP, moral, focus, renvoyer
- [x] PlanningRow — 24 ColorRect + préréglages (Journée/Nuit/Entraînement/Congé)
- [x] RecruitRow — rang, nom, classe, niveau, coût, bouton recruter
- [x] HeroEquipmentView — paperdoll + drag&drop
- [x] HeroSkillsPanel — achat et équipement de compétences
- [x] EnchantmentPanel — application d'enchantements
- [x] BuildMenu — menu construction
- [x] CombatHUD — CanvasLayer layer=10
- [x] guild_hud — HUD principal guilde
- [x] GuildCamera — zoom, pan ZQSD, focus, sauvegarde position
- [x] PauseMenu
- [x] Notifications — 4 types (success, error, warning, info), max 3 simultanées
- [ ] Menu options complet — audio OK, contrôles + résolution manquants
- [ ] Support manette

---

## 7. Contenu (data)

- [x] 2/2 classes de base dans `HeroClassRegistry` (Guerrier, Mage)
- [ ] 0 classes avancées dans `HeroClassRegistry`
- [ ] 0 compétences dans `SkillLibrary`
- [ ] 0 traits dans `TraitLibrary`
- [x] 1/1 mob dans `MobLibrary` (Slime)
- [x] 1/1 arme dans `EquipmentLibrary` (Épée Rouillée)
- [ ] 0 armures dans `EquipmentLibrary`
- [ ] 0 accessoires dans `EquipmentLibrary`
- [ ] 0 consommables dans `EquipmentLibrary`
- [ ] 0 enchantements dans `EnchantmentLibrary`
- [x] 1/1 matériau dans `MaterialLibrary` (Bois)
- [ ] 0 plats dans `DishLibrary`
- [ ] 0 fermentés dans `DishLibrary`
- [ ] 0 cultures dans `CropLibrary`
- [x] 39/39 recherches dans `ResearchLibrary`
- [x] 50+/50+ objets de construction dans `ItemRegistry`

---

## 8. Technique & Nettoyage

- [ ] Renommer `ItemRegistery.gd` → `ItemRegistry.gd` (typo) — PRIORITE HAUTE
- [ ] Renommer `heroVisual.gd` → `HeroVisual.gd` (PascalCase)
- [ ] Supprimer signaux EventBus jamais consommés (`object_freed`, `object_used`)
- [ ] Refactorer `HeroActivity` — trop de responsabilités (SRP) : extraire `HeroConstructionHandler`, `HeroCraftHandler`
- [ ] Refactorer `ConstructionManager` — God Object ~450 lignes : extraire `ConstructionValidator` + `ConstructionTaskQueue`
- [ ] Remplacer match statements tâches par `TaskFactory` + interface `ITask.execute(hero)` (OCP)
- [ ] Déplacer atlas coords hardcodés de ConstructionLayer vers ItemRegistry
- [ ] Ajouter limite au cache `_tex_cache` de ConstructionPreview (clear au changement de scène)

---

## 9. Non commencé / Futur

- [ ] Beauté / température des pièces — impact moral et besoins (GDD §5)
- [ ] Compétences des 12 classes avancées
- [ ] Système factions / diplomatie — relations −100 à +100, prix ajustés (GDD §9)
- [ ] Événements aléatoires — déclenchement toutes les 5–10 jours in-game (GDD §12)
- [ ] Fermentation bière / hydromel (logique complète, pas juste le stub)
- [ ] Système aggro / menace en combat (GDD §7.9)
- [ ] Classe avancée / Ascension — logique complète dans AscensionAltar
- [ ] Autres environnements de mission — donjon, village, caverne
- [ ] Support manette
- [ ] Menu options complet — contrôles remappables, résolution, mode fenêtre
- [ ] Stats métier — progression par usage (GDD §2.4)
- [ ] Recyclage avancé 50% et 100%
