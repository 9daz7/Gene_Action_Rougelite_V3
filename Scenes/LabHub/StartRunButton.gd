extends Button


signal start_run_pressed


func _ready():
	pressed.connect(_on_pressed)


func _on_pressed():

	print("START RUN BUTTON PRESSED")
	start_run_pressed.emit()
