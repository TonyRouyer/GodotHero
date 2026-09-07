## ResearchData.gd
## Données statiques d'une recherche.
extends Resource
class_name ResearchData

@export var id            : String        = ""
@export var label         : String        = ""
@export var description   : String        = ""
@export var unlocks       : String        = ""   ## Texte libre décrivant les déblocages
@export var cost          : int           = 0    ## Coût en or
@export var level         : int           = 1    ## Niveau 1–10
@export var prerequisites : Array[String] = []   ## IDs des prérequis
@export var icon_path     : String        = ""   ## Chemin vers l'icône (peut être vide)
