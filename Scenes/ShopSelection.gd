extends Control

@onready var vip_badge = $VIPBadge 
@onready var money_button = $VBoxContainer/MoneyButton
@onready var magnet_button = $VBoxContainer/MagnetButton
@onready var survival_button = $VBoxContainer/SurvivalButton

# Ten przycisk/label posłuży nam za wyświetlacz opisów!
@onready var info_button = $InfoButton

var base_cost: int = 10 # Koszt podstawowy (dla poziomu 0)

func _ready():
	update_shop_ui()
	
	# ==========================================
	# --- SYSTEM OPISÓW PO NAJECHANIU MYSZKĄ ---
	# ==========================================
	if money_button:
		money_button.mouse_entered.connect(_show_info.bind("GRUBY PORTFEL\nRozpoczynasz każdą nową grę z dużo większą ilością gotówki na start. Nie musisz żebrać!"))
		money_button.mouse_exited.connect(_hide_info)
		
	if magnet_button:
		magnet_button.mouse_entered.connect(_show_info.bind("MAGNES NA KASĘ\nMagia kasyna! Masz szansę (10% co każdy poziom) na znalezienie dodatkowych monet przy wygranej."))
		magnet_button.mouse_exited.connect(_hide_info)
		
	if survival_button:
		survival_button.mouse_entered.connect(_show_info.bind("DRUGA SZANSA (PRZETRWANIE)\nSzansa (10% co każdy poziom), że przy bankructwie gra uratuje Cię przed porażką i da 10 monet na odbicie się!"))
		survival_button.mouse_exited.connect(_hide_info)
		
	# Ustawiamy tekst domyślny
	_hide_info()

# --- FUNKCJA OBLICZAJĄCA KOSZT ---
func get_cost(current_level: int) -> int:
	return base_cost * (2 ** current_level)

# --- ODŚWIEŻANIE EKRANU ---
func update_shop_ui():
	vip_badge.text = str(GameManager.vip_points)
	
	# 1. Gruby Portfel
	if GameManager.upgrade_starting_money_level < 5:
		var cost = get_cost(GameManager.upgrade_starting_money_level)
		money_button.text = "Gruby Portfel (" + str(GameManager.upgrade_starting_money_level) + "/5) - " + str(cost) + " VIP"
		money_button.disabled = GameManager.vip_points < cost 
	else:
		money_button.text = "Gruby Portfel (MAX)"
		money_button.disabled = true 

	# 2. Magnes na kasę
	if GameManager.magnet_level < 5:
		var cost = get_cost(GameManager.magnet_level)
		magnet_button.text = "Magnes na kasę (" + str(GameManager.magnet_level) + "/5) - " + str(cost) + " VIP"
		magnet_button.disabled = GameManager.vip_points < cost
	else:
		magnet_button.text = "Magnes na kasę (MAX)"
		magnet_button.disabled = true

	# 3. Druga Szansa
	if GameManager.survival_level < 5:
		var cost = get_cost(GameManager.survival_level)
		survival_button.text = "Druga Szansa (" + str(GameManager.survival_level) + "/5) - " + str(cost) + " VIP"
		survival_button.disabled = GameManager.vip_points < cost
	else:
		survival_button.text = "Druga Szansa (MAX)"
		survival_button.disabled = true

# --- FUNKCJE KUPOWANIA ---
func _on_money_button_pressed():
	if GameManager.upgrade_starting_money_level < 5:
		var cost = get_cost(GameManager.upgrade_starting_money_level)
		if GameManager.vip_points >= cost:
			GameManager.vip_points -= cost
			GameManager.upgrade_starting_money_level += 1
			update_shop_ui()
			SaveManager.save_game()

func _on_magnet_button_pressed():
	if GameManager.magnet_level < 5:
		var cost = get_cost(GameManager.magnet_level)
		if GameManager.vip_points >= cost:
			GameManager.vip_points -= cost
			GameManager.magnet_level += 1
			update_shop_ui()
			SaveManager.save_game()

func _on_survival_button_pressed():
	if GameManager.survival_level < 5:
		var cost = get_cost(GameManager.survival_level)
		if GameManager.vip_points >= cost:
			GameManager.vip_points -= cost
			GameManager.survival_level += 1
			update_shop_ui()
			SaveManager.save_game()

# --- POWRÓT ---
func _on_back_button_pressed(): 
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

# ==========================================
# --- FUNKCJE POKAZYWANIA INFO ---
# ==========================================
func _show_info(description: String):
	info_button.text = description

func _hide_info():
	info_button.text = "Najedź kursorem na ulepszenie, aby poznać jego działanie..."
