extends Resource
class_name MoveResource

@export var move_name:String = "Unamed Move"
@export var power:int = 0
@export var description:String = ""

func execute(user, target):
	if power > 0:
		var damage = user.get_attack() + power
		print(
			user.name,
			" uses ",
			move_name,
			" for ",
			damage,
			" damage"
		)
		
		target.take_damage(damage)
		
		
