extends AnimalBase
class_name Enemies

# enemy ai logic goes here

func choose_action(player) -> String:
	if hp > base_hp * 0.5:
		return "protect" if randf() < 0.3 else "attack"
	else:
		return "protect" if randf() < 0.5 else "attack"
		
func take_damage(amount: int):
	
	hp -= amount
	hp = clamp(hp, 0, get_max_hp())

	hp_changed.emit(hp)

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
