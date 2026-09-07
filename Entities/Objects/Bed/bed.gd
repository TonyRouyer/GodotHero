## bed.gd
## Lit — sous-classe fine de GuildObject pour la logique visuelle unique du lit.
##
## Cette sous-classe gère uniquement :
##   • Le label "💤" (SleepingLabel) affiché pendant le sommeil
##   • L'intercalage du héros entre les deux couches du lit (z_index absolu)
##   • Le flag is_ground_sleeping
extends GuildObject

## Z-index du héros pendant le sommeil (entre SpriteBottom z=0 et SpriteTop z=2)
const Z_HERO : int = 1

@onready var sleeping_label : Label = $SleepingLabel


# ─────────────────────────────────────────────
#  USE / EXIT
# ─────────────────────────────────────────────

## En plus du comportement hérité (position + freeze + tick), le lit :
##   • marque le héros comme dormant dans un lit (pas au sol)
##   • affiche le label "💤"
##   • intercale le héros visuellement entre les deux couches du lit
func use(hero: Node) -> void:
	super(hero)
	if hero.activity:
		hero.activity.is_ground_sleeping = false
	sleeping_label.visible = true
	## z_as_relative = false → z_index est absolu, indépendant du parent
	hero.z_index       = Z_HERO
	hero.z_as_relative = false


## En plus du comportement hérité (unfreeze), restore le z relatif du héros.
func exit(hero: Node) -> void:
	super(hero)
	hero.z_as_relative = true


# ─────────────────────────────────────────────
#  NETTOYAGE VISUEL
# ─────────────────────────────────────────────

## Masque le label "💤" quand le héros quitte le lit.
## Appelé automatiquement par GuildObject.exit() → clear_state().
func clear_state() -> void:
	sleeping_label.visible = false
