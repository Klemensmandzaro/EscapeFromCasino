extends Node

var save_path = "user://kasyno_save.cfg"

# Odpalamy wczytywanie automatycznie przy starcie gry
func _ready():
	load_game()

func save_game():
	var config = ConfigFile.new()
	
	# Zapisujemy zmienne z GameManagera
	config.set_value("Sklep", "vip_points", GameManager.vip_points)
	config.set_value("Sklep", "upgrade_starting_money_level", GameManager.upgrade_starting_money_level)
	config.set_value("Sklep", "magnet_level", GameManager.magnet_level)
	config.set_value("Sklep", "survival_level", GameManager.survival_level)
	config.set_value("Gracz", "player_class", GameManager.player_class)
	config.set_value("Timer", "playtime", GameManager.total_playtime)
	config.set_value("Sklep", "is_first_time_playing", GameManager.is_first_time_playing)
	config.save(save_path)
	print("SaveManager: Zapisano grę pomyślnie!")

func load_game():
	var config = ConfigFile.new()
	var err = config.load(save_path)
	
	if err == OK:
		# Nadpisujemy zmienne w GameManagerze zapisanymi danymi
		GameManager.vip_points = config.get_value("Sklep", "vip_points", 50)
		GameManager.upgrade_starting_money_level = config.get_value("Sklep", "upgrade_starting_money_level", 0)
		GameManager.magnet_level = config.get_value("Sklep", "magnet_level", 0)
		GameManager.survival_level = config.get_value("Sklep", "survival_level", 0)
		GameManager.player_class = config.get_value("Gracz", "player_class", 1)
		GameManager.total_playtime = config.get_value("Timer", "playtime", 0)
		GameManager.is_first_time_playing = config.get_value("Sklep", "is_first_time_playing", true)
		print("SaveManager: Wczytano stan gry!")
	else:
		print("SaveManager: Brak pliku zapisu, zaczynamy od zera.")
