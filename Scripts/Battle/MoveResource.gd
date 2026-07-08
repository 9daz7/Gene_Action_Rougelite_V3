extends Resource
class_name MoveResource

@export var move_name:String = "Unamed Move"
@export var power:int = 0
@export var description:String = ""

func execute(user, target):
	print("Executing move:", move_name, " Power:", power)
	
	if move_name == "Protect":
		print(user.name, "protects")
		user.is_protected = true
		return
		
	var damage = user.get_attack() + power
		
	print(
		user.name,
		" uses ",
		move_name,
		" for ",
		damage,
		" damage"
	)
		
	print("Targets:", target)
		
	target.take_damage(damage)
		
		
