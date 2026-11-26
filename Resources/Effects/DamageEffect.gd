# TODO: Create a 3D-compatible version of this effect.
# Legacy implementation disabled during 2D cleanup.

#extends Node
#class_name DamageEffect
#
#
#@export var power_bonus:int = 0
#
#
#func apply(user, target):
#
	#var damage = user.get_attack() + power_bonus
#
	#damage = target.calculate_damage_taken(
		#damage
	#)
#
	#target.take_damage(
		#damage,
		#user
	#)
