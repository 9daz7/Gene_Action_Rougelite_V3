extends Resource
class_name MoveResource

enum MoveCatagory {
	BIOLOGICAL,
	GENETIC
}

@export var move_name:String = "Unamed Move"
@export var power:int = 0
@export var priority:int = 0
@export var description:String = ""

# type of move
@export var catagory: MoveCatagory = MoveCatagory.BIOLOGICAL

# Chance to hit (future use)
@export var accuracy:int = 100

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
		
	var damage = DamageCalculator.calculate_damage(
		user,
		target,
		self
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
		
		
