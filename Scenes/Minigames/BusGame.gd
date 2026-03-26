extends Control

# --- WĘZŁY STOŁU ---
@onready var deck = $Deck
@onready var cards_container = $CardsContainer
@onready var start_card_pos = $StartCardPos 

@onready var start_button = $StartButton
@onready var score_button = $ScoreButton 
@onready var bet_button = $BetButton
@onready var money_button = $HUD/Button 

# NOWOŚĆ: EKRANY Z KOŚCI/BLACKJACKA
@onready var level_button = $LevelButton

@onready var game_over_panel = $GameOverLayer/GameOverPanel
@onready var score_label = $GameOverLayer/GameOverPanel/ScoreLabel
@onready var restart_button = $GameOverLayer/GameOverPanel/RestartButton
@onready var menu_button = $GameOverLayer/GameOverPanel/MenuButton

@onready var regular_panel = $LevelUpLayer/RegularLevelUpPanel
@onready var maze_panel = $LevelUpLayer/MazeCompletedPanel
@onready var next_level_button = $LevelUpLayer/MazeCompletedPanel/NextLevelButton 
@onready var next_level_label = $LevelUpLayer/MazeCompletedPanel/Label 

# UNIWERSALNE PRZYCISKI ETAPÓW
@onready var btn1 = $Btn1
@onready var btn2 = $Btn2
@onready var btn3 = $Btn3
@onready var btn4 = $Btn4

# PRZYCISK: WYPŁATA (CASH OUT)
@onready var btn_cashout = $BtnCashOut

# --- ZMIENNE GRY ---
var current_bet: int = 0
var card_offset = Vector2(150, 0) 
var drawn_cards = [] 
var current_stage = 1 
var card_scene = preload("res://Scenes/Card.tscn")

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	
	if btn1: btn1.pressed.connect(_on_btn_pressed.bind(1))
	if btn2: btn2.pressed.connect(_on_btn_pressed.bind(2))
	if btn3: btn3.pressed.connect(_on_btn_pressed.bind(3))
	if btn4: btn4.pressed.connect(_on_btn_pressed.bind(4))
	
	if btn_cashout: btn_cashout.pressed.connect(_on_cashout_pressed)
	
	# Podpinamy przyciski z paneli!
	if restart_button: restart_button.pressed.connect(_on_restart_button_pressed)
	if menu_button: menu_button.pressed.connect(_on_menu_button_pressed)
	if next_level_button: next_level_button.pressed.connect(_on_next_level_button_pressed)
	
	# Podpinamy GameManagera (Kasa i Poziomy)
	GameManager.money_changed.connect(update_money_display)
	GameManager.level_changed.connect(_on_level_changed) 
	GameManager.level_max.connect(_on_level_max) 
	GameManager.reset_game()
	
	update_money_display(GameManager.current_money)
	update_level_display() 
	
	if has_node("ChipContener/Chip1"): setup_chip($ChipContener/Chip1, 1)
	if has_node("ChipContener/Chip2"): setup_chip($ChipContener/Chip2, 5)
	if has_node("ChipContener/Chip3"): setup_chip($ChipContener/Chip3, 10)
	if has_node("ChipContener/Chip4"): setup_chip($ChipContener/Chip4, 50)
	if has_node("ChipContener/Chip5"): setup_chip($ChipContener/Chip5, 100)
	
	update_bet_display()
	hide_all_stage_buttons()
	
	game_over_panel.hide()
	regular_panel.hide()
	maze_panel.hide()
	
	score_button.text = "Postaw stawkę i kup bilet do Autobusu!"

# ==========================================
# --- SYSTEM ŻETONÓW I WYŚWIETLANIA ---
# ==========================================
func setup_chip(chip: TextureButton, value: int):
	chip.gui_input.connect(_on_chip_gui_input.bind(value))

func _on_chip_gui_input(event: InputEvent, value: int):
	if event is InputEventMouseButton and event.pressed:
		if start_button.visible == false: return 
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			current_bet += value
			if has_node("ChipSound"): $ChipSound.play()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			current_bet = max(0, current_bet - value)
			if has_node("ChipSound"): $ChipSound.play()
			
		update_bet_display()

