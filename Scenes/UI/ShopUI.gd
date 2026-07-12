extends Control


signal shop_closed

func open():
	show()
	
func _on_button_pressed():
	hide()
	shop_closed.emit()
	
