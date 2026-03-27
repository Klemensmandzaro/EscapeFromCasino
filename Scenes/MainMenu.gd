extends Control


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_graj_pressed() -> void:
	GameManager.resume_timer()
	if GameManager.is_first_time_playing:
		get_tree().change_scene_to_file("res://Scenes/ClassSelection.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/Minigames/DiceGame.tscn")


func _on_klasy_postaci_pressed():
	get_tree().change_scene_to_file("res://Scenes/ClassSelection.tscn")


func _on_sklep_pressed():
	get_tree().change_scene_to_file("res://Scenes/ShopSelection.tscn")


func _on_new_game_button_pressed():
	GameManager.hard_reset()
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://Scenes/ClassSelection.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
