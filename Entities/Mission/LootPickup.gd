## LootPickup.gd
## Objet ramassable généré par wood1_scene._place_loot().
## Auto-collecté quand un HeroCombatNode entre dans sa zone.
class_name LootPickup
extends Area2D

signal collected(item_id, quantity)

var item_id  : String = ""
var quantity : int    = 1


func setup(p_item_id: String, p_quantity: int = 1) -> void:
	item_id  = p_item_id
	quantity = p_quantity

	collision_layer = 8  # layer 4
	collision_mask  = 2  # layer 2 (héros)

	var col_shape := CollisionShape2D.new()
	var circle    := CircleShape2D.new()
	circle.radius = 10.0
	col_shape.shape = circle
	add_child(col_shape)

	## Visuel : carré jaune + étoile
	var bg := ColorRect.new()
	bg.color    = Color(0.85, 0.70, 0.10, 0.90)
	bg.size     = Vector2(12, 12)
	bg.position = Vector2(-6, -6)
	add_child(bg)

	var lbl := Label.new()
	lbl.text     = "★"
	lbl.position = Vector2(-6, -18)
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	add_child(lbl)

	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("is_dead") and not body.is_dead():
		GuildInventoryManager.add_item(item_id, quantity)
		collected.emit(item_id, quantity)
		queue_free()
