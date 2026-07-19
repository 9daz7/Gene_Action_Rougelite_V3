extends Resource
class_name MoveResource


enum MoveCategory {
	BIOLOGICAL,
	GENETIC
}

enum MoveEffectType {
	DAMAGE,
	PROTECT
}

@export var effect_type : MoveEffectType = MoveEffectType.DAMAGE

# --------------------------------------------------
# Basic Move Info
# --------------------------------------------------

@export var move_name: String = "Unnamed Move"
@export var power: int = 0
@export var description: String = ""

# --------------------------------------------------
# Combat
# --------------------------------------------------

@export var priority: int = 0
@export var accuracy: int = 100

# Type of move
@export var category: MoveCategory = MoveCategory.BIOLOGICAL

# Future critical hit system
@export var critical_chance: int = 0

# --------------------------------------------------
# Status Effects
# --------------------------------------------------

@export var effects: Array[StatusEffect] = []


func execute(user, target):
	print(
		"Executing move:",
		move_name,
		" Priority:",
		priority
	)
	
	# -----------------------------------------
	# Protect
	# -----------------------------------------
	
	if effect_type == MoveEffectType.PROTECT:
		print(user.name, " uses protect")
		user.activate_protect()
		return

	# -----------------------------------------
	# Accuracy
	# -----------------------------------------

	var hit_chance = user.calculate_hit_chance(target, accuracy)

	var roll = randi_range(1, 100)

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

	# -----------------------------------------
	# Damage
	# -----------------------------------------

	var damage = user.get_attack() + power

	damage = target.calculate_damage_taken(damage)

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
	
	# -----------------------------------------
	# Apply effects
	# -----------------------------------------
	
	for effect in effects:
		if effect:
			effect.apply(target)
