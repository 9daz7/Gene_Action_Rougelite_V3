extends Button

signal move_selected(move)

var move_resource:MoveResource

func setup(move:MoveResource):

	move_resource = move

	text = move.move_name


func _pressed():

	move_selected.emit(move_resource)
