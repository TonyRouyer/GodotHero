# Bugs & Dette Technique

> Référence pour ne pas réintroduire des bugs résolus et prioriser le refactoring.
> Fichiers associés : [`../readme.md`](../readme.md) | [`backlog.md`](backlog.md)

---

## Table des matières

1. [Bugs résolus (ne pas réintroduire)](#1-bugs-résolus-ne-pas-réintroduire)
2. [Dette technique — Priorité haute](#2-dette-technique--priorité-haute)
3. [Dette technique — Priorité moyenne](#3-dette-technique--priorité-moyenne)
4. [Dette technique — Priorité basse](#4-dette-technique--priorité-basse)
5. [Règles de code (rappels)](#5-règles-de-code-rappels)

---

## 1. Bugs résolus (ne pas réintroduire)

- `get_parent()` retourne `Window` si un composant reste connecté à un signal global après `queue_free()` → toujours implémenter `_exit_tree()` avec disconnect

- Double déclaration de `_on_navigation_finished` → Godot utilise la première silencieusement

- `SettingsManager` doit être avant `AudioManager` dans les autoloads (sinon `apply_audio()` ne fonctionne pas au démarrage)

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

- Buses audio manquantes → créer `Music` et `SFX` dans `Project > Audio` (output → Master)

---

## 2. Dette technique — Priorité haute

### [S] HeroActivity — trop de responsabilités (violation SRP)

- Combine dispatch des tâches, gestion de `used_object`, navigation, construction adjacente, craft registration
- Ajouter une tâche = modifier `HeroActivity.gd`
- **Action** : extraire `HeroConstructionHandler` et `HeroCraftHandler`

### [S] ConstructionManager — God Object (~450 lignes)

- Validation + affectation + finalisation + sérialisation dans un seul fichier
- **Action** : séparer en `ConstructionValidator` + `ConstructionTaskQueue`

### Typo critique : `ItemRegistery.gd` → `ItemRegistry.gd`

- Le fichier est mal nommé dans tout le projet
- **Action** : renommer le fichier et corriger toutes les références

---

## 3. Dette technique — Priorité moyenne

### [O] Match statements non extensibles pour les tâches (violation OCP)

- Ajouter une tâche = modifier `HeroActivity.gd` ET `ConstructionInput.gd`
- **Action** : implémenter `TaskFactory` + interface `ITask.execute(hero)`

### Atlas coords hardcodés dans ConstructionLayer

- Tous les murs mappés à `Vector2i(0, 0)` en dur
- **Action** : déplacer les coordonnées dans `ItemRegistry`

### Ajouter plus d'environnements de mission

- Seul `Wood1` (forêt) existe
- **Action** : créer au moins donjon, village, caverne

---

## 4. Dette technique — Priorité basse

### Cache de textures sans limite dans ConstructionPreview

- `_tex_cache` grandit indéfiniment pendant la session
- **Action** : ajouter un clear au changement de scène

### Signaux EventBus déclarés mais jamais consommés

- `object_freed`, `object_used` : émis par `GuildObject`, personne ne les écoute
- **Action** : supprimer ou câbler ces signaux

### Nommage incohérent : `heroVisual.gd`

- Devrait être `HeroVisual.gd` (PascalCase, convention GDScript)
- **Action** : renommer

---

## 5. Règles de code (rappels)

Ces règles s'appliquent à TOUT le code du projet.

- **Typage explicite TOUJOURS** : `var x : int = 0`, jamais `var x := 0`
- **Lambdas typées** : `func(a: Dictionary, b: Dictionary) -> bool: return a["key"] > b["key"]`
- **Pas de `class_name`** sur les autoloads
- **`_exit_tree()`** sur tous les composants qui se connectent à EventBus (disconnect les signaux)
- **Signaux globaux → EventBus**, jamais de références directes entre scènes
- **`is_instance_valid()`** obligatoire sur tout node susceptible d'avoir été `queue_free()`'d
- **Pas de ternaire C-style** : `x if condition else y`, pas `condition ? x : y`
- **`Color` dans les .tscn** : toujours 4 arguments `Color(r,g,b,a)`
- **Pas de `##` dans les .tscn** : commentaires interdits dans les fichiers de scène Godot
- **Méthode built-in `get_class()`** : utiliser `get_class_by_id(id)` pour la registry
- **Respect SOLID** : voir §2–4 pour les violations identifiées
