extends Node
class_name HealEffect


@export var amount:int = 10


func apply(user,target):

	user.heal(amount)
