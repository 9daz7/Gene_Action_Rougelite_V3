extends Resource
class_name MoveResource

enum MoveCategory {
	BIOLOGICAL,
	GENETIC
}

@export var move_name:String = "Unnamed Move"
@export var power:int = 0
@export var description:String = ""

@export var priority:int = 0
@export var accuracy:int = 100

# type of move
@export var category: MoveCategory = MoveCategory.BIOLOGICAL

# Future critical hit system
@export var critical_chance:int = 0

# Effects applied by this move
@export var effects:Array[StatusEffect] = []

func execute(user, target):
	
	print(
		"Executing move:",
		move_name,
		" Priority:",
		priority
		)
	
	if move_name == "Protect":
		print(user.name," uses protect")
		user.activate_protect()
		return
		
	var hit_chance = user.calculate_hit_chance(target, accuracy)
	
	var roll = randi_range(1,100)
	
	print(
		"Accuracy check:",
		roll,
		"/",
		hit_chance
	)
	
	if roll > hit_chance:
		
		print(
			user.name,
			" missed!"
		)
		
		return
		
		
	var damage = user.get_attack() + power
	
	print(
		"Base damage:",
		damage
	)
		
	print(
		user.name,
		" uses ",
		move_name,
		" for ",
		damage,
		" damage"
	)
		
	target.take_damage(damage)
		
		
