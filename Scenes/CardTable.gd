extends Control

# ==========================================
# --- 1. WĘZŁY STOŁU I KART ---
# ==========================================
@onready var deck = $Deck
@onready var draw_button = $DrawButton 
@onready var hit_button = $HitButton
@onready var stand_button = $StandButton
@onready var score_button = $ScoreButton
@onready var cards_container = $CardsContainer 
@onready var split_button = $SplitButton
@onready var insurance_button = $InsuranceButton
@onready var split_cards_container = $SplitCardsContainer

# Pola do rozdawania (Marker2D)
@onready var dealer_area = $DealerArea
@onready var player_area = $PlayerArea
@onready var split_area = $SplitArea
@onready var center_area = $CenterArea # <--- DODANE DO ANIMACJI SPLITA (Marker na środku!)

@onready var bet_button = $BetButton
@onready var double_button = $DoubleButton
@onready var level_button = $LevelButton

# ==========================================
# --- 2. WĘZŁY EKRANÓW (POPRAWIONE ŚCIEŻKI!) ---
# ==========================================
@onready var game_over_panel = $GameOverLayer/GameOverPanel
@onready var score_label = $GameOverLayer/GameOverPanel/ScoreLabel
@onready var restart_button = $GameOverLayer/GameOverPanel/RestartButton
@onready var menu_button = $GameOverLayer/GameOverPanel/MenuButton

@onready var regular_panel = $LevelUpLayer/RegularLevelUpPanel
@onready var maze_panel = $LevelUpLayer/MazeCompletedPanel
@onready var next_level_button = $LevelUpLayer/MazeCompletedPanel/NextLevelButton 

# ==========================================
# --- 3. ZMIENNE GRY ---
# ==========================================
var double_hand_1 = false 
var double_hand_2 = false 

var current_bet: int = 0
var dealer_hidden_card_node = null 

var has_insurance = false
var is_split_active = false
var second_hand = [] 
var active_hand = 1 

# Zmienne do płynnego przesuwania rąk po stole
var active_pos_1 = Vector2.ZERO
var active_pos_2 = Vector2.ZERO

var card_scene = preload("res://Scenes/Card.tscn")

var player_hand = []
var dealer_hand = []

var card_offset = Vector2(40, 0)

# ==========================================
# --- 4. START SKRYPTU ---
# ==========================================
func _ready():
	# Podpinamy przyciski akcji
	draw_button.pressed.connect(_on_start_game_pressed)
	hit_button.pressed.connect(_on_hit_pressed)
	stand_button.pressed.connect(_on_stand_pressed)
	insurance_button.pressed.connect(_on_insurance_pressed)
	split_button.pressed.connect(_on_split_pressed)
	double_button.pressed.connect(_on_double_pressed)
	score_button.hide()
	
	# Podpinamy przyciski z ekranów!
	if restart_button: restart_button.pressed.connect(_on_restart_button_pressed)
	if menu_button: menu_button.pressed.connect(_on_menu_button_pressed)
	if next_level_button: next_level_button.pressed.connect(_on_next_level_button_pressed)
	
	# Sygnały GameManagera
	GameManager.level_changed.connect(_on_level_changed)
	GameManager.level_max.connect(_on_level_max)
	GameManager.reset_game()
	
	update_bet_display()
	update_level_display()
	
	# Podpinanie żetonów
	if has_node("ChipContener/Chip1"): setup_chip($ChipContener/Chip1, 1)
	if has_node("ChipContener/Chip2"): setup_chip($ChipContener/Chip2, 5)
	if has_node("ChipContener/Chip3"): setup_chip($ChipContener/Chip3, 10)
	if has_node("ChipContener/Chip4"): setup_chip($ChipContener/Chip4, 50)
	if has_node("ChipContener/Chip5"): setup_chip($ChipContener/Chip5, 100)
	
	# Resetowanie UI na starcie
	draw_button.text = "Rozdaj Karty!"
	hit_button.hide()
	stand_button.hide()
	game_over_panel.hide()
	regular_panel.hide()
	maze_panel.hide()

# ==========================================
# --- 5. SYSTEM ŻETONÓW I WYŚWIETLANIA KASY ---
# ==========================================
func setup_chip(chip: TextureButton, value: int):
	chip.gui_input.connect(_on_chip_gui_input.bind(value))

func _on_chip_gui_input(event: InputEvent, value: int):
	if event is InputEventMouseButton and event.pressed:
		if draw_button.visible == false: 
			return 
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			current_bet += value
			if has_node("ChipSound"): $ChipSound.play()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			current_bet = max(0, current_bet - value)
			if has_node("ChipSound"): $ChipSound.play()
			
		update_bet_display()

