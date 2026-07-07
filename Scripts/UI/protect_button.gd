extends Button

var battle

func setup(b):
	battle = b
	
func _pressed():
	if battle == null:
		return
	battle.select_protect()