func update_bet_display():
	bet_button.text = "Stawka: " + str(current_bet)

func update_money_display(amount: int):
	money_button.text = "Konto: " + str(amount)


# ==========================================
# --- GŁÓWNA MECHANIKA ---
# ==========================================
func _on_start_pressed():
	if current_bet <= 0:
		score_button.text = "Najpierw postaw stawkę!"
		return
	if current_bet > GameManager.current_money:
		score_button.text = "Nie masz tyle pieniędzy!"
		return
		
	GameManager.add_money(-current_bet)
	for child in cards_container.get_children(): child.queue_free()
	drawn_cards.clear()
	deck.generate_deck()
	
	start_button.hide()
	prepare_stage_1()

# --- FAZY GRY I KUSZENIE WYPŁATĄ ---
func hide_all_stage_buttons():
	btn1.hide(); btn2.hide(); btn3.hide(); btn4.hide()
	if btn_cashout: btn_cashout.hide()

func prepare_stage_1():
	current_stage = 1
	score_button.text = "ETAP 1: Czerwone czy Czarne?"
	btn1.text = "Czerwone"
	btn2.text = "Czarne"
	btn1.show()
	btn2.show()

func prepare_stage_2():
	current_stage = 2
	score_button.text = "DOBRZE! ETAP 2: Wyższa czy Niższa od pierwszej?"
	btn1.text = "Wyższa"
	btn2.text = "Niższa"
	btn1.show()
	btn2.show()
	
	btn_cashout.text = "Wypłać: " + str(current_bet * 2) + " monet"
	btn_cashout.show()

func prepare_stage_3():
	current_stage = 3
	score_button.text = "ŚWIETNIE! ETAP 3: Pomiędzy dwiema czy Na zewnątrz?"
	btn1.text = "Pomiędzy"
	btn2.text = "Na zewnątrz"
	btn1.show()
	btn2.show()
	
	btn_cashout.text = "Wypłać: " + str(current_bet * 4) + " monet"
	btn_cashout.show()

func prepare_stage_4():
	current_stage = 4
	score_button.text = "OSTATNIA KARTA! ETAP 4: Zgadnij Znak!"
	btn1.text = "♠ Pik"
	btn2.text = "♥ Kier"
	btn3.text = "♣ Trefl"
	btn4.text = "♦ Karo"
	btn1.show(); btn2.show(); btn3.show(); btn4.show()
	
	btn_cashout.text = "Wypłać: " + str(current_bet * 6) + " monet"
	btn_cashout.show()

# ==========================================
# --- LOGIKA WYPŁATY (CASH OUT) ---
# ==========================================
func _on_cashout_pressed():
	var base_win = 0
	
	if current_stage == 2: base_win = current_bet * 2
	elif current_stage == 3: base_win = current_bet * 4
	elif current_stage == 4: base_win = current_bet * 6
	
	# Obliczamy bonusy (Ryzykant i Magnes)
	var payout_data = apply_win_bonuses(base_win)
	var final_amount = payout_data[0]
	var bonus_text = payout_data[1]
	
	GameManager.add_money(final_amount)
	
	if has_node("WinSound"): $WinSound.play()
	if has_node("CoinFountain"): $CoinFountain.restart()
	
	score_button.text = "WYCOFUJESZ SIĘ! Zgarniasz " + str(final_amount) + " monet!" + bonus_text
	
	hide_all_stage_buttons()
	current_bet = 0
	update_bet_display()
	start_button.text = "Nowy bilet"
	start_button.show()