func update_bet_display():
	bet_button.text = "Stawka: " + str(current_bet)

func update_level_display():
	if GameManager.current_level <= GameManager.max_level:
		level_button.text = "Poziom: " + str(GameManager.current_level) + "\n Wymóg: " + str(GameManager.level_requirements[GameManager.current_level]) + " monet"
	else:
		level_button.text = "POZIOM MAX!"

# ==========================================
# --- 6. GŁÓWNA PĘTLA GRY ---
# ==========================================
func _on_start_game_pressed():
	score_button.show()
	if current_bet <= 0:
		score_button.text = "Najpierw postaw stawkę!"
		return
	if current_bet > GameManager.current_money:
		score_button.text = "Nie masz tyle pieniędzy!"
		return
		
	GameManager.add_money(-current_bet)
	
	# Sprzątanie
	for child in cards_container.get_children(): child.queue_free()
	for child in split_cards_container.get_children(): child.queue_free()
	
	has_insurance = false
	is_split_active = false
	active_hand = 1
	second_hand.clear()
	
	double_hand_1 = false
	double_hand_2 = false
	double_button.hide()
		
	draw_button.hide()
	hit_button.show()
	hit_button.disabled = false 
	stand_button.show()
	insurance_button.hide()
	split_button.hide()
	score_button.text = ""
	
	deck.generate_deck() 
	player_hand.clear()
	dealer_hand.clear()
	
	# --- ROZDANIE POCZĄTKOWE NA ŚRODEK STOŁU ---
	active_pos_1 = center_area.global_position
	
	deal_card(dealer_hand, dealer_area.global_position, cards_container, false)
	deal_card(player_hand, active_pos_1, cards_container, false)
	dealer_hidden_card_node = deal_card(dealer_hand, dealer_area.global_position, cards_container, true)  
	deal_card(player_hand, active_pos_1, cards_container, false) 
	
	check_available_actions() 
	update_score_display()
	
	# Szybki Blackjack
	if calculate_score(player_hand) == 21:
		GameManager.add_money(int(current_bet * 2.5)) 
		if has_node("WinSound"): $WinSound.play()
		if has_node("CoinFountain"): $CoinFountain.restart()
		end_game("BLACKJACK! Wygrywasz od razu!")

func deal_card(hand: Array, base_pos: Vector2, container_node: Node2D, is_card_hidden: bool = false):
	var drawn_card_data = deck.draw_card()
	if drawn_card_data.is_empty(): return null
		
	hand.append(drawn_card_data)
	var new_card = card_scene.instantiate()
	container_node.add_child(new_card) 
	
	var target_pos = base_pos + (card_offset * (hand.size() - 1))
	var deck_start_pos = Vector2(1000, 100)
	
	new_card.global_position = deck_start_pos
	new_card.setup_card(drawn_card_data.value, drawn_card_data.suit, is_card_hidden)
	
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(new_card, "global_position", target_pos, 0.4)
	
	if has_node("CardSound"):
		$CardSound.play()
		
	return new_card
	
func calculate_score(hand: Array) -> int:
	var score = 0
	var aces = 0
	
	for card in hand:
		if card.value in ["J", "Q", "K"]:
			score += 10
		elif card.value == "A":
			aces += 1
			score += 11
		else:
			score += int(card.value)
			
	while score > 21 and aces > 0:
		score -= 10
		aces -= 1
		
	return score

func update_score_display():
	var d_score = 0
	if dealer_hidden_card_node and dealer_hidden_card_node.is_hidden:
		d_score = calculate_score([dealer_hand[0]])
	else:
		d_score = calculate_score(dealer_hand)
		
	var text = "Krupier: " + str(d_score) + "\nRęka 1: " + str(calculate_score(player_hand))
	
	if is_split_active:
		text += " | Ręka 2: " + str(calculate_score(second_hand))
		text += "\nGramy teraz: Ręka " + str(active_hand)
		
	score_button.text = text

# ==========================================
# --- 7. AKCJE GRACZA ---
# ==========================================
func check_available_actions():
	var current_hand = player_hand if active_hand == 1 else second_hand
	var p_score = calculate_score(current_hand)
	
	hit_button.disabled = (p_score >= 21)
	
	if current_hand.size() == 2:
		double_button.show()
	else:
		double_button.hide()

	if dealer_hand.size() == 2 and dealer_hand[0].value == "A" and player_hand.size() == 2 and not is_split_active:
		insurance_button.show()
	else:
		insurance_button.hide()
		
	if player_hand.size() == 2 and player_hand[0].value == player_hand[1].value and not is_split_active:
		split_button.show()
	else:
		split_button.hide()

