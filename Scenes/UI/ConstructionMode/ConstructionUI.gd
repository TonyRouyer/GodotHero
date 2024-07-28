extends Control
signal constructSignal
signal mouseInMenu
signal mouseOutMenu
var panel_open = false


func _on_wall_btn_pressed():
	global.construction_type = "wall"
	print("Construction mode:", global.construction_mode)
	emit_signal("constructSignal")

func _on_floor_btn_pressed():
	#global.construction_mode = true
	global.construction_type = "floor"
	print("Construction mode:", global.construction_mode)
	emit_signal("constructSignal")

func _on_door_btn_pressed():
	#global.construction_mode = true
	global.construction_type = "door"
	print("Construction mode:", global.construction_mode)
	emit_signal("constructSignal")


func _on_area_2d_mouse_entered():
	emit_signal("mouseInMenu")

func _on_area_2d_mouse_exited():
	emit_signal("mouseOutMenu")

func _on_construction_btn_pressed():
	global.construction_mode = !global.construction_mode
	#global.move_camera = !global.move_camera
	if panel_open:
		$TextureRect/constructionItemPanel.visible = false
		panel_open = false
	else:
		$TextureRect/constructionItemPanel.visible = true
		panel_open = true

