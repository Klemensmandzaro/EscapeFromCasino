extends Node3D

@onready var die1 = $Die1
@onready var die2 = $Die2

signal roll_finished(result1, result2)
var checking_roll = false

func roll_dices():
	die1.roll()
	die2.roll()
	checking_roll = true

func _process(_delta):
	if checking_roll:
		if not die1.is_rolling and not die2.is_rolling:
			checking_roll = false
			var res1 = die1.get_top_face_value()
			var res2 = die2.get_top_face_value()
			emit_signal("roll_finished", res1, res2)
