extends Resource
class_name StatusEffect

@export var effect_name := ""
@export var turns_remaining := 1

func on_apply(owner):
	pass
	
func on_turn_start(owner):
	pass

func on_turn_end(owner):
	turns_remaining -= 1
	
func on_remove(owner):
	pass
