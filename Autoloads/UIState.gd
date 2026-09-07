## UIState.gd — Autoload
## État global de l'interface utilisateur.
## Séparé de GameData (SRP) : GameData gère les données de jeu, UIState gère l'UI.
extends Node

var menu_open     : bool   = false
var current_panel : String = ""
