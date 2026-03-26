extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_graj_pressed() -> void:
	GameManager.resume_timer()
	if GameManager.is_first_time_playing:
		# Jeśli to absolutnie pierwszy raz, najpierw wybierz klasę!
		get_tree().change_scene_to_file("res://Scenes/ClassSelection.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/Minigames/DiceGame.tscn")


func _on_klasy_postaci_pressed():
	# Zmieniamy scenę na nasz nowy ekran wyboru klas!
	get_tree().change_scene_to_file("res://Scenes/ClassSelection.tscn")


func _on_sklep_pressed(): # Zmień na nazwę Twojej funkcji
	get_tree().change_scene_to_file("res://Scenes/ShopSelection.tscn")


func _on_new_game_button_pressed(): # Upewnij się, że nazwa pasuje do Twojego sygnału
	# 1. Zerujemy statystyki
	GameManager.hard_reset()
	# 2. Zapisujemy ten wyzerowany stan na dysku (żeby nadpisać stary save!)
	SaveManager.save_game()
	# 3. Przenosimy gracza do wyboru klasy, żeby mógł zacząć od nowa
	get_tree().change_scene_to_file("res://Scenes/ClassSelection.tscn")

func _on_quit_button_pressed():
	# Wbudowana funkcja Godota do bezpiecznego zamykania gry
	get_tree().quit()