func _on_hit_pressed():
	insurance_button.hide()
	split_button.hide()
	
	if active_hand == 1:
		deal_card(player_hand, active_pos_1, cards_container)
	else:
		deal_card(second_hand, active_pos_2, split_cards_container)
		
	update_score_display()
	check_available_actions()
	
	var current_hand = player_hand if active_hand == 1 else second_hand
	
	if calculate_score(current_hand) > 21:
		if is_split_active and active_hand == 1:
			active_hand = 2
			update_score_display()
			check_available_actions()
		elif is_split_active and active_hand == 2:
			if calculate_score(player_hand) > 21:
				end_game("FURA NA OBU RĘKACH! Przegrywasz.")
			else:
				_on_stand_pressed()
		else:
			end_game("FURA! Przekroczyłeś 21.")
	
	elif calculate_score(current_hand) == 21:
		
		hit_button.hide()
		stand_button.hide()
		if has_node("DoubleButton"): $DoubleButton.hide()
		
		# Czekamy pół sekundy, aż karta elegancko wyląduje na stole
		await get_tree().create_timer(0.5).timeout
		
		# Gra sama "klika" za nas przycisk Czekaj!
		_on_stand_pressed()

func _on_stand_pressed():
	if is_split_active and active_hand == 1:
		active_hand = 2
		update_score_display()
		check_available_actions()
		return
		
	hit_button.hide()
	stand_button.hide()
	split_button.hide()
	insurance_button.hide()
	if has_node("DoubleButton"): $DoubleButton.hide()
	
	if dealer_hidden_card_node and is_instance_valid(dealer_hidden_card_node):
		dealer_hidden_card_node.reveal()
		
	update_score_display()
	await get_tree().create_timer(0.5).timeout
	
	while calculate_score(dealer_hand) < 17:
		deal_card(dealer_hand, dealer_area.global_position, cards_container)
		update_score_display()
		await get_tree().create_timer(0.5).timeout
		
	check_winner()

func _on_double_pressed():
	if current_bet > GameManager.current_money:
		score_button.text = "Za mało kasy na Double Down!\n" + score_button.text
		return
		
	GameManager.add_money(-current_bet)
	double_button.hide()
	
	if active_hand == 1:
		double_hand_1 = true
		deal_card(player_hand, active_pos_1, cards_container)
	else:
		double_hand_2 = true
		deal_card(second_hand, active_pos_2, split_cards_container)
		
	update_score_display()
	_on_stand_pressed()

