extends Control


@onready var money_label = $Button

func _ready():
	update_money_text(GameManager.current_money)
	GameManager.money_changed.connect(update_money_text)

func update_money_text(new_amount):
	money_label.text = str(new_amount)
