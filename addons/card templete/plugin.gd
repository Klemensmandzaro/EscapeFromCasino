@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("Flippable Card", "Sprite2D", preload("flippable_card.gd"), preload("icon.png"))

func _exit_tree() -> void:
	remove_custom_type("Flippable Card")