# ==========================================
# --- LOGIKA ZGADYWANIA (SERCE AUTOBUSU) ---
# ==========================================
func _on_btn_pressed(choice: int):
	hide_all_stage_buttons() 
	var new_card_data = draw_and_animate_card()
	
	await get_tree().create_timer(0.5).timeout 
	
	if current_stage == 1:
		var is_red = (new_card_data.suit == "Hearts" or new_card_data.suit == "Diamonds")
		var win = (choice == 1 and is_red) or (choice == 2 and not is_red)
		if win: prepare_stage_2()
		else: bus_crash("ŹLE! To " + ("czerwona" if is_red else "czarna") + " karta. Wypadasz!")
			
	elif current_stage == 2:
		var v1 = get_card_value(drawn_cards[0])
		var v2 = get_card_value(new_card_data)
		var win = false
		var szuler_used = false
		
		if choice == 1 and v2 > v1: win = true
		elif choice == 2 and v2 < v1: win = true
		elif v1 == v2 and GameManager.player_class == 3: # UMIEJĘTNOŚĆ: SZULER (Wygrywa remisy!)
			win = true
			szuler_used = true
		
		if win: 
			prepare_stage_3()
			if szuler_used: score_button.text = "SZULER OSZUKAŁ REMIS!\n" + score_button.text
		else: bus_crash("ŹLE! Karta nie była " + ("wyższa" if choice == 1 else "niższa") + ". Wypadasz!")
			
	elif current_stage == 3:
		var v1 = get_card_value(drawn_cards[0])
		var v2 = get_card_value(drawn_cards[1])
		var min_v = min(v1, v2)
		var max_v = max(v1, v2)
		var v3 = get_card_value(new_card_data)
		
		var win = false
		var szuler_used = false
		
		if choice == 1 and v3 > min_v and v3 < max_v: win = true
		elif choice == 2 and (v3 < min_v or v3 > max_v): win = true
		elif (v3 == min_v or v3 == max_v) and GameManager.player_class == 3: # UMIEJĘTNOŚĆ: SZULER (Trafienie w słupek to wygrana!)
			win = true
			szuler_used = true
		
		if win: 
			prepare_stage_4()
			if szuler_used: score_button.text = "SZULER OMINĄŁ SŁUPEK!\n" + score_button.text
		else: bus_crash("ŹLE! Trafiłeś w słupek. Wypadasz z autobusu!")
			
	elif current_stage == 4:
		var suit = new_card_data.suit
		var win = false
		if choice == 1 and suit == "Spades": win = true
		elif choice == 2 and suit == "Hearts": win = true
		elif choice == 3 and suit == "Clubs": win = true
		elif choice == 4 and suit == "Diamonds": win = true
		
		if win: win_bus()
		else: bus_crash("A MIAŁEŚ TO W GARŚCI! Zły znak. Wypadasz na samej mecie!")

# ==========================================
# --- WYNIKI I POMOCNICE ---
# ==========================================
func apply_win_bonuses(base_amount: int) -> Array:
	var final_amount = base_amount
	var bonus_text = ""
	
	# UMIEJĘTNOŚĆ: RYZYKANT (20% na podwojenie puli)
	if GameManager.player_class == 2 and randf() <= 0.20:
		final_amount += base_amount 
		bonus_text += "\nRYZYKANT: Podwójna wygrana!"
			
	# ULEPSZENIE: MAGNES (Szansa na dodatkowe monety z mnożnikiem)
	if GameManager.magnet_level > 0 and randf() <= 0.30: 
		var magnet_bonus = int(final_amount * (GameManager.magnet_level * 0.10))
		if magnet_bonus > 0:
			final_amount += magnet_bonus
			bonus_text += "\nMAGNES: +" + str(magnet_bonus) + " monet!"
			
	return [final_amount, bonus_text]

func draw_and_animate_card() -> Dictionary:
	var drawn_card_data = deck.draw_card()
	drawn_cards.append(drawn_card_data)
	
	var new_card = card_scene.instantiate()
	cards_container.add_child(new_card)
	
	var target_pos = start_card_pos.global_position + (card_offset * (drawn_cards.size() - 1))
	var deck_start_pos = Vector2(1000, 100) 
	new_card.global_position = deck_start_pos
	new_card.setup_card(drawn_card_data.value, drawn_card_data.suit, false)
	
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(new_card, "global_position", target_pos, 0.4)
	
	if has_node("CardSound"): $CardSound.play()
	return drawn_card_data

