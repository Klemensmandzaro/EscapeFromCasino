extends Control

@onready var label = $ButtonScore       
@onready var bet_label = $BetButton  
@onready var dice_button = $Button  
@onready var game_over_panel = $GameOverLayer/GameOverPanel
@onready var roll_sound = $RollSound
@onready var win_sound = $WinSound
@onready var score_label = $GameOverLayer/GameOverPanel/ScoreLabel
@onready var dice_arena = $SubViewportContainer/SubViewport/DiceArena
@onready var level_button = $LevelButton

@onready var regular_panel = $LevelUpLayer/RegularLevelUpPanel
@onready var maze_panel = $LevelUpLayer/MazeCompletedPanel



var current_bet: int = 0           

func _ready():
	label.hide()
	game_over_panel.hide()
	GameManager.reset_game()
	GameManager.money_changed.emit(GameManager.current_money)
	GameManager.level_changed.connect(_screen_after_level)
	GameManager.level_max.connect(_screen_after_max)
	
	regular_panel.hide()
	maze_panel.hide()
	update_bet_display()
	update_level_display()
	
	
	if has_node("ChipContener/Chip1"): setup_chip($ChipContener/Chip1, 1)
	if has_node("ChipContener/Chip2"): setup_chip($ChipContener/Chip2, 5)
	if has_node("ChipContener/Chip3"): setup_chip($ChipContener/Chip3, 10)
	if has_node("ChipContener/Chip4"): setup_chip($ChipContener/Chip4, 50)
	if has_node("ChipContener/Chip5"): setup_chip($ChipContener/Chip5, 100)

func setup_chip(chip: TextureButton, value: int):
	chip.gui_input.connect(_on_chip_gui_input.bind(value))

func _on_chip_gui_input(event: InputEvent, value: int):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			current_bet += value
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			current_bet = max(0, current_bet - value)
		
		update_bet_display()

func update_bet_display():
	bet_label.text = "Twoja stawka: " + str(current_bet)



func _on_button_pressed():
	label.hide()
	if current_bet <= 0:
		label.show()
		label.text = "Najpierw postaw stawkę!"
		return
		
	if current_bet > GameManager.current_money:
		label.show()
		label.text = "Nie masz tyle pieniędzy!"
		return
	
	
	$Button.disabled = true
	
	
	if roll_sound:
		roll_sound.play()

	
	dice_arena.roll_dices()



func _on_dice_arena_roll_finished(result1: int, result2: int) -> void:
	
	var current_roll_sum = result1 + result2
	var roll_display = str(current_roll_sum) 
	label.show()
	
	
	if GameManager.player_class == 3:
		current_roll_sum += 1
		roll_display += " (+1 Szuler = " + str(current_roll_sum) + ")"

	
	if current_roll_sum >= 7: # WYGRANA
		var win_amount = current_bet
		var bonus_text = ""
		
		
		if GameManager.player_class == 2:
			if randf() <= 0.20:
				win_amount = current_bet * 2
				bonus_text += "\nRYZYKANT: Podwójna wygrana!!!"
				
		
		if GameManager.magnet_level > 0:
			if randf() <= 0.30:
				var magnet_multiplier = GameManager.magnet_level * 0.10
				var magnet_bonus = int(current_bet * magnet_multiplier)
				if magnet_bonus > 0:
					win_amount += magnet_bonus
					bonus_text += "\nSKLEP: Magnes przyciągnął bonus +" + str(magnet_bonus) + " monet!"
		
		
		label.text = "Wyrzuciłeś: " + roll_display + ". Wygrałeś " + str(win_amount) + "!" + bonus_text
		GameManager.add_money(win_amount)
		
		
		if win_sound:
			win_sound.play()
		if has_node("CoinFountain"):
			$CoinFountain.restart()
			
		
		
		
	else:
		label.text = "Wyrzuciłeś: " + roll_display + ". Przegrałeś " + str(current_bet) + "."
		GameManager.add_money(-current_bet)
	
	current_bet = 0
	update_bet_display()
	$Button.disabled = false

	if GameManager.current_money <= 0:
		var saved_from_bankruptcy = false
		
		if GameManager.survival_level > 0:
			var survival_chance = GameManager.survival_level * 0.10
			if randf() <= survival_chance:
				saved_from_bankruptcy = true
				GameManager.current_money = 10 
				label.text += "\nCUDA! Omijasz bankructwo i zostaje 10 monet!"
				GameManager.money_changed.emit(GameManager.current_money)
		
		if not saved_from_bankruptcy:
			var target_money_to_level_up = GameManager.level_requirements[GameManager.current_level]
			var final_score = GameManager.calculate_score(target_money_to_level_up)
			
			var earned_vip = int(final_score / 100)
			GameManager.vip_points += earned_vip
			if GameManager.vip_points<0:
				GameManager.vip_points=0
			SaveManager.save_game()
			
			score_label.text = "Twój Wynik: " + str(final_score) + " pkt!\nZdobywasz: " + str(earned_vip) + " Punktów VIP!"
			
			game_over_panel.show()
			$Button.disabled = true


func _on_restart_button_pressed():
	GameManager.total_run_levels = 0
	GameManager.reset_game()
	SaveManager.save_game()
	current_bet = 0
	update_bet_display()
	label.text = "Nowa gra! Rzuć kośćmi."
	
	game_over_panel.hide()
	$Button.disabled = false


func _on_menu_button_pressed() -> void:
	GameManager.reset_game()
	GameManager.total_run_levels = 0
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	
func update_level_display():
	level_button.text = "Poziom: " + str(GameManager.current_level) + "\n" + " Wymóg Labiryntu: " + str(GameManager.level_requirements[GameManager.current_level]) + " monet"


func _on_next_level_button_pressed() -> void:
	GameManager.reset_game()
	
	get_tree().change_scene_to_file("res://Scenes/CardTable.tscn")
	

	
	
func trigger_automatic_level_up() -> void:
	regular_panel.show()
	$Button.disabled = true
	

	await get_tree().create_timer(3.0).timeout
	
	regular_panel.hide()
	$Button.disabled = false
	
func _screen_after_level(levelup):
	if(GameManager.current_level>1):
		trigger_automatic_level_up()
		update_level_display()
		
func _screen_after_max(levelmax):
	SaveManager.save_game()
	maze_panel.show()
			
