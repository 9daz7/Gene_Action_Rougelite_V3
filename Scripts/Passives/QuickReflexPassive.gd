extends PassiveEffect
class_name QuickReflexPassive

@export var speed_gain := 2

func on_battle_start(owner):

	owner.modify_speed(speed_gain)
