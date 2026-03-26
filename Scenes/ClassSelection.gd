extends Control

func _on_bogacz_pressed():
	GameManager.player_class = 1
	GameManager.is_first_time_playing = false
	SaveManager.save_game()
	wraca_do_menu()

func _on_ryzykant_pressed():
	GameManager.player_class = 2
	GameManager.is_first_time_playing = false
	SaveManager.save_game()
	wraca_do_menu()

func _on_szuler_pressed():
	GameManager.player_class = 3
	GameManager.is_first_time_playing = false
	SaveManager.save_game()
	wraca_do_menu()

func _on_wroc_pressed(): # Przycisk "Wróć do Menu"
	wraca_do_menu()

# Robimy tu małą funkcję pomocniczą, żeby nie kopiować tej samej linijki 4 razy!
func wraca_do_menu():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