func get_card_value(card_data: Dictionary) -> int:
	var val = card_data.value
	if val == "J": return 11
	if val == "Q": return 12
	if val == "K": return 13
	if val == "A": return 14 
	return int(val)

func win_bus():
	var base_win = current_bet * 10 
	
	# Bonusy do Jackpota
	var payout_data = apply_win_bonuses(base_win)
	var final_amount = payout_data[0]
	var bonus_text = payout_data[1]
	
	GameManager.add_money(final_amount)
	
	score_button.text = "JACKPOT!!! Przeżyłeś Autobus! Zgarniasz potężne " + str(final_amount) + " monet!" + bonus_text
	
	if has_node("WinSound"): $WinSound.play()
	if has_node("CoinFountain"): $CoinFountain.restart()
	
	current_bet = 0
	update_bet_display()
	start_button.text = "Zagraj ponownie"
	start_button.show()

# ==========================================
# --- BANKRUCTWO I SYSTEM POZIOMÓW ---
# ==========================================
func bus_crash(message: String):
	score_button.text = message
	current_bet = 0
	update_bet_display() 
	
	# --- SPRAWDZANIE BANKRUCTWA I PRZETRWANIA ---
	if GameManager.current_money <= 0:
		var saved_from_bankruptcy = false
		
		# Ulepszenie: Druga Szansa
		if GameManager.survival_level > 0:
			var survival_chance = GameManager.survival_level * 0.10
			if randf() <= survival_chance:
				saved_from_bankruptcy = true
				GameManager.current_money = 10 
				score_button.text += "\nCUDA! Omijasz bankructwo (Zostaje 10 monet)!"
				GameManager.money_changed.emit(GameManager.current_money) 
				
		if not saved_from_bankruptcy:
			var target_money_to_level_up = GameManager.current_level * 100 
			var final_score = GameManager.calculate_score(target_money_to_level_up)
			var earned_vip = int(final_score / 100)
			
			GameManager.vip_points += earned_vip
			# SaveManager.save_game() # Jeśli tu wrzucimy Save, gracz będzie zbankrutowany po powrocie
			
			score_label.text = "Twój Wynik: " + str(final_score) + " pkt!\nZdobywasz: " + str(earned_vip) + " Punktów VIP!"
			game_over_panel.show()
			start_button.hide()
			return # Kończymy, gracz zbankrutował
			
	# Jeśli masz kasę (albo uratowało Cię Przetrwanie):
	start_button.text = "Kup nowy bilet"
	start_button.show()

func update_level_display():
	if GameManager.current_level <= GameManager.max_level:
		level_button.text = "Poziom: " + str(GameManager.current_level) + "\n Wymóg: " + str(GameManager.level_requirements[GameManager.current_level]) + " monet"
	else:
		level_button.text = "POZIOM MAX!"

func _on_level_changed(new_level: int):
	update_level_display()
	if new_level > 1 and start_button.visible: 
		trigger_automatic_level_up()

func _on_level_max(level: int):
	GameManager.stop_run_timer()
	next_level_button.text="Przejdź do Menu Zwycięsco!"
	# Formatujemy ładny czas! (wymaga funkcji w GameManagerze, tak jak gadaliśmy)
	var final_time = GameManager.get_formatted_time()
	next_level_label.text = "Gratulacje!\nPrzeszedłeś całą grę!\nTwój czas to:\n" + final_time
	
	maze_panel.show()

func trigger_automatic_level_up() -> void:
	regular_panel.show()
	start_button.disabled = true 
	await get_tree().create_timer(3.0).timeout 
	regular_panel.hide()
	start_button.disabled = false

# ==========================================
# --- PRZYCISKI Z PANELI ---
# ==========================================
func _on_restart_button_pressed():
	GameManager.total_run_levels = 0
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://Scenes/Minigames/DiceGame.tscn")

func _on_menu_button_pressed() -> void:
	GameManager.total_run_levels = 0
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_next_level_button_pressed() -> void:
	GameManager.total_run_levels = 0
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
