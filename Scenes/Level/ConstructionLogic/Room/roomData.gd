class_name RoomData
extends Resource

# Utilisé par GameData.ROOM_TYPES

@export var name: String
@export var min_size: Vector2i = Vector2i.ZERO
@export var required_objects: Array[String] = []