func _on_split_pressed():
	if current_bet > GameManager.current_money:
		score_button.text = "Za mało kasy na Split!\n" + score_button.text
		return
		
	GameManager.add_money(-current_bet) 
	is_split_active = true
	split_button.hide()
	insurance_button.hide()
	
	var moved_card_data = player_hand.pop_back()
	second_hand.append(moved_card_data)
	
	var child_count = cards_container.get_child_count()
	var visual_card = cards_container.get_child(child_count - 1)
	cards_container.remove_child(visual_card)
	split_cards_container.add_child(visual_card)
	
	active_pos_1 = player_area.global_position 
	active_pos_2 = split_area.global_position  
	
	
	var card1 = cards_container.get_child(1) 
	
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(card1, "global_position", active_pos_1, 0.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(visual_card, "global_position", active_pos_2, 0.4).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	
	deal_card(player_hand, active_pos_1, cards_container)
	deal_card(second_hand, active_pos_2, split_cards_container)
	
	update_score_display()
	check_available_actions()
	
	# Automatyczny stand na 1 ręce, jeśli od razu wpadło 21!
	if calculate_score(player_hand) == 21:
		await get_tree().create_timer(0.5).timeout
		_on_stand_pressed()

func _on_insurance_pressed():
	has_insurance = true
	insurance_button.hide()
	score_button.text = "Ubezpieczenie kupione!\n" + score_button.text

# ==========================================
# --- 8. ZAKOŃCZENIE I WYPŁATY ZE SKLEPU ---
# ==========================================
func check_winner():
	var d_score = calculate_score(dealer_hand)
	var final_message = ""
	
	if is_split_active:
		var p1_score = calculate_score(player_hand)
		var p2_score = calculate_score(second_hand)
		
		var bet1 = current_bet * 2 if double_hand_1 else current_bet
		var bet2 = current_bet * 2 if double_hand_2 else current_bet
		
		final_message = "Ręka 1: " + get_hand_result_and_payout(p1_score, d_score, bet1) + "\n"
		final_message += "Ręka 2: " + get_hand_result_and_payout(p2_score, d_score, bet2)
	else:
		var p_score = calculate_score(player_hand)
		var bet1 = current_bet * 2 if double_hand_1 else current_bet
		
		final_message = get_hand_result_and_payout(p_score, d_score, bet1)
		
	end_game(final_message)

func get_hand_result_and_payout(p_score: int, d_score: int, hand_bet: int) -> String:
	if p_score > 21: 
		return "FURA - Przegrana"
	
	if d_score > 21 or p_score > d_score: 
		var win_amount = hand_bet * 2
		var bonus_text = ""
		
		# UMIEJĘTNOŚĆ RYZYKANT
		if GameManager.player_class == 2:
			if randf() <= 0.20:
				win_amount += hand_bet 
				bonus_text += "\nRYZYKANT: Podwójna wygrana!"
				
		# ULEPSZENIE: MAGNES 
		if GameManager.magnet_level > 0:
			if randf() <= 0.30: 
				var magnet_bonus = int(hand_bet * (GameManager.magnet_level * 0.10))
				if magnet_bonus > 0:
					win_amount += magnet_bonus
					bonus_text += "\nMAGNES: +" + str(magnet_bonus) + " monet!"
		
		GameManager.add_money(win_amount)
		if has_node("WinSound"): $WinSound.play()
		if has_node("CoinFountain"): $CoinFountain.restart()
		return "WYGRANA (+" + str(win_amount - hand_bet) + ")" + bonus_text
		
	if d_score > p_score: 
		return "PRZEGRANA"
		
	if GameManager.player_class == 3: # UMIEJĘTNOŚĆ: SZULER
		GameManager.add_money(hand_bet * 2) 
		if has_node("WinSound"): $WinSound.play()
		if has_node("CoinFountain"): $CoinFountain.restart()
		return "SZULER OSZUKAŁ! Wygrany remis (+" + str(hand_bet) + ")"
	else:
		GameManager.add_money(hand_bet) 
		return "REMIS (Push)"

func end_game(message: String):
	if dealer_hidden_card_node and is_instance_valid(dealer_hidden_card_node) and dealer_hidden_card_node.is_hidden:
		dealer_hidden_card_node.reveal()
		update_score_display()
		
	score_button.text += "\n\n" + message
	hit_button.hide()
	stand_button.hide()
	split_button.hide()
	insurance_button.hide()
	if has_node("DoubleButton"): $DoubleButton.hide()
	
	current_bet = 0
	update_bet_display()
	
	# SPRAWDZANIE BANKRUCTWA I PRZETRWANIA
	if GameManager.current_money <= 0:
		var saved_from_bankruptcy = false
		
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
			# SaveManager.save_game() 
			
			score_label.text = "Twój Wynik: " + str(final_score) + " pkt!\nZdobywasz: " + str(earned_vip) + " Punktów VIP!"
			game_over_panel.show()
			draw_button.disabled = true
			return 
			
	draw_button.text = "Zagraj ponownie"
	draw_button.show()
	draw_button.disabled = false

# ==========================================
# --- 9. SYSTEM KAMPANII (POZIOMY Z KOŚCI) ---
# ==========================================
func _on_level_changed(new_level: int):
	update_level_display()
	if new_level > 1 and not draw_button.visible:
		trigger_automatic_level_up()

func _on_level_max(level: int):
	maze_panel.show()

func trigger_automatic_level_up() -> void:
	regular_panel.show()
	draw_button.disabled = true 
	await get_tree().create_timer(3.0).timeout 
	regular_panel.hide()
	draw_button.disabled = false

# ==========================================
# --- 10. PRZYCISKI Z EKRANÓW (UI) ---
# ==========================================
func _on_restart_button_pressed():
	GameManager.total_run_levels = 0
	GameManager.reset_game()
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://Scenes/Minigames/DiceGame.tscn")

func _on_menu_button_pressed() -> void:
	GameManager.total_run_levels = 0
	GameManager.reset_game()
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_next_level_button_pressed() -> void:
	GameManager.reset_game()
	SaveManager.save_game()
	
	get_tree().change_scene_to_file("res://Scenes/Minigames/BusGame.tscn")
